#include <config.h>

VM_IMAGE(linux_image, XSTR(BAO_DEMOS_WRKDIR_IMGS/linux.bin));
VM_IMAGE(baremetal_image, XSTR(BAO_DEMOS_WRKDIR_IMGS/interference.bin));

struct config config = {
    
    CONFIG_HEADER

    .shmemlist_size = 1,
    .shmemlist = (struct shmem[]) {
        [0] = { .size = 0x00010000, }
    },
    
    .vmlist_size = 2,
    .vmlist = {
        { 
            .image = {
                .base_addr = 0x20000000,
                .load_addr = VM_IMAGE_OFFSET(linux_image),
                .size = VM_IMAGE_SIZE(linux_image)
            },

            .entry = 0x20000000,

            .platform = {
                .cpu_num = 3,
                
                .region_num = 1,
                .regions =  (struct vm_mem_region[]) {
                    {
                        .base = 0x20000000,
                        .size = 0x40000000,
                        .place_phys = true,
                        .phys = 0x20000000
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
                        /* GENET */
                        .pa = 0xfd580000,
                        .va = 0xfd580000,
                        .size = 0x10000,
                        .interrupt_num = 2,
                        .interrupts = (irqid_t[]) {189, 190}  
                    },
                    {   
                        /* Arch timer interrupt */
                        .interrupt_num = 1,
                        .interrupts = 
                            (irqid_t[]) {27}                         
                    }
                },

                .arch = {
                    .gic = {
                        .gicd_addr = 0xff841000,
                        .gicc_addr = 0xff842000,
                    }
                }
            },
        },
        { 
            .image = {
                .base_addr = 0x600000,
                .load_addr = VM_IMAGE_OFFSET(baremetal_image),
                .size = VM_IMAGE_SIZE(baremetal_image)
            },

            .entry = 0x600000,

            .platform = {
                .cpu_num = 4,
                
                .region_num = 1,
                .regions =  (struct vm_mem_region[]) {
                    {
                        .base = 0x600000,
                        .size = 0x4000000 
                    }
                },

                .dev_num = 2,
                .devs =  (struct vm_dev_region[]) {
                    {   
                        /* UART1 */
                        .pa = 0xfe215000,
                        .va = 0xfe215000,
                        .size = 0x1000,
                        .interrupt_num = 1,
                        .interrupts = (irqid_t[]) {125}                        
                    },
                    {   
                        /* Arch timer interrupt */
                        .interrupt_num = 1,
                        .interrupts = 
                            (irqid_t[]) {27}                         
                    }
                },

                .arch = {
                    .gic = {
                        .gicd_addr = 0xff841000,
                        .gicc_addr = 0xff842000,
                    }
                }
            },
        },
    },
};