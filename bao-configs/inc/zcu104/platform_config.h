#define LINUX_BASE_ADDR             0x00200000
#define LINUX_ENTRY                 0x00200000
#define LINUX_CPU_NUM               1
#define LINUX_CPU_AFFIN             0b0001
#define LINUX_MEM_REG_NUM           1
#define LINUX_MEM_BASE              0x00000000
#define LINUX_MEM_SIZE              0x40000000
#define LINUX_CACHE_COLORS          0b00001111

// Devices
#define LINUX_DEV_NUM               3
// Devices - UART
#define LINUX_DEV_UART_PA           0xFF010000
#define LINUX_DEV_UART_VA           0xFF010000
#define LINUX_DEV_UART_SIZE         0x1000
#define LINUX_DEV_UART_IRQ_NUM      1
#define LINUX_DEV_UART_IRQ_ID       54
// Devices - Timer  
#define LINUX_DEV_TIM_IRQ_NUM       1
#define LINUX_DEV_TIM_IRQ_ID        27

// Devices - GEM
#define LINUX_DEV_GEM_SMMU_ID       0x877
#define LINUX_DEV_GEM_PA            0xff0e0000
#define LINUX_DEV_GEM_VA            0xff0e0000
#define LINUX_DEV_GEM_SIZE          0x1000
#define LINUX_DEV_GEM_IRQ_NUM       2
#define LINUX_DEV_GEM_IRQ_ID        95, 96


#define BAREMETAL_BASE_ADDR         0x40000000
#define BAREMETAL_ENTRY             0x40000000
#define BAREMETAL_CPU_NUM           3
#define BAREMETAL_CPU_AFFIN         0b1110
#define BAREMETAL_MEM_REG_NUM       1
#define BAREMETAL_MEM_BASE          0x40000000
#define BAREMETAL_MEM_SIZE          0x8000000
#define BAREMETAL_CACHE_COLORS      0b11110000

// Devices
#define BAREMETAL_DEV_NUM               2
// Devices - UART
#define BAREMETAL_DEV_UART_PA       0xFF000000
#define BAREMETAL_DEV_UART_VA       0xFF000000
#define BAREMETAL_DEV_UART_SIZE     0x1000

// Devices - UART
#define BAREMETAL_DEV_TIM_IRQ_NUM   1
#define BAREMETAL_DEV_TIM_IRQ_ID    27


// GIC
#define LINUX_PLAT_GICC_ADDR        0xF9020000
#define LINUX_PLAT_GICD_ADDR        0xF9010000
#define BAREMETAL_PLAT_GICC_ADDR    0xF902F000
#define BAREMETAL_PLAT_GICD_ADDR    0xF9010000



