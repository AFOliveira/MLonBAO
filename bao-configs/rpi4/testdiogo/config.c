#include <config.h>
VM_IMAGE(hostile_w_image, XSTR(/home/afonso/newtest/evaluation-guests/benchmarks/linux_mibench/build/baremetal.bin));
struct config config = {
    CONFIG_HEADER
    .vmlist_size = 1,
    .vmlist = {
        {
            .entry = 0x40000000,
            .image = {
                .base_addr = 0x40000000,
                .load_addr = VM_IMAGE_OFFSET(hostile_w_image),
                .size = VM_IMAGE_SIZE(hostile_w_image)
            },
            .cpu_affinity = 0b0110,
            .platform = {
                .cpu_num = 3,
                .region_num = 1,
                .regions =  (struct vm_mem_region[]) {
                    {
                        .base = 0x40000000,
                        .size = 0x8000000
                    }
                },
                .dev_num = 2,
                .devs =  (struct vm_dev_region[]) {
                    {  
                        /* UART 0 (mapped at aurt1) */
                        .pa = 0xfe215000,
                        .va = 0xfe215040,
                        .size = 0x1000,                   
                    },
                    {  
                        /* Arch timer interrupt */
                        .interrupt_num = 1,
                        .interrupts =  (irqid_t[]) {27}                        
                    },
                },
                .arch = {
                    .gic = {
                        .gicc_addr = 0xF902f000,
                        .gicd_addr = 0xF9010000
                    },
                }
            },
        },
    }
};