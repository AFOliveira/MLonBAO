MEMORY {
    RAM (rwx) : ORIGIN = 0x80000, LENGTH = 0x1000000
}
ENTRY(_start)
SECTIONS {
    .start : {
        *(.start)
    }
    .text : {
        *(.text*)
    }
    .rodata : {
        *(.rodata*)
    }
    .data : {
        *(.data .data.*)
        PROVIDE(__global_pointer$ = . + 0x800);
        *(.sdata .sdata.* .sdata2.*)
    }
    .bss (NOLOAD) : {
        __bss_start = .;
        *(.bss* .sbss*)
        *(COMMON)
        __bss_end = .;
    }
    . = ALIGN(16);
    PROVIDE(_stack_base = .);
    . = . + 2M;
    PROVIDE(_heap_base = .);
}
