#include <config.h>
#include <platform_config.h>

VM_IMAGE(linux_image, "../wrkdir/imgs/linux.bin");
VM_IMAGE(baremetal_image, "../wrkdir/imgs/baremetal.bin")

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
                .base_addr = BAREMETAL_BASE_ADDR,
                .load_addr = VM_IMAGE_OFFSET(baremetal_image),
                .size = VM_IMAGE_SIZE(baremetal_image)
            },

            .entry = BAREMETAL_ENTRY,
            .colors = BAREMETAL_CACHE_COLORS,
            .platform = {
                .cpu_num = BAREMETAL_CPU_NUM,
                
                .region_num = BAREMETAL_MEM_REG_NUM,
                .regions =  (struct vm_mem_region[]) {
                    {
                        .base = BAREMETAL_MEM_BASE,
                        .size = BAREMETAL_MEM_SIZE 
                    }
                },

                .dev_num = BAREMETAL_DEV_NUM,
                .devs =  (struct vm_dev_region[]) {
                    {   
                        /* UART1 */
                        .pa = BAREMETAL_DEV_UART_PA,
                        .va = BAREMETAL_DEV_UART_VA,
                        .size = BAREMETAL_DEV_UART_SIZE,
                        .interrupt_num = BAREMETAL_DEV_UART_IRQ_NUM,
                        .interrupts = (irqid_t[]) {BAREMETAL_DEV_UART_IRQ_ID}                        
                    },
                    {   
                        /* Arch timer interrupt */
                        .interrupt_num = BAREMETAL_DEV_TIM_IRQ_NUM,
                        .interrupts = 
                            (irqid_t[]) {BAREMETAL_DEV_TIM_IRQ_ID}                         
                    }
                },

                .arch = {
                    .gic = {
                        .gicd_addr = BAREMETAL_PLAT_GICD_ADDR,
                        .gicc_addr = BAREMETAL_PLAT_GICC_ADDR,
                    }
                }
            },
        },
        { 
            .image = {
                .base_addr = LINUX_BASE_ADDR,
                .load_addr = VM_IMAGE_OFFSET(linux_image),
                .size = VM_IMAGE_SIZE(linux_image),
            },

            .entry = LINUX_ENTRY,
            .colors = LINUX_CACHE_COLORS,
            .platform = {
                .cpu_num = LINUX_CPU_NUM,

                .region_num = LINUX_MEM_REG_NUM,
                .regions =  (struct vm_mem_region[]) {
                    {
                        .base = LINUX_MEM_BASE,
                        .size = LINUX_MEM_SIZE,
                        #ifdef LINUX_MEM_PHYS
                            .place_phys = true,
                            .phys = LINUX_MEM_PHYS
                        #endif
                    },
                },

                .dev_num = LINUX_DEV_NUM,
                .devs =  (struct vm_dev_region[]) {
                    #ifdef LINUX_DEV_UART_PA
                        {   
                            /* UART1 */
                            .pa = LINUX_DEV_UART_PA,
                            .va = LINUX_DEV_UART_VA,
                            .size = LINUX_DEV_UART_SIZE,
                            .interrupt_num = LINUX_DEV_UART_IRQ_NUM,
                            .interrupts = 
                                (irqid_t[]) {LINUX_DEV_UART_IRQ_ID}                         
                        },
                    #endif
                    {   
                        /* Arch timer interrupt */
                        .interrupt_num = LINUX_DEV_TIM_IRQ_NUM,
                        .interrupts = 
                            (irqid_t[]) {LINUX_DEV_TIM_IRQ_ID}                         
                    },
                    {
                        /* GEM3 */
                        #ifdef LINUX_DEV_GEM_SMMU_ID
                            .id = LINUX_DEV_GEM_SMMU_ID,
                        #endif
                        .pa = LINUX_DEV_GEM_PA,
                        .va = LINUX_DEV_GEM_VA,
                        .size = LINUX_DEV_GEM_SIZE,
                        .interrupt_num = LINUX_DEV_GEM_IRQ_NUM,
                        .interrupts = 
                            (irqid_t[]) {LINUX_DEV_GEM_IRQ_ID}                           
                    }
                },

                .arch = {
                    .gic = {
                        .gicc_addr = LINUX_PLAT_GICC_ADDR,
                        .gicd_addr = LINUX_PLAT_GICD_ADDR
                    },
                }
            },
        },
    },
};