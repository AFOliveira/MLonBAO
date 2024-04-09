#include <config.h>
#define BAREMETAL_BASE_ADDR         0x80000
#define BAREMETAL_ENTRY             0x80000
#define BAREMETAL_CPU_NUM           3
#define BAREMETAL_CPU_AFFIN         0b1110
#define BAREMETAL_MEM_REG_NUM       1
#define BAREMETAL_MEM_BASE          0x80000
#define BAREMETAL_MEM_SIZE          0x1000000
#define BAREMETAL_CACHE_COLORS      0b11110000
// Devices
#define BAREMETAL_DEV_NUM               2
// Devices - UART
#define BAREMETAL_DEV_UART_PA       0xfe215000
#define BAREMETAL_DEV_UART_VA       0xfe215000
#define BAREMETAL_DEV_UART_SIZE     0x1000
#define BAREMETAL_DEV_UART_IRQ_NUM  1
#define BAREMETAL_DEV_UART_IRQ_ID   125
// Devices - UART
#define BAREMETAL_DEV_TIM_IRQ_NUM   1
#define BAREMETAL_DEV_TIM_IRQ_ID    27




VM_IMAGE(linux_image, XSTR(/home/afonso/newtest/evaluation-guests/benchmarks/linux_mibench/build/linux.bin));
VM_IMAGE(baremetal_image, XSTR(/home/afonso/newtest/evaluation-guests/benchmarks/linux_mibench/build/baremetal.bin));

struct config config = {
    
    CONFIG_HEADER

    // .shmemlist_size = 1,
    // .shmemlist = (struct shmem[]) {
    //     [0] = { .size = 0x00010000, }
    // },
    
    .vmlist_size = 1,
    .vmlist = {
       { 
	.image = {
                .base_addr = 0x20000000,
                .load_addr = VM_IMAGE_OFFSET(linux_image),
                .size = VM_IMAGE_SIZE(linux_image)
            },

            .entry = 0x20000000,
            .cpu_affinity=0b0001,
            .platform = {
                .cpu_num = 1,
                
                .region_num = 1,
                .regions =  (struct vm_mem_region[]) {
                    {
                        .base = 0x20000000,
                        .size = 0x40000000,
                        .place_phys = true,
                        .phys = 0x20000000
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
                .base_addr = BAREMETAL_BASE_ADDR,
                .load_addr = VM_IMAGE_OFFSET(baremetal_image),
                .size = VM_IMAGE_SIZE(baremetal_image)
            },
            .entry = BAREMETAL_ENTRY,
            //.cpu_affinity=0b1111,
            .platform = {
                .cpu_num = 3,
                .region_num = 1,
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
                        .gicd_addr = 0xff841000,
                        .gicc_addr = 0xff842000,
                    }
                }
            },
        }
    },
};
