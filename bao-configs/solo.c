#include <config.h>
#include <platform_config.h>

VM_IMAGE(linux_image, "../wrkdir/imgs/linux.bin");

struct config config = {
    
    CONFIG_HEADER
    
    .vmlist_size = 1,
    .vmlist = {
        { 
            .image = {
                .base_addr = LINUX_BASE_ADDR,
                .load_addr = VM_IMAGE_OFFSET(linux_image),
                .size = VM_IMAGE_SIZE(linux_image),
            },

            .entry = LINUX_ENTRY,
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
