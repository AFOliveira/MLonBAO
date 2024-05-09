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

spinlock_t print_lock = SPINLOCK_INITVAL;

#define NUM_CPUS   (3)

#define INTERF_BUF_SIZE (0x100000)
#define CACHE_LINE (64)
#define CPU_INTERF_BUF_SIZE (INTERF_BUF_SIZE/NUM_CPUS)
volatile uint64_t interf_buf[NUM_CPUS][CPU_INTERF_BUF_SIZE/sizeof(uint64_t)]  __attribute__((aligned(INTERF_BUF_SIZE)));

#define INTERF_READ     1
#define INTERF_WRITE    1

void main(void){

    static volatile bool master_done = false;
    static size_t cpu_num = 0;
    static volatile size_t buf_index_ticket = 0;
    size_t buf_index;

    spin_lock(&print_lock);
    buf_index = buf_index_ticket;
    buf_index_ticket += 1;
    spin_unlock(&print_lock);

    if(buf_index >= NUM_CPUS) return;

    spin_lock(&print_lock);
    printf("cpu %d up\n", get_cpuid());
    spin_unlock(&print_lock);

    const size_t bufid = buf_index;
    const size_t range = CPU_INTERF_BUF_SIZE/sizeof(uint64_t);
    const size_t stride = CACHE_LINE/sizeof(uint64_t);
    const size_t base = 0;

    while(true) {

        #if(INTERF_WRITE)
            /* -------------------- WRITE ----------------------------- */
            for(size_t i = base; i < (base+range); i += stride) {
                interf_buf[bufid][i] = i;
            }
        #endif

        #if(INTERF_READ)
            /* -------------------- READ ----------------------------- */
            for(size_t i = base; i < (base+range); i += stride) {
                (void)interf_buf[bufid][i];
            }
        #endif

    }
}
