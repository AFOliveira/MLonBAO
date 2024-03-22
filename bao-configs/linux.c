#include <config.h>

VM_IMAGE(linux_image, XSTR(BAO_DEMOS_WRKDIR_IMGS/linux.bin));

struct config config = {
    
    CONFIG_HEADER

    .shmemlist_size = 1,
    .shmemlist = (struct shmem[]) {
        [0] = { .size = 0x00010000, }
    },

    .vmlist_size = 1,
    .vmlist = {
        { 
            .image = {
                .base_addr = 0x80000000,
                .load_addr = VM_IMAGE_OFFSET(linux_image),
                .size = VM_IMAGE_SIZE(linux_image)
            },

            .entry = 0x80000000,

            .platform = {
                .cpu_num = 2,
                
                .region_num = 1,
                .regions =  (struct vm_mem_region[]) {
                    {
                        .base = 0x80000000,
                        .size = 0x40000000,
                        .place_phys = true,
                        .phys = 0x80000000
                    }
                },

                .ipc_num = 1,
                .ipcs = (struct ipc[]) {
                    {
                        .base = 0xf0000000,
                        .size = 0x00010000,
                        .shmem_id = 0,
                        .interrupt_num = 1,
                        .interrupts = (irqid_t[]) {52}
                    }
                },

                .dev_num = 2,
                .devs =  (struct vm_dev_region[]) {
                    {   
                        /* Arch timer interrupt */
                        .interrupt_num = 1,
                        .interrupts = (irqid_t[]) {27}                         
                    },
                    {
                        /* virtio devices */
                        .pa = 0xa003000,   
                        .va = 0xa003000,  
                        .size = 0x1000,
                        .interrupt_num = 8,
                        .interrupts = (irqid_t[]) {72,73,74,75,76,77,78,79}
                    },
                },

                .arch = {
                    .gic = {
                       .gicd_addr = 0x8000000,
                       .gicr_addr = 0x80A0000
                    }
                }
            },
        },
    },
};
