/** 
 * Bao, a Lightweight Static Partitioning Hypervisor 
 *
 * Copyright (c) Bao Project (www.bao-project.org), 2019-
 *
 * Authors:
 *      Jose Martins <jose.martins@bao-project.org>
 *      Sandro Pinto <sandro.pinto@bao-project.org>
 *
 * Bao is free software; you can redistribute it and/or modify it under the
 * terms of the GNU General Public License version 2 as published by the Free
 * Software Foundation, with a special exception exempting guest code from such
 * license. See the COPYING file in the top-level directory for details. 
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <cpu.h>
#include <wfi.h>
#include <spinlock.h>
#include <plat.h>
#include <irq.h>
#include <uart.h>
#include <timer.h>
#include <pmu.h>
#include <gic.h>

#define XSTR(S) STR(S)

#define TIMER_PER   (1)
#define TIMER_INTERVAL (TIME_US(TIMER_PER))
#define NUM_SAMPLES  (200)
#define NUM_WARMUPS  (100)
#define COL_SIZE        20   
#define SAMPLE_FORMAT   "%" XSTR(COL_SIZE) "d"
#define HEADER_FORMAT   "%" XSTR(COL_SIZE) "s"
#define MAX_ITER    10
#define PMU_PARAMS  (6)
volatile size_t sample_count;
uint64_t next_tick;
uint64_t curr_time;

unsigned long irqlat_samples[NUM_SAMPLES];
unsigned long irqlat_end_samples[NUM_SAMPLES];
unsigned long exec_time_samples[NUM_SAMPLES];

#define L2_CACHE_SIZE   (1024*1024)
#define NUM_SUBSETS     (16)
#define SUBSET_SIZE     (L2_CACHE_SIZE/NUM_SUBSETS)
#define CACHE_LINE_SIZE (64)


volatile uint8_t cache_l2[NUM_SUBSETS][SUBSET_SIZE]__attribute__((aligned(L2_CACHE_SIZE)));
// volatile uint8_t cache_l1[L1_CACHE_SIZE] __attribute__((aligned(L1_CACHE_SIZE)));


const size_t sample_events[] = {
    L2D_CACHE_REFILL,
    L2D_CACHE,
    MEM_ACCESS,
    BUS_ACCESS,
    BUS_CYCLES,
};

const size_t sample_events_size = sizeof(sample_events)/sizeof(size_t);
unsigned long pmu_samples[sizeof(sample_events)/sizeof(size_t)][NUM_SAMPLES];
size_t pmu_used_counters = 0;

void pmu_setup_counters(size_t n, const size_t events[]){
    pmu_used_counters = n < pmu_num_counters()? n : pmu_num_counters();
    for(size_t i = 0; i < pmu_used_counters; i++){
        pmu_counter_set_event(i, events[i]);
        pmu_counter_enable(i);
    }
    pmu_cycle_enable(true);
}

void pmu_sample() {
    size_t n = pmu_num_counters();
    for(int i = 0; i < n; i++){
        pmu_samples[i][sample_count] = pmu_counter_get(i);
    }
}

void pmu_setup(size_t start, size_t n) {
    pmu_setup_counters(n, &sample_events[start]);
    pmu_reset();
    pmu_start();
}

static inline void pmu_print_header() {
    for (size_t i = 0; i < pmu_used_counters; i++) {
        uint32_t event = pmu_counter_get_event(i);
        char const * descr =  pmu_event_descr[event & 0xffff]; 
        descr = descr ? descr : "";
        uint32_t priv_code = (event >> 24) & 0xc8;
        const char * priv = priv_code == 0xc8 ? "_el2" : 
                            priv_code == 0x08 ? "_el1+2" :
                            "_el1";
        char buf[COL_SIZE];
        snprintf(buf, COL_SIZE-1, "%s%s", descr, priv);
        printf(HEADER_FORMAT, buf);
    }
    //printf(HEADER_FORMAT, "cycles");
}

static inline void pmu_print_samples(size_t i) {
    for (size_t j = 0; j < pmu_used_counters; j++) {
        printf(SAMPLE_FORMAT, pmu_samples[j][i]);
    }
    //printf(SAMPLE_FORMAT, pmu_samples[31][i]);
}

void print_samples_latency() {

    printf("--------------------------------\n");
    printf(HEADER_FORMAT, "sample");
    printf(HEADER_FORMAT, "execution_cycles");
    pmu_print_header();
    printf("\n");

    for(size_t i = 0; i < NUM_SAMPLES; i++) {
        printf(SAMPLE_FORMAT, i);
        printf(SAMPLE_FORMAT, exec_time_samples[i]);
        pmu_print_samples(i);
        
        printf("\n");
    }
    
}

void timer_handler(unsigned id){

    timer_disable();
    next_tick = timer_set(TIMER_INTERVAL);
    asm volatile("ic iallu\n\t");
}

void warmup_caches()
{
    for(int warm_samp = 0; warm_samp< NUM_WARMUPS; warm_samp++)
        for(int i=0; i<NUM_SUBSETS; i++){
            for (size_t j = 0; j < SUBSET_SIZE; j+= CACHE_LINE_SIZE) {
                cache_l2[i][j] = j;
            }
        }
}

void main(void){

    if(!cpu_is_master()) {
        return;
    }

    unsigned long initial_cycle = 0;
    unsigned long final_cycle = 0;
    unsigned long exec_cycles = 0;

    int num_acc_subsets = 10;
 
    while(1) {
        printf("Press 's' to start...\n");
        while(uart_getchar() != 's');

        printf("\nTesting %d/%d subsets\n", num_acc_subsets, NUM_SUBSETS);        

        warmup_caches();
        size_t i = 0;
        while(i < sample_events_size){

            sample_count = 0;
            pmu_setup(i, sample_events_size - i);

            while(sample_count < NUM_SAMPLES) {
                pmu_reset();
                initial_cycle = pmu_cycle_get();
                for(size_t it_idx = 0; it_idx < MAX_ITER; it_idx++){
                    for(int i=0; i<num_acc_subsets; i++){
                        for (size_t j = 0; j < SUBSET_SIZE; j+= CACHE_LINE_SIZE) {
                            cache_l2[i][j] = j;
                        }
                    }
                }
                final_cycle = pmu_cycle_get();
                pmu_sample();
                exec_cycles = final_cycle - initial_cycle;
                exec_time_samples[sample_count] = exec_cycles;
                sample_count++;
            }
        
            i += pmu_num_counters();
            print_samples_latency();
        }
    }
}


