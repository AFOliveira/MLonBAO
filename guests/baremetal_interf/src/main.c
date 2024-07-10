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

#define N_CORES (3)
#define L1_CACHE_SIZE   (333*1024)
#define L2_CACHE_SIZE   (1024*1024)
#define NUM_SUBSETS     (16)
#define SUBSET_SIZE     (L2_CACHE_SIZE/NUM_SUBSETS)
#define CACHE_LINE_SIZE (64)

volatile uint8_t cache_l1[N_CORES][L1_CACHE_SIZE] __attribute__((aligned(L2_CACHE_SIZE)));
volatile uint8_t cache_l2[N_CORES][NUM_SUBSETS][SUBSET_SIZE]__attribute__((aligned(L2_CACHE_SIZE)));
volatile uint64_t exec_time_samples[NUM_SAMPLES];

#define NUM_CPUS   (3)

spinlock_t print_lock = SPINLOCK_INITVAL;


void dummy_cache(uint8_t cpu_id)
{
    uint64_t initial_cycle = 0;
    uint64_t final_cycle = 0;
    uint64_t exec_cycles = 0;

    int num_acc_subsets = 9;

    sample_count=0;
    
    printf("subset %d/16\n", num_acc_subsets);

    while(1){
        for(size_t it_idx = 0; it_idx < MAX_ITER; it_idx++){
            for(int i=0; i<num_acc_subsets; i++){
                for (size_t j = 0; j < SUBSET_SIZE; j+= CACHE_LINE_SIZE) {
                    cache_l2[cpu_id][i][j] = j;
                }
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
