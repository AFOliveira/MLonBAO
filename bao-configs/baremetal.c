#include <config.h>
#include <platform_config.h>

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
    },
};