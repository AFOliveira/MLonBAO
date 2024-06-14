#define LINUX_BASE_ADDR             0x20000000
#define LINUX_ENTRY                 0x20000000
#define LINUX_CPU_NUM               1
#define LINUX_CPU_AFFIN             0b0001
#define LINUX_MEM_REG_NUM           1
#define LINUX_MEM_BASE              0x20000000
#define LINUX_MEM_SIZE              0x40000000
#define LINUX_MEM_PHYS              0x20000000
#define LINUX_CACHE_COLORS          0b1100

// Devices
#define LINUX_DEV_NUM               2
// Devices - Timer  
#define LINUX_DEV_TIM_IRQ_NUM       1
#define LINUX_DEV_TIM_IRQ_ID        27

// Devices - GEM
#define LINUX_DEV_GEM_PA            0xfd580000
#define LINUX_DEV_GEM_VA            0xfd580000
#define LINUX_DEV_GEM_SIZE          0x10000
#define LINUX_DEV_GEM_IRQ_NUM       2
#define LINUX_DEV_GEM_IRQ_ID        189, 190


#define BAREMETAL_BASE_ADDR         0x80000
#define BAREMETAL_ENTRY             0x80000
#define BAREMETAL_CPU_NUM           3
#define BAREMETAL_CPU_AFFIN         0b1110
#define BAREMETAL_MEM_REG_NUM       1
#define BAREMETAL_MEM_BASE          0x80000
#define BAREMETAL_MEM_SIZE          0x1000000
#define BAREMETAL_CACHE_COLORS      0b0011

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


// GIC
#define LINUX_PLAT_GICC_ADDR        0xff842000
#define LINUX_PLAT_GICD_ADDR        0xff841000

#define BAREMETAL_PLAT_GICC_ADDR    0xff842000
#define BAREMETAL_PLAT_GICD_ADDR    0xff841000



