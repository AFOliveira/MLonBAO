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
#define NUM_SAMPLES  (100)
#define NUM_WARMUPS  (100)
#define COL_SIZE        20   
#define SAMPLE_FORMAT   "%" XSTR(COL_SIZE) "d"
#define HEADER_FORMAT   "%" XSTR(COL_SIZE) "s"
#define MAX_ITER    1000
#define PMU_PARAMS  (6)

volatile size_t sample_count;
uint64_t next_tick;
uint64_t curr_time;

#define N_CORES (1)
#define L1_CACHE_SIZE   (333*1024)
#define L2_CACHE_SIZE   (1024*1024)
//#define BUFFER_SIZE   (333*1024)
#define CACHE_LINE_SIZE (64)

volatile uint8_t cache_l1[N_CORES][L1_CACHE_SIZE] __attribute__((aligned(L2_CACHE_SIZE)));
volatile uint64_t exec_time_samples[NUM_SAMPLES];


spinlock_t print_lock = SPINLOCK_INITVAL;


const size_t sample_events[] = {
    L1D_CACHE_REFILL,
    L1D_CACHE,
    L2D_CACHE_REFILL,
    L2D_CACHE,
    MEM_ACCESS,
    BUS_ACCESS,
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

void pmu_sample(size_t sample_idx) {
    size_t n = PMU_PARAMS;
    for(int i = 0; i < n; i++){
        pmu_samples[i][sample_idx] = pmu_counter_get(i);
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

void print_samples_latency(uint64_t cpu_id) {

    printf("--------------------------------\n");
    printf(HEADER_FORMAT, "sample");
    printf(HEADER_FORMAT, "execution cycles");
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

    sample_count++;
    if(sample_count >= (1000000/TIMER_PER))
    {
        spin_lock(&print_lock);
        printf("timer IRQ...\n");
        spin_unlock(&print_lock);

        sample_count = 0;
    }
}

void dummy_cache_pmu(uint8_t cpu_id)
{
    volatile uint64_t initial_cycle = 0;
    volatile uint64_t final_cycle = 0;
    volatile uint64_t exec_cycles = 0;

    pmu_setup(0,PMU_PARAMS);
    volatile size_t counter =0;
    
    while(1){
        pmu_reset();
        initial_cycle = pmu_cycle_get();
        for(size_t it_id = 0; it_id < MAX_ITER; it_id++){
            for (size_t j = 0; j < L1_CACHE_SIZE; j+= CACHE_LINE_SIZE) {
                cache_l1[cpu_id][j] = j;
            }
        }
        final_cycle = pmu_cycle_get();
        pmu_sample(counter);
        exec_cycles = final_cycle - initial_cycle;
        exec_time_samples[counter] = exec_cycles;
        counter++;

        if(counter==NUM_SAMPLES){
            printf("CPU %d\n", cpu_id);
            print_samples_latency(cpu_id);
            counter=0;
        }
        
    }
}

void dummy_cache(uint8_t cpu_id)
{
    uint64_t initial_cycle = 0;
    uint64_t final_cycle = 0;
    uint64_t exec_cycles = 0;

    sample_count=0;
    
    while(1){
        for(size_t it_idx = 0; it_idx < MAX_ITER; it_idx++){
            for (size_t i = 0; i < L1_CACHE_SIZE; i+= CACHE_LINE_SIZE) {
                cache_l1[cpu_id][i] = i;
            }
        }
        sample_count++;

        if(sample_count==NUM_SAMPLES){
            sample_count=0;
        }
        
    }
}

void main(void){
    uint64_t initial_cycle = 0;
    uint64_t final_cycle = 0;
    uint64_t exec_cycles = 0;
    
    uint64_t cpu_id = get_cpuid();

    spin_lock(&print_lock);
    printf("Core %d is up\n", cpu_id);
    spin_unlock(&print_lock);

    dummy_cache(cpu_id);
}


