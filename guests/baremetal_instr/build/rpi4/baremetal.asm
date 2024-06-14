
build/rpi4/baremetal.elf:     file format elf64-littleaarch64


Disassembly of section .start:

0000000000080000 <_start>:
.global _start
_start:

    /* Valid Image header.  */
    /* HW reset vector.  */
    b skip_header
   80000:	14000012 	b	80048 <skip_header>
    nop
   80004:	d503201f 	nop
	...
   80018:	00000008 	.word	0x00000008
	...
   80038:	644d5241 	.word	0x644d5241
	...

0000000000080048 <skip_header>:
    /* RES0  */
    .dword 0
    /* End of Image header.  */

skip_header:
    mrs x0, MPIDR_EL1
   80048:	d53800a0 	mrs	x0, mpidr_el1
    and x0, x0, MPIDR_CPU_MASK
   8004c:	92401c00 	and	x0, x0, #0xff
     * Check current exception level. If in:
     *     - el0 or el3, stop
     *     - el1, proceed
     *     - el2, jump to el1
     */
    mrs x1, currentEL
   80050:	d5384241 	mrs	x1, currentel
    lsr x1, x1, 2
   80054:	d342fc21 	lsr	x1, x1, #2
    cmp x1, 0
   80058:	f100003f 	cmp	x1, #0x0
    b.eq .
   8005c:	54000000 	b.eq	8005c <skip_header+0x14>  // b.none
    cmp x1, 3
   80060:	f1000c3f 	cmp	x1, #0x3
    b.eq .
   80064:	54000000 	b.eq	80064 <skip_header+0x1c>  // b.none
    cmp x1, 1
   80068:	f100043f 	cmp	x1, #0x1
    b.eq _enter_el1
   8006c:	54000100 	b.eq	8008c <_enter_el1>  // b.none
    mov x1, SPSR_EL1t | SPSR_F | SPSR_I | SPSR_A | SPSR_D
   80070:	d2807881 	mov	x1, #0x3c4                 	// #964
    msr spsr_el2, x1
   80074:	d51c4001 	msr	spsr_el2, x1
    mov x1, HCR_RW_BIT
   80078:	d2b00001 	mov	x1, #0x80000000            	// #2147483648
    msr hcr_el2, x1
   8007c:	d51c1101 	msr	hcr_el2, x1
    adr x1, _enter_el1
   80080:	10000061 	adr	x1, 8008c <_enter_el1>
    msr elr_el2, x1
   80084:	d51c4021 	msr	elr_el2, x1
    eret
   80088:	d69f03e0 	eret

000000000008008c <_enter_el1>:

_enter_el1:
    adr x1, _exception_vector
   8008c:	1000bba1 	adr	x1, 81800 <_exception_vector>
    msr	VBAR_EL1, x1
   80090:	d518c001 	msr	vbar_el1, x1

    ldr x1, =MAIR_EL1_DFLT
   80094:	58000621 	ldr	x1, 80158 <clear+0x18>
    msr	MAIR_EL1, x1
   80098:	d518a201 	msr	mair_el1, x1

    ldr x1, =0x0000000000802510
   8009c:	58000621 	ldr	x1, 80160 <clear+0x20>
    msr TCR_EL1, x1
   800a0:	d5182041 	msr	tcr_el1, x1

    adr x1, root_page_table
   800a4:	100bfae1 	adr	x1, 98000 <root_page_table>
    msr TTBR0_EL1, x1
   800a8:	d5182001 	msr	ttbr0_el1, x1

    // Enable floating point
    mov x1, #(3 << 20)
   800ac:	d2a00601 	mov	x1, #0x300000              	// #3145728
    msr CPACR_EL1, x1
   800b0:	d5181041 	msr	cpacr_el1, x1

    //TODO: invalidate caches, bp, .. ?

    tlbi	vmalle1
   800b4:	d508871f 	tlbi	vmalle1
	dsb	nsh
   800b8:	d503379f 	dsb	nsh
	isb
   800bc:	d5033fdf 	isb

    ldr x1, =(SCTLR_RES1 | SCTLR_M | SCTLR_C | SCTLR_I)
   800c0:	58000541 	ldr	x1, 80168 <clear+0x28>
    msr SCTLR_EL1, x1
   800c4:	d5181001 	msr	sctlr_el1, x1

    tlbi	vmalle1
   800c8:	d508871f 	tlbi	vmalle1
	dsb	nsh
   800cc:	d503379f 	dsb	nsh
	isb
   800d0:	d5033fdf 	isb
.pushsection .data
.global master_cpu
master_cpu: .8byte 0x0
master_cpu_set: .8byte 0x0
.popsection
    adr     x1, master_cpu_set
   800d4:	100b08e1 	adr	x1, 961f0 <master_cpu_set>
    mov     x2, 1
   800d8:	d2800022 	mov	x2, #0x1                   	// #1
1:
    ldaxr   x3, [x1]
   800dc:	c85ffc23 	ldaxr	x3, [x1]
    cbnz    x3, skip
   800e0:	b5000163 	cbnz	x3, 8010c <skip>
    stlxr   w3, x2, [x1]
   800e4:	c803fc22 	stlxr	w3, x2, [x1]
    cbnz    w3, 1b
   800e8:	35ffffa3 	cbnz	w3, 800dc <_enter_el1+0x50>
    adr     x1, master_cpu
   800ec:	100b07e1 	adr	x1, 961e8 <master_cpu>
    str     x0, [x1]
   800f0:	f9000020 	str	x0, [x1]

    ldr x16, =__bss_start 
   800f4:	580003f0 	ldr	x16, 80170 <clear+0x30>
    ldr x17, =__bss_end   
   800f8:	58000411 	ldr	x17, 80178 <clear+0x38>
    bl  clear
   800fc:	94000011 	bl	80140 <clear>
    .align 3
wait_flag:
    .dword 0x0
    .popsection

    adr x1, wait_flag
   80100:	100b07c1 	adr	x1, 961f8 <wait_flag>
    mov x2, #1
   80104:	d2800022 	mov	x2, #0x1                   	// #1
    str x2, [x1]
   80108:	f9000022 	str	x2, [x1]

000000000008010c <skip>:

skip:
1:
    adr x1, wait_flag
   8010c:	100b0761 	adr	x1, 961f8 <wait_flag>
    ldr x2, [x1]
   80110:	f9400022 	ldr	x2, [x1]
    cbz x2, 1b
   80114:	b4ffffc2 	cbz	x2, 8010c <skip>

    mov x3, #SPSel_SP							
   80118:	d2800023 	mov	x3, #0x1                   	// #1
	msr SPSEL, x3	
   8011c:	d5184203 	msr	spsel, x3

    ldr x1, =_stack_base
   80120:	58000301 	ldr	x1, 80180 <clear+0x40>
    ldr x2, =STACK_SIZE
   80124:	58000322 	ldr	x2, 80188 <clear+0x48>
    add x1, x1, x2
   80128:	8b020021 	add	x1, x1, x2
#ifndef SINGLE_CORE
    madd x1, x0, x2, x1
   8012c:	9b020401 	madd	x1, x0, x2, x1
#endif
    mov sp, x1
   80130:	9100003f 	mov	sp, x1
   
    //TODO: other c runtime init (ctors, etc...)

    b _init
   80134:	14000370 	b	80ef4 <_init>
    b _exit
   80138:	1400035e 	b	80eb0 <_exit>

000000000008013c <psci_wake_up>:

.global psci_wake_up
psci_wake_up:
    b .
   8013c:	14000000 	b	8013c <psci_wake_up>

0000000000080140 <clear>:

 .func clear
clear:
2:
	cmp	x16, x17			
   80140:	eb11021f 	cmp	x16, x17
	b.ge 1f				
   80144:	5400006a 	b.ge	80150 <clear+0x10>  // b.tcont
	str	xzr, [x16], #8	
   80148:	f800861f 	str	xzr, [x16], #8
	b	2b				
   8014c:	17fffffd 	b	80140 <clear>
1:
	ret
   80150:	d65f03c0 	ret
   80154:	00000000 	udf	#0
   80158:	0004ff00 	.word	0x0004ff00
   8015c:	00000000 	.word	0x00000000
   80160:	00802510 	.word	0x00802510
   80164:	00000000 	.word	0x00000000
   80168:	30c51835 	.word	0x30c51835
   8016c:	00000000 	.word	0x00000000
   80170:	00100000 	.word	0x00100000
   80174:	00000000 	.word	0x00000000
   80178:	00303138 	.word	0x00303138
   8017c:	00000000 	.word	0x00000000
   80180:	00303140 	.word	0x00303140
   80184:	00000000 	.word	0x00000000
   80188:	00004000 	.word	0x00004000
   8018c:	00000000 	.word	0x00000000

Disassembly of section .text:

0000000000080800 <pmu_setup_counters>:
    unsigned long pmcr = MRS(PMCR_EL0);
    MSR(PMCR_EL0, pmcr | 0x6);
}

static inline size_t pmu_num_counters() {
    return (size_t) bit_extract(MRS(PMCR_EL0), PMCR_N_OFF, PMCR_N_LEN);
   80800:	d53b9c02 	mrs	x2, pmcr_el0
    return word &= ~(1UL << off);
}

static inline uint64_t bit_extract(uint64_t word, uint64_t off, uint64_t len)
{
    return (word >> off) & BIT_MASK(0, len);
   80804:	d34b3c42 	ubfx	x2, x2, #11, #5
const size_t sample_events_size = sizeof(sample_events)/sizeof(size_t);
unsigned long pmu_samples[sizeof(sample_events)/sizeof(size_t)][NUM_SAMPLES];
size_t pmu_used_counters = 0;

void pmu_setup_counters(size_t n, const size_t events[]){
    pmu_used_counters = n < pmu_num_counters()? n : pmu_num_counters();
   80808:	eb02001f 	cmp	x0, x2
   8080c:	54000063 	b.cc	80818 <pmu_setup_counters+0x18>  // b.lo, b.ul, b.last
   80810:	d53b9c00 	mrs	x0, pmcr_el0
   80814:	d34b3c00 	ubfx	x0, x0, #11, #5
   80818:	90000403 	adrp	x3, 100000 <pmu_used_counters>
   8081c:	f9000060 	str	x0, [x3]
    for(size_t i = 0; i < pmu_used_counters; i++){
   80820:	b40001c0 	cbz	x0, 80858 <pmu_setup_counters+0x58>
   80824:	91000063 	add	x3, x3, #0x0
   80828:	d2800000 	mov	x0, #0x0                   	// #0
    //barrier?
    MSR(PMXEVCNTR_EL0, value);
}

static inline void pmu_counter_enable(size_t counter) {
    MSR(PMCNTENSET_EL0, 1UL << counter);
   8082c:	d2800024 	mov	x4, #0x1                   	// #1
        pmu_counter_set_event(i, events[i]);
   80830:	f8607822 	ldr	x2, [x1, x0, lsl #3]
    MSR(PMSELR_EL0, counter);
   80834:	d51b9ca0 	msr	pmselr_el0, x0
    DMB(ish);
}

static inline void fence_sync_write()
{
    DSB(ishst);
   80838:	d5033a9f 	dsb	ishst
    MSR(PMXEVTYPER_EL0, event);
   8083c:	d51b9d22 	msr	pmxevtyper_el0, x2
    MSR(PMCNTENSET_EL0, 1UL << counter);
   80840:	9ac02082 	lsl	x2, x4, x0
   80844:	d51b9c22 	msr	pmcntenset_el0, x2
    for(size_t i = 0; i < pmu_used_counters; i++){
   80848:	f9400062 	ldr	x2, [x3]
   8084c:	91000400 	add	x0, x0, #0x1
   80850:	eb00005f 	cmp	x2, x0
   80854:	54fffee8 	b.hi	80830 <pmu_setup_counters+0x30>  // b.pmore
}

static inline void pmu_cycle_enable(bool en){
    uint64_t val = (1ULL << 31);
    if(en){
        MSR(PMCNTENSET_EL0, val);
   80858:	d2b00000 	mov	x0, #0x80000000            	// #2147483648
   8085c:	d51b9c20 	msr	pmcntenset_el0, x0
        pmu_counter_enable(i);
    }
    pmu_cycle_enable(true);
}
   80860:	d65f03c0 	ret

0000000000080864 <pmu_sample>:
    return (size_t) bit_extract(MRS(PMCR_EL0), PMCR_N_OFF, PMCR_N_LEN);
   80864:	d53b9c00 	mrs	x0, pmcr_el0
   80868:	d34b3c06 	ubfx	x6, x0, #11, #5

void pmu_sample() {
    size_t n = pmu_num_counters();
    for(int i = 0; i < n; i++){
   8086c:	f275101f 	tst	x0, #0xf800
   80870:	54000240 	b.eq	808b8 <pmu_sample+0x54>  // b.none
   80874:	90000405 	adrp	x5, 100000 <pmu_used_counters>
   80878:	90000404 	adrp	x4, 100000 <pmu_used_counters>
   8087c:	910000a5 	add	x5, x5, #0x0
   80880:	91198084 	add	x4, x4, #0x660
   80884:	d2800001 	mov	x1, #0x0                   	// #0
        pmu_samples[i][sample_count] = pmu_counter_get(i);
   80888:	f94004a3 	ldr	x3, [x5, #8]
    MSR(PMSELR_EL0, counter);
   8088c:	d51b9ca1 	msr	pmselr_el0, x1
    return MRS(PMXEVCNTR_EL0);
   80890:	d53b9d42 	mrs	x2, pmxevcntr_el0
   80894:	937f7c20 	sbfiz	x0, x1, #1, #32
   80898:	8b21c000 	add	x0, x0, w1, sxtw
   8089c:	d37df000 	lsl	x0, x0, #3
   808a0:	8b21c000 	add	x0, x0, w1, sxtw
    for(int i = 0; i < n; i++){
   808a4:	91000421 	add	x1, x1, #0x1
        pmu_samples[i][sample_count] = pmu_counter_get(i);
   808a8:	8b000c60 	add	x0, x3, x0, lsl #3
   808ac:	f8207882 	str	x2, [x4, x0, lsl #3]
    for(int i = 0; i < n; i++){
   808b0:	eb06003f 	cmp	x1, x6
   808b4:	54fffea1 	b.ne	80888 <pmu_sample+0x24>  // b.any
    }
}
   808b8:	d65f03c0 	ret
   808bc:	d503201f 	nop

00000000000808c0 <pmu_setup>:

void pmu_setup(size_t start, size_t n) {
   808c0:	aa0003e3 	mov	x3, x0
    pmu_setup_counters(n, &sample_events[start]);
   808c4:	900000a2 	adrp	x2, 94000 <__any_on>
   808c8:	913dc042 	add	x2, x2, #0xf70
void pmu_setup(size_t start, size_t n) {
   808cc:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   808d0:	aa0103e0 	mov	x0, x1
   808d4:	910003fd 	mov	x29, sp
    pmu_setup_counters(n, &sample_events[start]);
   808d8:	8b030c41 	add	x1, x2, x3, lsl #3
   808dc:	97ffffc9 	bl	80800 <pmu_setup_counters>
    unsigned long pmcr = MRS(PMCR_EL0);
   808e0:	d53b9c00 	mrs	x0, pmcr_el0
    MSR(PMCR_EL0, pmcr | 0x6);
   808e4:	b27f0400 	orr	x0, x0, #0x6
   808e8:	d51b9c00 	msr	pmcr_el0, x0
    MSR(PMCR_EL0, 0x1);
   808ec:	52800020 	mov	w0, #0x1                   	// #1
   808f0:	d51b9c00 	msr	pmcr_el0, x0
    pmu_reset();
    pmu_start();
}
   808f4:	a8c17bfd 	ldp	x29, x30, [sp], #16
   808f8:	d65f03c0 	ret
   808fc:	d503201f 	nop

0000000000080900 <print_samples_latency>:
        printf(SAMPLE_FORMAT, pmu_samples[j][i]);
    }
    //printf(SAMPLE_FORMAT, pmu_samples[31][i]);
}

void print_samples_latency() {
   80900:	a9b97bfd 	stp	x29, x30, [sp, #-112]!

    printf("--------------------------------\n");
   80904:	900000a0 	adrp	x0, 94000 <__any_on>
   80908:	91372000 	add	x0, x0, #0xdc8
void print_samples_latency() {
   8090c:	910003fd 	mov	x29, sp
   80910:	a90153f3 	stp	x19, x20, [sp, #16]
    printf(HEADER_FORMAT, "sample");
   80914:	900000b3 	adrp	x19, 94000 <__any_on>
   80918:	9137e273 	add	x19, x19, #0xdf8
void print_samples_latency() {
   8091c:	a9025bf5 	stp	x21, x22, [sp, #32]
    for (size_t i = 0; i < pmu_used_counters; i++) {
   80920:	90000416 	adrp	x22, 100000 <pmu_used_counters>
void print_samples_latency() {
   80924:	a90363f7 	stp	x23, x24, [sp, #48]
   80928:	a9046bf9 	stp	x25, x26, [sp, #64]
    printf("--------------------------------\n");
   8092c:	9400063d 	bl	82220 <puts>
    printf(HEADER_FORMAT, "sample");
   80930:	aa1303e0 	mov	x0, x19
   80934:	900000a1 	adrp	x1, 94000 <__any_on>
   80938:	9137c021 	add	x1, x1, #0xdf0
   8093c:	940005d1 	bl	82080 <printf>
    printf(HEADER_FORMAT, "execution_cycles");
   80940:	aa1303e0 	mov	x0, x19
   80944:	900000a1 	adrp	x1, 94000 <__any_on>
   80948:	91380021 	add	x1, x1, #0xe00
   8094c:	940005cd 	bl	82080 <printf>
    for (size_t i = 0; i < pmu_used_counters; i++) {
   80950:	f94002c0 	ldr	x0, [x22]
   80954:	910002d6 	add	x22, x22, #0x0
   80958:	b4000500 	cbz	x0, 809f8 <print_samples_latency+0xf8>
   8095c:	900000b8 	adrp	x24, 94000 <__any_on>
   80960:	900000b7 	adrp	x23, 94000 <__any_on>
        descr = descr ? descr : "";
   80964:	900000b5 	adrp	x21, 94000 <__any_on>
        const char * priv = priv_code == 0xc8 ? "_el2" : 
   80968:	900000b4 	adrp	x20, 94000 <__any_on>
   8096c:	900000b9 	adrp	x25, 94000 <__any_on>
   80970:	913dc318 	add	x24, x24, #0xf70
   80974:	913862f7 	add	x23, x23, #0xe18
        descr = descr ? descr : "";
   80978:	9137a2b5 	add	x21, x21, #0xde8
        const char * priv = priv_code == 0xc8 ? "_el2" : 
   8097c:	9136c294 	add	x20, x20, #0xdb0
   80980:	91370339 	add	x25, x25, #0xdc0
    for (size_t i = 0; i < pmu_used_counters; i++) {
   80984:	d280001a 	mov	x26, #0x0                   	// #0
    MSR(PMSELR_EL0, counter);
   80988:	d51b9cba 	msr	pmselr_el0, x26
   8098c:	d5033a9f 	dsb	ishst
    return MRS(PMXEVTYPER_EL0);
   80990:	d53b9d24 	mrs	x4, pmxevtyper_el0
        char const * descr =  pmu_event_descr[event & 0xffff]; 
   80994:	9100c301 	add	x1, x24, #0x30
   80998:	92403c83 	and	x3, x4, #0xffff
        uint32_t priv_code = (event >> 24) & 0xc8;
   8099c:	52801905 	mov	w5, #0xc8                  	// #200
        const char * priv = priv_code == 0xc8 ? "_el2" : 
   809a0:	900000a0 	adrp	x0, 94000 <__any_on>
        uint32_t priv_code = (event >> 24) & 0xc8;
   809a4:	0a4460a5 	and	w5, w5, w4, lsr #24
        const char * priv = priv_code == 0xc8 ? "_el2" : 
   809a8:	9136e006 	add	x6, x0, #0xdb8
        char const * descr =  pmu_event_descr[event & 0xffff]; 
   809ac:	f8637823 	ldr	x3, [x1, x3, lsl #3]
        snprintf(buf, COL_SIZE-1, "%s%s", descr, priv);
   809b0:	aa1703e2 	mov	x2, x23
   809b4:	910163e0 	add	x0, sp, #0x58
    for (size_t i = 0; i < pmu_used_counters; i++) {
   809b8:	9100075a 	add	x26, x26, #0x1
        descr = descr ? descr : "";
   809bc:	f100007f 	cmp	x3, #0x0
        const char * priv = priv_code == 0xc8 ? "_el2" : 
   809c0:	aa1403e4 	mov	x4, x20
        descr = descr ? descr : "";
   809c4:	9a8302a3 	csel	x3, x21, x3, eq	// eq = none
        snprintf(buf, COL_SIZE-1, "%s%s", descr, priv);
   809c8:	d2800261 	mov	x1, #0x13                  	// #19
        const char * priv = priv_code == 0xc8 ? "_el2" : 
   809cc:	710320bf 	cmp	w5, #0xc8
   809d0:	54000060 	b.eq	809dc <print_samples_latency+0xdc>  // b.none
   809d4:	710020bf 	cmp	w5, #0x8
   809d8:	9a9900c4 	csel	x4, x6, x25, eq	// eq = none
        snprintf(buf, COL_SIZE-1, "%s%s", descr, priv);
   809dc:	94000791 	bl	82820 <snprintf>
        printf(HEADER_FORMAT, buf);
   809e0:	910163e1 	add	x1, sp, #0x58
   809e4:	aa1303e0 	mov	x0, x19
   809e8:	940005a6 	bl	82080 <printf>
    for (size_t i = 0; i < pmu_used_counters; i++) {
   809ec:	f94002c0 	ldr	x0, [x22]
   809f0:	eb00035f 	cmp	x26, x0
   809f4:	54fffca3 	b.cc	80988 <print_samples_latency+0x88>  // b.lo, b.ul, b.last
    pmu_print_header();
    printf("\n");
   809f8:	90000418 	adrp	x24, 100000 <pmu_used_counters>
   809fc:	900000b5 	adrp	x21, 94000 <__any_on>

    for(size_t i = 0; i < NUM_SAMPLES; i++) {
        printf(SAMPLE_FORMAT, i);
        printf(SAMPLE_FORMAT, exec_time_samples[i]);
   80a00:	910042d9 	add	x25, x22, #0x10
   80a04:	91198318 	add	x24, x24, #0x660
   80a08:	913882b5 	add	x21, x21, #0xe20
    for(size_t i = 0; i < NUM_SAMPLES; i++) {
   80a0c:	d2800017 	mov	x23, #0x0                   	// #0
    printf("\n");
   80a10:	52800140 	mov	w0, #0xa                   	// #10
   80a14:	940005bf 	bl	82110 <putchar>
        printf(SAMPLE_FORMAT, i);
   80a18:	aa1703e1 	mov	x1, x23
   80a1c:	aa1503e0 	mov	x0, x21
   80a20:	94000598 	bl	82080 <printf>
        printf(SAMPLE_FORMAT, exec_time_samples[i]);
   80a24:	f8777b21 	ldr	x1, [x25, x23, lsl #3]
   80a28:	aa1503e0 	mov	x0, x21
   80a2c:	94000595 	bl	82080 <printf>
    for (size_t j = 0; j < pmu_used_counters; j++) {
   80a30:	f94002c0 	ldr	x0, [x22]
   80a34:	b4000160 	cbz	x0, 80a60 <print_samples_latency+0x160>
   80a38:	aa1803f4 	mov	x20, x24
   80a3c:	d2800013 	mov	x19, #0x0                   	// #0
        printf(SAMPLE_FORMAT, pmu_samples[j][i]);
   80a40:	f9400281 	ldr	x1, [x20]
   80a44:	aa1503e0 	mov	x0, x21
    for (size_t j = 0; j < pmu_used_counters; j++) {
   80a48:	91000673 	add	x19, x19, #0x1
   80a4c:	91190294 	add	x20, x20, #0x640
        printf(SAMPLE_FORMAT, pmu_samples[j][i]);
   80a50:	9400058c 	bl	82080 <printf>
    for (size_t j = 0; j < pmu_used_counters; j++) {
   80a54:	f94002c0 	ldr	x0, [x22]
   80a58:	eb00027f 	cmp	x19, x0
   80a5c:	54ffff23 	b.cc	80a40 <print_samples_latency+0x140>  // b.lo, b.ul, b.last
        pmu_print_samples(i);
        
        printf("\n");
   80a60:	52800140 	mov	w0, #0xa                   	// #10
    for(size_t i = 0; i < NUM_SAMPLES; i++) {
   80a64:	910006f7 	add	x23, x23, #0x1
        printf("\n");
   80a68:	940005aa 	bl	82110 <putchar>
    for(size_t i = 0; i < NUM_SAMPLES; i++) {
   80a6c:	91002318 	add	x24, x24, #0x8
   80a70:	f10322ff 	cmp	x23, #0xc8
   80a74:	54fffd21 	b.ne	80a18 <print_samples_latency+0x118>  // b.any
    }
    
}
   80a78:	a94153f3 	ldp	x19, x20, [sp, #16]
   80a7c:	a9425bf5 	ldp	x21, x22, [sp, #32]
   80a80:	a94363f7 	ldp	x23, x24, [sp, #48]
   80a84:	a9446bf9 	ldp	x25, x26, [sp, #64]
   80a88:	a8c77bfd 	ldp	x29, x30, [sp], #112
   80a8c:	d65f03c0 	ret

0000000000080a90 <timer_handler>:

extern uint64_t TIMER_FREQ;

static inline void timer_disable()
{
    MSR(CNTV_CTL_EL0, 0);
   80a90:	52800000 	mov	w0, #0x0                   	// #0
   80a94:	d51be320 	msr	cntv_ctl_el0, x0

void timer_handler(unsigned id){

    timer_disable();
    next_tick = timer_set(TIMER_INTERVAL);
   80a98:	d0001400 	adrp	x0, 302000 <irq_handlers+0x1370>
   80a9c:	d2869b61 	mov	x1, #0x34db                	// #13531
   80aa0:	f2baf6c1 	movk	x1, #0xd7b6, lsl #16
   80aa4:	f9465400 	ldr	x0, [x0, #3240]
   80aa8:	f2dbd041 	movk	x1, #0xde82, lsl #32
   80aac:	f2e86361 	movk	x1, #0x431b, lsl #48
   80ab0:	9bc17c00 	umulh	x0, x0, x1
   80ab4:	d352fc00 	lsr	x0, x0, #18
}


static inline uint64_t timer_set(uint64_t n)
{
    MSR(CNTV_TVAL_EL0, n);
   80ab8:	d51be300 	msr	cntv_tval_el0, x0
    MSR(CNTV_CTL_EL0, 1);
   80abc:	52800020 	mov	w0, #0x1                   	// #1
   80ac0:	d51be320 	msr	cntv_ctl_el0, x0
    return MRS(CNTV_CVAL_EL0);
   80ac4:	d53be341 	mrs	x1, cntv_cval_el0
   80ac8:	90000400 	adrp	x0, 100000 <pmu_used_counters>
   80acc:	f9032801 	str	x1, [x0, #1616]
    asm volatile("ic iallu\n\t");
   80ad0:	d508751f 	ic	iallu
}
   80ad4:	d65f03c0 	ret
   80ad8:	d503201f 	nop
   80adc:	d503201f 	nop

0000000000080ae0 <warmup_caches>:

void warmup_caches()
{
    for(int warm_samp = 0; warm_samp< NUM_WARMUPS; warm_samp++)
   80ae0:	90000c04 	adrp	x4, 200000 <cache_l2>
   80ae4:	91000084 	add	x4, x4, #0x0
        for(int i=0; i<NUM_SUBSETS; i++){
   80ae8:	52800c85 	mov	w5, #0x64                  	// #100
   80aec:	52800003 	mov	w3, #0x0                   	// #0
            for (size_t j = 0; j < SUBSET_SIZE; j+= CACHE_LINE_SIZE) {
                cache_l2[i][j] = j;
   80af0:	93707c62 	sbfiz	x2, x3, #16, #32
            for (size_t j = 0; j < SUBSET_SIZE; j+= CACHE_LINE_SIZE) {
   80af4:	d2800000 	mov	x0, #0x0                   	// #0
                cache_l2[i][j] = j;
   80af8:	8b020082 	add	x2, x4, x2
   80afc:	d503201f 	nop
   80b00:	12001c01 	and	w1, w0, #0xff
   80b04:	38206841 	strb	w1, [x2, x0]
            for (size_t j = 0; j < SUBSET_SIZE; j+= CACHE_LINE_SIZE) {
   80b08:	91010000 	add	x0, x0, #0x40
   80b0c:	f140401f 	cmp	x0, #0x10, lsl #12
   80b10:	54ffff81 	b.ne	80b00 <warmup_caches+0x20>  // b.any
        for(int i=0; i<NUM_SUBSETS; i++){
   80b14:	11000463 	add	w3, w3, #0x1
   80b18:	7100407f 	cmp	w3, #0x10
   80b1c:	54fffea1 	b.ne	80af0 <warmup_caches+0x10>  // b.any
    for(int warm_samp = 0; warm_samp< NUM_WARMUPS; warm_samp++)
   80b20:	710004a5 	subs	w5, w5, #0x1
   80b24:	54fffe41 	b.ne	80aec <warmup_caches+0xc>  // b.any
            }
        }
}
   80b28:	d65f03c0 	ret
   80b2c:	00000000 	udf	#0

0000000000080b30 <main>:
#include <sysregs.h>

extern uint64_t master_cpu;

static inline uint64_t get_cpuid(){
    uint64_t cpuid = MRS(MPIDR_EL1);
   80b30:	d53800a1 	mrs	x1, mpidr_el1
    return cpuid & MPIDR_CPU_MASK;
}

static bool cpu_is_master() {
    return get_cpuid() == master_cpu;
   80b34:	d00000a0 	adrp	x0, 96000 <JIS_state_table+0x70>

void main(void){

    if(!cpu_is_master()) {
   80b38:	f940f400 	ldr	x0, [x0, #488]
   80b3c:	eb21001f 	cmp	x0, w1, uxtb
   80b40:	54000e21 	b.ne	80d04 <main+0x1d4>  // b.any
void main(void){
   80b44:	a9ba7bfd 	stp	x29, x30, [sp, #-96]!
   80b48:	910003fd 	mov	x29, sp
   80b4c:	a90153f3 	stp	x19, x20, [sp, #16]
   80b50:	90000413 	adrp	x19, 100000 <pmu_used_counters>
   80b54:	91000273 	add	x19, x19, #0x0
   80b58:	90000414 	adrp	x20, 100000 <pmu_used_counters>
   80b5c:	91198294 	add	x20, x20, #0x660
   80b60:	a9025bf5 	stp	x21, x22, [sp, #32]
   80b64:	900000b6 	adrp	x22, 94000 <__any_on>
   80b68:	900000b5 	adrp	x21, 94000 <__any_on>
   80b6c:	913902d6 	add	x22, x22, #0xe40
   80b70:	913dc2b5 	add	x21, x21, #0xf70
   80b74:	a90363f7 	stp	x23, x24, [sp, #48]
   80b78:	900000b7 	adrp	x23, 94000 <__any_on>
   80b7c:	9138a2f7 	add	x23, x23, #0xe28
   80b80:	a9046bf9 	stp	x25, x26, [sp, #64]
                    }
                }
                final_cycle = pmu_cycle_get();
                pmu_sample();
                exec_cycles = final_cycle - initial_cycle;
                exec_time_samples[sample_count] = exec_cycles;
   80b84:	91004279 	add	x25, x19, #0x10
            pmu_setup(i, sample_events_size - i);
   80b88:	d28000b8 	mov	x24, #0x5                   	// #5
void main(void){
   80b8c:	a90573fb 	stp	x27, x28, [sp, #80]
   80b90:	90000c1b 	adrp	x27, 200000 <cache_l2>
   80b94:	9100037b 	add	x27, x27, #0x0
        printf("Press 's' to start...\n");
   80b98:	aa1703e0 	mov	x0, x23
   80b9c:	940005a1 	bl	82220 <puts>
        while(uart_getchar() != 's');
   80ba0:	940000f8 	bl	80f80 <uart_getchar>
   80ba4:	12001c00 	and	w0, w0, #0xff
   80ba8:	7101cc1f 	cmp	w0, #0x73
   80bac:	54ffffa1 	b.ne	80ba0 <main+0x70>  // b.any
        printf("\nTesting %d/%d subsets\n", num_acc_subsets, NUM_SUBSETS);        
   80bb0:	aa1603e0 	mov	x0, x22
   80bb4:	52800202 	mov	w2, #0x10                  	// #16
   80bb8:	52800141 	mov	w1, #0xa                   	// #10
   80bbc:	94000531 	bl	82080 <printf>
   80bc0:	52800c84 	mov	w4, #0x64                  	// #100
        for(int i=0; i<NUM_SUBSETS; i++){
   80bc4:	52800003 	mov	w3, #0x0                   	// #0
                cache_l2[i][j] = j;
   80bc8:	93707c62 	sbfiz	x2, x3, #16, #32
            for (size_t j = 0; j < SUBSET_SIZE; j+= CACHE_LINE_SIZE) {
   80bcc:	d2800000 	mov	x0, #0x0                   	// #0
                cache_l2[i][j] = j;
   80bd0:	8b020362 	add	x2, x27, x2
   80bd4:	d503201f 	nop
   80bd8:	12001c01 	and	w1, w0, #0xff
   80bdc:	38206841 	strb	w1, [x2, x0]
            for (size_t j = 0; j < SUBSET_SIZE; j+= CACHE_LINE_SIZE) {
   80be0:	91010000 	add	x0, x0, #0x40
   80be4:	f140401f 	cmp	x0, #0x10, lsl #12
   80be8:	54ffff81 	b.ne	80bd8 <main+0xa8>  // b.any
        for(int i=0; i<NUM_SUBSETS; i++){
   80bec:	11000463 	add	w3, w3, #0x1
   80bf0:	7100407f 	cmp	w3, #0x10
   80bf4:	54fffea1 	b.ne	80bc8 <main+0x98>  // b.any
    for(int warm_samp = 0; warm_samp< NUM_WARMUPS; warm_samp++)
   80bf8:	71000484 	subs	w4, w4, #0x1
   80bfc:	54fffe41 	b.ne	80bc4 <main+0x94>  // b.any
        size_t i = 0;
   80c00:	d280001c 	mov	x28, #0x0                   	// #0
    MSR(PMCR_EL0, 0x1);
   80c04:	5280003a 	mov	w26, #0x1                   	// #1
    pmu_setup_counters(n, &sample_events[start]);
   80c08:	8b1c0ea1 	add	x1, x21, x28, lsl #3
   80c0c:	cb1c0300 	sub	x0, x24, x28
            sample_count = 0;
   80c10:	f900067f 	str	xzr, [x19, #8]
    pmu_setup_counters(n, &sample_events[start]);
   80c14:	97fffefb 	bl	80800 <pmu_setup_counters>
    unsigned long pmcr = MRS(PMCR_EL0);
   80c18:	d53b9c00 	mrs	x0, pmcr_el0
    MSR(PMCR_EL0, pmcr | 0x6);
   80c1c:	b27f0400 	orr	x0, x0, #0x6
   80c20:	d51b9c00 	msr	pmcr_el0, x0
    MSR(PMCR_EL0, 0x1);
   80c24:	d51b9c1a 	msr	pmcr_el0, x26
            while(sample_count < NUM_SAMPLES) {
   80c28:	f9400660 	ldr	x0, [x19, #8]
   80c2c:	f1031c1f 	cmp	x0, #0xc7
   80c30:	540005c8 	b.hi	80ce8 <main+0x1b8>  // b.pmore
    unsigned long pmcr = MRS(PMCR_EL0);
   80c34:	d53b9c00 	mrs	x0, pmcr_el0
    MSR(PMCR_EL0, pmcr | 0x6);
   80c38:	b27f0400 	orr	x0, x0, #0x6
   80c3c:	d51b9c00 	msr	pmcr_el0, x0
    }
}

static inline uint64_t pmu_cycle_get(){
    uint64_t val = 0;
    return MRS(PMCCNTR_EL0);
   80c40:	d53b9d05 	mrs	x5, pmccntr_el0
   80c44:	d2800143 	mov	x3, #0xa                   	// #10
                    for(int i=0; i<num_acc_subsets; i++){
   80c48:	52800004 	mov	w4, #0x0                   	// #0
                            cache_l2[i][j] = j;
   80c4c:	93707c82 	sbfiz	x2, x4, #16, #32
                        for (size_t j = 0; j < SUBSET_SIZE; j+= CACHE_LINE_SIZE) {
   80c50:	d2800000 	mov	x0, #0x0                   	// #0
                            cache_l2[i][j] = j;
   80c54:	8b020362 	add	x2, x27, x2
   80c58:	12001c01 	and	w1, w0, #0xff
   80c5c:	38206841 	strb	w1, [x2, x0]
                        for (size_t j = 0; j < SUBSET_SIZE; j+= CACHE_LINE_SIZE) {
   80c60:	91010000 	add	x0, x0, #0x40
   80c64:	f140401f 	cmp	x0, #0x10, lsl #12
   80c68:	54ffff81 	b.ne	80c58 <main+0x128>  // b.any
                    for(int i=0; i<num_acc_subsets; i++){
   80c6c:	11000484 	add	w4, w4, #0x1
   80c70:	7100289f 	cmp	w4, #0xa
   80c74:	54fffec1 	b.ne	80c4c <main+0x11c>  // b.any
                for(size_t it_idx = 0; it_idx < MAX_ITER; it_idx++){
   80c78:	f1000463 	subs	x3, x3, #0x1
   80c7c:	54fffe61 	b.ne	80c48 <main+0x118>  // b.any
   80c80:	d53b9d01 	mrs	x1, pmccntr_el0
    return (size_t) bit_extract(MRS(PMCR_EL0), PMCR_N_OFF, PMCR_N_LEN);
   80c84:	d53b9c00 	mrs	x0, pmcr_el0
   80c88:	d34b3c02 	ubfx	x2, x0, #11, #5
    for(int i = 0; i < n; i++){
   80c8c:	f275101f 	tst	x0, #0xf800
   80c90:	540001a0 	b.eq	80cc4 <main+0x194>  // b.none
        pmu_samples[i][sample_count] = pmu_counter_get(i);
   80c94:	f9400666 	ldr	x6, [x19, #8]
    MSR(PMSELR_EL0, counter);
   80c98:	d51b9ca3 	msr	pmselr_el0, x3
    return MRS(PMXEVCNTR_EL0);
   80c9c:	d53b9d44 	mrs	x4, pmxevcntr_el0
   80ca0:	937f7c60 	sbfiz	x0, x3, #1, #32
   80ca4:	8b23c000 	add	x0, x0, w3, sxtw
   80ca8:	d37df000 	lsl	x0, x0, #3
   80cac:	8b23c000 	add	x0, x0, w3, sxtw
    for(int i = 0; i < n; i++){
   80cb0:	91000463 	add	x3, x3, #0x1
        pmu_samples[i][sample_count] = pmu_counter_get(i);
   80cb4:	8b000cc0 	add	x0, x6, x0, lsl #3
   80cb8:	f8207a84 	str	x4, [x20, x0, lsl #3]
    for(int i = 0; i < n; i++){
   80cbc:	eb02007f 	cmp	x3, x2
   80cc0:	54fffea1 	b.ne	80c94 <main+0x164>  // b.any
                exec_time_samples[sample_count] = exec_cycles;
   80cc4:	f9400662 	ldr	x2, [x19, #8]
                exec_cycles = final_cycle - initial_cycle;
   80cc8:	cb050021 	sub	x1, x1, x5
                sample_count++;
   80ccc:	f9400660 	ldr	x0, [x19, #8]
                exec_time_samples[sample_count] = exec_cycles;
   80cd0:	f8227b21 	str	x1, [x25, x2, lsl #3]
                sample_count++;
   80cd4:	91000400 	add	x0, x0, #0x1
   80cd8:	f9000660 	str	x0, [x19, #8]
            while(sample_count < NUM_SAMPLES) {
   80cdc:	f9400660 	ldr	x0, [x19, #8]
   80ce0:	f1031c1f 	cmp	x0, #0xc7
   80ce4:	54fffa89 	b.ls	80c34 <main+0x104>  // b.plast
    return (size_t) bit_extract(MRS(PMCR_EL0), PMCR_N_OFF, PMCR_N_LEN);
   80ce8:	d53b9c00 	mrs	x0, pmcr_el0
   80cec:	d34b3c00 	ubfx	x0, x0, #11, #5
            }
        
            i += pmu_num_counters();
   80cf0:	8b00039c 	add	x28, x28, x0
            print_samples_latency();
   80cf4:	97ffff03 	bl	80900 <print_samples_latency>
        while(i < sample_events_size){
   80cf8:	f100139f 	cmp	x28, #0x4
   80cfc:	54fff4e8 	b.hi	80b98 <main+0x68>  // b.pmore
   80d00:	17ffffc2 	b	80c08 <main+0xd8>
   80d04:	d65f03c0 	ret
	...

0000000000080d10 <irq_set_handler>:
#include <stddef.h>

irq_handler_t irq_handlers[IRQ_NUM]; 

void irq_set_handler(unsigned id, irq_handler_t handler){
    if(id < IRQ_NUM)
   80d10:	710ffc1f 	cmp	w0, #0x3ff
   80d14:	54000088 	b.hi	80d24 <irq_set_handler+0x14>  // b.pmore
        irq_handlers[id] = handler;
   80d18:	90001402 	adrp	x2, 300000 <irqlat_end_samples>
   80d1c:	91324042 	add	x2, x2, #0xc90
   80d20:	f8205841 	str	x1, [x2, w0, uxtw #3]
}
   80d24:	d65f03c0 	ret
   80d28:	d503201f 	nop
   80d2c:	d503201f 	nop

0000000000080d30 <irq_handle>:

void irq_handle(unsigned id){
   80d30:	2a0003e1 	mov	w1, w0
    if(id < IRQ_NUM && irq_handlers[id] != NULL)
   80d34:	710ffc1f 	cmp	w0, #0x3ff
   80d38:	540000e8 	b.hi	80d54 <irq_handle+0x24>  // b.pmore
   80d3c:	90001402 	adrp	x2, 300000 <irqlat_end_samples>
   80d40:	91324042 	add	x2, x2, #0xc90
   80d44:	f8615841 	ldr	x1, [x2, w1, uxtw #3]
   80d48:	b4000061 	cbz	x1, 80d54 <irq_handle+0x24>
        irq_handlers[id](id);
   80d4c:	aa0103f0 	mov	x16, x1
   80d50:	d61f0200 	br	x16
}
   80d54:	d65f03c0 	ret
	...

0000000000080d60 <_read>:
#include <cpu.h>
#include <fences.h>
#include <wfi.h>

int _read(int file, char *ptr, int len)
{
   80d60:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   80d64:	910003fd 	mov	x29, sp
   80d68:	f90013f5 	str	x21, [sp, #32]
   80d6c:	2a0203f5 	mov	w21, w2
    int i;
    for (i = 0; i < len; ++i)
   80d70:	7100005f 	cmp	w2, #0x0
   80d74:	5400014d 	b.le	80d9c <_read+0x3c>
   80d78:	a90153f3 	stp	x19, x20, [sp, #16]
   80d7c:	aa0103f3 	mov	x19, x1
   80d80:	8b22c034 	add	x20, x1, w2, sxtw
   80d84:	d503201f 	nop
    {
        ptr[i] = uart_getchar();
   80d88:	9400007e 	bl	80f80 <uart_getchar>
   80d8c:	38001660 	strb	w0, [x19], #1
    for (i = 0; i < len; ++i)
   80d90:	eb14027f 	cmp	x19, x20
   80d94:	54ffffa1 	b.ne	80d88 <_read+0x28>  // b.any
   80d98:	a94153f3 	ldp	x19, x20, [sp, #16]
    }

    return len;
}
   80d9c:	2a1503e0 	mov	w0, w21
   80da0:	f94013f5 	ldr	x21, [sp, #32]
   80da4:	a8c37bfd 	ldp	x29, x30, [sp], #48
   80da8:	d65f03c0 	ret
   80dac:	d503201f 	nop

0000000000080db0 <_write>:

int _write(int file, char *ptr, int len)
{
   80db0:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   80db4:	910003fd 	mov	x29, sp
   80db8:	a90153f3 	stp	x19, x20, [sp, #16]
   80dbc:	8b22c034 	add	x20, x1, w2, sxtw
   80dc0:	f90013f5 	str	x21, [sp, #32]
   80dc4:	2a0203f5 	mov	w21, w2
    int i;
    for (i = 0; i < len; ++i)
   80dc8:	7100005f 	cmp	w2, #0x0
   80dcc:	5400022d 	b.le	80e10 <_write+0x60>
   80dd0:	aa0103f3 	mov	x19, x1
   80dd4:	14000005 	b	80de8 <_write+0x38>
   80dd8:	91000673 	add	x19, x19, #0x1
    {
        if (ptr[i] == '\n')
        {
            uart_putc('\r');
        }
        uart_putc(ptr[i]);
   80ddc:	94000066 	bl	80f74 <uart_putc>
    for (i = 0; i < len; ++i)
   80de0:	eb14027f 	cmp	x19, x20
   80de4:	54000160 	b.eq	80e10 <_write+0x60>  // b.none
        if (ptr[i] == '\n')
   80de8:	39400260 	ldrb	w0, [x19]
   80dec:	7100281f 	cmp	w0, #0xa
   80df0:	54ffff41 	b.ne	80dd8 <_write+0x28>  // b.any
            uart_putc('\r');
   80df4:	528001a0 	mov	w0, #0xd                   	// #13
   80df8:	9400005f 	bl	80f74 <uart_putc>
        uart_putc(ptr[i]);
   80dfc:	39400260 	ldrb	w0, [x19]
    for (i = 0; i < len; ++i)
   80e00:	91000673 	add	x19, x19, #0x1
        uart_putc(ptr[i]);
   80e04:	9400005c 	bl	80f74 <uart_putc>
    for (i = 0; i < len; ++i)
   80e08:	eb14027f 	cmp	x19, x20
   80e0c:	54fffee1 	b.ne	80de8 <_write+0x38>  // b.any
    }

    return len;
}
   80e10:	a94153f3 	ldp	x19, x20, [sp, #16]
   80e14:	2a1503e0 	mov	w0, w21
   80e18:	f94013f5 	ldr	x21, [sp, #32]
   80e1c:	a8c37bfd 	ldp	x29, x30, [sp], #48
   80e20:	d65f03c0 	ret

0000000000080e24 <_lseek>:

int _lseek(int file, int ptr, int dir)
{
   80e24:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   80e28:	910003fd 	mov	x29, sp
    errno = ESPIPE;
   80e2c:	94000475 	bl	82000 <__errno>
   80e30:	aa0003e1 	mov	x1, x0
   80e34:	528003a2 	mov	w2, #0x1d                  	// #29
    return -1;
}
   80e38:	12800000 	mov	w0, #0xffffffff            	// #-1
    errno = ESPIPE;
   80e3c:	b9000022 	str	w2, [x1]
}
   80e40:	a8c17bfd 	ldp	x29, x30, [sp], #16
   80e44:	d65f03c0 	ret
   80e48:	d503201f 	nop
   80e4c:	d503201f 	nop

0000000000080e50 <_close>:

int _close(int file)
{
    return -1;
}
   80e50:	12800000 	mov	w0, #0xffffffff            	// #-1
   80e54:	d65f03c0 	ret
   80e58:	d503201f 	nop
   80e5c:	d503201f 	nop

0000000000080e60 <_fstat>:

int _fstat(int file, struct stat *st)
{
    st->st_mode = S_IFCHR;
   80e60:	52840002 	mov	w2, #0x2000                	// #8192
    return 0;
}
   80e64:	52800000 	mov	w0, #0x0                   	// #0
    st->st_mode = S_IFCHR;
   80e68:	b9000422 	str	w2, [x1, #4]
}
   80e6c:	d65f03c0 	ret

0000000000080e70 <_isatty>:

int _isatty(int fd)
{
   80e70:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   80e74:	910003fd 	mov	x29, sp
    errno = ENOTTY;
   80e78:	94000462 	bl	82000 <__errno>
   80e7c:	aa0003e1 	mov	x1, x0
   80e80:	52800322 	mov	w2, #0x19                  	// #25
    return 0;
}
   80e84:	52800000 	mov	w0, #0x0                   	// #0
    errno = ENOTTY;
   80e88:	b9000022 	str	w2, [x1]
}
   80e8c:	a8c17bfd 	ldp	x29, x30, [sp], #16
   80e90:	d65f03c0 	ret

0000000000080e94 <_sbrk>:

void* _sbrk(int increment)
{
    extern char _heap_base;
    static char* heap_end = &_heap_base;
    char* current_heap_end = heap_end;
   80e94:	d00000a2 	adrp	x2, 96000 <JIS_state_table+0x70>
{
   80e98:	2a0003e1 	mov	w1, w0
    char* current_heap_end = heap_end;
   80e9c:	f940e840 	ldr	x0, [x2, #464]
    heap_end += increment;
   80ea0:	8b21c001 	add	x1, x0, w1, sxtw
   80ea4:	f900e841 	str	x1, [x2, #464]
    return current_heap_end;
}
   80ea8:	d65f03c0 	ret
   80eac:	d503201f 	nop

0000000000080eb0 <_exit>:
    DMB(ish);
   80eb0:	d5033bbf 	dmb	ish
   80eb4:	d503201f 	nop
#ifndef WFI_H
#define WFI_H

static inline void wfi(){
    asm volatile("wfi\n\t" ::: "memory");
   80eb8:	d503207f 	wfi
   80ebc:	17ffffff 	b	80eb8 <_exit+0x8>

0000000000080ec0 <_getpid>:
}

int _getpid(void)
{
  return 1;
}
   80ec0:	52800020 	mov	w0, #0x1                   	// #1
   80ec4:	d65f03c0 	ret
   80ec8:	d503201f 	nop
   80ecc:	d503201f 	nop

0000000000080ed0 <_kill>:

int _kill(int pid, int sig)
{
   80ed0:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   80ed4:	910003fd 	mov	x29, sp
    errno = EINVAL;
   80ed8:	9400044a 	bl	82000 <__errno>
   80edc:	aa0003e1 	mov	x1, x0
   80ee0:	528002c2 	mov	w2, #0x16                  	// #22
    return -1;
}
   80ee4:	12800000 	mov	w0, #0xffffffff            	// #-1
    errno = EINVAL;
   80ee8:	b9000022 	str	w2, [x1]
}
   80eec:	a8c17bfd 	ldp	x29, x30, [sp], #16
   80ef0:	d65f03c0 	ret

0000000000080ef4 <_init>:

static bool init_done = false;
static spinlock_t init_lock = SPINLOCK_INITVAL;

__attribute__((weak))
void _init(){
   80ef4:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
static inline void spin_lock(spinlock_t* lock){

    uint32_t const ONE = 1;
    spinlock_t tmp;

    asm volatile (
   80ef8:	d0001400 	adrp	x0, 302000 <irq_handlers+0x1370>
   80efc:	52800021 	mov	w1, #0x1                   	// #1
   80f00:	910003fd 	mov	x29, sp
   80f04:	f9000bf3 	str	x19, [sp, #16]
   80f08:	91324013 	add	x19, x0, #0xc90
   80f0c:	885ffe62 	ldaxr	w2, [x19]
   80f10:	35ffffe2 	cbnz	w2, 80f0c <_init+0x18>
   80f14:	88027e61 	stxr	w2, w1, [x19]
   80f18:	35ffffa2 	cbnz	w2, 80f0c <_init+0x18>

    spin_lock(&init_lock);
    if(!init_done) {
   80f1c:	39401260 	ldrb	w0, [x19, #4]
   80f20:	b9002fe2 	str	w2, [sp, #44]
   80f24:	340000a0 	cbz	w0, 80f38 <_init+0x44>

}

static inline void spin_unlock(spinlock_t* lock){

    asm volatile ("stlr wzr, %0\n\t" :: "Q"(*lock));
   80f28:	889ffe7f 	stlr	wzr, [x19]
        init_done = true;
        uart_init();
    }
    spin_unlock(&init_lock);
    
    arch_init();
   80f2c:	940000e5 	bl	812c0 <arch_init>

    int ret = main();
   80f30:	97ffff00 	bl	80b30 <main>
    _exit(ret);
   80f34:	97ffffdf 	bl	80eb0 <_exit>
        init_done = true;
   80f38:	39001261 	strb	w1, [x19, #4]
        uart_init();
   80f3c:	94000005 	bl	80f50 <uart_init>
   80f40:	17fffffa 	b	80f28 <_init+0x34>
	...

0000000000080f50 <uart_init>:
#define VIRT_UART_BAUDRATE		    115200
#define VIRT_UART_FREQ		        3000000

void uart_init(){

    uart8250_init(VIRT_UART16550_ADDR, VIRT_UART_FREQ, VIRT_UART_BAUDRATE, 0, 4);
   80f50:	52984002 	mov	w2, #0xc200                	// #49664
   80f54:	5298d801 	mov	w1, #0xc6c0                	// #50880
   80f58:	d28a0800 	mov	x0, #0x5040                	// #20544
   80f5c:	72a00022 	movk	w2, #0x1, lsl #16
   80f60:	72a005a1 	movk	w1, #0x2d, lsl #16
   80f64:	f2bfc420 	movk	x0, #0xfe21, lsl #16
   80f68:	52800084 	mov	w4, #0x4                   	// #4
   80f6c:	52800003 	mov	w3, #0x0                   	// #0
   80f70:	1400008c 	b	811a0 <uart8250_init>

0000000000080f74 <uart_putc>:
}

void uart_putc(char c)
{
    uart8250_putc(c);
   80f74:	14000023 	b	81000 <uart8250_putc>
   80f78:	d503201f 	nop
   80f7c:	d503201f 	nop

0000000000080f80 <uart_getchar>:
}

char uart_getchar(void)
{
   80f80:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   80f84:	910003fd 	mov	x29, sp
    return uart8250_getc();
   80f88:	9400003e 	bl	81080 <uart8250_getc>
}
   80f8c:	a8c17bfd 	ldp	x29, x30, [sp], #16
   80f90:	d65f03c0 	ret

0000000000080f94 <uart_enable_rxirq>:

void uart_enable_rxirq()
{
    uart8250_enable_rx_int();
   80f94:	14000070 	b	81154 <uart8250_enable_rx_int>
   80f98:	d503201f 	nop
   80f9c:	d503201f 	nop

0000000000080fa0 <uart_clear_rxirq>:
}

void uart_clear_rxirq()
{
    uart8250_interrupt_handler(); 
   80fa0:	14000055 	b	810f4 <uart8250_interrupt_handler>
	...

0000000000080fb0 <get_reg>:
static u32 uart8250_reg_width;
static u32 uart8250_reg_shift;

static volatile u32 get_reg(u32 num)
{
	u32 offset = num << uart8250_reg_shift;
   80fb0:	d0001401 	adrp	x1, 302000 <irq_handlers+0x1370>
   80fb4:	91326022 	add	x2, x1, #0xc98
   80fb8:	b94c9821 	ldr	w1, [x1, #3224]

	if (uart8250_reg_width == 1)
   80fbc:	b9400443 	ldr	w3, [x2, #4]
		return readb(uart8250_base + offset);
   80fc0:	f9400442 	ldr	x2, [x2, #8]
	u32 offset = num << uart8250_reg_shift;
   80fc4:	1ac12004 	lsl	w4, w0, w1
		return readb(uart8250_base + offset);
   80fc8:	1ac12000 	lsl	w0, w0, w1
	if (uart8250_reg_width == 1)
   80fcc:	7100047f 	cmp	w3, #0x1
   80fd0:	54000120 	b.eq	80ff4 <get_reg+0x44>  // b.none
	else if (uart8250_reg_width == 2)
   80fd4:	7100087f 	cmp	w3, #0x2
   80fd8:	54000060 	b.eq	80fe4 <get_reg+0x34>  // b.none
		return readw(uart8250_base + offset);
	else
		return readl(uart8250_base + offset);
   80fdc:	b8607840 	ldr	w0, [x2, x0, lsl #2]
}
   80fe0:	d65f03c0 	ret
		return readw(uart8250_base + offset);
   80fe4:	d37ff800 	lsl	x0, x0, #1
   80fe8:	78606840 	ldrh	w0, [x2, x0]
   80fec:	12003c00 	and	w0, w0, #0xffff
}
   80ff0:	d65f03c0 	ret
		return readb(uart8250_base + offset);
   80ff4:	38644840 	ldrb	w0, [x2, w4, uxtw]
   80ff8:	12001c00 	and	w0, w0, #0xff
}
   80ffc:	d65f03c0 	ret

0000000000081000 <uart8250_putc>:
	u32 offset = num << uart8250_reg_shift;
   81000:	b0001403 	adrp	x3, 302000 <irq_handlers+0x1370>
   81004:	91326061 	add	x1, x3, #0xc98
   81008:	528000a2 	mov	w2, #0x5                   	// #5
	else
		writel(val, uart8250_base + offset);
}

void uart8250_putc(char ch)
{
   8100c:	12001c00 	and	w0, w0, #0xff
	u32 offset = num << uart8250_reg_shift;
   81010:	b94c9863 	ldr	w3, [x3, #3224]
		return readl(uart8250_base + offset);
   81014:	f9400425 	ldr	x5, [x1, #8]
	if (uart8250_reg_width == 1)
   81018:	b9400421 	ldr	w1, [x1, #4]
		return readl(uart8250_base + offset);
   8101c:	1ac32042 	lsl	w2, w2, w3
		return readb(uart8250_base + offset);
   81020:	8b0200a6 	add	x6, x5, x2
		return readl(uart8250_base + offset);
   81024:	8b0208a4 	add	x4, x5, x2, lsl #2
		return readw(uart8250_base + offset);
   81028:	8b0204a3 	add	x3, x5, x2, lsl #1
	if (uart8250_reg_width == 1)
   8102c:	7100043f 	cmp	w1, #0x1
   81030:	540000a1 	b.ne	81044 <uart8250_putc+0x44>  // b.any
		return readb(uart8250_base + offset);
   81034:	394000c1 	ldrb	w1, [x6]
	while ((get_reg(UART_LSR_OFFSET) & UART_LSR_THRE) == 0)
   81038:	362fffe1 	tbz	w1, #5, 81034 <uart8250_putc+0x34>
		writeb(val, uart8250_base + offset);
   8103c:	390000a0 	strb	w0, [x5]
		;

	set_reg(UART_THR_OFFSET, ch);
}
   81040:	d65f03c0 	ret
	else if (uart8250_reg_width == 2)
   81044:	7100083f 	cmp	w1, #0x2
   81048:	54000120 	b.eq	8106c <uart8250_putc+0x6c>  // b.none
		return readl(uart8250_base + offset);
   8104c:	b9400082 	ldr	w2, [x4]
	while ((get_reg(UART_LSR_OFFSET) & UART_LSR_THRE) == 0)
   81050:	362fffa2 	tbz	w2, #5, 81044 <uart8250_putc+0x44>
	if (uart8250_reg_width == 1)
   81054:	7100043f 	cmp	w1, #0x1
   81058:	54ffff20 	b.eq	8103c <uart8250_putc+0x3c>  // b.none
	else if (uart8250_reg_width == 2)
   8105c:	7100083f 	cmp	w1, #0x2
   81060:	540000a0 	b.eq	81074 <uart8250_putc+0x74>  // b.none
		writel(val, uart8250_base + offset);
   81064:	b90000a0 	str	w0, [x5]
}
   81068:	d65f03c0 	ret
		return readw(uart8250_base + offset);
   8106c:	79400061 	ldrh	w1, [x3]
	while ((get_reg(UART_LSR_OFFSET) & UART_LSR_THRE) == 0)
   81070:	362fffe1 	tbz	w1, #5, 8106c <uart8250_putc+0x6c>
		writew(val, uart8250_base + offset);
   81074:	790000a0 	strh	w0, [x5]
}
   81078:	d65f03c0 	ret
   8107c:	d503201f 	nop

0000000000081080 <uart8250_getc>:
	u32 offset = num << uart8250_reg_shift;
   81080:	b0001401 	adrp	x1, 302000 <irq_handlers+0x1370>
   81084:	91326022 	add	x2, x1, #0xc98
   81088:	528000a0 	mov	w0, #0x5                   	// #5
   8108c:	b94c9821 	ldr	w1, [x1, #3224]
	if (uart8250_reg_width == 1)
   81090:	b9400443 	ldr	w3, [x2, #4]
		return readb(uart8250_base + offset);
   81094:	f9400442 	ldr	x2, [x2, #8]
	u32 offset = num << uart8250_reg_shift;
   81098:	1ac12004 	lsl	w4, w0, w1
		return readb(uart8250_base + offset);
   8109c:	1ac12000 	lsl	w0, w0, w1
	if (uart8250_reg_width == 1)
   810a0:	7100047f 	cmp	w3, #0x1
   810a4:	540001a0 	b.eq	810d8 <uart8250_getc+0x58>  // b.none
	else if (uart8250_reg_width == 2)
   810a8:	7100087f 	cmp	w3, #0x2
   810ac:	540000a0 	b.eq	810c0 <uart8250_getc+0x40>  // b.none
		return readl(uart8250_base + offset);
   810b0:	b8607840 	ldr	w0, [x2, x0, lsl #2]

int uart8250_getc(void)
{
	if (get_reg(UART_LSR_OFFSET) & UART_LSR_DR)
   810b4:	360001c0 	tbz	w0, #0, 810ec <uart8250_getc+0x6c>
		return readl(uart8250_base + offset);
   810b8:	b9400040 	ldr	w0, [x2]
		return get_reg(UART_RBR_OFFSET);
	return -1;
}
   810bc:	d65f03c0 	ret
		return readw(uart8250_base + offset);
   810c0:	d37ff800 	lsl	x0, x0, #1
   810c4:	78606840 	ldrh	w0, [x2, x0]
	if (get_reg(UART_LSR_OFFSET) & UART_LSR_DR)
   810c8:	36000120 	tbz	w0, #0, 810ec <uart8250_getc+0x6c>
		return readw(uart8250_base + offset);
   810cc:	79400040 	ldrh	w0, [x2]
   810d0:	12003c00 	and	w0, w0, #0xffff
}
   810d4:	d65f03c0 	ret
		return readb(uart8250_base + offset);
   810d8:	38644840 	ldrb	w0, [x2, w4, uxtw]
	if (get_reg(UART_LSR_OFFSET) & UART_LSR_DR)
   810dc:	36000080 	tbz	w0, #0, 810ec <uart8250_getc+0x6c>
		return readb(uart8250_base + offset);
   810e0:	39400040 	ldrb	w0, [x2]
   810e4:	12001c00 	and	w0, w0, #0xff
}
   810e8:	d65f03c0 	ret
	return -1;
   810ec:	12800000 	mov	w0, #0xffffffff            	// #-1
}
   810f0:	d65f03c0 	ret

00000000000810f4 <uart8250_interrupt_handler>:
	if (uart8250_reg_width == 1)
   810f4:	b0001400 	adrp	x0, 302000 <irq_handlers+0x1370>
   810f8:	91326000 	add	x0, x0, #0xc98

void uart8250_interrupt_handler(){
   810fc:	d10043ff 	sub	sp, sp, #0x10
	if (uart8250_reg_width == 1)
   81100:	b9400401 	ldr	w1, [x0, #4]
		return readb(uart8250_base + offset);
   81104:	f9400400 	ldr	x0, [x0, #8]
	if (uart8250_reg_width == 1)
   81108:	7100043f 	cmp	w1, #0x1
   8110c:	540001a0 	b.eq	81140 <uart8250_interrupt_handler+0x4c>  // b.none
	else if (uart8250_reg_width == 2)
   81110:	7100083f 	cmp	w1, #0x2
   81114:	540000c0 	b.eq	8112c <uart8250_interrupt_handler+0x38>  // b.none
		return readl(uart8250_base + offset);
   81118:	b9400000 	ldr	w0, [x0]
	volatile char c = get_reg(UART_RBR_OFFSET);
   8111c:	12001c00 	and	w0, w0, #0xff
   81120:	39003fe0 	strb	w0, [sp, #15]
}
   81124:	910043ff 	add	sp, sp, #0x10
   81128:	d65f03c0 	ret
		return readw(uart8250_base + offset);
   8112c:	79400000 	ldrh	w0, [x0]
	volatile char c = get_reg(UART_RBR_OFFSET);
   81130:	12001c00 	and	w0, w0, #0xff
   81134:	39003fe0 	strb	w0, [sp, #15]
}
   81138:	910043ff 	add	sp, sp, #0x10
   8113c:	d65f03c0 	ret
		return readb(uart8250_base + offset);
   81140:	39400000 	ldrb	w0, [x0]
   81144:	12001c00 	and	w0, w0, #0xff
	volatile char c = get_reg(UART_RBR_OFFSET);
   81148:	39003fe0 	strb	w0, [sp, #15]
}
   8114c:	910043ff 	add	sp, sp, #0x10
   81150:	d65f03c0 	ret

0000000000081154 <uart8250_enable_rx_int>:
	u32 offset = num << uart8250_reg_shift;
   81154:	b0001400 	adrp	x0, 302000 <irq_handlers+0x1370>
   81158:	91326003 	add	x3, x0, #0xc98
   8115c:	52800021 	mov	w1, #0x1                   	// #1
   81160:	b94c9800 	ldr	w0, [x0, #3224]
	if (uart8250_reg_width == 1)
   81164:	b9400462 	ldr	w2, [x3, #4]
		writeb(val, uart8250_base + offset);
   81168:	f9400463 	ldr	x3, [x3, #8]
	u32 offset = num << uart8250_reg_shift;
   8116c:	1ac02024 	lsl	w4, w1, w0
		writeb(val, uart8250_base + offset);
   81170:	1ac02020 	lsl	w0, w1, w0
	if (uart8250_reg_width == 1)
   81174:	6b01005f 	cmp	w2, w1
   81178:	540000e0 	b.eq	81194 <uart8250_enable_rx_int+0x40>  // b.none
	else if (uart8250_reg_width == 2)
   8117c:	7100085f 	cmp	w2, #0x2
   81180:	54000060 	b.eq	8118c <uart8250_enable_rx_int+0x38>  // b.none
		writel(val, uart8250_base + offset);
   81184:	b8207861 	str	w1, [x3, x0, lsl #2]

void uart8250_enable_rx_int(){
	set_reg(UART_IER_OFFSET, 1);
}
   81188:	d65f03c0 	ret
		writew(val, uart8250_base + offset);
   8118c:	78244861 	strh	w1, [x3, w4, uxtw]
}
   81190:	d65f03c0 	ret
		writeb(val, uart8250_base + offset);
   81194:	38244862 	strb	w2, [x3, w4, uxtw]
}
   81198:	d65f03c0 	ret
   8119c:	d503201f 	nop

00000000000811a0 <uart8250_init>:

int uart8250_init(unsigned long base, u32 in_freq, u32 baudrate, u32 reg_shift,
		  u32 reg_width)
{
   811a0:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
	u16 bdiv;

	uart8250_base	   = (volatile void *)base;
   811a4:	b0001401 	adrp	x1, 302000 <irq_handlers+0x1370>
   811a8:	91326026 	add	x6, x1, #0xc98
{
   811ac:	910003fd 	mov	x29, sp
   811b0:	aa0003e5 	mov	x5, x0
	uart8250_reg_shift = reg_shift;
   811b4:	b90c9823 	str	w3, [x1, #3224]
	u32 offset = num << uart8250_reg_shift;
   811b8:	52800028 	mov	w8, #0x1                   	// #1
   811bc:	52800067 	mov	w7, #0x3                   	// #3
   811c0:	528000e0 	mov	w0, #0x7                   	// #7
   811c4:	52800042 	mov	w2, #0x2                   	// #2
   811c8:	52800081 	mov	w1, #0x4                   	// #4
	uart8250_reg_width = reg_width;
   811cc:	b90004c4 	str	w4, [x6, #4]
	uart8250_base	   = (volatile void *)base;
   811d0:	f90004c5 	str	x5, [x6, #8]
	u32 offset = num << uart8250_reg_shift;
   811d4:	1ac3204d 	lsl	w13, w2, w3
   811d8:	1ac3202c 	lsl	w12, w1, w3
   811dc:	1ac3210e 	lsl	w14, w8, w3
   811e0:	1ac320e9 	lsl	w9, w7, w3
   811e4:	1ac3200b 	lsl	w11, w0, w3
		writeb(val, uart8250_base + offset);
   811e8:	1ac32042 	lsl	w2, w2, w3
   811ec:	1ac32021 	lsl	w1, w1, w3
   811f0:	1ac320ea 	lsl	w10, w7, w3
   811f4:	1ac32006 	lsl	w6, w0, w3
   811f8:	1ac32103 	lsl	w3, w8, w3
	if (uart8250_reg_width == 1)
   811fc:	6b08009f 	cmp	w4, w8
   81200:	540003e0 	b.eq	8127c <uart8250_init+0xdc>  // b.none
	else if (uart8250_reg_width == 2)
   81204:	7100089f 	cmp	w4, #0x2
   81208:	540001e0 	b.eq	81244 <uart8250_init+0xa4>  // b.none
		writel(val, uart8250_base + offset);
   8120c:	b82378bf 	str	wzr, [x5, x3, lsl #2]
   81210:	52801000 	mov	w0, #0x80                  	// #128
   81214:	b82a78a0 	str	w0, [x5, x10, lsl #2]
	/* Enable FIFO */
	set_reg(UART_FCR_OFFSET, 0x01);
	/* No modem control DTR RTS */
	set_reg(UART_MCR_OFFSET, 0x00);
	/* Clear line status */
	get_reg(UART_LSR_OFFSET);
   81218:	528000a0 	mov	w0, #0x5                   	// #5
		writel(val, uart8250_base + offset);
   8121c:	b82a78a7 	str	w7, [x5, x10, lsl #2]
   81220:	b82278a8 	str	w8, [x5, x2, lsl #2]
   81224:	b82178bf 	str	wzr, [x5, x1, lsl #2]
	get_reg(UART_LSR_OFFSET);
   81228:	97ffff62 	bl	80fb0 <get_reg>
	/* Read receive buffer */
	get_reg(UART_RBR_OFFSET);
   8122c:	52800000 	mov	w0, #0x0                   	// #0
   81230:	97ffff60 	bl	80fb0 <get_reg>
		writel(val, uart8250_base + offset);
   81234:	b82678bf 	str	wzr, [x5, x6, lsl #2]
	/* Set scratchpad */
	set_reg(UART_SCR_OFFSET, 0x00);

	return 0;
   81238:	52800000 	mov	w0, #0x0                   	// #0
   8123c:	a8c17bfd 	ldp	x29, x30, [sp], #16
   81240:	d65f03c0 	ret
		writew(val, uart8250_base + offset);
   81244:	782e48bf 	strh	wzr, [x5, w14, uxtw]
   81248:	52801000 	mov	w0, #0x80                  	// #128
   8124c:	782948a0 	strh	w0, [x5, w9, uxtw]
	get_reg(UART_LSR_OFFSET);
   81250:	528000a0 	mov	w0, #0x5                   	// #5
		writew(val, uart8250_base + offset);
   81254:	782948a7 	strh	w7, [x5, w9, uxtw]
   81258:	782d48a8 	strh	w8, [x5, w13, uxtw]
   8125c:	782c48bf 	strh	wzr, [x5, w12, uxtw]
	get_reg(UART_LSR_OFFSET);
   81260:	97ffff54 	bl	80fb0 <get_reg>
	get_reg(UART_RBR_OFFSET);
   81264:	52800000 	mov	w0, #0x0                   	// #0
   81268:	97ffff52 	bl	80fb0 <get_reg>
		writew(val, uart8250_base + offset);
   8126c:	782b48bf 	strh	wzr, [x5, w11, uxtw]
   81270:	52800000 	mov	w0, #0x0                   	// #0
   81274:	a8c17bfd 	ldp	x29, x30, [sp], #16
   81278:	d65f03c0 	ret
		writeb(val, uart8250_base + offset);
   8127c:	382e48bf 	strb	wzr, [x5, w14, uxtw]
   81280:	12800fe0 	mov	w0, #0xffffff80            	// #-128
   81284:	382948a0 	strb	w0, [x5, w9, uxtw]
	get_reg(UART_LSR_OFFSET);
   81288:	528000a0 	mov	w0, #0x5                   	// #5
		writeb(val, uart8250_base + offset);
   8128c:	382948a7 	strb	w7, [x5, w9, uxtw]
   81290:	382d48a4 	strb	w4, [x5, w13, uxtw]
   81294:	382c48bf 	strb	wzr, [x5, w12, uxtw]
	get_reg(UART_LSR_OFFSET);
   81298:	97ffff46 	bl	80fb0 <get_reg>
	get_reg(UART_RBR_OFFSET);
   8129c:	52800000 	mov	w0, #0x0                   	// #0
   812a0:	97ffff44 	bl	80fb0 <get_reg>
		writeb(val, uart8250_base + offset);
   812a4:	382b48bf 	strb	wzr, [x5, w11, uxtw]
   812a8:	52800000 	mov	w0, #0x0                   	// #0
   812ac:	a8c17bfd 	ldp	x29, x30, [sp], #16
   812b0:	d65f03c0 	ret
	...

00000000000812c0 <arch_init>:
#include <sysregs.h>

void _start();

__attribute__((weak))
void arch_init(){
   812c0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   812c4:	910003fd 	mov	x29, sp
   812c8:	a90153f3 	stp	x19, x20, [sp, #16]
    uint64_t cpuid = MRS(MPIDR_EL1);
   812cc:	d53800b3 	mrs	x19, mpidr_el1
    uint64_t cpuid = get_cpuid();
    gic_init();
   812d0:	94000084 	bl	814e0 <gic_init>
    TIMER_FREQ = MRS(CNTFRQ_EL0);
   812d4:	d53be001 	mrs	x1, cntfrq_el0
   812d8:	b0001400 	adrp	x0, 302000 <irq_handlers+0x1370>
   812dc:	f9065401 	str	x1, [x0, #3240]
   812e0:	d53800a1 	mrs	x1, mpidr_el1
    return get_cpuid() == master_cpu;
   812e4:	b00000a0 	adrp	x0, 96000 <JIS_state_table+0x70>
#ifndef SINGLE_CORE
    if(cpu_is_master()){
   812e8:	f940f400 	ldr	x0, [x0, #488]
   812ec:	eb21001f 	cmp	x0, w1, uxtb
   812f0:	540000a0 	b.eq	81304 <arch_init+0x44>  // b.none
        do {
            ret = psci_cpu_on(i, (uintptr_t) _start, 0);
        } while(i++, ret == PSCI_E_SUCCESS);
    }
#endif
    asm volatile("MSR   DAIFClr, #2\n\t");
   812f4:	d50342ff 	msr	daifclr, #0x2
}
   812f8:	a94153f3 	ldp	x19, x20, [sp, #16]
   812fc:	a8c27bfd 	ldp	x29, x30, [sp], #32
   81300:	d65f03c0 	ret
    return cpuid & MPIDR_CPU_MASK;
   81304:	92401e73 	and	x19, x19, #0xff
            ret = psci_cpu_on(i, (uintptr_t) _start, 0);
   81308:	f0fffff4 	adrp	x20, 80000 <_start>
        size_t i = cpuid + 1;
   8130c:	91000673 	add	x19, x19, #0x1
            ret = psci_cpu_on(i, (uintptr_t) _start, 0);
   81310:	91000294 	add	x20, x20, #0x0
   81314:	d503201f 	nop
   81318:	aa1303e0 	mov	x0, x19
   8131c:	aa1403e1 	mov	x1, x20
        } while(i++, ret == PSCI_E_SUCCESS);
   81320:	91000673 	add	x19, x19, #0x1
            ret = psci_cpu_on(i, (uintptr_t) _start, 0);
   81324:	d2800002 	mov	x2, #0x0                   	// #0
   81328:	94000022 	bl	813b0 <psci_cpu_on>
        } while(i++, ret == PSCI_E_SUCCESS);
   8132c:	34ffff60 	cbz	w0, 81318 <arch_init+0x58>
    asm volatile("MSR   DAIFClr, #2\n\t");
   81330:	d50342ff 	msr	daifclr, #0x2
}
   81334:	a94153f3 	ldp	x19, x20, [sp, #16]
   81338:	a8c27bfd 	ldp	x29, x30, [sp], #32
   8133c:	d65f03c0 	ret

0000000000081340 <smc_call>:
	register uint64_t r0 asm("r0") = x0;
	register uint64_t r1 asm("r1") = x1;
	register uint64_t r2 asm("r2") = x2;
	register uint64_t r3 asm("r3") = x3;

    asm volatile(
   81340:	d4000003 	smc	#0x0
			: "=r" (r0)
			: "r" (r0), "r" (r1), "r" (r2)
			: "r3");

	return r0;
}
   81344:	d65f03c0 	ret
   81348:	d503201f 	nop
   8134c:	d503201f 	nop

0000000000081350 <psci_version>:
	register uint64_t r0 asm("r0") = x0;
   81350:	d2b08000 	mov	x0, #0x84000000            	// #2214592512
	register uint64_t r1 asm("r1") = x1;
   81354:	d2800001 	mov	x1, #0x0                   	// #0
	register uint64_t r2 asm("r2") = x2;
   81358:	d2800002 	mov	x2, #0x0                   	// #0
    asm volatile(
   8135c:	d4000003 	smc	#0x0
--------------------------------- */

uint64_t psci_version(void)
{
    return smc_call(PSCI_VERSION, 0, 0, 0);
}
   81360:	93407c00 	sxtw	x0, w0
   81364:	d65f03c0 	ret
   81368:	d503201f 	nop
   8136c:	d503201f 	nop

0000000000081370 <psci_cpu_suspend>:


uint64_t psci_cpu_suspend(uint64_t power_state, uintptr_t entrypoint, 
                    uint64_t context_id)
{
   81370:	aa0003e3 	mov	x3, x0
	register uint64_t r0 asm("r0") = x0;
   81374:	d2800020 	mov	x0, #0x1                   	// #1
{
   81378:	aa0103e2 	mov	x2, x1
	register uint64_t r0 asm("r0") = x0;
   8137c:	f2b88000 	movk	x0, #0xc400, lsl #16
	register uint64_t r1 asm("r1") = x1;
   81380:	aa0303e1 	mov	x1, x3
    asm volatile(
   81384:	d4000003 	smc	#0x0
    return smc_call(PSCI_CPU_SUSPEND_AARCH64, power_state, entrypoint, 
                                                                    context_id);
}
   81388:	93407c00 	sxtw	x0, w0
   8138c:	d65f03c0 	ret

0000000000081390 <psci_cpu_off>:
	register uint64_t r0 asm("r0") = x0;
   81390:	d2800040 	mov	x0, #0x2                   	// #2
	register uint64_t r1 asm("r1") = x1;
   81394:	d2800001 	mov	x1, #0x0                   	// #0
	register uint64_t r0 asm("r0") = x0;
   81398:	f2b08000 	movk	x0, #0x8400, lsl #16
	register uint64_t r2 asm("r2") = x2;
   8139c:	d2800002 	mov	x2, #0x0                   	// #0
    asm volatile(
   813a0:	d4000003 	smc	#0x0

uint64_t psci_cpu_off(void)
{
    return smc_call(PSCI_CPU_OFF, 0, 0, 0);
}
   813a4:	93407c00 	sxtw	x0, w0
   813a8:	d65f03c0 	ret
   813ac:	d503201f 	nop

00000000000813b0 <psci_cpu_on>:

uint64_t psci_cpu_on(uint64_t target_cpu, uintptr_t entrypoint, 
                    uint64_t context_id)
{
   813b0:	aa0003e3 	mov	x3, x0
	register uint64_t r0 asm("r0") = x0;
   813b4:	d2800060 	mov	x0, #0x3                   	// #3
{
   813b8:	aa0103e2 	mov	x2, x1
	register uint64_t r0 asm("r0") = x0;
   813bc:	f2b88000 	movk	x0, #0xc400, lsl #16
	register uint64_t r1 asm("r1") = x1;
   813c0:	aa0303e1 	mov	x1, x3
    asm volatile(
   813c4:	d4000003 	smc	#0x0
    return smc_call(PSCI_CPU_ON_AARCH64, target_cpu, entrypoint, context_id);
}
   813c8:	93407c00 	sxtw	x0, w0
   813cc:	d65f03c0 	ret

00000000000813d0 <psci_affinity_info>:

uint64_t psci_affinity_info(uint64_t target_affinity, 
                            uint64_t lowest_affinity_level)
{
   813d0:	aa0003e3 	mov	x3, x0
	register uint64_t r0 asm("r0") = x0;
   813d4:	d2800080 	mov	x0, #0x4                   	// #4
{
   813d8:	aa0103e2 	mov	x2, x1
	register uint64_t r0 asm("r0") = x0;
   813dc:	f2b88000 	movk	x0, #0xc400, lsl #16
	register uint64_t r1 asm("r1") = x1;
   813e0:	aa0303e1 	mov	x1, x3
    asm volatile(
   813e4:	d4000003 	smc	#0x0
    return smc_call(PSCI_AFFINITY_INFO_AARCH64, target_affinity, 
                    lowest_affinity_level, 0);
}
   813e8:	93407c00 	sxtw	x0, w0
   813ec:	d65f03c0 	ret

00000000000813f0 <irq_enable>:

#ifndef GIC_VERSION
#error "GIC_VERSION not defined for this platform"
#endif

void irq_enable(unsigned id) {
   813f0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   gic_set_enable(id, true); 
   813f4:	52800021 	mov	w1, #0x1                   	// #1
void irq_enable(unsigned id) {
   813f8:	910003fd 	mov	x29, sp
   813fc:	f9000bf3 	str	x19, [sp, #16]
   gic_set_enable(id, true); 
   81400:	2a0003f3 	mov	w19, w0
   81404:	aa1303e0 	mov	x0, x19
   81408:	94000046 	bl	81520 <gic_set_enable>
   if(GIC_VERSION == GICV2) {
       gic_set_trgt(id, gic_get_trgt(id) | (1 << get_cpuid()));
   8140c:	aa1303e0 	mov	x0, x19
   81410:	94000060 	bl	81590 <gic_get_trgt>
   81414:	12001c02 	and	w2, w0, #0xff
    uint64_t cpuid = MRS(MPIDR_EL1);
   81418:	d53800a3 	mrs	x3, mpidr_el1
   8141c:	aa1303e0 	mov	x0, x19
   81420:	52800021 	mov	w1, #0x1                   	// #1
   } else {
       gic_set_route(id, get_cpuid());
   }
}
   81424:	f9400bf3 	ldr	x19, [sp, #16]
       gic_set_trgt(id, gic_get_trgt(id) | (1 << get_cpuid()));
   81428:	1ac32021 	lsl	w1, w1, w3
}
   8142c:	a8c27bfd 	ldp	x29, x30, [sp], #32
       gic_set_trgt(id, gic_get_trgt(id) | (1 << get_cpuid()));
   81430:	2a010041 	orr	w1, w2, w1
   81434:	14000048 	b	81554 <gic_set_trgt>
   81438:	d503201f 	nop
   8143c:	d503201f 	nop

0000000000081440 <irq_set_prio>:

void irq_set_prio(unsigned id, unsigned prio){
    gic_set_prio(id, (uint8_t) prio);
   81440:	2a0003e0 	mov	w0, w0
   81444:	14000068 	b	815e4 <gic_set_prio>
   81448:	d503201f 	nop
   8144c:	d503201f 	nop

0000000000081450 <irq_send_ipi>:
}

void irq_send_ipi(uint64_t target_cpu_mask) {
   81450:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   81454:	910003fd 	mov	x29, sp
   81458:	a90153f3 	stp	x19, x20, [sp, #16]
   8145c:	aa0003f4 	mov	x20, x0
   81460:	d2800013 	mov	x19, #0x0                   	// #0
   81464:	14000004 	b	81474 <irq_send_ipi+0x24>
    for(int i = 0; i < sizeof(target_cpu_mask)*8; i++) {
   81468:	91000673 	add	x19, x19, #0x1
   8146c:	f101027f 	cmp	x19, #0x40
   81470:	54000120 	b.eq	81494 <irq_send_ipi+0x44>  // b.none
        if(target_cpu_mask & (1ull << i)) {
   81474:	9ad32681 	lsr	x1, x20, x19
   81478:	3607ff81 	tbz	w1, #0, 81468 <irq_send_ipi+0x18>
            gic_send_sgi(i, IPI_IRQ_ID);
   8147c:	aa1303e0 	mov	x0, x19
   81480:	d2800001 	mov	x1, #0x0                   	// #0
    for(int i = 0; i < sizeof(target_cpu_mask)*8; i++) {
   81484:	91000673 	add	x19, x19, #0x1
            gic_send_sgi(i, IPI_IRQ_ID);
   81488:	9400004e 	bl	815c0 <gic_send_sgi>
    for(int i = 0; i < sizeof(target_cpu_mask)*8; i++) {
   8148c:	f101027f 	cmp	x19, #0x40
   81490:	54ffff21 	b.ne	81474 <irq_send_ipi+0x24>  // b.any
        }
    }
}
   81494:	a94153f3 	ldp	x19, x20, [sp, #16]
   81498:	a8c27bfd 	ldp	x29, x30, [sp], #32
   8149c:	d65f03c0 	ret

00000000000814a0 <gicc_init>:

    for(int i = 0; i< GIC_NUM_PRIO_REGS(GIC_CPU_PRIV); i++){
       //gicd->IPRIORITYR[i] = -1;
    }

    gicc->PMR = -1;
   814a0:	b00000a0 	adrp	x0, 96000 <JIS_state_table+0x70>
   814a4:	12800002 	mov	w2, #0xffffffff            	// #-1
    gicc->CTLR = GICC_CTLR_EN_BIT;
   814a8:	52800021 	mov	w1, #0x1                   	// #1
    gicc->PMR = -1;
   814ac:	f940ec00 	ldr	x0, [x0, #472]
   814b0:	b9000402 	str	w2, [x0, #4]
    gicc->CTLR = GICC_CTLR_EN_BIT;
   814b4:	b9000001 	str	w1, [x0]
    
}
   814b8:	d65f03c0 	ret
   814bc:	d503201f 	nop

00000000000814c0 <gicd_init>:
    return ((gicd->TYPER & BIT_MASK(GICD_TYPER_ITLINENUM_OFF, GICD_TYPER_ITLINENUM_LEN) >>
   814c0:	b00000a0 	adrp	x0, 96000 <JIS_state_table+0x70>
//        gicd->ICFGR[i] = 0xAAAAAAAA;

    /* No need to setup gicd->NSACR as all interrupts are  setup to group 1 */

    /* Enable distributor */
    gicd->CTLR = GICD_CTLR_EN_BIT;
   814c4:	52800021 	mov	w1, #0x1                   	// #1
    return ((gicd->TYPER & BIT_MASK(GICD_TYPER_ITLINENUM_OFF, GICD_TYPER_ITLINENUM_LEN) >>
   814c8:	f940f000 	ldr	x0, [x0, #480]
   814cc:	b9400402 	ldr	w2, [x0, #4]
    gicd->CTLR = GICD_CTLR_EN_BIT;
   814d0:	b9000001 	str	w1, [x0]
}
   814d4:	d65f03c0 	ret
   814d8:	d503201f 	nop
   814dc:	d503201f 	nop

00000000000814e0 <gic_init>:
   814e0:	d53800a1 	mrs	x1, mpidr_el1
    return cpuid & MPIDR_CPU_MASK;
   814e4:	b00000a0 	adrp	x0, 96000 <JIS_state_table+0x70>

void gic_init() {
    if(get_cpuid() == 0) {
   814e8:	72001c3f 	tst	w1, #0xff
   814ec:	540000c1 	b.ne	81504 <gic_init+0x24>  // b.any
    return ((gicd->TYPER & BIT_MASK(GICD_TYPER_ITLINENUM_OFF, GICD_TYPER_ITLINENUM_LEN) >>
   814f0:	91076001 	add	x1, x0, #0x1d8
    gicd->CTLR = GICD_CTLR_EN_BIT;
   814f4:	52800022 	mov	w2, #0x1                   	// #1
    return ((gicd->TYPER & BIT_MASK(GICD_TYPER_ITLINENUM_OFF, GICD_TYPER_ITLINENUM_LEN) >>
   814f8:	f9400421 	ldr	x1, [x1, #8]
   814fc:	b9400423 	ldr	w3, [x1, #4]
    gicd->CTLR = GICD_CTLR_EN_BIT;
   81500:	b9000022 	str	w2, [x1]
    gicc->PMR = -1;
   81504:	f940ec00 	ldr	x0, [x0, #472]
   81508:	12800002 	mov	w2, #0xffffffff            	// #-1
    gicc->CTLR = GICC_CTLR_EN_BIT;
   8150c:	52800021 	mov	w1, #0x1                   	// #1
    gicc->PMR = -1;
   81510:	b9000402 	str	w2, [x0, #4]
    gicc->CTLR = GICC_CTLR_EN_BIT;
   81514:	b9000001 	str	w1, [x0]
        gicd_init();
    }
    gicc_init();
}
   81518:	d65f03c0 	ret
   8151c:	d503201f 	nop

0000000000081520 <gic_set_enable>:
    
    uint64_t reg_ind = int_id/(sizeof(uint32_t)*8);
    uint64_t bit = (1UL << int_id%(sizeof(uint32_t)*8));

    if(en)
        gicd->ISENABLER[reg_ind] = bit;
   81520:	b00000a3 	adrp	x3, 96000 <JIS_state_table+0x70>
    uint64_t bit = (1UL << int_id%(sizeof(uint32_t)*8));
   81524:	12001004 	and	w4, w0, #0x1f
    uint64_t reg_ind = int_id/(sizeof(uint32_t)*8);
   81528:	d345fc00 	lsr	x0, x0, #5
    uint64_t bit = (1UL << int_id%(sizeof(uint32_t)*8));
   8152c:	d2800022 	mov	x2, #0x1                   	// #1
        gicd->ISENABLER[reg_ind] = bit;
   81530:	f940f063 	ldr	x3, [x3, #480]
    uint64_t bit = (1UL << int_id%(sizeof(uint32_t)*8));
   81534:	9ac42042 	lsl	x2, x2, x4
        gicd->ISENABLER[reg_ind] = bit;
   81538:	8b000860 	add	x0, x3, x0, lsl #2
    if(en)
   8153c:	72001c3f 	tst	w1, #0xff
   81540:	54000060 	b.eq	8154c <gic_set_enable+0x2c>  // b.none
        gicd->ISENABLER[reg_ind] = bit;
   81544:	b9010002 	str	w2, [x0, #256]
    else
        gicd->ICENABLER[reg_ind] = bit;

}
   81548:	d65f03c0 	ret
        gicd->ICENABLER[reg_ind] = bit;
   8154c:	b9018002 	str	w2, [x0, #384]
}
   81550:	d65f03c0 	ret

0000000000081554 <gic_set_trgt>:
    uint64_t reg_ind = (int_id * GIC_TARGET_BITS) / (sizeof(uint32_t) * 8);
    uint64_t off = (int_id * GIC_TARGET_BITS) % (sizeof(uint32_t) * 8);
    uint32_t mask = ((1U << GIC_TARGET_BITS) - 1) << off;

    gicd->ITARGETSR[reg_ind] =
        (gicd->ITARGETSR[reg_ind] & ~mask) | ((trgt << off) & mask);
   81554:	b00000a2 	adrp	x2, 96000 <JIS_state_table+0x70>
    uint32_t mask = ((1U << GIC_TARGET_BITS) - 1) << off;
   81558:	927ee804 	and	x4, x0, #0x1ffffffffffffffc
{
   8155c:	12001c21 	and	w1, w1, #0xff
    uint64_t off = (int_id * GIC_TARGET_BITS) % (sizeof(uint32_t) * 8);
   81560:	d37d0400 	ubfiz	x0, x0, #3, #2
    gicd->ITARGETSR[reg_ind] =
   81564:	f940f042 	ldr	x2, [x2, #480]
    uint32_t mask = ((1U << GIC_TARGET_BITS) - 1) << off;
   81568:	52801fe3 	mov	w3, #0xff                  	// #255
   8156c:	1ac02063 	lsl	w3, w3, w0
   81570:	8b040042 	add	x2, x2, x4
        (gicd->ITARGETSR[reg_ind] & ~mask) | ((trgt << off) & mask);
   81574:	1ac02021 	lsl	w1, w1, w0
   81578:	b9480040 	ldr	w0, [x2, #2048]
   8157c:	4a000021 	eor	w1, w1, w0
   81580:	0a030021 	and	w1, w1, w3
   81584:	4a000021 	eor	w1, w1, w0
    gicd->ITARGETSR[reg_ind] =
   81588:	b9080041 	str	w1, [x2, #2048]
}
   8158c:	d65f03c0 	ret

0000000000081590 <gic_get_trgt>:
{
    uint64_t reg_ind = (int_id * GIC_TARGET_BITS) / (sizeof(uint32_t) * 8);
    uint64_t off = (int_id * GIC_TARGET_BITS) % (sizeof(uint32_t) * 8);
    uint32_t mask = ((1U << GIC_TARGET_BITS) - 1) << off;

    return (gicd->ITARGETSR[reg_ind] & mask) >> off;
   81590:	b00000a2 	adrp	x2, 96000 <JIS_state_table+0x70>
   81594:	927ee803 	and	x3, x0, #0x1ffffffffffffffc
    uint64_t off = (int_id * GIC_TARGET_BITS) % (sizeof(uint32_t) * 8);
   81598:	d37d0400 	ubfiz	x0, x0, #3, #2
    uint32_t mask = ((1U << GIC_TARGET_BITS) - 1) << off;
   8159c:	52801fe1 	mov	w1, #0xff                  	// #255
    return (gicd->ITARGETSR[reg_ind] & mask) >> off;
   815a0:	f940f042 	ldr	x2, [x2, #480]
    uint32_t mask = ((1U << GIC_TARGET_BITS) - 1) << off;
   815a4:	1ac02021 	lsl	w1, w1, w0
    return (gicd->ITARGETSR[reg_ind] & mask) >> off;
   815a8:	8b030042 	add	x2, x2, x3
   815ac:	b9480042 	ldr	w2, [x2, #2048]
   815b0:	0a020021 	and	w1, w1, w2
}
   815b4:	1ac02420 	lsr	w0, w1, w0
   815b8:	d65f03c0 	ret
   815bc:	d503201f 	nop

00000000000815c0 <gic_send_sgi>:

void gic_send_sgi(uint64_t cpu_target, uint64_t sgi_num){
    gicd->SGIR   = (1UL << (GICD_SGIR_CPUTRGLST_OFF + cpu_target))
   815c0:	b00000a3 	adrp	x3, 96000 <JIS_state_table+0x70>
   815c4:	11004002 	add	w2, w0, #0x10
        | (sgi_num & GICD_SGIR_SGIINTID_MSK);
   815c8:	12000c21 	and	w1, w1, #0xf
    gicd->SGIR   = (1UL << (GICD_SGIR_CPUTRGLST_OFF + cpu_target))
   815cc:	d2800020 	mov	x0, #0x1                   	// #1
   815d0:	f940f063 	ldr	x3, [x3, #480]
   815d4:	9ac22000 	lsl	x0, x0, x2
        | (sgi_num & GICD_SGIR_SGIINTID_MSK);
   815d8:	2a000021 	orr	w1, w1, w0
    gicd->SGIR   = (1UL << (GICD_SGIR_CPUTRGLST_OFF + cpu_target))
   815dc:	b90f0061 	str	w1, [x3, #3840]
}
   815e0:	d65f03c0 	ret

00000000000815e4 <gic_set_prio>:
void gic_set_prio(uint64_t int_id, uint8_t prio){
    uint64_t reg_ind = (int_id*GIC_PRIO_BITS)/(sizeof(uint32_t)*8);
    uint64_t off = (int_id*GIC_PRIO_BITS)%((sizeof(uint32_t)*8));
    uint64_t mask = ((1 << GIC_PRIO_BITS)-1) << off;

    gicd->IPRIORITYR[reg_ind] = (gicd->IPRIORITYR[reg_ind] & ~mask) | 
   815e4:	b00000a2 	adrp	x2, 96000 <JIS_state_table+0x70>
    uint64_t mask = ((1 << GIC_PRIO_BITS)-1) << off;
   815e8:	927ee804 	and	x4, x0, #0x1ffffffffffffffc
void gic_set_prio(uint64_t int_id, uint8_t prio){
   815ec:	12001c21 	and	w1, w1, #0xff
    uint64_t off = (int_id*GIC_PRIO_BITS)%((sizeof(uint32_t)*8));
   815f0:	d37d0400 	ubfiz	x0, x0, #3, #2
    gicd->IPRIORITYR[reg_ind] = (gicd->IPRIORITYR[reg_ind] & ~mask) | 
   815f4:	f940f042 	ldr	x2, [x2, #480]
    uint64_t mask = ((1 << GIC_PRIO_BITS)-1) << off;
   815f8:	52801fe3 	mov	w3, #0xff                  	// #255
   815fc:	1ac02063 	lsl	w3, w3, w0
   81600:	8b040042 	add	x2, x2, x4
        ((prio << off) & mask);
   81604:	1ac02021 	lsl	w1, w1, w0
    gicd->IPRIORITYR[reg_ind] = (gicd->IPRIORITYR[reg_ind] & ~mask) | 
   81608:	b9440040 	ldr	w0, [x2, #1024]
   8160c:	4a000021 	eor	w1, w1, w0
   81610:	0a030021 	and	w1, w1, w3
   81614:	4a000021 	eor	w1, w1, w0
   81618:	b9040041 	str	w1, [x2, #1024]
}
   8161c:	d65f03c0 	ret

0000000000081620 <gic_is_pending>:
bool gic_is_pending(uint64_t int_id){

    uint64_t reg_ind = int_id/(sizeof(uint32_t)*8);
    uint64_t off = int_id%(sizeof(uint32_t)*8);

    return ((1U << off) & gicd->ISPENDR[reg_ind]) != 0;
   81620:	b00000a1 	adrp	x1, 96000 <JIS_state_table+0x70>
   81624:	f940f022 	ldr	x2, [x1, #480]
    uint64_t reg_ind = int_id/(sizeof(uint32_t)*8);
   81628:	d345fc01 	lsr	x1, x0, #5
    uint64_t off = int_id%(sizeof(uint32_t)*8);
   8162c:	92401000 	and	x0, x0, #0x1f
    return ((1U << off) & gicd->ISPENDR[reg_ind]) != 0;
   81630:	8b010841 	add	x1, x2, x1, lsl #2
   81634:	b9420021 	ldr	w1, [x1, #512]
   81638:	1ac02420 	lsr	w0, w1, w0
}
   8163c:	12000000 	and	w0, w0, #0x1
   81640:	d65f03c0 	ret

0000000000081644 <gic_set_pending>:
void gic_set_pending(uint64_t int_id, bool pending){
    uint64_t reg_ind = int_id / (sizeof(uint32_t) * 8);
    uint64_t mask = 1U << int_id % (sizeof(uint32_t) * 8);

    if (pending) {
        gicd->ISPENDR[reg_ind] = mask;
   81644:	b00000a2 	adrp	x2, 96000 <JIS_state_table+0x70>
    uint64_t mask = 1U << int_id % (sizeof(uint32_t) * 8);
   81648:	52800023 	mov	w3, #0x1                   	// #1
        gicd->ISPENDR[reg_ind] = mask;
   8164c:	f940f044 	ldr	x4, [x2, #480]
    uint64_t reg_ind = int_id / (sizeof(uint32_t) * 8);
   81650:	d345fc02 	lsr	x2, x0, #5
    uint64_t mask = 1U << int_id % (sizeof(uint32_t) * 8);
   81654:	1ac02060 	lsl	w0, w3, w0
        gicd->ISPENDR[reg_ind] = mask;
   81658:	8b020882 	add	x2, x4, x2, lsl #2
    if (pending) {
   8165c:	72001c3f 	tst	w1, #0xff
   81660:	54000060 	b.eq	8166c <gic_set_pending+0x28>  // b.none
        gicd->ISPENDR[reg_ind] = mask;
   81664:	b9020040 	str	w0, [x2, #512]
    } else {
        gicd->ICPENDR[reg_ind] = mask;
    }   
}
   81668:	d65f03c0 	ret
        gicd->ICPENDR[reg_ind] = mask;
   8166c:	b9028040 	str	w0, [x2, #640]
}
   81670:	d65f03c0 	ret

0000000000081674 <gic_is_active>:
bool gic_is_active(uint64_t int_id){

    uint64_t reg_ind = int_id/(sizeof(uint32_t)*8);
    uint64_t off = int_id%(sizeof(uint32_t)*8);

    return ((1U << off) & gicd->ISACTIVER[reg_ind]) != 0;
   81674:	b00000a1 	adrp	x1, 96000 <JIS_state_table+0x70>
   81678:	f940f022 	ldr	x2, [x1, #480]
    uint64_t reg_ind = int_id/(sizeof(uint32_t)*8);
   8167c:	d345fc01 	lsr	x1, x0, #5
    uint64_t off = int_id%(sizeof(uint32_t)*8);
   81680:	92401000 	and	x0, x0, #0x1f
    return ((1U << off) & gicd->ISACTIVER[reg_ind]) != 0;
   81684:	8b010841 	add	x1, x2, x1, lsl #2
   81688:	b9430021 	ldr	w1, [x1, #768]
   8168c:	1ac02420 	lsr	w0, w1, w0
}
   81690:	12000000 	and	w0, w0, #0x1
   81694:	d65f03c0 	ret
   81698:	d503201f 	nop
   8169c:	d503201f 	nop

00000000000816a0 <gic_handle>:

void gic_handle(){
   816a0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   816a4:	910003fd 	mov	x29, sp
   816a8:	a90153f3 	stp	x19, x20, [sp, #16]

    uint64_t ack = gicc->IAR;
   816ac:	b00000b4 	adrp	x20, 96000 <JIS_state_table+0x70>
   816b0:	f940ee80 	ldr	x0, [x20, #472]
   816b4:	b9400c13 	ldr	w19, [x0, #12]
    uint64_t id = ack & GICC_IAR_ID_MSK;
   816b8:	12002660 	and	w0, w19, #0x3ff
    uint64_t src = (ack & GICC_IAR_CPU_MSK) >> GICC_IAR_CPU_OFF;

    if(id >= 1022) return;
   816bc:	710ff41f 	cmp	w0, #0x3fd
   816c0:	54000088 	b.hi	816d0 <gic_handle+0x30>  // b.pmore

    irq_handle(id);
   816c4:	97fffd9b 	bl	80d30 <irq_handle>
        
    gicc->EOIR = ack;
   816c8:	f940ee80 	ldr	x0, [x20, #472]
   816cc:	b9001013 	str	w19, [x0, #16]
    
}
   816d0:	a94153f3 	ldp	x19, x20, [sp, #16]
   816d4:	a8c27bfd 	ldp	x29, x30, [sp], #32
   816d8:	d65f03c0 	ret
	...

0000000000081800 <_exception_vector>:
/* 
 * EL1 with SP0
 */  
.balign ENTRY_SIZE
curr_el_sp0_sync:        
    b	.
   81800:	14000000 	b	81800 <_exception_vector>
   81804:	d503201f 	nop
   81808:	d503201f 	nop
   8180c:	d503201f 	nop
   81810:	d503201f 	nop
   81814:	d503201f 	nop
   81818:	d503201f 	nop
   8181c:	d503201f 	nop
   81820:	d503201f 	nop
   81824:	d503201f 	nop
   81828:	d503201f 	nop
   8182c:	d503201f 	nop
   81830:	d503201f 	nop
   81834:	d503201f 	nop
   81838:	d503201f 	nop
   8183c:	d503201f 	nop
   81840:	d503201f 	nop
   81844:	d503201f 	nop
   81848:	d503201f 	nop
   8184c:	d503201f 	nop
   81850:	d503201f 	nop
   81854:	d503201f 	nop
   81858:	d503201f 	nop
   8185c:	d503201f 	nop
   81860:	d503201f 	nop
   81864:	d503201f 	nop
   81868:	d503201f 	nop
   8186c:	d503201f 	nop
   81870:	d503201f 	nop
   81874:	d503201f 	nop
   81878:	d503201f 	nop
   8187c:	d503201f 	nop

0000000000081880 <curr_el_sp0_irq>:
.balign ENTRY_SIZE
curr_el_sp0_irq:  
    b   .
   81880:	14000000 	b	81880 <curr_el_sp0_irq>
   81884:	d503201f 	nop
   81888:	d503201f 	nop
   8188c:	d503201f 	nop
   81890:	d503201f 	nop
   81894:	d503201f 	nop
   81898:	d503201f 	nop
   8189c:	d503201f 	nop
   818a0:	d503201f 	nop
   818a4:	d503201f 	nop
   818a8:	d503201f 	nop
   818ac:	d503201f 	nop
   818b0:	d503201f 	nop
   818b4:	d503201f 	nop
   818b8:	d503201f 	nop
   818bc:	d503201f 	nop
   818c0:	d503201f 	nop
   818c4:	d503201f 	nop
   818c8:	d503201f 	nop
   818cc:	d503201f 	nop
   818d0:	d503201f 	nop
   818d4:	d503201f 	nop
   818d8:	d503201f 	nop
   818dc:	d503201f 	nop
   818e0:	d503201f 	nop
   818e4:	d503201f 	nop
   818e8:	d503201f 	nop
   818ec:	d503201f 	nop
   818f0:	d503201f 	nop
   818f4:	d503201f 	nop
   818f8:	d503201f 	nop
   818fc:	d503201f 	nop

0000000000081900 <curr_el_sp0_fiq>:
.balign ENTRY_SIZE
curr_el_sp0_fiq:         
    b	.
   81900:	14000000 	b	81900 <curr_el_sp0_fiq>
   81904:	d503201f 	nop
   81908:	d503201f 	nop
   8190c:	d503201f 	nop
   81910:	d503201f 	nop
   81914:	d503201f 	nop
   81918:	d503201f 	nop
   8191c:	d503201f 	nop
   81920:	d503201f 	nop
   81924:	d503201f 	nop
   81928:	d503201f 	nop
   8192c:	d503201f 	nop
   81930:	d503201f 	nop
   81934:	d503201f 	nop
   81938:	d503201f 	nop
   8193c:	d503201f 	nop
   81940:	d503201f 	nop
   81944:	d503201f 	nop
   81948:	d503201f 	nop
   8194c:	d503201f 	nop
   81950:	d503201f 	nop
   81954:	d503201f 	nop
   81958:	d503201f 	nop
   8195c:	d503201f 	nop
   81960:	d503201f 	nop
   81964:	d503201f 	nop
   81968:	d503201f 	nop
   8196c:	d503201f 	nop
   81970:	d503201f 	nop
   81974:	d503201f 	nop
   81978:	d503201f 	nop
   8197c:	d503201f 	nop

0000000000081980 <curr_el_sp0_serror>:
.balign ENTRY_SIZE
curr_el_sp0_serror:      
    b	.
   81980:	14000000 	b	81980 <curr_el_sp0_serror>
   81984:	d503201f 	nop
   81988:	d503201f 	nop
   8198c:	d503201f 	nop
   81990:	d503201f 	nop
   81994:	d503201f 	nop
   81998:	d503201f 	nop
   8199c:	d503201f 	nop
   819a0:	d503201f 	nop
   819a4:	d503201f 	nop
   819a8:	d503201f 	nop
   819ac:	d503201f 	nop
   819b0:	d503201f 	nop
   819b4:	d503201f 	nop
   819b8:	d503201f 	nop
   819bc:	d503201f 	nop
   819c0:	d503201f 	nop
   819c4:	d503201f 	nop
   819c8:	d503201f 	nop
   819cc:	d503201f 	nop
   819d0:	d503201f 	nop
   819d4:	d503201f 	nop
   819d8:	d503201f 	nop
   819dc:	d503201f 	nop
   819e0:	d503201f 	nop
   819e4:	d503201f 	nop
   819e8:	d503201f 	nop
   819ec:	d503201f 	nop
   819f0:	d503201f 	nop
   819f4:	d503201f 	nop
   819f8:	d503201f 	nop
   819fc:	d503201f 	nop

0000000000081a00 <curr_el_spx_sync>:
/* 
 * EL1 with SPx
 */  
.balign ENTRY_SIZE  
curr_el_spx_sync:        
    b	.
   81a00:	14000000 	b	81a00 <curr_el_spx_sync>
   81a04:	d503201f 	nop
   81a08:	d503201f 	nop
   81a0c:	d503201f 	nop
   81a10:	d503201f 	nop
   81a14:	d503201f 	nop
   81a18:	d503201f 	nop
   81a1c:	d503201f 	nop
   81a20:	d503201f 	nop
   81a24:	d503201f 	nop
   81a28:	d503201f 	nop
   81a2c:	d503201f 	nop
   81a30:	d503201f 	nop
   81a34:	d503201f 	nop
   81a38:	d503201f 	nop
   81a3c:	d503201f 	nop
   81a40:	d503201f 	nop
   81a44:	d503201f 	nop
   81a48:	d503201f 	nop
   81a4c:	d503201f 	nop
   81a50:	d503201f 	nop
   81a54:	d503201f 	nop
   81a58:	d503201f 	nop
   81a5c:	d503201f 	nop
   81a60:	d503201f 	nop
   81a64:	d503201f 	nop
   81a68:	d503201f 	nop
   81a6c:	d503201f 	nop
   81a70:	d503201f 	nop
   81a74:	d503201f 	nop
   81a78:	d503201f 	nop
   81a7c:	d503201f 	nop

0000000000081a80 <curr_el_spx_irq>:
.balign ENTRY_SIZE
curr_el_spx_irq:       
    SAVE_REGS
   81a80:	d102c3ff 	sub	sp, sp, #0xb0
   81a84:	a90007e0 	stp	x0, x1, [sp]
   81a88:	a9010fe2 	stp	x2, x3, [sp, #16]
   81a8c:	a90217e4 	stp	x4, x5, [sp, #32]
   81a90:	a9031fe6 	stp	x6, x7, [sp, #48]
   81a94:	a90427e8 	stp	x8, x9, [sp, #64]
   81a98:	a9052fea 	stp	x10, x11, [sp, #80]
   81a9c:	a90637ec 	stp	x12, x13, [sp, #96]
   81aa0:	a9073fee 	stp	x14, x15, [sp, #112]
   81aa4:	a90847f0 	stp	x16, x17, [sp, #128]
   81aa8:	a9094ff2 	stp	x18, x19, [sp, #144]
   81aac:	a90e7bfd 	stp	x29, x30, [sp, #224]
    bl	gic_handle
   81ab0:	97fffefc 	bl	816a0 <gic_handle>
    RESTORE_REGS
   81ab4:	a94007e0 	ldp	x0, x1, [sp]
   81ab8:	a9410fe2 	ldp	x2, x3, [sp, #16]
   81abc:	a94217e4 	ldp	x4, x5, [sp, #32]
   81ac0:	a9431fe6 	ldp	x6, x7, [sp, #48]
   81ac4:	a94427e8 	ldp	x8, x9, [sp, #64]
   81ac8:	a9452fea 	ldp	x10, x11, [sp, #80]
   81acc:	a94637ec 	ldp	x12, x13, [sp, #96]
   81ad0:	a9473fee 	ldp	x14, x15, [sp, #112]
   81ad4:	a94847f0 	ldp	x16, x17, [sp, #128]
   81ad8:	a9494ff2 	ldp	x18, x19, [sp, #144]
   81adc:	a94e7bfd 	ldp	x29, x30, [sp, #224]
   81ae0:	9102c3ff 	add	sp, sp, #0xb0
    eret
   81ae4:	d69f03e0 	eret
   81ae8:	d503201f 	nop
   81aec:	d503201f 	nop
   81af0:	d503201f 	nop
   81af4:	d503201f 	nop
   81af8:	d503201f 	nop
   81afc:	d503201f 	nop

0000000000081b00 <curr_el_spx_fiq>:
.balign ENTRY_SIZE
curr_el_spx_fiq:         
    SAVE_REGS
   81b00:	d102c3ff 	sub	sp, sp, #0xb0
   81b04:	a90007e0 	stp	x0, x1, [sp]
   81b08:	a9010fe2 	stp	x2, x3, [sp, #16]
   81b0c:	a90217e4 	stp	x4, x5, [sp, #32]
   81b10:	a9031fe6 	stp	x6, x7, [sp, #48]
   81b14:	a90427e8 	stp	x8, x9, [sp, #64]
   81b18:	a9052fea 	stp	x10, x11, [sp, #80]
   81b1c:	a90637ec 	stp	x12, x13, [sp, #96]
   81b20:	a9073fee 	stp	x14, x15, [sp, #112]
   81b24:	a90847f0 	stp	x16, x17, [sp, #128]
   81b28:	a9094ff2 	stp	x18, x19, [sp, #144]
   81b2c:	a90e7bfd 	stp	x29, x30, [sp, #224]
    bl	gic_handle
   81b30:	97fffedc 	bl	816a0 <gic_handle>
    RESTORE_REGS
   81b34:	a94007e0 	ldp	x0, x1, [sp]
   81b38:	a9410fe2 	ldp	x2, x3, [sp, #16]
   81b3c:	a94217e4 	ldp	x4, x5, [sp, #32]
   81b40:	a9431fe6 	ldp	x6, x7, [sp, #48]
   81b44:	a94427e8 	ldp	x8, x9, [sp, #64]
   81b48:	a9452fea 	ldp	x10, x11, [sp, #80]
   81b4c:	a94637ec 	ldp	x12, x13, [sp, #96]
   81b50:	a9473fee 	ldp	x14, x15, [sp, #112]
   81b54:	a94847f0 	ldp	x16, x17, [sp, #128]
   81b58:	a9494ff2 	ldp	x18, x19, [sp, #144]
   81b5c:	a94e7bfd 	ldp	x29, x30, [sp, #224]
   81b60:	9102c3ff 	add	sp, sp, #0xb0
    eret
   81b64:	d69f03e0 	eret
   81b68:	d503201f 	nop
   81b6c:	d503201f 	nop
   81b70:	d503201f 	nop
   81b74:	d503201f 	nop
   81b78:	d503201f 	nop
   81b7c:	d503201f 	nop

0000000000081b80 <curr_el_spx_serror>:
.balign ENTRY_SIZE
curr_el_spx_serror:      
    b	.         
   81b80:	14000000 	b	81b80 <curr_el_spx_serror>
   81b84:	d503201f 	nop
   81b88:	d503201f 	nop
   81b8c:	d503201f 	nop
   81b90:	d503201f 	nop
   81b94:	d503201f 	nop
   81b98:	d503201f 	nop
   81b9c:	d503201f 	nop
   81ba0:	d503201f 	nop
   81ba4:	d503201f 	nop
   81ba8:	d503201f 	nop
   81bac:	d503201f 	nop
   81bb0:	d503201f 	nop
   81bb4:	d503201f 	nop
   81bb8:	d503201f 	nop
   81bbc:	d503201f 	nop
   81bc0:	d503201f 	nop
   81bc4:	d503201f 	nop
   81bc8:	d503201f 	nop
   81bcc:	d503201f 	nop
   81bd0:	d503201f 	nop
   81bd4:	d503201f 	nop
   81bd8:	d503201f 	nop
   81bdc:	d503201f 	nop
   81be0:	d503201f 	nop
   81be4:	d503201f 	nop
   81be8:	d503201f 	nop
   81bec:	d503201f 	nop
   81bf0:	d503201f 	nop
   81bf4:	d503201f 	nop
   81bf8:	d503201f 	nop
   81bfc:	d503201f 	nop

0000000000081c00 <lower_el_aarch64_sync>:
 * Lower EL using AArch64
 */  

.balign ENTRY_SIZE
lower_el_aarch64_sync:
    b .
   81c00:	14000000 	b	81c00 <lower_el_aarch64_sync>
   81c04:	d503201f 	nop
   81c08:	d503201f 	nop
   81c0c:	d503201f 	nop
   81c10:	d503201f 	nop
   81c14:	d503201f 	nop
   81c18:	d503201f 	nop
   81c1c:	d503201f 	nop
   81c20:	d503201f 	nop
   81c24:	d503201f 	nop
   81c28:	d503201f 	nop
   81c2c:	d503201f 	nop
   81c30:	d503201f 	nop
   81c34:	d503201f 	nop
   81c38:	d503201f 	nop
   81c3c:	d503201f 	nop
   81c40:	d503201f 	nop
   81c44:	d503201f 	nop
   81c48:	d503201f 	nop
   81c4c:	d503201f 	nop
   81c50:	d503201f 	nop
   81c54:	d503201f 	nop
   81c58:	d503201f 	nop
   81c5c:	d503201f 	nop
   81c60:	d503201f 	nop
   81c64:	d503201f 	nop
   81c68:	d503201f 	nop
   81c6c:	d503201f 	nop
   81c70:	d503201f 	nop
   81c74:	d503201f 	nop
   81c78:	d503201f 	nop
   81c7c:	d503201f 	nop

0000000000081c80 <lower_el_aarch64_irq>:
.balign ENTRY_SIZE
lower_el_aarch64_irq:    
    b .
   81c80:	14000000 	b	81c80 <lower_el_aarch64_irq>
   81c84:	d503201f 	nop
   81c88:	d503201f 	nop
   81c8c:	d503201f 	nop
   81c90:	d503201f 	nop
   81c94:	d503201f 	nop
   81c98:	d503201f 	nop
   81c9c:	d503201f 	nop
   81ca0:	d503201f 	nop
   81ca4:	d503201f 	nop
   81ca8:	d503201f 	nop
   81cac:	d503201f 	nop
   81cb0:	d503201f 	nop
   81cb4:	d503201f 	nop
   81cb8:	d503201f 	nop
   81cbc:	d503201f 	nop
   81cc0:	d503201f 	nop
   81cc4:	d503201f 	nop
   81cc8:	d503201f 	nop
   81ccc:	d503201f 	nop
   81cd0:	d503201f 	nop
   81cd4:	d503201f 	nop
   81cd8:	d503201f 	nop
   81cdc:	d503201f 	nop
   81ce0:	d503201f 	nop
   81ce4:	d503201f 	nop
   81ce8:	d503201f 	nop
   81cec:	d503201f 	nop
   81cf0:	d503201f 	nop
   81cf4:	d503201f 	nop
   81cf8:	d503201f 	nop
   81cfc:	d503201f 	nop

0000000000081d00 <lower_el_aarch64_fiq>:
.balign ENTRY_SIZE
lower_el_aarch64_fiq:    
    b	.
   81d00:	14000000 	b	81d00 <lower_el_aarch64_fiq>
   81d04:	d503201f 	nop
   81d08:	d503201f 	nop
   81d0c:	d503201f 	nop
   81d10:	d503201f 	nop
   81d14:	d503201f 	nop
   81d18:	d503201f 	nop
   81d1c:	d503201f 	nop
   81d20:	d503201f 	nop
   81d24:	d503201f 	nop
   81d28:	d503201f 	nop
   81d2c:	d503201f 	nop
   81d30:	d503201f 	nop
   81d34:	d503201f 	nop
   81d38:	d503201f 	nop
   81d3c:	d503201f 	nop
   81d40:	d503201f 	nop
   81d44:	d503201f 	nop
   81d48:	d503201f 	nop
   81d4c:	d503201f 	nop
   81d50:	d503201f 	nop
   81d54:	d503201f 	nop
   81d58:	d503201f 	nop
   81d5c:	d503201f 	nop
   81d60:	d503201f 	nop
   81d64:	d503201f 	nop
   81d68:	d503201f 	nop
   81d6c:	d503201f 	nop
   81d70:	d503201f 	nop
   81d74:	d503201f 	nop
   81d78:	d503201f 	nop
   81d7c:	d503201f 	nop

0000000000081d80 <lower_el_aarch64_serror>:
.balign ENTRY_SIZE
lower_el_aarch64_serror: 
    b	.          
   81d80:	14000000 	b	81d80 <lower_el_aarch64_serror>
   81d84:	d503201f 	nop
   81d88:	d503201f 	nop
   81d8c:	d503201f 	nop
   81d90:	d503201f 	nop
   81d94:	d503201f 	nop
   81d98:	d503201f 	nop
   81d9c:	d503201f 	nop
   81da0:	d503201f 	nop
   81da4:	d503201f 	nop
   81da8:	d503201f 	nop
   81dac:	d503201f 	nop
   81db0:	d503201f 	nop
   81db4:	d503201f 	nop
   81db8:	d503201f 	nop
   81dbc:	d503201f 	nop
   81dc0:	d503201f 	nop
   81dc4:	d503201f 	nop
   81dc8:	d503201f 	nop
   81dcc:	d503201f 	nop
   81dd0:	d503201f 	nop
   81dd4:	d503201f 	nop
   81dd8:	d503201f 	nop
   81ddc:	d503201f 	nop
   81de0:	d503201f 	nop
   81de4:	d503201f 	nop
   81de8:	d503201f 	nop
   81dec:	d503201f 	nop
   81df0:	d503201f 	nop
   81df4:	d503201f 	nop
   81df8:	d503201f 	nop
   81dfc:	d503201f 	nop

0000000000081e00 <lower_el_aarch32_sync>:
/* 
 * Lower EL using AArch32
 */  
.balign ENTRY_SIZE   
lower_el_aarch32_sync:   
    b	.
   81e00:	14000000 	b	81e00 <lower_el_aarch32_sync>
   81e04:	d503201f 	nop
   81e08:	d503201f 	nop
   81e0c:	d503201f 	nop
   81e10:	d503201f 	nop
   81e14:	d503201f 	nop
   81e18:	d503201f 	nop
   81e1c:	d503201f 	nop
   81e20:	d503201f 	nop
   81e24:	d503201f 	nop
   81e28:	d503201f 	nop
   81e2c:	d503201f 	nop
   81e30:	d503201f 	nop
   81e34:	d503201f 	nop
   81e38:	d503201f 	nop
   81e3c:	d503201f 	nop
   81e40:	d503201f 	nop
   81e44:	d503201f 	nop
   81e48:	d503201f 	nop
   81e4c:	d503201f 	nop
   81e50:	d503201f 	nop
   81e54:	d503201f 	nop
   81e58:	d503201f 	nop
   81e5c:	d503201f 	nop
   81e60:	d503201f 	nop
   81e64:	d503201f 	nop
   81e68:	d503201f 	nop
   81e6c:	d503201f 	nop
   81e70:	d503201f 	nop
   81e74:	d503201f 	nop
   81e78:	d503201f 	nop
   81e7c:	d503201f 	nop

0000000000081e80 <lower_el_aarch32_irq>:
.balign ENTRY_SIZE
lower_el_aarch32_irq:    
    b	.
   81e80:	14000000 	b	81e80 <lower_el_aarch32_irq>
   81e84:	d503201f 	nop
   81e88:	d503201f 	nop
   81e8c:	d503201f 	nop
   81e90:	d503201f 	nop
   81e94:	d503201f 	nop
   81e98:	d503201f 	nop
   81e9c:	d503201f 	nop
   81ea0:	d503201f 	nop
   81ea4:	d503201f 	nop
   81ea8:	d503201f 	nop
   81eac:	d503201f 	nop
   81eb0:	d503201f 	nop
   81eb4:	d503201f 	nop
   81eb8:	d503201f 	nop
   81ebc:	d503201f 	nop
   81ec0:	d503201f 	nop
   81ec4:	d503201f 	nop
   81ec8:	d503201f 	nop
   81ecc:	d503201f 	nop
   81ed0:	d503201f 	nop
   81ed4:	d503201f 	nop
   81ed8:	d503201f 	nop
   81edc:	d503201f 	nop
   81ee0:	d503201f 	nop
   81ee4:	d503201f 	nop
   81ee8:	d503201f 	nop
   81eec:	d503201f 	nop
   81ef0:	d503201f 	nop
   81ef4:	d503201f 	nop
   81ef8:	d503201f 	nop
   81efc:	d503201f 	nop

0000000000081f00 <lower_el_aarch32_fiq>:
.balign ENTRY_SIZE
lower_el_aarch32_fiq:    
    b	.
   81f00:	14000000 	b	81f00 <lower_el_aarch32_fiq>
   81f04:	d503201f 	nop
   81f08:	d503201f 	nop
   81f0c:	d503201f 	nop
   81f10:	d503201f 	nop
   81f14:	d503201f 	nop
   81f18:	d503201f 	nop
   81f1c:	d503201f 	nop
   81f20:	d503201f 	nop
   81f24:	d503201f 	nop
   81f28:	d503201f 	nop
   81f2c:	d503201f 	nop
   81f30:	d503201f 	nop
   81f34:	d503201f 	nop
   81f38:	d503201f 	nop
   81f3c:	d503201f 	nop
   81f40:	d503201f 	nop
   81f44:	d503201f 	nop
   81f48:	d503201f 	nop
   81f4c:	d503201f 	nop
   81f50:	d503201f 	nop
   81f54:	d503201f 	nop
   81f58:	d503201f 	nop
   81f5c:	d503201f 	nop
   81f60:	d503201f 	nop
   81f64:	d503201f 	nop
   81f68:	d503201f 	nop
   81f6c:	d503201f 	nop
   81f70:	d503201f 	nop
   81f74:	d503201f 	nop
   81f78:	d503201f 	nop
   81f7c:	d503201f 	nop

0000000000081f80 <lower_el_aarch32_serror>:
.balign ENTRY_SIZE
lower_el_aarch32_serror: 
    b	.
   81f80:	14000000 	b	81f80 <lower_el_aarch32_serror>
   81f84:	d503201f 	nop
   81f88:	d503201f 	nop
   81f8c:	d503201f 	nop
   81f90:	d503201f 	nop
   81f94:	d503201f 	nop
   81f98:	d503201f 	nop
   81f9c:	d503201f 	nop
   81fa0:	d503201f 	nop
   81fa4:	d503201f 	nop
   81fa8:	d503201f 	nop
   81fac:	d503201f 	nop
   81fb0:	d503201f 	nop
   81fb4:	d503201f 	nop
   81fb8:	d503201f 	nop
   81fbc:	d503201f 	nop
   81fc0:	d503201f 	nop
   81fc4:	d503201f 	nop
   81fc8:	d503201f 	nop
   81fcc:	d503201f 	nop
   81fd0:	d503201f 	nop
   81fd4:	d503201f 	nop
   81fd8:	d503201f 	nop
   81fdc:	d503201f 	nop
   81fe0:	d503201f 	nop
   81fe4:	d503201f 	nop
   81fe8:	d503201f 	nop
   81fec:	d503201f 	nop
   81ff0:	d503201f 	nop
   81ff4:	d503201f 	nop
   81ff8:	d503201f 	nop
   81ffc:	d503201f 	nop

0000000000082000 <__errno>:
   82000:	900000a0 	adrp	x0, 96000 <JIS_state_table+0x70>
   82004:	f9410000 	ldr	x0, [x0, #512]
   82008:	d65f03c0 	ret
   8200c:	00000000 	udf	#0

0000000000082010 <_printf_r>:
   82010:	a9b07bfd 	stp	x29, x30, [sp, #-256]!
   82014:	128005e9 	mov	w9, #0xffffffd0            	// #-48
   82018:	12800fe8 	mov	w8, #0xffffff80            	// #-128
   8201c:	910003fd 	mov	x29, sp
   82020:	910343ea 	add	x10, sp, #0xd0
   82024:	910403eb 	add	x11, sp, #0x100
   82028:	a9032feb 	stp	x11, x11, [sp, #48]
   8202c:	f90023ea 	str	x10, [sp, #64]
   82030:	290923e9 	stp	w9, w8, [sp, #72]
   82034:	3d8017e0 	str	q0, [sp, #80]
   82038:	ad41c3e0 	ldp	q0, q16, [sp, #48]
   8203c:	3d801be1 	str	q1, [sp, #96]
   82040:	3d801fe2 	str	q2, [sp, #112]
   82044:	3d8023e3 	str	q3, [sp, #128]
   82048:	3d8027e4 	str	q4, [sp, #144]
   8204c:	3d802be5 	str	q5, [sp, #160]
   82050:	3d802fe6 	str	q6, [sp, #176]
   82054:	3d8033e7 	str	q7, [sp, #192]
   82058:	a90d0fe2 	stp	x2, x3, [sp, #208]
   8205c:	aa0103e2 	mov	x2, x1
   82060:	910043e3 	add	x3, sp, #0x10
   82064:	a90e17e4 	stp	x4, x5, [sp, #224]
   82068:	a90f1fe6 	stp	x6, x7, [sp, #240]
   8206c:	ad00c3e0 	stp	q0, q16, [sp, #16]
   82070:	f9400801 	ldr	x1, [x0, #16]
   82074:	9400109f 	bl	862f0 <_vfprintf_r>
   82078:	a8d07bfd 	ldp	x29, x30, [sp], #256
   8207c:	d65f03c0 	ret

0000000000082080 <printf>:
   82080:	a9af7bfd 	stp	x29, x30, [sp, #-272]!
   82084:	128006eb 	mov	w11, #0xffffffc8            	// #-56
   82088:	12800fea 	mov	w10, #0xffffff80            	// #-128
   8208c:	910003fd 	mov	x29, sp
   82090:	910343ec 	add	x12, sp, #0xd0
   82094:	910443e8 	add	x8, sp, #0x110
   82098:	900000a9 	adrp	x9, 96000 <JIS_state_table+0x70>
   8209c:	a90323e8 	stp	x8, x8, [sp, #48]
   820a0:	aa0003e8 	mov	x8, x0
   820a4:	f90023ec 	str	x12, [sp, #64]
   820a8:	29092beb 	stp	w11, w10, [sp, #72]
   820ac:	f9410120 	ldr	x0, [x9, #512]
   820b0:	3d8017e0 	str	q0, [sp, #80]
   820b4:	ad41c3e0 	ldp	q0, q16, [sp, #48]
   820b8:	3d801be1 	str	q1, [sp, #96]
   820bc:	3d801fe2 	str	q2, [sp, #112]
   820c0:	3d8023e3 	str	q3, [sp, #128]
   820c4:	3d8027e4 	str	q4, [sp, #144]
   820c8:	3d802be5 	str	q5, [sp, #160]
   820cc:	3d802fe6 	str	q6, [sp, #176]
   820d0:	3d8033e7 	str	q7, [sp, #192]
   820d4:	a90d8be1 	stp	x1, x2, [sp, #216]
   820d8:	aa0803e2 	mov	x2, x8
   820dc:	a90e93e3 	stp	x3, x4, [sp, #232]
   820e0:	910043e3 	add	x3, sp, #0x10
   820e4:	a90f9be5 	stp	x5, x6, [sp, #248]
   820e8:	f90087e7 	str	x7, [sp, #264]
   820ec:	ad00c3e0 	stp	q0, q16, [sp, #16]
   820f0:	f9400801 	ldr	x1, [x0, #16]
   820f4:	9400107f 	bl	862f0 <_vfprintf_r>
   820f8:	a8d17bfd 	ldp	x29, x30, [sp], #272
   820fc:	d65f03c0 	ret

0000000000082100 <_putchar_r>:
   82100:	f9400802 	ldr	x2, [x0, #16]
   82104:	14002cbb 	b	8d3f0 <_putc_r>
	...

0000000000082110 <putchar>:
   82110:	900000a2 	adrp	x2, 96000 <JIS_state_table+0x70>
   82114:	2a0003e1 	mov	w1, w0
   82118:	f9410040 	ldr	x0, [x2, #512]
   8211c:	f9400802 	ldr	x2, [x0, #16]
   82120:	14002cb4 	b	8d3f0 <_putc_r>
	...

0000000000082130 <_puts_r>:
   82130:	a9ba7bfd 	stp	x29, x30, [sp, #-96]!
   82134:	910003fd 	mov	x29, sp
   82138:	a90153f3 	stp	x19, x20, [sp, #16]
   8213c:	aa0003f4 	mov	x20, x0
   82140:	aa0103f3 	mov	x19, x1
   82144:	aa0103e0 	mov	x0, x1
   82148:	9400020e 	bl	82980 <strlen>
   8214c:	f9402682 	ldr	x2, [x20, #72]
   82150:	91000404 	add	x4, x0, #0x1
   82154:	910103e6 	add	x6, sp, #0x40
   82158:	f0000081 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8215c:	d2800023 	mov	x3, #0x1                   	// #1
   82160:	91170021 	add	x1, x1, #0x5c0
   82164:	52800045 	mov	w5, #0x2                   	// #2
   82168:	f90017e6 	str	x6, [sp, #40]
   8216c:	b90033e5 	str	w5, [sp, #48]
   82170:	a903cfe4 	stp	x4, x19, [sp, #56]
   82174:	a90487e0 	stp	x0, x1, [sp, #72]
   82178:	f9002fe3 	str	x3, [sp, #88]
   8217c:	f9400a93 	ldr	x19, [x20, #16]
   82180:	b4000482 	cbz	x2, 82210 <_puts_r+0xe0>
   82184:	b940b261 	ldr	w1, [x19, #176]
   82188:	79c02260 	ldrsh	w0, [x19, #16]
   8218c:	37000041 	tbnz	w1, #0, 82194 <_puts_r+0x64>
   82190:	36480380 	tbz	w0, #9, 82200 <_puts_r+0xd0>
   82194:	376800c0 	tbnz	w0, #13, 821ac <_puts_r+0x7c>
   82198:	b940b261 	ldr	w1, [x19, #176]
   8219c:	32130000 	orr	w0, w0, #0x2000
   821a0:	79002260 	strh	w0, [x19, #16]
   821a4:	12127820 	and	w0, w1, #0xffffdfff
   821a8:	b900b260 	str	w0, [x19, #176]
   821ac:	aa1403e0 	mov	x0, x20
   821b0:	aa1303e1 	mov	x1, x19
   821b4:	9100a3e2 	add	x2, sp, #0x28
   821b8:	9400028e 	bl	82bf0 <__sfvwrite_r>
   821bc:	b940b261 	ldr	w1, [x19, #176]
   821c0:	7100001f 	cmp	w0, #0x0
   821c4:	52800154 	mov	w20, #0xa                   	// #10
   821c8:	5a9f0294 	csinv	w20, w20, wzr, eq	// eq = none
   821cc:	37000061 	tbnz	w1, #0, 821d8 <_puts_r+0xa8>
   821d0:	79402260 	ldrh	w0, [x19, #16]
   821d4:	364800a0 	tbz	w0, #9, 821e8 <_puts_r+0xb8>
   821d8:	2a1403e0 	mov	w0, w20
   821dc:	a94153f3 	ldp	x19, x20, [sp, #16]
   821e0:	a8c67bfd 	ldp	x29, x30, [sp], #96
   821e4:	d65f03c0 	ret
   821e8:	f9405260 	ldr	x0, [x19, #160]
   821ec:	94002761 	bl	8bf70 <__retarget_lock_release_recursive>
   821f0:	2a1403e0 	mov	w0, w20
   821f4:	a94153f3 	ldp	x19, x20, [sp, #16]
   821f8:	a8c67bfd 	ldp	x29, x30, [sp], #96
   821fc:	d65f03c0 	ret
   82200:	f9405260 	ldr	x0, [x19, #160]
   82204:	9400274b 	bl	8bf30 <__retarget_lock_acquire_recursive>
   82208:	79c02260 	ldrsh	w0, [x19, #16]
   8220c:	17ffffe2 	b	82194 <_puts_r+0x64>
   82210:	aa1403e0 	mov	x0, x20
   82214:	940000fb 	bl	82600 <__sinit>
   82218:	17ffffdb 	b	82184 <_puts_r+0x54>
   8221c:	00000000 	udf	#0

0000000000082220 <puts>:
   82220:	900000a2 	adrp	x2, 96000 <JIS_state_table+0x70>
   82224:	aa0003e1 	mov	x1, x0
   82228:	f9410040 	ldr	x0, [x2, #512]
   8222c:	17ffffc1 	b	82130 <_puts_r>

0000000000082230 <stdio_exit_handler>:
   82230:	900000a2 	adrp	x2, 96000 <JIS_state_table+0x70>
   82234:	d0000041 	adrp	x1, 8c000 <currentlocale+0x80>
   82238:	910d8042 	add	x2, x2, #0x360
   8223c:	9131c021 	add	x1, x1, #0xc70
   82240:	900000a0 	adrp	x0, 96000 <JIS_state_table+0x70>
   82244:	91082000 	add	x0, x0, #0x208
   82248:	140003b6 	b	83120 <_fwalk_sglue>
   8224c:	00000000 	udf	#0

0000000000082250 <cleanup_stdio>:
   82250:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   82254:	90001402 	adrp	x2, 302000 <irq_handlers+0x1370>
   82258:	9132c042 	add	x2, x2, #0xcb0
   8225c:	910003fd 	mov	x29, sp
   82260:	f9400401 	ldr	x1, [x0, #8]
   82264:	f9000bf3 	str	x19, [sp, #16]
   82268:	aa0003f3 	mov	x19, x0
   8226c:	eb02003f 	cmp	x1, x2
   82270:	54000040 	b.eq	82278 <cleanup_stdio+0x28>  // b.none
   82274:	94002a7f 	bl	8cc70 <_fclose_r>
   82278:	f9400a61 	ldr	x1, [x19, #16]
   8227c:	90001400 	adrp	x0, 302000 <irq_handlers+0x1370>
   82280:	9135a000 	add	x0, x0, #0xd68
   82284:	eb00003f 	cmp	x1, x0
   82288:	54000060 	b.eq	82294 <cleanup_stdio+0x44>  // b.none
   8228c:	aa1303e0 	mov	x0, x19
   82290:	94002a78 	bl	8cc70 <_fclose_r>
   82294:	f9400e61 	ldr	x1, [x19, #24]
   82298:	90001400 	adrp	x0, 302000 <irq_handlers+0x1370>
   8229c:	91388000 	add	x0, x0, #0xe20
   822a0:	eb00003f 	cmp	x1, x0
   822a4:	540000a0 	b.eq	822b8 <cleanup_stdio+0x68>  // b.none
   822a8:	aa1303e0 	mov	x0, x19
   822ac:	f9400bf3 	ldr	x19, [sp, #16]
   822b0:	a8c27bfd 	ldp	x29, x30, [sp], #32
   822b4:	14002a6f 	b	8cc70 <_fclose_r>
   822b8:	f9400bf3 	ldr	x19, [sp, #16]
   822bc:	a8c27bfd 	ldp	x29, x30, [sp], #32
   822c0:	d65f03c0 	ret
	...

00000000000822d0 <__fp_lock>:
   822d0:	b940b020 	ldr	w0, [x1, #176]
   822d4:	37000060 	tbnz	w0, #0, 822e0 <__fp_lock+0x10>
   822d8:	79402020 	ldrh	w0, [x1, #16]
   822dc:	36480060 	tbz	w0, #9, 822e8 <__fp_lock+0x18>
   822e0:	52800000 	mov	w0, #0x0                   	// #0
   822e4:	d65f03c0 	ret
   822e8:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   822ec:	910003fd 	mov	x29, sp
   822f0:	f9405020 	ldr	x0, [x1, #160]
   822f4:	9400270f 	bl	8bf30 <__retarget_lock_acquire_recursive>
   822f8:	52800000 	mov	w0, #0x0                   	// #0
   822fc:	a8c17bfd 	ldp	x29, x30, [sp], #16
   82300:	d65f03c0 	ret
	...

0000000000082310 <__fp_unlock>:
   82310:	b940b020 	ldr	w0, [x1, #176]
   82314:	37000060 	tbnz	w0, #0, 82320 <__fp_unlock+0x10>
   82318:	79402020 	ldrh	w0, [x1, #16]
   8231c:	36480060 	tbz	w0, #9, 82328 <__fp_unlock+0x18>
   82320:	52800000 	mov	w0, #0x0                   	// #0
   82324:	d65f03c0 	ret
   82328:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   8232c:	910003fd 	mov	x29, sp
   82330:	f9405020 	ldr	x0, [x1, #160]
   82334:	9400270f 	bl	8bf70 <__retarget_lock_release_recursive>
   82338:	52800000 	mov	w0, #0x0                   	// #0
   8233c:	a8c17bfd 	ldp	x29, x30, [sp], #16
   82340:	d65f03c0 	ret
	...

0000000000082350 <global_stdio_init.part.0>:
   82350:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
   82354:	90001400 	adrp	x0, 302000 <irq_handlers+0x1370>
   82358:	90000003 	adrp	x3, 82000 <__errno>
   8235c:	910003fd 	mov	x29, sp
   82360:	9108c063 	add	x3, x3, #0x230
   82364:	a90153f3 	stp	x19, x20, [sp, #16]
   82368:	9132c013 	add	x19, x0, #0xcb0
   8236c:	90001405 	adrp	x5, 302000 <irq_handlers+0x1370>
   82370:	52800084 	mov	w4, #0x4                   	// #4
   82374:	d2800102 	mov	x2, #0x8                   	// #8
   82378:	52800001 	mov	w1, #0x0                   	// #0
   8237c:	a9025bf5 	stp	x21, x22, [sp, #32]
   82380:	90000014 	adrp	x20, 82000 <__errno>
   82384:	90000016 	adrp	x22, 82000 <__errno>
   82388:	f9001bf7 	str	x23, [sp, #48]
   8238c:	912c82d6 	add	x22, x22, #0xb20
   82390:	f9076ca3 	str	x3, [x5, #3800]
   82394:	912f8294 	add	x20, x20, #0xbe0
   82398:	f906581f 	str	xzr, [x0, #3248]
   8239c:	90001400 	adrp	x0, 302000 <irq_handlers+0x1370>
   823a0:	91356000 	add	x0, x0, #0xd58
   823a4:	f900067f 	str	xzr, [x19, #8]
   823a8:	b9001264 	str	w4, [x19, #16]
   823ac:	90000015 	adrp	x21, 82000 <__errno>
   823b0:	f9000e7f 	str	xzr, [x19, #24]
   823b4:	912e42b5 	add	x21, x21, #0xb90
   823b8:	b900227f 	str	wzr, [x19, #32]
   823bc:	90000017 	adrp	x23, 82000 <__errno>
   823c0:	b9002a7f 	str	wzr, [x19, #40]
   823c4:	912b02f7 	add	x23, x23, #0xac0
   823c8:	b900b27f 	str	wzr, [x19, #176]
   823cc:	94002c7d 	bl	8d5c0 <memset>
   823d0:	90001400 	adrp	x0, 302000 <irq_handlers+0x1370>
   823d4:	91354000 	add	x0, x0, #0xd50
   823d8:	a9035e73 	stp	x19, x23, [x19, #48]
   823dc:	a9045676 	stp	x22, x21, [x19, #64]
   823e0:	f9002a74 	str	x20, [x19, #80]
   823e4:	940026c3 	bl	8bef0 <__retarget_lock_init_recursive>
   823e8:	52800123 	mov	w3, #0x9                   	// #9
   823ec:	d2800102 	mov	x2, #0x8                   	// #8
   823f0:	72a00023 	movk	w3, #0x1, lsl #16
   823f4:	52800001 	mov	w1, #0x0                   	// #0
   823f8:	90001400 	adrp	x0, 302000 <irq_handlers+0x1370>
   823fc:	91384000 	add	x0, x0, #0xe10
   82400:	f9005e7f 	str	xzr, [x19, #184]
   82404:	f900627f 	str	xzr, [x19, #192]
   82408:	b900ca63 	str	w3, [x19, #200]
   8240c:	f9006a7f 	str	xzr, [x19, #208]
   82410:	b900da7f 	str	wzr, [x19, #216]
   82414:	b900e27f 	str	wzr, [x19, #224]
   82418:	b9016a7f 	str	wzr, [x19, #360]
   8241c:	94002c69 	bl	8d5c0 <memset>
   82420:	90001401 	adrp	x1, 302000 <irq_handlers+0x1370>
   82424:	9135a021 	add	x1, x1, #0xd68
   82428:	90001400 	adrp	x0, 302000 <irq_handlers+0x1370>
   8242c:	91382000 	add	x0, x0, #0xe08
   82430:	a90ede61 	stp	x1, x23, [x19, #232]
   82434:	a90fd676 	stp	x22, x21, [x19, #248]
   82438:	f9008674 	str	x20, [x19, #264]
   8243c:	940026ad 	bl	8bef0 <__retarget_lock_init_recursive>
   82440:	52800243 	mov	w3, #0x12                  	// #18
   82444:	d2800102 	mov	x2, #0x8                   	// #8
   82448:	72a00043 	movk	w3, #0x2, lsl #16
   8244c:	52800001 	mov	w1, #0x0                   	// #0
   82450:	90001400 	adrp	x0, 302000 <irq_handlers+0x1370>
   82454:	913b2000 	add	x0, x0, #0xec8
   82458:	f900ba7f 	str	xzr, [x19, #368]
   8245c:	f900be7f 	str	xzr, [x19, #376]
   82460:	b9018263 	str	w3, [x19, #384]
   82464:	f900c67f 	str	xzr, [x19, #392]
   82468:	b901927f 	str	wzr, [x19, #400]
   8246c:	b9019a7f 	str	wzr, [x19, #408]
   82470:	b902227f 	str	wzr, [x19, #544]
   82474:	94002c53 	bl	8d5c0 <memset>
   82478:	90001401 	adrp	x1, 302000 <irq_handlers+0x1370>
   8247c:	91388021 	add	x1, x1, #0xe20
   82480:	a91a5e61 	stp	x1, x23, [x19, #416]
   82484:	90001400 	adrp	x0, 302000 <irq_handlers+0x1370>
   82488:	913b0000 	add	x0, x0, #0xec0
   8248c:	a91b5676 	stp	x22, x21, [x19, #432]
   82490:	f900e274 	str	x20, [x19, #448]
   82494:	a94153f3 	ldp	x19, x20, [sp, #16]
   82498:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8249c:	f9401bf7 	ldr	x23, [sp, #48]
   824a0:	a8c47bfd 	ldp	x29, x30, [sp], #64
   824a4:	14002693 	b	8bef0 <__retarget_lock_init_recursive>
	...

00000000000824b0 <__sfp>:
   824b0:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
   824b4:	910003fd 	mov	x29, sp
   824b8:	a9025bf5 	stp	x21, x22, [sp, #32]
   824bc:	90001415 	adrp	x21, 302000 <irq_handlers+0x1370>
   824c0:	913d62b5 	add	x21, x21, #0xf58
   824c4:	aa0003f6 	mov	x22, x0
   824c8:	aa1503e0 	mov	x0, x21
   824cc:	a90153f3 	stp	x19, x20, [sp, #16]
   824d0:	f9001bf7 	str	x23, [sp, #48]
   824d4:	94002697 	bl	8bf30 <__retarget_lock_acquire_recursive>
   824d8:	90001400 	adrp	x0, 302000 <irq_handlers+0x1370>
   824dc:	f9476c00 	ldr	x0, [x0, #3800]
   824e0:	b40007a0 	cbz	x0, 825d4 <__sfp+0x124>
   824e4:	900000b4 	adrp	x20, 96000 <JIS_state_table+0x70>
   824e8:	910d8294 	add	x20, x20, #0x360
   824ec:	52801717 	mov	w23, #0xb8                  	// #184
   824f0:	b9400a82 	ldr	w2, [x20, #8]
   824f4:	f9400a93 	ldr	x19, [x20, #16]
   824f8:	7100005f 	cmp	w2, #0x0
   824fc:	5400044d 	b.le	82584 <__sfp+0xd4>
   82500:	9bb74c42 	umaddl	x2, w2, w23, x19
   82504:	14000004 	b	82514 <__sfp+0x64>
   82508:	9102e273 	add	x19, x19, #0xb8
   8250c:	eb02027f 	cmp	x19, x2
   82510:	540003a0 	b.eq	82584 <__sfp+0xd4>  // b.none
   82514:	79c02261 	ldrsh	w1, [x19, #16]
   82518:	35ffff81 	cbnz	w1, 82508 <__sfp+0x58>
   8251c:	129fffc0 	mov	w0, #0xffff0001            	// #-65535
   82520:	b9001260 	str	w0, [x19, #16]
   82524:	b900b27f 	str	wzr, [x19, #176]
   82528:	91028260 	add	x0, x19, #0xa0
   8252c:	94002671 	bl	8bef0 <__retarget_lock_init_recursive>
   82530:	aa1503e0 	mov	x0, x21
   82534:	9400268f 	bl	8bf70 <__retarget_lock_release_recursive>
   82538:	f900027f 	str	xzr, [x19]
   8253c:	9102a260 	add	x0, x19, #0xa8
   82540:	f900067f 	str	xzr, [x19, #8]
   82544:	d2800102 	mov	x2, #0x8                   	// #8
   82548:	f9000e7f 	str	xzr, [x19, #24]
   8254c:	52800001 	mov	w1, #0x0                   	// #0
   82550:	b900227f 	str	wzr, [x19, #32]
   82554:	b9002a7f 	str	wzr, [x19, #40]
   82558:	94002c1a 	bl	8d5c0 <memset>
   8255c:	f9002e7f 	str	xzr, [x19, #88]
   82560:	b900627f 	str	wzr, [x19, #96]
   82564:	f9003e7f 	str	xzr, [x19, #120]
   82568:	b900827f 	str	wzr, [x19, #128]
   8256c:	a9425bf5 	ldp	x21, x22, [sp, #32]
   82570:	aa1303e0 	mov	x0, x19
   82574:	a94153f3 	ldp	x19, x20, [sp, #16]
   82578:	f9401bf7 	ldr	x23, [sp, #48]
   8257c:	a8c47bfd 	ldp	x29, x30, [sp], #64
   82580:	d65f03c0 	ret
   82584:	f9400293 	ldr	x19, [x20]
   82588:	b4000073 	cbz	x19, 82594 <__sfp+0xe4>
   8258c:	aa1303f4 	mov	x20, x19
   82590:	17ffffd8 	b	824f0 <__sfp+0x40>
   82594:	aa1603e0 	mov	x0, x22
   82598:	d2805f01 	mov	x1, #0x2f8                 	// #760
   8259c:	940023f9 	bl	8b580 <_malloc_r>
   825a0:	aa0003f3 	mov	x19, x0
   825a4:	b40001c0 	cbz	x0, 825dc <__sfp+0x12c>
   825a8:	91006000 	add	x0, x0, #0x18
   825ac:	52800081 	mov	w1, #0x4                   	// #4
   825b0:	f900027f 	str	xzr, [x19]
   825b4:	d2805c02 	mov	x2, #0x2e0                 	// #736
   825b8:	b9000a61 	str	w1, [x19, #8]
   825bc:	52800001 	mov	w1, #0x0                   	// #0
   825c0:	f9000a60 	str	x0, [x19, #16]
   825c4:	94002bff 	bl	8d5c0 <memset>
   825c8:	f9000293 	str	x19, [x20]
   825cc:	aa1303f4 	mov	x20, x19
   825d0:	17ffffc8 	b	824f0 <__sfp+0x40>
   825d4:	97ffff5f 	bl	82350 <global_stdio_init.part.0>
   825d8:	17ffffc3 	b	824e4 <__sfp+0x34>
   825dc:	f900029f 	str	xzr, [x20]
   825e0:	aa1503e0 	mov	x0, x21
   825e4:	94002663 	bl	8bf70 <__retarget_lock_release_recursive>
   825e8:	52800180 	mov	w0, #0xc                   	// #12
   825ec:	b90002c0 	str	w0, [x22]
   825f0:	17ffffdf 	b	8256c <__sfp+0xbc>
	...

0000000000082600 <__sinit>:
   82600:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   82604:	910003fd 	mov	x29, sp
   82608:	a90153f3 	stp	x19, x20, [sp, #16]
   8260c:	aa0003f4 	mov	x20, x0
   82610:	90001413 	adrp	x19, 302000 <irq_handlers+0x1370>
   82614:	913d6273 	add	x19, x19, #0xf58
   82618:	aa1303e0 	mov	x0, x19
   8261c:	94002645 	bl	8bf30 <__retarget_lock_acquire_recursive>
   82620:	f9402680 	ldr	x0, [x20, #72]
   82624:	b50000e0 	cbnz	x0, 82640 <__sinit+0x40>
   82628:	90001401 	adrp	x1, 302000 <irq_handlers+0x1370>
   8262c:	90000000 	adrp	x0, 82000 <__errno>
   82630:	91094000 	add	x0, x0, #0x250
   82634:	f9002680 	str	x0, [x20, #72]
   82638:	f9476c20 	ldr	x0, [x1, #3800]
   8263c:	b40000a0 	cbz	x0, 82650 <__sinit+0x50>
   82640:	aa1303e0 	mov	x0, x19
   82644:	a94153f3 	ldp	x19, x20, [sp, #16]
   82648:	a8c27bfd 	ldp	x29, x30, [sp], #32
   8264c:	14002649 	b	8bf70 <__retarget_lock_release_recursive>
   82650:	97ffff40 	bl	82350 <global_stdio_init.part.0>
   82654:	aa1303e0 	mov	x0, x19
   82658:	a94153f3 	ldp	x19, x20, [sp, #16]
   8265c:	a8c27bfd 	ldp	x29, x30, [sp], #32
   82660:	14002644 	b	8bf70 <__retarget_lock_release_recursive>
	...

0000000000082670 <__sfp_lock_acquire>:
   82670:	90001400 	adrp	x0, 302000 <irq_handlers+0x1370>
   82674:	913d6000 	add	x0, x0, #0xf58
   82678:	1400262e 	b	8bf30 <__retarget_lock_acquire_recursive>
   8267c:	00000000 	udf	#0

0000000000082680 <__sfp_lock_release>:
   82680:	90001400 	adrp	x0, 302000 <irq_handlers+0x1370>
   82684:	913d6000 	add	x0, x0, #0xf58
   82688:	1400263a 	b	8bf70 <__retarget_lock_release_recursive>
   8268c:	00000000 	udf	#0

0000000000082690 <__fp_lock_all>:
   82690:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   82694:	90001400 	adrp	x0, 302000 <irq_handlers+0x1370>
   82698:	913d6000 	add	x0, x0, #0xf58
   8269c:	910003fd 	mov	x29, sp
   826a0:	94002624 	bl	8bf30 <__retarget_lock_acquire_recursive>
   826a4:	a8c17bfd 	ldp	x29, x30, [sp], #16
   826a8:	900000a2 	adrp	x2, 96000 <JIS_state_table+0x70>
   826ac:	90000001 	adrp	x1, 82000 <__errno>
   826b0:	910d8042 	add	x2, x2, #0x360
   826b4:	910b4021 	add	x1, x1, #0x2d0
   826b8:	d2800000 	mov	x0, #0x0                   	// #0
   826bc:	14000299 	b	83120 <_fwalk_sglue>

00000000000826c0 <__fp_unlock_all>:
   826c0:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   826c4:	900000a2 	adrp	x2, 96000 <JIS_state_table+0x70>
   826c8:	90000001 	adrp	x1, 82000 <__errno>
   826cc:	910003fd 	mov	x29, sp
   826d0:	910d8042 	add	x2, x2, #0x360
   826d4:	910c4021 	add	x1, x1, #0x310
   826d8:	d2800000 	mov	x0, #0x0                   	// #0
   826dc:	94000291 	bl	83120 <_fwalk_sglue>
   826e0:	a8c17bfd 	ldp	x29, x30, [sp], #16
   826e4:	90001400 	adrp	x0, 302000 <irq_handlers+0x1370>
   826e8:	913d6000 	add	x0, x0, #0xf58
   826ec:	14002621 	b	8bf70 <__retarget_lock_release_recursive>

00000000000826f0 <_snprintf_r>:
   826f0:	a9a47bfd 	stp	x29, x30, [sp, #-448]!
   826f4:	aa0203e8 	mov	x8, x2
   826f8:	aa0303e2 	mov	x2, x3
   826fc:	910003fd 	mov	x29, sp
   82700:	f9000bf3 	str	x19, [sp, #16]
   82704:	b2407be3 	mov	x3, #0x7fffffff            	// #2147483647
   82708:	3d804be0 	str	q0, [sp, #288]
   8270c:	aa0003f3 	mov	x19, x0
   82710:	3d804fe1 	str	q1, [sp, #304]
   82714:	3d8053e2 	str	q2, [sp, #320]
   82718:	3d8057e3 	str	q3, [sp, #336]
   8271c:	3d805be4 	str	q4, [sp, #352]
   82720:	3d805fe5 	str	q5, [sp, #368]
   82724:	3d8063e6 	str	q6, [sp, #384]
   82728:	3d8067e7 	str	q7, [sp, #400]
   8272c:	a91a17e4 	stp	x4, x5, [sp, #416]
   82730:	a91b1fe6 	stp	x6, x7, [sp, #432]
   82734:	eb03011f 	cmp	x8, x3
   82738:	54000668 	b.hi	82804 <_snprintf_r+0x114>  // b.pmore
   8273c:	52804103 	mov	w3, #0x208                 	// #520
   82740:	910683e4 	add	x4, sp, #0x1a0
   82744:	910703e5 	add	x5, sp, #0x1c0
   82748:	a90497e5 	stp	x5, x5, [sp, #72]
   8274c:	f9002fe4 	str	x4, [sp, #88]
   82750:	f90037e1 	str	x1, [sp, #104]
   82754:	7900f3e3 	strh	w3, [sp, #120]
   82758:	128003e3 	mov	w3, #0xffffffe0            	// #-32
   8275c:	f90043e1 	str	x1, [sp, #128]
   82760:	12800fe1 	mov	w1, #0xffffff80            	// #-128
   82764:	b40002c8 	cbz	x8, 827bc <_snprintf_r+0xcc>
   82768:	910123e5 	add	x5, sp, #0x48
   8276c:	290c07e3 	stp	w3, w1, [sp, #96]
   82770:	51000508 	sub	w8, w8, #0x1
   82774:	12800004 	mov	w4, #0xffffffff            	// #-1
   82778:	910083e3 	add	x3, sp, #0x20
   8277c:	9101a3e1 	add	x1, sp, #0x68
   82780:	ad4004a0 	ldp	q0, q1, [x5]
   82784:	b90077e8 	str	w8, [sp, #116]
   82788:	7900f7e4 	strh	w4, [sp, #122]
   8278c:	b9008be8 	str	w8, [sp, #136]
   82790:	ad0107e0 	stp	q0, q1, [sp, #32]
   82794:	9400028b 	bl	831c0 <_svfprintf_r>
   82798:	3100041f 	cmn	w0, #0x1
   8279c:	5400006a 	b.ge	827a8 <_snprintf_r+0xb8>  // b.tcont
   827a0:	52801161 	mov	w1, #0x8b                  	// #139
   827a4:	b9000261 	str	w1, [x19]
   827a8:	f94037e1 	ldr	x1, [sp, #104]
   827ac:	3900003f 	strb	wzr, [x1]
   827b0:	f9400bf3 	ldr	x19, [sp, #16]
   827b4:	a8dc7bfd 	ldp	x29, x30, [sp], #448
   827b8:	d65f03c0 	ret
   827bc:	910123e5 	add	x5, sp, #0x48
   827c0:	290c07e3 	stp	w3, w1, [sp, #96]
   827c4:	12800004 	mov	w4, #0xffffffff            	// #-1
   827c8:	910083e3 	add	x3, sp, #0x20
   827cc:	9101a3e1 	add	x1, sp, #0x68
   827d0:	b90077ff 	str	wzr, [sp, #116]
   827d4:	ad4004a0 	ldp	q0, q1, [x5]
   827d8:	7900f7e4 	strh	w4, [sp, #122]
   827dc:	b9008bff 	str	wzr, [sp, #136]
   827e0:	ad0107e0 	stp	q0, q1, [sp, #32]
   827e4:	94000277 	bl	831c0 <_svfprintf_r>
   827e8:	3100041f 	cmn	w0, #0x1
   827ec:	5400006a 	b.ge	827f8 <_snprintf_r+0x108>  // b.tcont
   827f0:	52801161 	mov	w1, #0x8b                  	// #139
   827f4:	b9000261 	str	w1, [x19]
   827f8:	f9400bf3 	ldr	x19, [sp, #16]
   827fc:	a8dc7bfd 	ldp	x29, x30, [sp], #448
   82800:	d65f03c0 	ret
   82804:	52801161 	mov	w1, #0x8b                  	// #139
   82808:	12800000 	mov	w0, #0xffffffff            	// #-1
   8280c:	b9000261 	str	w1, [x19]
   82810:	17fffffa 	b	827f8 <_snprintf_r+0x108>
	...

0000000000082820 <snprintf>:
   82820:	a9a37bfd 	stp	x29, x30, [sp, #-464]!
   82824:	900000a9 	adrp	x9, 96000 <JIS_state_table+0x70>
   82828:	b2407be8 	mov	x8, #0x7fffffff            	// #2147483647
   8282c:	910003fd 	mov	x29, sp
   82830:	f9000bf3 	str	x19, [sp, #16]
   82834:	3d804be0 	str	q0, [sp, #288]
   82838:	3d804fe1 	str	q1, [sp, #304]
   8283c:	3d8053e2 	str	q2, [sp, #320]
   82840:	3d8057e3 	str	q3, [sp, #336]
   82844:	3d805be4 	str	q4, [sp, #352]
   82848:	3d805fe5 	str	q5, [sp, #368]
   8284c:	3d8063e6 	str	q6, [sp, #384]
   82850:	3d8067e7 	str	q7, [sp, #400]
   82854:	a91a93e3 	stp	x3, x4, [sp, #424]
   82858:	a91b9be5 	stp	x5, x6, [sp, #440]
   8285c:	f900e7e7 	str	x7, [sp, #456]
   82860:	f9410133 	ldr	x19, [x9, #512]
   82864:	eb08003f 	cmp	x1, x8
   82868:	54000768 	b.hi	82954 <snprintf+0x134>  // b.pmore
   8286c:	52804103 	mov	w3, #0x208                 	// #520
   82870:	f90037e0 	str	x0, [sp, #104]
   82874:	7900f3e3 	strh	w3, [sp, #120]
   82878:	f90043e0 	str	x0, [sp, #128]
   8287c:	b40003a1 	cbz	x1, 828f0 <snprintf+0xd0>
   82880:	910123e6 	add	x6, sp, #0x48
   82884:	910683e4 	add	x4, sp, #0x1a0
   82888:	910743e5 	add	x5, sp, #0x1d0
   8288c:	128004e3 	mov	w3, #0xffffffd8            	// #-40
   82890:	12800fe0 	mov	w0, #0xffffff80            	// #-128
   82894:	a90497e5 	stp	x5, x5, [sp, #72]
   82898:	12800005 	mov	w5, #0xffffffff            	// #-1
   8289c:	f9002fe4 	str	x4, [sp, #88]
   828a0:	51000424 	sub	w4, w1, #0x1
   828a4:	290c03e3 	stp	w3, w0, [sp, #96]
   828a8:	9101a3e1 	add	x1, sp, #0x68
   828ac:	910083e3 	add	x3, sp, #0x20
   828b0:	aa1303e0 	mov	x0, x19
   828b4:	ad4004c0 	ldp	q0, q1, [x6]
   828b8:	b90077e4 	str	w4, [sp, #116]
   828bc:	7900f7e5 	strh	w5, [sp, #122]
   828c0:	b9008be4 	str	w4, [sp, #136]
   828c4:	ad0107e0 	stp	q0, q1, [sp, #32]
   828c8:	9400023e 	bl	831c0 <_svfprintf_r>
   828cc:	3100041f 	cmn	w0, #0x1
   828d0:	5400006a 	b.ge	828dc <snprintf+0xbc>  // b.tcont
   828d4:	52801161 	mov	w1, #0x8b                  	// #139
   828d8:	b9000261 	str	w1, [x19]
   828dc:	f94037e1 	ldr	x1, [sp, #104]
   828e0:	3900003f 	strb	wzr, [x1]
   828e4:	f9400bf3 	ldr	x19, [sp, #16]
   828e8:	a8dd7bfd 	ldp	x29, x30, [sp], #464
   828ec:	d65f03c0 	ret
   828f0:	910123e5 	add	x5, sp, #0x48
   828f4:	910683e3 	add	x3, sp, #0x1a0
   828f8:	910743e4 	add	x4, sp, #0x1d0
   828fc:	128004e1 	mov	w1, #0xffffffd8            	// #-40
   82900:	12800fe0 	mov	w0, #0xffffff80            	// #-128
   82904:	a90493e4 	stp	x4, x4, [sp, #72]
   82908:	12800004 	mov	w4, #0xffffffff            	// #-1
   8290c:	f9002fe3 	str	x3, [sp, #88]
   82910:	910083e3 	add	x3, sp, #0x20
   82914:	290c03e1 	stp	w1, w0, [sp, #96]
   82918:	9101a3e1 	add	x1, sp, #0x68
   8291c:	aa1303e0 	mov	x0, x19
   82920:	b90077ff 	str	wzr, [sp, #116]
   82924:	ad4004a0 	ldp	q0, q1, [x5]
   82928:	7900f7e4 	strh	w4, [sp, #122]
   8292c:	b9008bff 	str	wzr, [sp, #136]
   82930:	ad0107e0 	stp	q0, q1, [sp, #32]
   82934:	94000223 	bl	831c0 <_svfprintf_r>
   82938:	3100041f 	cmn	w0, #0x1
   8293c:	5400006a 	b.ge	82948 <snprintf+0x128>  // b.tcont
   82940:	52801161 	mov	w1, #0x8b                  	// #139
   82944:	b9000261 	str	w1, [x19]
   82948:	f9400bf3 	ldr	x19, [sp, #16]
   8294c:	a8dd7bfd 	ldp	x29, x30, [sp], #464
   82950:	d65f03c0 	ret
   82954:	52801161 	mov	w1, #0x8b                  	// #139
   82958:	12800000 	mov	w0, #0xffffffff            	// #-1
   8295c:	b9000261 	str	w1, [x19]
   82960:	17fffffa 	b	82948 <snprintf+0x128>
	...

0000000000082980 <strlen>:
   82980:	92402c04 	and	x4, x0, #0xfff
   82984:	b200c3e8 	mov	x8, #0x101010101010101     	// #72340172838076673
   82988:	f13fc09f 	cmp	x4, #0xff0
   8298c:	5400082c 	b.gt	82a90 <strlen+0x110>
   82990:	a9400c02 	ldp	x2, x3, [x0]
   82994:	cb080044 	sub	x4, x2, x8
   82998:	b200d845 	orr	x5, x2, #0x7f7f7f7f7f7f7f7f
   8299c:	cb080066 	sub	x6, x3, x8
   829a0:	b200d867 	orr	x7, x3, #0x7f7f7f7f7f7f7f7f
   829a4:	ea250084 	bics	x4, x4, x5
   829a8:	8a2700c5 	bic	x5, x6, x7
   829ac:	fa4008a0 	ccmp	x5, #0x0, #0x0, eq	// eq = none
   829b0:	54000100 	b.eq	829d0 <strlen+0x50>  // b.none
   829b4:	9a853084 	csel	x4, x4, x5, cc	// cc = lo, ul, last
   829b8:	d2800100 	mov	x0, #0x8                   	// #8
   829bc:	dac00c84 	rev	x4, x4
   829c0:	dac01084 	clz	x4, x4
   829c4:	9a8033e0 	csel	x0, xzr, x0, cc	// cc = lo, ul, last
   829c8:	8b440c00 	add	x0, x0, x4, lsr #3
   829cc:	d65f03c0 	ret
   829d0:	927cec01 	and	x1, x0, #0xfffffffffffffff0
   829d4:	d1004021 	sub	x1, x1, #0x10
   829d8:	a9c20c22 	ldp	x2, x3, [x1, #32]!
   829dc:	cb080044 	sub	x4, x2, x8
   829e0:	cb080066 	sub	x6, x3, x8
   829e4:	aa060085 	orr	x5, x4, x6
   829e8:	ea081cbf 	tst	x5, x8, lsl #7
   829ec:	54000101 	b.ne	82a0c <strlen+0x8c>  // b.any
   829f0:	a9410c22 	ldp	x2, x3, [x1, #16]
   829f4:	cb080044 	sub	x4, x2, x8
   829f8:	cb080066 	sub	x6, x3, x8
   829fc:	aa060085 	orr	x5, x4, x6
   82a00:	ea081cbf 	tst	x5, x8, lsl #7
   82a04:	54fffea0 	b.eq	829d8 <strlen+0x58>  // b.none
   82a08:	91004021 	add	x1, x1, #0x10
   82a0c:	b200d845 	orr	x5, x2, #0x7f7f7f7f7f7f7f7f
   82a10:	b200d867 	orr	x7, x3, #0x7f7f7f7f7f7f7f7f
   82a14:	ea250084 	bics	x4, x4, x5
   82a18:	8a2700c5 	bic	x5, x6, x7
   82a1c:	fa4008a0 	ccmp	x5, #0x0, #0x0, eq	// eq = none
   82a20:	54000120 	b.eq	82a44 <strlen+0xc4>  // b.none
   82a24:	9a853084 	csel	x4, x4, x5, cc	// cc = lo, ul, last
   82a28:	cb000020 	sub	x0, x1, x0
   82a2c:	dac00c84 	rev	x4, x4
   82a30:	91002005 	add	x5, x0, #0x8
   82a34:	dac01084 	clz	x4, x4
   82a38:	9a853000 	csel	x0, x0, x5, cc	// cc = lo, ul, last
   82a3c:	8b440c00 	add	x0, x0, x4, lsr #3
   82a40:	d65f03c0 	ret
   82a44:	a9c10c22 	ldp	x2, x3, [x1, #16]!
   82a48:	cb080044 	sub	x4, x2, x8
   82a4c:	b200d845 	orr	x5, x2, #0x7f7f7f7f7f7f7f7f
   82a50:	cb080066 	sub	x6, x3, x8
   82a54:	b200d867 	orr	x7, x3, #0x7f7f7f7f7f7f7f7f
   82a58:	ea250084 	bics	x4, x4, x5
   82a5c:	8a2700c5 	bic	x5, x6, x7
   82a60:	fa4008a0 	ccmp	x5, #0x0, #0x0, eq	// eq = none
   82a64:	54fffe01 	b.ne	82a24 <strlen+0xa4>  // b.any
   82a68:	a9c10c22 	ldp	x2, x3, [x1, #16]!
   82a6c:	cb080044 	sub	x4, x2, x8
   82a70:	b200d845 	orr	x5, x2, #0x7f7f7f7f7f7f7f7f
   82a74:	cb080066 	sub	x6, x3, x8
   82a78:	b200d867 	orr	x7, x3, #0x7f7f7f7f7f7f7f7f
   82a7c:	ea250084 	bics	x4, x4, x5
   82a80:	8a2700c5 	bic	x5, x6, x7
   82a84:	fa4008a0 	ccmp	x5, #0x0, #0x0, eq	// eq = none
   82a88:	54fffde0 	b.eq	82a44 <strlen+0xc4>  // b.none
   82a8c:	17ffffe6 	b	82a24 <strlen+0xa4>
   82a90:	927cec01 	and	x1, x0, #0xfffffffffffffff0
   82a94:	a9400c22 	ldp	x2, x3, [x1]
   82a98:	d37df004 	lsl	x4, x0, #3
   82a9c:	92800007 	mov	x7, #0xffffffffffffffff    	// #-1
   82aa0:	9ac420e4 	lsl	x4, x7, x4
   82aa4:	b201c084 	orr	x4, x4, #0x8080808080808080
   82aa8:	aa240042 	orn	x2, x2, x4
   82aac:	aa240065 	orn	x5, x3, x4
   82ab0:	f27d001f 	tst	x0, #0x8
   82ab4:	9a870042 	csel	x2, x2, x7, eq	// eq = none
   82ab8:	9a850063 	csel	x3, x3, x5, eq	// eq = none
   82abc:	17ffffc8 	b	829dc <strlen+0x5c>

0000000000082ac0 <__sread>:
   82ac0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   82ac4:	93407c63 	sxtw	x3, w3
   82ac8:	910003fd 	mov	x29, sp
   82acc:	f9000bf3 	str	x19, [sp, #16]
   82ad0:	aa0103f3 	mov	x19, x1
   82ad4:	79c02421 	ldrsh	w1, [x1, #18]
   82ad8:	94003552 	bl	90020 <_read_r>
   82adc:	b7f800e0 	tbnz	x0, #63, 82af8 <__sread+0x38>
   82ae0:	f9404a61 	ldr	x1, [x19, #144]
   82ae4:	8b000021 	add	x1, x1, x0
   82ae8:	f9004a61 	str	x1, [x19, #144]
   82aec:	f9400bf3 	ldr	x19, [sp, #16]
   82af0:	a8c27bfd 	ldp	x29, x30, [sp], #32
   82af4:	d65f03c0 	ret
   82af8:	79402261 	ldrh	w1, [x19, #16]
   82afc:	12137821 	and	w1, w1, #0xffffefff
   82b00:	79002261 	strh	w1, [x19, #16]
   82b04:	f9400bf3 	ldr	x19, [sp, #16]
   82b08:	a8c27bfd 	ldp	x29, x30, [sp], #32
   82b0c:	d65f03c0 	ret

0000000000082b10 <__seofread>:
   82b10:	52800000 	mov	w0, #0x0                   	// #0
   82b14:	d65f03c0 	ret
	...

0000000000082b20 <__swrite>:
   82b20:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   82b24:	910003fd 	mov	x29, sp
   82b28:	79c02024 	ldrsh	w4, [x1, #16]
   82b2c:	a90153f3 	stp	x19, x20, [sp, #16]
   82b30:	aa0103f3 	mov	x19, x1
   82b34:	aa0003f4 	mov	x20, x0
   82b38:	a9025bf5 	stp	x21, x22, [sp, #32]
   82b3c:	aa0203f5 	mov	x21, x2
   82b40:	2a0303f6 	mov	w22, w3
   82b44:	37400184 	tbnz	w4, #8, 82b74 <__swrite+0x54>
   82b48:	79c02661 	ldrsh	w1, [x19, #18]
   82b4c:	12137884 	and	w4, w4, #0xffffefff
   82b50:	79002264 	strh	w4, [x19, #16]
   82b54:	93407ec3 	sxtw	x3, w22
   82b58:	aa1503e2 	mov	x2, x21
   82b5c:	aa1403e0 	mov	x0, x20
   82b60:	94000158 	bl	830c0 <_write_r>
   82b64:	a94153f3 	ldp	x19, x20, [sp, #16]
   82b68:	a9425bf5 	ldp	x21, x22, [sp, #32]
   82b6c:	a8c37bfd 	ldp	x29, x30, [sp], #48
   82b70:	d65f03c0 	ret
   82b74:	79c02421 	ldrsh	w1, [x1, #18]
   82b78:	52800043 	mov	w3, #0x2                   	// #2
   82b7c:	d2800002 	mov	x2, #0x0                   	// #0
   82b80:	94003510 	bl	8ffc0 <_lseek_r>
   82b84:	79c02264 	ldrsh	w4, [x19, #16]
   82b88:	17fffff0 	b	82b48 <__swrite+0x28>
   82b8c:	00000000 	udf	#0

0000000000082b90 <__sseek>:
   82b90:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   82b94:	910003fd 	mov	x29, sp
   82b98:	f9000bf3 	str	x19, [sp, #16]
   82b9c:	aa0103f3 	mov	x19, x1
   82ba0:	79c02421 	ldrsh	w1, [x1, #18]
   82ba4:	94003507 	bl	8ffc0 <_lseek_r>
   82ba8:	79c02261 	ldrsh	w1, [x19, #16]
   82bac:	b100041f 	cmn	x0, #0x1
   82bb0:	540000e0 	b.eq	82bcc <__sseek+0x3c>  // b.none
   82bb4:	32140021 	orr	w1, w1, #0x1000
   82bb8:	79002261 	strh	w1, [x19, #16]
   82bbc:	f9004a60 	str	x0, [x19, #144]
   82bc0:	f9400bf3 	ldr	x19, [sp, #16]
   82bc4:	a8c27bfd 	ldp	x29, x30, [sp], #32
   82bc8:	d65f03c0 	ret
   82bcc:	12137821 	and	w1, w1, #0xffffefff
   82bd0:	79002261 	strh	w1, [x19, #16]
   82bd4:	f9400bf3 	ldr	x19, [sp, #16]
   82bd8:	a8c27bfd 	ldp	x29, x30, [sp], #32
   82bdc:	d65f03c0 	ret

0000000000082be0 <__sclose>:
   82be0:	79c02421 	ldrsh	w1, [x1, #18]
   82be4:	14002fd7 	b	8eb40 <_close_r>
	...

0000000000082bf0 <__sfvwrite_r>:
   82bf0:	a9ba7bfd 	stp	x29, x30, [sp, #-96]!
   82bf4:	910003fd 	mov	x29, sp
   82bf8:	a9025bf5 	stp	x21, x22, [sp, #32]
   82bfc:	aa0003f5 	mov	x21, x0
   82c00:	f9400840 	ldr	x0, [x2, #16]
   82c04:	b4000ac0 	cbz	x0, 82d5c <__sfvwrite_r+0x16c>
   82c08:	79c02025 	ldrsh	w5, [x1, #16]
   82c0c:	a90153f3 	stp	x19, x20, [sp, #16]
   82c10:	aa0103f3 	mov	x19, x1
   82c14:	a90573fb 	stp	x27, x28, [sp, #80]
   82c18:	aa0203fb 	mov	x27, x2
   82c1c:	36180a85 	tbz	w5, #3, 82d6c <__sfvwrite_r+0x17c>
   82c20:	f9400c20 	ldr	x0, [x1, #24]
   82c24:	b4000a40 	cbz	x0, 82d6c <__sfvwrite_r+0x17c>
   82c28:	a90363f7 	stp	x23, x24, [sp, #48]
   82c2c:	f9400374 	ldr	x20, [x27]
   82c30:	360803e5 	tbz	w5, #1, 82cac <__sfvwrite_r+0xbc>
   82c34:	f9401a61 	ldr	x1, [x19, #48]
   82c38:	d2800017 	mov	x23, #0x0                   	// #0
   82c3c:	f9402264 	ldr	x4, [x19, #64]
   82c40:	d2800016 	mov	x22, #0x0                   	// #0
   82c44:	b27653f8 	mov	x24, #0x7ffffc00            	// #2147482624
   82c48:	eb1802df 	cmp	x22, x24
   82c4c:	aa1703e2 	mov	x2, x23
   82c50:	9a9892c3 	csel	x3, x22, x24, ls	// ls = plast
   82c54:	aa1503e0 	mov	x0, x21
   82c58:	b4000256 	cbz	x22, 82ca0 <__sfvwrite_r+0xb0>
   82c5c:	d63f0080 	blr	x4
   82c60:	7100001f 	cmp	w0, #0x0
   82c64:	5400216d 	b.le	83090 <__sfvwrite_r+0x4a0>
   82c68:	f9400b61 	ldr	x1, [x27, #16]
   82c6c:	93407c00 	sxtw	x0, w0
   82c70:	8b0002f7 	add	x23, x23, x0
   82c74:	cb0002d6 	sub	x22, x22, x0
   82c78:	cb000020 	sub	x0, x1, x0
   82c7c:	f9000b60 	str	x0, [x27, #16]
   82c80:	b40020c0 	cbz	x0, 83098 <__sfvwrite_r+0x4a8>
   82c84:	eb1802df 	cmp	x22, x24
   82c88:	aa1703e2 	mov	x2, x23
   82c8c:	f9401a61 	ldr	x1, [x19, #48]
   82c90:	9a9892c3 	csel	x3, x22, x24, ls	// ls = plast
   82c94:	f9402264 	ldr	x4, [x19, #64]
   82c98:	aa1503e0 	mov	x0, x21
   82c9c:	b5fffe16 	cbnz	x22, 82c5c <__sfvwrite_r+0x6c>
   82ca0:	a9405a97 	ldp	x23, x22, [x20]
   82ca4:	91004294 	add	x20, x20, #0x10
   82ca8:	17ffffe8 	b	82c48 <__sfvwrite_r+0x58>
   82cac:	a9046bf9 	stp	x25, x26, [sp, #64]
   82cb0:	36000a65 	tbz	w5, #0, 82dfc <__sfvwrite_r+0x20c>
   82cb4:	52800018 	mov	w24, #0x0                   	// #0
   82cb8:	52800000 	mov	w0, #0x0                   	// #0
   82cbc:	d280001a 	mov	x26, #0x0                   	// #0
   82cc0:	d2800019 	mov	x25, #0x0                   	// #0
   82cc4:	d503201f 	nop
   82cc8:	b40007f9 	cbz	x25, 82dc4 <__sfvwrite_r+0x1d4>
   82ccc:	34000860 	cbz	w0, 82dd8 <__sfvwrite_r+0x1e8>
   82cd0:	f9400260 	ldr	x0, [x19]
   82cd4:	93407f17 	sxtw	x23, w24
   82cd8:	f9400e61 	ldr	x1, [x19, #24]
   82cdc:	eb1902ff 	cmp	x23, x25
   82ce0:	b9400e76 	ldr	w22, [x19, #12]
   82ce4:	9a9992f7 	csel	x23, x23, x25, ls	// ls = plast
   82ce8:	b9402263 	ldr	w3, [x19, #32]
   82cec:	eb01001f 	cmp	x0, x1
   82cf0:	0b160076 	add	w22, w3, w22
   82cf4:	7a5682e4 	ccmp	w23, w22, #0x4, hi	// hi = pmore
   82cf8:	540019ac 	b.gt	8302c <__sfvwrite_r+0x43c>
   82cfc:	6b17007f 	cmp	w3, w23
   82d00:	540017ec 	b.gt	82ffc <__sfvwrite_r+0x40c>
   82d04:	f9401a61 	ldr	x1, [x19, #48]
   82d08:	aa1a03e2 	mov	x2, x26
   82d0c:	f9402264 	ldr	x4, [x19, #64]
   82d10:	aa1503e0 	mov	x0, x21
   82d14:	d63f0080 	blr	x4
   82d18:	2a0003f6 	mov	w22, w0
   82d1c:	7100001f 	cmp	w0, #0x0
   82d20:	540003cd 	b.le	82d98 <__sfvwrite_r+0x1a8>
   82d24:	6b160318 	subs	w24, w24, w22
   82d28:	52800020 	mov	w0, #0x1                   	// #1
   82d2c:	540002e0 	b.eq	82d88 <__sfvwrite_r+0x198>  // b.none
   82d30:	f9400b61 	ldr	x1, [x27, #16]
   82d34:	93407ed6 	sxtw	x22, w22
   82d38:	8b16035a 	add	x26, x26, x22
   82d3c:	cb160339 	sub	x25, x25, x22
   82d40:	cb160021 	sub	x1, x1, x22
   82d44:	f9000b61 	str	x1, [x27, #16]
   82d48:	b5fffc01 	cbnz	x1, 82cc8 <__sfvwrite_r+0xd8>
   82d4c:	a94153f3 	ldp	x19, x20, [sp, #16]
   82d50:	a94363f7 	ldp	x23, x24, [sp, #48]
   82d54:	a9446bf9 	ldp	x25, x26, [sp, #64]
   82d58:	a94573fb 	ldp	x27, x28, [sp, #80]
   82d5c:	52800000 	mov	w0, #0x0                   	// #0
   82d60:	a9425bf5 	ldp	x21, x22, [sp, #32]
   82d64:	a8c67bfd 	ldp	x29, x30, [sp], #96
   82d68:	d65f03c0 	ret
   82d6c:	aa1303e1 	mov	x1, x19
   82d70:	aa1503e0 	mov	x0, x21
   82d74:	9400284b 	bl	8cea0 <__swsetup_r>
   82d78:	350001a0 	cbnz	w0, 82dac <__sfvwrite_r+0x1bc>
   82d7c:	79c02265 	ldrsh	w5, [x19, #16]
   82d80:	a90363f7 	stp	x23, x24, [sp, #48]
   82d84:	17ffffaa 	b	82c2c <__sfvwrite_r+0x3c>
   82d88:	aa1303e1 	mov	x1, x19
   82d8c:	aa1503e0 	mov	x0, x21
   82d90:	94003030 	bl	8ee50 <_fflush_r>
   82d94:	34fffce0 	cbz	w0, 82d30 <__sfvwrite_r+0x140>
   82d98:	a9446bf9 	ldp	x25, x26, [sp, #64]
   82d9c:	79c02260 	ldrsh	w0, [x19, #16]
   82da0:	a94363f7 	ldp	x23, x24, [sp, #48]
   82da4:	321a0000 	orr	w0, w0, #0x40
   82da8:	79002260 	strh	w0, [x19, #16]
   82dac:	a94153f3 	ldp	x19, x20, [sp, #16]
   82db0:	12800000 	mov	w0, #0xffffffff            	// #-1
   82db4:	a9425bf5 	ldp	x21, x22, [sp, #32]
   82db8:	a94573fb 	ldp	x27, x28, [sp, #80]
   82dbc:	a8c67bfd 	ldp	x29, x30, [sp], #96
   82dc0:	d65f03c0 	ret
   82dc4:	f9400699 	ldr	x25, [x20, #8]
   82dc8:	aa1403e0 	mov	x0, x20
   82dcc:	91004294 	add	x20, x20, #0x10
   82dd0:	b4ffffb9 	cbz	x25, 82dc4 <__sfvwrite_r+0x1d4>
   82dd4:	f940001a 	ldr	x26, [x0]
   82dd8:	aa1903e2 	mov	x2, x25
   82ddc:	aa1a03e0 	mov	x0, x26
   82de0:	52800141 	mov	w1, #0xa                   	// #10
   82de4:	940027f7 	bl	8cdc0 <memchr>
   82de8:	91000418 	add	x24, x0, #0x1
   82dec:	f100001f 	cmp	x0, #0x0
   82df0:	cb1a0318 	sub	x24, x24, x26
   82df4:	1a991718 	csinc	w24, w24, w25, ne	// ne = any
   82df8:	17ffffb6 	b	82cd0 <__sfvwrite_r+0xe0>
   82dfc:	f9400264 	ldr	x4, [x19]
   82e00:	d280001c 	mov	x28, #0x0                   	// #0
   82e04:	b9400e61 	ldr	w1, [x19, #12]
   82e08:	d280001a 	mov	x26, #0x0                   	// #0
   82e0c:	d503201f 	nop
   82e10:	aa0403e0 	mov	x0, x4
   82e14:	2a0103f8 	mov	w24, w1
   82e18:	b40003fa 	cbz	x26, 82e94 <__sfvwrite_r+0x2a4>
   82e1c:	36480425 	tbz	w5, #9, 82ea0 <__sfvwrite_r+0x2b0>
   82e20:	93407c37 	sxtw	x23, w1
   82e24:	eb1a02ff 	cmp	x23, x26
   82e28:	540008c9 	b.ls	82f40 <__sfvwrite_r+0x350>  // b.plast
   82e2c:	93407f41 	sxtw	x1, w26
   82e30:	aa0103f9 	mov	x25, x1
   82e34:	aa0403e0 	mov	x0, x4
   82e38:	aa0103f7 	mov	x23, x1
   82e3c:	2a1a03f8 	mov	w24, w26
   82e40:	aa1c03e1 	mov	x1, x28
   82e44:	aa1703e2 	mov	x2, x23
   82e48:	9400293e 	bl	8d340 <memmove>
   82e4c:	f9400264 	ldr	x4, [x19]
   82e50:	b9400e61 	ldr	w1, [x19, #12]
   82e54:	8b170084 	add	x4, x4, x23
   82e58:	f9000264 	str	x4, [x19]
   82e5c:	4b180021 	sub	w1, w1, w24
   82e60:	b9000e61 	str	w1, [x19, #12]
   82e64:	f9400b60 	ldr	x0, [x27, #16]
   82e68:	8b19039c 	add	x28, x28, x25
   82e6c:	cb19035a 	sub	x26, x26, x25
   82e70:	cb190000 	sub	x0, x0, x25
   82e74:	f9000b60 	str	x0, [x27, #16]
   82e78:	b4fff6a0 	cbz	x0, 82d4c <__sfvwrite_r+0x15c>
   82e7c:	f9400264 	ldr	x4, [x19]
   82e80:	b9400e61 	ldr	w1, [x19, #12]
   82e84:	79c02265 	ldrsh	w5, [x19, #16]
   82e88:	aa0403e0 	mov	x0, x4
   82e8c:	2a0103f8 	mov	w24, w1
   82e90:	b5fffc7a 	cbnz	x26, 82e1c <__sfvwrite_r+0x22c>
   82e94:	a9406a9c 	ldp	x28, x26, [x20]
   82e98:	91004294 	add	x20, x20, #0x10
   82e9c:	17ffffdd 	b	82e10 <__sfvwrite_r+0x220>
   82ea0:	f9400e60 	ldr	x0, [x19, #24]
   82ea4:	eb04001f 	cmp	x0, x4
   82ea8:	54000243 	b.cc	82ef0 <__sfvwrite_r+0x300>  // b.lo, b.ul, b.last
   82eac:	b9402265 	ldr	w5, [x19, #32]
   82eb0:	eb25c35f 	cmp	x26, w5, sxtw
   82eb4:	540001e3 	b.cc	82ef0 <__sfvwrite_r+0x300>  // b.lo, b.ul, b.last
   82eb8:	b2407be0 	mov	x0, #0x7fffffff            	// #2147483647
   82ebc:	eb00035f 	cmp	x26, x0
   82ec0:	9a809343 	csel	x3, x26, x0, ls	// ls = plast
   82ec4:	aa1c03e2 	mov	x2, x28
   82ec8:	f9401a61 	ldr	x1, [x19, #48]
   82ecc:	aa1503e0 	mov	x0, x21
   82ed0:	1ac50c63 	sdiv	w3, w3, w5
   82ed4:	f9402264 	ldr	x4, [x19, #64]
   82ed8:	1b057c63 	mul	w3, w3, w5
   82edc:	d63f0080 	blr	x4
   82ee0:	7100001f 	cmp	w0, #0x0
   82ee4:	54fff5ad 	b.le	82d98 <__sfvwrite_r+0x1a8>
   82ee8:	93407c19 	sxtw	x25, w0
   82eec:	17ffffde 	b	82e64 <__sfvwrite_r+0x274>
   82ef0:	93407c23 	sxtw	x3, w1
   82ef4:	aa0403e0 	mov	x0, x4
   82ef8:	eb1a007f 	cmp	x3, x26
   82efc:	aa1c03e1 	mov	x1, x28
   82f00:	9a9a9078 	csel	x24, x3, x26, ls	// ls = plast
   82f04:	93407f19 	sxtw	x25, w24
   82f08:	aa1903e2 	mov	x2, x25
   82f0c:	9400290d 	bl	8d340 <memmove>
   82f10:	f9400264 	ldr	x4, [x19]
   82f14:	b9400e61 	ldr	w1, [x19, #12]
   82f18:	8b190084 	add	x4, x4, x25
   82f1c:	f9000264 	str	x4, [x19]
   82f20:	4b180021 	sub	w1, w1, w24
   82f24:	b9000e61 	str	w1, [x19, #12]
   82f28:	35fff9e1 	cbnz	w1, 82e64 <__sfvwrite_r+0x274>
   82f2c:	aa1303e1 	mov	x1, x19
   82f30:	aa1503e0 	mov	x0, x21
   82f34:	94002fc7 	bl	8ee50 <_fflush_r>
   82f38:	34fff960 	cbz	w0, 82e64 <__sfvwrite_r+0x274>
   82f3c:	17ffff97 	b	82d98 <__sfvwrite_r+0x1a8>
   82f40:	93407f59 	sxtw	x25, w26
   82f44:	52809001 	mov	w1, #0x480                 	// #1152
   82f48:	6a0100bf 	tst	w5, w1
   82f4c:	54fff7a0 	b.eq	82e40 <__sfvwrite_r+0x250>  // b.none
   82f50:	b9402266 	ldr	w6, [x19, #32]
   82f54:	f9400e61 	ldr	x1, [x19, #24]
   82f58:	0b0604c6 	add	w6, w6, w6, lsl #1
   82f5c:	cb010099 	sub	x25, x4, x1
   82f60:	0b467cc6 	add	w6, w6, w6, lsr #31
   82f64:	93407f36 	sxtw	x22, w25
   82f68:	13017cd7 	asr	w23, w6, #1
   82f6c:	910006c0 	add	x0, x22, #0x1
   82f70:	8b1a0000 	add	x0, x0, x26
   82f74:	93407ee2 	sxtw	x2, w23
   82f78:	eb00005f 	cmp	x2, x0
   82f7c:	54000082 	b.cs	82f8c <__sfvwrite_r+0x39c>  // b.hs, b.nlast
   82f80:	11000726 	add	w6, w25, #0x1
   82f84:	0b1a00d7 	add	w23, w6, w26
   82f88:	93407ee2 	sxtw	x2, w23
   82f8c:	36500685 	tbz	w5, #10, 8305c <__sfvwrite_r+0x46c>
   82f90:	aa0203e1 	mov	x1, x2
   82f94:	aa1503e0 	mov	x0, x21
   82f98:	9400217a 	bl	8b580 <_malloc_r>
   82f9c:	aa0003f8 	mov	x24, x0
   82fa0:	b4000840 	cbz	x0, 830a8 <__sfvwrite_r+0x4b8>
   82fa4:	f9400e61 	ldr	x1, [x19, #24]
   82fa8:	aa1603e2 	mov	x2, x22
   82fac:	94002885 	bl	8d1c0 <memcpy>
   82fb0:	79402260 	ldrh	w0, [x19, #16]
   82fb4:	12809001 	mov	w1, #0xfffffb7f            	// #-1153
   82fb8:	0a010000 	and	w0, w0, w1
   82fbc:	32190000 	orr	w0, w0, #0x80
   82fc0:	79002260 	strh	w0, [x19, #16]
   82fc4:	8b160300 	add	x0, x24, x22
   82fc8:	4b1902e4 	sub	w4, w23, w25
   82fcc:	93407f59 	sxtw	x25, w26
   82fd0:	f9000260 	str	x0, [x19]
   82fd4:	b9000e64 	str	w4, [x19, #12]
   82fd8:	aa1903e1 	mov	x1, x25
   82fdc:	f9000e78 	str	x24, [x19, #24]
   82fe0:	aa0003e4 	mov	x4, x0
   82fe4:	b9002277 	str	w23, [x19, #32]
   82fe8:	2a1a03f8 	mov	w24, w26
   82fec:	eb1a033f 	cmp	x25, x26
   82ff0:	54fff208 	b.hi	82e30 <__sfvwrite_r+0x240>  // b.pmore
   82ff4:	aa1903f7 	mov	x23, x25
   82ff8:	17ffff92 	b	82e40 <__sfvwrite_r+0x250>
   82ffc:	93407efc 	sxtw	x28, w23
   83000:	aa1a03e1 	mov	x1, x26
   83004:	aa1c03e2 	mov	x2, x28
   83008:	940028ce 	bl	8d340 <memmove>
   8300c:	f9400260 	ldr	x0, [x19]
   83010:	2a1703f6 	mov	w22, w23
   83014:	b9400e61 	ldr	w1, [x19, #12]
   83018:	8b1c0000 	add	x0, x0, x28
   8301c:	f9000260 	str	x0, [x19]
   83020:	4b170021 	sub	w1, w1, w23
   83024:	b9000e61 	str	w1, [x19, #12]
   83028:	17ffff3f 	b	82d24 <__sfvwrite_r+0x134>
   8302c:	93407ed7 	sxtw	x23, w22
   83030:	aa1a03e1 	mov	x1, x26
   83034:	aa1703e2 	mov	x2, x23
   83038:	940028c2 	bl	8d340 <memmove>
   8303c:	f9400262 	ldr	x2, [x19]
   83040:	aa1303e1 	mov	x1, x19
   83044:	aa1503e0 	mov	x0, x21
   83048:	8b170042 	add	x2, x2, x23
   8304c:	f9000262 	str	x2, [x19]
   83050:	94002f80 	bl	8ee50 <_fflush_r>
   83054:	34ffe680 	cbz	w0, 82d24 <__sfvwrite_r+0x134>
   83058:	17ffff50 	b	82d98 <__sfvwrite_r+0x1a8>
   8305c:	aa1503e0 	mov	x0, x21
   83060:	94003034 	bl	8f130 <_realloc_r>
   83064:	aa0003f8 	mov	x24, x0
   83068:	b5fffae0 	cbnz	x0, 82fc4 <__sfvwrite_r+0x3d4>
   8306c:	f9400e61 	ldr	x1, [x19, #24]
   83070:	aa1503e0 	mov	x0, x21
   83074:	940031d3 	bl	8f7c0 <_free_r>
   83078:	79c02260 	ldrsh	w0, [x19, #16]
   8307c:	52800181 	mov	w1, #0xc                   	// #12
   83080:	a9446bf9 	ldp	x25, x26, [sp, #64]
   83084:	12187800 	and	w0, w0, #0xffffff7f
   83088:	b90002a1 	str	w1, [x21]
   8308c:	17ffff45 	b	82da0 <__sfvwrite_r+0x1b0>
   83090:	79c02260 	ldrsh	w0, [x19, #16]
   83094:	17ffff43 	b	82da0 <__sfvwrite_r+0x1b0>
   83098:	a94153f3 	ldp	x19, x20, [sp, #16]
   8309c:	a94363f7 	ldp	x23, x24, [sp, #48]
   830a0:	a94573fb 	ldp	x27, x28, [sp, #80]
   830a4:	17ffff2e 	b	82d5c <__sfvwrite_r+0x16c>
   830a8:	a9446bf9 	ldp	x25, x26, [sp, #64]
   830ac:	52800181 	mov	w1, #0xc                   	// #12
   830b0:	79c02260 	ldrsh	w0, [x19, #16]
   830b4:	b90002a1 	str	w1, [x21]
   830b8:	17ffff3a 	b	82da0 <__sfvwrite_r+0x1b0>
   830bc:	00000000 	udf	#0

00000000000830c0 <_write_r>:
   830c0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   830c4:	910003fd 	mov	x29, sp
   830c8:	a90153f3 	stp	x19, x20, [sp, #16]
   830cc:	90001414 	adrp	x20, 303000 <saved_categories.0+0xa0>
   830d0:	aa0003f3 	mov	x19, x0
   830d4:	2a0103e0 	mov	w0, w1
   830d8:	aa0203e1 	mov	x1, x2
   830dc:	b9012a9f 	str	wzr, [x20, #296]
   830e0:	aa0303e2 	mov	x2, x3
   830e4:	97fff733 	bl	80db0 <_write>
   830e8:	93407c01 	sxtw	x1, w0
   830ec:	3100041f 	cmn	w0, #0x1
   830f0:	540000a0 	b.eq	83104 <_write_r+0x44>  // b.none
   830f4:	a94153f3 	ldp	x19, x20, [sp, #16]
   830f8:	aa0103e0 	mov	x0, x1
   830fc:	a8c27bfd 	ldp	x29, x30, [sp], #32
   83100:	d65f03c0 	ret
   83104:	b9412a80 	ldr	w0, [x20, #296]
   83108:	34ffff60 	cbz	w0, 830f4 <_write_r+0x34>
   8310c:	b9000260 	str	w0, [x19]
   83110:	aa0103e0 	mov	x0, x1
   83114:	a94153f3 	ldp	x19, x20, [sp, #16]
   83118:	a8c27bfd 	ldp	x29, x30, [sp], #32
   8311c:	d65f03c0 	ret

0000000000083120 <_fwalk_sglue>:
   83120:	a9bb7bfd 	stp	x29, x30, [sp, #-80]!
   83124:	910003fd 	mov	x29, sp
   83128:	a9025bf5 	stp	x21, x22, [sp, #32]
   8312c:	aa0203f6 	mov	x22, x2
   83130:	52800015 	mov	w21, #0x0                   	// #0
   83134:	a90363f7 	stp	x23, x24, [sp, #48]
   83138:	aa0003f7 	mov	x23, x0
   8313c:	aa0103f8 	mov	x24, x1
   83140:	a90153f3 	stp	x19, x20, [sp, #16]
   83144:	f90023f9 	str	x25, [sp, #64]
   83148:	52801719 	mov	w25, #0xb8                  	// #184
   8314c:	d503201f 	nop
   83150:	b9400ad4 	ldr	w20, [x22, #8]
   83154:	f9400ad3 	ldr	x19, [x22, #16]
   83158:	7100029f 	cmp	w20, #0x0
   8315c:	5400020d 	b.le	8319c <_fwalk_sglue+0x7c>
   83160:	9bb94e94 	umaddl	x20, w20, w25, x19
   83164:	d503201f 	nop
   83168:	79402263 	ldrh	w3, [x19, #16]
   8316c:	7100047f 	cmp	w3, #0x1
   83170:	54000109 	b.ls	83190 <_fwalk_sglue+0x70>  // b.plast
   83174:	79c02663 	ldrsh	w3, [x19, #18]
   83178:	aa1303e1 	mov	x1, x19
   8317c:	aa1703e0 	mov	x0, x23
   83180:	3100047f 	cmn	w3, #0x1
   83184:	54000060 	b.eq	83190 <_fwalk_sglue+0x70>  // b.none
   83188:	d63f0300 	blr	x24
   8318c:	2a0002b5 	orr	w21, w21, w0
   83190:	9102e273 	add	x19, x19, #0xb8
   83194:	eb13029f 	cmp	x20, x19
   83198:	54fffe81 	b.ne	83168 <_fwalk_sglue+0x48>  // b.any
   8319c:	f94002d6 	ldr	x22, [x22]
   831a0:	b5fffd96 	cbnz	x22, 83150 <_fwalk_sglue+0x30>
   831a4:	a94153f3 	ldp	x19, x20, [sp, #16]
   831a8:	2a1503e0 	mov	w0, w21
   831ac:	a9425bf5 	ldp	x21, x22, [sp, #32]
   831b0:	a94363f7 	ldp	x23, x24, [sp, #48]
   831b4:	f94023f9 	ldr	x25, [sp, #64]
   831b8:	a8c57bfd 	ldp	x29, x30, [sp], #80
   831bc:	d65f03c0 	ret

00000000000831c0 <_svfprintf_r>:
   831c0:	d10983ff 	sub	sp, sp, #0x260
   831c4:	a9007bfd 	stp	x29, x30, [sp]
   831c8:	910003fd 	mov	x29, sp
   831cc:	a9025bf5 	stp	x21, x22, [sp, #32]
   831d0:	aa0103f5 	mov	x21, x1
   831d4:	f9400061 	ldr	x1, [x3]
   831d8:	a90787e2 	stp	x2, x1, [sp, #120]
   831dc:	f9400461 	ldr	x1, [x3, #8]
   831e0:	f90057e1 	str	x1, [sp, #168]
   831e4:	f9400861 	ldr	x1, [x3, #16]
   831e8:	f9008be1 	str	x1, [sp, #272]
   831ec:	b9401861 	ldr	w1, [x3, #24]
   831f0:	b9009be1 	str	w1, [sp, #152]
   831f4:	b9401c61 	ldr	w1, [x3, #28]
   831f8:	a90153f3 	stp	x19, x20, [sp, #16]
   831fc:	aa0003f3 	mov	x19, x0
   83200:	b900ffe1 	str	w1, [sp, #252]
   83204:	94002693 	bl	8cc50 <_localeconv_r>
   83208:	f9400000 	ldr	x0, [x0]
   8320c:	f9005fe0 	str	x0, [sp, #184]
   83210:	97fffddc 	bl	82980 <strlen>
   83214:	f9005be0 	str	x0, [sp, #176]
   83218:	d2800102 	mov	x2, #0x8                   	// #8
   8321c:	910523e0 	add	x0, sp, #0x148
   83220:	52800001 	mov	w1, #0x0                   	// #0
   83224:	940028e7 	bl	8d5c0 <memset>
   83228:	794022a0 	ldrh	w0, [x21, #16]
   8322c:	f9403fe9 	ldr	x9, [sp, #120]
   83230:	36380060 	tbz	w0, #7, 8323c <_svfprintf_r+0x7c>
   83234:	f9400ea0 	ldr	x0, [x21, #24]
   83238:	b400af00 	cbz	x0, 84818 <_svfprintf_r+0x1658>
   8323c:	a90363f7 	stp	x23, x24, [sp, #48]
   83240:	a9046bf9 	stp	x25, x26, [sp, #64]
   83244:	a90573fb 	stp	x27, x28, [sp, #80]
   83248:	6d0627e8 	stp	d8, d9, [sp, #96]
   8324c:	910783f6 	add	x22, sp, #0x1e0
   83250:	2f00e408 	movi	d8, #0x0
   83254:	f0000094 	adrp	x20, 96000 <JIS_state_table+0x70>
   83258:	aa1603fc 	mov	x28, x22
   8325c:	91324294 	add	x20, x20, #0xc90
   83260:	aa0903f9 	mov	x25, x9
   83264:	d0000080 	adrp	x0, 95000 <pmu_event_descr+0x60>
   83268:	91189000 	add	x0, x0, #0x624
   8326c:	b9007bff 	str	wzr, [sp, #120]
   83270:	f90047e0 	str	x0, [sp, #136]
   83274:	f90063ff 	str	xzr, [sp, #192]
   83278:	29197fff 	stp	wzr, wzr, [sp, #200]
   8327c:	a90effff 	stp	xzr, xzr, [sp, #232]
   83280:	f90083ff 	str	xzr, [sp, #256]
   83284:	f900b3f6 	str	x22, [sp, #352]
   83288:	b9016bff 	str	wzr, [sp, #360]
   8328c:	f900bbff 	str	xzr, [sp, #368]
   83290:	aa1903fa 	mov	x26, x25
   83294:	d503201f 	nop
   83298:	f9407697 	ldr	x23, [x20, #232]
   8329c:	9400265d 	bl	8cc10 <__locale_mb_cur_max>
   832a0:	910523e4 	add	x4, sp, #0x148
   832a4:	93407c03 	sxtw	x3, w0
   832a8:	aa1a03e2 	mov	x2, x26
   832ac:	9104f3e1 	add	x1, sp, #0x13c
   832b0:	aa1303e0 	mov	x0, x19
   832b4:	d63f02e0 	blr	x23
   832b8:	7100001f 	cmp	w0, #0x0
   832bc:	340001e0 	cbz	w0, 832f8 <_svfprintf_r+0x138>
   832c0:	540000eb 	b.lt	832dc <_svfprintf_r+0x11c>  // b.tstop
   832c4:	b9413fe1 	ldr	w1, [sp, #316]
   832c8:	7100943f 	cmp	w1, #0x25
   832cc:	540033c0 	b.eq	83944 <_svfprintf_r+0x784>  // b.none
   832d0:	93407c00 	sxtw	x0, w0
   832d4:	8b00035a 	add	x26, x26, x0
   832d8:	17fffff0 	b	83298 <_svfprintf_r+0xd8>
   832dc:	910523e0 	add	x0, sp, #0x148
   832e0:	d2800102 	mov	x2, #0x8                   	// #8
   832e4:	52800001 	mov	w1, #0x0                   	// #0
   832e8:	940028b6 	bl	8d5c0 <memset>
   832ec:	d2800020 	mov	x0, #0x1                   	// #1
   832f0:	8b00035a 	add	x26, x26, x0
   832f4:	17ffffe9 	b	83298 <_svfprintf_r+0xd8>
   832f8:	2a0003f7 	mov	w23, w0
   832fc:	cb190340 	sub	x0, x26, x25
   83300:	2a0003fb 	mov	w27, w0
   83304:	3400ee00 	cbz	w0, 850c4 <_svfprintf_r+0x1f04>
   83308:	f940bbe2 	ldr	x2, [sp, #368]
   8330c:	93407f61 	sxtw	x1, w27
   83310:	b9416be0 	ldr	w0, [sp, #360]
   83314:	8b010042 	add	x2, x2, x1
   83318:	a9000799 	stp	x25, x1, [x28]
   8331c:	11000400 	add	w0, w0, #0x1
   83320:	b9016be0 	str	w0, [sp, #360]
   83324:	9100439c 	add	x28, x28, #0x10
   83328:	f900bbe2 	str	x2, [sp, #368]
   8332c:	71001c1f 	cmp	w0, #0x7
   83330:	5400458c 	b.gt	83be0 <_svfprintf_r+0xa20>
   83334:	b9407be0 	ldr	w0, [sp, #120]
   83338:	0b1b0000 	add	w0, w0, w27
   8333c:	b9007be0 	str	w0, [sp, #120]
   83340:	3400ec37 	cbz	w23, 850c4 <_svfprintf_r+0x1f04>
   83344:	39400748 	ldrb	w8, [x26, #1]
   83348:	91000759 	add	x25, x26, #0x1
   8334c:	12800007 	mov	w7, #0xffffffff            	// #-1
   83350:	5280000b 	mov	w11, #0x0                   	// #0
   83354:	52800009 	mov	w9, #0x0                   	// #0
   83358:	2a0b03f8 	mov	w24, w11
   8335c:	2a0903f7 	mov	w23, w9
   83360:	2a0703fa 	mov	w26, w7
   83364:	3904bfff 	strb	wzr, [sp, #303]
   83368:	91000739 	add	x25, x25, #0x1
   8336c:	51008100 	sub	w0, w8, #0x20
   83370:	7101681f 	cmp	w0, #0x5a
   83374:	540000c8 	b.hi	8338c <_svfprintf_r+0x1cc>  // b.pmore
   83378:	f94047e1 	ldr	x1, [sp, #136]
   8337c:	78605820 	ldrh	w0, [x1, w0, uxtw #1]
   83380:	10000061 	adr	x1, 8338c <_svfprintf_r+0x1cc>
   83384:	8b20a820 	add	x0, x1, w0, sxth #2
   83388:	d61f0000 	br	x0
   8338c:	2a1703e9 	mov	w9, w23
   83390:	2a1803eb 	mov	w11, w24
   83394:	3400e988 	cbz	w8, 850c4 <_svfprintf_r+0x1f04>
   83398:	52800023 	mov	w3, #0x1                   	// #1
   8339c:	9105e3f8 	add	x24, sp, #0x178
   833a0:	2a0303fb 	mov	w27, w3
   833a4:	52800001 	mov	w1, #0x0                   	// #0
   833a8:	d2800017 	mov	x23, #0x0                   	// #0
   833ac:	52800007 	mov	w7, #0x0                   	// #0
   833b0:	b90093ff 	str	wzr, [sp, #144]
   833b4:	2913ffff 	stp	wzr, wzr, [sp, #156]
   833b8:	3904bfff 	strb	wzr, [sp, #303]
   833bc:	3905e3e8 	strb	w8, [sp, #376]
   833c0:	721f0132 	ands	w18, w9, #0x2
   833c4:	11000862 	add	w2, w3, #0x2
   833c8:	f940bbe0 	ldr	x0, [sp, #368]
   833cc:	1a831043 	csel	w3, w2, w3, ne	// ne = any
   833d0:	5280108e 	mov	w14, #0x84                  	// #132
   833d4:	6a0e013a 	ands	w26, w9, w14
   833d8:	54000081 	b.ne	833e8 <_svfprintf_r+0x228>  // b.any
   833dc:	4b030164 	sub	w4, w11, w3
   833e0:	7100009f 	cmp	w4, #0x0
   833e4:	54001a6c 	b.gt	83730 <_svfprintf_r+0x570>
   833e8:	340001a1 	cbz	w1, 8341c <_svfprintf_r+0x25c>
   833ec:	b9416be1 	ldr	w1, [sp, #360]
   833f0:	9104bfe2 	add	x2, sp, #0x12f
   833f4:	91000400 	add	x0, x0, #0x1
   833f8:	f9000382 	str	x2, [x28]
   833fc:	11000421 	add	w1, w1, #0x1
   83400:	d2800022 	mov	x2, #0x1                   	// #1
   83404:	f9000782 	str	x2, [x28, #8]
   83408:	9100439c 	add	x28, x28, #0x10
   8340c:	b9016be1 	str	w1, [sp, #360]
   83410:	f900bbe0 	str	x0, [sp, #368]
   83414:	71001c3f 	cmp	w1, #0x7
   83418:	540020ac 	b.gt	8382c <_svfprintf_r+0x66c>
   8341c:	340001b2 	cbz	w18, 83450 <_svfprintf_r+0x290>
   83420:	b9416be1 	ldr	w1, [sp, #360]
   83424:	9104c3e2 	add	x2, sp, #0x130
   83428:	91000800 	add	x0, x0, #0x2
   8342c:	f9000382 	str	x2, [x28]
   83430:	11000421 	add	w1, w1, #0x1
   83434:	d2800042 	mov	x2, #0x2                   	// #2
   83438:	f9000782 	str	x2, [x28, #8]
   8343c:	9100439c 	add	x28, x28, #0x10
   83440:	b9016be1 	str	w1, [sp, #360]
   83444:	f900bbe0 	str	x0, [sp, #368]
   83448:	71001c3f 	cmp	w1, #0x7
   8344c:	54003d8c 	b.gt	83bfc <_svfprintf_r+0xa3c>
   83450:	7102035f 	cmp	w26, #0x80
   83454:	54002820 	b.eq	83958 <_svfprintf_r+0x798>  // b.none
   83458:	4b1b00fa 	sub	w26, w7, w27
   8345c:	7100035f 	cmp	w26, #0x0
   83460:	540004cc 	b.gt	834f8 <_svfprintf_r+0x338>
   83464:	37400de9 	tbnz	w9, #8, 83620 <_svfprintf_r+0x460>
   83468:	b9416be1 	ldr	w1, [sp, #360]
   8346c:	93407f6c 	sxtw	x12, w27
   83470:	8b0c0000 	add	x0, x0, x12
   83474:	a9003398 	stp	x24, x12, [x28]
   83478:	11000421 	add	w1, w1, #0x1
   8347c:	b9016be1 	str	w1, [sp, #360]
   83480:	f900bbe0 	str	x0, [sp, #368]
   83484:	71001c3f 	cmp	w1, #0x7
   83488:	5400240c 	b.gt	83908 <_svfprintf_r+0x748>
   8348c:	9100439c 	add	x28, x28, #0x10
   83490:	36100089 	tbz	w9, #2, 834a0 <_svfprintf_r+0x2e0>
   83494:	4b03017a 	sub	w26, w11, w3
   83498:	7100035f 	cmp	w26, #0x0
   8349c:	54003d4c 	b.gt	83c44 <_svfprintf_r+0xa84>
   834a0:	b9407be1 	ldr	w1, [sp, #120]
   834a4:	6b03017f 	cmp	w11, w3
   834a8:	1a83a163 	csel	w3, w11, w3, ge	// ge = tcont
   834ac:	0b030021 	add	w1, w1, w3
   834b0:	b9007be1 	str	w1, [sp, #120]
   834b4:	b5002f20 	cbnz	x0, 83a98 <_svfprintf_r+0x8d8>
   834b8:	b9016bff 	str	wzr, [sp, #360]
   834bc:	b4000097 	cbz	x23, 834cc <_svfprintf_r+0x30c>
   834c0:	aa1703e1 	mov	x1, x23
   834c4:	aa1303e0 	mov	x0, x19
   834c8:	940030be 	bl	8f7c0 <_free_r>
   834cc:	aa1603fc 	mov	x28, x22
   834d0:	17ffff70 	b	83290 <_svfprintf_r+0xd0>
   834d4:	5100c100 	sub	w0, w8, #0x30
   834d8:	52800018 	mov	w24, #0x0                   	// #0
   834dc:	38401728 	ldrb	w8, [x25], #1
   834e0:	0b180b0b 	add	w11, w24, w24, lsl #2
   834e4:	0b0b0418 	add	w24, w0, w11, lsl #1
   834e8:	5100c100 	sub	w0, w8, #0x30
   834ec:	7100241f 	cmp	w0, #0x9
   834f0:	54ffff69 	b.ls	834dc <_svfprintf_r+0x31c>  // b.plast
   834f4:	17ffff9e 	b	8336c <_svfprintf_r+0x1ac>
   834f8:	d0000084 	adrp	x4, 95000 <pmu_event_descr+0x60>
   834fc:	b9416be1 	ldr	w1, [sp, #360]
   83500:	911b8084 	add	x4, x4, #0x6e0
   83504:	7100435f 	cmp	w26, #0x10
   83508:	5400058d 	b.le	835b8 <_svfprintf_r+0x3f8>
   8350c:	aa1c03e2 	mov	x2, x28
   83510:	d280020d 	mov	x13, #0x10                  	// #16
   83514:	aa1903fc 	mov	x28, x25
   83518:	aa0403f9 	mov	x25, x4
   8351c:	b900d3e8 	str	w8, [sp, #208]
   83520:	f9006ff8 	str	x24, [sp, #216]
   83524:	2a1a03f8 	mov	w24, w26
   83528:	2a0303fa 	mov	w26, w3
   8352c:	b900e3e9 	str	w9, [sp, #224]
   83530:	b900fbeb 	str	w11, [sp, #248]
   83534:	14000004 	b	83544 <_svfprintf_r+0x384>
   83538:	51004318 	sub	w24, w24, #0x10
   8353c:	7100431f 	cmp	w24, #0x10
   83540:	540002ad 	b.le	83594 <_svfprintf_r+0x3d4>
   83544:	91004000 	add	x0, x0, #0x10
   83548:	11000421 	add	w1, w1, #0x1
   8354c:	a9003459 	stp	x25, x13, [x2]
   83550:	91004042 	add	x2, x2, #0x10
   83554:	b9016be1 	str	w1, [sp, #360]
   83558:	f900bbe0 	str	x0, [sp, #368]
   8355c:	71001c3f 	cmp	w1, #0x7
   83560:	54fffecd 	b.le	83538 <_svfprintf_r+0x378>
   83564:	910583e2 	add	x2, sp, #0x160
   83568:	aa1503e1 	mov	x1, x21
   8356c:	aa1303e0 	mov	x0, x19
   83570:	94003564 	bl	90b00 <__ssprint_r>
   83574:	350029e0 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   83578:	51004318 	sub	w24, w24, #0x10
   8357c:	b9416be1 	ldr	w1, [sp, #360]
   83580:	f940bbe0 	ldr	x0, [sp, #368]
   83584:	aa1603e2 	mov	x2, x22
   83588:	d280020d 	mov	x13, #0x10                  	// #16
   8358c:	7100431f 	cmp	w24, #0x10
   83590:	54fffdac 	b.gt	83544 <_svfprintf_r+0x384>
   83594:	2a1a03e3 	mov	w3, w26
   83598:	b940d3e8 	ldr	w8, [sp, #208]
   8359c:	2a1803fa 	mov	w26, w24
   835a0:	b940e3e9 	ldr	w9, [sp, #224]
   835a4:	f9406ff8 	ldr	x24, [sp, #216]
   835a8:	aa1903e4 	mov	x4, x25
   835ac:	b940fbeb 	ldr	w11, [sp, #248]
   835b0:	aa1c03f9 	mov	x25, x28
   835b4:	aa0203fc 	mov	x28, x2
   835b8:	93407f47 	sxtw	x7, w26
   835bc:	11000421 	add	w1, w1, #0x1
   835c0:	8b070000 	add	x0, x0, x7
   835c4:	a9001f84 	stp	x4, x7, [x28]
   835c8:	9100439c 	add	x28, x28, #0x10
   835cc:	b9016be1 	str	w1, [sp, #360]
   835d0:	f900bbe0 	str	x0, [sp, #368]
   835d4:	71001c3f 	cmp	w1, #0x7
   835d8:	54fff46d 	b.le	83464 <_svfprintf_r+0x2a4>
   835dc:	910583e2 	add	x2, sp, #0x160
   835e0:	aa1503e1 	mov	x1, x21
   835e4:	aa1303e0 	mov	x0, x19
   835e8:	b900d3e8 	str	w8, [sp, #208]
   835ec:	b900dbe9 	str	w9, [sp, #216]
   835f0:	b900e3eb 	str	w11, [sp, #224]
   835f4:	b900fbe3 	str	w3, [sp, #248]
   835f8:	94003542 	bl	90b00 <__ssprint_r>
   835fc:	350025a0 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   83600:	b940dbe9 	ldr	w9, [sp, #216]
   83604:	aa1603fc 	mov	x28, x22
   83608:	f940bbe0 	ldr	x0, [sp, #368]
   8360c:	b940d3e8 	ldr	w8, [sp, #208]
   83610:	b940e3eb 	ldr	w11, [sp, #224]
   83614:	b940fbe3 	ldr	w3, [sp, #248]
   83618:	3647f289 	tbz	w9, #8, 83468 <_svfprintf_r+0x2a8>
   8361c:	d503201f 	nop
   83620:	7101951f 	cmp	w8, #0x65
   83624:	5400268d 	b.le	83af4 <_svfprintf_r+0x934>
   83628:	1e602108 	fcmp	d8, #0.0
   8362c:	54003da1 	b.ne	83de0 <_svfprintf_r+0xc20>  // b.any
   83630:	b9416be1 	ldr	w1, [sp, #360]
   83634:	91000400 	add	x0, x0, #0x1
   83638:	d0000082 	adrp	x2, 95000 <pmu_event_descr+0x60>
   8363c:	d2800024 	mov	x4, #0x1                   	// #1
   83640:	91188042 	add	x2, x2, #0x620
   83644:	11000421 	add	w1, w1, #0x1
   83648:	a9001382 	stp	x2, x4, [x28]
   8364c:	9100439c 	add	x28, x28, #0x10
   83650:	b9016be1 	str	w1, [sp, #360]
   83654:	f900bbe0 	str	x0, [sp, #368]
   83658:	71001c3f 	cmp	w1, #0x7
   8365c:	5400be4c 	b.gt	84e24 <_svfprintf_r+0x1c64>
   83660:	b940cbe2 	ldr	w2, [sp, #200]
   83664:	b9413be1 	ldr	w1, [sp, #312]
   83668:	6b02003f 	cmp	w1, w2
   8366c:	54007d2a 	b.ge	84610 <_svfprintf_r+0x1450>  // b.tcont
   83670:	a94b13e2 	ldp	x2, x4, [sp, #176]
   83674:	a9000b84 	stp	x4, x2, [x28]
   83678:	b9416be1 	ldr	w1, [sp, #360]
   8367c:	9100439c 	add	x28, x28, #0x10
   83680:	11000421 	add	w1, w1, #0x1
   83684:	b9016be1 	str	w1, [sp, #360]
   83688:	8b020000 	add	x0, x0, x2
   8368c:	f900bbe0 	str	x0, [sp, #368]
   83690:	71001c3f 	cmp	w1, #0x7
   83694:	540089ac 	b.gt	847c8 <_svfprintf_r+0x1608>
   83698:	b940cbe1 	ldr	w1, [sp, #200]
   8369c:	5100043a 	sub	w26, w1, #0x1
   836a0:	7100035f 	cmp	w26, #0x0
   836a4:	54ffef6d 	b.le	83490 <_svfprintf_r+0x2d0>
   836a8:	d0000084 	adrp	x4, 95000 <pmu_event_descr+0x60>
   836ac:	b9416be1 	ldr	w1, [sp, #360]
   836b0:	911b8084 	add	x4, x4, #0x6e0
   836b4:	7100435f 	cmp	w26, #0x10
   836b8:	5400c72d 	b.le	84f9c <_svfprintf_r+0x1ddc>
   836bc:	aa1c03e2 	mov	x2, x28
   836c0:	2a1a03f8 	mov	w24, w26
   836c4:	aa1903fc 	mov	x28, x25
   836c8:	2a0303fa 	mov	w26, w3
   836cc:	aa0403f9 	mov	x25, x4
   836d0:	d280021b 	mov	x27, #0x10                  	// #16
   836d4:	b90093e9 	str	w9, [sp, #144]
   836d8:	b9009feb 	str	w11, [sp, #156]
   836dc:	14000004 	b	836ec <_svfprintf_r+0x52c>
   836e0:	51004318 	sub	w24, w24, #0x10
   836e4:	7100431f 	cmp	w24, #0x10
   836e8:	5400c4cd 	b.le	84f80 <_svfprintf_r+0x1dc0>
   836ec:	91004000 	add	x0, x0, #0x10
   836f0:	11000421 	add	w1, w1, #0x1
   836f4:	a9006c59 	stp	x25, x27, [x2]
   836f8:	91004042 	add	x2, x2, #0x10
   836fc:	b9016be1 	str	w1, [sp, #360]
   83700:	f900bbe0 	str	x0, [sp, #368]
   83704:	71001c3f 	cmp	w1, #0x7
   83708:	54fffecd 	b.le	836e0 <_svfprintf_r+0x520>
   8370c:	910583e2 	add	x2, sp, #0x160
   83710:	aa1503e1 	mov	x1, x21
   83714:	aa1303e0 	mov	x0, x19
   83718:	940034fa 	bl	90b00 <__ssprint_r>
   8371c:	35001ca0 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   83720:	f940bbe0 	ldr	x0, [sp, #368]
   83724:	aa1603e2 	mov	x2, x22
   83728:	b9416be1 	ldr	w1, [sp, #360]
   8372c:	17ffffed 	b	836e0 <_svfprintf_r+0x520>
   83730:	d000008d 	adrp	x13, 95000 <pmu_event_descr+0x60>
   83734:	b9416be1 	ldr	w1, [sp, #360]
   83738:	911bc1ad 	add	x13, x13, #0x6f0
   8373c:	7100409f 	cmp	w4, #0x10
   83740:	5400060d 	b.le	83800 <_svfprintf_r+0x640>
   83744:	aa1c03e2 	mov	x2, x28
   83748:	d280020f 	mov	x15, #0x10                  	// #16
   8374c:	aa1903fc 	mov	x28, x25
   83750:	aa0d03f9 	mov	x25, x13
   83754:	b900d3f2 	str	w18, [sp, #208]
   83758:	b900dbe8 	str	w8, [sp, #216]
   8375c:	f90073f8 	str	x24, [sp, #224]
   83760:	2a0403f8 	mov	w24, w4
   83764:	b900fbe9 	str	w9, [sp, #248]
   83768:	b9010beb 	str	w11, [sp, #264]
   8376c:	b9011be7 	str	w7, [sp, #280]
   83770:	b9011fe3 	str	w3, [sp, #284]
   83774:	14000004 	b	83784 <_svfprintf_r+0x5c4>
   83778:	51004318 	sub	w24, w24, #0x10
   8377c:	7100431f 	cmp	w24, #0x10
   83780:	540002ad 	b.le	837d4 <_svfprintf_r+0x614>
   83784:	91004000 	add	x0, x0, #0x10
   83788:	11000421 	add	w1, w1, #0x1
   8378c:	a9003c59 	stp	x25, x15, [x2]
   83790:	91004042 	add	x2, x2, #0x10
   83794:	b9016be1 	str	w1, [sp, #360]
   83798:	f900bbe0 	str	x0, [sp, #368]
   8379c:	71001c3f 	cmp	w1, #0x7
   837a0:	54fffecd 	b.le	83778 <_svfprintf_r+0x5b8>
   837a4:	910583e2 	add	x2, sp, #0x160
   837a8:	aa1503e1 	mov	x1, x21
   837ac:	aa1303e0 	mov	x0, x19
   837b0:	940034d4 	bl	90b00 <__ssprint_r>
   837b4:	350017e0 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   837b8:	51004318 	sub	w24, w24, #0x10
   837bc:	b9416be1 	ldr	w1, [sp, #360]
   837c0:	f940bbe0 	ldr	x0, [sp, #368]
   837c4:	aa1603e2 	mov	x2, x22
   837c8:	d280020f 	mov	x15, #0x10                  	// #16
   837cc:	7100431f 	cmp	w24, #0x10
   837d0:	54fffdac 	b.gt	83784 <_svfprintf_r+0x5c4>
   837d4:	2a1803e4 	mov	w4, w24
   837d8:	b940d3f2 	ldr	w18, [sp, #208]
   837dc:	f94073f8 	ldr	x24, [sp, #224]
   837e0:	aa1903ed 	mov	x13, x25
   837e4:	b940dbe8 	ldr	w8, [sp, #216]
   837e8:	aa1c03f9 	mov	x25, x28
   837ec:	b940fbe9 	ldr	w9, [sp, #248]
   837f0:	aa0203fc 	mov	x28, x2
   837f4:	b9410beb 	ldr	w11, [sp, #264]
   837f8:	b9411be7 	ldr	w7, [sp, #280]
   837fc:	b9411fe3 	ldr	w3, [sp, #284]
   83800:	93407c84 	sxtw	x4, w4
   83804:	11000421 	add	w1, w1, #0x1
   83808:	8b040000 	add	x0, x0, x4
   8380c:	a900138d 	stp	x13, x4, [x28]
   83810:	b9016be1 	str	w1, [sp, #360]
   83814:	f900bbe0 	str	x0, [sp, #368]
   83818:	71001c3f 	cmp	w1, #0x7
   8381c:	5400a12c 	b.gt	84c40 <_svfprintf_r+0x1a80>
   83820:	3944bfe1 	ldrb	w1, [sp, #303]
   83824:	9100439c 	add	x28, x28, #0x10
   83828:	17fffef0 	b	833e8 <_svfprintf_r+0x228>
   8382c:	910583e2 	add	x2, sp, #0x160
   83830:	aa1503e1 	mov	x1, x21
   83834:	aa1303e0 	mov	x0, x19
   83838:	b900d3f2 	str	w18, [sp, #208]
   8383c:	b900dbe8 	str	w8, [sp, #216]
   83840:	b900e3e9 	str	w9, [sp, #224]
   83844:	b900fbeb 	str	w11, [sp, #248]
   83848:	b9010be7 	str	w7, [sp, #264]
   8384c:	b9011be3 	str	w3, [sp, #280]
   83850:	940034ac 	bl	90b00 <__ssprint_r>
   83854:	350012e0 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   83858:	f940bbe0 	ldr	x0, [sp, #368]
   8385c:	aa1603fc 	mov	x28, x22
   83860:	b940d3f2 	ldr	w18, [sp, #208]
   83864:	b940dbe8 	ldr	w8, [sp, #216]
   83868:	b940e3e9 	ldr	w9, [sp, #224]
   8386c:	b940fbeb 	ldr	w11, [sp, #248]
   83870:	b9410be7 	ldr	w7, [sp, #264]
   83874:	b9411be3 	ldr	w3, [sp, #280]
   83878:	17fffee9 	b	8341c <_svfprintf_r+0x25c>
   8387c:	b9416be1 	ldr	w1, [sp, #360]
   83880:	91000400 	add	x0, x0, #0x1
   83884:	d0000084 	adrp	x4, 95000 <pmu_event_descr+0x60>
   83888:	d2800027 	mov	x7, #0x1                   	// #1
   8388c:	91188084 	add	x4, x4, #0x620
   83890:	11000421 	add	w1, w1, #0x1
   83894:	a9001f84 	stp	x4, x7, [x28]
   83898:	9100439c 	add	x28, x28, #0x10
   8389c:	b9016be1 	str	w1, [sp, #360]
   838a0:	f900bbe0 	str	x0, [sp, #368]
   838a4:	71001c3f 	cmp	w1, #0x7
   838a8:	5400e2ac 	b.gt	854fc <_svfprintf_r+0x233c>
   838ac:	b940cbe1 	ldr	w1, [sp, #200]
   838b0:	2a020021 	orr	w1, w1, w2
   838b4:	3400e6a1 	cbz	w1, 85588 <_svfprintf_r+0x23c8>
   838b8:	a94b17e4 	ldp	x4, x5, [sp, #176]
   838bc:	a9001385 	stp	x5, x4, [x28]
   838c0:	b9416be1 	ldr	w1, [sp, #360]
   838c4:	91004386 	add	x6, x28, #0x10
   838c8:	11000421 	add	w1, w1, #0x1
   838cc:	b9016be1 	str	w1, [sp, #360]
   838d0:	8b000080 	add	x0, x4, x0
   838d4:	f900bbe0 	str	x0, [sp, #368]
   838d8:	71001c3f 	cmp	w1, #0x7
   838dc:	5400e6cc 	b.gt	855b4 <_svfprintf_r+0x23f4>
   838e0:	37f910a2 	tbnz	w2, #31, 85af4 <_svfprintf_r+0x2934>
   838e4:	b980cbe2 	ldrsw	x2, [sp, #200]
   838e8:	11000421 	add	w1, w1, #0x1
   838ec:	a90008d8 	stp	x24, x2, [x6]
   838f0:	910040dc 	add	x28, x6, #0x10
   838f4:	8b000040 	add	x0, x2, x0
   838f8:	b9016be1 	str	w1, [sp, #360]
   838fc:	f900bbe0 	str	x0, [sp, #368]
   83900:	71001c3f 	cmp	w1, #0x7
   83904:	54ffdc6d 	b.le	83490 <_svfprintf_r+0x2d0>
   83908:	910583e2 	add	x2, sp, #0x160
   8390c:	aa1503e1 	mov	x1, x21
   83910:	aa1303e0 	mov	x0, x19
   83914:	b90093e9 	str	w9, [sp, #144]
   83918:	29138feb 	stp	w11, w3, [sp, #156]
   8391c:	94003479 	bl	90b00 <__ssprint_r>
   83920:	35000c80 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   83924:	f940bbe0 	ldr	x0, [sp, #368]
   83928:	aa1603fc 	mov	x28, x22
   8392c:	b94093e9 	ldr	w9, [sp, #144]
   83930:	29538feb 	ldp	w11, w3, [sp, #156]
   83934:	17fffed7 	b	83490 <_svfprintf_r+0x2d0>
   83938:	39400328 	ldrb	w8, [x25]
   8393c:	321c02f7 	orr	w23, w23, #0x10
   83940:	17fffe8a 	b	83368 <_svfprintf_r+0x1a8>
   83944:	2a0003f7 	mov	w23, w0
   83948:	cb190340 	sub	x0, x26, x25
   8394c:	2a0003fb 	mov	w27, w0
   83950:	34ffcfa0 	cbz	w0, 83344 <_svfprintf_r+0x184>
   83954:	17fffe6d 	b	83308 <_svfprintf_r+0x148>
   83958:	4b03017a 	sub	w26, w11, w3
   8395c:	7100035f 	cmp	w26, #0x0
   83960:	54ffd7cd 	b.le	83458 <_svfprintf_r+0x298>
   83964:	d0000084 	adrp	x4, 95000 <pmu_event_descr+0x60>
   83968:	b9416be1 	ldr	w1, [sp, #360]
   8396c:	911b8084 	add	x4, x4, #0x6e0
   83970:	7100435f 	cmp	w26, #0x10
   83974:	540005cd 	b.le	83a2c <_svfprintf_r+0x86c>
   83978:	aa1c03e2 	mov	x2, x28
   8397c:	d280020e 	mov	x14, #0x10                  	// #16
   83980:	aa1903fc 	mov	x28, x25
   83984:	aa0403f9 	mov	x25, x4
   83988:	b900d3e8 	str	w8, [sp, #208]
   8398c:	f9006ff8 	str	x24, [sp, #216]
   83990:	2a1a03f8 	mov	w24, w26
   83994:	2a0303fa 	mov	w26, w3
   83998:	b900e3e9 	str	w9, [sp, #224]
   8399c:	b900fbeb 	str	w11, [sp, #248]
   839a0:	b9010be7 	str	w7, [sp, #264]
   839a4:	14000004 	b	839b4 <_svfprintf_r+0x7f4>
   839a8:	51004318 	sub	w24, w24, #0x10
   839ac:	7100431f 	cmp	w24, #0x10
   839b0:	540002ad 	b.le	83a04 <_svfprintf_r+0x844>
   839b4:	91004000 	add	x0, x0, #0x10
   839b8:	11000421 	add	w1, w1, #0x1
   839bc:	a9003859 	stp	x25, x14, [x2]
   839c0:	91004042 	add	x2, x2, #0x10
   839c4:	b9016be1 	str	w1, [sp, #360]
   839c8:	f900bbe0 	str	x0, [sp, #368]
   839cc:	71001c3f 	cmp	w1, #0x7
   839d0:	54fffecd 	b.le	839a8 <_svfprintf_r+0x7e8>
   839d4:	910583e2 	add	x2, sp, #0x160
   839d8:	aa1503e1 	mov	x1, x21
   839dc:	aa1303e0 	mov	x0, x19
   839e0:	94003448 	bl	90b00 <__ssprint_r>
   839e4:	35000660 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   839e8:	51004318 	sub	w24, w24, #0x10
   839ec:	b9416be1 	ldr	w1, [sp, #360]
   839f0:	f940bbe0 	ldr	x0, [sp, #368]
   839f4:	aa1603e2 	mov	x2, x22
   839f8:	d280020e 	mov	x14, #0x10                  	// #16
   839fc:	7100431f 	cmp	w24, #0x10
   83a00:	54fffdac 	b.gt	839b4 <_svfprintf_r+0x7f4>
   83a04:	2a1a03e3 	mov	w3, w26
   83a08:	b940d3e8 	ldr	w8, [sp, #208]
   83a0c:	2a1803fa 	mov	w26, w24
   83a10:	b940e3e9 	ldr	w9, [sp, #224]
   83a14:	f9406ff8 	ldr	x24, [sp, #216]
   83a18:	aa1903e4 	mov	x4, x25
   83a1c:	b940fbeb 	ldr	w11, [sp, #248]
   83a20:	aa1c03f9 	mov	x25, x28
   83a24:	b9410be7 	ldr	w7, [sp, #264]
   83a28:	aa0203fc 	mov	x28, x2
   83a2c:	93407f4d 	sxtw	x13, w26
   83a30:	11000421 	add	w1, w1, #0x1
   83a34:	8b0d0000 	add	x0, x0, x13
   83a38:	a9003784 	stp	x4, x13, [x28]
   83a3c:	9100439c 	add	x28, x28, #0x10
   83a40:	b9016be1 	str	w1, [sp, #360]
   83a44:	f900bbe0 	str	x0, [sp, #368]
   83a48:	71001c3f 	cmp	w1, #0x7
   83a4c:	54ffd06d 	b.le	83458 <_svfprintf_r+0x298>
   83a50:	910583e2 	add	x2, sp, #0x160
   83a54:	aa1503e1 	mov	x1, x21
   83a58:	aa1303e0 	mov	x0, x19
   83a5c:	b900d3e8 	str	w8, [sp, #208]
   83a60:	b900dbe9 	str	w9, [sp, #216]
   83a64:	b900e3eb 	str	w11, [sp, #224]
   83a68:	b900fbe7 	str	w7, [sp, #248]
   83a6c:	b9010be3 	str	w3, [sp, #264]
   83a70:	94003424 	bl	90b00 <__ssprint_r>
   83a74:	350001e0 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   83a78:	f940bbe0 	ldr	x0, [sp, #368]
   83a7c:	aa1603fc 	mov	x28, x22
   83a80:	b940d3e8 	ldr	w8, [sp, #208]
   83a84:	b940dbe9 	ldr	w9, [sp, #216]
   83a88:	b940e3eb 	ldr	w11, [sp, #224]
   83a8c:	b940fbe7 	ldr	w7, [sp, #248]
   83a90:	b9410be3 	ldr	w3, [sp, #264]
   83a94:	17fffe71 	b	83458 <_svfprintf_r+0x298>
   83a98:	910583e2 	add	x2, sp, #0x160
   83a9c:	aa1503e1 	mov	x1, x21
   83aa0:	aa1303e0 	mov	x0, x19
   83aa4:	94003417 	bl	90b00 <__ssprint_r>
   83aa8:	34ffd080 	cbz	w0, 834b8 <_svfprintf_r+0x2f8>
   83aac:	d503201f 	nop
   83ab0:	b4000097 	cbz	x23, 83ac0 <_svfprintf_r+0x900>
   83ab4:	aa1703e1 	mov	x1, x23
   83ab8:	aa1303e0 	mov	x0, x19
   83abc:	94002f41 	bl	8f7c0 <_free_r>
   83ac0:	794022a0 	ldrh	w0, [x21, #16]
   83ac4:	121a0000 	and	w0, w0, #0x40
   83ac8:	a94363f7 	ldp	x23, x24, [sp, #48]
   83acc:	a9446bf9 	ldp	x25, x26, [sp, #64]
   83ad0:	a94573fb 	ldp	x27, x28, [sp, #80]
   83ad4:	6d4627e8 	ldp	d8, d9, [sp, #96]
   83ad8:	35010ee0 	cbnz	w0, 85cb4 <_svfprintf_r+0x2af4>
   83adc:	a9407bfd 	ldp	x29, x30, [sp]
   83ae0:	a94153f3 	ldp	x19, x20, [sp, #16]
   83ae4:	a9425bf5 	ldp	x21, x22, [sp, #32]
   83ae8:	b9407be0 	ldr	w0, [sp, #120]
   83aec:	910983ff 	add	sp, sp, #0x260
   83af0:	d65f03c0 	ret
   83af4:	b9416be1 	ldr	w1, [sp, #360]
   83af8:	91000400 	add	x0, x0, #0x1
   83afc:	b940cbe2 	ldr	w2, [sp, #200]
   83b00:	91004387 	add	x7, x28, #0x10
   83b04:	11000421 	add	w1, w1, #0x1
   83b08:	7100045f 	cmp	w2, #0x1
   83b0c:	540023ad 	b.le	83f80 <_svfprintf_r+0xdc0>
   83b10:	d2800022 	mov	x2, #0x1                   	// #1
   83b14:	a9000b98 	stp	x24, x2, [x28]
   83b18:	b9016be1 	str	w1, [sp, #360]
   83b1c:	f900bbe0 	str	x0, [sp, #368]
   83b20:	71001c3f 	cmp	w1, #0x7
   83b24:	54002bec 	b.gt	840a0 <_svfprintf_r+0xee0>
   83b28:	a94b13e2 	ldp	x2, x4, [sp, #176]
   83b2c:	11000421 	add	w1, w1, #0x1
   83b30:	a90008e4 	stp	x4, x2, [x7]
   83b34:	910040e7 	add	x7, x7, #0x10
   83b38:	b9016be1 	str	w1, [sp, #360]
   83b3c:	8b020000 	add	x0, x0, x2
   83b40:	f900bbe0 	str	x0, [sp, #368]
   83b44:	71001c3f 	cmp	w1, #0x7
   83b48:	540028ac 	b.gt	8405c <_svfprintf_r+0xe9c>
   83b4c:	1e602108 	fcmp	d8, #0.0
   83b50:	b940cbe2 	ldr	w2, [sp, #200]
   83b54:	5100045a 	sub	w26, w2, #0x1
   83b58:	540023c0 	b.eq	83fd0 <_svfprintf_r+0xe10>  // b.none
   83b5c:	93407f5a 	sxtw	x26, w26
   83b60:	11000421 	add	w1, w1, #0x1
   83b64:	8b1a0000 	add	x0, x0, x26
   83b68:	b9016be1 	str	w1, [sp, #360]
   83b6c:	f900bbe0 	str	x0, [sp, #368]
   83b70:	91000705 	add	x5, x24, #0x1
   83b74:	f90000e5 	str	x5, [x7]
   83b78:	f90004fa 	str	x26, [x7, #8]
   83b7c:	71001c3f 	cmp	w1, #0x7
   83b80:	540060ac 	b.gt	84794 <_svfprintf_r+0x15d4>
   83b84:	910040e7 	add	x7, x7, #0x10
   83b88:	b980cfe2 	ldrsw	x2, [sp, #204]
   83b8c:	11000421 	add	w1, w1, #0x1
   83b90:	910503e4 	add	x4, sp, #0x140
   83b94:	a90008e4 	stp	x4, x2, [x7]
   83b98:	8b000040 	add	x0, x2, x0
   83b9c:	b9016be1 	str	w1, [sp, #360]
   83ba0:	910040fc 	add	x28, x7, #0x10
   83ba4:	f900bbe0 	str	x0, [sp, #368]
   83ba8:	71001c3f 	cmp	w1, #0x7
   83bac:	54ffc72d 	b.le	83490 <_svfprintf_r+0x2d0>
   83bb0:	910583e2 	add	x2, sp, #0x160
   83bb4:	aa1503e1 	mov	x1, x21
   83bb8:	aa1303e0 	mov	x0, x19
   83bbc:	b90093e9 	str	w9, [sp, #144]
   83bc0:	29138feb 	stp	w11, w3, [sp, #156]
   83bc4:	940033cf 	bl	90b00 <__ssprint_r>
   83bc8:	35fff740 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   83bcc:	f940bbe0 	ldr	x0, [sp, #368]
   83bd0:	aa1603fc 	mov	x28, x22
   83bd4:	b94093e9 	ldr	w9, [sp, #144]
   83bd8:	29538feb 	ldp	w11, w3, [sp, #156]
   83bdc:	17fffe2d 	b	83490 <_svfprintf_r+0x2d0>
   83be0:	910583e2 	add	x2, sp, #0x160
   83be4:	aa1503e1 	mov	x1, x21
   83be8:	aa1303e0 	mov	x0, x19
   83bec:	940033c5 	bl	90b00 <__ssprint_r>
   83bf0:	35fff680 	cbnz	w0, 83ac0 <_svfprintf_r+0x900>
   83bf4:	aa1603fc 	mov	x28, x22
   83bf8:	17fffdcf 	b	83334 <_svfprintf_r+0x174>
   83bfc:	910583e2 	add	x2, sp, #0x160
   83c00:	aa1503e1 	mov	x1, x21
   83c04:	aa1303e0 	mov	x0, x19
   83c08:	b900d3e8 	str	w8, [sp, #208]
   83c0c:	b900dbe9 	str	w9, [sp, #216]
   83c10:	b900e3eb 	str	w11, [sp, #224]
   83c14:	b900fbe7 	str	w7, [sp, #248]
   83c18:	b9010be3 	str	w3, [sp, #264]
   83c1c:	940033b9 	bl	90b00 <__ssprint_r>
   83c20:	35fff480 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   83c24:	f940bbe0 	ldr	x0, [sp, #368]
   83c28:	aa1603fc 	mov	x28, x22
   83c2c:	b940d3e8 	ldr	w8, [sp, #208]
   83c30:	b940dbe9 	ldr	w9, [sp, #216]
   83c34:	b940e3eb 	ldr	w11, [sp, #224]
   83c38:	b940fbe7 	ldr	w7, [sp, #248]
   83c3c:	b9410be3 	ldr	w3, [sp, #264]
   83c40:	17fffe04 	b	83450 <_svfprintf_r+0x290>
   83c44:	d000008d 	adrp	x13, 95000 <pmu_event_descr+0x60>
   83c48:	b9416be1 	ldr	w1, [sp, #360]
   83c4c:	911bc1ad 	add	x13, x13, #0x6f0
   83c50:	7100435f 	cmp	w26, #0x10
   83c54:	5400046d 	b.le	83ce0 <_svfprintf_r+0xb20>
   83c58:	2a1a03f8 	mov	w24, w26
   83c5c:	d280021b 	mov	x27, #0x10                  	// #16
   83c60:	aa1903fa 	mov	x26, x25
   83c64:	aa0d03f9 	mov	x25, x13
   83c68:	b90093eb 	str	w11, [sp, #144]
   83c6c:	b9009fe3 	str	w3, [sp, #156]
   83c70:	14000004 	b	83c80 <_svfprintf_r+0xac0>
   83c74:	51004318 	sub	w24, w24, #0x10
   83c78:	7100431f 	cmp	w24, #0x10
   83c7c:	5400028d 	b.le	83ccc <_svfprintf_r+0xb0c>
   83c80:	91004000 	add	x0, x0, #0x10
   83c84:	11000421 	add	w1, w1, #0x1
   83c88:	a9006f99 	stp	x25, x27, [x28]
   83c8c:	9100439c 	add	x28, x28, #0x10
   83c90:	b9016be1 	str	w1, [sp, #360]
   83c94:	f900bbe0 	str	x0, [sp, #368]
   83c98:	71001c3f 	cmp	w1, #0x7
   83c9c:	54fffecd 	b.le	83c74 <_svfprintf_r+0xab4>
   83ca0:	910583e2 	add	x2, sp, #0x160
   83ca4:	aa1503e1 	mov	x1, x21
   83ca8:	aa1303e0 	mov	x0, x19
   83cac:	94003395 	bl	90b00 <__ssprint_r>
   83cb0:	35fff000 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   83cb4:	51004318 	sub	w24, w24, #0x10
   83cb8:	b9416be1 	ldr	w1, [sp, #360]
   83cbc:	f940bbe0 	ldr	x0, [sp, #368]
   83cc0:	aa1603fc 	mov	x28, x22
   83cc4:	7100431f 	cmp	w24, #0x10
   83cc8:	54fffdcc 	b.gt	83c80 <_svfprintf_r+0xac0>
   83ccc:	b94093eb 	ldr	w11, [sp, #144]
   83cd0:	aa1903ed 	mov	x13, x25
   83cd4:	b9409fe3 	ldr	w3, [sp, #156]
   83cd8:	aa1a03f9 	mov	x25, x26
   83cdc:	2a1803fa 	mov	w26, w24
   83ce0:	93407f5a 	sxtw	x26, w26
   83ce4:	11000421 	add	w1, w1, #0x1
   83ce8:	8b1a0000 	add	x0, x0, x26
   83cec:	a9006b8d 	stp	x13, x26, [x28]
   83cf0:	b9016be1 	str	w1, [sp, #360]
   83cf4:	f900bbe0 	str	x0, [sp, #368]
   83cf8:	71001c3f 	cmp	w1, #0x7
   83cfc:	54ffbd2d 	b.le	834a0 <_svfprintf_r+0x2e0>
   83d00:	910583e2 	add	x2, sp, #0x160
   83d04:	aa1503e1 	mov	x1, x21
   83d08:	aa1303e0 	mov	x0, x19
   83d0c:	b90093eb 	str	w11, [sp, #144]
   83d10:	b9009fe3 	str	w3, [sp, #156]
   83d14:	9400337b 	bl	90b00 <__ssprint_r>
   83d18:	35ffecc0 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   83d1c:	f940bbe0 	ldr	x0, [sp, #368]
   83d20:	b94093eb 	ldr	w11, [sp, #144]
   83d24:	b9409fe3 	ldr	w3, [sp, #156]
   83d28:	17fffdde 	b	834a0 <_svfprintf_r+0x2e0>
   83d2c:	b940ffe0 	ldr	w0, [sp, #252]
   83d30:	2a1703e9 	mov	w9, w23
   83d34:	2a1803eb 	mov	w11, w24
   83d38:	2a1a03e7 	mov	w7, w26
   83d3c:	36184929 	tbz	w9, #3, 84660 <_svfprintf_r+0x14a0>
   83d40:	37f8b8c0 	tbnz	w0, #31, 85458 <_svfprintf_r+0x2298>
   83d44:	f94043e0 	ldr	x0, [sp, #128]
   83d48:	91003c00 	add	x0, x0, #0xf
   83d4c:	927cec00 	and	x0, x0, #0xfffffffffffffff0
   83d50:	91004001 	add	x1, x0, #0x10
   83d54:	f90043e1 	str	x1, [sp, #128]
   83d58:	3dc00000 	ldr	q0, [x0]
   83d5c:	b90093e8 	str	w8, [sp, #144]
   83d60:	2913afe9 	stp	w9, w11, [sp, #156]
   83d64:	b900d3e7 	str	w7, [sp, #208]
   83d68:	94004306 	bl	94980 <__trunctfdf2>
   83d6c:	b94093e8 	ldr	w8, [sp, #144]
   83d70:	1e604008 	fmov	d8, d0
   83d74:	2953afe9 	ldp	w9, w11, [sp, #156]
   83d78:	b940d3e7 	ldr	w7, [sp, #208]
   83d7c:	1e60c100 	fabs	d0, d8
   83d80:	92f00200 	mov	x0, #0x7fefffffffffffff    	// #9218868437227405311
   83d84:	9e670001 	fmov	d1, x0
   83d88:	1e612000 	fcmp	d0, d1
   83d8c:	5400798d 	b.le	84cbc <_svfprintf_r+0x1afc>
   83d90:	1e602118 	fcmpe	d8, #0.0
   83d94:	5400b964 	b.mi	854c0 <_svfprintf_r+0x2300>  // b.first
   83d98:	3944bfe1 	ldrb	w1, [sp, #303]
   83d9c:	d0000080 	adrp	x0, 95000 <pmu_event_descr+0x60>
   83da0:	d0000085 	adrp	x5, 95000 <pmu_event_descr+0x60>
   83da4:	7101211f 	cmp	w8, #0x48
   83da8:	91174000 	add	x0, x0, #0x5d0
   83dac:	911720a5 	add	x5, x5, #0x5c8
   83db0:	b90093ff 	str	wzr, [sp, #144]
   83db4:	52800063 	mov	w3, #0x3                   	// #3
   83db8:	2913ffff 	stp	wzr, wzr, [sp, #156]
   83dbc:	12187929 	and	w9, w9, #0xffffff7f
   83dc0:	9a80b0b8 	csel	x24, x5, x0, lt	// lt = tstop
   83dc4:	2a0303fb 	mov	w27, w3
   83dc8:	d2800017 	mov	x23, #0x0                   	// #0
   83dcc:	52800007 	mov	w7, #0x0                   	// #0
   83dd0:	34ffaf81 	cbz	w1, 833c0 <_svfprintf_r+0x200>
   83dd4:	d503201f 	nop
   83dd8:	11000463 	add	w3, w3, #0x1
   83ddc:	17fffd79 	b	833c0 <_svfprintf_r+0x200>
   83de0:	b9413be2 	ldr	w2, [sp, #312]
   83de4:	7100005f 	cmp	w2, #0x0
   83de8:	54ffd4ad 	b.le	8387c <_svfprintf_r+0x6bc>
   83dec:	b940cbe1 	ldr	w1, [sp, #200]
   83df0:	b94093e2 	ldr	w2, [sp, #144]
   83df4:	6b01005f 	cmp	w2, w1
   83df8:	8b21c304 	add	x4, x24, w1, sxtw
   83dfc:	1a81d05b 	csel	w27, w2, w1, le
   83e00:	f9006be4 	str	x4, [sp, #208]
   83e04:	7100037f 	cmp	w27, #0x0
   83e08:	5400016d 	b.le	83e34 <_svfprintf_r+0xc74>
   83e0c:	b9416be1 	ldr	w1, [sp, #360]
   83e10:	93407f62 	sxtw	x2, w27
   83e14:	8b020000 	add	x0, x0, x2
   83e18:	a9000b98 	stp	x24, x2, [x28]
   83e1c:	11000421 	add	w1, w1, #0x1
   83e20:	b9016be1 	str	w1, [sp, #360]
   83e24:	9100439c 	add	x28, x28, #0x10
   83e28:	f900bbe0 	str	x0, [sp, #368]
   83e2c:	71001c3f 	cmp	w1, #0x7
   83e30:	5400b90c 	b.gt	85550 <_svfprintf_r+0x2390>
   83e34:	7100037f 	cmp	w27, #0x0
   83e38:	b94093e1 	ldr	w1, [sp, #144]
   83e3c:	1a9fa364 	csel	w4, w27, wzr, ge	// ge = tcont
   83e40:	4b04003b 	sub	w27, w1, w4
   83e44:	7100037f 	cmp	w27, #0x0
   83e48:	5400518c 	b.gt	84878 <_svfprintf_r+0x16b8>
   83e4c:	b94093e1 	ldr	w1, [sp, #144]
   83e50:	8b21c318 	add	x24, x24, w1, sxtw
   83e54:	375059e9 	tbnz	w9, #10, 84990 <_svfprintf_r+0x17d0>
   83e58:	b940cbe1 	ldr	w1, [sp, #200]
   83e5c:	b9413bfa 	ldr	w26, [sp, #312]
   83e60:	6b01035f 	cmp	w26, w1
   83e64:	5400004b 	b.lt	83e6c <_svfprintf_r+0xcac>  // b.tstop
   83e68:	3600bc29 	tbz	w9, #0, 855ec <_svfprintf_r+0x242c>
   83e6c:	a94b13e2 	ldp	x2, x4, [sp, #176]
   83e70:	a9000b84 	stp	x4, x2, [x28]
   83e74:	b9416be1 	ldr	w1, [sp, #360]
   83e78:	9100439c 	add	x28, x28, #0x10
   83e7c:	11000421 	add	w1, w1, #0x1
   83e80:	b9016be1 	str	w1, [sp, #360]
   83e84:	8b020000 	add	x0, x0, x2
   83e88:	f900bbe0 	str	x0, [sp, #368]
   83e8c:	71001c3f 	cmp	w1, #0x7
   83e90:	5400d96c 	b.gt	859bc <_svfprintf_r+0x27fc>
   83e94:	b940cbe1 	ldr	w1, [sp, #200]
   83e98:	4b1a003a 	sub	w26, w1, w26
   83e9c:	f9406be1 	ldr	x1, [sp, #208]
   83ea0:	cb18003b 	sub	x27, x1, x24
   83ea4:	6b1b035f 	cmp	w26, w27
   83ea8:	1a9bb35b 	csel	w27, w26, w27, lt	// lt = tstop
   83eac:	7100037f 	cmp	w27, #0x0
   83eb0:	5400016d 	b.le	83edc <_svfprintf_r+0xd1c>
   83eb4:	b9416be1 	ldr	w1, [sp, #360]
   83eb8:	93407f62 	sxtw	x2, w27
   83ebc:	8b020000 	add	x0, x0, x2
   83ec0:	a9000b98 	stp	x24, x2, [x28]
   83ec4:	11000421 	add	w1, w1, #0x1
   83ec8:	b9016be1 	str	w1, [sp, #360]
   83ecc:	9100439c 	add	x28, x28, #0x10
   83ed0:	f900bbe0 	str	x0, [sp, #368]
   83ed4:	71001c3f 	cmp	w1, #0x7
   83ed8:	5400dd4c 	b.gt	85a80 <_svfprintf_r+0x28c0>
   83edc:	7100037f 	cmp	w27, #0x0
   83ee0:	1a9fa37b 	csel	w27, w27, wzr, ge	// ge = tcont
   83ee4:	4b1b035a 	sub	w26, w26, w27
   83ee8:	7100035f 	cmp	w26, #0x0
   83eec:	54ffad2d 	b.le	83490 <_svfprintf_r+0x2d0>
   83ef0:	d0000084 	adrp	x4, 95000 <pmu_event_descr+0x60>
   83ef4:	b9416be1 	ldr	w1, [sp, #360]
   83ef8:	911b8084 	add	x4, x4, #0x6e0
   83efc:	7100435f 	cmp	w26, #0x10
   83f00:	540084ed 	b.le	84f9c <_svfprintf_r+0x1ddc>
   83f04:	2a1a03e5 	mov	w5, w26
   83f08:	aa1c03e2 	mov	x2, x28
   83f0c:	aa1703fa 	mov	x26, x23
   83f10:	aa1903fc 	mov	x28, x25
   83f14:	aa0403f8 	mov	x24, x4
   83f18:	2a0303f9 	mov	w25, w3
   83f1c:	2a0503f7 	mov	w23, w5
   83f20:	d280021b 	mov	x27, #0x10                  	// #16
   83f24:	b90093e9 	str	w9, [sp, #144]
   83f28:	b9009feb 	str	w11, [sp, #156]
   83f2c:	14000004 	b	83f3c <_svfprintf_r+0xd7c>
   83f30:	510042f7 	sub	w23, w23, #0x10
   83f34:	710042ff 	cmp	w23, #0x10
   83f38:	5400d86d 	b.le	85a44 <_svfprintf_r+0x2884>
   83f3c:	91004000 	add	x0, x0, #0x10
   83f40:	11000421 	add	w1, w1, #0x1
   83f44:	a9006c58 	stp	x24, x27, [x2]
   83f48:	91004042 	add	x2, x2, #0x10
   83f4c:	b9016be1 	str	w1, [sp, #360]
   83f50:	f900bbe0 	str	x0, [sp, #368]
   83f54:	71001c3f 	cmp	w1, #0x7
   83f58:	54fffecd 	b.le	83f30 <_svfprintf_r+0xd70>
   83f5c:	910583e2 	add	x2, sp, #0x160
   83f60:	aa1503e1 	mov	x1, x21
   83f64:	aa1303e0 	mov	x0, x19
   83f68:	940032e6 	bl	90b00 <__ssprint_r>
   83f6c:	35010140 	cbnz	w0, 85f94 <_svfprintf_r+0x2dd4>
   83f70:	f940bbe0 	ldr	x0, [sp, #368]
   83f74:	aa1603e2 	mov	x2, x22
   83f78:	b9416be1 	ldr	w1, [sp, #360]
   83f7c:	17ffffed 	b	83f30 <_svfprintf_r+0xd70>
   83f80:	3707dc89 	tbnz	w9, #0, 83b10 <_svfprintf_r+0x950>
   83f84:	d2800022 	mov	x2, #0x1                   	// #1
   83f88:	a9000b98 	stp	x24, x2, [x28]
   83f8c:	b9016be1 	str	w1, [sp, #360]
   83f90:	f900bbe0 	str	x0, [sp, #368]
   83f94:	71001c3f 	cmp	w1, #0x7
   83f98:	54ffdf8d 	b.le	83b88 <_svfprintf_r+0x9c8>
   83f9c:	910583e2 	add	x2, sp, #0x160
   83fa0:	aa1503e1 	mov	x1, x21
   83fa4:	aa1303e0 	mov	x0, x19
   83fa8:	b90093e9 	str	w9, [sp, #144]
   83fac:	29138feb 	stp	w11, w3, [sp, #156]
   83fb0:	940032d4 	bl	90b00 <__ssprint_r>
   83fb4:	35ffd7e0 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   83fb8:	f940bbe0 	ldr	x0, [sp, #368]
   83fbc:	aa1603e7 	mov	x7, x22
   83fc0:	b94093e9 	ldr	w9, [sp, #144]
   83fc4:	29538feb 	ldp	w11, w3, [sp, #156]
   83fc8:	b9416be1 	ldr	w1, [sp, #360]
   83fcc:	17fffeef 	b	83b88 <_svfprintf_r+0x9c8>
   83fd0:	b940cbe2 	ldr	w2, [sp, #200]
   83fd4:	7100045f 	cmp	w2, #0x1
   83fd8:	54ffdd8d 	b.le	83b88 <_svfprintf_r+0x9c8>
   83fdc:	d0000084 	adrp	x4, 95000 <pmu_event_descr+0x60>
   83fe0:	911b8084 	add	x4, x4, #0x6e0
   83fe4:	7100445f 	cmp	w2, #0x11
   83fe8:	54003c4d 	b.le	84770 <_svfprintf_r+0x15b0>
   83fec:	2a1a03f8 	mov	w24, w26
   83ff0:	2a0b03fc 	mov	w28, w11
   83ff4:	aa1903fa 	mov	x26, x25
   83ff8:	d280021b 	mov	x27, #0x10                  	// #16
   83ffc:	aa0403f9 	mov	x25, x4
   84000:	b90093e9 	str	w9, [sp, #144]
   84004:	b9009fe3 	str	w3, [sp, #156]
   84008:	14000004 	b	84018 <_svfprintf_r+0xe58>
   8400c:	51004318 	sub	w24, w24, #0x10
   84010:	7100431f 	cmp	w24, #0x10
   84014:	54003a2d 	b.le	84758 <_svfprintf_r+0x1598>
   84018:	91004000 	add	x0, x0, #0x10
   8401c:	11000421 	add	w1, w1, #0x1
   84020:	a9006cf9 	stp	x25, x27, [x7]
   84024:	910040e7 	add	x7, x7, #0x10
   84028:	b9016be1 	str	w1, [sp, #360]
   8402c:	f900bbe0 	str	x0, [sp, #368]
   84030:	71001c3f 	cmp	w1, #0x7
   84034:	54fffecd 	b.le	8400c <_svfprintf_r+0xe4c>
   84038:	910583e2 	add	x2, sp, #0x160
   8403c:	aa1503e1 	mov	x1, x21
   84040:	aa1303e0 	mov	x0, x19
   84044:	940032af 	bl	90b00 <__ssprint_r>
   84048:	35ffd340 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   8404c:	f940bbe0 	ldr	x0, [sp, #368]
   84050:	aa1603e7 	mov	x7, x22
   84054:	b9416be1 	ldr	w1, [sp, #360]
   84058:	17ffffed 	b	8400c <_svfprintf_r+0xe4c>
   8405c:	910583e2 	add	x2, sp, #0x160
   84060:	aa1503e1 	mov	x1, x21
   84064:	aa1303e0 	mov	x0, x19
   84068:	b90093e9 	str	w9, [sp, #144]
   8406c:	29138feb 	stp	w11, w3, [sp, #156]
   84070:	940032a4 	bl	90b00 <__ssprint_r>
   84074:	35ffd1e0 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   84078:	1e602108 	fcmp	d8, #0.0
   8407c:	b940cbe2 	ldr	w2, [sp, #200]
   84080:	f940bbe0 	ldr	x0, [sp, #368]
   84084:	aa1603e7 	mov	x7, x22
   84088:	b94093e9 	ldr	w9, [sp, #144]
   8408c:	5100045a 	sub	w26, w2, #0x1
   84090:	29538feb 	ldp	w11, w3, [sp, #156]
   84094:	b9416be1 	ldr	w1, [sp, #360]
   84098:	54fff9c0 	b.eq	83fd0 <_svfprintf_r+0xe10>  // b.none
   8409c:	17fffeb0 	b	83b5c <_svfprintf_r+0x99c>
   840a0:	910583e2 	add	x2, sp, #0x160
   840a4:	aa1503e1 	mov	x1, x21
   840a8:	aa1303e0 	mov	x0, x19
   840ac:	b90093e9 	str	w9, [sp, #144]
   840b0:	29138feb 	stp	w11, w3, [sp, #156]
   840b4:	94003293 	bl	90b00 <__ssprint_r>
   840b8:	35ffcfc0 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   840bc:	f940bbe0 	ldr	x0, [sp, #368]
   840c0:	aa1603e7 	mov	x7, x22
   840c4:	b94093e9 	ldr	w9, [sp, #144]
   840c8:	29538feb 	ldp	w11, w3, [sp, #156]
   840cc:	b9416be1 	ldr	w1, [sp, #360]
   840d0:	17fffe96 	b	83b28 <_svfprintf_r+0x968>
   840d4:	b9409be0 	ldr	w0, [sp, #152]
   840d8:	2a1703e9 	mov	w9, w23
   840dc:	2a1803eb 	mov	w11, w24
   840e0:	2a1a03e7 	mov	w7, w26
   840e4:	37f82fa0 	tbnz	w0, #31, 846d8 <_svfprintf_r+0x1518>
   840e8:	f94043e0 	ldr	x0, [sp, #128]
   840ec:	91003c01 	add	x1, x0, #0xf
   840f0:	927df021 	and	x1, x1, #0xfffffffffffffff8
   840f4:	f90043e1 	str	x1, [sp, #128]
   840f8:	f9400018 	ldr	x24, [x0]
   840fc:	3904bfff 	strb	wzr, [sp, #303]
   84100:	b4007cb8 	cbz	x24, 85094 <_svfprintf_r+0x1ed4>
   84104:	71014d1f 	cmp	w8, #0x53
   84108:	54006a60 	b.eq	84e54 <_svfprintf_r+0x1c94>  // b.none
   8410c:	121c0120 	and	w0, w9, #0x10
   84110:	b90093e0 	str	w0, [sp, #144]
   84114:	37206a09 	tbnz	w9, #4, 84e54 <_svfprintf_r+0x1c94>
   84118:	310004ff 	cmn	w7, #0x1
   8411c:	5400ace0 	b.eq	856b8 <_svfprintf_r+0x24f8>  // b.none
   84120:	93407ce2 	sxtw	x2, w7
   84124:	aa1803e0 	mov	x0, x24
   84128:	52800001 	mov	w1, #0x0                   	// #0
   8412c:	2913a7e7 	stp	w7, w9, [sp, #156]
   84130:	b900d3eb 	str	w11, [sp, #208]
   84134:	94002323 	bl	8cdc0 <memchr>
   84138:	2953a7e7 	ldp	w7, w9, [sp, #156]
   8413c:	aa0003f7 	mov	x23, x0
   84140:	b940d3eb 	ldr	w11, [sp, #208]
   84144:	b400ed60 	cbz	x0, 85ef0 <_svfprintf_r+0x2d30>
   84148:	3944bfe1 	ldrb	w1, [sp, #303]
   8414c:	cb180003 	sub	x3, x0, x24
   84150:	2913ffff 	stp	wzr, wzr, [sp, #156]
   84154:	7100007f 	cmp	w3, #0x0
   84158:	2a0303fb 	mov	w27, w3
   8415c:	52800007 	mov	w7, #0x0                   	// #0
   84160:	1a9fa063 	csel	w3, w3, wzr, ge	// ge = tcont
   84164:	d2800017 	mov	x23, #0x0                   	// #0
   84168:	52800e68 	mov	w8, #0x73                  	// #115
   8416c:	34ff92a1 	cbz	w1, 833c0 <_svfprintf_r+0x200>
   84170:	17ffff1a 	b	83dd8 <_svfprintf_r+0xc18>
   84174:	2a1703e9 	mov	w9, w23
   84178:	2a1803eb 	mov	w11, w24
   8417c:	71010d1f 	cmp	w8, #0x43
   84180:	54000040 	b.eq	84188 <_svfprintf_r+0xfc8>  // b.none
   84184:	36202d29 	tbz	w9, #4, 84728 <_svfprintf_r+0x1568>
   84188:	910563e0 	add	x0, sp, #0x158
   8418c:	d2800102 	mov	x2, #0x8                   	// #8
   84190:	52800001 	mov	w1, #0x0                   	// #0
   84194:	b90093e8 	str	w8, [sp, #144]
   84198:	2913afe9 	stp	w9, w11, [sp, #156]
   8419c:	94002509 	bl	8d5c0 <memset>
   841a0:	295327e0 	ldp	w0, w9, [sp, #152]
   841a4:	b94093e8 	ldr	w8, [sp, #144]
   841a8:	b940a3eb 	ldr	w11, [sp, #160]
   841ac:	37f87fa0 	tbnz	w0, #31, 851a0 <_svfprintf_r+0x1fe0>
   841b0:	f94043e0 	ldr	x0, [sp, #128]
   841b4:	91002c01 	add	x1, x0, #0xb
   841b8:	927df021 	and	x1, x1, #0xfffffffffffffff8
   841bc:	f90043e1 	str	x1, [sp, #128]
   841c0:	b9400002 	ldr	w2, [x0]
   841c4:	9105e3f7 	add	x23, sp, #0x178
   841c8:	910563e3 	add	x3, sp, #0x158
   841cc:	aa1703e1 	mov	x1, x23
   841d0:	aa1303e0 	mov	x0, x19
   841d4:	b90093e8 	str	w8, [sp, #144]
   841d8:	2913afe9 	stp	w9, w11, [sp, #156]
   841dc:	94001ef5 	bl	8bdb0 <_wcrtomb_r>
   841e0:	2a0003fb 	mov	w27, w0
   841e4:	b94093e8 	ldr	w8, [sp, #144]
   841e8:	3100041f 	cmn	w0, #0x1
   841ec:	2953afe9 	ldp	w9, w11, [sp, #156]
   841f0:	5400d540 	b.eq	85c98 <_svfprintf_r+0x2ad8>  // b.none
   841f4:	7100001f 	cmp	w0, #0x0
   841f8:	1a9fa003 	csel	w3, w0, wzr, ge	// ge = tcont
   841fc:	aa1703f8 	mov	x24, x23
   84200:	52800001 	mov	w1, #0x0                   	// #0
   84204:	d2800017 	mov	x23, #0x0                   	// #0
   84208:	52800007 	mov	w7, #0x0                   	// #0
   8420c:	b90093ff 	str	wzr, [sp, #144]
   84210:	2913ffff 	stp	wzr, wzr, [sp, #156]
   84214:	3904bfff 	strb	wzr, [sp, #303]
   84218:	17fffc6a 	b	833c0 <_svfprintf_r+0x200>
   8421c:	4b1803f8 	neg	w24, w24
   84220:	f90043e0 	str	x0, [sp, #128]
   84224:	39400328 	ldrb	w8, [x25]
   84228:	321e02f7 	orr	w23, w23, #0x4
   8422c:	17fffc4f 	b	83368 <_svfprintf_r+0x1a8>
   84230:	2a1a03e7 	mov	w7, w26
   84234:	2a1803eb 	mov	w11, w24
   84238:	321c02fa 	orr	w26, w23, #0x10
   8423c:	b9409be0 	ldr	w0, [sp, #152]
   84240:	3728005a 	tbnz	w26, #5, 84248 <_svfprintf_r+0x1088>
   84244:	36201fda 	tbz	w26, #4, 8463c <_svfprintf_r+0x147c>
   84248:	37f848a0 	tbnz	w0, #31, 84b5c <_svfprintf_r+0x199c>
   8424c:	f94043e0 	ldr	x0, [sp, #128]
   84250:	91003c01 	add	x1, x0, #0xf
   84254:	927df021 	and	x1, x1, #0xfffffffffffffff8
   84258:	f90043e1 	str	x1, [sp, #128]
   8425c:	f9400000 	ldr	x0, [x0]
   84260:	52800021 	mov	w1, #0x1                   	// #1
   84264:	52800002 	mov	w2, #0x0                   	// #0
   84268:	3904bfe2 	strb	w2, [sp, #303]
   8426c:	310004ff 	cmn	w7, #0x1
   84270:	540016e0 	b.eq	8454c <_svfprintf_r+0x138c>  // b.none
   84274:	f100001f 	cmp	x0, #0x0
   84278:	12187b49 	and	w9, w26, #0xffffff7f
   8427c:	7a4008e0 	ccmp	w7, #0x0, #0x0, eq	// eq = none
   84280:	54001641 	b.ne	84548 <_svfprintf_r+0x1388>  // b.any
   84284:	35000461 	cbnz	w1, 84310 <_svfprintf_r+0x1150>
   84288:	1200035b 	and	w27, w26, #0x1
   8428c:	36001b3a 	tbz	w26, #0, 845f0 <_svfprintf_r+0x1430>
   84290:	91076ff8 	add	x24, sp, #0x1db
   84294:	52800600 	mov	w0, #0x30                  	// #48
   84298:	52800007 	mov	w7, #0x0                   	// #0
   8429c:	39076fe0 	strb	w0, [sp, #475]
   842a0:	3944bfe1 	ldrb	w1, [sp, #303]
   842a4:	6b1b00ff 	cmp	w7, w27
   842a8:	b90093ff 	str	wzr, [sp, #144]
   842ac:	1a9ba0e3 	csel	w3, w7, w27, ge	// ge = tcont
   842b0:	2913ffff 	stp	wzr, wzr, [sp, #156]
   842b4:	d2800017 	mov	x23, #0x0                   	// #0
   842b8:	34ff8841 	cbz	w1, 833c0 <_svfprintf_r+0x200>
   842bc:	17fffec7 	b	83dd8 <_svfprintf_r+0xc18>
   842c0:	2a1803eb 	mov	w11, w24
   842c4:	2a1a03e7 	mov	w7, w26
   842c8:	321c02e9 	orr	w9, w23, #0x10
   842cc:	b9409be0 	ldr	w0, [sp, #152]
   842d0:	37280049 	tbnz	w9, #5, 842d8 <_svfprintf_r+0x1118>
   842d4:	36201a29 	tbz	w9, #4, 84618 <_svfprintf_r+0x1458>
   842d8:	37f842e0 	tbnz	w0, #31, 84b34 <_svfprintf_r+0x1974>
   842dc:	f94043e0 	ldr	x0, [sp, #128]
   842e0:	91003c01 	add	x1, x0, #0xf
   842e4:	927df021 	and	x1, x1, #0xfffffffffffffff8
   842e8:	f90043e1 	str	x1, [sp, #128]
   842ec:	f9400001 	ldr	x1, [x0]
   842f0:	aa0103e0 	mov	x0, x1
   842f4:	b7f81841 	tbnz	x1, #63, 845fc <_svfprintf_r+0x143c>
   842f8:	310004ff 	cmn	w7, #0x1
   842fc:	54001680 	b.eq	845cc <_svfprintf_r+0x140c>  // b.none
   84300:	710000ff 	cmp	w7, #0x0
   84304:	12187929 	and	w9, w9, #0xffffff7f
   84308:	fa400800 	ccmp	x0, #0x0, #0x0, eq	// eq = none
   8430c:	54001601 	b.ne	845cc <_svfprintf_r+0x140c>  // b.any
   84310:	910773f8 	add	x24, sp, #0x1dc
   84314:	52800007 	mov	w7, #0x0                   	// #0
   84318:	5280001b 	mov	w27, #0x0                   	// #0
   8431c:	17ffffe1 	b	842a0 <_svfprintf_r+0x10e0>
   84320:	2a1803eb 	mov	w11, w24
   84324:	2a1a03e7 	mov	w7, w26
   84328:	321c02e9 	orr	w9, w23, #0x10
   8432c:	b9409be0 	ldr	w0, [sp, #152]
   84330:	37280049 	tbnz	w9, #5, 84338 <_svfprintf_r+0x1178>
   84334:	36201a89 	tbz	w9, #4, 84684 <_svfprintf_r+0x14c4>
   84338:	37f83ea0 	tbnz	w0, #31, 84b0c <_svfprintf_r+0x194c>
   8433c:	f94043e0 	ldr	x0, [sp, #128]
   84340:	91003c01 	add	x1, x0, #0xf
   84344:	927df021 	and	x1, x1, #0xfffffffffffffff8
   84348:	f90043e1 	str	x1, [sp, #128]
   8434c:	f9400000 	ldr	x0, [x0]
   84350:	1215793a 	and	w26, w9, #0xfffffbff
   84354:	52800001 	mov	w1, #0x0                   	// #0
   84358:	17ffffc3 	b	84264 <_svfprintf_r+0x10a4>
   8435c:	39400328 	ldrb	w8, [x25]
   84360:	321d02f7 	orr	w23, w23, #0x8
   84364:	17fffc01 	b	83368 <_svfprintf_r+0x1a8>
   84368:	39400328 	ldrb	w8, [x25]
   8436c:	321b02f7 	orr	w23, w23, #0x20
   84370:	17fffbfe 	b	83368 <_svfprintf_r+0x1a8>
   84374:	b9409be0 	ldr	w0, [sp, #152]
   84378:	2a1703e9 	mov	w9, w23
   8437c:	2a1803eb 	mov	w11, w24
   84380:	2a1a03e7 	mov	w7, w26
   84384:	37f81be0 	tbnz	w0, #31, 84700 <_svfprintf_r+0x1540>
   84388:	f94043e0 	ldr	x0, [sp, #128]
   8438c:	91003c01 	add	x1, x0, #0xf
   84390:	927df021 	and	x1, x1, #0xfffffffffffffff8
   84394:	f90043e1 	str	x1, [sp, #128]
   84398:	f9400000 	ldr	x0, [x0]
   8439c:	528f0602 	mov	w2, #0x7830                	// #30768
   843a0:	b0000083 	adrp	x3, 95000 <pmu_event_descr+0x60>
   843a4:	321f013a 	orr	w26, w9, #0x2
   843a8:	9117a063 	add	x3, x3, #0x5e8
   843ac:	52800041 	mov	w1, #0x2                   	// #2
   843b0:	52800f08 	mov	w8, #0x78                  	// #120
   843b4:	f90063e3 	str	x3, [sp, #192]
   843b8:	790263e2 	strh	w2, [sp, #304]
   843bc:	17ffffaa 	b	84264 <_svfprintf_r+0x10a4>
   843c0:	b9409be0 	ldr	w0, [sp, #152]
   843c4:	2a1703e9 	mov	w9, w23
   843c8:	372801a9 	tbnz	w9, #5, 843fc <_svfprintf_r+0x123c>
   843cc:	37200189 	tbnz	w9, #4, 843fc <_svfprintf_r+0x123c>
   843d0:	373092c9 	tbnz	w9, #6, 85628 <_svfprintf_r+0x2468>
   843d4:	3648cc49 	tbz	w9, #9, 85d5c <_svfprintf_r+0x2b9c>
   843d8:	37f8e6c0 	tbnz	w0, #31, 860b0 <_svfprintf_r+0x2ef0>
   843dc:	f94043e0 	ldr	x0, [sp, #128]
   843e0:	91003c01 	add	x1, x0, #0xf
   843e4:	927df021 	and	x1, x1, #0xfffffffffffffff8
   843e8:	f90043e1 	str	x1, [sp, #128]
   843ec:	f9400000 	ldr	x0, [x0]
   843f0:	3941e3e1 	ldrb	w1, [sp, #120]
   843f4:	39000001 	strb	w1, [x0]
   843f8:	17fffba6 	b	83290 <_svfprintf_r+0xd0>
   843fc:	37f822a0 	tbnz	w0, #31, 84850 <_svfprintf_r+0x1690>
   84400:	f94043e0 	ldr	x0, [sp, #128]
   84404:	91003c01 	add	x1, x0, #0xf
   84408:	927df021 	and	x1, x1, #0xfffffffffffffff8
   8440c:	f90043e1 	str	x1, [sp, #128]
   84410:	f9400000 	ldr	x0, [x0]
   84414:	b9807be1 	ldrsw	x1, [sp, #120]
   84418:	f9000001 	str	x1, [x0]
   8441c:	17fffb9d 	b	83290 <_svfprintf_r+0xd0>
   84420:	39400328 	ldrb	w8, [x25]
   84424:	7101b11f 	cmp	w8, #0x6c
   84428:	54001f00 	b.eq	84808 <_svfprintf_r+0x1648>  // b.none
   8442c:	321c02f7 	orr	w23, w23, #0x10
   84430:	17fffbce 	b	83368 <_svfprintf_r+0x1a8>
   84434:	39400328 	ldrb	w8, [x25]
   84438:	7101a11f 	cmp	w8, #0x68
   8443c:	54001de0 	b.eq	847f8 <_svfprintf_r+0x1638>  // b.none
   84440:	321a02f7 	orr	w23, w23, #0x40
   84444:	17fffbc9 	b	83368 <_svfprintf_r+0x1a8>
   84448:	52800560 	mov	w0, #0x2b                  	// #43
   8444c:	39400328 	ldrb	w8, [x25]
   84450:	3904bfe0 	strb	w0, [sp, #303]
   84454:	17fffbc5 	b	83368 <_svfprintf_r+0x1a8>
   84458:	39400328 	ldrb	w8, [x25]
   8445c:	321902f7 	orr	w23, w23, #0x80
   84460:	17fffbc2 	b	83368 <_svfprintf_r+0x1a8>
   84464:	aa1903e1 	mov	x1, x25
   84468:	38401428 	ldrb	w8, [x1], #1
   8446c:	7100a91f 	cmp	w8, #0x2a
   84470:	5400eb40 	b.eq	861d8 <_svfprintf_r+0x3018>  // b.none
   84474:	5100c100 	sub	w0, w8, #0x30
   84478:	aa0103f9 	mov	x25, x1
   8447c:	5280001a 	mov	w26, #0x0                   	// #0
   84480:	7100241f 	cmp	w0, #0x9
   84484:	54ff7748 	b.hi	8336c <_svfprintf_r+0x1ac>  // b.pmore
   84488:	38401728 	ldrb	w8, [x25], #1
   8448c:	0b1a0b47 	add	w7, w26, w26, lsl #2
   84490:	0b07041a 	add	w26, w0, w7, lsl #1
   84494:	5100c100 	sub	w0, w8, #0x30
   84498:	7100241f 	cmp	w0, #0x9
   8449c:	54ffff69 	b.ls	84488 <_svfprintf_r+0x12c8>  // b.plast
   844a0:	17fffbb3 	b	8336c <_svfprintf_r+0x1ac>
   844a4:	b9409be0 	ldr	w0, [sp, #152]
   844a8:	37f81060 	tbnz	w0, #31, 846b4 <_svfprintf_r+0x14f4>
   844ac:	f94043e0 	ldr	x0, [sp, #128]
   844b0:	91002c00 	add	x0, x0, #0xb
   844b4:	927df000 	and	x0, x0, #0xfffffffffffffff8
   844b8:	f94043e1 	ldr	x1, [sp, #128]
   844bc:	b9400038 	ldr	w24, [x1]
   844c0:	37ffeaf8 	tbnz	w24, #31, 8421c <_svfprintf_r+0x105c>
   844c4:	39400328 	ldrb	w8, [x25]
   844c8:	f90043e0 	str	x0, [sp, #128]
   844cc:	17fffba7 	b	83368 <_svfprintf_r+0x1a8>
   844d0:	aa1303e0 	mov	x0, x19
   844d4:	940021df 	bl	8cc50 <_localeconv_r>
   844d8:	f9400400 	ldr	x0, [x0, #8]
   844dc:	f90077e0 	str	x0, [sp, #232]
   844e0:	97fff928 	bl	82980 <strlen>
   844e4:	aa0003e1 	mov	x1, x0
   844e8:	aa0103fb 	mov	x27, x1
   844ec:	aa1303e0 	mov	x0, x19
   844f0:	f90083e1 	str	x1, [sp, #256]
   844f4:	940021d7 	bl	8cc50 <_localeconv_r>
   844f8:	f9400800 	ldr	x0, [x0, #16]
   844fc:	f9007be0 	str	x0, [sp, #240]
   84500:	f100037f 	cmp	x27, #0x0
   84504:	fa401804 	ccmp	x0, #0x0, #0x4, ne	// ne = any
   84508:	54000ba0 	b.eq	8467c <_svfprintf_r+0x14bc>  // b.none
   8450c:	39400001 	ldrb	w1, [x0]
   84510:	321602e0 	orr	w0, w23, #0x400
   84514:	39400328 	ldrb	w8, [x25]
   84518:	7100003f 	cmp	w1, #0x0
   8451c:	1a971017 	csel	w23, w0, w23, ne	// ne = any
   84520:	17fffb92 	b	83368 <_svfprintf_r+0x1a8>
   84524:	39400328 	ldrb	w8, [x25]
   84528:	320002f7 	orr	w23, w23, #0x1
   8452c:	17fffb8f 	b	83368 <_svfprintf_r+0x1a8>
   84530:	3944bfe0 	ldrb	w0, [sp, #303]
   84534:	39400328 	ldrb	w8, [x25]
   84538:	35ff7180 	cbnz	w0, 83368 <_svfprintf_r+0x1a8>
   8453c:	52800400 	mov	w0, #0x20                  	// #32
   84540:	3904bfe0 	strb	w0, [sp, #303]
   84544:	17fffb89 	b	83368 <_svfprintf_r+0x1a8>
   84548:	2a0903fa 	mov	w26, w9
   8454c:	7100043f 	cmp	w1, #0x1
   84550:	54000400 	b.eq	845d0 <_svfprintf_r+0x1410>  // b.none
   84554:	910773ec 	add	x12, sp, #0x1dc
   84558:	aa0c03f8 	mov	x24, x12
   8455c:	7100083f 	cmp	w1, #0x2
   84560:	54000141 	b.ne	84588 <_svfprintf_r+0x13c8>  // b.any
   84564:	f94063e2 	ldr	x2, [sp, #192]
   84568:	92400c01 	and	x1, x0, #0xf
   8456c:	d344fc00 	lsr	x0, x0, #4
   84570:	38616841 	ldrb	w1, [x2, x1]
   84574:	381fff01 	strb	w1, [x24, #-1]!
   84578:	b5ffff80 	cbnz	x0, 84568 <_svfprintf_r+0x13a8>
   8457c:	4b18019b 	sub	w27, w12, w24
   84580:	2a1a03e9 	mov	w9, w26
   84584:	17ffff47 	b	842a0 <_svfprintf_r+0x10e0>
   84588:	12000801 	and	w1, w0, #0x7
   8458c:	aa1803e2 	mov	x2, x24
   84590:	1100c021 	add	w1, w1, #0x30
   84594:	381fff01 	strb	w1, [x24, #-1]!
   84598:	d343fc00 	lsr	x0, x0, #3
   8459c:	b5ffff60 	cbnz	x0, 84588 <_svfprintf_r+0x13c8>
   845a0:	7100c03f 	cmp	w1, #0x30
   845a4:	1a9f07e0 	cset	w0, ne	// ne = any
   845a8:	6a00035f 	tst	w26, w0
   845ac:	54fffe80 	b.eq	8457c <_svfprintf_r+0x13bc>  // b.none
   845b0:	d1000842 	sub	x2, x2, #0x2
   845b4:	52800600 	mov	w0, #0x30                  	// #48
   845b8:	2a1a03e9 	mov	w9, w26
   845bc:	4b02019b 	sub	w27, w12, w2
   845c0:	381ff300 	sturb	w0, [x24, #-1]
   845c4:	aa0203f8 	mov	x24, x2
   845c8:	17ffff36 	b	842a0 <_svfprintf_r+0x10e0>
   845cc:	2a0903fa 	mov	w26, w9
   845d0:	f100241f 	cmp	x0, #0x9
   845d4:	54004f88 	b.hi	84fc4 <_svfprintf_r+0x1e04>  // b.pmore
   845d8:	1100c000 	add	w0, w0, #0x30
   845dc:	2a1a03e9 	mov	w9, w26
   845e0:	91076ff8 	add	x24, sp, #0x1db
   845e4:	5280003b 	mov	w27, #0x1                   	// #1
   845e8:	39076fe0 	strb	w0, [sp, #475]
   845ec:	17ffff2d 	b	842a0 <_svfprintf_r+0x10e0>
   845f0:	910773f8 	add	x24, sp, #0x1dc
   845f4:	52800007 	mov	w7, #0x0                   	// #0
   845f8:	17ffff2a 	b	842a0 <_svfprintf_r+0x10e0>
   845fc:	cb0003e0 	neg	x0, x0
   84600:	2a0903fa 	mov	w26, w9
   84604:	528005a2 	mov	w2, #0x2d                  	// #45
   84608:	52800021 	mov	w1, #0x1                   	// #1
   8460c:	17ffff17 	b	84268 <_svfprintf_r+0x10a8>
   84610:	36077409 	tbz	w9, #0, 83490 <_svfprintf_r+0x2d0>
   84614:	17fffc17 	b	83670 <_svfprintf_r+0x4b0>
   84618:	36305689 	tbz	w9, #6, 850e8 <_svfprintf_r+0x1f28>
   8461c:	37f88820 	tbnz	w0, #31, 85720 <_svfprintf_r+0x2560>
   84620:	f94043e0 	ldr	x0, [sp, #128]
   84624:	91002c01 	add	x1, x0, #0xb
   84628:	927df021 	and	x1, x1, #0xfffffffffffffff8
   8462c:	f90043e1 	str	x1, [sp, #128]
   84630:	79800000 	ldrsh	x0, [x0]
   84634:	aa0003e1 	mov	x1, x0
   84638:	17ffff2f 	b	842f4 <_svfprintf_r+0x1134>
   8463c:	36305a1a 	tbz	w26, #6, 8517c <_svfprintf_r+0x1fbc>
   84640:	37f885c0 	tbnz	w0, #31, 856f8 <_svfprintf_r+0x2538>
   84644:	f94043e0 	ldr	x0, [sp, #128]
   84648:	91002c01 	add	x1, x0, #0xb
   8464c:	927df021 	and	x1, x1, #0xfffffffffffffff8
   84650:	f90043e1 	str	x1, [sp, #128]
   84654:	79400000 	ldrh	w0, [x0]
   84658:	52800021 	mov	w1, #0x1                   	// #1
   8465c:	17ffff02 	b	84264 <_svfprintf_r+0x10a4>
   84660:	37f87380 	tbnz	w0, #31, 854d0 <_svfprintf_r+0x2310>
   84664:	f94043e0 	ldr	x0, [sp, #128]
   84668:	91003c01 	add	x1, x0, #0xf
   8466c:	fd400008 	ldr	d8, [x0]
   84670:	927df021 	and	x1, x1, #0xfffffffffffffff8
   84674:	f90043e1 	str	x1, [sp, #128]
   84678:	17fffdc1 	b	83d7c <_svfprintf_r+0xbbc>
   8467c:	39400328 	ldrb	w8, [x25]
   84680:	17fffb3a 	b	83368 <_svfprintf_r+0x1a8>
   84684:	36305a29 	tbz	w9, #6, 851c8 <_svfprintf_r+0x2008>
   84688:	37f88600 	tbnz	w0, #31, 85748 <_svfprintf_r+0x2588>
   8468c:	f94043e0 	ldr	x0, [sp, #128]
   84690:	91002c01 	add	x1, x0, #0xb
   84694:	927df021 	and	x1, x1, #0xfffffffffffffff8
   84698:	79400000 	ldrh	w0, [x0]
   8469c:	f90043e1 	str	x1, [sp, #128]
   846a0:	17ffff2c 	b	84350 <_svfprintf_r+0x1190>
   846a4:	2a1703e9 	mov	w9, w23
   846a8:	2a1803eb 	mov	w11, w24
   846ac:	2a1a03e7 	mov	w7, w26
   846b0:	17ffff07 	b	842cc <_svfprintf_r+0x110c>
   846b4:	b9409be0 	ldr	w0, [sp, #152]
   846b8:	11002001 	add	w1, w0, #0x8
   846bc:	7100003f 	cmp	w1, #0x0
   846c0:	5400942d 	b.le	85944 <_svfprintf_r+0x2784>
   846c4:	f94043e0 	ldr	x0, [sp, #128]
   846c8:	b9009be1 	str	w1, [sp, #152]
   846cc:	91002c00 	add	x0, x0, #0xb
   846d0:	927df000 	and	x0, x0, #0xfffffffffffffff8
   846d4:	17ffff79 	b	844b8 <_svfprintf_r+0x12f8>
   846d8:	b9409be0 	ldr	w0, [sp, #152]
   846dc:	11002001 	add	w1, w0, #0x8
   846e0:	7100003f 	cmp	w1, #0x0
   846e4:	5400948d 	b.le	85974 <_svfprintf_r+0x27b4>
   846e8:	f94043e0 	ldr	x0, [sp, #128]
   846ec:	b9009be1 	str	w1, [sp, #152]
   846f0:	91003c02 	add	x2, x0, #0xf
   846f4:	927df041 	and	x1, x2, #0xfffffffffffffff8
   846f8:	f90043e1 	str	x1, [sp, #128]
   846fc:	17fffe7f 	b	840f8 <_svfprintf_r+0xf38>
   84700:	b9409be0 	ldr	w0, [sp, #152]
   84704:	11002001 	add	w1, w0, #0x8
   84708:	7100003f 	cmp	w1, #0x0
   8470c:	540092ad 	b.le	85960 <_svfprintf_r+0x27a0>
   84710:	f94043e0 	ldr	x0, [sp, #128]
   84714:	b9009be1 	str	w1, [sp, #152]
   84718:	91003c02 	add	x2, x0, #0xf
   8471c:	927df041 	and	x1, x2, #0xfffffffffffffff8
   84720:	f90043e1 	str	x1, [sp, #128]
   84724:	17ffff1d 	b	84398 <_svfprintf_r+0x11d8>
   84728:	b9409be0 	ldr	w0, [sp, #152]
   8472c:	37f88f80 	tbnz	w0, #31, 8591c <_svfprintf_r+0x275c>
   84730:	f94043e0 	ldr	x0, [sp, #128]
   84734:	91002c01 	add	x1, x0, #0xb
   84738:	927df021 	and	x1, x1, #0xfffffffffffffff8
   8473c:	f90043e1 	str	x1, [sp, #128]
   84740:	b9400000 	ldr	w0, [x0]
   84744:	52800023 	mov	w3, #0x1                   	// #1
   84748:	9105e3f7 	add	x23, sp, #0x178
   8474c:	2a0303fb 	mov	w27, w3
   84750:	3905e3e0 	strb	w0, [sp, #376]
   84754:	17fffeaa 	b	841fc <_svfprintf_r+0x103c>
   84758:	b94093e9 	ldr	w9, [sp, #144]
   8475c:	aa1903e4 	mov	x4, x25
   84760:	b9409fe3 	ldr	w3, [sp, #156]
   84764:	aa1a03f9 	mov	x25, x26
   84768:	2a1c03eb 	mov	w11, w28
   8476c:	2a1803fa 	mov	w26, w24
   84770:	93407f5a 	sxtw	x26, w26
   84774:	11000421 	add	w1, w1, #0x1
   84778:	8b1a0000 	add	x0, x0, x26
   8477c:	b9016be1 	str	w1, [sp, #360]
   84780:	f900bbe0 	str	x0, [sp, #368]
   84784:	f90000e4 	str	x4, [x7]
   84788:	f90004fa 	str	x26, [x7, #8]
   8478c:	71001c3f 	cmp	w1, #0x7
   84790:	54ff9fad 	b.le	83b84 <_svfprintf_r+0x9c4>
   84794:	910583e2 	add	x2, sp, #0x160
   84798:	aa1503e1 	mov	x1, x21
   8479c:	aa1303e0 	mov	x0, x19
   847a0:	b90093e9 	str	w9, [sp, #144]
   847a4:	29138feb 	stp	w11, w3, [sp, #156]
   847a8:	940030d6 	bl	90b00 <__ssprint_r>
   847ac:	35ff9820 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   847b0:	f940bbe0 	ldr	x0, [sp, #368]
   847b4:	aa1603e7 	mov	x7, x22
   847b8:	b94093e9 	ldr	w9, [sp, #144]
   847bc:	29538feb 	ldp	w11, w3, [sp, #156]
   847c0:	b9416be1 	ldr	w1, [sp, #360]
   847c4:	17fffcf1 	b	83b88 <_svfprintf_r+0x9c8>
   847c8:	910583e2 	add	x2, sp, #0x160
   847cc:	aa1503e1 	mov	x1, x21
   847d0:	aa1303e0 	mov	x0, x19
   847d4:	b90093e9 	str	w9, [sp, #144]
   847d8:	29138feb 	stp	w11, w3, [sp, #156]
   847dc:	940030c9 	bl	90b00 <__ssprint_r>
   847e0:	35ff9680 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   847e4:	f940bbe0 	ldr	x0, [sp, #368]
   847e8:	aa1603fc 	mov	x28, x22
   847ec:	b94093e9 	ldr	w9, [sp, #144]
   847f0:	29538feb 	ldp	w11, w3, [sp, #156]
   847f4:	17fffba9 	b	83698 <_svfprintf_r+0x4d8>
   847f8:	39400728 	ldrb	w8, [x25, #1]
   847fc:	321702f7 	orr	w23, w23, #0x200
   84800:	91000739 	add	x25, x25, #0x1
   84804:	17fffad9 	b	83368 <_svfprintf_r+0x1a8>
   84808:	39400728 	ldrb	w8, [x25, #1]
   8480c:	321b02f7 	orr	w23, w23, #0x20
   84810:	91000739 	add	x25, x25, #0x1
   84814:	17fffad5 	b	83368 <_svfprintf_r+0x1a8>
   84818:	aa1303e0 	mov	x0, x19
   8481c:	d2800801 	mov	x1, #0x40                  	// #64
   84820:	94001b58 	bl	8b580 <_malloc_r>
   84824:	f90002a0 	str	x0, [x21]
   84828:	f9000ea0 	str	x0, [x21, #24]
   8482c:	f9403fe9 	ldr	x9, [sp, #120]
   84830:	b400d500 	cbz	x0, 862d0 <_svfprintf_r+0x3110>
   84834:	a90363f7 	stp	x23, x24, [sp, #48]
   84838:	52800800 	mov	w0, #0x40                  	// #64
   8483c:	a9046bf9 	stp	x25, x26, [sp, #64]
   84840:	a90573fb 	stp	x27, x28, [sp, #80]
   84844:	6d0627e8 	stp	d8, d9, [sp, #96]
   84848:	b90022a0 	str	w0, [x21, #32]
   8484c:	17fffa80 	b	8324c <_svfprintf_r+0x8c>
   84850:	b9409be0 	ldr	w0, [sp, #152]
   84854:	11002001 	add	w1, w0, #0x8
   84858:	7100003f 	cmp	w1, #0x0
   8485c:	5400908d 	b.le	85a6c <_svfprintf_r+0x28ac>
   84860:	f94043e0 	ldr	x0, [sp, #128]
   84864:	b9009be1 	str	w1, [sp, #152]
   84868:	91003c02 	add	x2, x0, #0xf
   8486c:	927df041 	and	x1, x2, #0xfffffffffffffff8
   84870:	f90043e1 	str	x1, [sp, #128]
   84874:	17fffee7 	b	84410 <_svfprintf_r+0x1250>
   84878:	b0000084 	adrp	x4, 95000 <pmu_event_descr+0x60>
   8487c:	b9416be1 	ldr	w1, [sp, #360]
   84880:	911b8084 	add	x4, x4, #0x6e0
   84884:	7100437f 	cmp	w27, #0x10
   84888:	54005bad 	b.le	853fc <_svfprintf_r+0x223c>
   8488c:	2a1b03e5 	mov	w5, w27
   84890:	aa1c03e2 	mov	x2, x28
   84894:	aa1703fb 	mov	x27, x23
   84898:	aa1903fc 	mov	x28, x25
   8489c:	2a0903fa 	mov	w26, w9
   848a0:	2a0303f9 	mov	w25, w3
   848a4:	2a0503f7 	mov	w23, w5
   848a8:	d2800208 	mov	x8, #0x10                  	// #16
   848ac:	f9006ff8 	str	x24, [sp, #216]
   848b0:	aa0403f8 	mov	x24, x4
   848b4:	b900e3eb 	str	w11, [sp, #224]
   848b8:	14000004 	b	848c8 <_svfprintf_r+0x1708>
   848bc:	510042f7 	sub	w23, w23, #0x10
   848c0:	710042ff 	cmp	w23, #0x10
   848c4:	5400588d 	b.le	853d4 <_svfprintf_r+0x2214>
   848c8:	91004000 	add	x0, x0, #0x10
   848cc:	11000421 	add	w1, w1, #0x1
   848d0:	a9002058 	stp	x24, x8, [x2]
   848d4:	91004042 	add	x2, x2, #0x10
   848d8:	b9016be1 	str	w1, [sp, #360]
   848dc:	f900bbe0 	str	x0, [sp, #368]
   848e0:	71001c3f 	cmp	w1, #0x7
   848e4:	54fffecd 	b.le	848bc <_svfprintf_r+0x16fc>
   848e8:	910583e2 	add	x2, sp, #0x160
   848ec:	aa1503e1 	mov	x1, x21
   848f0:	aa1303e0 	mov	x0, x19
   848f4:	94003083 	bl	90b00 <__ssprint_r>
   848f8:	3500a2e0 	cbnz	w0, 85d54 <_svfprintf_r+0x2b94>
   848fc:	f940bbe0 	ldr	x0, [sp, #368]
   84900:	aa1603e2 	mov	x2, x22
   84904:	b9416be1 	ldr	w1, [sp, #360]
   84908:	d2800208 	mov	x8, #0x10                  	// #16
   8490c:	17ffffec 	b	848bc <_svfprintf_r+0x16fc>
   84910:	2a1703e9 	mov	w9, w23
   84914:	2a1803eb 	mov	w11, w24
   84918:	2a1a03e7 	mov	w7, w26
   8491c:	b0000080 	adrp	x0, 95000 <pmu_event_descr+0x60>
   84920:	91180000 	add	x0, x0, #0x600
   84924:	f90063e0 	str	x0, [sp, #192]
   84928:	b9409be0 	ldr	w0, [sp, #152]
   8492c:	37280b89 	tbnz	w9, #5, 84a9c <_svfprintf_r+0x18dc>
   84930:	37200b69 	tbnz	w9, #4, 84a9c <_svfprintf_r+0x18dc>
   84934:	36303f69 	tbz	w9, #6, 85120 <_svfprintf_r+0x1f60>
   84938:	37f871e0 	tbnz	w0, #31, 85774 <_svfprintf_r+0x25b4>
   8493c:	f94043e0 	ldr	x0, [sp, #128]
   84940:	91002c01 	add	x1, x0, #0xb
   84944:	927df021 	and	x1, x1, #0xfffffffffffffff8
   84948:	79400000 	ldrh	w0, [x0]
   8494c:	f90043e1 	str	x1, [sp, #128]
   84950:	14000059 	b	84ab4 <_svfprintf_r+0x18f4>
   84954:	2a1a03e7 	mov	w7, w26
   84958:	2a1803eb 	mov	w11, w24
   8495c:	2a1703fa 	mov	w26, w23
   84960:	17fffe37 	b	8423c <_svfprintf_r+0x107c>
   84964:	b0000080 	adrp	x0, 95000 <pmu_event_descr+0x60>
   84968:	2a1703e9 	mov	w9, w23
   8496c:	9117a000 	add	x0, x0, #0x5e8
   84970:	2a1803eb 	mov	w11, w24
   84974:	2a1a03e7 	mov	w7, w26
   84978:	f90063e0 	str	x0, [sp, #192]
   8497c:	17ffffeb 	b	84928 <_svfprintf_r+0x1768>
   84980:	2a1703e9 	mov	w9, w23
   84984:	2a1803eb 	mov	w11, w24
   84988:	2a1a03e7 	mov	w7, w26
   8498c:	17fffe68 	b	8432c <_svfprintf_r+0x116c>
   84990:	29538be1 	ldp	w1, w2, [sp, #156]
   84994:	7100005f 	cmp	w2, #0x0
   84998:	7a40d820 	ccmp	w1, #0x0, #0x0, le
   8499c:	5400078d 	b.le	84a8c <_svfprintf_r+0x18cc>
   849a0:	aa1c03e1 	mov	x1, x28
   849a4:	f90087f9 	str	x25, [sp, #264]
   849a8:	f9407bf9 	ldr	x25, [sp, #240]
   849ac:	b0000084 	adrp	x4, 95000 <pmu_event_descr+0x60>
   849b0:	f94083fc 	ldr	x28, [sp, #256]
   849b4:	911b8084 	add	x4, x4, #0x6e0
   849b8:	f9004bf7 	str	x23, [sp, #144]
   849bc:	2a0203f7 	mov	w23, w2
   849c0:	d280021b 	mov	x27, #0x10                  	// #16
   849c4:	b900dbe9 	str	w9, [sp, #216]
   849c8:	b900e3eb 	str	w11, [sp, #224]
   849cc:	b900fbe3 	str	w3, [sp, #248]
   849d0:	34000817 	cbz	w23, 84ad0 <_svfprintf_r+0x1910>
   849d4:	510006f7 	sub	w23, w23, #0x1
   849d8:	b9416be2 	ldr	w2, [sp, #360]
   849dc:	8b1c0000 	add	x0, x0, x28
   849e0:	f94077e3 	ldr	x3, [sp, #232]
   849e4:	11000442 	add	w2, w2, #0x1
   849e8:	a9007023 	stp	x3, x28, [x1]
   849ec:	91004021 	add	x1, x1, #0x10
   849f0:	b9016be2 	str	w2, [sp, #360]
   849f4:	f900bbe0 	str	x0, [sp, #368]
   849f8:	71001c5f 	cmp	w2, #0x7
   849fc:	540014cc 	b.gt	84c94 <_svfprintf_r+0x1ad4>
   84a00:	f9406be3 	ldr	x3, [sp, #208]
   84a04:	39400322 	ldrb	w2, [x25]
   84a08:	cb180063 	sub	x3, x3, x24
   84a0c:	6b03005f 	cmp	w2, w3
   84a10:	1a83b05a 	csel	w26, w2, w3, lt	// lt = tstop
   84a14:	7100035f 	cmp	w26, #0x0
   84a18:	5400018d 	b.le	84a48 <_svfprintf_r+0x1888>
   84a1c:	b9416be2 	ldr	w2, [sp, #360]
   84a20:	93407f49 	sxtw	x9, w26
   84a24:	8b090000 	add	x0, x0, x9
   84a28:	a9002438 	stp	x24, x9, [x1]
   84a2c:	11000442 	add	w2, w2, #0x1
   84a30:	b9016be2 	str	w2, [sp, #360]
   84a34:	f900bbe0 	str	x0, [sp, #368]
   84a38:	71001c5f 	cmp	w2, #0x7
   84a3c:	5400316c 	b.gt	85068 <_svfprintf_r+0x1ea8>
   84a40:	39400322 	ldrb	w2, [x25]
   84a44:	91004021 	add	x1, x1, #0x10
   84a48:	7100035f 	cmp	w26, #0x0
   84a4c:	1a9fa343 	csel	w3, w26, wzr, ge	// ge = tcont
   84a50:	4b03005a 	sub	w26, w2, w3
   84a54:	7100035f 	cmp	w26, #0x0
   84a58:	5400096c 	b.gt	84b84 <_svfprintf_r+0x19c4>
   84a5c:	b9409fe3 	ldr	w3, [sp, #156]
   84a60:	8b220318 	add	x24, x24, w2, uxtb
   84a64:	7100007f 	cmp	w3, #0x0
   84a68:	7a40dae0 	ccmp	w23, #0x0, #0x0, le
   84a6c:	54fffb2c 	b.gt	849d0 <_svfprintf_r+0x1810>
   84a70:	f9404bf7 	ldr	x23, [sp, #144]
   84a74:	f9007bf9 	str	x25, [sp, #240]
   84a78:	f94087f9 	ldr	x25, [sp, #264]
   84a7c:	aa0103fc 	mov	x28, x1
   84a80:	b940dbe9 	ldr	w9, [sp, #216]
   84a84:	b940e3eb 	ldr	w11, [sp, #224]
   84a88:	b940fbe3 	ldr	w3, [sp, #248]
   84a8c:	f9406be1 	ldr	x1, [sp, #208]
   84a90:	eb01031f 	cmp	x24, x1
   84a94:	9a819318 	csel	x24, x24, x1, ls	// ls = plast
   84a98:	17fffcf0 	b	83e58 <_svfprintf_r+0xc98>
   84a9c:	37f80240 	tbnz	w0, #31, 84ae4 <_svfprintf_r+0x1924>
   84aa0:	f94043e0 	ldr	x0, [sp, #128]
   84aa4:	91003c01 	add	x1, x0, #0xf
   84aa8:	927df021 	and	x1, x1, #0xfffffffffffffff8
   84aac:	f90043e1 	str	x1, [sp, #128]
   84ab0:	f9400000 	ldr	x0, [x0]
   84ab4:	f100001f 	cmp	x0, #0x0
   84ab8:	1a9f07e1 	cset	w1, ne	// ne = any
   84abc:	6a01013f 	tst	w9, w1
   84ac0:	54001a81 	b.ne	84e10 <_svfprintf_r+0x1c50>  // b.any
   84ac4:	1215793a 	and	w26, w9, #0xfffffbff
   84ac8:	52800041 	mov	w1, #0x2                   	// #2
   84acc:	17fffde6 	b	84264 <_svfprintf_r+0x10a4>
   84ad0:	b9409fe2 	ldr	w2, [sp, #156]
   84ad4:	d1000739 	sub	x25, x25, #0x1
   84ad8:	51000442 	sub	w2, w2, #0x1
   84adc:	b9009fe2 	str	w2, [sp, #156]
   84ae0:	17ffffbe 	b	849d8 <_svfprintf_r+0x1818>
   84ae4:	b9409be0 	ldr	w0, [sp, #152]
   84ae8:	11002001 	add	w1, w0, #0x8
   84aec:	7100003f 	cmp	w1, #0x0
   84af0:	540033cd 	b.le	85168 <_svfprintf_r+0x1fa8>
   84af4:	f94043e0 	ldr	x0, [sp, #128]
   84af8:	b9009be1 	str	w1, [sp, #152]
   84afc:	91003c02 	add	x2, x0, #0xf
   84b00:	927df041 	and	x1, x2, #0xfffffffffffffff8
   84b04:	f90043e1 	str	x1, [sp, #128]
   84b08:	17ffffea 	b	84ab0 <_svfprintf_r+0x18f0>
   84b0c:	b9409be0 	ldr	w0, [sp, #152]
   84b10:	11002001 	add	w1, w0, #0x8
   84b14:	7100003f 	cmp	w1, #0x0
   84b18:	54002fad 	b.le	8510c <_svfprintf_r+0x1f4c>
   84b1c:	f94043e0 	ldr	x0, [sp, #128]
   84b20:	b9009be1 	str	w1, [sp, #152]
   84b24:	91003c02 	add	x2, x0, #0xf
   84b28:	927df041 	and	x1, x2, #0xfffffffffffffff8
   84b2c:	f90043e1 	str	x1, [sp, #128]
   84b30:	17fffe07 	b	8434c <_svfprintf_r+0x118c>
   84b34:	b9409be0 	ldr	w0, [sp, #152]
   84b38:	11002001 	add	w1, w0, #0x8
   84b3c:	7100003f 	cmp	w1, #0x0
   84b40:	5400300d 	b.le	85140 <_svfprintf_r+0x1f80>
   84b44:	f94043e0 	ldr	x0, [sp, #128]
   84b48:	b9009be1 	str	w1, [sp, #152]
   84b4c:	91003c02 	add	x2, x0, #0xf
   84b50:	927df041 	and	x1, x2, #0xfffffffffffffff8
   84b54:	f90043e1 	str	x1, [sp, #128]
   84b58:	17fffde5 	b	842ec <_svfprintf_r+0x112c>
   84b5c:	b9409be0 	ldr	w0, [sp, #152]
   84b60:	11002001 	add	w1, w0, #0x8
   84b64:	7100003f 	cmp	w1, #0x0
   84b68:	54002f6d 	b.le	85154 <_svfprintf_r+0x1f94>
   84b6c:	f94043e0 	ldr	x0, [sp, #128]
   84b70:	b9009be1 	str	w1, [sp, #152]
   84b74:	91003c02 	add	x2, x0, #0xf
   84b78:	927df041 	and	x1, x2, #0xfffffffffffffff8
   84b7c:	f90043e1 	str	x1, [sp, #128]
   84b80:	17fffdb7 	b	8425c <_svfprintf_r+0x109c>
   84b84:	b0000089 	adrp	x9, 95000 <pmu_event_descr+0x60>
   84b88:	b9416be2 	ldr	w2, [sp, #360]
   84b8c:	911b8129 	add	x9, x9, #0x6e0
   84b90:	7100435f 	cmp	w26, #0x10
   84b94:	5400040d 	b.le	84c14 <_svfprintf_r+0x1a54>
   84b98:	b900a3f7 	str	w23, [sp, #160]
   84b9c:	2a1a03f7 	mov	w23, w26
   84ba0:	aa0403fa 	mov	x26, x4
   84ba4:	14000004 	b	84bb4 <_svfprintf_r+0x19f4>
   84ba8:	510042f7 	sub	w23, w23, #0x10
   84bac:	710042ff 	cmp	w23, #0x10
   84bb0:	540002cd 	b.le	84c08 <_svfprintf_r+0x1a48>
   84bb4:	91004000 	add	x0, x0, #0x10
   84bb8:	11000442 	add	w2, w2, #0x1
   84bbc:	a9006c24 	stp	x4, x27, [x1]
   84bc0:	91004021 	add	x1, x1, #0x10
   84bc4:	b9016be2 	str	w2, [sp, #360]
   84bc8:	f900bbe0 	str	x0, [sp, #368]
   84bcc:	71001c5f 	cmp	w2, #0x7
   84bd0:	54fffecd 	b.le	84ba8 <_svfprintf_r+0x19e8>
   84bd4:	910583e2 	add	x2, sp, #0x160
   84bd8:	aa1503e1 	mov	x1, x21
   84bdc:	aa1303e0 	mov	x0, x19
   84be0:	94002fc8 	bl	90b00 <__ssprint_r>
   84be4:	35006e80 	cbnz	w0, 859b4 <_svfprintf_r+0x27f4>
   84be8:	510042f7 	sub	w23, w23, #0x10
   84bec:	b0000083 	adrp	x3, 95000 <pmu_event_descr+0x60>
   84bf0:	f940bbe0 	ldr	x0, [sp, #368]
   84bf4:	aa1603e1 	mov	x1, x22
   84bf8:	b9416be2 	ldr	w2, [sp, #360]
   84bfc:	911b8064 	add	x4, x3, #0x6e0
   84c00:	710042ff 	cmp	w23, #0x10
   84c04:	54fffd8c 	b.gt	84bb4 <_svfprintf_r+0x19f4>
   84c08:	aa1a03e9 	mov	x9, x26
   84c0c:	2a1703fa 	mov	w26, w23
   84c10:	b940a3f7 	ldr	w23, [sp, #160]
   84c14:	93407f43 	sxtw	x3, w26
   84c18:	11000442 	add	w2, w2, #0x1
   84c1c:	8b030000 	add	x0, x0, x3
   84c20:	a9000c29 	stp	x9, x3, [x1]
   84c24:	b9016be2 	str	w2, [sp, #360]
   84c28:	f900bbe0 	str	x0, [sp, #368]
   84c2c:	71001c5f 	cmp	w2, #0x7
   84c30:	54006acc 	b.gt	85988 <_svfprintf_r+0x27c8>
   84c34:	39400322 	ldrb	w2, [x25]
   84c38:	91004021 	add	x1, x1, #0x10
   84c3c:	17ffff88 	b	84a5c <_svfprintf_r+0x189c>
   84c40:	910583e2 	add	x2, sp, #0x160
   84c44:	aa1503e1 	mov	x1, x21
   84c48:	aa1303e0 	mov	x0, x19
   84c4c:	b900d3f2 	str	w18, [sp, #208]
   84c50:	b900dbe8 	str	w8, [sp, #216]
   84c54:	b900e3e9 	str	w9, [sp, #224]
   84c58:	b900fbeb 	str	w11, [sp, #248]
   84c5c:	b9010be7 	str	w7, [sp, #264]
   84c60:	b9011be3 	str	w3, [sp, #280]
   84c64:	94002fa7 	bl	90b00 <__ssprint_r>
   84c68:	35ff7240 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   84c6c:	f940bbe0 	ldr	x0, [sp, #368]
   84c70:	aa1603fc 	mov	x28, x22
   84c74:	3944bfe1 	ldrb	w1, [sp, #303]
   84c78:	b940d3f2 	ldr	w18, [sp, #208]
   84c7c:	b940dbe8 	ldr	w8, [sp, #216]
   84c80:	b940e3e9 	ldr	w9, [sp, #224]
   84c84:	b940fbeb 	ldr	w11, [sp, #248]
   84c88:	b9410be7 	ldr	w7, [sp, #264]
   84c8c:	b9411be3 	ldr	w3, [sp, #280]
   84c90:	17fff9d6 	b	833e8 <_svfprintf_r+0x228>
   84c94:	910583e2 	add	x2, sp, #0x160
   84c98:	aa1503e1 	mov	x1, x21
   84c9c:	aa1303e0 	mov	x0, x19
   84ca0:	94002f98 	bl	90b00 <__ssprint_r>
   84ca4:	35006880 	cbnz	w0, 859b4 <_svfprintf_r+0x27f4>
   84ca8:	f940bbe0 	ldr	x0, [sp, #368]
   84cac:	b0000082 	adrp	x2, 95000 <pmu_event_descr+0x60>
   84cb0:	aa1603e1 	mov	x1, x22
   84cb4:	911b8044 	add	x4, x2, #0x6e0
   84cb8:	17ffff52 	b	84a00 <_svfprintf_r+0x1840>
   84cbc:	1e682100 	fcmp	d8, d8
   84cc0:	54008d26 	b.vs	85e64 <_svfprintf_r+0x2ca4>
   84cc4:	121a791b 	and	w27, w8, #0xffffffdf
   84cc8:	7101077f 	cmp	w27, #0x41
   84ccc:	540028e1 	b.ne	851e8 <_svfprintf_r+0x2028>  // b.any
   84cd0:	52800b01 	mov	w1, #0x58                  	// #88
   84cd4:	7101851f 	cmp	w8, #0x61
   84cd8:	52800f00 	mov	w0, #0x78                  	// #120
   84cdc:	1a810000 	csel	w0, w0, w1, eq	// eq = none
   84ce0:	52800601 	mov	w1, #0x30                  	// #48
   84ce4:	3904c3e1 	strb	w1, [sp, #304]
   84ce8:	3904c7e0 	strb	w0, [sp, #305]
   84cec:	9105e3f8 	add	x24, sp, #0x178
   84cf0:	d2800017 	mov	x23, #0x0                   	// #0
   84cf4:	71018cff 	cmp	w7, #0x63
   84cf8:	5400572c 	b.gt	857dc <_svfprintf_r+0x261c>
   84cfc:	9e660101 	fmov	x1, d8
   84d00:	1e614100 	fneg	d0, d8
   84d04:	528005a2 	mov	w2, #0x2d                  	// #45
   84d08:	9104e3e0 	add	x0, sp, #0x138
   84d0c:	b90093e8 	str	w8, [sp, #144]
   84d10:	29139fe9 	stp	w9, w7, [sp, #156]
   84d14:	d360fc21 	lsr	x1, x1, #32
   84d18:	b900cbeb 	str	w11, [sp, #200]
   84d1c:	7100003f 	cmp	w1, #0x0
   84d20:	1a9fb041 	csel	w1, w2, wzr, lt	// lt = tstop
   84d24:	b900d3e1 	str	w1, [sp, #208]
   84d28:	1e68bc00 	fcsel	d0, d0, d8, lt	// lt = tstop
   84d2c:	940028e1 	bl	8f0b0 <frexp>
   84d30:	1e681001 	fmov	d1, #1.250000000000000000e-01
   84d34:	b94093e8 	ldr	w8, [sp, #144]
   84d38:	29539fe9 	ldp	w9, w7, [sp, #156]
   84d3c:	1e610801 	fmul	d1, d0, d1
   84d40:	b940cbeb 	ldr	w11, [sp, #200]
   84d44:	1e602028 	fcmp	d1, #0.0
   84d48:	540052c0 	b.eq	857a0 <_svfprintf_r+0x25e0>  // b.none
   84d4c:	2a0703e3 	mov	w3, w7
   84d50:	7101851f 	cmp	w8, #0x61
   84d54:	91000463 	add	x3, x3, #0x1
   84d58:	b0000080 	adrp	x0, 95000 <pmu_event_descr+0x60>
   84d5c:	b0000082 	adrp	x2, 95000 <pmu_event_descr+0x60>
   84d60:	91180000 	add	x0, x0, #0x600
   84d64:	9117a042 	add	x2, x2, #0x5e8
   84d68:	8b030303 	add	x3, x24, x3
   84d6c:	9a800042 	csel	x2, x2, x0, eq	// eq = none
   84d70:	1e661002 	fmov	d2, #1.600000000000000000e+01
   84d74:	aa1803e0 	mov	x0, x24
   84d78:	14000003 	b	84d84 <_svfprintf_r+0x1bc4>
   84d7c:	1e602028 	fcmp	d1, #0.0
   84d80:	54009360 	b.eq	85fec <_svfprintf_r+0x2e2c>  // b.none
   84d84:	1e620821 	fmul	d1, d1, d2
   84d88:	aa0003ec 	mov	x12, x0
   84d8c:	1e780021 	fcvtzs	w1, d1
   84d90:	1e620020 	scvtf	d0, w1
   84d94:	3861c844 	ldrb	w4, [x2, w1, sxtw]
   84d98:	38001404 	strb	w4, [x0], #1
   84d9c:	1e603821 	fsub	d1, d1, d0
   84da0:	eb00007f 	cmp	x3, x0
   84da4:	54fffec1 	b.ne	84d7c <_svfprintf_r+0x1bbc>  // b.any
   84da8:	12800003 	mov	w3, #0xffffffff            	// #-1
   84dac:	1e6c1000 	fmov	d0, #5.000000000000000000e-01
   84db0:	1e602030 	fcmpe	d1, d0
   84db4:	54007a0c 	b.gt	85cf4 <_svfprintf_r+0x2b34>
   84db8:	1e602020 	fcmp	d1, d0
   84dbc:	54000041 	b.ne	84dc4 <_svfprintf_r+0x1c04>  // b.any
   84dc0:	370079a1 	tbnz	w1, #0, 85cf4 <_svfprintf_r+0x2b34>
   84dc4:	11000461 	add	w1, w3, #0x1
   84dc8:	52800602 	mov	w2, #0x30                  	// #48
   84dcc:	8b21c001 	add	x1, x0, w1, sxtw
   84dd0:	37f87b83 	tbnz	w3, #31, 85d40 <_svfprintf_r+0x2b80>
   84dd4:	38001402 	strb	w2, [x0], #1
   84dd8:	eb00003f 	cmp	x1, x0
   84ddc:	54ffffc1 	b.ne	84dd4 <_svfprintf_r+0x1c14>  // b.any
   84de0:	b9413be0 	ldr	w0, [sp, #312]
   84de4:	b90093e0 	str	w0, [sp, #144]
   84de8:	4b180020 	sub	w0, w1, w24
   84dec:	b900cbe0 	str	w0, [sp, #200]
   84df0:	b94093e0 	ldr	w0, [sp, #144]
   84df4:	11003d01 	add	w1, w8, #0xf
   84df8:	321f0129 	orr	w9, w9, #0x2
   84dfc:	12001c21 	and	w1, w1, #0xff
   84e00:	51000400 	sub	w0, w0, #0x1
   84e04:	52800022 	mov	w2, #0x1                   	// #1
   84e08:	b9013be0 	str	w0, [sp, #312]
   84e0c:	14000135 	b	852e0 <_svfprintf_r+0x2120>
   84e10:	52800601 	mov	w1, #0x30                  	// #48
   84e14:	321f0129 	orr	w9, w9, #0x2
   84e18:	3904c3e1 	strb	w1, [sp, #304]
   84e1c:	3904c7e8 	strb	w8, [sp, #305]
   84e20:	17ffff29 	b	84ac4 <_svfprintf_r+0x1904>
   84e24:	910583e2 	add	x2, sp, #0x160
   84e28:	aa1503e1 	mov	x1, x21
   84e2c:	aa1303e0 	mov	x0, x19
   84e30:	b90093e9 	str	w9, [sp, #144]
   84e34:	29138feb 	stp	w11, w3, [sp, #156]
   84e38:	94002f32 	bl	90b00 <__ssprint_r>
   84e3c:	35ff63a0 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   84e40:	f940bbe0 	ldr	x0, [sp, #368]
   84e44:	aa1603fc 	mov	x28, x22
   84e48:	b94093e9 	ldr	w9, [sp, #144]
   84e4c:	29538feb 	ldp	w11, w3, [sp, #156]
   84e50:	17fffa04 	b	83660 <_svfprintf_r+0x4a0>
   84e54:	910543e0 	add	x0, sp, #0x150
   84e58:	d2800102 	mov	x2, #0x8                   	// #8
   84e5c:	52800001 	mov	w1, #0x0                   	// #0
   84e60:	b90093e8 	str	w8, [sp, #144]
   84e64:	2913afe9 	stp	w9, w11, [sp, #156]
   84e68:	b900d3e7 	str	w7, [sp, #208]
   84e6c:	f900aff8 	str	x24, [sp, #344]
   84e70:	940021d4 	bl	8d5c0 <memset>
   84e74:	b940d3e7 	ldr	w7, [sp, #208]
   84e78:	b94093e8 	ldr	w8, [sp, #144]
   84e7c:	2953afe9 	ldp	w9, w11, [sp, #156]
   84e80:	310004ff 	cmn	w7, #0x1
   84e84:	54003000 	b.eq	85484 <_svfprintf_r+0x22c4>  // b.none
   84e88:	aa1903e0 	mov	x0, x25
   84e8c:	5280001b 	mov	w27, #0x0                   	// #0
   84e90:	aa1503f9 	mov	x25, x21
   84e94:	2a0703fa 	mov	w26, w7
   84e98:	2a1b03f5 	mov	w21, w27
   84e9c:	d2800017 	mov	x23, #0x0                   	// #0
   84ea0:	aa0003fb 	mov	x27, x0
   84ea4:	b90093e8 	str	w8, [sp, #144]
   84ea8:	2913afe9 	stp	w9, w11, [sp, #156]
   84eac:	1400000d 	b	84ee0 <_svfprintf_r+0x1d20>
   84eb0:	910543e3 	add	x3, sp, #0x150
   84eb4:	9105e3e1 	add	x1, sp, #0x178
   84eb8:	aa1303e0 	mov	x0, x19
   84ebc:	94001bbd 	bl	8bdb0 <_wcrtomb_r>
   84ec0:	3100041f 	cmn	w0, #0x1
   84ec4:	54006e80 	b.eq	85c94 <_svfprintf_r+0x2ad4>  // b.none
   84ec8:	0b0002a0 	add	w0, w21, w0
   84ecc:	6b1a001f 	cmp	w0, w26
   84ed0:	540000ec 	b.gt	84eec <_svfprintf_r+0x1d2c>
   84ed4:	910012f7 	add	x23, x23, #0x4
   84ed8:	54008b80 	b.eq	86048 <_svfprintf_r+0x2e88>  // b.none
   84edc:	2a0003f5 	mov	w21, w0
   84ee0:	f940afe0 	ldr	x0, [sp, #344]
   84ee4:	b8776802 	ldr	w2, [x0, x23]
   84ee8:	35fffe42 	cbnz	w2, 84eb0 <_svfprintf_r+0x1cf0>
   84eec:	aa1b03e0 	mov	x0, x27
   84ef0:	b94093e8 	ldr	w8, [sp, #144]
   84ef4:	2953afe9 	ldp	w9, w11, [sp, #156]
   84ef8:	2a1503fb 	mov	w27, w21
   84efc:	aa1903f5 	mov	x21, x25
   84f00:	aa0003f9 	mov	x25, x0
   84f04:	3400317b 	cbz	w27, 85530 <_svfprintf_r+0x2370>
   84f08:	71018f7f 	cmp	w27, #0x63
   84f0c:	5400450c 	b.gt	857ac <_svfprintf_r+0x25ec>
   84f10:	9105e3f8 	add	x24, sp, #0x178
   84f14:	d2800017 	mov	x23, #0x0                   	// #0
   84f18:	93407f7a 	sxtw	x26, w27
   84f1c:	d2800102 	mov	x2, #0x8                   	// #8
   84f20:	52800001 	mov	w1, #0x0                   	// #0
   84f24:	910543e0 	add	x0, sp, #0x150
   84f28:	b90093e8 	str	w8, [sp, #144]
   84f2c:	2913afe9 	stp	w9, w11, [sp, #156]
   84f30:	940021a4 	bl	8d5c0 <memset>
   84f34:	910543e4 	add	x4, sp, #0x150
   84f38:	aa1a03e3 	mov	x3, x26
   84f3c:	910563e2 	add	x2, sp, #0x158
   84f40:	aa1803e1 	mov	x1, x24
   84f44:	aa1303e0 	mov	x0, x19
   84f48:	9400221e 	bl	8d7c0 <_wcsrtombs_r>
   84f4c:	b94093e8 	ldr	w8, [sp, #144]
   84f50:	eb00035f 	cmp	x26, x0
   84f54:	2953afe9 	ldp	w9, w11, [sp, #156]
   84f58:	54009c21 	b.ne	862dc <_svfprintf_r+0x311c>  // b.any
   84f5c:	383bcb1f 	strb	wzr, [x24, w27, sxtw]
   84f60:	7100037f 	cmp	w27, #0x0
   84f64:	b90093ff 	str	wzr, [sp, #144]
   84f68:	1a9fa363 	csel	w3, w27, wzr, ge	// ge = tcont
   84f6c:	3944bfe1 	ldrb	w1, [sp, #303]
   84f70:	52800007 	mov	w7, #0x0                   	// #0
   84f74:	2913ffff 	stp	wzr, wzr, [sp, #156]
   84f78:	34ff2241 	cbz	w1, 833c0 <_svfprintf_r+0x200>
   84f7c:	17fffb97 	b	83dd8 <_svfprintf_r+0xc18>
   84f80:	b94093e9 	ldr	w9, [sp, #144]
   84f84:	2a1a03e3 	mov	w3, w26
   84f88:	b9409feb 	ldr	w11, [sp, #156]
   84f8c:	aa1903e4 	mov	x4, x25
   84f90:	2a1803fa 	mov	w26, w24
   84f94:	aa1c03f9 	mov	x25, x28
   84f98:	aa0203fc 	mov	x28, x2
   84f9c:	93407f5a 	sxtw	x26, w26
   84fa0:	11000421 	add	w1, w1, #0x1
   84fa4:	8b1a0000 	add	x0, x0, x26
   84fa8:	b9016be1 	str	w1, [sp, #360]
   84fac:	f900bbe0 	str	x0, [sp, #368]
   84fb0:	a9006b84 	stp	x4, x26, [x28]
   84fb4:	71001c3f 	cmp	w1, #0x7
   84fb8:	54ff4a8c 	b.gt	83908 <_svfprintf_r+0x748>
   84fbc:	9100439c 	add	x28, x28, #0x10
   84fc0:	17fff934 	b	83490 <_svfprintf_r+0x2d0>
   84fc4:	12160343 	and	w3, w26, #0x400
   84fc8:	910773ec 	add	x12, sp, #0x1dc
   84fcc:	b202e7fb 	mov	x27, #0xcccccccccccccccc    	// #-3689348814741910324
   84fd0:	aa1903e4 	mov	x4, x25
   84fd4:	aa0c03e2 	mov	x2, x12
   84fd8:	aa1303f9 	mov	x25, x19
   84fdc:	52800005 	mov	w5, #0x0                   	// #0
   84fe0:	2a0303f3 	mov	w19, w3
   84fe4:	f29999bb 	movk	x27, #0xcccd
   84fe8:	aa1503e3 	mov	x3, x21
   84fec:	f9407bf5 	ldr	x21, [sp, #240]
   84ff0:	14000007 	b	8500c <_svfprintf_r+0x1e4c>
   84ff4:	9bdb7c17 	umulh	x23, x0, x27
   84ff8:	d343fef7 	lsr	x23, x23, #3
   84ffc:	f100241f 	cmp	x0, #0x9
   85000:	54000249 	b.ls	85048 <_svfprintf_r+0x1e88>  // b.plast
   85004:	aa1703e0 	mov	x0, x23
   85008:	aa1803e2 	mov	x2, x24
   8500c:	9bdb7c17 	umulh	x23, x0, x27
   85010:	110004a5 	add	w5, w5, #0x1
   85014:	d1000458 	sub	x24, x2, #0x1
   85018:	d343fef7 	lsr	x23, x23, #3
   8501c:	8b170ae1 	add	x1, x23, x23, lsl #2
   85020:	cb010401 	sub	x1, x0, x1, lsl #1
   85024:	1100c021 	add	w1, w1, #0x30
   85028:	381ff041 	sturb	w1, [x2, #-1]
   8502c:	34fffe53 	cbz	w19, 84ff4 <_svfprintf_r+0x1e34>
   85030:	394002a1 	ldrb	w1, [x21]
   85034:	7103fc3f 	cmp	w1, #0xff
   85038:	7a451020 	ccmp	w1, w5, #0x0, ne	// ne = any
   8503c:	54fffdc1 	b.ne	84ff4 <_svfprintf_r+0x1e34>  // b.any
   85040:	f100241f 	cmp	x0, #0x9
   85044:	54004d68 	b.hi	859f0 <_svfprintf_r+0x2830>  // b.pmore
   85048:	aa1903f3 	mov	x19, x25
   8504c:	4b18019b 	sub	w27, w12, w24
   85050:	aa0403f9 	mov	x25, x4
   85054:	2a1a03e9 	mov	w9, w26
   85058:	b900cbe5 	str	w5, [sp, #200]
   8505c:	f9007bf5 	str	x21, [sp, #240]
   85060:	aa0303f5 	mov	x21, x3
   85064:	17fffc8f 	b	842a0 <_svfprintf_r+0x10e0>
   85068:	910583e2 	add	x2, sp, #0x160
   8506c:	aa1503e1 	mov	x1, x21
   85070:	aa1303e0 	mov	x0, x19
   85074:	94002ea3 	bl	90b00 <__ssprint_r>
   85078:	350049e0 	cbnz	w0, 859b4 <_svfprintf_r+0x27f4>
   8507c:	f940bbe0 	ldr	x0, [sp, #368]
   85080:	90000083 	adrp	x3, 95000 <pmu_event_descr+0x60>
   85084:	39400322 	ldrb	w2, [x25]
   85088:	aa1603e1 	mov	x1, x22
   8508c:	911b8064 	add	x4, x3, #0x6e0
   85090:	17fffe6e 	b	84a48 <_svfprintf_r+0x1888>
   85094:	710018ff 	cmp	w7, #0x6
   85098:	528000c3 	mov	w3, #0x6                   	// #6
   8509c:	1a8390e3 	csel	w3, w7, w3, ls	// ls = plast
   850a0:	90000085 	adrp	x5, 95000 <pmu_event_descr+0x60>
   850a4:	2a0303fb 	mov	w27, w3
   850a8:	911860b8 	add	x24, x5, #0x618
   850ac:	d2800017 	mov	x23, #0x0                   	// #0
   850b0:	52800001 	mov	w1, #0x0                   	// #0
   850b4:	52800007 	mov	w7, #0x0                   	// #0
   850b8:	b90093ff 	str	wzr, [sp, #144]
   850bc:	2913ffff 	stp	wzr, wzr, [sp, #156]
   850c0:	17fff8c0 	b	833c0 <_svfprintf_r+0x200>
   850c4:	f940bbe0 	ldr	x0, [sp, #368]
   850c8:	b4ff4fc0 	cbz	x0, 83ac0 <_svfprintf_r+0x900>
   850cc:	aa1303e0 	mov	x0, x19
   850d0:	910583e2 	add	x2, sp, #0x160
   850d4:	aa1503e1 	mov	x1, x21
   850d8:	94002e8a 	bl	90b00 <__ssprint_r>
   850dc:	794022a0 	ldrh	w0, [x21, #16]
   850e0:	121a0000 	and	w0, w0, #0x40
   850e4:	17fffa79 	b	83ac8 <_svfprintf_r+0x908>
   850e8:	36482b29 	tbz	w9, #9, 8564c <_svfprintf_r+0x248c>
   850ec:	37f876c0 	tbnz	w0, #31, 85fc4 <_svfprintf_r+0x2e04>
   850f0:	f94043e0 	ldr	x0, [sp, #128]
   850f4:	91002c01 	add	x1, x0, #0xb
   850f8:	927df021 	and	x1, x1, #0xfffffffffffffff8
   850fc:	f90043e1 	str	x1, [sp, #128]
   85100:	39800000 	ldrsb	x0, [x0]
   85104:	aa0003e1 	mov	x1, x0
   85108:	17fffc7b 	b	842f4 <_svfprintf_r+0x1134>
   8510c:	f94057e2 	ldr	x2, [sp, #168]
   85110:	b9409be0 	ldr	w0, [sp, #152]
   85114:	b9009be1 	str	w1, [sp, #152]
   85118:	8b20c040 	add	x0, x2, w0, sxtw
   8511c:	17fffc8c 	b	8434c <_svfprintf_r+0x118c>
   85120:	36482b49 	tbz	w9, #9, 85688 <_svfprintf_r+0x24c8>
   85124:	37f86d00 	tbnz	w0, #31, 85ec4 <_svfprintf_r+0x2d04>
   85128:	f94043e0 	ldr	x0, [sp, #128]
   8512c:	91002c01 	add	x1, x0, #0xb
   85130:	927df021 	and	x1, x1, #0xfffffffffffffff8
   85134:	39400000 	ldrb	w0, [x0]
   85138:	f90043e1 	str	x1, [sp, #128]
   8513c:	17fffe5e 	b	84ab4 <_svfprintf_r+0x18f4>
   85140:	f94057e2 	ldr	x2, [sp, #168]
   85144:	b9409be0 	ldr	w0, [sp, #152]
   85148:	b9009be1 	str	w1, [sp, #152]
   8514c:	8b20c040 	add	x0, x2, w0, sxtw
   85150:	17fffc67 	b	842ec <_svfprintf_r+0x112c>
   85154:	f94057e2 	ldr	x2, [sp, #168]
   85158:	b9409be0 	ldr	w0, [sp, #152]
   8515c:	b9009be1 	str	w1, [sp, #152]
   85160:	8b20c040 	add	x0, x2, w0, sxtw
   85164:	17fffc3e 	b	8425c <_svfprintf_r+0x109c>
   85168:	f94057e2 	ldr	x2, [sp, #168]
   8516c:	b9409be0 	ldr	w0, [sp, #152]
   85170:	b9009be1 	str	w1, [sp, #152]
   85174:	8b20c040 	add	x0, x2, w0, sxtw
   85178:	17fffe4e 	b	84ab0 <_svfprintf_r+0x18f0>
   8517c:	3648247a 	tbz	w26, #9, 85608 <_svfprintf_r+0x2448>
   85180:	37f873c0 	tbnz	w0, #31, 85ff8 <_svfprintf_r+0x2e38>
   85184:	f94043e0 	ldr	x0, [sp, #128]
   85188:	91002c01 	add	x1, x0, #0xb
   8518c:	927df021 	and	x1, x1, #0xfffffffffffffff8
   85190:	f90043e1 	str	x1, [sp, #128]
   85194:	39400000 	ldrb	w0, [x0]
   85198:	52800021 	mov	w1, #0x1                   	// #1
   8519c:	17fffc32 	b	84264 <_svfprintf_r+0x10a4>
   851a0:	b9409be0 	ldr	w0, [sp, #152]
   851a4:	11002001 	add	w1, w0, #0x8
   851a8:	7100003f 	cmp	w1, #0x0
   851ac:	540027cd 	b.le	856a4 <_svfprintf_r+0x24e4>
   851b0:	f94043e0 	ldr	x0, [sp, #128]
   851b4:	b9009be1 	str	w1, [sp, #152]
   851b8:	91002c02 	add	x2, x0, #0xb
   851bc:	927df041 	and	x1, x2, #0xfffffffffffffff8
   851c0:	f90043e1 	str	x1, [sp, #128]
   851c4:	17fffbff 	b	841c0 <_svfprintf_r+0x1000>
   851c8:	36482529 	tbz	w9, #9, 8566c <_svfprintf_r+0x24ac>
   851cc:	37f86a20 	tbnz	w0, #31, 85f10 <_svfprintf_r+0x2d50>
   851d0:	f94043e0 	ldr	x0, [sp, #128]
   851d4:	91002c01 	add	x1, x0, #0xb
   851d8:	927df021 	and	x1, x1, #0xfffffffffffffff8
   851dc:	39400000 	ldrb	w0, [x0]
   851e0:	f90043e1 	str	x1, [sp, #128]
   851e4:	17fffc5b 	b	84350 <_svfprintf_r+0x1190>
   851e8:	310004ff 	cmn	w7, #0x1
   851ec:	54003200 	b.eq	8582c <_svfprintf_r+0x266c>  // b.none
   851f0:	71011f7f 	cmp	w27, #0x47
   851f4:	7a4008e0 	ccmp	w7, #0x0, #0x0, eq	// eq = none
   851f8:	1a9f14e7 	csinc	w7, w7, wzr, ne	// ne = any
   851fc:	9e660100 	fmov	x0, d8
   85200:	32180137 	orr	w23, w9, #0x100
   85204:	d360fc00 	lsr	x0, x0, #32
   85208:	37f87380 	tbnz	w0, #31, 86078 <_svfprintf_r+0x2eb8>
   8520c:	1e604109 	fmov	d9, d8
   85210:	b900d3ff 	str	wzr, [sp, #208]
   85214:	71011b7f 	cmp	w27, #0x46
   85218:	540034c0 	b.eq	858b0 <_svfprintf_r+0x26f0>  // b.none
   8521c:	7101177f 	cmp	w27, #0x45
   85220:	54004b21 	b.ne	85b84 <_svfprintf_r+0x29c4>  // b.any
   85224:	1e604120 	fmov	d0, d9
   85228:	110004e0 	add	w0, w7, #0x1
   8522c:	2a0003fa 	mov	w26, w0
   85230:	2a0003e2 	mov	w2, w0
   85234:	910563e5 	add	x5, sp, #0x158
   85238:	910543e4 	add	x4, sp, #0x150
   8523c:	9104e3e3 	add	x3, sp, #0x138
   85240:	aa1303e0 	mov	x0, x19
   85244:	52800041 	mov	w1, #0x2                   	// #2
   85248:	b90093e7 	str	w7, [sp, #144]
   8524c:	2913a7e8 	stp	w8, w9, [sp, #156]
   85250:	b900cbfa 	str	w26, [sp, #200]
   85254:	b900dbeb 	str	w11, [sp, #216]
   85258:	940021d6 	bl	8d9b0 <_dtoa_r>
   8525c:	1e602128 	fcmp	d9, #0.0
   85260:	b94093e7 	ldr	w7, [sp, #144]
   85264:	2953a7e8 	ldp	w8, w9, [sp, #156]
   85268:	aa0003f8 	mov	x24, x0
   8526c:	b940dbeb 	ldr	w11, [sp, #216]
   85270:	8b3ac002 	add	x2, x0, w26, sxtw
   85274:	540074a0 	b.eq	86108 <_svfprintf_r+0x2f48>  // b.none
   85278:	f940afe0 	ldr	x0, [sp, #344]
   8527c:	eb02001f 	cmp	x0, x2
   85280:	54000102 	b.cs	852a0 <_svfprintf_r+0x20e0>  // b.hs, b.nlast
   85284:	52800603 	mov	w3, #0x30                  	// #48
   85288:	91000401 	add	x1, x0, #0x1
   8528c:	f900afe1 	str	x1, [sp, #344]
   85290:	39000003 	strb	w3, [x0]
   85294:	f940afe0 	ldr	x0, [sp, #344]
   85298:	eb02001f 	cmp	x0, x2
   8529c:	54ffff63 	b.cc	85288 <_svfprintf_r+0x20c8>  // b.lo, b.ul, b.last
   852a0:	b9413be1 	ldr	w1, [sp, #312]
   852a4:	cb180000 	sub	x0, x0, x24
   852a8:	b90093e1 	str	w1, [sp, #144]
   852ac:	b900cbe0 	str	w0, [sp, #200]
   852b0:	71011f7f 	cmp	w27, #0x47
   852b4:	540071a1 	b.ne	860e8 <_svfprintf_r+0x2f28>  // b.any
   852b8:	b94093e1 	ldr	w1, [sp, #144]
   852bc:	6b07003f 	cmp	w1, w7
   852c0:	3a43d821 	ccmn	w1, #0x3, #0x1, le
   852c4:	54002cea 	b.ge	85860 <_svfprintf_r+0x26a0>  // b.tcont
   852c8:	51000908 	sub	w8, w8, #0x2
   852cc:	51000420 	sub	w0, w1, #0x1
   852d0:	12001d01 	and	w1, w8, #0xff
   852d4:	52800002 	mov	w2, #0x0                   	// #0
   852d8:	d2800017 	mov	x23, #0x0                   	// #0
   852dc:	b9013be0 	str	w0, [sp, #312]
   852e0:	390503e1 	strb	w1, [sp, #320]
   852e4:	52800561 	mov	w1, #0x2b                  	// #43
   852e8:	36f800a0 	tbz	w0, #31, 852fc <_svfprintf_r+0x213c>
   852ec:	b94093e1 	ldr	w1, [sp, #144]
   852f0:	52800020 	mov	w0, #0x1                   	// #1
   852f4:	4b010000 	sub	w0, w0, w1
   852f8:	528005a1 	mov	w1, #0x2d                  	// #45
   852fc:	390507e1 	strb	w1, [sp, #321]
   85300:	7100241f 	cmp	w0, #0x9
   85304:	54004b2d 	b.le	85c68 <_svfprintf_r+0x2aa8>
   85308:	91057fec 	add	x12, sp, #0x15f
   8530c:	529999ad 	mov	w13, #0xcccd                	// #52429
   85310:	aa0c03e4 	mov	x4, x12
   85314:	72b9998d 	movk	w13, #0xcccc, lsl #16
   85318:	9bad7c02 	umull	x2, w0, w13
   8531c:	aa0403e3 	mov	x3, x4
   85320:	2a0003e5 	mov	w5, w0
   85324:	d1000484 	sub	x4, x4, #0x1
   85328:	d363fc42 	lsr	x2, x2, #35
   8532c:	0b020841 	add	w1, w2, w2, lsl #2
   85330:	4b010401 	sub	w1, w0, w1, lsl #1
   85334:	2a0203e0 	mov	w0, w2
   85338:	1100c021 	add	w1, w1, #0x30
   8533c:	381ff061 	sturb	w1, [x3, #-1]
   85340:	71018cbf 	cmp	w5, #0x63
   85344:	54fffeac 	b.gt	85318 <_svfprintf_r+0x2158>
   85348:	1100c040 	add	w0, w2, #0x30
   8534c:	381ff080 	sturb	w0, [x4, #-1]
   85350:	d1000860 	sub	x0, x3, #0x2
   85354:	eb0c001f 	cmp	x0, x12
   85358:	540078a2 	b.cs	8626c <_svfprintf_r+0x30ac>  // b.hs, b.nlast
   8535c:	91050be1 	add	x1, sp, #0x142
   85360:	38401402 	ldrb	w2, [x0], #1
   85364:	38001422 	strb	w2, [x1], #1
   85368:	eb0c001f 	cmp	x0, x12
   8536c:	54ffffa1 	b.ne	85360 <_svfprintf_r+0x21a0>  // b.any
   85370:	910587e0 	add	x0, sp, #0x161
   85374:	91050be2 	add	x2, sp, #0x142
   85378:	cb030000 	sub	x0, x0, x3
   8537c:	910503e1 	add	x1, sp, #0x140
   85380:	8b000040 	add	x0, x2, x0
   85384:	4b010000 	sub	w0, w0, w1
   85388:	b900cfe0 	str	w0, [sp, #204]
   8538c:	295907e0 	ldp	w0, w1, [sp, #200]
   85390:	0b00003b 	add	w27, w1, w0
   85394:	7100041f 	cmp	w0, #0x1
   85398:	5400494d 	b.le	85cc0 <_svfprintf_r+0x2b00>
   8539c:	b940b3e0 	ldr	w0, [sp, #176]
   853a0:	0b00037b 	add	w27, w27, w0
   853a4:	1215792a 	and	w10, w9, #0xfffffbff
   853a8:	7100037f 	cmp	w27, #0x0
   853ac:	32180149 	orr	w9, w10, #0x100
   853b0:	1a9fa363 	csel	w3, w27, wzr, ge	// ge = tcont
   853b4:	b90093ff 	str	wzr, [sp, #144]
   853b8:	2913ffff 	stp	wzr, wzr, [sp, #156]
   853bc:	b940d3e0 	ldr	w0, [sp, #208]
   853c0:	35002440 	cbnz	w0, 85848 <_svfprintf_r+0x2688>
   853c4:	3944bfe1 	ldrb	w1, [sp, #303]
   853c8:	52800007 	mov	w7, #0x0                   	// #0
   853cc:	34feffa1 	cbz	w1, 833c0 <_svfprintf_r+0x200>
   853d0:	17fffa82 	b	83dd8 <_svfprintf_r+0xc18>
   853d4:	2a1703e5 	mov	w5, w23
   853d8:	aa1803e4 	mov	x4, x24
   853dc:	f9406ff8 	ldr	x24, [sp, #216]
   853e0:	2a1903e3 	mov	w3, w25
   853e4:	b940e3eb 	ldr	w11, [sp, #224]
   853e8:	aa1b03f7 	mov	x23, x27
   853ec:	aa1c03f9 	mov	x25, x28
   853f0:	2a1a03e9 	mov	w9, w26
   853f4:	aa0203fc 	mov	x28, x2
   853f8:	2a0503fb 	mov	w27, w5
   853fc:	93407f67 	sxtw	x7, w27
   85400:	11000421 	add	w1, w1, #0x1
   85404:	8b070000 	add	x0, x0, x7
   85408:	a9001f84 	stp	x4, x7, [x28]
   8540c:	9100439c 	add	x28, x28, #0x10
   85410:	b9016be1 	str	w1, [sp, #360]
   85414:	f900bbe0 	str	x0, [sp, #368]
   85418:	71001c3f 	cmp	w1, #0x7
   8541c:	54ff518d 	b.le	83e4c <_svfprintf_r+0xc8c>
   85420:	910583e2 	add	x2, sp, #0x160
   85424:	aa1503e1 	mov	x1, x21
   85428:	aa1303e0 	mov	x0, x19
   8542c:	b900dbe9 	str	w9, [sp, #216]
   85430:	b900e3eb 	str	w11, [sp, #224]
   85434:	b900fbe3 	str	w3, [sp, #248]
   85438:	94002db2 	bl	90b00 <__ssprint_r>
   8543c:	35ff33a0 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   85440:	f940bbe0 	ldr	x0, [sp, #368]
   85444:	aa1603fc 	mov	x28, x22
   85448:	b940dbe9 	ldr	w9, [sp, #216]
   8544c:	b940e3eb 	ldr	w11, [sp, #224]
   85450:	b940fbe3 	ldr	w3, [sp, #248]
   85454:	17fffa7e 	b	83e4c <_svfprintf_r+0xc8c>
   85458:	b940ffe0 	ldr	w0, [sp, #252]
   8545c:	11004001 	add	w1, w0, #0x10
   85460:	7100003f 	cmp	w1, #0x0
   85464:	54001e8d 	b.le	85834 <_svfprintf_r+0x2674>
   85468:	f94043e0 	ldr	x0, [sp, #128]
   8546c:	b900ffe1 	str	w1, [sp, #252]
   85470:	91003c00 	add	x0, x0, #0xf
   85474:	927cec00 	and	x0, x0, #0xfffffffffffffff0
   85478:	91004001 	add	x1, x0, #0x10
   8547c:	f90043e1 	str	x1, [sp, #128]
   85480:	17fffa36 	b	83d58 <_svfprintf_r+0xb98>
   85484:	910543e4 	add	x4, sp, #0x150
   85488:	910563e2 	add	x2, sp, #0x158
   8548c:	aa1303e0 	mov	x0, x19
   85490:	d2800003 	mov	x3, #0x0                   	// #0
   85494:	d2800001 	mov	x1, #0x0                   	// #0
   85498:	b90093e8 	str	w8, [sp, #144]
   8549c:	2913afe9 	stp	w9, w11, [sp, #156]
   854a0:	940020c8 	bl	8d7c0 <_wcsrtombs_r>
   854a4:	b94093e8 	ldr	w8, [sp, #144]
   854a8:	2a0003fb 	mov	w27, w0
   854ac:	2953afe9 	ldp	w9, w11, [sp, #156]
   854b0:	3100041f 	cmn	w0, #0x1
   854b4:	54003f20 	b.eq	85c98 <_svfprintf_r+0x2ad8>  // b.none
   854b8:	f900aff8 	str	x24, [sp, #344]
   854bc:	17fffe92 	b	84f04 <_svfprintf_r+0x1d44>
   854c0:	528005a0 	mov	w0, #0x2d                  	// #45
   854c4:	528005a1 	mov	w1, #0x2d                  	// #45
   854c8:	3904bfe0 	strb	w0, [sp, #303]
   854cc:	17fffa34 	b	83d9c <_svfprintf_r+0xbdc>
   854d0:	b940ffe0 	ldr	w0, [sp, #252]
   854d4:	11004001 	add	w1, w0, #0x10
   854d8:	7100003f 	cmp	w1, #0x0
   854dc:	540019cd 	b.le	85814 <_svfprintf_r+0x2654>
   854e0:	f94043e0 	ldr	x0, [sp, #128]
   854e4:	b900ffe1 	str	w1, [sp, #252]
   854e8:	91003c02 	add	x2, x0, #0xf
   854ec:	fd400008 	ldr	d8, [x0]
   854f0:	927df041 	and	x1, x2, #0xfffffffffffffff8
   854f4:	f90043e1 	str	x1, [sp, #128]
   854f8:	17fffa21 	b	83d7c <_svfprintf_r+0xbbc>
   854fc:	910583e2 	add	x2, sp, #0x160
   85500:	aa1503e1 	mov	x1, x21
   85504:	aa1303e0 	mov	x0, x19
   85508:	b90093e9 	str	w9, [sp, #144]
   8550c:	29138feb 	stp	w11, w3, [sp, #156]
   85510:	94002d7c 	bl	90b00 <__ssprint_r>
   85514:	35ff2ce0 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   85518:	f940bbe0 	ldr	x0, [sp, #368]
   8551c:	aa1603fc 	mov	x28, x22
   85520:	b94093e9 	ldr	w9, [sp, #144]
   85524:	29538feb 	ldp	w11, w3, [sp, #156]
   85528:	b9413be2 	ldr	w2, [sp, #312]
   8552c:	17fff8e0 	b	838ac <_svfprintf_r+0x6ec>
   85530:	3944bfe1 	ldrb	w1, [sp, #303]
   85534:	52800003 	mov	w3, #0x0                   	// #0
   85538:	b90093ff 	str	wzr, [sp, #144]
   8553c:	52800007 	mov	w7, #0x0                   	// #0
   85540:	2913ffff 	stp	wzr, wzr, [sp, #156]
   85544:	d2800017 	mov	x23, #0x0                   	// #0
   85548:	34fef3c1 	cbz	w1, 833c0 <_svfprintf_r+0x200>
   8554c:	17fffa23 	b	83dd8 <_svfprintf_r+0xc18>
   85550:	910583e2 	add	x2, sp, #0x160
   85554:	aa1503e1 	mov	x1, x21
   85558:	aa1303e0 	mov	x0, x19
   8555c:	b900dbe9 	str	w9, [sp, #216]
   85560:	b900e3eb 	str	w11, [sp, #224]
   85564:	b900fbe3 	str	w3, [sp, #248]
   85568:	94002d66 	bl	90b00 <__ssprint_r>
   8556c:	35ff2a20 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   85570:	f940bbe0 	ldr	x0, [sp, #368]
   85574:	aa1603fc 	mov	x28, x22
   85578:	b940dbe9 	ldr	w9, [sp, #216]
   8557c:	b940e3eb 	ldr	w11, [sp, #224]
   85580:	b940fbe3 	ldr	w3, [sp, #248]
   85584:	17fffa2c 	b	83e34 <_svfprintf_r+0xc74>
   85588:	3606f849 	tbz	w9, #0, 83490 <_svfprintf_r+0x2d0>
   8558c:	a94b13e2 	ldp	x2, x4, [sp, #176]
   85590:	a9000b84 	stp	x4, x2, [x28]
   85594:	b9416be1 	ldr	w1, [sp, #360]
   85598:	91004386 	add	x6, x28, #0x10
   8559c:	11000421 	add	w1, w1, #0x1
   855a0:	b9016be1 	str	w1, [sp, #360]
   855a4:	8b000040 	add	x0, x2, x0
   855a8:	f900bbe0 	str	x0, [sp, #368]
   855ac:	71001c3f 	cmp	w1, #0x7
   855b0:	54ff19ad 	b.le	838e4 <_svfprintf_r+0x724>
   855b4:	910583e2 	add	x2, sp, #0x160
   855b8:	aa1503e1 	mov	x1, x21
   855bc:	aa1303e0 	mov	x0, x19
   855c0:	b90093e9 	str	w9, [sp, #144]
   855c4:	29138feb 	stp	w11, w3, [sp, #156]
   855c8:	94002d4e 	bl	90b00 <__ssprint_r>
   855cc:	35ff2720 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   855d0:	f940bbe0 	ldr	x0, [sp, #368]
   855d4:	aa1603e6 	mov	x6, x22
   855d8:	b94093e9 	ldr	w9, [sp, #144]
   855dc:	29538feb 	ldp	w11, w3, [sp, #156]
   855e0:	b9413be2 	ldr	w2, [sp, #312]
   855e4:	b9416be1 	ldr	w1, [sp, #360]
   855e8:	17fff8be 	b	838e0 <_svfprintf_r+0x720>
   855ec:	b940cbe1 	ldr	w1, [sp, #200]
   855f0:	4b1a003a 	sub	w26, w1, w26
   855f4:	f9406be1 	ldr	x1, [sp, #208]
   855f8:	cb18003b 	sub	x27, x1, x24
   855fc:	6b1b035f 	cmp	w26, w27
   85600:	1a9bb35b 	csel	w27, w26, w27, lt	// lt = tstop
   85604:	17fffa36 	b	83edc <_svfprintf_r+0xd1c>
   85608:	37f850c0 	tbnz	w0, #31, 86020 <_svfprintf_r+0x2e60>
   8560c:	f94043e0 	ldr	x0, [sp, #128]
   85610:	91002c01 	add	x1, x0, #0xb
   85614:	927df021 	and	x1, x1, #0xfffffffffffffff8
   85618:	f90043e1 	str	x1, [sp, #128]
   8561c:	b9400000 	ldr	w0, [x0]
   85620:	52800021 	mov	w1, #0x1                   	// #1
   85624:	17fffb10 	b	84264 <_svfprintf_r+0x10a4>
   85628:	37f84ba0 	tbnz	w0, #31, 85f9c <_svfprintf_r+0x2ddc>
   8562c:	f94043e0 	ldr	x0, [sp, #128]
   85630:	91003c01 	add	x1, x0, #0xf
   85634:	927df021 	and	x1, x1, #0xfffffffffffffff8
   85638:	f90043e1 	str	x1, [sp, #128]
   8563c:	f9400000 	ldr	x0, [x0]
   85640:	7940f3e1 	ldrh	w1, [sp, #120]
   85644:	79000001 	strh	w1, [x0]
   85648:	17fff712 	b	83290 <_svfprintf_r+0xd0>
   8564c:	37f841e0 	tbnz	w0, #31, 85e88 <_svfprintf_r+0x2cc8>
   85650:	f94043e0 	ldr	x0, [sp, #128]
   85654:	91002c01 	add	x1, x0, #0xb
   85658:	927df021 	and	x1, x1, #0xfffffffffffffff8
   8565c:	f90043e1 	str	x1, [sp, #128]
   85660:	b9800000 	ldrsw	x0, [x0]
   85664:	aa0003e1 	mov	x1, x0
   85668:	17fffb23 	b	842f4 <_svfprintf_r+0x1134>
   8566c:	37f847e0 	tbnz	w0, #31, 85f68 <_svfprintf_r+0x2da8>
   85670:	f94043e0 	ldr	x0, [sp, #128]
   85674:	91002c01 	add	x1, x0, #0xb
   85678:	927df021 	and	x1, x1, #0xfffffffffffffff8
   8567c:	b9400000 	ldr	w0, [x0]
   85680:	f90043e1 	str	x1, [sp, #128]
   85684:	17fffb33 	b	84350 <_svfprintf_r+0x1190>
   85688:	37f845a0 	tbnz	w0, #31, 85f3c <_svfprintf_r+0x2d7c>
   8568c:	f94043e0 	ldr	x0, [sp, #128]
   85690:	91002c01 	add	x1, x0, #0xb
   85694:	927df021 	and	x1, x1, #0xfffffffffffffff8
   85698:	b9400000 	ldr	w0, [x0]
   8569c:	f90043e1 	str	x1, [sp, #128]
   856a0:	17fffd05 	b	84ab4 <_svfprintf_r+0x18f4>
   856a4:	f94057e2 	ldr	x2, [sp, #168]
   856a8:	b9409be0 	ldr	w0, [sp, #152]
   856ac:	b9009be1 	str	w1, [sp, #152]
   856b0:	8b20c040 	add	x0, x2, w0, sxtw
   856b4:	17fffac3 	b	841c0 <_svfprintf_r+0x1000>
   856b8:	aa1803e0 	mov	x0, x24
   856bc:	b900d3e9 	str	w9, [sp, #208]
   856c0:	b900dbeb 	str	w11, [sp, #216]
   856c4:	97fff4af 	bl	82980 <strlen>
   856c8:	3944bfe1 	ldrb	w1, [sp, #303]
   856cc:	7100001f 	cmp	w0, #0x0
   856d0:	2913ffff 	stp	wzr, wzr, [sp, #156]
   856d4:	2a0003fb 	mov	w27, w0
   856d8:	b940d3e9 	ldr	w9, [sp, #208]
   856dc:	1a9fa003 	csel	w3, w0, wzr, ge	// ge = tcont
   856e0:	b940dbeb 	ldr	w11, [sp, #216]
   856e4:	d2800017 	mov	x23, #0x0                   	// #0
   856e8:	52800007 	mov	w7, #0x0                   	// #0
   856ec:	52800e68 	mov	w8, #0x73                  	// #115
   856f0:	34fee681 	cbz	w1, 833c0 <_svfprintf_r+0x200>
   856f4:	17fff9b9 	b	83dd8 <_svfprintf_r+0xc18>
   856f8:	b9409be0 	ldr	w0, [sp, #152]
   856fc:	11002001 	add	w1, w0, #0x8
   85700:	7100003f 	cmp	w1, #0x0
   85704:	54003d6d 	b.le	85eb0 <_svfprintf_r+0x2cf0>
   85708:	f94043e0 	ldr	x0, [sp, #128]
   8570c:	b9009be1 	str	w1, [sp, #152]
   85710:	91002c02 	add	x2, x0, #0xb
   85714:	927df041 	and	x1, x2, #0xfffffffffffffff8
   85718:	f90043e1 	str	x1, [sp, #128]
   8571c:	17fffbce 	b	84654 <_svfprintf_r+0x1494>
   85720:	b9409be0 	ldr	w0, [sp, #152]
   85724:	11002001 	add	w1, w0, #0x8
   85728:	7100003f 	cmp	w1, #0x0
   8572c:	540033ad 	b.le	85da0 <_svfprintf_r+0x2be0>
   85730:	f94043e0 	ldr	x0, [sp, #128]
   85734:	b9009be1 	str	w1, [sp, #152]
   85738:	91002c02 	add	x2, x0, #0xb
   8573c:	927df041 	and	x1, x2, #0xfffffffffffffff8
   85740:	f90043e1 	str	x1, [sp, #128]
   85744:	17fffbbb 	b	84630 <_svfprintf_r+0x1470>
   85748:	b9409be0 	ldr	w0, [sp, #152]
   8574c:	11002001 	add	w1, w0, #0x8
   85750:	7100003f 	cmp	w1, #0x0
   85754:	5400330d 	b.le	85db4 <_svfprintf_r+0x2bf4>
   85758:	f94043e0 	ldr	x0, [sp, #128]
   8575c:	b9009be1 	str	w1, [sp, #152]
   85760:	91002c02 	add	x2, x0, #0xb
   85764:	927df041 	and	x1, x2, #0xfffffffffffffff8
   85768:	79400000 	ldrh	w0, [x0]
   8576c:	f90043e1 	str	x1, [sp, #128]
   85770:	17fffaf8 	b	84350 <_svfprintf_r+0x1190>
   85774:	b9409be0 	ldr	w0, [sp, #152]
   85778:	11002001 	add	w1, w0, #0x8
   8577c:	7100003f 	cmp	w1, #0x0
   85780:	5400470d 	b.le	86060 <_svfprintf_r+0x2ea0>
   85784:	f94043e0 	ldr	x0, [sp, #128]
   85788:	b9009be1 	str	w1, [sp, #152]
   8578c:	91002c02 	add	x2, x0, #0xb
   85790:	927df041 	and	x1, x2, #0xfffffffffffffff8
   85794:	79400000 	ldrh	w0, [x0]
   85798:	f90043e1 	str	x1, [sp, #128]
   8579c:	17fffcc6 	b	84ab4 <_svfprintf_r+0x18f4>
   857a0:	52800020 	mov	w0, #0x1                   	// #1
   857a4:	b9013be0 	str	w0, [sp, #312]
   857a8:	17fffd69 	b	84d4c <_svfprintf_r+0x1b8c>
   857ac:	11000761 	add	w1, w27, #0x1
   857b0:	aa1303e0 	mov	x0, x19
   857b4:	b90093e8 	str	w8, [sp, #144]
   857b8:	93407c21 	sxtw	x1, w1
   857bc:	2913afe9 	stp	w9, w11, [sp, #156]
   857c0:	94001770 	bl	8b580 <_malloc_r>
   857c4:	aa0003f8 	mov	x24, x0
   857c8:	b94093e8 	ldr	w8, [sp, #144]
   857cc:	2953afe9 	ldp	w9, w11, [sp, #156]
   857d0:	b4002640 	cbz	x0, 85c98 <_svfprintf_r+0x2ad8>
   857d4:	aa0003f7 	mov	x23, x0
   857d8:	17fffdd0 	b	84f18 <_svfprintf_r+0x1d58>
   857dc:	110004e1 	add	w1, w7, #0x1
   857e0:	aa1303e0 	mov	x0, x19
   857e4:	b90093e7 	str	w7, [sp, #144]
   857e8:	93407c21 	sxtw	x1, w1
   857ec:	2913afe8 	stp	w8, w11, [sp, #156]
   857f0:	b900cbe9 	str	w9, [sp, #200]
   857f4:	94001763 	bl	8b580 <_malloc_r>
   857f8:	b94093e7 	ldr	w7, [sp, #144]
   857fc:	aa0003f8 	mov	x24, x0
   85800:	2953afe8 	ldp	w8, w11, [sp, #156]
   85804:	b940cbe9 	ldr	w9, [sp, #200]
   85808:	b4002480 	cbz	x0, 85c98 <_svfprintf_r+0x2ad8>
   8580c:	aa0003f7 	mov	x23, x0
   85810:	17fffd3b 	b	84cfc <_svfprintf_r+0x1b3c>
   85814:	f9408be2 	ldr	x2, [sp, #272]
   85818:	b940ffe0 	ldr	w0, [sp, #252]
   8581c:	b900ffe1 	str	w1, [sp, #252]
   85820:	8b20c040 	add	x0, x2, w0, sxtw
   85824:	fd400008 	ldr	d8, [x0]
   85828:	17fff955 	b	83d7c <_svfprintf_r+0xbbc>
   8582c:	528000c7 	mov	w7, #0x6                   	// #6
   85830:	17fffe73 	b	851fc <_svfprintf_r+0x203c>
   85834:	f9408be2 	ldr	x2, [sp, #272]
   85838:	b940ffe0 	ldr	w0, [sp, #252]
   8583c:	b900ffe1 	str	w1, [sp, #252]
   85840:	8b20c040 	add	x0, x2, w0, sxtw
   85844:	17fff945 	b	83d58 <_svfprintf_r+0xb98>
   85848:	528005a0 	mov	w0, #0x2d                  	// #45
   8584c:	11000463 	add	w3, w3, #0x1
   85850:	528005a1 	mov	w1, #0x2d                  	// #45
   85854:	52800007 	mov	w7, #0x0                   	// #0
   85858:	3904bfe0 	strb	w0, [sp, #303]
   8585c:	17fff6d9 	b	833c0 <_svfprintf_r+0x200>
   85860:	b94093e1 	ldr	w1, [sp, #144]
   85864:	b940cbe2 	ldr	w2, [sp, #200]
   85868:	6b02003f 	cmp	w1, w2
   8586c:	5400128b 	b.lt	85abc <_svfprintf_r+0x28fc>  // b.tstop
   85870:	b94093e0 	ldr	w0, [sp, #144]
   85874:	f240013f 	tst	x9, #0x1
   85878:	b940b3e1 	ldr	w1, [sp, #176]
   8587c:	0b01000c 	add	w12, w0, w1
   85880:	1a80119b 	csel	w27, w12, w0, ne	// ne = any
   85884:	36500089 	tbz	w9, #10, 85894 <_svfprintf_r+0x26d4>
   85888:	b94093e0 	ldr	w0, [sp, #144]
   8588c:	7100001f 	cmp	w0, #0x0
   85890:	54002a8c 	b.gt	85de0 <_svfprintf_r+0x2c20>
   85894:	7100037f 	cmp	w27, #0x0
   85898:	52800ce8 	mov	w8, #0x67                  	// #103
   8589c:	1a9fa363 	csel	w3, w27, wzr, ge	// ge = tcont
   858a0:	2a1703e9 	mov	w9, w23
   858a4:	d2800017 	mov	x23, #0x0                   	// #0
   858a8:	2913ffff 	stp	wzr, wzr, [sp, #156]
   858ac:	17fffec4 	b	853bc <_svfprintf_r+0x21fc>
   858b0:	1e604120 	fmov	d0, d9
   858b4:	2a0703e2 	mov	w2, w7
   858b8:	910563e5 	add	x5, sp, #0x158
   858bc:	910543e4 	add	x4, sp, #0x150
   858c0:	9104e3e3 	add	x3, sp, #0x138
   858c4:	aa1303e0 	mov	x0, x19
   858c8:	52800061 	mov	w1, #0x3                   	// #3
   858cc:	b90093e7 	str	w7, [sp, #144]
   858d0:	2913afe8 	stp	w8, w11, [sp, #156]
   858d4:	b900cbe9 	str	w9, [sp, #200]
   858d8:	94002036 	bl	8d9b0 <_dtoa_r>
   858dc:	aa0003f8 	mov	x24, x0
   858e0:	39400000 	ldrb	w0, [x0]
   858e4:	2f00e400 	movi	d0, #0x0
   858e8:	b94093e7 	ldr	w7, [sp, #144]
   858ec:	7100c01f 	cmp	w0, #0x30
   858f0:	b940cbe9 	ldr	w9, [sp, #200]
   858f4:	2953afe8 	ldp	w8, w11, [sp, #156]
   858f8:	1e600524 	fccmp	d9, d0, #0x4, eq	// eq = none
   858fc:	54004a41 	b.ne	86244 <_svfprintf_r+0x3084>  // b.any
   85900:	b9413be0 	ldr	w0, [sp, #312]
   85904:	1e602128 	fcmp	d9, #0.0
   85908:	93407ce1 	sxtw	x1, w7
   8590c:	8b20c020 	add	x0, x1, w0, sxtw
   85910:	54001dc0 	b.eq	85cc8 <_svfprintf_r+0x2b08>  // b.none
   85914:	8b000302 	add	x2, x24, x0
   85918:	17fffe58 	b	85278 <_svfprintf_r+0x20b8>
   8591c:	b9409be0 	ldr	w0, [sp, #152]
   85920:	11002001 	add	w1, w0, #0x8
   85924:	7100003f 	cmp	w1, #0x0
   85928:	540022cd 	b.le	85d80 <_svfprintf_r+0x2bc0>
   8592c:	f94043e0 	ldr	x0, [sp, #128]
   85930:	b9009be1 	str	w1, [sp, #152]
   85934:	91002c02 	add	x2, x0, #0xb
   85938:	927df041 	and	x1, x2, #0xfffffffffffffff8
   8593c:	f90043e1 	str	x1, [sp, #128]
   85940:	17fffb80 	b	84740 <_svfprintf_r+0x1580>
   85944:	f94057e2 	ldr	x2, [sp, #168]
   85948:	b9409be0 	ldr	w0, [sp, #152]
   8594c:	b9009be1 	str	w1, [sp, #152]
   85950:	8b20c042 	add	x2, x2, w0, sxtw
   85954:	f94043e0 	ldr	x0, [sp, #128]
   85958:	f90043e2 	str	x2, [sp, #128]
   8595c:	17fffad7 	b	844b8 <_svfprintf_r+0x12f8>
   85960:	f94057e2 	ldr	x2, [sp, #168]
   85964:	b9409be0 	ldr	w0, [sp, #152]
   85968:	b9009be1 	str	w1, [sp, #152]
   8596c:	8b20c040 	add	x0, x2, w0, sxtw
   85970:	17fffa8a 	b	84398 <_svfprintf_r+0x11d8>
   85974:	f94057e2 	ldr	x2, [sp, #168]
   85978:	b9409be0 	ldr	w0, [sp, #152]
   8597c:	b9009be1 	str	w1, [sp, #152]
   85980:	8b20c040 	add	x0, x2, w0, sxtw
   85984:	17fff9dd 	b	840f8 <_svfprintf_r+0xf38>
   85988:	910583e2 	add	x2, sp, #0x160
   8598c:	aa1503e1 	mov	x1, x21
   85990:	aa1303e0 	mov	x0, x19
   85994:	94002c5b 	bl	90b00 <__ssprint_r>
   85998:	350000e0 	cbnz	w0, 859b4 <_svfprintf_r+0x27f4>
   8599c:	f940bbe0 	ldr	x0, [sp, #368]
   859a0:	90000083 	adrp	x3, 95000 <pmu_event_descr+0x60>
   859a4:	39400322 	ldrb	w2, [x25]
   859a8:	aa1603e1 	mov	x1, x22
   859ac:	911b8064 	add	x4, x3, #0x6e0
   859b0:	17fffc2b 	b	84a5c <_svfprintf_r+0x189c>
   859b4:	f9404bf7 	ldr	x23, [sp, #144]
   859b8:	17fff83e 	b	83ab0 <_svfprintf_r+0x8f0>
   859bc:	910583e2 	add	x2, sp, #0x160
   859c0:	aa1503e1 	mov	x1, x21
   859c4:	aa1303e0 	mov	x0, x19
   859c8:	b90093e9 	str	w9, [sp, #144]
   859cc:	29138feb 	stp	w11, w3, [sp, #156]
   859d0:	94002c4c 	bl	90b00 <__ssprint_r>
   859d4:	35ff06e0 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   859d8:	f940bbe0 	ldr	x0, [sp, #368]
   859dc:	aa1603fc 	mov	x28, x22
   859e0:	b94093e9 	ldr	w9, [sp, #144]
   859e4:	29538feb 	ldp	w11, w3, [sp, #156]
   859e8:	b9413bfa 	ldr	w26, [sp, #312]
   859ec:	17fff92a 	b	83e94 <_svfprintf_r+0xcd4>
   859f0:	f94077e1 	ldr	x1, [sp, #232]
   859f4:	b90093e8 	str	w8, [sp, #144]
   859f8:	f94083e0 	ldr	x0, [sp, #256]
   859fc:	b9009feb 	str	w11, [sp, #156]
   85a00:	f90053e3 	str	x3, [sp, #160]
   85a04:	cb000318 	sub	x24, x24, x0
   85a08:	aa0003e2 	mov	x2, x0
   85a0c:	aa1803e0 	mov	x0, x24
   85a10:	b900cbe7 	str	w7, [sp, #200]
   85a14:	a90d33e4 	stp	x4, x12, [sp, #208]
   85a18:	9400291e 	bl	8fe90 <strncpy>
   85a1c:	394006a0 	ldrb	w0, [x21, #1]
   85a20:	f94053e3 	ldr	x3, [sp, #160]
   85a24:	7100001f 	cmp	w0, #0x0
   85a28:	a94d33e4 	ldp	x4, x12, [sp, #208]
   85a2c:	9a9506b5 	cinc	x21, x21, ne	// ne = any
   85a30:	b94093e8 	ldr	w8, [sp, #144]
   85a34:	52800005 	mov	w5, #0x0                   	// #0
   85a38:	b9409feb 	ldr	w11, [sp, #156]
   85a3c:	b940cbe7 	ldr	w7, [sp, #200]
   85a40:	17fffd71 	b	85004 <_svfprintf_r+0x1e44>
   85a44:	2a1703e5 	mov	w5, w23
   85a48:	2a1903e3 	mov	w3, w25
   85a4c:	aa1a03f7 	mov	x23, x26
   85a50:	aa1c03f9 	mov	x25, x28
   85a54:	b94093e9 	ldr	w9, [sp, #144]
   85a58:	aa0203fc 	mov	x28, x2
   85a5c:	b9409feb 	ldr	w11, [sp, #156]
   85a60:	aa1803e4 	mov	x4, x24
   85a64:	2a0503fa 	mov	w26, w5
   85a68:	17fffd4d 	b	84f9c <_svfprintf_r+0x1ddc>
   85a6c:	f94057e2 	ldr	x2, [sp, #168]
   85a70:	b9409be0 	ldr	w0, [sp, #152]
   85a74:	b9009be1 	str	w1, [sp, #152]
   85a78:	8b20c040 	add	x0, x2, w0, sxtw
   85a7c:	17fffa65 	b	84410 <_svfprintf_r+0x1250>
   85a80:	910583e2 	add	x2, sp, #0x160
   85a84:	aa1503e1 	mov	x1, x21
   85a88:	aa1303e0 	mov	x0, x19
   85a8c:	b90093e9 	str	w9, [sp, #144]
   85a90:	29138feb 	stp	w11, w3, [sp, #156]
   85a94:	94002c1b 	bl	90b00 <__ssprint_r>
   85a98:	35ff00c0 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   85a9c:	b940cbe1 	ldr	w1, [sp, #200]
   85aa0:	aa1603fc 	mov	x28, x22
   85aa4:	b9413bfa 	ldr	w26, [sp, #312]
   85aa8:	f940bbe0 	ldr	x0, [sp, #368]
   85aac:	4b1a003a 	sub	w26, w1, w26
   85ab0:	b94093e9 	ldr	w9, [sp, #144]
   85ab4:	29538feb 	ldp	w11, w3, [sp, #156]
   85ab8:	17fff909 	b	83edc <_svfprintf_r+0xd1c>
   85abc:	b940b3e1 	ldr	w1, [sp, #176]
   85ac0:	52800ce8 	mov	w8, #0x67                  	// #103
   85ac4:	0b00003b 	add	w27, w1, w0
   85ac8:	b94093e0 	ldr	w0, [sp, #144]
   85acc:	7100001f 	cmp	w0, #0x0
   85ad0:	540000ad 	b.le	85ae4 <_svfprintf_r+0x2924>
   85ad4:	37501889 	tbnz	w9, #10, 85de4 <_svfprintf_r+0x2c24>
   85ad8:	7100037f 	cmp	w27, #0x0
   85adc:	1a9fa363 	csel	w3, w27, wzr, ge	// ge = tcont
   85ae0:	17ffff70 	b	858a0 <_svfprintf_r+0x26e0>
   85ae4:	4b00036c 	sub	w12, w27, w0
   85ae8:	3100059b 	adds	w27, w12, #0x1
   85aec:	1a9f5363 	csel	w3, w27, wzr, pl	// pl = nfrst
   85af0:	17ffff6c 	b	858a0 <_svfprintf_r+0x26e0>
   85af4:	90000084 	adrp	x4, 95000 <pmu_event_descr+0x60>
   85af8:	4b0203fa 	neg	w26, w2
   85afc:	911b8084 	add	x4, x4, #0x6e0
   85b00:	3100405f 	cmn	w2, #0x10
   85b04:	5400086a 	b.ge	85c10 <_svfprintf_r+0x2a50>  // b.tcont
   85b08:	aa1903e2 	mov	x2, x25
   85b0c:	2a0903fc 	mov	w28, w9
   85b10:	aa1703f9 	mov	x25, x23
   85b14:	d280021b 	mov	x27, #0x10                  	// #16
   85b18:	aa1503f7 	mov	x23, x21
   85b1c:	2a1a03f5 	mov	w21, w26
   85b20:	aa0203fa 	mov	x26, x2
   85b24:	f9004bf8 	str	x24, [sp, #144]
   85b28:	aa0403f8 	mov	x24, x4
   85b2c:	29138feb 	stp	w11, w3, [sp, #156]
   85b30:	14000004 	b	85b40 <_svfprintf_r+0x2980>
   85b34:	510042b5 	sub	w21, w21, #0x10
   85b38:	710042bf 	cmp	w21, #0x10
   85b3c:	5400058d 	b.le	85bec <_svfprintf_r+0x2a2c>
   85b40:	91004000 	add	x0, x0, #0x10
   85b44:	11000421 	add	w1, w1, #0x1
   85b48:	a9006cd8 	stp	x24, x27, [x6]
   85b4c:	910040c6 	add	x6, x6, #0x10
   85b50:	b9016be1 	str	w1, [sp, #360]
   85b54:	f900bbe0 	str	x0, [sp, #368]
   85b58:	71001c3f 	cmp	w1, #0x7
   85b5c:	54fffecd 	b.le	85b34 <_svfprintf_r+0x2974>
   85b60:	910583e2 	add	x2, sp, #0x160
   85b64:	aa1703e1 	mov	x1, x23
   85b68:	aa1303e0 	mov	x0, x19
   85b6c:	94002be5 	bl	90b00 <__ssprint_r>
   85b70:	35002c60 	cbnz	w0, 860fc <_svfprintf_r+0x2f3c>
   85b74:	f940bbe0 	ldr	x0, [sp, #368]
   85b78:	aa1603e6 	mov	x6, x22
   85b7c:	b9416be1 	ldr	w1, [sp, #360]
   85b80:	17ffffed 	b	85b34 <_svfprintf_r+0x2974>
   85b84:	1e604120 	fmov	d0, d9
   85b88:	2a0703e2 	mov	w2, w7
   85b8c:	910563e5 	add	x5, sp, #0x158
   85b90:	910543e4 	add	x4, sp, #0x150
   85b94:	9104e3e3 	add	x3, sp, #0x138
   85b98:	aa1303e0 	mov	x0, x19
   85b9c:	52800041 	mov	w1, #0x2                   	// #2
   85ba0:	b90093e7 	str	w7, [sp, #144]
   85ba4:	2913afe8 	stp	w8, w11, [sp, #156]
   85ba8:	b900cbe9 	str	w9, [sp, #200]
   85bac:	94001f81 	bl	8d9b0 <_dtoa_r>
   85bb0:	b940cbe9 	ldr	w9, [sp, #200]
   85bb4:	aa0003f8 	mov	x24, x0
   85bb8:	b94093e7 	ldr	w7, [sp, #144]
   85bbc:	2953afe8 	ldp	w8, w11, [sp, #156]
   85bc0:	360000a9 	tbz	w9, #0, 85bd4 <_svfprintf_r+0x2a14>
   85bc4:	1e602128 	fcmp	d9, #0.0
   85bc8:	54002a60 	b.eq	86114 <_svfprintf_r+0x2f54>  // b.none
   85bcc:	8b27c302 	add	x2, x24, w7, sxtw
   85bd0:	17fffdaa 	b	85278 <_svfprintf_r+0x20b8>
   85bd4:	f940afe0 	ldr	x0, [sp, #344]
   85bd8:	b9413be1 	ldr	w1, [sp, #312]
   85bdc:	cb180000 	sub	x0, x0, x24
   85be0:	b90093e1 	str	w1, [sp, #144]
   85be4:	b900cbe0 	str	w0, [sp, #200]
   85be8:	17fffdb4 	b	852b8 <_svfprintf_r+0x20f8>
   85bec:	aa1a03e2 	mov	x2, x26
   85bf0:	aa1803e4 	mov	x4, x24
   85bf4:	f9404bf8 	ldr	x24, [sp, #144]
   85bf8:	2a1503fa 	mov	w26, w21
   85bfc:	29538feb 	ldp	w11, w3, [sp, #156]
   85c00:	aa1703f5 	mov	x21, x23
   85c04:	2a1c03e9 	mov	w9, w28
   85c08:	aa1903f7 	mov	x23, x25
   85c0c:	aa0203f9 	mov	x25, x2
   85c10:	93407f5a 	sxtw	x26, w26
   85c14:	11000421 	add	w1, w1, #0x1
   85c18:	8b1a0000 	add	x0, x0, x26
   85c1c:	a90068c4 	stp	x4, x26, [x6]
   85c20:	910040c6 	add	x6, x6, #0x10
   85c24:	b9016be1 	str	w1, [sp, #360]
   85c28:	f900bbe0 	str	x0, [sp, #368]
   85c2c:	71001c3f 	cmp	w1, #0x7
   85c30:	54fee5ad 	b.le	838e4 <_svfprintf_r+0x724>
   85c34:	910583e2 	add	x2, sp, #0x160
   85c38:	aa1503e1 	mov	x1, x21
   85c3c:	aa1303e0 	mov	x0, x19
   85c40:	b90093e9 	str	w9, [sp, #144]
   85c44:	29138feb 	stp	w11, w3, [sp, #156]
   85c48:	94002bae 	bl	90b00 <__ssprint_r>
   85c4c:	35fef320 	cbnz	w0, 83ab0 <_svfprintf_r+0x8f0>
   85c50:	f940bbe0 	ldr	x0, [sp, #368]
   85c54:	aa1603e6 	mov	x6, x22
   85c58:	b94093e9 	ldr	w9, [sp, #144]
   85c5c:	29538feb 	ldp	w11, w3, [sp, #156]
   85c60:	b9416be1 	ldr	w1, [sp, #360]
   85c64:	17fff720 	b	838e4 <_svfprintf_r+0x724>
   85c68:	91050be1 	add	x1, sp, #0x142
   85c6c:	35000082 	cbnz	w2, 85c7c <_svfprintf_r+0x2abc>
   85c70:	91050fe1 	add	x1, sp, #0x143
   85c74:	52800602 	mov	w2, #0x30                  	// #48
   85c78:	39050be2 	strb	w2, [sp, #322]
   85c7c:	1100c000 	add	w0, w0, #0x30
   85c80:	38001420 	strb	w0, [x1], #1
   85c84:	910503e2 	add	x2, sp, #0x140
   85c88:	4b020020 	sub	w0, w1, w2
   85c8c:	b900cfe0 	str	w0, [sp, #204]
   85c90:	17fffdbf 	b	8538c <_svfprintf_r+0x21cc>
   85c94:	aa1903f5 	mov	x21, x25
   85c98:	a94363f7 	ldp	x23, x24, [sp, #48]
   85c9c:	a9446bf9 	ldp	x25, x26, [sp, #64]
   85ca0:	a94573fb 	ldp	x27, x28, [sp, #80]
   85ca4:	6d4627e8 	ldp	d8, d9, [sp, #96]
   85ca8:	794022a0 	ldrh	w0, [x21, #16]
   85cac:	321a0000 	orr	w0, w0, #0x40
   85cb0:	790022a0 	strh	w0, [x21, #16]
   85cb4:	12800000 	mov	w0, #0xffffffff            	// #-1
   85cb8:	b9007be0 	str	w0, [sp, #120]
   85cbc:	17fff788 	b	83adc <_svfprintf_r+0x91c>
   85cc0:	3607b729 	tbz	w9, #0, 853a4 <_svfprintf_r+0x21e4>
   85cc4:	17fffdb6 	b	8539c <_svfprintf_r+0x21dc>
   85cc8:	b9413be1 	ldr	w1, [sp, #312]
   85ccc:	b900cbe0 	str	w0, [sp, #200]
   85cd0:	12000120 	and	w0, w9, #0x1
   85cd4:	b90093e1 	str	w1, [sp, #144]
   85cd8:	2a070000 	orr	w0, w0, w7
   85cdc:	7100003f 	cmp	w1, #0x0
   85ce0:	540025cd 	b.le	86198 <_svfprintf_r+0x2fd8>
   85ce4:	35000740 	cbnz	w0, 85dcc <_svfprintf_r+0x2c0c>
   85ce8:	b94093fb 	ldr	w27, [sp, #144]
   85cec:	52800cc8 	mov	w8, #0x66                  	// #102
   85cf0:	17ffff79 	b	85ad4 <_svfprintf_r+0x2914>
   85cf4:	f900afec 	str	x12, [sp, #344]
   85cf8:	aa0003e1 	mov	x1, x0
   85cfc:	39403c44 	ldrb	w4, [x2, #15]
   85d00:	385ff003 	ldurb	w3, [x0, #-1]
   85d04:	6b04007f 	cmp	w3, w4
   85d08:	54000121 	b.ne	85d2c <_svfprintf_r+0x2b6c>  // b.any
   85d0c:	52800607 	mov	w7, #0x30                  	// #48
   85d10:	381ff027 	sturb	w7, [x1, #-1]
   85d14:	f940afe1 	ldr	x1, [sp, #344]
   85d18:	d1000423 	sub	x3, x1, #0x1
   85d1c:	f900afe3 	str	x3, [sp, #344]
   85d20:	385ff023 	ldurb	w3, [x1, #-1]
   85d24:	6b04007f 	cmp	w3, w4
   85d28:	54ffff40 	b.eq	85d10 <_svfprintf_r+0x2b50>  // b.none
   85d2c:	11000464 	add	w4, w3, #0x1
   85d30:	12001c84 	and	w4, w4, #0xff
   85d34:	7100e47f 	cmp	w3, #0x39
   85d38:	540002e0 	b.eq	85d94 <_svfprintf_r+0x2bd4>  // b.none
   85d3c:	381ff024 	sturb	w4, [x1, #-1]
   85d40:	b9413be1 	ldr	w1, [sp, #312]
   85d44:	4b180000 	sub	w0, w0, w24
   85d48:	b90093e1 	str	w1, [sp, #144]
   85d4c:	b900cbe0 	str	w0, [sp, #200]
   85d50:	17fffc28 	b	84df0 <_svfprintf_r+0x1c30>
   85d54:	aa1b03f7 	mov	x23, x27
   85d58:	17fff756 	b	83ab0 <_svfprintf_r+0x8f0>
   85d5c:	37f81960 	tbnz	w0, #31, 86088 <_svfprintf_r+0x2ec8>
   85d60:	f94043e0 	ldr	x0, [sp, #128]
   85d64:	91003c01 	add	x1, x0, #0xf
   85d68:	927df021 	and	x1, x1, #0xfffffffffffffff8
   85d6c:	f90043e1 	str	x1, [sp, #128]
   85d70:	f9400000 	ldr	x0, [x0]
   85d74:	b9407be1 	ldr	w1, [sp, #120]
   85d78:	b9000001 	str	w1, [x0]
   85d7c:	17fff545 	b	83290 <_svfprintf_r+0xd0>
   85d80:	f94057e2 	ldr	x2, [sp, #168]
   85d84:	b9409be0 	ldr	w0, [sp, #152]
   85d88:	b9009be1 	str	w1, [sp, #152]
   85d8c:	8b20c040 	add	x0, x2, w0, sxtw
   85d90:	17fffa6c 	b	84740 <_svfprintf_r+0x1580>
   85d94:	39402844 	ldrb	w4, [x2, #10]
   85d98:	381ff024 	sturb	w4, [x1, #-1]
   85d9c:	17ffffe9 	b	85d40 <_svfprintf_r+0x2b80>
   85da0:	f94057e2 	ldr	x2, [sp, #168]
   85da4:	b9409be0 	ldr	w0, [sp, #152]
   85da8:	b9009be1 	str	w1, [sp, #152]
   85dac:	8b20c040 	add	x0, x2, w0, sxtw
   85db0:	17fffa20 	b	84630 <_svfprintf_r+0x1470>
   85db4:	f94057e2 	ldr	x2, [sp, #168]
   85db8:	b9409be0 	ldr	w0, [sp, #152]
   85dbc:	b9009be1 	str	w1, [sp, #152]
   85dc0:	8b20c040 	add	x0, x2, w0, sxtw
   85dc4:	79400000 	ldrh	w0, [x0]
   85dc8:	17fff962 	b	84350 <_svfprintf_r+0x1190>
   85dcc:	b940b3e0 	ldr	w0, [sp, #176]
   85dd0:	52800cc8 	mov	w8, #0x66                  	// #102
   85dd4:	0b00002c 	add	w12, w1, w0
   85dd8:	0b07019b 	add	w27, w12, w7
   85ddc:	17ffff3e 	b	85ad4 <_svfprintf_r+0x2914>
   85de0:	52800ce8 	mov	w8, #0x67                  	// #103
   85de4:	f9407be2 	ldr	x2, [sp, #240]
   85de8:	39400040 	ldrb	w0, [x2]
   85dec:	7103fc1f 	cmp	w0, #0xff
   85df0:	540026c0 	b.eq	862c8 <_svfprintf_r+0x3108>  // b.none
   85df4:	b94093e1 	ldr	w1, [sp, #144]
   85df8:	52800004 	mov	w4, #0x0                   	// #0
   85dfc:	52800003 	mov	w3, #0x0                   	// #0
   85e00:	14000005 	b	85e14 <_svfprintf_r+0x2c54>
   85e04:	11000463 	add	w3, w3, #0x1
   85e08:	91000442 	add	x2, x2, #0x1
   85e0c:	7103fc1f 	cmp	w0, #0xff
   85e10:	54000120 	b.eq	85e34 <_svfprintf_r+0x2c74>  // b.none
   85e14:	6b01001f 	cmp	w0, w1
   85e18:	540000ea 	b.ge	85e34 <_svfprintf_r+0x2c74>  // b.tcont
   85e1c:	4b000021 	sub	w1, w1, w0
   85e20:	39400440 	ldrb	w0, [x2, #1]
   85e24:	35ffff00 	cbnz	w0, 85e04 <_svfprintf_r+0x2c44>
   85e28:	39400040 	ldrb	w0, [x2]
   85e2c:	11000484 	add	w4, w4, #0x1
   85e30:	17fffff7 	b	85e0c <_svfprintf_r+0x2c4c>
   85e34:	b90093e1 	str	w1, [sp, #144]
   85e38:	291393e3 	stp	w3, w4, [sp, #156]
   85e3c:	f9007be2 	str	x2, [sp, #240]
   85e40:	295383e1 	ldp	w1, w0, [sp, #156]
   85e44:	2a1703e9 	mov	w9, w23
   85e48:	d2800017 	mov	x23, #0x0                   	// #0
   85e4c:	0b010000 	add	w0, w0, w1
   85e50:	b94103e1 	ldr	w1, [sp, #256]
   85e54:	1b016c1b 	madd	w27, w0, w1, w27
   85e58:	7100037f 	cmp	w27, #0x0
   85e5c:	1a9fa363 	csel	w3, w27, wzr, ge	// ge = tcont
   85e60:	17fffd57 	b	853bc <_svfprintf_r+0x21fc>
   85e64:	9e660100 	fmov	x0, d8
   85e68:	b7f81380 	tbnz	x0, #63, 860d8 <_svfprintf_r+0x2f18>
   85e6c:	3944bfe1 	ldrb	w1, [sp, #303]
   85e70:	90000080 	adrp	x0, 95000 <pmu_event_descr+0x60>
   85e74:	90000085 	adrp	x5, 95000 <pmu_event_descr+0x60>
   85e78:	7101211f 	cmp	w8, #0x48
   85e7c:	91178000 	add	x0, x0, #0x5e0
   85e80:	911760a5 	add	x5, x5, #0x5d8
   85e84:	17fff7cb 	b	83db0 <_svfprintf_r+0xbf0>
   85e88:	b9409be0 	ldr	w0, [sp, #152]
   85e8c:	11002001 	add	w1, w0, #0x8
   85e90:	7100003f 	cmp	w1, #0x0
   85e94:	540014ad 	b.le	86128 <_svfprintf_r+0x2f68>
   85e98:	f94043e0 	ldr	x0, [sp, #128]
   85e9c:	b9009be1 	str	w1, [sp, #152]
   85ea0:	91002c02 	add	x2, x0, #0xb
   85ea4:	927df041 	and	x1, x2, #0xfffffffffffffff8
   85ea8:	f90043e1 	str	x1, [sp, #128]
   85eac:	17fffded 	b	85660 <_svfprintf_r+0x24a0>
   85eb0:	f94057e2 	ldr	x2, [sp, #168]
   85eb4:	b9409be0 	ldr	w0, [sp, #152]
   85eb8:	b9009be1 	str	w1, [sp, #152]
   85ebc:	8b20c040 	add	x0, x2, w0, sxtw
   85ec0:	17fff9e5 	b	84654 <_svfprintf_r+0x1494>
   85ec4:	b9409be0 	ldr	w0, [sp, #152]
   85ec8:	11002001 	add	w1, w0, #0x8
   85ecc:	7100003f 	cmp	w1, #0x0
   85ed0:	5400142d 	b.le	86154 <_svfprintf_r+0x2f94>
   85ed4:	f94043e0 	ldr	x0, [sp, #128]
   85ed8:	b9009be1 	str	w1, [sp, #152]
   85edc:	91002c02 	add	x2, x0, #0xb
   85ee0:	927df041 	and	x1, x2, #0xfffffffffffffff8
   85ee4:	39400000 	ldrb	w0, [x0]
   85ee8:	f90043e1 	str	x1, [sp, #128]
   85eec:	17fffaf2 	b	84ab4 <_svfprintf_r+0x18f4>
   85ef0:	3944bfe1 	ldrb	w1, [sp, #303]
   85ef4:	2a0703e3 	mov	w3, w7
   85ef8:	2913ffff 	stp	wzr, wzr, [sp, #156]
   85efc:	2a0703fb 	mov	w27, w7
   85f00:	52800e68 	mov	w8, #0x73                  	// #115
   85f04:	52800007 	mov	w7, #0x0                   	// #0
   85f08:	34fea5c1 	cbz	w1, 833c0 <_svfprintf_r+0x200>
   85f0c:	17fff7b3 	b	83dd8 <_svfprintf_r+0xc18>
   85f10:	b9409be0 	ldr	w0, [sp, #152]
   85f14:	11002001 	add	w1, w0, #0x8
   85f18:	7100003f 	cmp	w1, #0x0
   85f1c:	5400128d 	b.le	8616c <_svfprintf_r+0x2fac>
   85f20:	f94043e0 	ldr	x0, [sp, #128]
   85f24:	b9009be1 	str	w1, [sp, #152]
   85f28:	91002c02 	add	x2, x0, #0xb
   85f2c:	927df041 	and	x1, x2, #0xfffffffffffffff8
   85f30:	39400000 	ldrb	w0, [x0]
   85f34:	f90043e1 	str	x1, [sp, #128]
   85f38:	17fff906 	b	84350 <_svfprintf_r+0x1190>
   85f3c:	b9409be0 	ldr	w0, [sp, #152]
   85f40:	11002001 	add	w1, w0, #0x8
   85f44:	7100003f 	cmp	w1, #0x0
   85f48:	54000fad 	b.le	8613c <_svfprintf_r+0x2f7c>
   85f4c:	f94043e0 	ldr	x0, [sp, #128]
   85f50:	b9009be1 	str	w1, [sp, #152]
   85f54:	91002c02 	add	x2, x0, #0xb
   85f58:	927df041 	and	x1, x2, #0xfffffffffffffff8
   85f5c:	b9400000 	ldr	w0, [x0]
   85f60:	f90043e1 	str	x1, [sp, #128]
   85f64:	17fffad4 	b	84ab4 <_svfprintf_r+0x18f4>
   85f68:	b9409be0 	ldr	w0, [sp, #152]
   85f6c:	11002001 	add	w1, w0, #0x8
   85f70:	7100003f 	cmp	w1, #0x0
   85f74:	5400170d 	b.le	86254 <_svfprintf_r+0x3094>
   85f78:	f94043e0 	ldr	x0, [sp, #128]
   85f7c:	b9009be1 	str	w1, [sp, #152]
   85f80:	91002c02 	add	x2, x0, #0xb
   85f84:	927df041 	and	x1, x2, #0xfffffffffffffff8
   85f88:	b9400000 	ldr	w0, [x0]
   85f8c:	f90043e1 	str	x1, [sp, #128]
   85f90:	17fff8f0 	b	84350 <_svfprintf_r+0x1190>
   85f94:	aa1a03f7 	mov	x23, x26
   85f98:	17fff6c6 	b	83ab0 <_svfprintf_r+0x8f0>
   85f9c:	b9409be0 	ldr	w0, [sp, #152]
   85fa0:	11002001 	add	w1, w0, #0x8
   85fa4:	7100003f 	cmp	w1, #0x0
   85fa8:	5400172d 	b.le	8628c <_svfprintf_r+0x30cc>
   85fac:	f94043e0 	ldr	x0, [sp, #128]
   85fb0:	b9009be1 	str	w1, [sp, #152]
   85fb4:	91003c02 	add	x2, x0, #0xf
   85fb8:	927df041 	and	x1, x2, #0xfffffffffffffff8
   85fbc:	f90043e1 	str	x1, [sp, #128]
   85fc0:	17fffd9f 	b	8563c <_svfprintf_r+0x247c>
   85fc4:	b9409be0 	ldr	w0, [sp, #152]
   85fc8:	11002001 	add	w1, w0, #0x8
   85fcc:	7100003f 	cmp	w1, #0x0
   85fd0:	5400154d 	b.le	86278 <_svfprintf_r+0x30b8>
   85fd4:	f94043e0 	ldr	x0, [sp, #128]
   85fd8:	b9009be1 	str	w1, [sp, #152]
   85fdc:	91002c02 	add	x2, x0, #0xb
   85fe0:	927df041 	and	x1, x2, #0xfffffffffffffff8
   85fe4:	f90043e1 	str	x1, [sp, #128]
   85fe8:	17fffc46 	b	85100 <_svfprintf_r+0x1f40>
   85fec:	0b1800e3 	add	w3, w7, w24
   85ff0:	4b000063 	sub	w3, w3, w0
   85ff4:	17fffb6e 	b	84dac <_svfprintf_r+0x1bec>
   85ff8:	b9409be0 	ldr	w0, [sp, #152]
   85ffc:	11002001 	add	w1, w0, #0x8
   86000:	7100003f 	cmp	w1, #0x0
   86004:	540014ed 	b.le	862a0 <_svfprintf_r+0x30e0>
   86008:	f94043e0 	ldr	x0, [sp, #128]
   8600c:	b9009be1 	str	w1, [sp, #152]
   86010:	91002c02 	add	x2, x0, #0xb
   86014:	927df041 	and	x1, x2, #0xfffffffffffffff8
   86018:	f90043e1 	str	x1, [sp, #128]
   8601c:	17fffc5e 	b	85194 <_svfprintf_r+0x1fd4>
   86020:	b9409be0 	ldr	w0, [sp, #152]
   86024:	11002001 	add	w1, w0, #0x8
   86028:	7100003f 	cmp	w1, #0x0
   8602c:	54000f2d 	b.le	86210 <_svfprintf_r+0x3050>
   86030:	f94043e0 	ldr	x0, [sp, #128]
   86034:	b9009be1 	str	w1, [sp, #152]
   86038:	91002c02 	add	x2, x0, #0xb
   8603c:	927df041 	and	x1, x2, #0xfffffffffffffff8
   86040:	f90043e1 	str	x1, [sp, #128]
   86044:	17fffd76 	b	8561c <_svfprintf_r+0x245c>
   86048:	aa1903f5 	mov	x21, x25
   8604c:	b94093e8 	ldr	w8, [sp, #144]
   86050:	aa1b03f9 	mov	x25, x27
   86054:	2a1a03fb 	mov	w27, w26
   86058:	2953afe9 	ldp	w9, w11, [sp, #156]
   8605c:	17fffbaa 	b	84f04 <_svfprintf_r+0x1d44>
   86060:	f94057e2 	ldr	x2, [sp, #168]
   86064:	b9409be0 	ldr	w0, [sp, #152]
   86068:	b9009be1 	str	w1, [sp, #152]
   8606c:	8b20c040 	add	x0, x2, w0, sxtw
   86070:	79400000 	ldrh	w0, [x0]
   86074:	17fffa90 	b	84ab4 <_svfprintf_r+0x18f4>
   86078:	528005a0 	mov	w0, #0x2d                  	// #45
   8607c:	1e614109 	fneg	d9, d8
   86080:	b900d3e0 	str	w0, [sp, #208]
   86084:	17fffc64 	b	85214 <_svfprintf_r+0x2054>
   86088:	b9409be0 	ldr	w0, [sp, #152]
   8608c:	11002001 	add	w1, w0, #0x8
   86090:	7100003f 	cmp	w1, #0x0
   86094:	5400078d 	b.le	86184 <_svfprintf_r+0x2fc4>
   86098:	f94043e0 	ldr	x0, [sp, #128]
   8609c:	b9009be1 	str	w1, [sp, #152]
   860a0:	91003c02 	add	x2, x0, #0xf
   860a4:	927df041 	and	x1, x2, #0xfffffffffffffff8
   860a8:	f90043e1 	str	x1, [sp, #128]
   860ac:	17ffff31 	b	85d70 <_svfprintf_r+0x2bb0>
   860b0:	b9409be0 	ldr	w0, [sp, #152]
   860b4:	11002001 	add	w1, w0, #0x8
   860b8:	7100003f 	cmp	w1, #0x0
   860bc:	5400084d 	b.le	861c4 <_svfprintf_r+0x3004>
   860c0:	f94043e0 	ldr	x0, [sp, #128]
   860c4:	b9009be1 	str	w1, [sp, #152]
   860c8:	91003c02 	add	x2, x0, #0xf
   860cc:	927df041 	and	x1, x2, #0xfffffffffffffff8
   860d0:	f90043e1 	str	x1, [sp, #128]
   860d4:	17fff8c6 	b	843ec <_svfprintf_r+0x122c>
   860d8:	528005a0 	mov	w0, #0x2d                  	// #45
   860dc:	528005a1 	mov	w1, #0x2d                  	// #45
   860e0:	3904bfe0 	strb	w0, [sp, #303]
   860e4:	17ffff63 	b	85e70 <_svfprintf_r+0x2cb0>
   860e8:	71011b7f 	cmp	w27, #0x46
   860ec:	54ffdf20 	b.eq	85cd0 <_svfprintf_r+0x2b10>  // b.none
   860f0:	b94093e0 	ldr	w0, [sp, #144]
   860f4:	51000400 	sub	w0, w0, #0x1
   860f8:	17fffc76 	b	852d0 <_svfprintf_r+0x2110>
   860fc:	aa1703f5 	mov	x21, x23
   86100:	aa1903f7 	mov	x23, x25
   86104:	17fff66b 	b	83ab0 <_svfprintf_r+0x8f0>
   86108:	b9413be0 	ldr	w0, [sp, #312]
   8610c:	b90093e0 	str	w0, [sp, #144]
   86110:	17fffff8 	b	860f0 <_svfprintf_r+0x2f30>
   86114:	b9413be0 	ldr	w0, [sp, #312]
   86118:	b90093e0 	str	w0, [sp, #144]
   8611c:	93407ce0 	sxtw	x0, w7
   86120:	b900cbe7 	str	w7, [sp, #200]
   86124:	17fffc65 	b	852b8 <_svfprintf_r+0x20f8>
   86128:	f94057e2 	ldr	x2, [sp, #168]
   8612c:	b9409be0 	ldr	w0, [sp, #152]
   86130:	b9009be1 	str	w1, [sp, #152]
   86134:	8b20c040 	add	x0, x2, w0, sxtw
   86138:	17fffd4a 	b	85660 <_svfprintf_r+0x24a0>
   8613c:	f94057e2 	ldr	x2, [sp, #168]
   86140:	b9409be0 	ldr	w0, [sp, #152]
   86144:	b9009be1 	str	w1, [sp, #152]
   86148:	8b20c040 	add	x0, x2, w0, sxtw
   8614c:	b9400000 	ldr	w0, [x0]
   86150:	17fffa59 	b	84ab4 <_svfprintf_r+0x18f4>
   86154:	f94057e2 	ldr	x2, [sp, #168]
   86158:	b9409be0 	ldr	w0, [sp, #152]
   8615c:	b9009be1 	str	w1, [sp, #152]
   86160:	8b20c040 	add	x0, x2, w0, sxtw
   86164:	39400000 	ldrb	w0, [x0]
   86168:	17fffa53 	b	84ab4 <_svfprintf_r+0x18f4>
   8616c:	f94057e2 	ldr	x2, [sp, #168]
   86170:	b9409be0 	ldr	w0, [sp, #152]
   86174:	b9009be1 	str	w1, [sp, #152]
   86178:	8b20c040 	add	x0, x2, w0, sxtw
   8617c:	39400000 	ldrb	w0, [x0]
   86180:	17fff874 	b	84350 <_svfprintf_r+0x1190>
   86184:	f94057e2 	ldr	x2, [sp, #168]
   86188:	b9409be0 	ldr	w0, [sp, #152]
   8618c:	b9009be1 	str	w1, [sp, #152]
   86190:	8b20c040 	add	x0, x2, w0, sxtw
   86194:	17fffef7 	b	85d70 <_svfprintf_r+0x2bb0>
   86198:	350000a0 	cbnz	w0, 861ac <_svfprintf_r+0x2fec>
   8619c:	52800023 	mov	w3, #0x1                   	// #1
   861a0:	52800cc8 	mov	w8, #0x66                  	// #102
   861a4:	2a0303fb 	mov	w27, w3
   861a8:	17fffdbe 	b	858a0 <_svfprintf_r+0x26e0>
   861ac:	b940b3e0 	ldr	w0, [sp, #176]
   861b0:	52800cc8 	mov	w8, #0x66                  	// #102
   861b4:	1100040c 	add	w12, w0, #0x1
   861b8:	2b07019b 	adds	w27, w12, w7
   861bc:	1a9f5363 	csel	w3, w27, wzr, pl	// pl = nfrst
   861c0:	17fffdb8 	b	858a0 <_svfprintf_r+0x26e0>
   861c4:	f94057e2 	ldr	x2, [sp, #168]
   861c8:	b9409be0 	ldr	w0, [sp, #152]
   861cc:	b9009be1 	str	w1, [sp, #152]
   861d0:	8b20c040 	add	x0, x2, w0, sxtw
   861d4:	17fff886 	b	843ec <_svfprintf_r+0x122c>
   861d8:	b9409be2 	ldr	w2, [sp, #152]
   861dc:	37f80242 	tbnz	w2, #31, 86224 <_svfprintf_r+0x3064>
   861e0:	f94043e0 	ldr	x0, [sp, #128]
   861e4:	91002c00 	add	x0, x0, #0xb
   861e8:	927df000 	and	x0, x0, #0xfffffffffffffff8
   861ec:	f94043e3 	ldr	x3, [sp, #128]
   861f0:	f90043e0 	str	x0, [sp, #128]
   861f4:	39400728 	ldrb	w8, [x25, #1]
   861f8:	aa0103f9 	mov	x25, x1
   861fc:	b9009be2 	str	w2, [sp, #152]
   86200:	b9400067 	ldr	w7, [x3]
   86204:	710000ff 	cmp	w7, #0x0
   86208:	5a9fa0fa 	csinv	w26, w7, wzr, ge	// ge = tcont
   8620c:	17fff457 	b	83368 <_svfprintf_r+0x1a8>
   86210:	f94057e2 	ldr	x2, [sp, #168]
   86214:	b9409be0 	ldr	w0, [sp, #152]
   86218:	b9009be1 	str	w1, [sp, #152]
   8621c:	8b20c040 	add	x0, x2, w0, sxtw
   86220:	17fffcff 	b	8561c <_svfprintf_r+0x245c>
   86224:	b9409be0 	ldr	w0, [sp, #152]
   86228:	11002002 	add	w2, w0, #0x8
   8622c:	f94043e0 	ldr	x0, [sp, #128]
   86230:	7100005f 	cmp	w2, #0x0
   86234:	5400040d 	b.le	862b4 <_svfprintf_r+0x30f4>
   86238:	91002c00 	add	x0, x0, #0xb
   8623c:	927df000 	and	x0, x0, #0xfffffffffffffff8
   86240:	17ffffeb 	b	861ec <_svfprintf_r+0x302c>
   86244:	52800020 	mov	w0, #0x1                   	// #1
   86248:	4b070000 	sub	w0, w0, w7
   8624c:	b9013be0 	str	w0, [sp, #312]
   86250:	17fffdad 	b	85904 <_svfprintf_r+0x2744>
   86254:	f94057e2 	ldr	x2, [sp, #168]
   86258:	b9409be0 	ldr	w0, [sp, #152]
   8625c:	b9009be1 	str	w1, [sp, #152]
   86260:	8b20c040 	add	x0, x2, w0, sxtw
   86264:	b9400000 	ldr	w0, [x0]
   86268:	17fff83a 	b	84350 <_svfprintf_r+0x1190>
   8626c:	52800040 	mov	w0, #0x2                   	// #2
   86270:	b900cfe0 	str	w0, [sp, #204]
   86274:	17fffc46 	b	8538c <_svfprintf_r+0x21cc>
   86278:	f94057e2 	ldr	x2, [sp, #168]
   8627c:	b9409be0 	ldr	w0, [sp, #152]
   86280:	b9009be1 	str	w1, [sp, #152]
   86284:	8b20c040 	add	x0, x2, w0, sxtw
   86288:	17fffb9e 	b	85100 <_svfprintf_r+0x1f40>
   8628c:	f94057e2 	ldr	x2, [sp, #168]
   86290:	b9409be0 	ldr	w0, [sp, #152]
   86294:	b9009be1 	str	w1, [sp, #152]
   86298:	8b20c040 	add	x0, x2, w0, sxtw
   8629c:	17fffce8 	b	8563c <_svfprintf_r+0x247c>
   862a0:	f94057e2 	ldr	x2, [sp, #168]
   862a4:	b9409be0 	ldr	w0, [sp, #152]
   862a8:	b9009be1 	str	w1, [sp, #152]
   862ac:	8b20c040 	add	x0, x2, w0, sxtw
   862b0:	17fffbb9 	b	85194 <_svfprintf_r+0x1fd4>
   862b4:	f94057e4 	ldr	x4, [sp, #168]
   862b8:	b9409be3 	ldr	w3, [sp, #152]
   862bc:	8b23c083 	add	x3, x4, w3, sxtw
   862c0:	f90043e3 	str	x3, [sp, #128]
   862c4:	17ffffca 	b	861ec <_svfprintf_r+0x302c>
   862c8:	2913ffff 	stp	wzr, wzr, [sp, #156]
   862cc:	17fffedd 	b	85e40 <_svfprintf_r+0x2c80>
   862d0:	52800180 	mov	w0, #0xc                   	// #12
   862d4:	b9000260 	str	w0, [x19]
   862d8:	17fffe77 	b	85cb4 <_svfprintf_r+0x2af4>
   862dc:	794022a0 	ldrh	w0, [x21, #16]
   862e0:	321a0000 	orr	w0, w0, #0x40
   862e4:	790022a0 	strh	w0, [x21, #16]
   862e8:	17fff5f2 	b	83ab0 <_svfprintf_r+0x8f0>
   862ec:	00000000 	udf	#0

00000000000862f0 <_vfprintf_r>:
   862f0:	d10a03ff 	sub	sp, sp, #0x280
   862f4:	a9007bfd 	stp	x29, x30, [sp]
   862f8:	910003fd 	mov	x29, sp
   862fc:	a9025bf5 	stp	x21, x22, [sp, #32]
   86300:	aa0103f5 	mov	x21, x1
   86304:	f9400061 	ldr	x1, [x3]
   86308:	f90043e1 	str	x1, [sp, #128]
   8630c:	f9400461 	ldr	x1, [x3, #8]
   86310:	f90057e1 	str	x1, [sp, #168]
   86314:	f9400861 	ldr	x1, [x3, #16]
   86318:	f90087e1 	str	x1, [sp, #264]
   8631c:	b9401861 	ldr	w1, [x3, #24]
   86320:	b9007fe1 	str	w1, [sp, #124]
   86324:	b9401c61 	ldr	w1, [x3, #28]
   86328:	a90153f3 	stp	x19, x20, [sp, #16]
   8632c:	aa0303f4 	mov	x20, x3
   86330:	aa0003f3 	mov	x19, x0
   86334:	f9003be2 	str	x2, [sp, #112]
   86338:	b900efe1 	str	w1, [sp, #236]
   8633c:	94001a45 	bl	8cc50 <_localeconv_r>
   86340:	f9400000 	ldr	x0, [x0]
   86344:	f9005fe0 	str	x0, [sp, #184]
   86348:	97fff18e 	bl	82980 <strlen>
   8634c:	f9005be0 	str	x0, [sp, #176]
   86350:	d2800102 	mov	x2, #0x8                   	// #8
   86354:	9105a3e0 	add	x0, sp, #0x168
   86358:	52800001 	mov	w1, #0x0                   	// #0
   8635c:	94001c99 	bl	8d5c0 <memset>
   86360:	f9403be9 	ldr	x9, [sp, #112]
   86364:	b4000073 	cbz	x19, 86370 <_vfprintf_r+0x80>
   86368:	f9402660 	ldr	x0, [x19, #72]
   8636c:	b400c7c0 	cbz	x0, 87c64 <_vfprintf_r+0x1974>
   86370:	b940b2a1 	ldr	w1, [x21, #176]
   86374:	79c022a0 	ldrsh	w0, [x21, #16]
   86378:	37000041 	tbnz	w1, #0, 86380 <_vfprintf_r+0x90>
   8637c:	3648a3a0 	tbz	w0, #9, 877f0 <_vfprintf_r+0x1500>
   86380:	376800c0 	tbnz	w0, #13, 86398 <_vfprintf_r+0xa8>
   86384:	b940b2a1 	ldr	w1, [x21, #176]
   86388:	32130000 	orr	w0, w0, #0x2000
   8638c:	790022a0 	strh	w0, [x21, #16]
   86390:	12127821 	and	w1, w1, #0xffffdfff
   86394:	b900b2a1 	str	w1, [x21, #176]
   86398:	361805e0 	tbz	w0, #3, 86454 <_vfprintf_r+0x164>
   8639c:	f9400ea1 	ldr	x1, [x21, #24]
   863a0:	b40005a1 	cbz	x1, 86454 <_vfprintf_r+0x164>
   863a4:	52800341 	mov	w1, #0x1a                  	// #26
   863a8:	0a010001 	and	w1, w0, w1
   863ac:	7100283f 	cmp	w1, #0xa
   863b0:	54000680 	b.eq	86480 <_vfprintf_r+0x190>  // b.none
   863b4:	910803f6 	add	x22, sp, #0x200
   863b8:	6d0627e8 	stp	d8, d9, [sp, #96]
   863bc:	2f00e408 	movi	d8, #0x0
   863c0:	90000094 	adrp	x20, 96000 <JIS_state_table+0x70>
   863c4:	91324294 	add	x20, x20, #0xc90
   863c8:	a9046bf9 	stp	x25, x26, [sp, #64]
   863cc:	aa0903f9 	mov	x25, x9
   863d0:	f0000060 	adrp	x0, 95000 <pmu_event_descr+0x60>
   863d4:	a90573fb 	stp	x27, x28, [sp, #80]
   863d8:	aa1603fc 	mov	x28, x22
   863dc:	911c0000 	add	x0, x0, #0x700
   863e0:	a90363f7 	stp	x23, x24, [sp, #48]
   863e4:	b90073ff 	str	wzr, [sp, #112]
   863e8:	f90047e0 	str	x0, [sp, #136]
   863ec:	b9009fff 	str	wzr, [sp, #156]
   863f0:	f90063ff 	str	xzr, [sp, #192]
   863f4:	b900ebff 	str	wzr, [sp, #232]
   863f8:	a90f7fff 	stp	xzr, xzr, [sp, #240]
   863fc:	f90083ff 	str	xzr, [sp, #256]
   86400:	f900c3f6 	str	x22, [sp, #384]
   86404:	b9018bff 	str	wzr, [sp, #392]
   86408:	f900cbff 	str	xzr, [sp, #400]
   8640c:	aa1903fa 	mov	x26, x25
   86410:	f9407697 	ldr	x23, [x20, #232]
   86414:	940019ff 	bl	8cc10 <__locale_mb_cur_max>
   86418:	9105a3e4 	add	x4, sp, #0x168
   8641c:	93407c03 	sxtw	x3, w0
   86420:	aa1a03e2 	mov	x2, x26
   86424:	910573e1 	add	x1, sp, #0x15c
   86428:	aa1303e0 	mov	x0, x19
   8642c:	d63f02e0 	blr	x23
   86430:	7100001f 	cmp	w0, #0x0
   86434:	340005a0 	cbz	w0, 864e8 <_vfprintf_r+0x1f8>
   86438:	540004ab 	b.lt	864cc <_vfprintf_r+0x1dc>  // b.tstop
   8643c:	b9415fe1 	ldr	w1, [sp, #348]
   86440:	7100943f 	cmp	w1, #0x25
   86444:	54003860 	b.eq	86b50 <_vfprintf_r+0x860>  // b.none
   86448:	93407c00 	sxtw	x0, w0
   8644c:	8b00035a 	add	x26, x26, x0
   86450:	17fffff0 	b	86410 <_vfprintf_r+0x120>
   86454:	aa1503e1 	mov	x1, x21
   86458:	aa1303e0 	mov	x0, x19
   8645c:	f9003be9 	str	x9, [sp, #112]
   86460:	94001a90 	bl	8cea0 <__swsetup_r>
   86464:	350152c0 	cbnz	w0, 88ebc <_vfprintf_r+0x2bcc>
   86468:	79c022a0 	ldrsh	w0, [x21, #16]
   8646c:	52800341 	mov	w1, #0x1a                  	// #26
   86470:	f9403be9 	ldr	x9, [sp, #112]
   86474:	0a010001 	and	w1, w0, w1
   86478:	7100283f 	cmp	w1, #0xa
   8647c:	54fff9c1 	b.ne	863b4 <_vfprintf_r+0xc4>  // b.any
   86480:	79c026a1 	ldrsh	w1, [x21, #18]
   86484:	37fff981 	tbnz	w1, #31, 863b4 <_vfprintf_r+0xc4>
   86488:	b940b2a1 	ldr	w1, [x21, #176]
   8648c:	37000041 	tbnz	w1, #0, 86494 <_vfprintf_r+0x1a4>
   86490:	364915e0 	tbz	w0, #9, 8874c <_vfprintf_r+0x245c>
   86494:	ad400680 	ldp	q0, q1, [x20]
   86498:	aa1503e1 	mov	x1, x21
   8649c:	910483e3 	add	x3, sp, #0x120
   864a0:	aa0903e2 	mov	x2, x9
   864a4:	aa1303e0 	mov	x0, x19
   864a8:	ad0907e0 	stp	q0, q1, [sp, #288]
   864ac:	94000c6d 	bl	89660 <__sbprintf>
   864b0:	b90073e0 	str	w0, [sp, #112]
   864b4:	a9407bfd 	ldp	x29, x30, [sp]
   864b8:	a94153f3 	ldp	x19, x20, [sp, #16]
   864bc:	a9425bf5 	ldp	x21, x22, [sp, #32]
   864c0:	b94073e0 	ldr	w0, [sp, #112]
   864c4:	910a03ff 	add	sp, sp, #0x280
   864c8:	d65f03c0 	ret
   864cc:	9105a3e0 	add	x0, sp, #0x168
   864d0:	d2800102 	mov	x2, #0x8                   	// #8
   864d4:	52800001 	mov	w1, #0x0                   	// #0
   864d8:	94001c3a 	bl	8d5c0 <memset>
   864dc:	d2800020 	mov	x0, #0x1                   	// #1
   864e0:	8b00035a 	add	x26, x26, x0
   864e4:	17ffffcb 	b	86410 <_vfprintf_r+0x120>
   864e8:	2a0003f7 	mov	w23, w0
   864ec:	cb190340 	sub	x0, x26, x25
   864f0:	2a0003fb 	mov	w27, w0
   864f4:	3400de80 	cbz	w0, 880c4 <_vfprintf_r+0x1dd4>
   864f8:	f940cbe2 	ldr	x2, [sp, #400]
   864fc:	93407f61 	sxtw	x1, w27
   86500:	b9418be0 	ldr	w0, [sp, #392]
   86504:	8b010042 	add	x2, x2, x1
   86508:	a9000799 	stp	x25, x1, [x28]
   8650c:	11000400 	add	w0, w0, #0x1
   86510:	b9018be0 	str	w0, [sp, #392]
   86514:	9100439c 	add	x28, x28, #0x10
   86518:	f900cbe2 	str	x2, [sp, #400]
   8651c:	71001c1f 	cmp	w0, #0x7
   86520:	540044ac 	b.gt	86db4 <_vfprintf_r+0xac4>
   86524:	b94073e0 	ldr	w0, [sp, #112]
   86528:	0b1b0000 	add	w0, w0, w27
   8652c:	b90073e0 	str	w0, [sp, #112]
   86530:	3400dcb7 	cbz	w23, 880c4 <_vfprintf_r+0x1dd4>
   86534:	39400748 	ldrb	w8, [x26, #1]
   86538:	91000759 	add	x25, x26, #0x1
   8653c:	12800007 	mov	w7, #0xffffffff            	// #-1
   86540:	5280000b 	mov	w11, #0x0                   	// #0
   86544:	52800009 	mov	w9, #0x0                   	// #0
   86548:	2a0b03f8 	mov	w24, w11
   8654c:	2a0903f7 	mov	w23, w9
   86550:	2a0703fa 	mov	w26, w7
   86554:	39053fff 	strb	wzr, [sp, #335]
   86558:	91000739 	add	x25, x25, #0x1
   8655c:	51008100 	sub	w0, w8, #0x20
   86560:	7101681f 	cmp	w0, #0x5a
   86564:	540000c8 	b.hi	8657c <_vfprintf_r+0x28c>  // b.pmore
   86568:	f94047e1 	ldr	x1, [sp, #136]
   8656c:	78605820 	ldrh	w0, [x1, w0, uxtw #1]
   86570:	10000061 	adr	x1, 8657c <_vfprintf_r+0x28c>
   86574:	8b20a820 	add	x0, x1, w0, sxth #2
   86578:	d61f0000 	br	x0
   8657c:	2a1703e9 	mov	w9, w23
   86580:	2a1803eb 	mov	w11, w24
   86584:	3400da08 	cbz	w8, 880c4 <_vfprintf_r+0x1dd4>
   86588:	52800023 	mov	w3, #0x1                   	// #1
   8658c:	910663f8 	add	x24, sp, #0x198
   86590:	2a0303fb 	mov	w27, w3
   86594:	52800001 	mov	w1, #0x0                   	// #0
   86598:	d2800017 	mov	x23, #0x0                   	// #0
   8659c:	52800007 	mov	w7, #0x0                   	// #0
   865a0:	b90093ff 	str	wzr, [sp, #144]
   865a4:	b9009bff 	str	wzr, [sp, #152]
   865a8:	b900a3ff 	str	wzr, [sp, #160]
   865ac:	39053fff 	strb	wzr, [sp, #335]
   865b0:	390663e8 	strb	w8, [sp, #408]
   865b4:	d503201f 	nop
   865b8:	721f0132 	ands	w18, w9, #0x2
   865bc:	11000862 	add	w2, w3, #0x2
   865c0:	f940cbe0 	ldr	x0, [sp, #400]
   865c4:	1a831043 	csel	w3, w2, w3, ne	// ne = any
   865c8:	5280108e 	mov	w14, #0x84                  	// #132
   865cc:	6a0e013a 	ands	w26, w9, w14
   865d0:	54000081 	b.ne	865e0 <_vfprintf_r+0x2f0>  // b.any
   865d4:	4b030164 	sub	w4, w11, w3
   865d8:	7100009f 	cmp	w4, #0x0
   865dc:	54001a6c 	b.gt	86928 <_vfprintf_r+0x638>
   865e0:	340001a1 	cbz	w1, 86614 <_vfprintf_r+0x324>
   865e4:	b9418be1 	ldr	w1, [sp, #392]
   865e8:	91053fe2 	add	x2, sp, #0x14f
   865ec:	91000400 	add	x0, x0, #0x1
   865f0:	f9000382 	str	x2, [x28]
   865f4:	11000421 	add	w1, w1, #0x1
   865f8:	d2800022 	mov	x2, #0x1                   	// #1
   865fc:	f9000782 	str	x2, [x28, #8]
   86600:	9100439c 	add	x28, x28, #0x10
   86604:	b9018be1 	str	w1, [sp, #392]
   86608:	f900cbe0 	str	x0, [sp, #400]
   8660c:	71001c3f 	cmp	w1, #0x7
   86610:	54003e0c 	b.gt	86dd0 <_vfprintf_r+0xae0>
   86614:	340001b2 	cbz	w18, 86648 <_vfprintf_r+0x358>
   86618:	b9418be1 	ldr	w1, [sp, #392]
   8661c:	910543e2 	add	x2, sp, #0x150
   86620:	91000800 	add	x0, x0, #0x2
   86624:	f9000382 	str	x2, [x28]
   86628:	11000421 	add	w1, w1, #0x1
   8662c:	d2800042 	mov	x2, #0x2                   	// #2
   86630:	f9000782 	str	x2, [x28, #8]
   86634:	9100439c 	add	x28, x28, #0x10
   86638:	b9018be1 	str	w1, [sp, #392]
   8663c:	f900cbe0 	str	x0, [sp, #400]
   86640:	71001c3f 	cmp	w1, #0x7
   86644:	5400718c 	b.gt	87474 <_vfprintf_r+0x1184>
   86648:	7102035f 	cmp	w26, #0x80
   8664c:	540028c0 	b.eq	86b64 <_vfprintf_r+0x874>  // b.none
   86650:	4b1b00fa 	sub	w26, w7, w27
   86654:	7100035f 	cmp	w26, #0x0
   86658:	540004cc 	b.gt	866f0 <_vfprintf_r+0x400>
   8665c:	37400de9 	tbnz	w9, #8, 86818 <_vfprintf_r+0x528>
   86660:	b9418be1 	ldr	w1, [sp, #392]
   86664:	93407f6c 	sxtw	x12, w27
   86668:	8b0c0000 	add	x0, x0, x12
   8666c:	a9003398 	stp	x24, x12, [x28]
   86670:	11000421 	add	w1, w1, #0x1
   86674:	b9018be1 	str	w1, [sp, #392]
   86678:	f900cbe0 	str	x0, [sp, #400]
   8667c:	71001c3f 	cmp	w1, #0x7
   86680:	5400220c 	b.gt	86ac0 <_vfprintf_r+0x7d0>
   86684:	9100439c 	add	x28, x28, #0x10
   86688:	36100089 	tbz	w9, #2, 86698 <_vfprintf_r+0x3a8>
   8668c:	4b03017a 	sub	w26, w11, w3
   86690:	7100035f 	cmp	w26, #0x0
   86694:	5400714c 	b.gt	874bc <_vfprintf_r+0x11cc>
   86698:	b94073e1 	ldr	w1, [sp, #112]
   8669c:	6b03017f 	cmp	w11, w3
   866a0:	1a83a163 	csel	w3, w11, w3, ge	// ge = tcont
   866a4:	0b030021 	add	w1, w1, w3
   866a8:	b90073e1 	str	w1, [sp, #112]
   866ac:	b5002fc0 	cbnz	x0, 86ca4 <_vfprintf_r+0x9b4>
   866b0:	b9018bff 	str	wzr, [sp, #392]
   866b4:	b4000097 	cbz	x23, 866c4 <_vfprintf_r+0x3d4>
   866b8:	aa1703e1 	mov	x1, x23
   866bc:	aa1303e0 	mov	x0, x19
   866c0:	94002440 	bl	8f7c0 <_free_r>
   866c4:	aa1603fc 	mov	x28, x22
   866c8:	17ffff51 	b	8640c <_vfprintf_r+0x11c>
   866cc:	5100c100 	sub	w0, w8, #0x30
   866d0:	52800018 	mov	w24, #0x0                   	// #0
   866d4:	38401728 	ldrb	w8, [x25], #1
   866d8:	0b180b0b 	add	w11, w24, w24, lsl #2
   866dc:	0b0b0418 	add	w24, w0, w11, lsl #1
   866e0:	5100c100 	sub	w0, w8, #0x30
   866e4:	7100241f 	cmp	w0, #0x9
   866e8:	54ffff69 	b.ls	866d4 <_vfprintf_r+0x3e4>  // b.plast
   866ec:	17ffff9c 	b	8655c <_vfprintf_r+0x26c>
   866f0:	f0000064 	adrp	x4, 95000 <pmu_event_descr+0x60>
   866f4:	b9418be1 	ldr	w1, [sp, #392]
   866f8:	911f0084 	add	x4, x4, #0x7c0
   866fc:	7100435f 	cmp	w26, #0x10
   86700:	5400058d 	b.le	867b0 <_vfprintf_r+0x4c0>
   86704:	aa1c03e2 	mov	x2, x28
   86708:	d280020d 	mov	x13, #0x10                  	// #16
   8670c:	aa1903fc 	mov	x28, x25
   86710:	aa0403f9 	mov	x25, x4
   86714:	b900cbe9 	str	w9, [sp, #200]
   86718:	b900d3e8 	str	w8, [sp, #208]
   8671c:	f9006ff8 	str	x24, [sp, #216]
   86720:	2a1a03f8 	mov	w24, w26
   86724:	2a0303fa 	mov	w26, w3
   86728:	b900e3eb 	str	w11, [sp, #224]
   8672c:	14000004 	b	8673c <_vfprintf_r+0x44c>
   86730:	51004318 	sub	w24, w24, #0x10
   86734:	7100431f 	cmp	w24, #0x10
   86738:	540002ad 	b.le	8678c <_vfprintf_r+0x49c>
   8673c:	91004000 	add	x0, x0, #0x10
   86740:	11000421 	add	w1, w1, #0x1
   86744:	a9003459 	stp	x25, x13, [x2]
   86748:	91004042 	add	x2, x2, #0x10
   8674c:	b9018be1 	str	w1, [sp, #392]
   86750:	f900cbe0 	str	x0, [sp, #400]
   86754:	71001c3f 	cmp	w1, #0x7
   86758:	54fffecd 	b.le	86730 <_vfprintf_r+0x440>
   8675c:	910603e2 	add	x2, sp, #0x180
   86760:	aa1503e1 	mov	x1, x21
   86764:	aa1303e0 	mov	x0, x19
   86768:	94000c2e 	bl	89820 <__sprint_r>
   8676c:	35001ce0 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   86770:	51004318 	sub	w24, w24, #0x10
   86774:	b9418be1 	ldr	w1, [sp, #392]
   86778:	f940cbe0 	ldr	x0, [sp, #400]
   8677c:	aa1603e2 	mov	x2, x22
   86780:	d280020d 	mov	x13, #0x10                  	// #16
   86784:	7100431f 	cmp	w24, #0x10
   86788:	54fffdac 	b.gt	8673c <_vfprintf_r+0x44c>
   8678c:	2a1a03e3 	mov	w3, w26
   86790:	b940cbe9 	ldr	w9, [sp, #200]
   86794:	2a1803fa 	mov	w26, w24
   86798:	b940d3e8 	ldr	w8, [sp, #208]
   8679c:	f9406ff8 	ldr	x24, [sp, #216]
   867a0:	aa1903e4 	mov	x4, x25
   867a4:	b940e3eb 	ldr	w11, [sp, #224]
   867a8:	aa1c03f9 	mov	x25, x28
   867ac:	aa0203fc 	mov	x28, x2
   867b0:	93407f47 	sxtw	x7, w26
   867b4:	11000421 	add	w1, w1, #0x1
   867b8:	8b070000 	add	x0, x0, x7
   867bc:	a9001f84 	stp	x4, x7, [x28]
   867c0:	9100439c 	add	x28, x28, #0x10
   867c4:	b9018be1 	str	w1, [sp, #392]
   867c8:	f900cbe0 	str	x0, [sp, #400]
   867cc:	71001c3f 	cmp	w1, #0x7
   867d0:	54fff46d 	b.le	8665c <_vfprintf_r+0x36c>
   867d4:	910603e2 	add	x2, sp, #0x180
   867d8:	aa1503e1 	mov	x1, x21
   867dc:	aa1303e0 	mov	x0, x19
   867e0:	b900cbe9 	str	w9, [sp, #200]
   867e4:	b900d3e8 	str	w8, [sp, #208]
   867e8:	b900dbeb 	str	w11, [sp, #216]
   867ec:	b900e3e3 	str	w3, [sp, #224]
   867f0:	94000c0c 	bl	89820 <__sprint_r>
   867f4:	350018a0 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   867f8:	b940cbe9 	ldr	w9, [sp, #200]
   867fc:	aa1603fc 	mov	x28, x22
   86800:	f940cbe0 	ldr	x0, [sp, #400]
   86804:	b940d3e8 	ldr	w8, [sp, #208]
   86808:	b940dbeb 	ldr	w11, [sp, #216]
   8680c:	b940e3e3 	ldr	w3, [sp, #224]
   86810:	3647f289 	tbz	w9, #8, 86660 <_vfprintf_r+0x370>
   86814:	d503201f 	nop
   86818:	7101951f 	cmp	w8, #0x65
   8681c:	5400252d 	b.le	86cc0 <_vfprintf_r+0x9d0>
   86820:	1e602108 	fcmp	d8, #0.0
   86824:	54001001 	b.ne	86a24 <_vfprintf_r+0x734>  // b.any
   86828:	b9418be1 	ldr	w1, [sp, #392]
   8682c:	91000400 	add	x0, x0, #0x1
   86830:	f0000062 	adrp	x2, 95000 <pmu_event_descr+0x60>
   86834:	d2800024 	mov	x4, #0x1                   	// #1
   86838:	91188042 	add	x2, x2, #0x620
   8683c:	11000421 	add	w1, w1, #0x1
   86840:	a9001382 	stp	x2, x4, [x28]
   86844:	9100439c 	add	x28, x28, #0x10
   86848:	b9018be1 	str	w1, [sp, #392]
   8684c:	f900cbe0 	str	x0, [sp, #400]
   86850:	71001c3f 	cmp	w1, #0x7
   86854:	5400ac4c 	b.gt	87ddc <_vfprintf_r+0x1aec>
   86858:	b9409fe2 	ldr	w2, [sp, #156]
   8685c:	b9415be1 	ldr	w1, [sp, #344]
   86860:	6b02003f 	cmp	w1, w2
   86864:	54007d2a 	b.ge	87808 <_vfprintf_r+0x1518>  // b.tcont
   86868:	a94b13e2 	ldp	x2, x4, [sp, #176]
   8686c:	a9000b84 	stp	x4, x2, [x28]
   86870:	b9418be1 	ldr	w1, [sp, #392]
   86874:	9100439c 	add	x28, x28, #0x10
   86878:	11000421 	add	w1, w1, #0x1
   8687c:	b9018be1 	str	w1, [sp, #392]
   86880:	8b020000 	add	x0, x0, x2
   86884:	f900cbe0 	str	x0, [sp, #400]
   86888:	71001c3f 	cmp	w1, #0x7
   8688c:	54008a8c 	b.gt	879dc <_vfprintf_r+0x16ec>
   86890:	b9409fe1 	ldr	w1, [sp, #156]
   86894:	5100043a 	sub	w26, w1, #0x1
   86898:	7100035f 	cmp	w26, #0x0
   8689c:	54ffef6d 	b.le	86688 <_vfprintf_r+0x398>
   868a0:	f0000064 	adrp	x4, 95000 <pmu_event_descr+0x60>
   868a4:	b9418be1 	ldr	w1, [sp, #392]
   868a8:	911f0084 	add	x4, x4, #0x7c0
   868ac:	7100435f 	cmp	w26, #0x10
   868b0:	5400b7ad 	b.le	87fa4 <_vfprintf_r+0x1cb4>
   868b4:	aa1c03e2 	mov	x2, x28
   868b8:	2a1a03f8 	mov	w24, w26
   868bc:	aa1903fc 	mov	x28, x25
   868c0:	2a0303fa 	mov	w26, w3
   868c4:	aa0403f9 	mov	x25, x4
   868c8:	d280021b 	mov	x27, #0x10                  	// #16
   868cc:	b90093e9 	str	w9, [sp, #144]
   868d0:	b9009beb 	str	w11, [sp, #152]
   868d4:	14000004 	b	868e4 <_vfprintf_r+0x5f4>
   868d8:	51004318 	sub	w24, w24, #0x10
   868dc:	7100431f 	cmp	w24, #0x10
   868e0:	5400b54d 	b.le	87f88 <_vfprintf_r+0x1c98>
   868e4:	91004000 	add	x0, x0, #0x10
   868e8:	11000421 	add	w1, w1, #0x1
   868ec:	a9006c59 	stp	x25, x27, [x2]
   868f0:	91004042 	add	x2, x2, #0x10
   868f4:	b9018be1 	str	w1, [sp, #392]
   868f8:	f900cbe0 	str	x0, [sp, #400]
   868fc:	71001c3f 	cmp	w1, #0x7
   86900:	54fffecd 	b.le	868d8 <_vfprintf_r+0x5e8>
   86904:	910603e2 	add	x2, sp, #0x180
   86908:	aa1503e1 	mov	x1, x21
   8690c:	aa1303e0 	mov	x0, x19
   86910:	94000bc4 	bl	89820 <__sprint_r>
   86914:	35000fa0 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   86918:	f940cbe0 	ldr	x0, [sp, #400]
   8691c:	aa1603e2 	mov	x2, x22
   86920:	b9418be1 	ldr	w1, [sp, #392]
   86924:	17ffffed 	b	868d8 <_vfprintf_r+0x5e8>
   86928:	f000006d 	adrp	x13, 95000 <pmu_event_descr+0x60>
   8692c:	b9418be1 	ldr	w1, [sp, #392]
   86930:	911f41ad 	add	x13, x13, #0x7d0
   86934:	7100409f 	cmp	w4, #0x10
   86938:	5400060d 	b.le	869f8 <_vfprintf_r+0x708>
   8693c:	aa1c03e2 	mov	x2, x28
   86940:	d280020f 	mov	x15, #0x10                  	// #16
   86944:	aa1903fc 	mov	x28, x25
   86948:	aa0d03f9 	mov	x25, x13
   8694c:	b900cbf2 	str	w18, [sp, #200]
   86950:	b900d3e9 	str	w9, [sp, #208]
   86954:	b900dbe8 	str	w8, [sp, #216]
   86958:	f90073f8 	str	x24, [sp, #224]
   8695c:	2a0403f8 	mov	w24, w4
   86960:	b90113eb 	str	w11, [sp, #272]
   86964:	b9011be7 	str	w7, [sp, #280]
   86968:	b9011fe3 	str	w3, [sp, #284]
   8696c:	14000004 	b	8697c <_vfprintf_r+0x68c>
   86970:	51004318 	sub	w24, w24, #0x10
   86974:	7100431f 	cmp	w24, #0x10
   86978:	540002ad 	b.le	869cc <_vfprintf_r+0x6dc>
   8697c:	91004000 	add	x0, x0, #0x10
   86980:	11000421 	add	w1, w1, #0x1
   86984:	a9003c59 	stp	x25, x15, [x2]
   86988:	91004042 	add	x2, x2, #0x10
   8698c:	b9018be1 	str	w1, [sp, #392]
   86990:	f900cbe0 	str	x0, [sp, #400]
   86994:	71001c3f 	cmp	w1, #0x7
   86998:	54fffecd 	b.le	86970 <_vfprintf_r+0x680>
   8699c:	910603e2 	add	x2, sp, #0x180
   869a0:	aa1503e1 	mov	x1, x21
   869a4:	aa1303e0 	mov	x0, x19
   869a8:	94000b9e 	bl	89820 <__sprint_r>
   869ac:	35000ae0 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   869b0:	51004318 	sub	w24, w24, #0x10
   869b4:	b9418be1 	ldr	w1, [sp, #392]
   869b8:	f940cbe0 	ldr	x0, [sp, #400]
   869bc:	aa1603e2 	mov	x2, x22
   869c0:	d280020f 	mov	x15, #0x10                  	// #16
   869c4:	7100431f 	cmp	w24, #0x10
   869c8:	54fffdac 	b.gt	8697c <_vfprintf_r+0x68c>
   869cc:	2a1803e4 	mov	w4, w24
   869d0:	b940cbf2 	ldr	w18, [sp, #200]
   869d4:	f94073f8 	ldr	x24, [sp, #224]
   869d8:	aa1903ed 	mov	x13, x25
   869dc:	b940d3e9 	ldr	w9, [sp, #208]
   869e0:	aa1c03f9 	mov	x25, x28
   869e4:	b940dbe8 	ldr	w8, [sp, #216]
   869e8:	aa0203fc 	mov	x28, x2
   869ec:	b94113eb 	ldr	w11, [sp, #272]
   869f0:	b9411be7 	ldr	w7, [sp, #280]
   869f4:	b9411fe3 	ldr	w3, [sp, #284]
   869f8:	93407c84 	sxtw	x4, w4
   869fc:	11000421 	add	w1, w1, #0x1
   86a00:	8b040000 	add	x0, x0, x4
   86a04:	a900138d 	stp	x13, x4, [x28]
   86a08:	b9018be1 	str	w1, [sp, #392]
   86a0c:	f900cbe0 	str	x0, [sp, #400]
   86a10:	71001c3f 	cmp	w1, #0x7
   86a14:	54008fec 	b.gt	87c10 <_vfprintf_r+0x1920>
   86a18:	39453fe1 	ldrb	w1, [sp, #335]
   86a1c:	9100439c 	add	x28, x28, #0x10
   86a20:	17fffef0 	b	865e0 <_vfprintf_r+0x2f0>
   86a24:	b9415be2 	ldr	w2, [sp, #344]
   86a28:	7100005f 	cmp	w2, #0x0
   86a2c:	54005d4c 	b.gt	875d4 <_vfprintf_r+0x12e4>
   86a30:	b9418be1 	ldr	w1, [sp, #392]
   86a34:	91000400 	add	x0, x0, #0x1
   86a38:	f0000064 	adrp	x4, 95000 <pmu_event_descr+0x60>
   86a3c:	d2800027 	mov	x7, #0x1                   	// #1
   86a40:	91188084 	add	x4, x4, #0x620
   86a44:	11000421 	add	w1, w1, #0x1
   86a48:	a9001f84 	stp	x4, x7, [x28]
   86a4c:	9100439c 	add	x28, x28, #0x10
   86a50:	b9018be1 	str	w1, [sp, #392]
   86a54:	f900cbe0 	str	x0, [sp, #400]
   86a58:	71001c3f 	cmp	w1, #0x7
   86a5c:	5401094c 	b.gt	88b84 <_vfprintf_r+0x2894>
   86a60:	b9409fe1 	ldr	w1, [sp, #156]
   86a64:	2a020021 	orr	w1, w1, w2
   86a68:	3400d441 	cbz	w1, 884f0 <_vfprintf_r+0x2200>
   86a6c:	a94b17e4 	ldp	x4, x5, [sp, #176]
   86a70:	a9001385 	stp	x5, x4, [x28]
   86a74:	b9418be1 	ldr	w1, [sp, #392]
   86a78:	91004386 	add	x6, x28, #0x10
   86a7c:	11000421 	add	w1, w1, #0x1
   86a80:	b9018be1 	str	w1, [sp, #392]
   86a84:	8b000080 	add	x0, x4, x0
   86a88:	f900cbe0 	str	x0, [sp, #400]
   86a8c:	71001c3f 	cmp	w1, #0x7
   86a90:	5400d46c 	b.gt	8851c <_vfprintf_r+0x222c>
   86a94:	37f91882 	tbnz	w2, #31, 88da4 <_vfprintf_r+0x2ab4>
   86a98:	b9809fe2 	ldrsw	x2, [sp, #156]
   86a9c:	11000421 	add	w1, w1, #0x1
   86aa0:	a90008d8 	stp	x24, x2, [x6]
   86aa4:	910040dc 	add	x28, x6, #0x10
   86aa8:	8b000040 	add	x0, x2, x0
   86aac:	b9018be1 	str	w1, [sp, #392]
   86ab0:	f900cbe0 	str	x0, [sp, #400]
   86ab4:	71001c3f 	cmp	w1, #0x7
   86ab8:	54ffde8d 	b.le	86688 <_vfprintf_r+0x398>
   86abc:	d503201f 	nop
   86ac0:	910603e2 	add	x2, sp, #0x180
   86ac4:	aa1503e1 	mov	x1, x21
   86ac8:	aa1303e0 	mov	x0, x19
   86acc:	b90093e9 	str	w9, [sp, #144]
   86ad0:	b9009beb 	str	w11, [sp, #152]
   86ad4:	b900a3e3 	str	w3, [sp, #160]
   86ad8:	94000b52 	bl	89820 <__sprint_r>
   86adc:	35000160 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   86ae0:	f940cbe0 	ldr	x0, [sp, #400]
   86ae4:	aa1603fc 	mov	x28, x22
   86ae8:	b94093e9 	ldr	w9, [sp, #144]
   86aec:	b9409beb 	ldr	w11, [sp, #152]
   86af0:	b940a3e3 	ldr	w3, [sp, #160]
   86af4:	17fffee5 	b	86688 <_vfprintf_r+0x398>
   86af8:	39400328 	ldrb	w8, [x25]
   86afc:	321c02f7 	orr	w23, w23, #0x10
   86b00:	17fffe96 	b	86558 <_vfprintf_r+0x268>
   86b04:	f9404bf7 	ldr	x23, [sp, #144]
   86b08:	b4000097 	cbz	x23, 86b18 <_vfprintf_r+0x828>
   86b0c:	aa1703e1 	mov	x1, x23
   86b10:	aa1303e0 	mov	x0, x19
   86b14:	9400232b 	bl	8f7c0 <_free_r>
   86b18:	79c022a0 	ldrsh	w0, [x21, #16]
   86b1c:	b940b2a1 	ldr	w1, [x21, #176]
   86b20:	36001801 	tbz	w1, #0, 86e20 <_vfprintf_r+0xb30>
   86b24:	a94363f7 	ldp	x23, x24, [sp, #48]
   86b28:	a9446bf9 	ldp	x25, x26, [sp, #64]
   86b2c:	a94573fb 	ldp	x27, x28, [sp, #80]
   86b30:	6d4627e8 	ldp	d8, d9, [sp, #96]
   86b34:	37311d00 	tbnz	w0, #6, 88ed4 <_vfprintf_r+0x2be4>
   86b38:	a9407bfd 	ldp	x29, x30, [sp]
   86b3c:	a94153f3 	ldp	x19, x20, [sp, #16]
   86b40:	a9425bf5 	ldp	x21, x22, [sp, #32]
   86b44:	b94073e0 	ldr	w0, [sp, #112]
   86b48:	910a03ff 	add	sp, sp, #0x280
   86b4c:	d65f03c0 	ret
   86b50:	2a0003f7 	mov	w23, w0
   86b54:	cb190340 	sub	x0, x26, x25
   86b58:	2a0003fb 	mov	w27, w0
   86b5c:	34ffcec0 	cbz	w0, 86534 <_vfprintf_r+0x244>
   86b60:	17fffe66 	b	864f8 <_vfprintf_r+0x208>
   86b64:	4b03017a 	sub	w26, w11, w3
   86b68:	7100035f 	cmp	w26, #0x0
   86b6c:	54ffd72d 	b.le	86650 <_vfprintf_r+0x360>
   86b70:	f0000064 	adrp	x4, 95000 <pmu_event_descr+0x60>
   86b74:	b9418be1 	ldr	w1, [sp, #392]
   86b78:	911f0084 	add	x4, x4, #0x7c0
   86b7c:	7100435f 	cmp	w26, #0x10
   86b80:	540005cd 	b.le	86c38 <_vfprintf_r+0x948>
   86b84:	aa1c03e2 	mov	x2, x28
   86b88:	d280020e 	mov	x14, #0x10                  	// #16
   86b8c:	aa1903fc 	mov	x28, x25
   86b90:	aa0403f9 	mov	x25, x4
   86b94:	b900cbe9 	str	w9, [sp, #200]
   86b98:	b900d3e8 	str	w8, [sp, #208]
   86b9c:	f9006ff8 	str	x24, [sp, #216]
   86ba0:	2a1a03f8 	mov	w24, w26
   86ba4:	2a0303fa 	mov	w26, w3
   86ba8:	b900e3eb 	str	w11, [sp, #224]
   86bac:	b90113e7 	str	w7, [sp, #272]
   86bb0:	14000004 	b	86bc0 <_vfprintf_r+0x8d0>
   86bb4:	51004318 	sub	w24, w24, #0x10
   86bb8:	7100431f 	cmp	w24, #0x10
   86bbc:	540002ad 	b.le	86c10 <_vfprintf_r+0x920>
   86bc0:	91004000 	add	x0, x0, #0x10
   86bc4:	11000421 	add	w1, w1, #0x1
   86bc8:	a9003859 	stp	x25, x14, [x2]
   86bcc:	91004042 	add	x2, x2, #0x10
   86bd0:	b9018be1 	str	w1, [sp, #392]
   86bd4:	f900cbe0 	str	x0, [sp, #400]
   86bd8:	71001c3f 	cmp	w1, #0x7
   86bdc:	54fffecd 	b.le	86bb4 <_vfprintf_r+0x8c4>
   86be0:	910603e2 	add	x2, sp, #0x180
   86be4:	aa1503e1 	mov	x1, x21
   86be8:	aa1303e0 	mov	x0, x19
   86bec:	94000b0d 	bl	89820 <__sprint_r>
   86bf0:	35fff8c0 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   86bf4:	51004318 	sub	w24, w24, #0x10
   86bf8:	b9418be1 	ldr	w1, [sp, #392]
   86bfc:	f940cbe0 	ldr	x0, [sp, #400]
   86c00:	aa1603e2 	mov	x2, x22
   86c04:	d280020e 	mov	x14, #0x10                  	// #16
   86c08:	7100431f 	cmp	w24, #0x10
   86c0c:	54fffdac 	b.gt	86bc0 <_vfprintf_r+0x8d0>
   86c10:	2a1a03e3 	mov	w3, w26
   86c14:	b940cbe9 	ldr	w9, [sp, #200]
   86c18:	2a1803fa 	mov	w26, w24
   86c1c:	b940d3e8 	ldr	w8, [sp, #208]
   86c20:	f9406ff8 	ldr	x24, [sp, #216]
   86c24:	aa1903e4 	mov	x4, x25
   86c28:	b940e3eb 	ldr	w11, [sp, #224]
   86c2c:	aa1c03f9 	mov	x25, x28
   86c30:	b94113e7 	ldr	w7, [sp, #272]
   86c34:	aa0203fc 	mov	x28, x2
   86c38:	93407f4d 	sxtw	x13, w26
   86c3c:	11000421 	add	w1, w1, #0x1
   86c40:	8b0d0000 	add	x0, x0, x13
   86c44:	a9003784 	stp	x4, x13, [x28]
   86c48:	9100439c 	add	x28, x28, #0x10
   86c4c:	b9018be1 	str	w1, [sp, #392]
   86c50:	f900cbe0 	str	x0, [sp, #400]
   86c54:	71001c3f 	cmp	w1, #0x7
   86c58:	54ffcfcd 	b.le	86650 <_vfprintf_r+0x360>
   86c5c:	910603e2 	add	x2, sp, #0x180
   86c60:	aa1503e1 	mov	x1, x21
   86c64:	aa1303e0 	mov	x0, x19
   86c68:	b900cbe9 	str	w9, [sp, #200]
   86c6c:	b900d3e8 	str	w8, [sp, #208]
   86c70:	b900dbeb 	str	w11, [sp, #216]
   86c74:	b900e3e7 	str	w7, [sp, #224]
   86c78:	b90113e3 	str	w3, [sp, #272]
   86c7c:	94000ae9 	bl	89820 <__sprint_r>
   86c80:	35fff440 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   86c84:	f940cbe0 	ldr	x0, [sp, #400]
   86c88:	aa1603fc 	mov	x28, x22
   86c8c:	b940cbe9 	ldr	w9, [sp, #200]
   86c90:	b940d3e8 	ldr	w8, [sp, #208]
   86c94:	b940dbeb 	ldr	w11, [sp, #216]
   86c98:	b940e3e7 	ldr	w7, [sp, #224]
   86c9c:	b94113e3 	ldr	w3, [sp, #272]
   86ca0:	17fffe6c 	b	86650 <_vfprintf_r+0x360>
   86ca4:	910603e2 	add	x2, sp, #0x180
   86ca8:	aa1503e1 	mov	x1, x21
   86cac:	aa1303e0 	mov	x0, x19
   86cb0:	94000adc 	bl	89820 <__sprint_r>
   86cb4:	34ffcfe0 	cbz	w0, 866b0 <_vfprintf_r+0x3c0>
   86cb8:	b5fff2b7 	cbnz	x23, 86b0c <_vfprintf_r+0x81c>
   86cbc:	17ffff97 	b	86b18 <_vfprintf_r+0x828>
   86cc0:	b9418be1 	ldr	w1, [sp, #392]
   86cc4:	91000400 	add	x0, x0, #0x1
   86cc8:	b9409fe2 	ldr	w2, [sp, #156]
   86ccc:	91004387 	add	x7, x28, #0x10
   86cd0:	11000421 	add	w1, w1, #0x1
   86cd4:	7100045f 	cmp	w2, #0x1
   86cd8:	540010cd 	b.le	86ef0 <_vfprintf_r+0xc00>
   86cdc:	d2800022 	mov	x2, #0x1                   	// #1
   86ce0:	a9000b98 	stp	x24, x2, [x28]
   86ce4:	b9018be1 	str	w1, [sp, #392]
   86ce8:	f900cbe0 	str	x0, [sp, #400]
   86cec:	71001c3f 	cmp	w1, #0x7
   86cf0:	540053cc 	b.gt	87768 <_vfprintf_r+0x1478>
   86cf4:	a94b13e2 	ldp	x2, x4, [sp, #176]
   86cf8:	11000421 	add	w1, w1, #0x1
   86cfc:	a90008e4 	stp	x4, x2, [x7]
   86d00:	910040e7 	add	x7, x7, #0x10
   86d04:	b9018be1 	str	w1, [sp, #392]
   86d08:	8b020000 	add	x0, x0, x2
   86d0c:	f900cbe0 	str	x0, [sp, #400]
   86d10:	71001c3f 	cmp	w1, #0x7
   86d14:	5400548c 	b.gt	877a4 <_vfprintf_r+0x14b4>
   86d18:	1e602108 	fcmp	d8, #0.0
   86d1c:	b9409fe2 	ldr	w2, [sp, #156]
   86d20:	5100045a 	sub	w26, w2, #0x1
   86d24:	54001120 	b.eq	86f48 <_vfprintf_r+0xc58>  // b.none
   86d28:	93407f5a 	sxtw	x26, w26
   86d2c:	11000421 	add	w1, w1, #0x1
   86d30:	8b1a0000 	add	x0, x0, x26
   86d34:	b9018be1 	str	w1, [sp, #392]
   86d38:	f900cbe0 	str	x0, [sp, #400]
   86d3c:	91000705 	add	x5, x24, #0x1
   86d40:	f90000e5 	str	x5, [x7]
   86d44:	f90004fa 	str	x26, [x7, #8]
   86d48:	71001c3f 	cmp	w1, #0x7
   86d4c:	540062ac 	b.gt	879a0 <_vfprintf_r+0x16b0>
   86d50:	910040e7 	add	x7, x7, #0x10
   86d54:	b980ebe2 	ldrsw	x2, [sp, #232]
   86d58:	11000421 	add	w1, w1, #0x1
   86d5c:	910583e4 	add	x4, sp, #0x160
   86d60:	a90008e4 	stp	x4, x2, [x7]
   86d64:	8b000040 	add	x0, x2, x0
   86d68:	b9018be1 	str	w1, [sp, #392]
   86d6c:	910040fc 	add	x28, x7, #0x10
   86d70:	f900cbe0 	str	x0, [sp, #400]
   86d74:	71001c3f 	cmp	w1, #0x7
   86d78:	54ffc88d 	b.le	86688 <_vfprintf_r+0x398>
   86d7c:	910603e2 	add	x2, sp, #0x180
   86d80:	aa1503e1 	mov	x1, x21
   86d84:	aa1303e0 	mov	x0, x19
   86d88:	b90093e9 	str	w9, [sp, #144]
   86d8c:	b9009beb 	str	w11, [sp, #152]
   86d90:	b900a3e3 	str	w3, [sp, #160]
   86d94:	94000aa3 	bl	89820 <__sprint_r>
   86d98:	35ffeb80 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   86d9c:	f940cbe0 	ldr	x0, [sp, #400]
   86da0:	aa1603fc 	mov	x28, x22
   86da4:	b94093e9 	ldr	w9, [sp, #144]
   86da8:	b9409beb 	ldr	w11, [sp, #152]
   86dac:	b940a3e3 	ldr	w3, [sp, #160]
   86db0:	17fffe36 	b	86688 <_vfprintf_r+0x398>
   86db4:	910603e2 	add	x2, sp, #0x180
   86db8:	aa1503e1 	mov	x1, x21
   86dbc:	aa1303e0 	mov	x0, x19
   86dc0:	94000a98 	bl	89820 <__sprint_r>
   86dc4:	35ffeaa0 	cbnz	w0, 86b18 <_vfprintf_r+0x828>
   86dc8:	aa1603fc 	mov	x28, x22
   86dcc:	17fffdd6 	b	86524 <_vfprintf_r+0x234>
   86dd0:	910603e2 	add	x2, sp, #0x180
   86dd4:	aa1503e1 	mov	x1, x21
   86dd8:	aa1303e0 	mov	x0, x19
   86ddc:	b900cbf2 	str	w18, [sp, #200]
   86de0:	b900d3e9 	str	w9, [sp, #208]
   86de4:	b900dbe8 	str	w8, [sp, #216]
   86de8:	b900e3eb 	str	w11, [sp, #224]
   86dec:	b90113e7 	str	w7, [sp, #272]
   86df0:	b9011be3 	str	w3, [sp, #280]
   86df4:	94000a8b 	bl	89820 <__sprint_r>
   86df8:	35ffe880 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   86dfc:	f940cbe0 	ldr	x0, [sp, #400]
   86e00:	aa1603fc 	mov	x28, x22
   86e04:	b940cbf2 	ldr	w18, [sp, #200]
   86e08:	b940d3e9 	ldr	w9, [sp, #208]
   86e0c:	b940dbe8 	ldr	w8, [sp, #216]
   86e10:	b940e3eb 	ldr	w11, [sp, #224]
   86e14:	b94113e7 	ldr	w7, [sp, #272]
   86e18:	b9411be3 	ldr	w3, [sp, #280]
   86e1c:	17fffdfe 	b	86614 <_vfprintf_r+0x324>
   86e20:	374fe820 	tbnz	w0, #9, 86b24 <_vfprintf_r+0x834>
   86e24:	f94052a0 	ldr	x0, [x21, #160]
   86e28:	94001452 	bl	8bf70 <__retarget_lock_release_recursive>
   86e2c:	79c022a0 	ldrsh	w0, [x21, #16]
   86e30:	17ffff3d 	b	86b24 <_vfprintf_r+0x834>
   86e34:	b940efe0 	ldr	w0, [sp, #236]
   86e38:	2a1703e9 	mov	w9, w23
   86e3c:	2a1803eb 	mov	w11, w24
   86e40:	2a1a03e7 	mov	w7, w26
   86e44:	36184e69 	tbz	w9, #3, 87810 <_vfprintf_r+0x1520>
   86e48:	37f8e3a0 	tbnz	w0, #31, 88abc <_vfprintf_r+0x27cc>
   86e4c:	f94043e0 	ldr	x0, [sp, #128]
   86e50:	91003c00 	add	x0, x0, #0xf
   86e54:	927cec00 	and	x0, x0, #0xfffffffffffffff0
   86e58:	91004001 	add	x1, x0, #0x10
   86e5c:	f90043e1 	str	x1, [sp, #128]
   86e60:	3dc00000 	ldr	q0, [x0]
   86e64:	b90093e9 	str	w9, [sp, #144]
   86e68:	b9009be8 	str	w8, [sp, #152]
   86e6c:	b900a3eb 	str	w11, [sp, #160]
   86e70:	b900cbe7 	str	w7, [sp, #200]
   86e74:	940036c3 	bl	94980 <__trunctfdf2>
   86e78:	b94093e9 	ldr	w9, [sp, #144]
   86e7c:	1e604008 	fmov	d8, d0
   86e80:	b9409be8 	ldr	w8, [sp, #152]
   86e84:	b940a3eb 	ldr	w11, [sp, #160]
   86e88:	b940cbe7 	ldr	w7, [sp, #200]
   86e8c:	1e60c100 	fabs	d0, d8
   86e90:	92f00200 	mov	x0, #0x7fefffffffffffff    	// #9218868437227405311
   86e94:	9e670001 	fmov	d1, x0
   86e98:	1e612000 	fcmp	d0, d1
   86e9c:	54006f6d 	b.le	87c88 <_vfprintf_r+0x1998>
   86ea0:	1e602118 	fcmpe	d8, #0.0
   86ea4:	5400db84 	b.mi	88a14 <_vfprintf_r+0x2724>  // b.first
   86ea8:	39453fe1 	ldrb	w1, [sp, #335]
   86eac:	f0000060 	adrp	x0, 95000 <pmu_event_descr+0x60>
   86eb0:	f0000065 	adrp	x5, 95000 <pmu_event_descr+0x60>
   86eb4:	7101211f 	cmp	w8, #0x48
   86eb8:	91174000 	add	x0, x0, #0x5d0
   86ebc:	911720a5 	add	x5, x5, #0x5c8
   86ec0:	b90093ff 	str	wzr, [sp, #144]
   86ec4:	52800063 	mov	w3, #0x3                   	// #3
   86ec8:	b9009bff 	str	wzr, [sp, #152]
   86ecc:	12187929 	and	w9, w9, #0xffffff7f
   86ed0:	b900a3ff 	str	wzr, [sp, #160]
   86ed4:	9a80b0b8 	csel	x24, x5, x0, lt	// lt = tstop
   86ed8:	2a0303fb 	mov	w27, w3
   86edc:	d2800017 	mov	x23, #0x0                   	// #0
   86ee0:	52800007 	mov	w7, #0x0                   	// #0
   86ee4:	34ffb6a1 	cbz	w1, 865b8 <_vfprintf_r+0x2c8>
   86ee8:	11000463 	add	w3, w3, #0x1
   86eec:	17fffdb3 	b	865b8 <_vfprintf_r+0x2c8>
   86ef0:	3707ef69 	tbnz	w9, #0, 86cdc <_vfprintf_r+0x9ec>
   86ef4:	d2800022 	mov	x2, #0x1                   	// #1
   86ef8:	a9000b98 	stp	x24, x2, [x28]
   86efc:	b9018be1 	str	w1, [sp, #392]
   86f00:	f900cbe0 	str	x0, [sp, #400]
   86f04:	71001c3f 	cmp	w1, #0x7
   86f08:	54fff26d 	b.le	86d54 <_vfprintf_r+0xa64>
   86f0c:	910603e2 	add	x2, sp, #0x180
   86f10:	aa1503e1 	mov	x1, x21
   86f14:	aa1303e0 	mov	x0, x19
   86f18:	b90093e9 	str	w9, [sp, #144]
   86f1c:	b9009beb 	str	w11, [sp, #152]
   86f20:	b900a3e3 	str	w3, [sp, #160]
   86f24:	94000a3f 	bl	89820 <__sprint_r>
   86f28:	35ffdf00 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   86f2c:	f940cbe0 	ldr	x0, [sp, #400]
   86f30:	aa1603e7 	mov	x7, x22
   86f34:	b94093e9 	ldr	w9, [sp, #144]
   86f38:	b9409beb 	ldr	w11, [sp, #152]
   86f3c:	b940a3e3 	ldr	w3, [sp, #160]
   86f40:	b9418be1 	ldr	w1, [sp, #392]
   86f44:	17ffff84 	b	86d54 <_vfprintf_r+0xa64>
   86f48:	b9409fe2 	ldr	w2, [sp, #156]
   86f4c:	7100045f 	cmp	w2, #0x1
   86f50:	54fff02d 	b.le	86d54 <_vfprintf_r+0xa64>
   86f54:	f0000064 	adrp	x4, 95000 <pmu_event_descr+0x60>
   86f58:	911f0084 	add	x4, x4, #0x7c0
   86f5c:	7100445f 	cmp	w2, #0x11
   86f60:	540050ed 	b.le	8797c <_vfprintf_r+0x168c>
   86f64:	2a1a03f8 	mov	w24, w26
   86f68:	2a0b03fc 	mov	w28, w11
   86f6c:	aa1903fa 	mov	x26, x25
   86f70:	d280021b 	mov	x27, #0x10                  	// #16
   86f74:	aa0403f9 	mov	x25, x4
   86f78:	b90093e9 	str	w9, [sp, #144]
   86f7c:	b9009be3 	str	w3, [sp, #152]
   86f80:	14000004 	b	86f90 <_vfprintf_r+0xca0>
   86f84:	51004318 	sub	w24, w24, #0x10
   86f88:	7100431f 	cmp	w24, #0x10
   86f8c:	54004ecd 	b.le	87964 <_vfprintf_r+0x1674>
   86f90:	91004000 	add	x0, x0, #0x10
   86f94:	11000421 	add	w1, w1, #0x1
   86f98:	a9006cf9 	stp	x25, x27, [x7]
   86f9c:	910040e7 	add	x7, x7, #0x10
   86fa0:	b9018be1 	str	w1, [sp, #392]
   86fa4:	f900cbe0 	str	x0, [sp, #400]
   86fa8:	71001c3f 	cmp	w1, #0x7
   86fac:	54fffecd 	b.le	86f84 <_vfprintf_r+0xc94>
   86fb0:	910603e2 	add	x2, sp, #0x180
   86fb4:	aa1503e1 	mov	x1, x21
   86fb8:	aa1303e0 	mov	x0, x19
   86fbc:	94000a19 	bl	89820 <__sprint_r>
   86fc0:	35ffda40 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   86fc4:	f940cbe0 	ldr	x0, [sp, #400]
   86fc8:	aa1603e7 	mov	x7, x22
   86fcc:	b9418be1 	ldr	w1, [sp, #392]
   86fd0:	17ffffed 	b	86f84 <_vfprintf_r+0xc94>
   86fd4:	2a1703e9 	mov	w9, w23
   86fd8:	2a1803eb 	mov	w11, w24
   86fdc:	71010d1f 	cmp	w8, #0x43
   86fe0:	540056a0 	b.eq	87ab4 <_vfprintf_r+0x17c4>  // b.none
   86fe4:	37205689 	tbnz	w9, #4, 87ab4 <_vfprintf_r+0x17c4>
   86fe8:	b9407fe0 	ldr	w0, [sp, #124]
   86fec:	37f8dfc0 	tbnz	w0, #31, 88be4 <_vfprintf_r+0x28f4>
   86ff0:	f94043e0 	ldr	x0, [sp, #128]
   86ff4:	91002c01 	add	x1, x0, #0xb
   86ff8:	927df021 	and	x1, x1, #0xfffffffffffffff8
   86ffc:	f90043e1 	str	x1, [sp, #128]
   87000:	b9400000 	ldr	w0, [x0]
   87004:	52800023 	mov	w3, #0x1                   	// #1
   87008:	910663f7 	add	x23, sp, #0x198
   8700c:	2a0303fb 	mov	w27, w3
   87010:	390663e0 	strb	w0, [sp, #408]
   87014:	aa1703f8 	mov	x24, x23
   87018:	52800001 	mov	w1, #0x0                   	// #0
   8701c:	d2800017 	mov	x23, #0x0                   	// #0
   87020:	52800007 	mov	w7, #0x0                   	// #0
   87024:	b90093ff 	str	wzr, [sp, #144]
   87028:	b9009bff 	str	wzr, [sp, #152]
   8702c:	b900a3ff 	str	wzr, [sp, #160]
   87030:	39053fff 	strb	wzr, [sp, #335]
   87034:	17fffd61 	b	865b8 <_vfprintf_r+0x2c8>
   87038:	b9407fe0 	ldr	w0, [sp, #124]
   8703c:	2a1703e9 	mov	w9, w23
   87040:	2a1803eb 	mov	w11, w24
   87044:	2a1a03e7 	mov	w7, w26
   87048:	37f84540 	tbnz	w0, #31, 878f0 <_vfprintf_r+0x1600>
   8704c:	f94043e0 	ldr	x0, [sp, #128]
   87050:	91003c01 	add	x1, x0, #0xf
   87054:	927df021 	and	x1, x1, #0xfffffffffffffff8
   87058:	f90043e1 	str	x1, [sp, #128]
   8705c:	f9400018 	ldr	x24, [x0]
   87060:	39053fff 	strb	wzr, [sp, #335]
   87064:	b4008038 	cbz	x24, 88068 <_vfprintf_r+0x1d78>
   87068:	71014d1f 	cmp	w8, #0x53
   8706c:	54006d40 	b.eq	87e14 <_vfprintf_r+0x1b24>  // b.none
   87070:	121c0120 	and	w0, w9, #0x10
   87074:	b90093e0 	str	w0, [sp, #144]
   87078:	37206ce9 	tbnz	w9, #4, 87e14 <_vfprintf_r+0x1b24>
   8707c:	310004ff 	cmn	w7, #0x1
   87080:	5400ae00 	b.eq	88640 <_vfprintf_r+0x2350>  // b.none
   87084:	93407ce2 	sxtw	x2, w7
   87088:	aa1803e0 	mov	x0, x24
   8708c:	52800001 	mov	w1, #0x0                   	// #0
   87090:	b9009be7 	str	w7, [sp, #152]
   87094:	b900a3e9 	str	w9, [sp, #160]
   87098:	b900cbeb 	str	w11, [sp, #200]
   8709c:	94001749 	bl	8cdc0 <memchr>
   870a0:	b9409be7 	ldr	w7, [sp, #152]
   870a4:	aa0003f7 	mov	x23, x0
   870a8:	b940a3e9 	ldr	w9, [sp, #160]
   870ac:	b940cbeb 	ldr	w11, [sp, #200]
   870b0:	b400ffa0 	cbz	x0, 890a4 <_vfprintf_r+0x2db4>
   870b4:	39453fe1 	ldrb	w1, [sp, #335]
   870b8:	cb180003 	sub	x3, x0, x24
   870bc:	b9009bff 	str	wzr, [sp, #152]
   870c0:	7100007f 	cmp	w3, #0x0
   870c4:	b900a3ff 	str	wzr, [sp, #160]
   870c8:	2a0303fb 	mov	w27, w3
   870cc:	52800007 	mov	w7, #0x0                   	// #0
   870d0:	1a9fa063 	csel	w3, w3, wzr, ge	// ge = tcont
   870d4:	d2800017 	mov	x23, #0x0                   	// #0
   870d8:	52800e68 	mov	w8, #0x73                  	// #115
   870dc:	34ffa6e1 	cbz	w1, 865b8 <_vfprintf_r+0x2c8>
   870e0:	17ffff82 	b	86ee8 <_vfprintf_r+0xbf8>
   870e4:	4b1803f8 	neg	w24, w24
   870e8:	f90043e0 	str	x0, [sp, #128]
   870ec:	39400328 	ldrb	w8, [x25]
   870f0:	321e02f7 	orr	w23, w23, #0x4
   870f4:	17fffd19 	b	86558 <_vfprintf_r+0x268>
   870f8:	aa1903e1 	mov	x1, x25
   870fc:	38401428 	ldrb	w8, [x1], #1
   87100:	7100a91f 	cmp	w8, #0x2a
   87104:	54012100 	b.eq	89524 <_vfprintf_r+0x3234>  // b.none
   87108:	5100c100 	sub	w0, w8, #0x30
   8710c:	aa0103f9 	mov	x25, x1
   87110:	5280001a 	mov	w26, #0x0                   	// #0
   87114:	7100241f 	cmp	w0, #0x9
   87118:	54ffa228 	b.hi	8655c <_vfprintf_r+0x26c>  // b.pmore
   8711c:	d503201f 	nop
   87120:	38401728 	ldrb	w8, [x25], #1
   87124:	0b1a0b47 	add	w7, w26, w26, lsl #2
   87128:	0b07041a 	add	w26, w0, w7, lsl #1
   8712c:	5100c100 	sub	w0, w8, #0x30
   87130:	7100241f 	cmp	w0, #0x9
   87134:	54ffff69 	b.ls	87120 <_vfprintf_r+0xe30>  // b.plast
   87138:	17fffd09 	b	8655c <_vfprintf_r+0x26c>
   8713c:	52800560 	mov	w0, #0x2b                  	// #43
   87140:	39400328 	ldrb	w8, [x25]
   87144:	39053fe0 	strb	w0, [sp, #335]
   87148:	17fffd04 	b	86558 <_vfprintf_r+0x268>
   8714c:	b9407fe0 	ldr	w0, [sp, #124]
   87150:	37f83f80 	tbnz	w0, #31, 87940 <_vfprintf_r+0x1650>
   87154:	f94043e0 	ldr	x0, [sp, #128]
   87158:	91002c00 	add	x0, x0, #0xb
   8715c:	927df000 	and	x0, x0, #0xfffffffffffffff8
   87160:	f94043e1 	ldr	x1, [sp, #128]
   87164:	b9400038 	ldr	w24, [x1]
   87168:	37fffbf8 	tbnz	w24, #31, 870e4 <_vfprintf_r+0xdf4>
   8716c:	39400328 	ldrb	w8, [x25]
   87170:	f90043e0 	str	x0, [sp, #128]
   87174:	17fffcf9 	b	86558 <_vfprintf_r+0x268>
   87178:	aa1303e0 	mov	x0, x19
   8717c:	940016b5 	bl	8cc50 <_localeconv_r>
   87180:	f9400400 	ldr	x0, [x0, #8]
   87184:	f9007be0 	str	x0, [sp, #240]
   87188:	97ffedfe 	bl	82980 <strlen>
   8718c:	aa0003e1 	mov	x1, x0
   87190:	aa0103fb 	mov	x27, x1
   87194:	aa1303e0 	mov	x0, x19
   87198:	f90083e1 	str	x1, [sp, #256]
   8719c:	940016ad 	bl	8cc50 <_localeconv_r>
   871a0:	f9400800 	ldr	x0, [x0, #16]
   871a4:	f9007fe0 	str	x0, [sp, #248]
   871a8:	f100037f 	cmp	x27, #0x0
   871ac:	fa401804 	ccmp	x0, #0x0, #0x4, ne	// ne = any
   871b0:	540036c0 	b.eq	87888 <_vfprintf_r+0x1598>  // b.none
   871b4:	39400001 	ldrb	w1, [x0]
   871b8:	321602e0 	orr	w0, w23, #0x400
   871bc:	39400328 	ldrb	w8, [x25]
   871c0:	7100003f 	cmp	w1, #0x0
   871c4:	1a971017 	csel	w23, w0, w23, ne	// ne = any
   871c8:	17fffce4 	b	86558 <_vfprintf_r+0x268>
   871cc:	39400328 	ldrb	w8, [x25]
   871d0:	320002f7 	orr	w23, w23, #0x1
   871d4:	17fffce1 	b	86558 <_vfprintf_r+0x268>
   871d8:	39453fe0 	ldrb	w0, [sp, #335]
   871dc:	39400328 	ldrb	w8, [x25]
   871e0:	35ff9bc0 	cbnz	w0, 86558 <_vfprintf_r+0x268>
   871e4:	52800400 	mov	w0, #0x20                  	// #32
   871e8:	39053fe0 	strb	w0, [sp, #335]
   871ec:	17fffcdb 	b	86558 <_vfprintf_r+0x268>
   871f0:	2a1803eb 	mov	w11, w24
   871f4:	2a1a03e7 	mov	w7, w26
   871f8:	321c02e9 	orr	w9, w23, #0x10
   871fc:	b9407fe0 	ldr	w0, [sp, #124]
   87200:	37280049 	tbnz	w9, #5, 87208 <_vfprintf_r+0xf18>
   87204:	362035e9 	tbz	w9, #4, 878c0 <_vfprintf_r+0x15d0>
   87208:	37f84dc0 	tbnz	w0, #31, 87bc0 <_vfprintf_r+0x18d0>
   8720c:	f94043e0 	ldr	x0, [sp, #128]
   87210:	91003c01 	add	x1, x0, #0xf
   87214:	927df021 	and	x1, x1, #0xfffffffffffffff8
   87218:	f90043e1 	str	x1, [sp, #128]
   8721c:	f9400000 	ldr	x0, [x0]
   87220:	1215793a 	and	w26, w9, #0xfffffbff
   87224:	52800001 	mov	w1, #0x0                   	// #0
   87228:	52800002 	mov	w2, #0x0                   	// #0
   8722c:	39053fe2 	strb	w2, [sp, #335]
   87230:	310004ff 	cmn	w7, #0x1
   87234:	54000de0 	b.eq	873f0 <_vfprintf_r+0x1100>  // b.none
   87238:	f100001f 	cmp	x0, #0x0
   8723c:	12187b49 	and	w9, w26, #0xffffff7f
   87240:	7a4008e0 	ccmp	w7, #0x0, #0x0, eq	// eq = none
   87244:	54000d41 	b.ne	873ec <_vfprintf_r+0x10fc>  // b.any
   87248:	35000c41 	cbnz	w1, 873d0 <_vfprintf_r+0x10e0>
   8724c:	1200035b 	and	w27, w26, #0x1
   87250:	36001bda 	tbz	w26, #0, 875c8 <_vfprintf_r+0x12d8>
   87254:	9107eff8 	add	x24, sp, #0x1fb
   87258:	52800600 	mov	w0, #0x30                  	// #48
   8725c:	52800007 	mov	w7, #0x0                   	// #0
   87260:	3907efe0 	strb	w0, [sp, #507]
   87264:	d503201f 	nop
   87268:	39453fe1 	ldrb	w1, [sp, #335]
   8726c:	6b1b00ff 	cmp	w7, w27
   87270:	b90093ff 	str	wzr, [sp, #144]
   87274:	1a9ba0e3 	csel	w3, w7, w27, ge	// ge = tcont
   87278:	b9009bff 	str	wzr, [sp, #152]
   8727c:	d2800017 	mov	x23, #0x0                   	// #0
   87280:	b900a3ff 	str	wzr, [sp, #160]
   87284:	34ff99a1 	cbz	w1, 865b8 <_vfprintf_r+0x2c8>
   87288:	17ffff18 	b	86ee8 <_vfprintf_r+0xbf8>
   8728c:	39400328 	ldrb	w8, [x25]
   87290:	321d02f7 	orr	w23, w23, #0x8
   87294:	17fffcb1 	b	86558 <_vfprintf_r+0x268>
   87298:	2a1a03e7 	mov	w7, w26
   8729c:	2a1803eb 	mov	w11, w24
   872a0:	321c02fa 	orr	w26, w23, #0x10
   872a4:	b9407fe0 	ldr	w0, [sp, #124]
   872a8:	3728005a 	tbnz	w26, #5, 872b0 <_vfprintf_r+0xfc0>
   872ac:	36202c1a 	tbz	w26, #4, 8782c <_vfprintf_r+0x153c>
   872b0:	37f849c0 	tbnz	w0, #31, 87be8 <_vfprintf_r+0x18f8>
   872b4:	f94043e0 	ldr	x0, [sp, #128]
   872b8:	91003c01 	add	x1, x0, #0xf
   872bc:	927df021 	and	x1, x1, #0xfffffffffffffff8
   872c0:	f90043e1 	str	x1, [sp, #128]
   872c4:	f9400000 	ldr	x0, [x0]
   872c8:	52800021 	mov	w1, #0x1                   	// #1
   872cc:	17ffffd7 	b	87228 <_vfprintf_r+0xf38>
   872d0:	39400328 	ldrb	w8, [x25]
   872d4:	7101b11f 	cmp	w8, #0x6c
   872d8:	540039e0 	b.eq	87a14 <_vfprintf_r+0x1724>  // b.none
   872dc:	321c02f7 	orr	w23, w23, #0x10
   872e0:	17fffc9e 	b	86558 <_vfprintf_r+0x268>
   872e4:	39400328 	ldrb	w8, [x25]
   872e8:	7101a11f 	cmp	w8, #0x68
   872ec:	540039c0 	b.eq	87a24 <_vfprintf_r+0x1734>  // b.none
   872f0:	321a02f7 	orr	w23, w23, #0x40
   872f4:	17fffc99 	b	86558 <_vfprintf_r+0x268>
   872f8:	39400328 	ldrb	w8, [x25]
   872fc:	321b02f7 	orr	w23, w23, #0x20
   87300:	17fffc96 	b	86558 <_vfprintf_r+0x268>
   87304:	b9407fe0 	ldr	w0, [sp, #124]
   87308:	2a1703e9 	mov	w9, w23
   8730c:	2a1803eb 	mov	w11, w24
   87310:	2a1a03e7 	mov	w7, w26
   87314:	37f83020 	tbnz	w0, #31, 87918 <_vfprintf_r+0x1628>
   87318:	f94043e0 	ldr	x0, [sp, #128]
   8731c:	91003c01 	add	x1, x0, #0xf
   87320:	927df021 	and	x1, x1, #0xfffffffffffffff8
   87324:	f90043e1 	str	x1, [sp, #128]
   87328:	f9400000 	ldr	x0, [x0]
   8732c:	528f0602 	mov	w2, #0x7830                	// #30768
   87330:	d0000063 	adrp	x3, 95000 <pmu_event_descr+0x60>
   87334:	321f013a 	orr	w26, w9, #0x2
   87338:	9117a063 	add	x3, x3, #0x5e8
   8733c:	52800041 	mov	w1, #0x2                   	// #2
   87340:	52800f08 	mov	w8, #0x78                  	// #120
   87344:	f90063e3 	str	x3, [sp, #192]
   87348:	7902a3e2 	strh	w2, [sp, #336]
   8734c:	17ffffb7 	b	87228 <_vfprintf_r+0xf38>
   87350:	b9407fe0 	ldr	w0, [sp, #124]
   87354:	2a1703e9 	mov	w9, w23
   87358:	362829c9 	tbz	w9, #5, 87890 <_vfprintf_r+0x15a0>
   8735c:	37f86a00 	tbnz	w0, #31, 8809c <_vfprintf_r+0x1dac>
   87360:	f94043e0 	ldr	x0, [sp, #128]
   87364:	91003c01 	add	x1, x0, #0xf
   87368:	927df021 	and	x1, x1, #0xfffffffffffffff8
   8736c:	f90043e1 	str	x1, [sp, #128]
   87370:	f9400000 	ldr	x0, [x0]
   87374:	b98073e1 	ldrsw	x1, [sp, #112]
   87378:	f9000001 	str	x1, [x0]
   8737c:	17fffc24 	b	8640c <_vfprintf_r+0x11c>
   87380:	2a1803eb 	mov	w11, w24
   87384:	2a1a03e7 	mov	w7, w26
   87388:	321c02e9 	orr	w9, w23, #0x10
   8738c:	b9407fe0 	ldr	w0, [sp, #124]
   87390:	37280049 	tbnz	w9, #5, 87398 <_vfprintf_r+0x10a8>
   87394:	362025e9 	tbz	w9, #4, 87850 <_vfprintf_r+0x1560>
   87398:	37f84000 	tbnz	w0, #31, 87b98 <_vfprintf_r+0x18a8>
   8739c:	f94043e0 	ldr	x0, [sp, #128]
   873a0:	91003c01 	add	x1, x0, #0xf
   873a4:	927df021 	and	x1, x1, #0xfffffffffffffff8
   873a8:	f90043e1 	str	x1, [sp, #128]
   873ac:	f9400001 	ldr	x1, [x0]
   873b0:	aa0103e0 	mov	x0, x1
   873b4:	b7f82601 	tbnz	x1, #63, 87874 <_vfprintf_r+0x1584>
   873b8:	310004ff 	cmn	w7, #0x1
   873bc:	54000f40 	b.eq	875a4 <_vfprintf_r+0x12b4>  // b.none
   873c0:	710000ff 	cmp	w7, #0x0
   873c4:	12187929 	and	w9, w9, #0xffffff7f
   873c8:	fa400800 	ccmp	x0, #0x0, #0x0, eq	// eq = none
   873cc:	54000ec1 	b.ne	875a4 <_vfprintf_r+0x12b4>  // b.any
   873d0:	9107f3f8 	add	x24, sp, #0x1fc
   873d4:	52800007 	mov	w7, #0x0                   	// #0
   873d8:	5280001b 	mov	w27, #0x0                   	// #0
   873dc:	17ffffa3 	b	87268 <_vfprintf_r+0xf78>
   873e0:	39400328 	ldrb	w8, [x25]
   873e4:	321902f7 	orr	w23, w23, #0x80
   873e8:	17fffc5c 	b	86558 <_vfprintf_r+0x268>
   873ec:	2a0903fa 	mov	w26, w9
   873f0:	7100043f 	cmp	w1, #0x1
   873f4:	54000da0 	b.eq	875a8 <_vfprintf_r+0x12b8>  // b.none
   873f8:	9107f3ec 	add	x12, sp, #0x1fc
   873fc:	aa0c03f8 	mov	x24, x12
   87400:	7100083f 	cmp	w1, #0x2
   87404:	54000161 	b.ne	87430 <_vfprintf_r+0x1140>  // b.any
   87408:	f94063e2 	ldr	x2, [sp, #192]
   8740c:	d503201f 	nop
   87410:	92400c01 	and	x1, x0, #0xf
   87414:	d344fc00 	lsr	x0, x0, #4
   87418:	38616841 	ldrb	w1, [x2, x1]
   8741c:	381fff01 	strb	w1, [x24, #-1]!
   87420:	b5ffff80 	cbnz	x0, 87410 <_vfprintf_r+0x1120>
   87424:	4b18019b 	sub	w27, w12, w24
   87428:	2a1a03e9 	mov	w9, w26
   8742c:	17ffff8f 	b	87268 <_vfprintf_r+0xf78>
   87430:	12000801 	and	w1, w0, #0x7
   87434:	aa1803e2 	mov	x2, x24
   87438:	1100c021 	add	w1, w1, #0x30
   8743c:	381fff01 	strb	w1, [x24, #-1]!
   87440:	d343fc00 	lsr	x0, x0, #3
   87444:	b5ffff60 	cbnz	x0, 87430 <_vfprintf_r+0x1140>
   87448:	7100c03f 	cmp	w1, #0x30
   8744c:	1a9f07e0 	cset	w0, ne	// ne = any
   87450:	6a00035f 	tst	w26, w0
   87454:	54fffe80 	b.eq	87424 <_vfprintf_r+0x1134>  // b.none
   87458:	d1000842 	sub	x2, x2, #0x2
   8745c:	52800600 	mov	w0, #0x30                  	// #48
   87460:	2a1a03e9 	mov	w9, w26
   87464:	4b02019b 	sub	w27, w12, w2
   87468:	381ff300 	sturb	w0, [x24, #-1]
   8746c:	aa0203f8 	mov	x24, x2
   87470:	17ffff7e 	b	87268 <_vfprintf_r+0xf78>
   87474:	910603e2 	add	x2, sp, #0x180
   87478:	aa1503e1 	mov	x1, x21
   8747c:	aa1303e0 	mov	x0, x19
   87480:	b900cbe9 	str	w9, [sp, #200]
   87484:	b900d3e8 	str	w8, [sp, #208]
   87488:	b900dbeb 	str	w11, [sp, #216]
   8748c:	b900e3e7 	str	w7, [sp, #224]
   87490:	b90113e3 	str	w3, [sp, #272]
   87494:	940008e3 	bl	89820 <__sprint_r>
   87498:	35ffb380 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   8749c:	f940cbe0 	ldr	x0, [sp, #400]
   874a0:	aa1603fc 	mov	x28, x22
   874a4:	b940cbe9 	ldr	w9, [sp, #200]
   874a8:	b940d3e8 	ldr	w8, [sp, #208]
   874ac:	b940dbeb 	ldr	w11, [sp, #216]
   874b0:	b940e3e7 	ldr	w7, [sp, #224]
   874b4:	b94113e3 	ldr	w3, [sp, #272]
   874b8:	17fffc64 	b	86648 <_vfprintf_r+0x358>
   874bc:	d000006d 	adrp	x13, 95000 <pmu_event_descr+0x60>
   874c0:	b9418be1 	ldr	w1, [sp, #392]
   874c4:	911f41ad 	add	x13, x13, #0x7d0
   874c8:	7100435f 	cmp	w26, #0x10
   874cc:	5400046d 	b.le	87558 <_vfprintf_r+0x1268>
   874d0:	2a1a03f8 	mov	w24, w26
   874d4:	d280021b 	mov	x27, #0x10                  	// #16
   874d8:	aa1903fa 	mov	x26, x25
   874dc:	aa0d03f9 	mov	x25, x13
   874e0:	b90093eb 	str	w11, [sp, #144]
   874e4:	b9009be3 	str	w3, [sp, #152]
   874e8:	14000004 	b	874f8 <_vfprintf_r+0x1208>
   874ec:	51004318 	sub	w24, w24, #0x10
   874f0:	7100431f 	cmp	w24, #0x10
   874f4:	5400028d 	b.le	87544 <_vfprintf_r+0x1254>
   874f8:	91004000 	add	x0, x0, #0x10
   874fc:	11000421 	add	w1, w1, #0x1
   87500:	a9006f99 	stp	x25, x27, [x28]
   87504:	9100439c 	add	x28, x28, #0x10
   87508:	b9018be1 	str	w1, [sp, #392]
   8750c:	f900cbe0 	str	x0, [sp, #400]
   87510:	71001c3f 	cmp	w1, #0x7
   87514:	54fffecd 	b.le	874ec <_vfprintf_r+0x11fc>
   87518:	910603e2 	add	x2, sp, #0x180
   8751c:	aa1503e1 	mov	x1, x21
   87520:	aa1303e0 	mov	x0, x19
   87524:	940008bf 	bl	89820 <__sprint_r>
   87528:	35ffaf00 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   8752c:	51004318 	sub	w24, w24, #0x10
   87530:	b9418be1 	ldr	w1, [sp, #392]
   87534:	f940cbe0 	ldr	x0, [sp, #400]
   87538:	aa1603fc 	mov	x28, x22
   8753c:	7100431f 	cmp	w24, #0x10
   87540:	54fffdcc 	b.gt	874f8 <_vfprintf_r+0x1208>
   87544:	b94093eb 	ldr	w11, [sp, #144]
   87548:	aa1903ed 	mov	x13, x25
   8754c:	b9409be3 	ldr	w3, [sp, #152]
   87550:	aa1a03f9 	mov	x25, x26
   87554:	2a1803fa 	mov	w26, w24
   87558:	93407f5a 	sxtw	x26, w26
   8755c:	11000421 	add	w1, w1, #0x1
   87560:	8b1a0000 	add	x0, x0, x26
   87564:	a9006b8d 	stp	x13, x26, [x28]
   87568:	b9018be1 	str	w1, [sp, #392]
   8756c:	f900cbe0 	str	x0, [sp, #400]
   87570:	71001c3f 	cmp	w1, #0x7
   87574:	54ff892d 	b.le	86698 <_vfprintf_r+0x3a8>
   87578:	910603e2 	add	x2, sp, #0x180
   8757c:	aa1503e1 	mov	x1, x21
   87580:	aa1303e0 	mov	x0, x19
   87584:	b90093eb 	str	w11, [sp, #144]
   87588:	b9009be3 	str	w3, [sp, #152]
   8758c:	940008a5 	bl	89820 <__sprint_r>
   87590:	35ffabc0 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   87594:	f940cbe0 	ldr	x0, [sp, #400]
   87598:	b94093eb 	ldr	w11, [sp, #144]
   8759c:	b9409be3 	ldr	w3, [sp, #152]
   875a0:	17fffc3e 	b	86698 <_vfprintf_r+0x3a8>
   875a4:	2a0903fa 	mov	w26, w9
   875a8:	f100241f 	cmp	x0, #0x9
   875ac:	54005108 	b.hi	87fcc <_vfprintf_r+0x1cdc>  // b.pmore
   875b0:	1100c000 	add	w0, w0, #0x30
   875b4:	2a1a03e9 	mov	w9, w26
   875b8:	9107eff8 	add	x24, sp, #0x1fb
   875bc:	5280003b 	mov	w27, #0x1                   	// #1
   875c0:	3907efe0 	strb	w0, [sp, #507]
   875c4:	17ffff29 	b	87268 <_vfprintf_r+0xf78>
   875c8:	9107f3f8 	add	x24, sp, #0x1fc
   875cc:	52800007 	mov	w7, #0x0                   	// #0
   875d0:	17ffff26 	b	87268 <_vfprintf_r+0xf78>
   875d4:	b9409fe1 	ldr	w1, [sp, #156]
   875d8:	b94093e2 	ldr	w2, [sp, #144]
   875dc:	6b01005f 	cmp	w2, w1
   875e0:	8b21c304 	add	x4, x24, w1, sxtw
   875e4:	1a81d05b 	csel	w27, w2, w1, le
   875e8:	f90067e4 	str	x4, [sp, #200]
   875ec:	7100037f 	cmp	w27, #0x0
   875f0:	5400016d 	b.le	8761c <_vfprintf_r+0x132c>
   875f4:	b9418be1 	ldr	w1, [sp, #392]
   875f8:	93407f62 	sxtw	x2, w27
   875fc:	8b020000 	add	x0, x0, x2
   87600:	a9000b98 	stp	x24, x2, [x28]
   87604:	11000421 	add	w1, w1, #0x1
   87608:	b9018be1 	str	w1, [sp, #392]
   8760c:	9100439c 	add	x28, x28, #0x10
   87610:	f900cbe0 	str	x0, [sp, #400]
   87614:	71001c3f 	cmp	w1, #0x7
   87618:	5400b32c 	b.gt	88c7c <_vfprintf_r+0x298c>
   8761c:	7100037f 	cmp	w27, #0x0
   87620:	b94093e1 	ldr	w1, [sp, #144]
   87624:	1a9fa364 	csel	w4, w27, wzr, ge	// ge = tcont
   87628:	4b04003b 	sub	w27, w1, w4
   8762c:	7100037f 	cmp	w27, #0x0
   87630:	5400554c 	b.gt	880d8 <_vfprintf_r+0x1de8>
   87634:	b94093e1 	ldr	w1, [sp, #144]
   87638:	8b21c318 	add	x24, x24, w1, sxtw
   8763c:	37508be9 	tbnz	w9, #10, 887b8 <_vfprintf_r+0x24c8>
   87640:	b9409fe1 	ldr	w1, [sp, #156]
   87644:	b9415bfa 	ldr	w26, [sp, #344]
   87648:	6b01035f 	cmp	w26, w1
   8764c:	5400004b 	b.lt	87654 <_vfprintf_r+0x1364>  // b.tstop
   87650:	36007869 	tbz	w9, #0, 8855c <_vfprintf_r+0x226c>
   87654:	a94b13e2 	ldp	x2, x4, [sp, #176]
   87658:	a9000b84 	stp	x4, x2, [x28]
   8765c:	b9418be1 	ldr	w1, [sp, #392]
   87660:	9100439c 	add	x28, x28, #0x10
   87664:	11000421 	add	w1, w1, #0x1
   87668:	b9018be1 	str	w1, [sp, #392]
   8766c:	8b020000 	add	x0, x0, x2
   87670:	f900cbe0 	str	x0, [sp, #400]
   87674:	71001c3f 	cmp	w1, #0x7
   87678:	5400b32c 	b.gt	88cdc <_vfprintf_r+0x29ec>
   8767c:	b9409fe1 	ldr	w1, [sp, #156]
   87680:	4b1a003a 	sub	w26, w1, w26
   87684:	f94067e1 	ldr	x1, [sp, #200]
   87688:	cb18003b 	sub	x27, x1, x24
   8768c:	6b1b035f 	cmp	w26, w27
   87690:	1a9bb35b 	csel	w27, w26, w27, lt	// lt = tstop
   87694:	7100037f 	cmp	w27, #0x0
   87698:	5400016d 	b.le	876c4 <_vfprintf_r+0x13d4>
   8769c:	b9418be1 	ldr	w1, [sp, #392]
   876a0:	93407f62 	sxtw	x2, w27
   876a4:	8b020000 	add	x0, x0, x2
   876a8:	a9000b98 	stp	x24, x2, [x28]
   876ac:	11000421 	add	w1, w1, #0x1
   876b0:	b9018be1 	str	w1, [sp, #392]
   876b4:	9100439c 	add	x28, x28, #0x10
   876b8:	f900cbe0 	str	x0, [sp, #400]
   876bc:	71001c3f 	cmp	w1, #0x7
   876c0:	5400b52c 	b.gt	88d64 <_vfprintf_r+0x2a74>
   876c4:	7100037f 	cmp	w27, #0x0
   876c8:	1a9fa37b 	csel	w27, w27, wzr, ge	// ge = tcont
   876cc:	4b1b035a 	sub	w26, w26, w27
   876d0:	7100035f 	cmp	w26, #0x0
   876d4:	54ff7dad 	b.le	86688 <_vfprintf_r+0x398>
   876d8:	d0000064 	adrp	x4, 95000 <pmu_event_descr+0x60>
   876dc:	b9418be1 	ldr	w1, [sp, #392]
   876e0:	911f0084 	add	x4, x4, #0x7c0
   876e4:	7100435f 	cmp	w26, #0x10
   876e8:	540045ed 	b.le	87fa4 <_vfprintf_r+0x1cb4>
   876ec:	2a1a03e5 	mov	w5, w26
   876f0:	aa1c03e2 	mov	x2, x28
   876f4:	aa1703fa 	mov	x26, x23
   876f8:	aa1903fc 	mov	x28, x25
   876fc:	aa0403f8 	mov	x24, x4
   87700:	2a0303f9 	mov	w25, w3
   87704:	2a0503f7 	mov	w23, w5
   87708:	d280021b 	mov	x27, #0x10                  	// #16
   8770c:	b90093e9 	str	w9, [sp, #144]
   87710:	b9009beb 	str	w11, [sp, #152]
   87714:	14000004 	b	87724 <_vfprintf_r+0x1434>
   87718:	510042f7 	sub	w23, w23, #0x10
   8771c:	710042ff 	cmp	w23, #0x10
   87720:	5400acad 	b.le	88cb4 <_vfprintf_r+0x29c4>
   87724:	91004000 	add	x0, x0, #0x10
   87728:	11000421 	add	w1, w1, #0x1
   8772c:	a9006c58 	stp	x24, x27, [x2]
   87730:	91004042 	add	x2, x2, #0x10
   87734:	b9018be1 	str	w1, [sp, #392]
   87738:	f900cbe0 	str	x0, [sp, #400]
   8773c:	71001c3f 	cmp	w1, #0x7
   87740:	54fffecd 	b.le	87718 <_vfprintf_r+0x1428>
   87744:	910603e2 	add	x2, sp, #0x180
   87748:	aa1503e1 	mov	x1, x21
   8774c:	aa1303e0 	mov	x0, x19
   87750:	94000834 	bl	89820 <__sprint_r>
   87754:	3500e0c0 	cbnz	w0, 8936c <_vfprintf_r+0x307c>
   87758:	f940cbe0 	ldr	x0, [sp, #400]
   8775c:	aa1603e2 	mov	x2, x22
   87760:	b9418be1 	ldr	w1, [sp, #392]
   87764:	17ffffed 	b	87718 <_vfprintf_r+0x1428>
   87768:	910603e2 	add	x2, sp, #0x180
   8776c:	aa1503e1 	mov	x1, x21
   87770:	aa1303e0 	mov	x0, x19
   87774:	b90093e9 	str	w9, [sp, #144]
   87778:	b9009beb 	str	w11, [sp, #152]
   8777c:	b900a3e3 	str	w3, [sp, #160]
   87780:	94000828 	bl	89820 <__sprint_r>
   87784:	35ff9c20 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   87788:	f940cbe0 	ldr	x0, [sp, #400]
   8778c:	aa1603e7 	mov	x7, x22
   87790:	b94093e9 	ldr	w9, [sp, #144]
   87794:	b9409beb 	ldr	w11, [sp, #152]
   87798:	b940a3e3 	ldr	w3, [sp, #160]
   8779c:	b9418be1 	ldr	w1, [sp, #392]
   877a0:	17fffd55 	b	86cf4 <_vfprintf_r+0xa04>
   877a4:	910603e2 	add	x2, sp, #0x180
   877a8:	aa1503e1 	mov	x1, x21
   877ac:	aa1303e0 	mov	x0, x19
   877b0:	b90093e9 	str	w9, [sp, #144]
   877b4:	b9009beb 	str	w11, [sp, #152]
   877b8:	b900a3e3 	str	w3, [sp, #160]
   877bc:	94000819 	bl	89820 <__sprint_r>
   877c0:	35ff9a40 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   877c4:	1e602108 	fcmp	d8, #0.0
   877c8:	b9409fe2 	ldr	w2, [sp, #156]
   877cc:	f940cbe0 	ldr	x0, [sp, #400]
   877d0:	aa1603e7 	mov	x7, x22
   877d4:	b94093e9 	ldr	w9, [sp, #144]
   877d8:	5100045a 	sub	w26, w2, #0x1
   877dc:	b9409beb 	ldr	w11, [sp, #152]
   877e0:	b940a3e3 	ldr	w3, [sp, #160]
   877e4:	b9418be1 	ldr	w1, [sp, #392]
   877e8:	54ffbb00 	b.eq	86f48 <_vfprintf_r+0xc58>  // b.none
   877ec:	17fffd4f 	b	86d28 <_vfprintf_r+0xa38>
   877f0:	f94052a0 	ldr	x0, [x21, #160]
   877f4:	f9003be9 	str	x9, [sp, #112]
   877f8:	940011ce 	bl	8bf30 <__retarget_lock_acquire_recursive>
   877fc:	f9403be9 	ldr	x9, [sp, #112]
   87800:	79c022a0 	ldrsh	w0, [x21, #16]
   87804:	17fffadf 	b	86380 <_vfprintf_r+0x90>
   87808:	36077409 	tbz	w9, #0, 86688 <_vfprintf_r+0x398>
   8780c:	17fffc17 	b	86868 <_vfprintf_r+0x578>
   87810:	37f88ec0 	tbnz	w0, #31, 889e8 <_vfprintf_r+0x26f8>
   87814:	f94043e0 	ldr	x0, [sp, #128]
   87818:	91003c01 	add	x1, x0, #0xf
   8781c:	fd400008 	ldr	d8, [x0]
   87820:	927df021 	and	x1, x1, #0xfffffffffffffff8
   87824:	f90043e1 	str	x1, [sp, #128]
   87828:	17fffd99 	b	86e8c <_vfprintf_r+0xb9c>
   8782c:	3630507a 	tbz	w26, #6, 88238 <_vfprintf_r+0x1f48>
   87830:	37f87740 	tbnz	w0, #31, 88718 <_vfprintf_r+0x2428>
   87834:	f94043e0 	ldr	x0, [sp, #128]
   87838:	91002c01 	add	x1, x0, #0xb
   8783c:	927df021 	and	x1, x1, #0xfffffffffffffff8
   87840:	f90043e1 	str	x1, [sp, #128]
   87844:	79400000 	ldrh	w0, [x0]
   87848:	52800021 	mov	w1, #0x1                   	// #1
   8784c:	17fffe77 	b	87228 <_vfprintf_r+0xf38>
   87850:	36304ce9 	tbz	w9, #6, 881ec <_vfprintf_r+0x1efc>
   87854:	37f87380 	tbnz	w0, #31, 886c4 <_vfprintf_r+0x23d4>
   87858:	f94043e0 	ldr	x0, [sp, #128]
   8785c:	91002c01 	add	x1, x0, #0xb
   87860:	927df021 	and	x1, x1, #0xfffffffffffffff8
   87864:	f90043e1 	str	x1, [sp, #128]
   87868:	79800000 	ldrsh	x0, [x0]
   8786c:	aa0003e1 	mov	x1, x0
   87870:	b6ffda41 	tbz	x1, #63, 873b8 <_vfprintf_r+0x10c8>
   87874:	cb0003e0 	neg	x0, x0
   87878:	2a0903fa 	mov	w26, w9
   8787c:	528005a2 	mov	w2, #0x2d                  	// #45
   87880:	52800021 	mov	w1, #0x1                   	// #1
   87884:	17fffe6a 	b	8722c <_vfprintf_r+0xf3c>
   87888:	39400328 	ldrb	w8, [x25]
   8788c:	17fffb33 	b	86558 <_vfprintf_r+0x268>
   87890:	3727d669 	tbnz	w9, #4, 8735c <_vfprintf_r+0x106c>
   87894:	37306729 	tbnz	w9, #6, 88578 <_vfprintf_r+0x2288>
   87898:	3648bf49 	tbz	w9, #9, 89080 <_vfprintf_r+0x2d90>
   8789c:	37f8d860 	tbnz	w0, #31, 893a8 <_vfprintf_r+0x30b8>
   878a0:	f94043e0 	ldr	x0, [sp, #128]
   878a4:	91003c01 	add	x1, x0, #0xf
   878a8:	927df021 	and	x1, x1, #0xfffffffffffffff8
   878ac:	f90043e1 	str	x1, [sp, #128]
   878b0:	f9400000 	ldr	x0, [x0]
   878b4:	3941c3e1 	ldrb	w1, [sp, #112]
   878b8:	39000001 	strb	w1, [x0]
   878bc:	17fffad4 	b	8640c <_vfprintf_r+0x11c>
   878c0:	36304869 	tbz	w9, #6, 881cc <_vfprintf_r+0x1edc>
   878c4:	37f86ea0 	tbnz	w0, #31, 88698 <_vfprintf_r+0x23a8>
   878c8:	f94043e0 	ldr	x0, [sp, #128]
   878cc:	91002c01 	add	x1, x0, #0xb
   878d0:	927df021 	and	x1, x1, #0xfffffffffffffff8
   878d4:	79400000 	ldrh	w0, [x0]
   878d8:	f90043e1 	str	x1, [sp, #128]
   878dc:	17fffe51 	b	87220 <_vfprintf_r+0xf30>
   878e0:	2a1703e9 	mov	w9, w23
   878e4:	2a1803eb 	mov	w11, w24
   878e8:	2a1a03e7 	mov	w7, w26
   878ec:	17fffea8 	b	8738c <_vfprintf_r+0x109c>
   878f0:	b9407fe0 	ldr	w0, [sp, #124]
   878f4:	11002001 	add	w1, w0, #0x8
   878f8:	7100003f 	cmp	w1, #0x0
   878fc:	54009a0d 	b.le	88c3c <_vfprintf_r+0x294c>
   87900:	f94043e0 	ldr	x0, [sp, #128]
   87904:	b9007fe1 	str	w1, [sp, #124]
   87908:	91003c02 	add	x2, x0, #0xf
   8790c:	927df041 	and	x1, x2, #0xfffffffffffffff8
   87910:	f90043e1 	str	x1, [sp, #128]
   87914:	17fffdd2 	b	8705c <_vfprintf_r+0xd6c>
   87918:	b9407fe0 	ldr	w0, [sp, #124]
   8791c:	11002001 	add	w1, w0, #0x8
   87920:	7100003f 	cmp	w1, #0x0
   87924:	5400982d 	b.le	88c28 <_vfprintf_r+0x2938>
   87928:	f94043e0 	ldr	x0, [sp, #128]
   8792c:	b9007fe1 	str	w1, [sp, #124]
   87930:	91003c02 	add	x2, x0, #0xf
   87934:	927df041 	and	x1, x2, #0xfffffffffffffff8
   87938:	f90043e1 	str	x1, [sp, #128]
   8793c:	17fffe7b 	b	87328 <_vfprintf_r+0x1038>
   87940:	b9407fe0 	ldr	w0, [sp, #124]
   87944:	11002001 	add	w1, w0, #0x8
   87948:	7100003f 	cmp	w1, #0x0
   8794c:	5400960d 	b.le	88c0c <_vfprintf_r+0x291c>
   87950:	f94043e0 	ldr	x0, [sp, #128]
   87954:	b9007fe1 	str	w1, [sp, #124]
   87958:	91002c00 	add	x0, x0, #0xb
   8795c:	927df000 	and	x0, x0, #0xfffffffffffffff8
   87960:	17fffe00 	b	87160 <_vfprintf_r+0xe70>
   87964:	b94093e9 	ldr	w9, [sp, #144]
   87968:	aa1903e4 	mov	x4, x25
   8796c:	b9409be3 	ldr	w3, [sp, #152]
   87970:	aa1a03f9 	mov	x25, x26
   87974:	2a1c03eb 	mov	w11, w28
   87978:	2a1803fa 	mov	w26, w24
   8797c:	93407f5a 	sxtw	x26, w26
   87980:	11000421 	add	w1, w1, #0x1
   87984:	8b1a0000 	add	x0, x0, x26
   87988:	b9018be1 	str	w1, [sp, #392]
   8798c:	f900cbe0 	str	x0, [sp, #400]
   87990:	f90000e4 	str	x4, [x7]
   87994:	f90004fa 	str	x26, [x7, #8]
   87998:	71001c3f 	cmp	w1, #0x7
   8799c:	54ff9dad 	b.le	86d50 <_vfprintf_r+0xa60>
   879a0:	910603e2 	add	x2, sp, #0x180
   879a4:	aa1503e1 	mov	x1, x21
   879a8:	aa1303e0 	mov	x0, x19
   879ac:	b90093e9 	str	w9, [sp, #144]
   879b0:	b9009beb 	str	w11, [sp, #152]
   879b4:	b900a3e3 	str	w3, [sp, #160]
   879b8:	9400079a 	bl	89820 <__sprint_r>
   879bc:	35ff8a60 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   879c0:	f940cbe0 	ldr	x0, [sp, #400]
   879c4:	aa1603e7 	mov	x7, x22
   879c8:	b94093e9 	ldr	w9, [sp, #144]
   879cc:	b9409beb 	ldr	w11, [sp, #152]
   879d0:	b940a3e3 	ldr	w3, [sp, #160]
   879d4:	b9418be1 	ldr	w1, [sp, #392]
   879d8:	17fffcdf 	b	86d54 <_vfprintf_r+0xa64>
   879dc:	910603e2 	add	x2, sp, #0x180
   879e0:	aa1503e1 	mov	x1, x21
   879e4:	aa1303e0 	mov	x0, x19
   879e8:	b90093e9 	str	w9, [sp, #144]
   879ec:	b9009beb 	str	w11, [sp, #152]
   879f0:	b900a3e3 	str	w3, [sp, #160]
   879f4:	9400078b 	bl	89820 <__sprint_r>
   879f8:	35ff8880 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   879fc:	f940cbe0 	ldr	x0, [sp, #400]
   87a00:	aa1603fc 	mov	x28, x22
   87a04:	b94093e9 	ldr	w9, [sp, #144]
   87a08:	b9409beb 	ldr	w11, [sp, #152]
   87a0c:	b940a3e3 	ldr	w3, [sp, #160]
   87a10:	17fffba0 	b	86890 <_vfprintf_r+0x5a0>
   87a14:	39400728 	ldrb	w8, [x25, #1]
   87a18:	321b02f7 	orr	w23, w23, #0x20
   87a1c:	91000739 	add	x25, x25, #0x1
   87a20:	17ffface 	b	86558 <_vfprintf_r+0x268>
   87a24:	39400728 	ldrb	w8, [x25, #1]
   87a28:	321702f7 	orr	w23, w23, #0x200
   87a2c:	91000739 	add	x25, x25, #0x1
   87a30:	17fffaca 	b	86558 <_vfprintf_r+0x268>
   87a34:	2a1a03e7 	mov	w7, w26
   87a38:	2a1803eb 	mov	w11, w24
   87a3c:	2a1703fa 	mov	w26, w23
   87a40:	17fffe19 	b	872a4 <_vfprintf_r+0xfb4>
   87a44:	2a1703e9 	mov	w9, w23
   87a48:	2a1803eb 	mov	w11, w24
   87a4c:	2a1a03e7 	mov	w7, w26
   87a50:	d0000060 	adrp	x0, 95000 <pmu_event_descr+0x60>
   87a54:	91180000 	add	x0, x0, #0x600
   87a58:	f90063e0 	str	x0, [sp, #192]
   87a5c:	b9407fe0 	ldr	w0, [sp, #124]
   87a60:	372806e9 	tbnz	w9, #5, 87b3c <_vfprintf_r+0x184c>
   87a64:	372006c9 	tbnz	w9, #4, 87b3c <_vfprintf_r+0x184c>
   87a68:	36303849 	tbz	w9, #6, 88170 <_vfprintf_r+0x1e80>
   87a6c:	37f86400 	tbnz	w0, #31, 886ec <_vfprintf_r+0x23fc>
   87a70:	f94043e0 	ldr	x0, [sp, #128]
   87a74:	91002c01 	add	x1, x0, #0xb
   87a78:	927df021 	and	x1, x1, #0xfffffffffffffff8
   87a7c:	79400000 	ldrh	w0, [x0]
   87a80:	f90043e1 	str	x1, [sp, #128]
   87a84:	14000034 	b	87b54 <_vfprintf_r+0x1864>
   87a88:	d0000060 	adrp	x0, 95000 <pmu_event_descr+0x60>
   87a8c:	2a1703e9 	mov	w9, w23
   87a90:	9117a000 	add	x0, x0, #0x5e8
   87a94:	2a1803eb 	mov	w11, w24
   87a98:	2a1a03e7 	mov	w7, w26
   87a9c:	f90063e0 	str	x0, [sp, #192]
   87aa0:	17ffffef 	b	87a5c <_vfprintf_r+0x176c>
   87aa4:	2a1703e9 	mov	w9, w23
   87aa8:	2a1803eb 	mov	w11, w24
   87aac:	2a1a03e7 	mov	w7, w26
   87ab0:	17fffdd3 	b	871fc <_vfprintf_r+0xf0c>
   87ab4:	9105e3e0 	add	x0, sp, #0x178
   87ab8:	d2800102 	mov	x2, #0x8                   	// #8
   87abc:	52800001 	mov	w1, #0x0                   	// #0
   87ac0:	b90093e9 	str	w9, [sp, #144]
   87ac4:	b9009be8 	str	w8, [sp, #152]
   87ac8:	b900a3eb 	str	w11, [sp, #160]
   87acc:	940016bd 	bl	8d5c0 <memset>
   87ad0:	b9407fe0 	ldr	w0, [sp, #124]
   87ad4:	b94093e9 	ldr	w9, [sp, #144]
   87ad8:	b9409be8 	ldr	w8, [sp, #152]
   87adc:	b940a3eb 	ldr	w11, [sp, #160]
   87ae0:	37f83620 	tbnz	w0, #31, 881a4 <_vfprintf_r+0x1eb4>
   87ae4:	f94043e0 	ldr	x0, [sp, #128]
   87ae8:	91002c01 	add	x1, x0, #0xb
   87aec:	927df021 	and	x1, x1, #0xfffffffffffffff8
   87af0:	f90043e1 	str	x1, [sp, #128]
   87af4:	b9400002 	ldr	w2, [x0]
   87af8:	910663f7 	add	x23, sp, #0x198
   87afc:	9105e3e3 	add	x3, sp, #0x178
   87b00:	aa1703e1 	mov	x1, x23
   87b04:	aa1303e0 	mov	x0, x19
   87b08:	b90093e9 	str	w9, [sp, #144]
   87b0c:	b9009be8 	str	w8, [sp, #152]
   87b10:	b900a3eb 	str	w11, [sp, #160]
   87b14:	940010a7 	bl	8bdb0 <_wcrtomb_r>
   87b18:	b94093e9 	ldr	w9, [sp, #144]
   87b1c:	2a0003fb 	mov	w27, w0
   87b20:	b9409be8 	ldr	w8, [sp, #152]
   87b24:	3100041f 	cmn	w0, #0x1
   87b28:	b940a3eb 	ldr	w11, [sp, #160]
   87b2c:	5400caa0 	b.eq	89480 <_vfprintf_r+0x3190>  // b.none
   87b30:	7100001f 	cmp	w0, #0x0
   87b34:	1a9fa003 	csel	w3, w0, wzr, ge	// ge = tcont
   87b38:	17fffd37 	b	87014 <_vfprintf_r+0xd24>
   87b3c:	37f801a0 	tbnz	w0, #31, 87b70 <_vfprintf_r+0x1880>
   87b40:	f94043e0 	ldr	x0, [sp, #128]
   87b44:	91003c01 	add	x1, x0, #0xf
   87b48:	927df021 	and	x1, x1, #0xfffffffffffffff8
   87b4c:	f90043e1 	str	x1, [sp, #128]
   87b50:	f9400000 	ldr	x0, [x0]
   87b54:	f100001f 	cmp	x0, #0x0
   87b58:	1a9f07e1 	cset	w1, ne	// ne = any
   87b5c:	6a01013f 	tst	w9, w1
   87b60:	540008a1 	b.ne	87c74 <_vfprintf_r+0x1984>  // b.any
   87b64:	1215793a 	and	w26, w9, #0xfffffbff
   87b68:	52800041 	mov	w1, #0x2                   	// #2
   87b6c:	17fffdaf 	b	87228 <_vfprintf_r+0xf38>
   87b70:	b9407fe0 	ldr	w0, [sp, #124]
   87b74:	11002001 	add	w1, w0, #0x8
   87b78:	7100003f 	cmp	w1, #0x0
   87b7c:	540034ad 	b.le	88210 <_vfprintf_r+0x1f20>
   87b80:	f94043e0 	ldr	x0, [sp, #128]
   87b84:	b9007fe1 	str	w1, [sp, #124]
   87b88:	91003c02 	add	x2, x0, #0xf
   87b8c:	927df041 	and	x1, x2, #0xfffffffffffffff8
   87b90:	f90043e1 	str	x1, [sp, #128]
   87b94:	17ffffef 	b	87b50 <_vfprintf_r+0x1860>
   87b98:	b9407fe0 	ldr	w0, [sp, #124]
   87b9c:	11002001 	add	w1, w0, #0x8
   87ba0:	7100003f 	cmp	w1, #0x0
   87ba4:	5400340d 	b.le	88224 <_vfprintf_r+0x1f34>
   87ba8:	f94043e0 	ldr	x0, [sp, #128]
   87bac:	b9007fe1 	str	w1, [sp, #124]
   87bb0:	91003c02 	add	x2, x0, #0xf
   87bb4:	927df041 	and	x1, x2, #0xfffffffffffffff8
   87bb8:	f90043e1 	str	x1, [sp, #128]
   87bbc:	17fffdfc 	b	873ac <_vfprintf_r+0x10bc>
   87bc0:	b9407fe0 	ldr	w0, [sp, #124]
   87bc4:	11002001 	add	w1, w0, #0x8
   87bc8:	7100003f 	cmp	w1, #0x0
   87bcc:	54002e2d 	b.le	88190 <_vfprintf_r+0x1ea0>
   87bd0:	f94043e0 	ldr	x0, [sp, #128]
   87bd4:	b9007fe1 	str	w1, [sp, #124]
   87bd8:	91003c02 	add	x2, x0, #0xf
   87bdc:	927df041 	and	x1, x2, #0xfffffffffffffff8
   87be0:	f90043e1 	str	x1, [sp, #128]
   87be4:	17fffd8e 	b	8721c <_vfprintf_r+0xf2c>
   87be8:	b9407fe0 	ldr	w0, [sp, #124]
   87bec:	11002001 	add	w1, w0, #0x8
   87bf0:	7100003f 	cmp	w1, #0x0
   87bf4:	5400334d 	b.le	8825c <_vfprintf_r+0x1f6c>
   87bf8:	f94043e0 	ldr	x0, [sp, #128]
   87bfc:	b9007fe1 	str	w1, [sp, #124]
   87c00:	91003c02 	add	x2, x0, #0xf
   87c04:	927df041 	and	x1, x2, #0xfffffffffffffff8
   87c08:	f90043e1 	str	x1, [sp, #128]
   87c0c:	17fffdae 	b	872c4 <_vfprintf_r+0xfd4>
   87c10:	910603e2 	add	x2, sp, #0x180
   87c14:	aa1503e1 	mov	x1, x21
   87c18:	aa1303e0 	mov	x0, x19
   87c1c:	b900cbf2 	str	w18, [sp, #200]
   87c20:	b900d3e9 	str	w9, [sp, #208]
   87c24:	b900dbe8 	str	w8, [sp, #216]
   87c28:	b900e3eb 	str	w11, [sp, #224]
   87c2c:	b90113e7 	str	w7, [sp, #272]
   87c30:	b9011be3 	str	w3, [sp, #280]
   87c34:	940006fb 	bl	89820 <__sprint_r>
   87c38:	35ff7680 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   87c3c:	f940cbe0 	ldr	x0, [sp, #400]
   87c40:	aa1603fc 	mov	x28, x22
   87c44:	39453fe1 	ldrb	w1, [sp, #335]
   87c48:	b940cbf2 	ldr	w18, [sp, #200]
   87c4c:	b940d3e9 	ldr	w9, [sp, #208]
   87c50:	b940dbe8 	ldr	w8, [sp, #216]
   87c54:	b940e3eb 	ldr	w11, [sp, #224]
   87c58:	b94113e7 	ldr	w7, [sp, #272]
   87c5c:	b9411be3 	ldr	w3, [sp, #280]
   87c60:	17fffa60 	b	865e0 <_vfprintf_r+0x2f0>
   87c64:	aa1303e0 	mov	x0, x19
   87c68:	97ffea66 	bl	82600 <__sinit>
   87c6c:	f9403be9 	ldr	x9, [sp, #112]
   87c70:	17fff9c0 	b	86370 <_vfprintf_r+0x80>
   87c74:	52800601 	mov	w1, #0x30                  	// #48
   87c78:	321f0129 	orr	w9, w9, #0x2
   87c7c:	390543e1 	strb	w1, [sp, #336]
   87c80:	390547e8 	strb	w8, [sp, #337]
   87c84:	17ffffb8 	b	87b64 <_vfprintf_r+0x1874>
   87c88:	1e682100 	fcmp	d8, d8
   87c8c:	5400a3c6 	b.vs	89104 <_vfprintf_r+0x2e14>
   87c90:	121a791b 	and	w27, w8, #0xffffffdf
   87c94:	7101077f 	cmp	w27, #0x41
   87c98:	54002ec1 	b.ne	88270 <_vfprintf_r+0x1f80>  // b.any
   87c9c:	52800b01 	mov	w1, #0x58                  	// #88
   87ca0:	7101851f 	cmp	w8, #0x61
   87ca4:	52800f00 	mov	w0, #0x78                  	// #120
   87ca8:	1a810000 	csel	w0, w0, w1, eq	// eq = none
   87cac:	52800601 	mov	w1, #0x30                  	// #48
   87cb0:	390543e1 	strb	w1, [sp, #336]
   87cb4:	390547e0 	strb	w0, [sp, #337]
   87cb8:	910663f8 	add	x24, sp, #0x198
   87cbc:	d2800017 	mov	x23, #0x0                   	// #0
   87cc0:	71018cff 	cmp	w7, #0x63
   87cc4:	540054ec 	b.gt	88760 <_vfprintf_r+0x2470>
   87cc8:	9e660101 	fmov	x1, d8
   87ccc:	1e614100 	fneg	d0, d8
   87cd0:	528005a2 	mov	w2, #0x2d                  	// #45
   87cd4:	910563e0 	add	x0, sp, #0x158
   87cd8:	b90093e9 	str	w9, [sp, #144]
   87cdc:	29132fe8 	stp	w8, w11, [sp, #152]
   87ce0:	d360fc21 	lsr	x1, x1, #32
   87ce4:	b900a3e7 	str	w7, [sp, #160]
   87ce8:	7100003f 	cmp	w1, #0x0
   87cec:	1a9fb041 	csel	w1, w2, wzr, lt	// lt = tstop
   87cf0:	b900cbe1 	str	w1, [sp, #200]
   87cf4:	1e68bc00 	fcsel	d0, d0, d8, lt	// lt = tstop
   87cf8:	94001cee 	bl	8f0b0 <frexp>
   87cfc:	1e681001 	fmov	d1, #1.250000000000000000e-01
   87d00:	b94093e9 	ldr	w9, [sp, #144]
   87d04:	29532fe8 	ldp	w8, w11, [sp, #152]
   87d08:	1e610801 	fmul	d1, d0, d1
   87d0c:	b940a3e7 	ldr	w7, [sp, #160]
   87d10:	1e602028 	fcmp	d1, #0.0
   87d14:	54005160 	b.eq	88740 <_vfprintf_r+0x2450>  // b.none
   87d18:	2a0703e3 	mov	w3, w7
   87d1c:	7101851f 	cmp	w8, #0x61
   87d20:	91000463 	add	x3, x3, #0x1
   87d24:	d0000060 	adrp	x0, 95000 <pmu_event_descr+0x60>
   87d28:	d0000062 	adrp	x2, 95000 <pmu_event_descr+0x60>
   87d2c:	91180000 	add	x0, x0, #0x600
   87d30:	9117a042 	add	x2, x2, #0x5e8
   87d34:	8b030303 	add	x3, x24, x3
   87d38:	9a800042 	csel	x2, x2, x0, eq	// eq = none
   87d3c:	1e661002 	fmov	d2, #1.600000000000000000e+01
   87d40:	aa1803e0 	mov	x0, x24
   87d44:	14000003 	b	87d50 <_vfprintf_r+0x1a60>
   87d48:	1e602028 	fcmp	d1, #0.0
   87d4c:	5400a6c0 	b.eq	89224 <_vfprintf_r+0x2f34>  // b.none
   87d50:	1e620821 	fmul	d1, d1, d2
   87d54:	aa0003ec 	mov	x12, x0
   87d58:	1e780021 	fcvtzs	w1, d1
   87d5c:	1e620020 	scvtf	d0, w1
   87d60:	3861c844 	ldrb	w4, [x2, w1, sxtw]
   87d64:	38001404 	strb	w4, [x0], #1
   87d68:	1e603821 	fsub	d1, d1, d0
   87d6c:	eb00007f 	cmp	x3, x0
   87d70:	54fffec1 	b.ne	87d48 <_vfprintf_r+0x1a58>  // b.any
   87d74:	12800003 	mov	w3, #0xffffffff            	// #-1
   87d78:	1e6c1000 	fmov	d0, #5.000000000000000000e-01
   87d7c:	1e602030 	fcmpe	d1, d0
   87d80:	540092cc 	b.gt	88fd8 <_vfprintf_r+0x2ce8>
   87d84:	1e602020 	fcmp	d1, d0
   87d88:	54000041 	b.ne	87d90 <_vfprintf_r+0x1aa0>  // b.any
   87d8c:	37009261 	tbnz	w1, #0, 88fd8 <_vfprintf_r+0x2ce8>
   87d90:	11000461 	add	w1, w3, #0x1
   87d94:	52800602 	mov	w2, #0x30                  	// #48
   87d98:	8b21c001 	add	x1, x0, w1, sxtw
   87d9c:	37f89443 	tbnz	w3, #31, 89024 <_vfprintf_r+0x2d34>
   87da0:	38001402 	strb	w2, [x0], #1
   87da4:	eb00003f 	cmp	x1, x0
   87da8:	54ffffc1 	b.ne	87da0 <_vfprintf_r+0x1ab0>  // b.any
   87dac:	b9415be0 	ldr	w0, [sp, #344]
   87db0:	b90093e0 	str	w0, [sp, #144]
   87db4:	4b180020 	sub	w0, w1, w24
   87db8:	b9009fe0 	str	w0, [sp, #156]
   87dbc:	b94093e0 	ldr	w0, [sp, #144]
   87dc0:	11003d01 	add	w1, w8, #0xf
   87dc4:	321f0129 	orr	w9, w9, #0x2
   87dc8:	12001c21 	and	w1, w1, #0xff
   87dcc:	51000400 	sub	w0, w0, #0x1
   87dd0:	52800022 	mov	w2, #0x1                   	// #1
   87dd4:	b9015be0 	str	w0, [sp, #344]
   87dd8:	14000166 	b	88370 <_vfprintf_r+0x2080>
   87ddc:	910603e2 	add	x2, sp, #0x180
   87de0:	aa1503e1 	mov	x1, x21
   87de4:	aa1303e0 	mov	x0, x19
   87de8:	b90093e9 	str	w9, [sp, #144]
   87dec:	b9009beb 	str	w11, [sp, #152]
   87df0:	b900a3e3 	str	w3, [sp, #160]
   87df4:	9400068b 	bl	89820 <__sprint_r>
   87df8:	35ff6880 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   87dfc:	f940cbe0 	ldr	x0, [sp, #400]
   87e00:	aa1603fc 	mov	x28, x22
   87e04:	b94093e9 	ldr	w9, [sp, #144]
   87e08:	b9409beb 	ldr	w11, [sp, #152]
   87e0c:	b940a3e3 	ldr	w3, [sp, #160]
   87e10:	17fffa92 	b	86858 <_vfprintf_r+0x568>
   87e14:	9105c3e0 	add	x0, sp, #0x170
   87e18:	d2800102 	mov	x2, #0x8                   	// #8
   87e1c:	52800001 	mov	w1, #0x0                   	// #0
   87e20:	b90093e9 	str	w9, [sp, #144]
   87e24:	b9009be8 	str	w8, [sp, #152]
   87e28:	b900a3eb 	str	w11, [sp, #160]
   87e2c:	b900cbe7 	str	w7, [sp, #200]
   87e30:	f900bff8 	str	x24, [sp, #376]
   87e34:	940015e3 	bl	8d5c0 <memset>
   87e38:	b940cbe7 	ldr	w7, [sp, #200]
   87e3c:	b94093e9 	ldr	w9, [sp, #144]
   87e40:	b9409be8 	ldr	w8, [sp, #152]
   87e44:	b940a3eb 	ldr	w11, [sp, #160]
   87e48:	310004ff 	cmn	w7, #0x1
   87e4c:	54005ec0 	b.eq	88a24 <_vfprintf_r+0x2734>  // b.none
   87e50:	aa1903e0 	mov	x0, x25
   87e54:	5280001b 	mov	w27, #0x0                   	// #0
   87e58:	aa1503f9 	mov	x25, x21
   87e5c:	2a0703fa 	mov	w26, w7
   87e60:	2a1b03f5 	mov	w21, w27
   87e64:	d2800017 	mov	x23, #0x0                   	// #0
   87e68:	aa0003fb 	mov	x27, x0
   87e6c:	b90093e9 	str	w9, [sp, #144]
   87e70:	b9009be8 	str	w8, [sp, #152]
   87e74:	b900a3eb 	str	w11, [sp, #160]
   87e78:	1400000d 	b	87eac <_vfprintf_r+0x1bbc>
   87e7c:	9105c3e3 	add	x3, sp, #0x170
   87e80:	910663e1 	add	x1, sp, #0x198
   87e84:	aa1303e0 	mov	x0, x19
   87e88:	94000fca 	bl	8bdb0 <_wcrtomb_r>
   87e8c:	3100041f 	cmn	w0, #0x1
   87e90:	54008ee0 	b.eq	8906c <_vfprintf_r+0x2d7c>  // b.none
   87e94:	0b0002a0 	add	w0, w21, w0
   87e98:	6b1a001f 	cmp	w0, w26
   87e9c:	540000ec 	b.gt	87eb8 <_vfprintf_r+0x1bc8>
   87ea0:	910012f7 	add	x23, x23, #0x4
   87ea4:	5400a1a0 	b.eq	892d8 <_vfprintf_r+0x2fe8>  // b.none
   87ea8:	2a0003f5 	mov	w21, w0
   87eac:	f940bfe0 	ldr	x0, [sp, #376]
   87eb0:	b8776802 	ldr	w2, [x0, x23]
   87eb4:	35fffe42 	cbnz	w2, 87e7c <_vfprintf_r+0x1b8c>
   87eb8:	aa1b03e0 	mov	x0, x27
   87ebc:	b94093e9 	ldr	w9, [sp, #144]
   87ec0:	b9409be8 	ldr	w8, [sp, #152]
   87ec4:	2a1503fb 	mov	w27, w21
   87ec8:	b940a3eb 	ldr	w11, [sp, #160]
   87ecc:	aa1903f5 	mov	x21, x25
   87ed0:	aa0003f9 	mov	x25, x0
   87ed4:	3400677b 	cbz	w27, 88bc0 <_vfprintf_r+0x28d0>
   87ed8:	71018f7f 	cmp	w27, #0x63
   87edc:	54007ead 	b.le	88eb0 <_vfprintf_r+0x2bc0>
   87ee0:	11000761 	add	w1, w27, #0x1
   87ee4:	aa1303e0 	mov	x0, x19
   87ee8:	b90093e9 	str	w9, [sp, #144]
   87eec:	93407c21 	sxtw	x1, w1
   87ef0:	b9009be8 	str	w8, [sp, #152]
   87ef4:	b900a3eb 	str	w11, [sp, #160]
   87ef8:	94000da2 	bl	8b580 <_malloc_r>
   87efc:	b94093e9 	ldr	w9, [sp, #144]
   87f00:	aa0003f8 	mov	x24, x0
   87f04:	b9409be8 	ldr	w8, [sp, #152]
   87f08:	b940a3eb 	ldr	w11, [sp, #160]
   87f0c:	b400aba0 	cbz	x0, 89480 <_vfprintf_r+0x3190>
   87f10:	aa0003f7 	mov	x23, x0
   87f14:	93407f7a 	sxtw	x26, w27
   87f18:	d2800102 	mov	x2, #0x8                   	// #8
   87f1c:	52800001 	mov	w1, #0x0                   	// #0
   87f20:	9105c3e0 	add	x0, sp, #0x170
   87f24:	b90093e9 	str	w9, [sp, #144]
   87f28:	b9009be8 	str	w8, [sp, #152]
   87f2c:	b900a3eb 	str	w11, [sp, #160]
   87f30:	940015a4 	bl	8d5c0 <memset>
   87f34:	9105c3e4 	add	x4, sp, #0x170
   87f38:	aa1a03e3 	mov	x3, x26
   87f3c:	9105e3e2 	add	x2, sp, #0x178
   87f40:	aa1803e1 	mov	x1, x24
   87f44:	aa1303e0 	mov	x0, x19
   87f48:	9400161e 	bl	8d7c0 <_wcsrtombs_r>
   87f4c:	b94093e9 	ldr	w9, [sp, #144]
   87f50:	eb00035f 	cmp	x26, x0
   87f54:	b9409be8 	ldr	w8, [sp, #152]
   87f58:	b940a3eb 	ldr	w11, [sp, #160]
   87f5c:	5400b4c1 	b.ne	895f4 <_vfprintf_r+0x3304>  // b.any
   87f60:	383bcb1f 	strb	wzr, [x24, w27, sxtw]
   87f64:	7100037f 	cmp	w27, #0x0
   87f68:	b90093ff 	str	wzr, [sp, #144]
   87f6c:	1a9fa363 	csel	w3, w27, wzr, ge	// ge = tcont
   87f70:	39453fe1 	ldrb	w1, [sp, #335]
   87f74:	52800007 	mov	w7, #0x0                   	// #0
   87f78:	b9009bff 	str	wzr, [sp, #152]
   87f7c:	b900a3ff 	str	wzr, [sp, #160]
   87f80:	34ff31c1 	cbz	w1, 865b8 <_vfprintf_r+0x2c8>
   87f84:	17fffbd9 	b	86ee8 <_vfprintf_r+0xbf8>
   87f88:	b94093e9 	ldr	w9, [sp, #144]
   87f8c:	2a1a03e3 	mov	w3, w26
   87f90:	b9409beb 	ldr	w11, [sp, #152]
   87f94:	aa1903e4 	mov	x4, x25
   87f98:	2a1803fa 	mov	w26, w24
   87f9c:	aa1c03f9 	mov	x25, x28
   87fa0:	aa0203fc 	mov	x28, x2
   87fa4:	93407f5a 	sxtw	x26, w26
   87fa8:	11000421 	add	w1, w1, #0x1
   87fac:	8b1a0000 	add	x0, x0, x26
   87fb0:	b9018be1 	str	w1, [sp, #392]
   87fb4:	f900cbe0 	str	x0, [sp, #400]
   87fb8:	a9006b84 	stp	x4, x26, [x28]
   87fbc:	71001c3f 	cmp	w1, #0x7
   87fc0:	54ff580c 	b.gt	86ac0 <_vfprintf_r+0x7d0>
   87fc4:	9100439c 	add	x28, x28, #0x10
   87fc8:	17fff9b0 	b	86688 <_vfprintf_r+0x398>
   87fcc:	12160343 	and	w3, w26, #0x400
   87fd0:	9107f3ec 	add	x12, sp, #0x1fc
   87fd4:	b202e7fb 	mov	x27, #0xcccccccccccccccc    	// #-3689348814741910324
   87fd8:	aa1903e4 	mov	x4, x25
   87fdc:	aa0c03e2 	mov	x2, x12
   87fe0:	aa1303f9 	mov	x25, x19
   87fe4:	52800005 	mov	w5, #0x0                   	// #0
   87fe8:	2a0303f3 	mov	w19, w3
   87fec:	f29999bb 	movk	x27, #0xcccd
   87ff0:	aa1503e3 	mov	x3, x21
   87ff4:	f9407ff5 	ldr	x21, [sp, #248]
   87ff8:	14000007 	b	88014 <_vfprintf_r+0x1d24>
   87ffc:	9bdb7c17 	umulh	x23, x0, x27
   88000:	d343fef7 	lsr	x23, x23, #3
   88004:	f100241f 	cmp	x0, #0x9
   88008:	54000249 	b.ls	88050 <_vfprintf_r+0x1d60>  // b.plast
   8800c:	aa1703e0 	mov	x0, x23
   88010:	aa1803e2 	mov	x2, x24
   88014:	9bdb7c17 	umulh	x23, x0, x27
   88018:	110004a5 	add	w5, w5, #0x1
   8801c:	d1000458 	sub	x24, x2, #0x1
   88020:	d343fef7 	lsr	x23, x23, #3
   88024:	8b170ae1 	add	x1, x23, x23, lsl #2
   88028:	cb010401 	sub	x1, x0, x1, lsl #1
   8802c:	1100c021 	add	w1, w1, #0x30
   88030:	381ff041 	sturb	w1, [x2, #-1]
   88034:	34fffe53 	cbz	w19, 87ffc <_vfprintf_r+0x1d0c>
   88038:	394002a1 	ldrb	w1, [x21]
   8803c:	7103fc3f 	cmp	w1, #0xff
   88040:	7a451020 	ccmp	w1, w5, #0x0, ne	// ne = any
   88044:	54fffdc1 	b.ne	87ffc <_vfprintf_r+0x1d0c>  // b.any
   88048:	f100241f 	cmp	x0, #0x9
   8804c:	54006668 	b.hi	88d18 <_vfprintf_r+0x2a28>  // b.pmore
   88050:	aa1903f3 	mov	x19, x25
   88054:	aa0403f9 	mov	x25, x4
   88058:	b9009fe5 	str	w5, [sp, #156]
   8805c:	f9007ff5 	str	x21, [sp, #248]
   88060:	aa0303f5 	mov	x21, x3
   88064:	17fffcf0 	b	87424 <_vfprintf_r+0x1134>
   88068:	710018ff 	cmp	w7, #0x6
   8806c:	528000c3 	mov	w3, #0x6                   	// #6
   88070:	1a8390e3 	csel	w3, w7, w3, ls	// ls = plast
   88074:	b0000065 	adrp	x5, 95000 <pmu_event_descr+0x60>
   88078:	2a0303fb 	mov	w27, w3
   8807c:	911860b8 	add	x24, x5, #0x618
   88080:	d2800017 	mov	x23, #0x0                   	// #0
   88084:	52800001 	mov	w1, #0x0                   	// #0
   88088:	52800007 	mov	w7, #0x0                   	// #0
   8808c:	b90093ff 	str	wzr, [sp, #144]
   88090:	b9009bff 	str	wzr, [sp, #152]
   88094:	b900a3ff 	str	wzr, [sp, #160]
   88098:	17fff948 	b	865b8 <_vfprintf_r+0x2c8>
   8809c:	b9407fe0 	ldr	w0, [sp, #124]
   880a0:	11002001 	add	w1, w0, #0x8
   880a4:	7100003f 	cmp	w1, #0x0
   880a8:	540027ad 	b.le	8859c <_vfprintf_r+0x22ac>
   880ac:	f94043e0 	ldr	x0, [sp, #128]
   880b0:	b9007fe1 	str	w1, [sp, #124]
   880b4:	91003c02 	add	x2, x0, #0xf
   880b8:	927df041 	and	x1, x2, #0xfffffffffffffff8
   880bc:	f90043e1 	str	x1, [sp, #128]
   880c0:	17fffcac 	b	87370 <_vfprintf_r+0x1080>
   880c4:	f940cbe0 	ldr	x0, [sp, #400]
   880c8:	b5002b00 	cbnz	x0, 88628 <_vfprintf_r+0x2338>
   880cc:	79c022a0 	ldrsh	w0, [x21, #16]
   880d0:	b9018bff 	str	wzr, [sp, #392]
   880d4:	17fffa92 	b	86b1c <_vfprintf_r+0x82c>
   880d8:	b0000064 	adrp	x4, 95000 <pmu_event_descr+0x60>
   880dc:	b9418be1 	ldr	w1, [sp, #392]
   880e0:	911f0084 	add	x4, x4, #0x7c0
   880e4:	7100437f 	cmp	w27, #0x10
   880e8:	54001d6d 	b.le	88494 <_vfprintf_r+0x21a4>
   880ec:	2a1b03e5 	mov	w5, w27
   880f0:	aa1c03e2 	mov	x2, x28
   880f4:	aa1703fb 	mov	x27, x23
   880f8:	aa1903fc 	mov	x28, x25
   880fc:	2a0903fa 	mov	w26, w9
   88100:	2a0303f9 	mov	w25, w3
   88104:	2a0503f7 	mov	w23, w5
   88108:	d2800208 	mov	x8, #0x10                  	// #16
   8810c:	f9006bf8 	str	x24, [sp, #208]
   88110:	aa0403f8 	mov	x24, x4
   88114:	b900dbeb 	str	w11, [sp, #216]
   88118:	14000004 	b	88128 <_vfprintf_r+0x1e38>
   8811c:	510042f7 	sub	w23, w23, #0x10
   88120:	710042ff 	cmp	w23, #0x10
   88124:	54001a4d 	b.le	8846c <_vfprintf_r+0x217c>
   88128:	91004000 	add	x0, x0, #0x10
   8812c:	11000421 	add	w1, w1, #0x1
   88130:	a9002058 	stp	x24, x8, [x2]
   88134:	91004042 	add	x2, x2, #0x10
   88138:	b9018be1 	str	w1, [sp, #392]
   8813c:	f900cbe0 	str	x0, [sp, #400]
   88140:	71001c3f 	cmp	w1, #0x7
   88144:	54fffecd 	b.le	8811c <_vfprintf_r+0x1e2c>
   88148:	910603e2 	add	x2, sp, #0x180
   8814c:	aa1503e1 	mov	x1, x21
   88150:	aa1303e0 	mov	x0, x19
   88154:	940005b3 	bl	89820 <__sprint_r>
   88158:	35007840 	cbnz	w0, 89060 <_vfprintf_r+0x2d70>
   8815c:	f940cbe0 	ldr	x0, [sp, #400]
   88160:	aa1603e2 	mov	x2, x22
   88164:	b9418be1 	ldr	w1, [sp, #392]
   88168:	d2800208 	mov	x8, #0x10                  	// #16
   8816c:	17ffffec 	b	8811c <_vfprintf_r+0x1e2c>
   88170:	36482309 	tbz	w9, #9, 885d0 <_vfprintf_r+0x22e0>
   88174:	37f887c0 	tbnz	w0, #31, 8926c <_vfprintf_r+0x2f7c>
   88178:	f94043e0 	ldr	x0, [sp, #128]
   8817c:	91002c01 	add	x1, x0, #0xb
   88180:	927df021 	and	x1, x1, #0xfffffffffffffff8
   88184:	39400000 	ldrb	w0, [x0]
   88188:	f90043e1 	str	x1, [sp, #128]
   8818c:	17fffe72 	b	87b54 <_vfprintf_r+0x1864>
   88190:	f94057e2 	ldr	x2, [sp, #168]
   88194:	b9407fe0 	ldr	w0, [sp, #124]
   88198:	b9007fe1 	str	w1, [sp, #124]
   8819c:	8b20c040 	add	x0, x2, w0, sxtw
   881a0:	17fffc1f 	b	8721c <_vfprintf_r+0xf2c>
   881a4:	b9407fe0 	ldr	w0, [sp, #124]
   881a8:	11002001 	add	w1, w0, #0x8
   881ac:	7100003f 	cmp	w1, #0x0
   881b0:	540026ad 	b.le	88684 <_vfprintf_r+0x2394>
   881b4:	f94043e0 	ldr	x0, [sp, #128]
   881b8:	b9007fe1 	str	w1, [sp, #124]
   881bc:	91002c02 	add	x2, x0, #0xb
   881c0:	927df041 	and	x1, x2, #0xfffffffffffffff8
   881c4:	f90043e1 	str	x1, [sp, #128]
   881c8:	17fffe4b 	b	87af4 <_vfprintf_r+0x1804>
   881cc:	36482109 	tbz	w9, #9, 885ec <_vfprintf_r+0x22fc>
   881d0:	37f87ce0 	tbnz	w0, #31, 8916c <_vfprintf_r+0x2e7c>
   881d4:	f94043e0 	ldr	x0, [sp, #128]
   881d8:	91002c01 	add	x1, x0, #0xb
   881dc:	927df021 	and	x1, x1, #0xfffffffffffffff8
   881e0:	39400000 	ldrb	w0, [x0]
   881e4:	f90043e1 	str	x1, [sp, #128]
   881e8:	17fffc0e 	b	87220 <_vfprintf_r+0xf30>
   881ec:	364820e9 	tbz	w9, #9, 88608 <_vfprintf_r+0x2318>
   881f0:	37f88c40 	tbnz	w0, #31, 89378 <_vfprintf_r+0x3088>
   881f4:	f94043e0 	ldr	x0, [sp, #128]
   881f8:	91002c01 	add	x1, x0, #0xb
   881fc:	927df021 	and	x1, x1, #0xfffffffffffffff8
   88200:	f90043e1 	str	x1, [sp, #128]
   88204:	39800000 	ldrsb	x0, [x0]
   88208:	aa0003e1 	mov	x1, x0
   8820c:	17fffc6a 	b	873b4 <_vfprintf_r+0x10c4>
   88210:	f94057e2 	ldr	x2, [sp, #168]
   88214:	b9407fe0 	ldr	w0, [sp, #124]
   88218:	b9007fe1 	str	w1, [sp, #124]
   8821c:	8b20c040 	add	x0, x2, w0, sxtw
   88220:	17fffe4c 	b	87b50 <_vfprintf_r+0x1860>
   88224:	f94057e2 	ldr	x2, [sp, #168]
   88228:	b9407fe0 	ldr	w0, [sp, #124]
   8822c:	b9007fe1 	str	w1, [sp, #124]
   88230:	8b20c040 	add	x0, x2, w0, sxtw
   88234:	17fffc5e 	b	873ac <_vfprintf_r+0x10bc>
   88238:	36481bda 	tbz	w26, #9, 885b0 <_vfprintf_r+0x22c0>
   8823c:	37f885c0 	tbnz	w0, #31, 892f4 <_vfprintf_r+0x3004>
   88240:	f94043e0 	ldr	x0, [sp, #128]
   88244:	91002c01 	add	x1, x0, #0xb
   88248:	927df021 	and	x1, x1, #0xfffffffffffffff8
   8824c:	f90043e1 	str	x1, [sp, #128]
   88250:	39400000 	ldrb	w0, [x0]
   88254:	52800021 	mov	w1, #0x1                   	// #1
   88258:	17fffbf4 	b	87228 <_vfprintf_r+0xf38>
   8825c:	f94057e2 	ldr	x2, [sp, #168]
   88260:	b9407fe0 	ldr	w0, [sp, #124]
   88264:	b9007fe1 	str	w1, [sp, #124]
   88268:	8b20c040 	add	x0, x2, w0, sxtw
   8826c:	17fffc16 	b	872c4 <_vfprintf_r+0xfd4>
   88270:	310004ff 	cmn	w7, #0x1
   88274:	54002920 	b.eq	88798 <_vfprintf_r+0x24a8>  // b.none
   88278:	71011f7f 	cmp	w27, #0x47
   8827c:	7a4008e0 	ccmp	w7, #0x0, #0x0, eq	// eq = none
   88280:	1a9f14e7 	csinc	w7, w7, wzr, ne	// ne = any
   88284:	9e660100 	fmov	x0, d8
   88288:	32180137 	orr	w23, w9, #0x100
   8828c:	d360fc00 	lsr	x0, x0, #32
   88290:	37f87d00 	tbnz	w0, #31, 89230 <_vfprintf_r+0x2f40>
   88294:	1e604109 	fmov	d9, d8
   88298:	b900cbff 	str	wzr, [sp, #200]
   8829c:	71011b7f 	cmp	w27, #0x46
   882a0:	54004240 	b.eq	88ae8 <_vfprintf_r+0x27f8>  // b.none
   882a4:	7101177f 	cmp	w27, #0x45
   882a8:	54005c81 	b.ne	88e38 <_vfprintf_r+0x2b48>  // b.any
   882ac:	1e604120 	fmov	d0, d9
   882b0:	110004e0 	add	w0, w7, #0x1
   882b4:	2a0003fa 	mov	w26, w0
   882b8:	2a0003e2 	mov	w2, w0
   882bc:	9105e3e5 	add	x5, sp, #0x178
   882c0:	9105c3e4 	add	x4, sp, #0x170
   882c4:	910563e3 	add	x3, sp, #0x158
   882c8:	aa1303e0 	mov	x0, x19
   882cc:	52800041 	mov	w1, #0x2                   	// #2
   882d0:	b90093e7 	str	w7, [sp, #144]
   882d4:	29136be9 	stp	w9, w26, [sp, #152]
   882d8:	b900a3e8 	str	w8, [sp, #160]
   882dc:	b900d3eb 	str	w11, [sp, #208]
   882e0:	940015b4 	bl	8d9b0 <_dtoa_r>
   882e4:	1e602128 	fcmp	d9, #0.0
   882e8:	b94093e7 	ldr	w7, [sp, #144]
   882ec:	b9409be9 	ldr	w9, [sp, #152]
   882f0:	aa0003f8 	mov	x24, x0
   882f4:	b940a3e8 	ldr	w8, [sp, #160]
   882f8:	8b3ac002 	add	x2, x0, w26, sxtw
   882fc:	b940d3eb 	ldr	w11, [sp, #208]
   88300:	540088c0 	b.eq	89418 <_vfprintf_r+0x3128>  // b.none
   88304:	f940bfe0 	ldr	x0, [sp, #376]
   88308:	eb02001f 	cmp	x0, x2
   8830c:	54000122 	b.cs	88330 <_vfprintf_r+0x2040>  // b.hs, b.nlast
   88310:	52800603 	mov	w3, #0x30                  	// #48
   88314:	d503201f 	nop
   88318:	91000401 	add	x1, x0, #0x1
   8831c:	f900bfe1 	str	x1, [sp, #376]
   88320:	39000003 	strb	w3, [x0]
   88324:	f940bfe0 	ldr	x0, [sp, #376]
   88328:	eb02001f 	cmp	x0, x2
   8832c:	54ffff63 	b.cc	88318 <_vfprintf_r+0x2028>  // b.lo, b.ul, b.last
   88330:	b9415be1 	ldr	w1, [sp, #344]
   88334:	cb180000 	sub	x0, x0, x24
   88338:	b90093e1 	str	w1, [sp, #144]
   8833c:	b9009fe0 	str	w0, [sp, #156]
   88340:	71011f7f 	cmp	w27, #0x47
   88344:	54009521 	b.ne	895e8 <_vfprintf_r+0x32f8>  // b.any
   88348:	b94093e1 	ldr	w1, [sp, #144]
   8834c:	6b07003f 	cmp	w1, w7
   88350:	3a43d821 	ccmn	w1, #0x3, #0x1, le
   88354:	540038aa 	b.ge	88a68 <_vfprintf_r+0x2778>  // b.tcont
   88358:	51000908 	sub	w8, w8, #0x2
   8835c:	51000420 	sub	w0, w1, #0x1
   88360:	12001d01 	and	w1, w8, #0xff
   88364:	52800002 	mov	w2, #0x0                   	// #0
   88368:	d2800017 	mov	x23, #0x0                   	// #0
   8836c:	b9015be0 	str	w0, [sp, #344]
   88370:	390583e1 	strb	w1, [sp, #352]
   88374:	52800561 	mov	w1, #0x2b                  	// #43
   88378:	36f800a0 	tbz	w0, #31, 8838c <_vfprintf_r+0x209c>
   8837c:	b94093e1 	ldr	w1, [sp, #144]
   88380:	52800020 	mov	w0, #0x1                   	// #1
   88384:	4b010000 	sub	w0, w0, w1
   88388:	528005a1 	mov	w1, #0x2d                  	// #45
   8838c:	390587e1 	strb	w1, [sp, #353]
   88390:	7100241f 	cmp	w0, #0x9
   88394:	54005b2d 	b.le	88ef8 <_vfprintf_r+0x2c08>
   88398:	9105ffec 	add	x12, sp, #0x17f
   8839c:	529999ad 	mov	w13, #0xcccd                	// #52429
   883a0:	aa0c03e4 	mov	x4, x12
   883a4:	72b9998d 	movk	w13, #0xcccc, lsl #16
   883a8:	9bad7c02 	umull	x2, w0, w13
   883ac:	aa0403e3 	mov	x3, x4
   883b0:	2a0003e5 	mov	w5, w0
   883b4:	d1000484 	sub	x4, x4, #0x1
   883b8:	d363fc42 	lsr	x2, x2, #35
   883bc:	0b020841 	add	w1, w2, w2, lsl #2
   883c0:	4b010401 	sub	w1, w0, w1, lsl #1
   883c4:	2a0203e0 	mov	w0, w2
   883c8:	1100c021 	add	w1, w1, #0x30
   883cc:	381ff061 	sturb	w1, [x3, #-1]
   883d0:	71018cbf 	cmp	w5, #0x63
   883d4:	54fffeac 	b.gt	883a8 <_vfprintf_r+0x20b8>
   883d8:	1100c040 	add	w0, w2, #0x30
   883dc:	381ff080 	sturb	w0, [x4, #-1]
   883e0:	d1000860 	sub	x0, x3, #0x2
   883e4:	eb0c001f 	cmp	x0, x12
   883e8:	54008da2 	b.cs	8959c <_vfprintf_r+0x32ac>  // b.hs, b.nlast
   883ec:	91058be1 	add	x1, sp, #0x162
   883f0:	38401402 	ldrb	w2, [x0], #1
   883f4:	38001422 	strb	w2, [x1], #1
   883f8:	eb0c001f 	cmp	x0, x12
   883fc:	54ffffa1 	b.ne	883f0 <_vfprintf_r+0x2100>  // b.any
   88400:	910607e0 	add	x0, sp, #0x181
   88404:	91058be2 	add	x2, sp, #0x162
   88408:	cb030000 	sub	x0, x0, x3
   8840c:	910583e1 	add	x1, sp, #0x160
   88410:	8b000040 	add	x0, x2, x0
   88414:	4b010000 	sub	w0, w0, w1
   88418:	b900ebe0 	str	w0, [sp, #232]
   8841c:	b9409fe0 	ldr	w0, [sp, #156]
   88420:	b940ebe1 	ldr	w1, [sp, #232]
   88424:	0b00003b 	add	w27, w1, w0
   88428:	7100041f 	cmp	w0, #0x1
   8842c:	5400606d 	b.le	89038 <_vfprintf_r+0x2d48>
   88430:	b940b3e0 	ldr	w0, [sp, #176]
   88434:	0b00037b 	add	w27, w27, w0
   88438:	1215792a 	and	w10, w9, #0xfffffbff
   8843c:	7100037f 	cmp	w27, #0x0
   88440:	32180149 	orr	w9, w10, #0x100
   88444:	1a9fa363 	csel	w3, w27, wzr, ge	// ge = tcont
   88448:	b90093ff 	str	wzr, [sp, #144]
   8844c:	b9009bff 	str	wzr, [sp, #152]
   88450:	b900a3ff 	str	wzr, [sp, #160]
   88454:	b940cbe0 	ldr	w0, [sp, #200]
   88458:	35001a40 	cbnz	w0, 887a0 <_vfprintf_r+0x24b0>
   8845c:	39453fe1 	ldrb	w1, [sp, #335]
   88460:	52800007 	mov	w7, #0x0                   	// #0
   88464:	34ff0aa1 	cbz	w1, 865b8 <_vfprintf_r+0x2c8>
   88468:	17fffaa0 	b	86ee8 <_vfprintf_r+0xbf8>
   8846c:	2a1703e5 	mov	w5, w23
   88470:	aa1803e4 	mov	x4, x24
   88474:	f9406bf8 	ldr	x24, [sp, #208]
   88478:	2a1903e3 	mov	w3, w25
   8847c:	b940dbeb 	ldr	w11, [sp, #216]
   88480:	aa1b03f7 	mov	x23, x27
   88484:	aa1c03f9 	mov	x25, x28
   88488:	2a1a03e9 	mov	w9, w26
   8848c:	aa0203fc 	mov	x28, x2
   88490:	2a0503fb 	mov	w27, w5
   88494:	93407f67 	sxtw	x7, w27
   88498:	11000421 	add	w1, w1, #0x1
   8849c:	8b070000 	add	x0, x0, x7
   884a0:	a9001f84 	stp	x4, x7, [x28]
   884a4:	9100439c 	add	x28, x28, #0x10
   884a8:	b9018be1 	str	w1, [sp, #392]
   884ac:	f900cbe0 	str	x0, [sp, #400]
   884b0:	71001c3f 	cmp	w1, #0x7
   884b4:	54ff8c0d 	b.le	87634 <_vfprintf_r+0x1344>
   884b8:	910603e2 	add	x2, sp, #0x180
   884bc:	aa1503e1 	mov	x1, x21
   884c0:	aa1303e0 	mov	x0, x19
   884c4:	b900d3e9 	str	w9, [sp, #208]
   884c8:	b900dbeb 	str	w11, [sp, #216]
   884cc:	b900e3e3 	str	w3, [sp, #224]
   884d0:	940004d4 	bl	89820 <__sprint_r>
   884d4:	35ff31a0 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   884d8:	f940cbe0 	ldr	x0, [sp, #400]
   884dc:	aa1603fc 	mov	x28, x22
   884e0:	b940d3e9 	ldr	w9, [sp, #208]
   884e4:	b940dbeb 	ldr	w11, [sp, #216]
   884e8:	b940e3e3 	ldr	w3, [sp, #224]
   884ec:	17fffc52 	b	87634 <_vfprintf_r+0x1344>
   884f0:	36070cc9 	tbz	w9, #0, 86688 <_vfprintf_r+0x398>
   884f4:	a94b13e2 	ldp	x2, x4, [sp, #176]
   884f8:	a9000b84 	stp	x4, x2, [x28]
   884fc:	b9418be1 	ldr	w1, [sp, #392]
   88500:	91004386 	add	x6, x28, #0x10
   88504:	11000421 	add	w1, w1, #0x1
   88508:	b9018be1 	str	w1, [sp, #392]
   8850c:	8b000040 	add	x0, x2, x0
   88510:	f900cbe0 	str	x0, [sp, #400]
   88514:	71001c3f 	cmp	w1, #0x7
   88518:	54ff2c0d 	b.le	86a98 <_vfprintf_r+0x7a8>
   8851c:	910603e2 	add	x2, sp, #0x180
   88520:	aa1503e1 	mov	x1, x21
   88524:	aa1303e0 	mov	x0, x19
   88528:	b90093e9 	str	w9, [sp, #144]
   8852c:	b9009beb 	str	w11, [sp, #152]
   88530:	b900a3e3 	str	w3, [sp, #160]
   88534:	940004bb 	bl	89820 <__sprint_r>
   88538:	35ff2e80 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   8853c:	f940cbe0 	ldr	x0, [sp, #400]
   88540:	aa1603e6 	mov	x6, x22
   88544:	b94093e9 	ldr	w9, [sp, #144]
   88548:	b9409beb 	ldr	w11, [sp, #152]
   8854c:	b940a3e3 	ldr	w3, [sp, #160]
   88550:	b9415be2 	ldr	w2, [sp, #344]
   88554:	b9418be1 	ldr	w1, [sp, #392]
   88558:	17fff94f 	b	86a94 <_vfprintf_r+0x7a4>
   8855c:	b9409fe1 	ldr	w1, [sp, #156]
   88560:	4b1a003a 	sub	w26, w1, w26
   88564:	f94067e1 	ldr	x1, [sp, #200]
   88568:	cb18003b 	sub	x27, x1, x24
   8856c:	6b1b035f 	cmp	w26, w27
   88570:	1a9bb35b 	csel	w27, w26, w27, lt	// lt = tstop
   88574:	17fffc54 	b	876c4 <_vfprintf_r+0x13d4>
   88578:	37f86e60 	tbnz	w0, #31, 89344 <_vfprintf_r+0x3054>
   8857c:	f94043e0 	ldr	x0, [sp, #128]
   88580:	91003c01 	add	x1, x0, #0xf
   88584:	927df021 	and	x1, x1, #0xfffffffffffffff8
   88588:	f90043e1 	str	x1, [sp, #128]
   8858c:	f9400000 	ldr	x0, [x0]
   88590:	7940e3e1 	ldrh	w1, [sp, #112]
   88594:	79000001 	strh	w1, [x0]
   88598:	17fff79d 	b	8640c <_vfprintf_r+0x11c>
   8859c:	f94057e2 	ldr	x2, [sp, #168]
   885a0:	b9407fe0 	ldr	w0, [sp, #124]
   885a4:	b9007fe1 	str	w1, [sp, #124]
   885a8:	8b20c040 	add	x0, x2, w0, sxtw
   885ac:	17fffb71 	b	87370 <_vfprintf_r+0x1080>
   885b0:	37f85960 	tbnz	w0, #31, 890dc <_vfprintf_r+0x2dec>
   885b4:	f94043e0 	ldr	x0, [sp, #128]
   885b8:	91002c01 	add	x1, x0, #0xb
   885bc:	927df021 	and	x1, x1, #0xfffffffffffffff8
   885c0:	f90043e1 	str	x1, [sp, #128]
   885c4:	b9400000 	ldr	w0, [x0]
   885c8:	52800021 	mov	w1, #0x1                   	// #1
   885cc:	17fffb17 	b	87228 <_vfprintf_r+0xf38>
   885d0:	37f86380 	tbnz	w0, #31, 89240 <_vfprintf_r+0x2f50>
   885d4:	f94043e0 	ldr	x0, [sp, #128]
   885d8:	91002c01 	add	x1, x0, #0xb
   885dc:	927df021 	and	x1, x1, #0xfffffffffffffff8
   885e0:	b9400000 	ldr	w0, [x0]
   885e4:	f90043e1 	str	x1, [sp, #128]
   885e8:	17fffd5b 	b	87b54 <_vfprintf_r+0x1864>
   885ec:	37f859e0 	tbnz	w0, #31, 89128 <_vfprintf_r+0x2e38>
   885f0:	f94043e0 	ldr	x0, [sp, #128]
   885f4:	91002c01 	add	x1, x0, #0xb
   885f8:	927df021 	and	x1, x1, #0xfffffffffffffff8
   885fc:	b9400000 	ldr	w0, [x0]
   88600:	f90043e1 	str	x1, [sp, #128]
   88604:	17fffb07 	b	87220 <_vfprintf_r+0xf30>
   88608:	37f868a0 	tbnz	w0, #31, 8931c <_vfprintf_r+0x302c>
   8860c:	f94043e0 	ldr	x0, [sp, #128]
   88610:	91002c01 	add	x1, x0, #0xb
   88614:	927df021 	and	x1, x1, #0xfffffffffffffff8
   88618:	f90043e1 	str	x1, [sp, #128]
   8861c:	b9800000 	ldrsw	x0, [x0]
   88620:	aa0003e1 	mov	x1, x0
   88624:	17fffb64 	b	873b4 <_vfprintf_r+0x10c4>
   88628:	aa1303e0 	mov	x0, x19
   8862c:	910603e2 	add	x2, sp, #0x180
   88630:	aa1503e1 	mov	x1, x21
   88634:	9400047b 	bl	89820 <__sprint_r>
   88638:	34ffd4a0 	cbz	w0, 880cc <_vfprintf_r+0x1ddc>
   8863c:	17fff937 	b	86b18 <_vfprintf_r+0x828>
   88640:	aa1803e0 	mov	x0, x24
   88644:	b900cbe9 	str	w9, [sp, #200]
   88648:	b900d3eb 	str	w11, [sp, #208]
   8864c:	97ffe8cd 	bl	82980 <strlen>
   88650:	39453fe1 	ldrb	w1, [sp, #335]
   88654:	7100001f 	cmp	w0, #0x0
   88658:	b9009bff 	str	wzr, [sp, #152]
   8865c:	2a0003fb 	mov	w27, w0
   88660:	b900a3ff 	str	wzr, [sp, #160]
   88664:	1a9fa003 	csel	w3, w0, wzr, ge	// ge = tcont
   88668:	b940cbe9 	ldr	w9, [sp, #200]
   8866c:	d2800017 	mov	x23, #0x0                   	// #0
   88670:	b940d3eb 	ldr	w11, [sp, #208]
   88674:	52800007 	mov	w7, #0x0                   	// #0
   88678:	52800e68 	mov	w8, #0x73                  	// #115
   8867c:	34fef9e1 	cbz	w1, 865b8 <_vfprintf_r+0x2c8>
   88680:	17fffa1a 	b	86ee8 <_vfprintf_r+0xbf8>
   88684:	f94057e2 	ldr	x2, [sp, #168]
   88688:	b9407fe0 	ldr	w0, [sp, #124]
   8868c:	b9007fe1 	str	w1, [sp, #124]
   88690:	8b20c040 	add	x0, x2, w0, sxtw
   88694:	17fffd18 	b	87af4 <_vfprintf_r+0x1804>
   88698:	b9407fe0 	ldr	w0, [sp, #124]
   8869c:	11002001 	add	w1, w0, #0x8
   886a0:	7100003f 	cmp	w1, #0x0
   886a4:	54005fad 	b.le	89298 <_vfprintf_r+0x2fa8>
   886a8:	f94043e0 	ldr	x0, [sp, #128]
   886ac:	b9007fe1 	str	w1, [sp, #124]
   886b0:	91002c02 	add	x2, x0, #0xb
   886b4:	927df041 	and	x1, x2, #0xfffffffffffffff8
   886b8:	79400000 	ldrh	w0, [x0]
   886bc:	f90043e1 	str	x1, [sp, #128]
   886c0:	17fffad8 	b	87220 <_vfprintf_r+0xf30>
   886c4:	b9407fe0 	ldr	w0, [sp, #124]
   886c8:	11002001 	add	w1, w0, #0x8
   886cc:	7100003f 	cmp	w1, #0x0
   886d0:	54004fcd 	b.le	890c8 <_vfprintf_r+0x2dd8>
   886d4:	f94043e0 	ldr	x0, [sp, #128]
   886d8:	b9007fe1 	str	w1, [sp, #124]
   886dc:	91002c02 	add	x2, x0, #0xb
   886e0:	927df041 	and	x1, x2, #0xfffffffffffffff8
   886e4:	f90043e1 	str	x1, [sp, #128]
   886e8:	17fffc60 	b	87868 <_vfprintf_r+0x1578>
   886ec:	b9407fe0 	ldr	w0, [sp, #124]
   886f0:	11002001 	add	w1, w0, #0x8
   886f4:	7100003f 	cmp	w1, #0x0
   886f8:	540052ed 	b.le	89154 <_vfprintf_r+0x2e64>
   886fc:	f94043e0 	ldr	x0, [sp, #128]
   88700:	b9007fe1 	str	w1, [sp, #124]
   88704:	91002c02 	add	x2, x0, #0xb
   88708:	927df041 	and	x1, x2, #0xfffffffffffffff8
   8870c:	79400000 	ldrh	w0, [x0]
   88710:	f90043e1 	str	x1, [sp, #128]
   88714:	17fffd10 	b	87b54 <_vfprintf_r+0x1864>
   88718:	b9407fe0 	ldr	w0, [sp, #124]
   8871c:	11002001 	add	w1, w0, #0x8
   88720:	7100003f 	cmp	w1, #0x0
   88724:	54005c6d 	b.le	892b0 <_vfprintf_r+0x2fc0>
   88728:	f94043e0 	ldr	x0, [sp, #128]
   8872c:	b9007fe1 	str	w1, [sp, #124]
   88730:	91002c02 	add	x2, x0, #0xb
   88734:	927df041 	and	x1, x2, #0xfffffffffffffff8
   88738:	f90043e1 	str	x1, [sp, #128]
   8873c:	17fffc42 	b	87844 <_vfprintf_r+0x1554>
   88740:	52800020 	mov	w0, #0x1                   	// #1
   88744:	b9015be0 	str	w0, [sp, #344]
   88748:	17fffd74 	b	87d18 <_vfprintf_r+0x1a28>
   8874c:	f94052a0 	ldr	x0, [x21, #160]
   88750:	f9003be9 	str	x9, [sp, #112]
   88754:	94000e07 	bl	8bf70 <__retarget_lock_release_recursive>
   88758:	f9403be9 	ldr	x9, [sp, #112]
   8875c:	17fff74e 	b	86494 <_vfprintf_r+0x1a4>
   88760:	110004e1 	add	w1, w7, #0x1
   88764:	aa1303e0 	mov	x0, x19
   88768:	b90093e7 	str	w7, [sp, #144]
   8876c:	93407c21 	sxtw	x1, w1
   88770:	291323e9 	stp	w9, w8, [sp, #152]
   88774:	b900a3eb 	str	w11, [sp, #160]
   88778:	94000b82 	bl	8b580 <_malloc_r>
   8877c:	b94093e7 	ldr	w7, [sp, #144]
   88780:	aa0003f8 	mov	x24, x0
   88784:	295323e9 	ldp	w9, w8, [sp, #152]
   88788:	b940a3eb 	ldr	w11, [sp, #160]
   8878c:	b40067a0 	cbz	x0, 89480 <_vfprintf_r+0x3190>
   88790:	aa0003f7 	mov	x23, x0
   88794:	17fffd4d 	b	87cc8 <_vfprintf_r+0x19d8>
   88798:	528000c7 	mov	w7, #0x6                   	// #6
   8879c:	17fffeba 	b	88284 <_vfprintf_r+0x1f94>
   887a0:	528005a0 	mov	w0, #0x2d                  	// #45
   887a4:	11000463 	add	w3, w3, #0x1
   887a8:	528005a1 	mov	w1, #0x2d                  	// #45
   887ac:	52800007 	mov	w7, #0x0                   	// #0
   887b0:	39053fe0 	strb	w0, [sp, #335]
   887b4:	17fff781 	b	865b8 <_vfprintf_r+0x2c8>
   887b8:	b940a3e2 	ldr	w2, [sp, #160]
   887bc:	b9409be1 	ldr	w1, [sp, #152]
   887c0:	7100005f 	cmp	w2, #0x0
   887c4:	7a40d820 	ccmp	w1, #0x0, #0x0, le
   887c8:	540007ad 	b.le	888bc <_vfprintf_r+0x25cc>
   887cc:	aa1c03e1 	mov	x1, x28
   887d0:	f9008bf9 	str	x25, [sp, #272]
   887d4:	f9407ff9 	ldr	x25, [sp, #248]
   887d8:	b0000064 	adrp	x4, 95000 <pmu_event_descr+0x60>
   887dc:	f94083fc 	ldr	x28, [sp, #256]
   887e0:	911f0084 	add	x4, x4, #0x7c0
   887e4:	f9004bf7 	str	x23, [sp, #144]
   887e8:	2a0203f7 	mov	w23, w2
   887ec:	d280021b 	mov	x27, #0x10                  	// #16
   887f0:	b900d3e9 	str	w9, [sp, #208]
   887f4:	b900dbeb 	str	w11, [sp, #216]
   887f8:	b900e3e3 	str	w3, [sp, #224]
   887fc:	d503201f 	nop
   88800:	34000677 	cbz	w23, 888cc <_vfprintf_r+0x25dc>
   88804:	510006f7 	sub	w23, w23, #0x1
   88808:	b9418be2 	ldr	w2, [sp, #392]
   8880c:	8b1c0000 	add	x0, x0, x28
   88810:	f9407be3 	ldr	x3, [sp, #240]
   88814:	11000442 	add	w2, w2, #0x1
   88818:	a9007023 	stp	x3, x28, [x1]
   8881c:	91004021 	add	x1, x1, #0x10
   88820:	b9018be2 	str	w2, [sp, #392]
   88824:	f900cbe0 	str	x0, [sp, #400]
   88828:	71001c5f 	cmp	w2, #0x7
   8882c:	5400098c 	b.gt	8895c <_vfprintf_r+0x266c>
   88830:	f94067e3 	ldr	x3, [sp, #200]
   88834:	39400322 	ldrb	w2, [x25]
   88838:	cb180063 	sub	x3, x3, x24
   8883c:	6b03005f 	cmp	w2, w3
   88840:	1a83b05a 	csel	w26, w2, w3, lt	// lt = tstop
   88844:	7100035f 	cmp	w26, #0x0
   88848:	5400018d 	b.le	88878 <_vfprintf_r+0x2588>
   8884c:	b9418be2 	ldr	w2, [sp, #392]
   88850:	93407f49 	sxtw	x9, w26
   88854:	8b090000 	add	x0, x0, x9
   88858:	a9002438 	stp	x24, x9, [x1]
   8885c:	11000442 	add	w2, w2, #0x1
   88860:	b9018be2 	str	w2, [sp, #392]
   88864:	f900cbe0 	str	x0, [sp, #400]
   88868:	71001c5f 	cmp	w2, #0x7
   8886c:	54000a8c 	b.gt	889bc <_vfprintf_r+0x26cc>
   88870:	39400322 	ldrb	w2, [x25]
   88874:	91004021 	add	x1, x1, #0x10
   88878:	7100035f 	cmp	w26, #0x0
   8887c:	1a9fa343 	csel	w3, w26, wzr, ge	// ge = tcont
   88880:	4b03005a 	sub	w26, w2, w3
   88884:	7100035f 	cmp	w26, #0x0
   88888:	540002cc 	b.gt	888e0 <_vfprintf_r+0x25f0>
   8888c:	b9409be3 	ldr	w3, [sp, #152]
   88890:	8b220318 	add	x24, x24, w2, uxtb
   88894:	7100007f 	cmp	w3, #0x0
   88898:	7a40dae0 	ccmp	w23, #0x0, #0x0, le
   8889c:	54fffb2c 	b.gt	88800 <_vfprintf_r+0x2510>
   888a0:	f9404bf7 	ldr	x23, [sp, #144]
   888a4:	f9007ff9 	str	x25, [sp, #248]
   888a8:	f9408bf9 	ldr	x25, [sp, #272]
   888ac:	aa0103fc 	mov	x28, x1
   888b0:	b940d3e9 	ldr	w9, [sp, #208]
   888b4:	b940dbeb 	ldr	w11, [sp, #216]
   888b8:	b940e3e3 	ldr	w3, [sp, #224]
   888bc:	f94067e1 	ldr	x1, [sp, #200]
   888c0:	eb01031f 	cmp	x24, x1
   888c4:	9a819318 	csel	x24, x24, x1, ls	// ls = plast
   888c8:	17fffb5e 	b	87640 <_vfprintf_r+0x1350>
   888cc:	b9409be2 	ldr	w2, [sp, #152]
   888d0:	d1000739 	sub	x25, x25, #0x1
   888d4:	51000442 	sub	w2, w2, #0x1
   888d8:	b9009be2 	str	w2, [sp, #152]
   888dc:	17ffffcb 	b	88808 <_vfprintf_r+0x2518>
   888e0:	b0000069 	adrp	x9, 95000 <pmu_event_descr+0x60>
   888e4:	b9418be2 	ldr	w2, [sp, #392]
   888e8:	911f0129 	add	x9, x9, #0x7c0
   888ec:	7100435f 	cmp	w26, #0x10
   888f0:	5400050d 	b.le	88990 <_vfprintf_r+0x26a0>
   888f4:	b900a3f7 	str	w23, [sp, #160]
   888f8:	2a1a03f7 	mov	w23, w26
   888fc:	aa0403fa 	mov	x26, x4
   88900:	14000004 	b	88910 <_vfprintf_r+0x2620>
   88904:	510042f7 	sub	w23, w23, #0x10
   88908:	710042ff 	cmp	w23, #0x10
   8890c:	540003cd 	b.le	88984 <_vfprintf_r+0x2694>
   88910:	91004000 	add	x0, x0, #0x10
   88914:	11000442 	add	w2, w2, #0x1
   88918:	a9006c24 	stp	x4, x27, [x1]
   8891c:	91004021 	add	x1, x1, #0x10
   88920:	b9018be2 	str	w2, [sp, #392]
   88924:	f900cbe0 	str	x0, [sp, #400]
   88928:	71001c5f 	cmp	w2, #0x7
   8892c:	54fffecd 	b.le	88904 <_vfprintf_r+0x2614>
   88930:	910603e2 	add	x2, sp, #0x180
   88934:	aa1503e1 	mov	x1, x21
   88938:	aa1303e0 	mov	x0, x19
   8893c:	940003b9 	bl	89820 <__sprint_r>
   88940:	35ff0e20 	cbnz	w0, 86b04 <_vfprintf_r+0x814>
   88944:	f940cbe0 	ldr	x0, [sp, #400]
   88948:	b0000063 	adrp	x3, 95000 <pmu_event_descr+0x60>
   8894c:	b9418be2 	ldr	w2, [sp, #392]
   88950:	aa1603e1 	mov	x1, x22
   88954:	911f0064 	add	x4, x3, #0x7c0
   88958:	17ffffeb 	b	88904 <_vfprintf_r+0x2614>
   8895c:	910603e2 	add	x2, sp, #0x180
   88960:	aa1503e1 	mov	x1, x21
   88964:	aa1303e0 	mov	x0, x19
   88968:	940003ae 	bl	89820 <__sprint_r>
   8896c:	35ff0cc0 	cbnz	w0, 86b04 <_vfprintf_r+0x814>
   88970:	f940cbe0 	ldr	x0, [sp, #400]
   88974:	b0000062 	adrp	x2, 95000 <pmu_event_descr+0x60>
   88978:	aa1603e1 	mov	x1, x22
   8897c:	911f0044 	add	x4, x2, #0x7c0
   88980:	17ffffac 	b	88830 <_vfprintf_r+0x2540>
   88984:	aa1a03e9 	mov	x9, x26
   88988:	2a1703fa 	mov	w26, w23
   8898c:	b940a3f7 	ldr	w23, [sp, #160]
   88990:	93407f43 	sxtw	x3, w26
   88994:	11000442 	add	w2, w2, #0x1
   88998:	8b030000 	add	x0, x0, x3
   8899c:	a9000c29 	stp	x9, x3, [x1]
   889a0:	b9018be2 	str	w2, [sp, #392]
   889a4:	f900cbe0 	str	x0, [sp, #400]
   889a8:	71001c5f 	cmp	w2, #0x7
   889ac:	5400152c 	b.gt	88c50 <_vfprintf_r+0x2960>
   889b0:	39400322 	ldrb	w2, [x25]
   889b4:	91004021 	add	x1, x1, #0x10
   889b8:	17ffffb5 	b	8888c <_vfprintf_r+0x259c>
   889bc:	910603e2 	add	x2, sp, #0x180
   889c0:	aa1503e1 	mov	x1, x21
   889c4:	aa1303e0 	mov	x0, x19
   889c8:	94000396 	bl	89820 <__sprint_r>
   889cc:	35ff09c0 	cbnz	w0, 86b04 <_vfprintf_r+0x814>
   889d0:	f940cbe0 	ldr	x0, [sp, #400]
   889d4:	b0000063 	adrp	x3, 95000 <pmu_event_descr+0x60>
   889d8:	39400322 	ldrb	w2, [x25]
   889dc:	aa1603e1 	mov	x1, x22
   889e0:	911f0064 	add	x4, x3, #0x7c0
   889e4:	17ffffa5 	b	88878 <_vfprintf_r+0x2588>
   889e8:	b940efe0 	ldr	w0, [sp, #236]
   889ec:	11004001 	add	w1, w0, #0x10
   889f0:	7100003f 	cmp	w1, #0x0
   889f4:	54002e6d 	b.le	88fc0 <_vfprintf_r+0x2cd0>
   889f8:	f94043e0 	ldr	x0, [sp, #128]
   889fc:	b900efe1 	str	w1, [sp, #236]
   88a00:	91003c02 	add	x2, x0, #0xf
   88a04:	fd400008 	ldr	d8, [x0]
   88a08:	927df041 	and	x1, x2, #0xfffffffffffffff8
   88a0c:	f90043e1 	str	x1, [sp, #128]
   88a10:	17fff91f 	b	86e8c <_vfprintf_r+0xb9c>
   88a14:	528005a0 	mov	w0, #0x2d                  	// #45
   88a18:	528005a1 	mov	w1, #0x2d                  	// #45
   88a1c:	39053fe0 	strb	w0, [sp, #335]
   88a20:	17fff923 	b	86eac <_vfprintf_r+0xbbc>
   88a24:	9105c3e4 	add	x4, sp, #0x170
   88a28:	9105e3e2 	add	x2, sp, #0x178
   88a2c:	aa1303e0 	mov	x0, x19
   88a30:	d2800003 	mov	x3, #0x0                   	// #0
   88a34:	d2800001 	mov	x1, #0x0                   	// #0
   88a38:	b90093e9 	str	w9, [sp, #144]
   88a3c:	b9009be8 	str	w8, [sp, #152]
   88a40:	b900a3eb 	str	w11, [sp, #160]
   88a44:	9400135f 	bl	8d7c0 <_wcsrtombs_r>
   88a48:	b94093e9 	ldr	w9, [sp, #144]
   88a4c:	2a0003fb 	mov	w27, w0
   88a50:	b9409be8 	ldr	w8, [sp, #152]
   88a54:	3100041f 	cmn	w0, #0x1
   88a58:	b940a3eb 	ldr	w11, [sp, #160]
   88a5c:	54005120 	b.eq	89480 <_vfprintf_r+0x3190>  // b.none
   88a60:	f900bff8 	str	x24, [sp, #376]
   88a64:	17fffd1c 	b	87ed4 <_vfprintf_r+0x1be4>
   88a68:	b94093e1 	ldr	w1, [sp, #144]
   88a6c:	b9409fe2 	ldr	w2, [sp, #156]
   88a70:	6b02003f 	cmp	w1, w2
   88a74:	540020ab 	b.lt	88e88 <_vfprintf_r+0x2b98>  // b.tstop
   88a78:	b94093e0 	ldr	w0, [sp, #144]
   88a7c:	f240013f 	tst	x9, #0x1
   88a80:	b940b3e1 	ldr	w1, [sp, #176]
   88a84:	0b01000c 	add	w12, w0, w1
   88a88:	1a80119b 	csel	w27, w12, w0, ne	// ne = any
   88a8c:	36500089 	tbz	w9, #10, 88a9c <_vfprintf_r+0x27ac>
   88a90:	b94093e0 	ldr	w0, [sp, #144]
   88a94:	7100001f 	cmp	w0, #0x0
   88a98:	5400380c 	b.gt	89198 <_vfprintf_r+0x2ea8>
   88a9c:	7100037f 	cmp	w27, #0x0
   88aa0:	52800ce8 	mov	w8, #0x67                  	// #103
   88aa4:	1a9fa363 	csel	w3, w27, wzr, ge	// ge = tcont
   88aa8:	2a1703e9 	mov	w9, w23
   88aac:	d2800017 	mov	x23, #0x0                   	// #0
   88ab0:	b9009bff 	str	wzr, [sp, #152]
   88ab4:	b900a3ff 	str	wzr, [sp, #160]
   88ab8:	17fffe67 	b	88454 <_vfprintf_r+0x2164>
   88abc:	b940efe0 	ldr	w0, [sp, #236]
   88ac0:	11004001 	add	w1, w0, #0x10
   88ac4:	7100003f 	cmp	w1, #0x0
   88ac8:	5400272d 	b.le	88fac <_vfprintf_r+0x2cbc>
   88acc:	f94043e0 	ldr	x0, [sp, #128]
   88ad0:	b900efe1 	str	w1, [sp, #236]
   88ad4:	91003c00 	add	x0, x0, #0xf
   88ad8:	927cec00 	and	x0, x0, #0xfffffffffffffff0
   88adc:	91004001 	add	x1, x0, #0x10
   88ae0:	f90043e1 	str	x1, [sp, #128]
   88ae4:	17fff8df 	b	86e60 <_vfprintf_r+0xb70>
   88ae8:	1e604120 	fmov	d0, d9
   88aec:	2a0703e2 	mov	w2, w7
   88af0:	9105e3e5 	add	x5, sp, #0x178
   88af4:	9105c3e4 	add	x4, sp, #0x170
   88af8:	910563e3 	add	x3, sp, #0x158
   88afc:	aa1303e0 	mov	x0, x19
   88b00:	52800061 	mov	w1, #0x3                   	// #3
   88b04:	b90093e7 	str	w7, [sp, #144]
   88b08:	291323e9 	stp	w9, w8, [sp, #152]
   88b0c:	b900a3eb 	str	w11, [sp, #160]
   88b10:	940013a8 	bl	8d9b0 <_dtoa_r>
   88b14:	aa0003f8 	mov	x24, x0
   88b18:	39400000 	ldrb	w0, [x0]
   88b1c:	2f00e400 	movi	d0, #0x0
   88b20:	b94093e7 	ldr	w7, [sp, #144]
   88b24:	7100c01f 	cmp	w0, #0x30
   88b28:	b940a3eb 	ldr	w11, [sp, #160]
   88b2c:	295323e9 	ldp	w9, w8, [sp, #152]
   88b30:	1e600524 	fccmp	d9, d0, #0x4, eq	// eq = none
   88b34:	54004e61 	b.ne	89500 <_vfprintf_r+0x3210>  // b.any
   88b38:	b9415be0 	ldr	w0, [sp, #344]
   88b3c:	1e602128 	fcmp	d9, #0.0
   88b40:	93407ce1 	sxtw	x1, w7
   88b44:	8b20c020 	add	x0, x1, w0, sxtw
   88b48:	540042c1 	b.ne	893a0 <_vfprintf_r+0x30b0>  // b.any
   88b4c:	b9415be1 	ldr	w1, [sp, #344]
   88b50:	b9009fe0 	str	w0, [sp, #156]
   88b54:	12000120 	and	w0, w9, #0x1
   88b58:	b90093e1 	str	w1, [sp, #144]
   88b5c:	2a070000 	orr	w0, w0, w7
   88b60:	7100003f 	cmp	w1, #0x0
   88b64:	54004b8d 	b.le	894d4 <_vfprintf_r+0x31e4>
   88b68:	35003ae0 	cbnz	w0, 892c4 <_vfprintf_r+0x2fd4>
   88b6c:	b94093fb 	ldr	w27, [sp, #144]
   88b70:	52800cc8 	mov	w8, #0x66                  	// #102
   88b74:	37503149 	tbnz	w9, #10, 8919c <_vfprintf_r+0x2eac>
   88b78:	7100037f 	cmp	w27, #0x0
   88b7c:	1a9fa363 	csel	w3, w27, wzr, ge	// ge = tcont
   88b80:	17ffffca 	b	88aa8 <_vfprintf_r+0x27b8>
   88b84:	910603e2 	add	x2, sp, #0x180
   88b88:	aa1503e1 	mov	x1, x21
   88b8c:	aa1303e0 	mov	x0, x19
   88b90:	b90093e9 	str	w9, [sp, #144]
   88b94:	b9009beb 	str	w11, [sp, #152]
   88b98:	b900a3e3 	str	w3, [sp, #160]
   88b9c:	94000321 	bl	89820 <__sprint_r>
   88ba0:	35fefb40 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   88ba4:	f940cbe0 	ldr	x0, [sp, #400]
   88ba8:	aa1603fc 	mov	x28, x22
   88bac:	b94093e9 	ldr	w9, [sp, #144]
   88bb0:	b9409beb 	ldr	w11, [sp, #152]
   88bb4:	b940a3e3 	ldr	w3, [sp, #160]
   88bb8:	b9415be2 	ldr	w2, [sp, #344]
   88bbc:	17fff7a9 	b	86a60 <_vfprintf_r+0x770>
   88bc0:	39453fe1 	ldrb	w1, [sp, #335]
   88bc4:	52800003 	mov	w3, #0x0                   	// #0
   88bc8:	b90093ff 	str	wzr, [sp, #144]
   88bcc:	52800007 	mov	w7, #0x0                   	// #0
   88bd0:	b9009bff 	str	wzr, [sp, #152]
   88bd4:	d2800017 	mov	x23, #0x0                   	// #0
   88bd8:	b900a3ff 	str	wzr, [sp, #160]
   88bdc:	34fecee1 	cbz	w1, 865b8 <_vfprintf_r+0x2c8>
   88be0:	17fff8c2 	b	86ee8 <_vfprintf_r+0xbf8>
   88be4:	b9407fe0 	ldr	w0, [sp, #124]
   88be8:	11002001 	add	w1, w0, #0x8
   88bec:	7100003f 	cmp	w1, #0x0
   88bf0:	540022ed 	b.le	8904c <_vfprintf_r+0x2d5c>
   88bf4:	f94043e0 	ldr	x0, [sp, #128]
   88bf8:	b9007fe1 	str	w1, [sp, #124]
   88bfc:	91002c02 	add	x2, x0, #0xb
   88c00:	927df041 	and	x1, x2, #0xfffffffffffffff8
   88c04:	f90043e1 	str	x1, [sp, #128]
   88c08:	17fff8fe 	b	87000 <_vfprintf_r+0xd10>
   88c0c:	f94057e2 	ldr	x2, [sp, #168]
   88c10:	b9407fe0 	ldr	w0, [sp, #124]
   88c14:	b9007fe1 	str	w1, [sp, #124]
   88c18:	8b20c042 	add	x2, x2, w0, sxtw
   88c1c:	f94043e0 	ldr	x0, [sp, #128]
   88c20:	f90043e2 	str	x2, [sp, #128]
   88c24:	17fff94f 	b	87160 <_vfprintf_r+0xe70>
   88c28:	f94057e2 	ldr	x2, [sp, #168]
   88c2c:	b9407fe0 	ldr	w0, [sp, #124]
   88c30:	b9007fe1 	str	w1, [sp, #124]
   88c34:	8b20c040 	add	x0, x2, w0, sxtw
   88c38:	17fff9bc 	b	87328 <_vfprintf_r+0x1038>
   88c3c:	f94057e2 	ldr	x2, [sp, #168]
   88c40:	b9407fe0 	ldr	w0, [sp, #124]
   88c44:	b9007fe1 	str	w1, [sp, #124]
   88c48:	8b20c040 	add	x0, x2, w0, sxtw
   88c4c:	17fff904 	b	8705c <_vfprintf_r+0xd6c>
   88c50:	910603e2 	add	x2, sp, #0x180
   88c54:	aa1503e1 	mov	x1, x21
   88c58:	aa1303e0 	mov	x0, x19
   88c5c:	940002f1 	bl	89820 <__sprint_r>
   88c60:	35fef520 	cbnz	w0, 86b04 <_vfprintf_r+0x814>
   88c64:	f940cbe0 	ldr	x0, [sp, #400]
   88c68:	b0000063 	adrp	x3, 95000 <pmu_event_descr+0x60>
   88c6c:	39400322 	ldrb	w2, [x25]
   88c70:	aa1603e1 	mov	x1, x22
   88c74:	911f0064 	add	x4, x3, #0x7c0
   88c78:	17ffff05 	b	8888c <_vfprintf_r+0x259c>
   88c7c:	910603e2 	add	x2, sp, #0x180
   88c80:	aa1503e1 	mov	x1, x21
   88c84:	aa1303e0 	mov	x0, x19
   88c88:	b900d3e9 	str	w9, [sp, #208]
   88c8c:	b900dbeb 	str	w11, [sp, #216]
   88c90:	b900e3e3 	str	w3, [sp, #224]
   88c94:	940002e3 	bl	89820 <__sprint_r>
   88c98:	35fef380 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   88c9c:	f940cbe0 	ldr	x0, [sp, #400]
   88ca0:	aa1603fc 	mov	x28, x22
   88ca4:	b940d3e9 	ldr	w9, [sp, #208]
   88ca8:	b940dbeb 	ldr	w11, [sp, #216]
   88cac:	b940e3e3 	ldr	w3, [sp, #224]
   88cb0:	17fffa5b 	b	8761c <_vfprintf_r+0x132c>
   88cb4:	2a1703e5 	mov	w5, w23
   88cb8:	2a1903e3 	mov	w3, w25
   88cbc:	aa1a03f7 	mov	x23, x26
   88cc0:	aa1c03f9 	mov	x25, x28
   88cc4:	b94093e9 	ldr	w9, [sp, #144]
   88cc8:	aa0203fc 	mov	x28, x2
   88ccc:	b9409beb 	ldr	w11, [sp, #152]
   88cd0:	aa1803e4 	mov	x4, x24
   88cd4:	2a0503fa 	mov	w26, w5
   88cd8:	17fffcb3 	b	87fa4 <_vfprintf_r+0x1cb4>
   88cdc:	910603e2 	add	x2, sp, #0x180
   88ce0:	aa1503e1 	mov	x1, x21
   88ce4:	aa1303e0 	mov	x0, x19
   88ce8:	b90093e9 	str	w9, [sp, #144]
   88cec:	b9009beb 	str	w11, [sp, #152]
   88cf0:	b900a3e3 	str	w3, [sp, #160]
   88cf4:	940002cb 	bl	89820 <__sprint_r>
   88cf8:	35fef080 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   88cfc:	f940cbe0 	ldr	x0, [sp, #400]
   88d00:	aa1603fc 	mov	x28, x22
   88d04:	b94093e9 	ldr	w9, [sp, #144]
   88d08:	b9409beb 	ldr	w11, [sp, #152]
   88d0c:	b940a3e3 	ldr	w3, [sp, #160]
   88d10:	b9415bfa 	ldr	w26, [sp, #344]
   88d14:	17fffa5a 	b	8767c <_vfprintf_r+0x138c>
   88d18:	f9407be1 	ldr	x1, [sp, #240]
   88d1c:	b90093e8 	str	w8, [sp, #144]
   88d20:	f94083e0 	ldr	x0, [sp, #256]
   88d24:	29131feb 	stp	w11, w7, [sp, #152]
   88d28:	f90053e3 	str	x3, [sp, #160]
   88d2c:	cb000318 	sub	x24, x24, x0
   88d30:	aa0003e2 	mov	x2, x0
   88d34:	aa1803e0 	mov	x0, x24
   88d38:	a90cb3e4 	stp	x4, x12, [sp, #200]
   88d3c:	94001c55 	bl	8fe90 <strncpy>
   88d40:	394006a0 	ldrb	w0, [x21, #1]
   88d44:	52800005 	mov	w5, #0x0                   	// #0
   88d48:	f94053e3 	ldr	x3, [sp, #160]
   88d4c:	7100001f 	cmp	w0, #0x0
   88d50:	a94cb3e4 	ldp	x4, x12, [sp, #200]
   88d54:	9a9506b5 	cinc	x21, x21, ne	// ne = any
   88d58:	b94093e8 	ldr	w8, [sp, #144]
   88d5c:	29531feb 	ldp	w11, w7, [sp, #152]
   88d60:	17fffcab 	b	8800c <_vfprintf_r+0x1d1c>
   88d64:	910603e2 	add	x2, sp, #0x180
   88d68:	aa1503e1 	mov	x1, x21
   88d6c:	aa1303e0 	mov	x0, x19
   88d70:	b90093e9 	str	w9, [sp, #144]
   88d74:	b9009beb 	str	w11, [sp, #152]
   88d78:	b900a3e3 	str	w3, [sp, #160]
   88d7c:	940002a9 	bl	89820 <__sprint_r>
   88d80:	35feec40 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   88d84:	295307eb 	ldp	w11, w1, [sp, #152]
   88d88:	aa1603fc 	mov	x28, x22
   88d8c:	b9415bfa 	ldr	w26, [sp, #344]
   88d90:	f940cbe0 	ldr	x0, [sp, #400]
   88d94:	4b1a003a 	sub	w26, w1, w26
   88d98:	b94093e9 	ldr	w9, [sp, #144]
   88d9c:	b940a3e3 	ldr	w3, [sp, #160]
   88da0:	17fffa49 	b	876c4 <_vfprintf_r+0x13d4>
   88da4:	b0000064 	adrp	x4, 95000 <pmu_event_descr+0x60>
   88da8:	4b0203fa 	neg	w26, w2
   88dac:	911f0084 	add	x4, x4, #0x7c0
   88db0:	3100405f 	cmn	w2, #0x10
   88db4:	54000cca 	b.ge	88f4c <_vfprintf_r+0x2c5c>  // b.tcont
   88db8:	aa1903e2 	mov	x2, x25
   88dbc:	2a0903fc 	mov	w28, w9
   88dc0:	aa1703f9 	mov	x25, x23
   88dc4:	d280021b 	mov	x27, #0x10                  	// #16
   88dc8:	aa1503f7 	mov	x23, x21
   88dcc:	2a1a03f5 	mov	w21, w26
   88dd0:	aa0203fa 	mov	x26, x2
   88dd4:	f9004bf8 	str	x24, [sp, #144]
   88dd8:	aa0403f8 	mov	x24, x4
   88ddc:	b9009beb 	str	w11, [sp, #152]
   88de0:	b900a3e3 	str	w3, [sp, #160]
   88de4:	14000004 	b	88df4 <_vfprintf_r+0x2b04>
   88de8:	510042b5 	sub	w21, w21, #0x10
   88dec:	710042bf 	cmp	w21, #0x10
   88df0:	540009ad 	b.le	88f24 <_vfprintf_r+0x2c34>
   88df4:	91004000 	add	x0, x0, #0x10
   88df8:	11000421 	add	w1, w1, #0x1
   88dfc:	a9006cd8 	stp	x24, x27, [x6]
   88e00:	910040c6 	add	x6, x6, #0x10
   88e04:	b9018be1 	str	w1, [sp, #392]
   88e08:	f900cbe0 	str	x0, [sp, #400]
   88e0c:	71001c3f 	cmp	w1, #0x7
   88e10:	54fffecd 	b.le	88de8 <_vfprintf_r+0x2af8>
   88e14:	910603e2 	add	x2, sp, #0x180
   88e18:	aa1703e1 	mov	x1, x23
   88e1c:	aa1303e0 	mov	x0, x19
   88e20:	94000280 	bl	89820 <__sprint_r>
   88e24:	35002f20 	cbnz	w0, 89408 <_vfprintf_r+0x3118>
   88e28:	f940cbe0 	ldr	x0, [sp, #400]
   88e2c:	aa1603e6 	mov	x6, x22
   88e30:	b9418be1 	ldr	w1, [sp, #392]
   88e34:	17ffffed 	b	88de8 <_vfprintf_r+0x2af8>
   88e38:	1e604120 	fmov	d0, d9
   88e3c:	2a0703e2 	mov	w2, w7
   88e40:	9105e3e5 	add	x5, sp, #0x178
   88e44:	9105c3e4 	add	x4, sp, #0x170
   88e48:	910563e3 	add	x3, sp, #0x158
   88e4c:	aa1303e0 	mov	x0, x19
   88e50:	52800041 	mov	w1, #0x2                   	// #2
   88e54:	b90093e7 	str	w7, [sp, #144]
   88e58:	291323e9 	stp	w9, w8, [sp, #152]
   88e5c:	b900a3eb 	str	w11, [sp, #160]
   88e60:	940012d4 	bl	8d9b0 <_dtoa_r>
   88e64:	295323e9 	ldp	w9, w8, [sp, #152]
   88e68:	aa0003f8 	mov	x24, x0
   88e6c:	b94093e7 	ldr	w7, [sp, #144]
   88e70:	b940a3eb 	ldr	w11, [sp, #160]
   88e74:	36000369 	tbz	w9, #0, 88ee0 <_vfprintf_r+0x2bf0>
   88e78:	1e602128 	fcmp	d9, #0.0
   88e7c:	54003860 	b.eq	89588 <_vfprintf_r+0x3298>  // b.none
   88e80:	8b27c302 	add	x2, x24, w7, sxtw
   88e84:	17fffd20 	b	88304 <_vfprintf_r+0x2014>
   88e88:	b940b3e1 	ldr	w1, [sp, #176]
   88e8c:	52800ce8 	mov	w8, #0x67                  	// #103
   88e90:	0b00003b 	add	w27, w1, w0
   88e94:	b94093e0 	ldr	w0, [sp, #144]
   88e98:	7100001f 	cmp	w0, #0x0
   88e9c:	54ffe6cc 	b.gt	88b74 <_vfprintf_r+0x2884>
   88ea0:	4b00036c 	sub	w12, w27, w0
   88ea4:	3100059b 	adds	w27, w12, #0x1
   88ea8:	1a9f5363 	csel	w3, w27, wzr, pl	// pl = nfrst
   88eac:	17fffeff 	b	88aa8 <_vfprintf_r+0x27b8>
   88eb0:	910663f8 	add	x24, sp, #0x198
   88eb4:	d2800017 	mov	x23, #0x0                   	// #0
   88eb8:	17fffc17 	b	87f14 <_vfprintf_r+0x1c24>
   88ebc:	b940b2a0 	ldr	w0, [x21, #176]
   88ec0:	370000a0 	tbnz	w0, #0, 88ed4 <_vfprintf_r+0x2be4>
   88ec4:	794022a0 	ldrh	w0, [x21, #16]
   88ec8:	37480060 	tbnz	w0, #9, 88ed4 <_vfprintf_r+0x2be4>
   88ecc:	f94052a0 	ldr	x0, [x21, #160]
   88ed0:	94000c28 	bl	8bf70 <__retarget_lock_release_recursive>
   88ed4:	12800000 	mov	w0, #0xffffffff            	// #-1
   88ed8:	b90073e0 	str	w0, [sp, #112]
   88edc:	17fff717 	b	86b38 <_vfprintf_r+0x848>
   88ee0:	f940bfe0 	ldr	x0, [sp, #376]
   88ee4:	b9415be1 	ldr	w1, [sp, #344]
   88ee8:	cb180000 	sub	x0, x0, x24
   88eec:	b90093e1 	str	w1, [sp, #144]
   88ef0:	b9009fe0 	str	w0, [sp, #156]
   88ef4:	17fffd15 	b	88348 <_vfprintf_r+0x2058>
   88ef8:	91058be1 	add	x1, sp, #0x162
   88efc:	35000082 	cbnz	w2, 88f0c <_vfprintf_r+0x2c1c>
   88f00:	91058fe1 	add	x1, sp, #0x163
   88f04:	52800602 	mov	w2, #0x30                  	// #48
   88f08:	39058be2 	strb	w2, [sp, #354]
   88f0c:	1100c000 	add	w0, w0, #0x30
   88f10:	38001420 	strb	w0, [x1], #1
   88f14:	910583e2 	add	x2, sp, #0x160
   88f18:	4b020020 	sub	w0, w1, w2
   88f1c:	b900ebe0 	str	w0, [sp, #232]
   88f20:	17fffd3f 	b	8841c <_vfprintf_r+0x212c>
   88f24:	aa1a03e2 	mov	x2, x26
   88f28:	aa1803e4 	mov	x4, x24
   88f2c:	f9404bf8 	ldr	x24, [sp, #144]
   88f30:	2a1503fa 	mov	w26, w21
   88f34:	b9409beb 	ldr	w11, [sp, #152]
   88f38:	aa1703f5 	mov	x21, x23
   88f3c:	b940a3e3 	ldr	w3, [sp, #160]
   88f40:	aa1903f7 	mov	x23, x25
   88f44:	2a1c03e9 	mov	w9, w28
   88f48:	aa0203f9 	mov	x25, x2
   88f4c:	93407f5a 	sxtw	x26, w26
   88f50:	11000421 	add	w1, w1, #0x1
   88f54:	8b1a0000 	add	x0, x0, x26
   88f58:	a90068c4 	stp	x4, x26, [x6]
   88f5c:	910040c6 	add	x6, x6, #0x10
   88f60:	b9018be1 	str	w1, [sp, #392]
   88f64:	f900cbe0 	str	x0, [sp, #400]
   88f68:	71001c3f 	cmp	w1, #0x7
   88f6c:	54fed96d 	b.le	86a98 <_vfprintf_r+0x7a8>
   88f70:	910603e2 	add	x2, sp, #0x180
   88f74:	aa1503e1 	mov	x1, x21
   88f78:	aa1303e0 	mov	x0, x19
   88f7c:	b90093e9 	str	w9, [sp, #144]
   88f80:	b9009beb 	str	w11, [sp, #152]
   88f84:	b900a3e3 	str	w3, [sp, #160]
   88f88:	94000226 	bl	89820 <__sprint_r>
   88f8c:	35fedbe0 	cbnz	w0, 86b08 <_vfprintf_r+0x818>
   88f90:	f940cbe0 	ldr	x0, [sp, #400]
   88f94:	aa1603e6 	mov	x6, x22
   88f98:	b94093e9 	ldr	w9, [sp, #144]
   88f9c:	b9409beb 	ldr	w11, [sp, #152]
   88fa0:	b940a3e3 	ldr	w3, [sp, #160]
   88fa4:	b9418be1 	ldr	w1, [sp, #392]
   88fa8:	17fff6bc 	b	86a98 <_vfprintf_r+0x7a8>
   88fac:	f94087e2 	ldr	x2, [sp, #264]
   88fb0:	b940efe0 	ldr	w0, [sp, #236]
   88fb4:	b900efe1 	str	w1, [sp, #236]
   88fb8:	8b20c040 	add	x0, x2, w0, sxtw
   88fbc:	17fff7a9 	b	86e60 <_vfprintf_r+0xb70>
   88fc0:	f94087e2 	ldr	x2, [sp, #264]
   88fc4:	b940efe0 	ldr	w0, [sp, #236]
   88fc8:	b900efe1 	str	w1, [sp, #236]
   88fcc:	8b20c040 	add	x0, x2, w0, sxtw
   88fd0:	fd400008 	ldr	d8, [x0]
   88fd4:	17fff7ae 	b	86e8c <_vfprintf_r+0xb9c>
   88fd8:	f900bfec 	str	x12, [sp, #376]
   88fdc:	aa0003e1 	mov	x1, x0
   88fe0:	39403c44 	ldrb	w4, [x2, #15]
   88fe4:	385ff003 	ldurb	w3, [x0, #-1]
   88fe8:	6b04007f 	cmp	w3, w4
   88fec:	54000121 	b.ne	89010 <_vfprintf_r+0x2d20>  // b.any
   88ff0:	52800607 	mov	w7, #0x30                  	// #48
   88ff4:	381ff027 	sturb	w7, [x1, #-1]
   88ff8:	f940bfe1 	ldr	x1, [sp, #376]
   88ffc:	d1000423 	sub	x3, x1, #0x1
   89000:	f900bfe3 	str	x3, [sp, #376]
   89004:	385ff023 	ldurb	w3, [x1, #-1]
   89008:	6b04007f 	cmp	w3, w4
   8900c:	54ffff40 	b.eq	88ff4 <_vfprintf_r+0x2d04>  // b.none
   89010:	11000464 	add	w4, w3, #0x1
   89014:	12001c84 	and	w4, w4, #0xff
   89018:	7100e47f 	cmp	w3, #0x39
   8901c:	54000120 	b.eq	89040 <_vfprintf_r+0x2d50>  // b.none
   89020:	381ff024 	sturb	w4, [x1, #-1]
   89024:	b9415be1 	ldr	w1, [sp, #344]
   89028:	4b180000 	sub	w0, w0, w24
   8902c:	b90093e1 	str	w1, [sp, #144]
   89030:	b9009fe0 	str	w0, [sp, #156]
   89034:	17fffb62 	b	87dbc <_vfprintf_r+0x1acc>
   89038:	3607a009 	tbz	w9, #0, 88438 <_vfprintf_r+0x2148>
   8903c:	17fffcfd 	b	88430 <_vfprintf_r+0x2140>
   89040:	39402844 	ldrb	w4, [x2, #10]
   89044:	381ff024 	sturb	w4, [x1, #-1]
   89048:	17fffff7 	b	89024 <_vfprintf_r+0x2d34>
   8904c:	f94057e2 	ldr	x2, [sp, #168]
   89050:	b9407fe0 	ldr	w0, [sp, #124]
   89054:	b9007fe1 	str	w1, [sp, #124]
   89058:	8b20c040 	add	x0, x2, w0, sxtw
   8905c:	17fff7e9 	b	87000 <_vfprintf_r+0xd10>
   89060:	aa1b03f7 	mov	x23, x27
   89064:	b5fed557 	cbnz	x23, 86b0c <_vfprintf_r+0x81c>
   89068:	17fff6ac 	b	86b18 <_vfprintf_r+0x828>
   8906c:	79c02320 	ldrsh	w0, [x25, #16]
   89070:	aa1903f5 	mov	x21, x25
   89074:	321a0000 	orr	w0, w0, #0x40
   89078:	79002320 	strh	w0, [x25, #16]
   8907c:	17fff6a8 	b	86b1c <_vfprintf_r+0x82c>
   89080:	37f81a80 	tbnz	w0, #31, 893d0 <_vfprintf_r+0x30e0>
   89084:	f94043e0 	ldr	x0, [sp, #128]
   89088:	91003c01 	add	x1, x0, #0xf
   8908c:	927df021 	and	x1, x1, #0xfffffffffffffff8
   89090:	f90043e1 	str	x1, [sp, #128]
   89094:	f9400000 	ldr	x0, [x0]
   89098:	b94073e1 	ldr	w1, [sp, #112]
   8909c:	b9000001 	str	w1, [x0]
   890a0:	17fff4db 	b	8640c <_vfprintf_r+0x11c>
   890a4:	39453fe1 	ldrb	w1, [sp, #335]
   890a8:	2a0703e3 	mov	w3, w7
   890ac:	b9009bff 	str	wzr, [sp, #152]
   890b0:	2a0703fb 	mov	w27, w7
   890b4:	b900a3ff 	str	wzr, [sp, #160]
   890b8:	52800007 	mov	w7, #0x0                   	// #0
   890bc:	52800e68 	mov	w8, #0x73                  	// #115
   890c0:	34fea7c1 	cbz	w1, 865b8 <_vfprintf_r+0x2c8>
   890c4:	17fff789 	b	86ee8 <_vfprintf_r+0xbf8>
   890c8:	f94057e2 	ldr	x2, [sp, #168]
   890cc:	b9407fe0 	ldr	w0, [sp, #124]
   890d0:	b9007fe1 	str	w1, [sp, #124]
   890d4:	8b20c040 	add	x0, x2, w0, sxtw
   890d8:	17fff9e4 	b	87868 <_vfprintf_r+0x1578>
   890dc:	b9407fe0 	ldr	w0, [sp, #124]
   890e0:	11002001 	add	w1, w0, #0x8
   890e4:	7100003f 	cmp	w1, #0x0
   890e8:	5400246d 	b.le	89574 <_vfprintf_r+0x3284>
   890ec:	f94043e0 	ldr	x0, [sp, #128]
   890f0:	b9007fe1 	str	w1, [sp, #124]
   890f4:	91002c02 	add	x2, x0, #0xb
   890f8:	927df041 	and	x1, x2, #0xfffffffffffffff8
   890fc:	f90043e1 	str	x1, [sp, #128]
   89100:	17fffd31 	b	885c4 <_vfprintf_r+0x22d4>
   89104:	9e660100 	fmov	x0, d8
   89108:	b7f81780 	tbnz	x0, #63, 893f8 <_vfprintf_r+0x3108>
   8910c:	39453fe1 	ldrb	w1, [sp, #335]
   89110:	90000060 	adrp	x0, 95000 <pmu_event_descr+0x60>
   89114:	90000065 	adrp	x5, 95000 <pmu_event_descr+0x60>
   89118:	7101211f 	cmp	w8, #0x48
   8911c:	91178000 	add	x0, x0, #0x5e0
   89120:	911760a5 	add	x5, x5, #0x5d8
   89124:	17fff767 	b	86ec0 <_vfprintf_r+0xbd0>
   89128:	b9407fe0 	ldr	w0, [sp, #124]
   8912c:	11002001 	add	w1, w0, #0x8
   89130:	7100003f 	cmp	w1, #0x0
   89134:	5400190d 	b.le	89454 <_vfprintf_r+0x3164>
   89138:	f94043e0 	ldr	x0, [sp, #128]
   8913c:	b9007fe1 	str	w1, [sp, #124]
   89140:	91002c02 	add	x2, x0, #0xb
   89144:	927df041 	and	x1, x2, #0xfffffffffffffff8
   89148:	b9400000 	ldr	w0, [x0]
   8914c:	f90043e1 	str	x1, [sp, #128]
   89150:	17fff834 	b	87220 <_vfprintf_r+0xf30>
   89154:	f94057e2 	ldr	x2, [sp, #168]
   89158:	b9407fe0 	ldr	w0, [sp, #124]
   8915c:	b9007fe1 	str	w1, [sp, #124]
   89160:	8b20c040 	add	x0, x2, w0, sxtw
   89164:	79400000 	ldrh	w0, [x0]
   89168:	17fffa7b 	b	87b54 <_vfprintf_r+0x1864>
   8916c:	b9407fe0 	ldr	w0, [sp, #124]
   89170:	11002001 	add	w1, w0, #0x8
   89174:	7100003f 	cmp	w1, #0x0
   89178:	54001f2d 	b.le	8955c <_vfprintf_r+0x326c>
   8917c:	f94043e0 	ldr	x0, [sp, #128]
   89180:	b9007fe1 	str	w1, [sp, #124]
   89184:	91002c02 	add	x2, x0, #0xb
   89188:	927df041 	and	x1, x2, #0xfffffffffffffff8
   8918c:	39400000 	ldrb	w0, [x0]
   89190:	f90043e1 	str	x1, [sp, #128]
   89194:	17fff823 	b	87220 <_vfprintf_r+0xf30>
   89198:	52800ce8 	mov	w8, #0x67                  	// #103
   8919c:	f9407fe2 	ldr	x2, [sp, #248]
   891a0:	39400040 	ldrb	w0, [x2]
   891a4:	7103fc1f 	cmp	w0, #0xff
   891a8:	540021a0 	b.eq	895dc <_vfprintf_r+0x32ec>  // b.none
   891ac:	b94093e1 	ldr	w1, [sp, #144]
   891b0:	52800004 	mov	w4, #0x0                   	// #0
   891b4:	52800003 	mov	w3, #0x0                   	// #0
   891b8:	14000005 	b	891cc <_vfprintf_r+0x2edc>
   891bc:	11000463 	add	w3, w3, #0x1
   891c0:	91000442 	add	x2, x2, #0x1
   891c4:	7103fc1f 	cmp	w0, #0xff
   891c8:	54000120 	b.eq	891ec <_vfprintf_r+0x2efc>  // b.none
   891cc:	6b01001f 	cmp	w0, w1
   891d0:	540000ea 	b.ge	891ec <_vfprintf_r+0x2efc>  // b.tcont
   891d4:	4b000021 	sub	w1, w1, w0
   891d8:	39400440 	ldrb	w0, [x2, #1]
   891dc:	35ffff00 	cbnz	w0, 891bc <_vfprintf_r+0x2ecc>
   891e0:	39400040 	ldrb	w0, [x2]
   891e4:	11000484 	add	w4, w4, #0x1
   891e8:	17fffff7 	b	891c4 <_vfprintf_r+0x2ed4>
   891ec:	b90093e1 	str	w1, [sp, #144]
   891f0:	b9009be3 	str	w3, [sp, #152]
   891f4:	b900a3e4 	str	w4, [sp, #160]
   891f8:	f9007fe2 	str	x2, [sp, #248]
   891fc:	b940a3e1 	ldr	w1, [sp, #160]
   89200:	2a1703e9 	mov	w9, w23
   89204:	b9409be0 	ldr	w0, [sp, #152]
   89208:	d2800017 	mov	x23, #0x0                   	// #0
   8920c:	0b010000 	add	w0, w0, w1
   89210:	b94103e1 	ldr	w1, [sp, #256]
   89214:	1b016c1b 	madd	w27, w0, w1, w27
   89218:	7100037f 	cmp	w27, #0x0
   8921c:	1a9fa363 	csel	w3, w27, wzr, ge	// ge = tcont
   89220:	17fffc8d 	b	88454 <_vfprintf_r+0x2164>
   89224:	0b1800e3 	add	w3, w7, w24
   89228:	4b000063 	sub	w3, w3, w0
   8922c:	17fffad3 	b	87d78 <_vfprintf_r+0x1a88>
   89230:	528005a0 	mov	w0, #0x2d                  	// #45
   89234:	1e614109 	fneg	d9, d8
   89238:	b900cbe0 	str	w0, [sp, #200]
   8923c:	17fffc18 	b	8829c <_vfprintf_r+0x1fac>
   89240:	b9407fe0 	ldr	w0, [sp, #124]
   89244:	11002001 	add	w1, w0, #0x8
   89248:	7100003f 	cmp	w1, #0x0
   8924c:	540012cd 	b.le	894a4 <_vfprintf_r+0x31b4>
   89250:	f94043e0 	ldr	x0, [sp, #128]
   89254:	b9007fe1 	str	w1, [sp, #124]
   89258:	91002c02 	add	x2, x0, #0xb
   8925c:	927df041 	and	x1, x2, #0xfffffffffffffff8
   89260:	b9400000 	ldr	w0, [x0]
   89264:	f90043e1 	str	x1, [sp, #128]
   89268:	17fffa3b 	b	87b54 <_vfprintf_r+0x1864>
   8926c:	b9407fe0 	ldr	w0, [sp, #124]
   89270:	11002001 	add	w1, w0, #0x8
   89274:	7100003f 	cmp	w1, #0x0
   89278:	5400122d 	b.le	894bc <_vfprintf_r+0x31cc>
   8927c:	f94043e0 	ldr	x0, [sp, #128]
   89280:	b9007fe1 	str	w1, [sp, #124]
   89284:	91002c02 	add	x2, x0, #0xb
   89288:	927df041 	and	x1, x2, #0xfffffffffffffff8
   8928c:	39400000 	ldrb	w0, [x0]
   89290:	f90043e1 	str	x1, [sp, #128]
   89294:	17fffa30 	b	87b54 <_vfprintf_r+0x1864>
   89298:	f94057e2 	ldr	x2, [sp, #168]
   8929c:	b9407fe0 	ldr	w0, [sp, #124]
   892a0:	b9007fe1 	str	w1, [sp, #124]
   892a4:	8b20c040 	add	x0, x2, w0, sxtw
   892a8:	79400000 	ldrh	w0, [x0]
   892ac:	17fff7dd 	b	87220 <_vfprintf_r+0xf30>
   892b0:	f94057e2 	ldr	x2, [sp, #168]
   892b4:	b9407fe0 	ldr	w0, [sp, #124]
   892b8:	b9007fe1 	str	w1, [sp, #124]
   892bc:	8b20c040 	add	x0, x2, w0, sxtw
   892c0:	17fff961 	b	87844 <_vfprintf_r+0x1554>
   892c4:	b940b3e0 	ldr	w0, [sp, #176]
   892c8:	52800cc8 	mov	w8, #0x66                  	// #102
   892cc:	0b00002c 	add	w12, w1, w0
   892d0:	0b07019b 	add	w27, w12, w7
   892d4:	17fffe28 	b	88b74 <_vfprintf_r+0x2884>
   892d8:	aa1903f5 	mov	x21, x25
   892dc:	b94093e9 	ldr	w9, [sp, #144]
   892e0:	aa1b03f9 	mov	x25, x27
   892e4:	b9409be8 	ldr	w8, [sp, #152]
   892e8:	b940a3eb 	ldr	w11, [sp, #160]
   892ec:	2a1a03fb 	mov	w27, w26
   892f0:	17fffaf9 	b	87ed4 <_vfprintf_r+0x1be4>
   892f4:	b9407fe0 	ldr	w0, [sp, #124]
   892f8:	11002001 	add	w1, w0, #0x8
   892fc:	7100003f 	cmp	w1, #0x0
   89300:	54000b6d 	b.le	8946c <_vfprintf_r+0x317c>
   89304:	f94043e0 	ldr	x0, [sp, #128]
   89308:	b9007fe1 	str	w1, [sp, #124]
   8930c:	91002c02 	add	x2, x0, #0xb
   89310:	927df041 	and	x1, x2, #0xfffffffffffffff8
   89314:	f90043e1 	str	x1, [sp, #128]
   89318:	17fffbce 	b	88250 <_vfprintf_r+0x1f60>
   8931c:	b9407fe0 	ldr	w0, [sp, #124]
   89320:	11002001 	add	w1, w0, #0x8
   89324:	7100003f 	cmp	w1, #0x0
   89328:	5400082d 	b.le	8942c <_vfprintf_r+0x313c>
   8932c:	f94043e0 	ldr	x0, [sp, #128]
   89330:	b9007fe1 	str	w1, [sp, #124]
   89334:	91002c02 	add	x2, x0, #0xb
   89338:	927df041 	and	x1, x2, #0xfffffffffffffff8
   8933c:	f90043e1 	str	x1, [sp, #128]
   89340:	17fffcb7 	b	8861c <_vfprintf_r+0x232c>
   89344:	b9407fe0 	ldr	w0, [sp, #124]
   89348:	11002001 	add	w1, w0, #0x8
   8934c:	7100003f 	cmp	w1, #0x0
   89350:	540012cd 	b.le	895a8 <_vfprintf_r+0x32b8>
   89354:	f94043e0 	ldr	x0, [sp, #128]
   89358:	b9007fe1 	str	w1, [sp, #124]
   8935c:	91003c02 	add	x2, x0, #0xf
   89360:	927df041 	and	x1, x2, #0xfffffffffffffff8
   89364:	f90043e1 	str	x1, [sp, #128]
   89368:	17fffc89 	b	8858c <_vfprintf_r+0x229c>
   8936c:	aa1a03f7 	mov	x23, x26
   89370:	b5febcf7 	cbnz	x23, 86b0c <_vfprintf_r+0x81c>
   89374:	17fff5e9 	b	86b18 <_vfprintf_r+0x828>
   89378:	b9407fe0 	ldr	w0, [sp, #124]
   8937c:	11002001 	add	w1, w0, #0x8
   89380:	7100003f 	cmp	w1, #0x0
   89384:	54000c6d 	b.le	89510 <_vfprintf_r+0x3220>
   89388:	f94043e0 	ldr	x0, [sp, #128]
   8938c:	b9007fe1 	str	w1, [sp, #124]
   89390:	91002c02 	add	x2, x0, #0xb
   89394:	927df041 	and	x1, x2, #0xfffffffffffffff8
   89398:	f90043e1 	str	x1, [sp, #128]
   8939c:	17fffb9a 	b	88204 <_vfprintf_r+0x1f14>
   893a0:	8b000302 	add	x2, x24, x0
   893a4:	17fffbd8 	b	88304 <_vfprintf_r+0x2014>
   893a8:	b9407fe0 	ldr	w0, [sp, #124]
   893ac:	11002001 	add	w1, w0, #0x8
   893b0:	7100003f 	cmp	w1, #0x0
   893b4:	5400046d 	b.le	89440 <_vfprintf_r+0x3150>
   893b8:	f94043e0 	ldr	x0, [sp, #128]
   893bc:	b9007fe1 	str	w1, [sp, #124]
   893c0:	91003c02 	add	x2, x0, #0xf
   893c4:	927df041 	and	x1, x2, #0xfffffffffffffff8
   893c8:	f90043e1 	str	x1, [sp, #128]
   893cc:	17fff939 	b	878b0 <_vfprintf_r+0x15c0>
   893d0:	b9407fe0 	ldr	w0, [sp, #124]
   893d4:	11002001 	add	w1, w0, #0x8
   893d8:	7100003f 	cmp	w1, #0x0
   893dc:	540005ad 	b.le	89490 <_vfprintf_r+0x31a0>
   893e0:	f94043e0 	ldr	x0, [sp, #128]
   893e4:	b9007fe1 	str	w1, [sp, #124]
   893e8:	91003c02 	add	x2, x0, #0xf
   893ec:	927df041 	and	x1, x2, #0xfffffffffffffff8
   893f0:	f90043e1 	str	x1, [sp, #128]
   893f4:	17ffff28 	b	89094 <_vfprintf_r+0x2da4>
   893f8:	528005a0 	mov	w0, #0x2d                  	// #45
   893fc:	528005a1 	mov	w1, #0x2d                  	// #45
   89400:	39053fe0 	strb	w0, [sp, #335]
   89404:	17ffff43 	b	89110 <_vfprintf_r+0x2e20>
   89408:	aa1703f5 	mov	x21, x23
   8940c:	aa1903f7 	mov	x23, x25
   89410:	b5feb7f7 	cbnz	x23, 86b0c <_vfprintf_r+0x81c>
   89414:	17fff5c1 	b	86b18 <_vfprintf_r+0x828>
   89418:	b9415be0 	ldr	w0, [sp, #344]
   8941c:	b90093e0 	str	w0, [sp, #144]
   89420:	b94093e0 	ldr	w0, [sp, #144]
   89424:	51000400 	sub	w0, w0, #0x1
   89428:	17fffbce 	b	88360 <_vfprintf_r+0x2070>
   8942c:	f94057e2 	ldr	x2, [sp, #168]
   89430:	b9407fe0 	ldr	w0, [sp, #124]
   89434:	b9007fe1 	str	w1, [sp, #124]
   89438:	8b20c040 	add	x0, x2, w0, sxtw
   8943c:	17fffc78 	b	8861c <_vfprintf_r+0x232c>
   89440:	f94057e2 	ldr	x2, [sp, #168]
   89444:	b9407fe0 	ldr	w0, [sp, #124]
   89448:	b9007fe1 	str	w1, [sp, #124]
   8944c:	8b20c040 	add	x0, x2, w0, sxtw
   89450:	17fff918 	b	878b0 <_vfprintf_r+0x15c0>
   89454:	f94057e2 	ldr	x2, [sp, #168]
   89458:	b9407fe0 	ldr	w0, [sp, #124]
   8945c:	b9007fe1 	str	w1, [sp, #124]
   89460:	8b20c040 	add	x0, x2, w0, sxtw
   89464:	b9400000 	ldr	w0, [x0]
   89468:	17fff76e 	b	87220 <_vfprintf_r+0xf30>
   8946c:	f94057e2 	ldr	x2, [sp, #168]
   89470:	b9407fe0 	ldr	w0, [sp, #124]
   89474:	b9007fe1 	str	w1, [sp, #124]
   89478:	8b20c040 	add	x0, x2, w0, sxtw
   8947c:	17fffb75 	b	88250 <_vfprintf_r+0x1f60>
   89480:	79c022a0 	ldrsh	w0, [x21, #16]
   89484:	321a0000 	orr	w0, w0, #0x40
   89488:	790022a0 	strh	w0, [x21, #16]
   8948c:	17fff5a4 	b	86b1c <_vfprintf_r+0x82c>
   89490:	f94057e2 	ldr	x2, [sp, #168]
   89494:	b9407fe0 	ldr	w0, [sp, #124]
   89498:	b9007fe1 	str	w1, [sp, #124]
   8949c:	8b20c040 	add	x0, x2, w0, sxtw
   894a0:	17fffefd 	b	89094 <_vfprintf_r+0x2da4>
   894a4:	f94057e2 	ldr	x2, [sp, #168]
   894a8:	b9407fe0 	ldr	w0, [sp, #124]
   894ac:	b9007fe1 	str	w1, [sp, #124]
   894b0:	8b20c040 	add	x0, x2, w0, sxtw
   894b4:	b9400000 	ldr	w0, [x0]
   894b8:	17fff9a7 	b	87b54 <_vfprintf_r+0x1864>
   894bc:	f94057e2 	ldr	x2, [sp, #168]
   894c0:	b9407fe0 	ldr	w0, [sp, #124]
   894c4:	b9007fe1 	str	w1, [sp, #124]
   894c8:	8b20c040 	add	x0, x2, w0, sxtw
   894cc:	39400000 	ldrb	w0, [x0]
   894d0:	17fff9a1 	b	87b54 <_vfprintf_r+0x1864>
   894d4:	350000a0 	cbnz	w0, 894e8 <_vfprintf_r+0x31f8>
   894d8:	52800023 	mov	w3, #0x1                   	// #1
   894dc:	52800cc8 	mov	w8, #0x66                  	// #102
   894e0:	2a0303fb 	mov	w27, w3
   894e4:	17fffd71 	b	88aa8 <_vfprintf_r+0x27b8>
   894e8:	b940b3e0 	ldr	w0, [sp, #176]
   894ec:	52800cc8 	mov	w8, #0x66                  	// #102
   894f0:	1100040c 	add	w12, w0, #0x1
   894f4:	2b07019b 	adds	w27, w12, w7
   894f8:	1a9f5363 	csel	w3, w27, wzr, pl	// pl = nfrst
   894fc:	17fffd6b 	b	88aa8 <_vfprintf_r+0x27b8>
   89500:	52800020 	mov	w0, #0x1                   	// #1
   89504:	4b070000 	sub	w0, w0, w7
   89508:	b9015be0 	str	w0, [sp, #344]
   8950c:	17fffd8c 	b	88b3c <_vfprintf_r+0x284c>
   89510:	f94057e2 	ldr	x2, [sp, #168]
   89514:	b9407fe0 	ldr	w0, [sp, #124]
   89518:	b9007fe1 	str	w1, [sp, #124]
   8951c:	8b20c040 	add	x0, x2, w0, sxtw
   89520:	17fffb39 	b	88204 <_vfprintf_r+0x1f14>
   89524:	b9407fe2 	ldr	w2, [sp, #124]
   89528:	37f804a2 	tbnz	w2, #31, 895bc <_vfprintf_r+0x32cc>
   8952c:	f94043e0 	ldr	x0, [sp, #128]
   89530:	91002c00 	add	x0, x0, #0xb
   89534:	927df000 	and	x0, x0, #0xfffffffffffffff8
   89538:	f94043e3 	ldr	x3, [sp, #128]
   8953c:	b9007fe2 	str	w2, [sp, #124]
   89540:	39400728 	ldrb	w8, [x25, #1]
   89544:	aa0103f9 	mov	x25, x1
   89548:	f90043e0 	str	x0, [sp, #128]
   8954c:	b9400067 	ldr	w7, [x3]
   89550:	710000ff 	cmp	w7, #0x0
   89554:	5a9fa0fa 	csinv	w26, w7, wzr, ge	// ge = tcont
   89558:	17fff400 	b	86558 <_vfprintf_r+0x268>
   8955c:	f94057e2 	ldr	x2, [sp, #168]
   89560:	b9407fe0 	ldr	w0, [sp, #124]
   89564:	b9007fe1 	str	w1, [sp, #124]
   89568:	8b20c040 	add	x0, x2, w0, sxtw
   8956c:	39400000 	ldrb	w0, [x0]
   89570:	17fff72c 	b	87220 <_vfprintf_r+0xf30>
   89574:	f94057e2 	ldr	x2, [sp, #168]
   89578:	b9407fe0 	ldr	w0, [sp, #124]
   8957c:	b9007fe1 	str	w1, [sp, #124]
   89580:	8b20c040 	add	x0, x2, w0, sxtw
   89584:	17fffc10 	b	885c4 <_vfprintf_r+0x22d4>
   89588:	b9415be0 	ldr	w0, [sp, #344]
   8958c:	b90093e0 	str	w0, [sp, #144]
   89590:	93407ce0 	sxtw	x0, w7
   89594:	b9009fe7 	str	w7, [sp, #156]
   89598:	17fffb6c 	b	88348 <_vfprintf_r+0x2058>
   8959c:	52800040 	mov	w0, #0x2                   	// #2
   895a0:	b900ebe0 	str	w0, [sp, #232]
   895a4:	17fffb9e 	b	8841c <_vfprintf_r+0x212c>
   895a8:	f94057e2 	ldr	x2, [sp, #168]
   895ac:	b9407fe0 	ldr	w0, [sp, #124]
   895b0:	b9007fe1 	str	w1, [sp, #124]
   895b4:	8b20c040 	add	x0, x2, w0, sxtw
   895b8:	17fffbf5 	b	8858c <_vfprintf_r+0x229c>
   895bc:	b9407fe0 	ldr	w0, [sp, #124]
   895c0:	11002002 	add	w2, w0, #0x8
   895c4:	f94043e0 	ldr	x0, [sp, #128]
   895c8:	7100005f 	cmp	w2, #0x0
   895cc:	540001ed 	b.le	89608 <_vfprintf_r+0x3318>
   895d0:	91002c00 	add	x0, x0, #0xb
   895d4:	927df000 	and	x0, x0, #0xfffffffffffffff8
   895d8:	17ffffd8 	b	89538 <_vfprintf_r+0x3248>
   895dc:	b9009bff 	str	wzr, [sp, #152]
   895e0:	b900a3ff 	str	wzr, [sp, #160]
   895e4:	17ffff06 	b	891fc <_vfprintf_r+0x2f0c>
   895e8:	71011b7f 	cmp	w27, #0x46
   895ec:	54ffab40 	b.eq	88b54 <_vfprintf_r+0x2864>  // b.none
   895f0:	17ffff8c 	b	89420 <_vfprintf_r+0x3130>
   895f4:	794022a0 	ldrh	w0, [x21, #16]
   895f8:	321a0000 	orr	w0, w0, #0x40
   895fc:	790022a0 	strh	w0, [x21, #16]
   89600:	b5fea877 	cbnz	x23, 86b0c <_vfprintf_r+0x81c>
   89604:	17fff545 	b	86b18 <_vfprintf_r+0x828>
   89608:	f94057e4 	ldr	x4, [sp, #168]
   8960c:	b9407fe3 	ldr	w3, [sp, #124]
   89610:	8b23c083 	add	x3, x4, w3, sxtw
   89614:	f90043e3 	str	x3, [sp, #128]
   89618:	17ffffc8 	b	89538 <_vfprintf_r+0x3248>
   8961c:	00000000 	udf	#0

0000000000089620 <vfprintf>:
   89620:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   89624:	b0000064 	adrp	x4, 96000 <JIS_state_table+0x70>
   89628:	aa0003e3 	mov	x3, x0
   8962c:	910003fd 	mov	x29, sp
   89630:	ad400440 	ldp	q0, q1, [x2]
   89634:	aa0103e2 	mov	x2, x1
   89638:	f9410080 	ldr	x0, [x4, #512]
   8963c:	aa0303e1 	mov	x1, x3
   89640:	910043e3 	add	x3, sp, #0x10
   89644:	ad0087e0 	stp	q0, q1, [sp, #16]
   89648:	97fff32a 	bl	862f0 <_vfprintf_r>
   8964c:	a8c37bfd 	ldp	x29, x30, [sp], #48
   89650:	d65f03c0 	ret
	...

0000000000089660 <__sbprintf>:
   89660:	d11443ff 	sub	sp, sp, #0x510
   89664:	a9007bfd 	stp	x29, x30, [sp]
   89668:	910003fd 	mov	x29, sp
   8966c:	a90153f3 	stp	x19, x20, [sp, #16]
   89670:	aa0103f3 	mov	x19, x1
   89674:	79402021 	ldrh	w1, [x1, #16]
   89678:	aa0303f4 	mov	x20, x3
   8967c:	910443e3 	add	x3, sp, #0x110
   89680:	f9401a66 	ldr	x6, [x19, #48]
   89684:	121e7821 	and	w1, w1, #0xfffffffd
   89688:	f9402265 	ldr	x5, [x19, #64]
   8968c:	a9025bf5 	stp	x21, x22, [sp, #32]
   89690:	79402667 	ldrh	w7, [x19, #18]
   89694:	b940b264 	ldr	w4, [x19, #176]
   89698:	aa0203f6 	mov	x22, x2
   8969c:	52808002 	mov	w2, #0x400                 	// #1024
   896a0:	aa0003f5 	mov	x21, x0
   896a4:	9103e3e0 	add	x0, sp, #0xf8
   896a8:	f9002fe3 	str	x3, [sp, #88]
   896ac:	b90067e2 	str	w2, [sp, #100]
   896b0:	7900d3e1 	strh	w1, [sp, #104]
   896b4:	7900d7e7 	strh	w7, [sp, #106]
   896b8:	f9003be3 	str	x3, [sp, #112]
   896bc:	b9007be2 	str	w2, [sp, #120]
   896c0:	b90083ff 	str	wzr, [sp, #128]
   896c4:	f90047e6 	str	x6, [sp, #136]
   896c8:	f9004fe5 	str	x5, [sp, #152]
   896cc:	b9010be4 	str	w4, [sp, #264]
   896d0:	94000a08 	bl	8bef0 <__retarget_lock_init_recursive>
   896d4:	ad400680 	ldp	q0, q1, [x20]
   896d8:	aa1603e2 	mov	x2, x22
   896dc:	9100c3e3 	add	x3, sp, #0x30
   896e0:	aa1503e0 	mov	x0, x21
   896e4:	910163e1 	add	x1, sp, #0x58
   896e8:	ad0187e0 	stp	q0, q1, [sp, #48]
   896ec:	97fff301 	bl	862f0 <_vfprintf_r>
   896f0:	2a0003f4 	mov	w20, w0
   896f4:	37f800c0 	tbnz	w0, #31, 8970c <__sbprintf+0xac>
   896f8:	910163e1 	add	x1, sp, #0x58
   896fc:	aa1503e0 	mov	x0, x21
   89700:	940015d4 	bl	8ee50 <_fflush_r>
   89704:	7100001f 	cmp	w0, #0x0
   89708:	5a9f0294 	csinv	w20, w20, wzr, eq	// eq = none
   8970c:	7940d3e0 	ldrh	w0, [sp, #104]
   89710:	36300080 	tbz	w0, #6, 89720 <__sbprintf+0xc0>
   89714:	79402260 	ldrh	w0, [x19, #16]
   89718:	321a0000 	orr	w0, w0, #0x40
   8971c:	79002260 	strh	w0, [x19, #16]
   89720:	f9407fe0 	ldr	x0, [sp, #248]
   89724:	940009fb 	bl	8bf10 <__retarget_lock_close_recursive>
   89728:	a9407bfd 	ldp	x29, x30, [sp]
   8972c:	2a1403e0 	mov	w0, w20
   89730:	a94153f3 	ldp	x19, x20, [sp, #16]
   89734:	a9425bf5 	ldp	x21, x22, [sp, #32]
   89738:	911443ff 	add	sp, sp, #0x510
   8973c:	d65f03c0 	ret

0000000000089740 <__sprint_r.part.0>:
   89740:	a9bb7bfd 	stp	x29, x30, [sp, #-80]!
   89744:	910003fd 	mov	x29, sp
   89748:	b940b023 	ldr	w3, [x1, #176]
   8974c:	a90363f7 	stp	x23, x24, [sp, #48]
   89750:	aa0203f8 	mov	x24, x2
   89754:	36680563 	tbz	w3, #13, 89800 <__sprint_r.part.0+0xc0>
   89758:	a9025bf5 	stp	x21, x22, [sp, #32]
   8975c:	aa0003f5 	mov	x21, x0
   89760:	f9400840 	ldr	x0, [x2, #16]
   89764:	a90153f3 	stp	x19, x20, [sp, #16]
   89768:	aa0103f4 	mov	x20, x1
   8976c:	a9046bf9 	stp	x25, x26, [sp, #64]
   89770:	f940005a 	ldr	x26, [x2]
   89774:	b40003c0 	cbz	x0, 897ec <__sprint_r.part.0+0xac>
   89778:	a9406756 	ldp	x22, x25, [x26]
   8977c:	d342ff39 	lsr	x25, x25, #2
   89780:	2a1903f7 	mov	w23, w25
   89784:	7100033f 	cmp	w25, #0x0
   89788:	540002ad 	b.le	897dc <__sprint_r.part.0+0x9c>
   8978c:	d2800013 	mov	x19, #0x0                   	// #0
   89790:	14000003 	b	8979c <__sprint_r.part.0+0x5c>
   89794:	6b1302ff 	cmp	w23, w19
   89798:	5400020d 	b.le	897d8 <__sprint_r.part.0+0x98>
   8979c:	b8737ac1 	ldr	w1, [x22, x19, lsl #2]
   897a0:	aa1403e2 	mov	x2, x20
   897a4:	aa1503e0 	mov	x0, x21
   897a8:	91000673 	add	x19, x19, #0x1
   897ac:	94001b95 	bl	90600 <_fputwc_r>
   897b0:	3100041f 	cmn	w0, #0x1
   897b4:	54ffff01 	b.ne	89794 <__sprint_r.part.0+0x54>  // b.any
   897b8:	a94153f3 	ldp	x19, x20, [sp, #16]
   897bc:	a9425bf5 	ldp	x21, x22, [sp, #32]
   897c0:	a9446bf9 	ldp	x25, x26, [sp, #64]
   897c4:	b9000b1f 	str	wzr, [x24, #8]
   897c8:	f9000b1f 	str	xzr, [x24, #16]
   897cc:	a94363f7 	ldp	x23, x24, [sp, #48]
   897d0:	a8c57bfd 	ldp	x29, x30, [sp], #80
   897d4:	d65f03c0 	ret
   897d8:	f9400b00 	ldr	x0, [x24, #16]
   897dc:	cb39c800 	sub	x0, x0, w25, sxtw #2
   897e0:	f9000b00 	str	x0, [x24, #16]
   897e4:	9100435a 	add	x26, x26, #0x10
   897e8:	b5fffc80 	cbnz	x0, 89778 <__sprint_r.part.0+0x38>
   897ec:	a94153f3 	ldp	x19, x20, [sp, #16]
   897f0:	52800000 	mov	w0, #0x0                   	// #0
   897f4:	a9425bf5 	ldp	x21, x22, [sp, #32]
   897f8:	a9446bf9 	ldp	x25, x26, [sp, #64]
   897fc:	17fffff2 	b	897c4 <__sprint_r.part.0+0x84>
   89800:	97ffe4fc 	bl	82bf0 <__sfvwrite_r>
   89804:	b9000b1f 	str	wzr, [x24, #8]
   89808:	f9000b1f 	str	xzr, [x24, #16]
   8980c:	a94363f7 	ldp	x23, x24, [sp, #48]
   89810:	a8c57bfd 	ldp	x29, x30, [sp], #80
   89814:	d65f03c0 	ret
	...

0000000000089820 <__sprint_r>:
   89820:	f9400844 	ldr	x4, [x2, #16]
   89824:	b4000044 	cbz	x4, 8982c <__sprint_r+0xc>
   89828:	17ffffc6 	b	89740 <__sprint_r.part.0>
   8982c:	52800000 	mov	w0, #0x0                   	// #0
   89830:	b900085f 	str	wzr, [x2, #8]
   89834:	d65f03c0 	ret
	...

0000000000089840 <_vfiprintf_r>:
   89840:	d10843ff 	sub	sp, sp, #0x210
   89844:	a9007bfd 	stp	x29, x30, [sp]
   89848:	910003fd 	mov	x29, sp
   8984c:	a90153f3 	stp	x19, x20, [sp, #16]
   89850:	aa0003f3 	mov	x19, x0
   89854:	aa0303f4 	mov	x20, x3
   89858:	a90363f7 	stp	x23, x24, [sp, #48]
   8985c:	a9400078 	ldp	x24, x0, [x3]
   89860:	a9025bf5 	stp	x21, x22, [sp, #32]
   89864:	aa0103f6 	mov	x22, x1
   89868:	b9401861 	ldr	w1, [x3, #24]
   8986c:	a9046bf9 	stp	x25, x26, [sp, #64]
   89870:	aa0203fa 	mov	x26, x2
   89874:	d2800102 	mov	x2, #0x8                   	// #8
   89878:	b90067e1 	str	w1, [sp, #100]
   8987c:	52800001 	mov	w1, #0x0                   	// #0
   89880:	f9003fe0 	str	x0, [sp, #120]
   89884:	9103e3e0 	add	x0, sp, #0xf8
   89888:	94000f4e 	bl	8d5c0 <memset>
   8988c:	b4000073 	cbz	x19, 89898 <_vfiprintf_r+0x58>
   89890:	f9402660 	ldr	x0, [x19, #72]
   89894:	b4009ba0 	cbz	x0, 8ac08 <_vfiprintf_r+0x13c8>
   89898:	b940b2c1 	ldr	w1, [x22, #176]
   8989c:	79c022c0 	ldrsh	w0, [x22, #16]
   898a0:	37000041 	tbnz	w1, #0, 898a8 <_vfiprintf_r+0x68>
   898a4:	364877a0 	tbz	w0, #9, 8a798 <_vfiprintf_r+0xf58>
   898a8:	376800c0 	tbnz	w0, #13, 898c0 <_vfiprintf_r+0x80>
   898ac:	b940b2c1 	ldr	w1, [x22, #176]
   898b0:	32130000 	orr	w0, w0, #0x2000
   898b4:	790022c0 	strh	w0, [x22, #16]
   898b8:	12127821 	and	w1, w1, #0xffffdfff
   898bc:	b900b2c1 	str	w1, [x22, #176]
   898c0:	36180520 	tbz	w0, #3, 89964 <_vfiprintf_r+0x124>
   898c4:	f9400ec1 	ldr	x1, [x22, #24]
   898c8:	b40004e1 	cbz	x1, 89964 <_vfiprintf_r+0x124>
   898cc:	52800341 	mov	w1, #0x1a                  	// #26
   898d0:	0a010001 	and	w1, w0, w1
   898d4:	7100283f 	cmp	w1, #0xa
   898d8:	54000580 	b.eq	89988 <_vfiprintf_r+0x148>  // b.none
   898dc:	910643f7 	add	x23, sp, #0x190
   898e0:	b0000075 	adrp	x21, 96000 <JIS_state_table+0x70>
   898e4:	913242b5 	add	x21, x21, #0xc90
   898e8:	a90573fb 	stp	x27, x28, [sp, #80]
   898ec:	aa1703fb 	mov	x27, x23
   898f0:	90000060 	adrp	x0, 95000 <pmu_event_descr+0x60>
   898f4:	911f8000 	add	x0, x0, #0x7e0
   898f8:	b90063ff 	str	wzr, [sp, #96]
   898fc:	f9003be0 	str	x0, [sp, #112]
   89900:	f90043ff 	str	xzr, [sp, #128]
   89904:	a909ffff 	stp	xzr, xzr, [sp, #152]
   89908:	f90057ff 	str	xzr, [sp, #168]
   8990c:	f9008bf7 	str	x23, [sp, #272]
   89910:	b9011bff 	str	wzr, [sp, #280]
   89914:	f90093ff 	str	xzr, [sp, #288]
   89918:	aa1a03fc 	mov	x28, x26
   8991c:	d503201f 	nop
   89920:	f94076b4 	ldr	x20, [x21, #232]
   89924:	94000cbb 	bl	8cc10 <__locale_mb_cur_max>
   89928:	9103e3e4 	add	x4, sp, #0xf8
   8992c:	93407c03 	sxtw	x3, w0
   89930:	aa1c03e2 	mov	x2, x28
   89934:	9103d3e1 	add	x1, sp, #0xf4
   89938:	aa1303e0 	mov	x0, x19
   8993c:	d63f0280 	blr	x20
   89940:	7100001f 	cmp	w0, #0x0
   89944:	340005a0 	cbz	w0, 899f8 <_vfiprintf_r+0x1b8>
   89948:	540004ab 	b.lt	899dc <_vfiprintf_r+0x19c>  // b.tstop
   8994c:	b940f7e1 	ldr	w1, [sp, #244]
   89950:	7100943f 	cmp	w1, #0x25
   89954:	54001be0 	b.eq	89cd0 <_vfiprintf_r+0x490>  // b.none
   89958:	93407c00 	sxtw	x0, w0
   8995c:	8b00039c 	add	x28, x28, x0
   89960:	17fffff0 	b	89920 <_vfiprintf_r+0xe0>
   89964:	aa1603e1 	mov	x1, x22
   89968:	aa1303e0 	mov	x0, x19
   8996c:	94000d4d 	bl	8cea0 <__swsetup_r>
   89970:	3500b960 	cbnz	w0, 8b09c <_vfiprintf_r+0x185c>
   89974:	79c022c0 	ldrsh	w0, [x22, #16]
   89978:	52800341 	mov	w1, #0x1a                  	// #26
   8997c:	0a010001 	and	w1, w0, w1
   89980:	7100283f 	cmp	w1, #0xa
   89984:	54fffac1 	b.ne	898dc <_vfiprintf_r+0x9c>  // b.any
   89988:	79c026c1 	ldrsh	w1, [x22, #18]
   8998c:	37fffa81 	tbnz	w1, #31, 898dc <_vfiprintf_r+0x9c>
   89990:	b940b2c1 	ldr	w1, [x22, #176]
   89994:	37000041 	tbnz	w1, #0, 8999c <_vfiprintf_r+0x15c>
   89998:	3648ae40 	tbz	w0, #9, 8af60 <_vfiprintf_r+0x1720>
   8999c:	ad400680 	ldp	q0, q1, [x20]
   899a0:	aa1a03e2 	mov	x2, x26
   899a4:	aa1603e1 	mov	x1, x22
   899a8:	910303e3 	add	x3, sp, #0xc0
   899ac:	aa1303e0 	mov	x0, x19
   899b0:	ad0607e0 	stp	q0, q1, [sp, #192]
   899b4:	940006bb 	bl	8b4a0 <__sbprintf>
   899b8:	b90063e0 	str	w0, [sp, #96]
   899bc:	a9407bfd 	ldp	x29, x30, [sp]
   899c0:	a94153f3 	ldp	x19, x20, [sp, #16]
   899c4:	a9425bf5 	ldp	x21, x22, [sp, #32]
   899c8:	a94363f7 	ldp	x23, x24, [sp, #48]
   899cc:	a9446bf9 	ldp	x25, x26, [sp, #64]
   899d0:	b94063e0 	ldr	w0, [sp, #96]
   899d4:	910843ff 	add	sp, sp, #0x210
   899d8:	d65f03c0 	ret
   899dc:	9103e3e0 	add	x0, sp, #0xf8
   899e0:	d2800102 	mov	x2, #0x8                   	// #8
   899e4:	52800001 	mov	w1, #0x0                   	// #0
   899e8:	94000ef6 	bl	8d5c0 <memset>
   899ec:	d2800020 	mov	x0, #0x1                   	// #1
   899f0:	8b00039c 	add	x28, x28, x0
   899f4:	17ffffcb 	b	89920 <_vfiprintf_r+0xe0>
   899f8:	2a0003f4 	mov	w20, w0
   899fc:	cb1a0380 	sub	x0, x28, x26
   89a00:	2a0003f9 	mov	w25, w0
   89a04:	34009280 	cbz	w0, 8ac54 <_vfiprintf_r+0x1414>
   89a08:	f94093e2 	ldr	x2, [sp, #288]
   89a0c:	93407f21 	sxtw	x1, w25
   89a10:	b9411be0 	ldr	w0, [sp, #280]
   89a14:	8b020022 	add	x2, x1, x2
   89a18:	a900077a 	stp	x26, x1, [x27]
   89a1c:	11000400 	add	w0, w0, #0x1
   89a20:	b9011be0 	str	w0, [sp, #280]
   89a24:	9100437b 	add	x27, x27, #0x10
   89a28:	f90093e2 	str	x2, [sp, #288]
   89a2c:	71001c1f 	cmp	w0, #0x7
   89a30:	5400010d 	b.le	89a50 <_vfiprintf_r+0x210>
   89a34:	b40066e2 	cbz	x2, 8a710 <_vfiprintf_r+0xed0>
   89a38:	910443e2 	add	x2, sp, #0x110
   89a3c:	aa1603e1 	mov	x1, x22
   89a40:	aa1303e0 	mov	x0, x19
   89a44:	97ffff3f 	bl	89740 <__sprint_r.part.0>
   89a48:	35000420 	cbnz	w0, 89acc <_vfiprintf_r+0x28c>
   89a4c:	aa1703fb 	mov	x27, x23
   89a50:	b94063e0 	ldr	w0, [sp, #96]
   89a54:	0b190000 	add	w0, w0, w25
   89a58:	b90063e0 	str	w0, [sp, #96]
   89a5c:	34008fd4 	cbz	w20, 8ac54 <_vfiprintf_r+0x1414>
   89a60:	39400780 	ldrb	w0, [x28, #1]
   89a64:	9100079a 	add	x26, x28, #0x1
   89a68:	12800003 	mov	w3, #0xffffffff            	// #-1
   89a6c:	52800008 	mov	w8, #0x0                   	// #0
   89a70:	2a0303fc 	mov	w28, w3
   89a74:	2a0803f9 	mov	w25, w8
   89a78:	52800014 	mov	w20, #0x0                   	// #0
   89a7c:	3903bfff 	strb	wzr, [sp, #239]
   89a80:	9100075a 	add	x26, x26, #0x1
   89a84:	51008001 	sub	w1, w0, #0x20
   89a88:	7101683f 	cmp	w1, #0x5a
   89a8c:	540003a8 	b.hi	89b00 <_vfiprintf_r+0x2c0>  // b.pmore
   89a90:	f9403be2 	ldr	x2, [sp, #112]
   89a94:	78615841 	ldrh	w1, [x2, w1, uxtw #1]
   89a98:	10000062 	adr	x2, 89aa4 <_vfiprintf_r+0x264>
   89a9c:	8b21a841 	add	x1, x2, w1, sxth #2
   89aa0:	d61f0020 	br	x1
   89aa4:	910443e2 	add	x2, sp, #0x110
   89aa8:	aa1603e1 	mov	x1, x22
   89aac:	aa1303e0 	mov	x0, x19
   89ab0:	97ffff24 	bl	89740 <__sprint_r.part.0>
   89ab4:	34000e60 	cbz	w0, 89c80 <_vfiprintf_r+0x440>
   89ab8:	f94037e0 	ldr	x0, [sp, #104]
   89abc:	b4000080 	cbz	x0, 89acc <_vfiprintf_r+0x28c>
   89ac0:	f94037e1 	ldr	x1, [sp, #104]
   89ac4:	aa1303e0 	mov	x0, x19
   89ac8:	9400173e 	bl	8f7c0 <_free_r>
   89acc:	79c022c0 	ldrsh	w0, [x22, #16]
   89ad0:	b940b2c1 	ldr	w1, [x22, #176]
   89ad4:	36003c01 	tbz	w1, #0, 8a254 <_vfiprintf_r+0xa14>
   89ad8:	a94573fb 	ldp	x27, x28, [sp, #80]
   89adc:	3730aec0 	tbnz	w0, #6, 8b0b4 <_vfiprintf_r+0x1874>
   89ae0:	a9407bfd 	ldp	x29, x30, [sp]
   89ae4:	a94153f3 	ldp	x19, x20, [sp, #16]
   89ae8:	a9425bf5 	ldp	x21, x22, [sp, #32]
   89aec:	a94363f7 	ldp	x23, x24, [sp, #48]
   89af0:	a9446bf9 	ldp	x25, x26, [sp, #64]
   89af4:	b94063e0 	ldr	w0, [sp, #96]
   89af8:	910843ff 	add	sp, sp, #0x210
   89afc:	d65f03c0 	ret
   89b00:	2a1903e8 	mov	w8, w25
   89b04:	34008a80 	cbz	w0, 8ac54 <_vfiprintf_r+0x1414>
   89b08:	52800024 	mov	w4, #0x1                   	// #1
   89b0c:	9104a3fc 	add	x28, sp, #0x128
   89b10:	2a0403f9 	mov	w25, w4
   89b14:	3903bfff 	strb	wzr, [sp, #239]
   89b18:	3904a3e0 	strb	w0, [sp, #296]
   89b1c:	52800003 	mov	w3, #0x0                   	// #0
   89b20:	f90037ff 	str	xzr, [sp, #104]
   89b24:	d503201f 	nop
   89b28:	b9411be1 	ldr	w1, [sp, #280]
   89b2c:	11000880 	add	w0, w4, #0x2
   89b30:	721f028e 	ands	w14, w20, #0x2
   89b34:	5280108c 	mov	w12, #0x84                  	// #132
   89b38:	11000422 	add	w2, w1, #0x1
   89b3c:	1a841004 	csel	w4, w0, w4, ne	// ne = any
   89b40:	f94093e0 	ldr	x0, [sp, #288]
   89b44:	6a0c028c 	ands	w12, w20, w12
   89b48:	2a0203eb 	mov	w11, w2
   89b4c:	54000081 	b.ne	89b5c <_vfiprintf_r+0x31c>  // b.any
   89b50:	4b04010a 	sub	w10, w8, w4
   89b54:	7100015f 	cmp	w10, #0x0
   89b58:	5400254c 	b.gt	8a000 <_vfiprintf_r+0x7c0>
   89b5c:	3943bfe2 	ldrb	w2, [sp, #239]
   89b60:	340001a2 	cbz	w2, 89b94 <_vfiprintf_r+0x354>
   89b64:	9103bfe1 	add	x1, sp, #0xef
   89b68:	91000400 	add	x0, x0, #0x1
   89b6c:	f9000361 	str	x1, [x27]
   89b70:	d2800021 	mov	x1, #0x1                   	// #1
   89b74:	f9000761 	str	x1, [x27, #8]
   89b78:	b9011beb 	str	w11, [sp, #280]
   89b7c:	f90093e0 	str	x0, [sp, #288]
   89b80:	71001d7f 	cmp	w11, #0x7
   89b84:	5400200c 	b.gt	89f84 <_vfiprintf_r+0x744>
   89b88:	2a0b03e1 	mov	w1, w11
   89b8c:	9100437b 	add	x27, x27, #0x10
   89b90:	1100056b 	add	w11, w11, #0x1
   89b94:	3400032e 	cbz	w14, 89bf8 <_vfiprintf_r+0x3b8>
   89b98:	91000800 	add	x0, x0, #0x2
   89b9c:	9103c3e2 	add	x2, sp, #0xf0
   89ba0:	d2800041 	mov	x1, #0x2                   	// #2
   89ba4:	a9000762 	stp	x2, x1, [x27]
   89ba8:	b9011beb 	str	w11, [sp, #280]
   89bac:	f90093e0 	str	x0, [sp, #288]
   89bb0:	71001d7f 	cmp	w11, #0x7
   89bb4:	540021ed 	b.le	89ff0 <_vfiprintf_r+0x7b0>
   89bb8:	b4005b80 	cbz	x0, 8a728 <_vfiprintf_r+0xee8>
   89bbc:	910443e2 	add	x2, sp, #0x110
   89bc0:	aa1603e1 	mov	x1, x22
   89bc4:	aa1303e0 	mov	x0, x19
   89bc8:	b9008be4 	str	w4, [sp, #136]
   89bcc:	b90093e8 	str	w8, [sp, #144]
   89bd0:	29160fec 	stp	w12, w3, [sp, #176]
   89bd4:	97fffedb 	bl	89740 <__sprint_r.part.0>
   89bd8:	35fff700 	cbnz	w0, 89ab8 <_vfiprintf_r+0x278>
   89bdc:	b9411be1 	ldr	w1, [sp, #280]
   89be0:	aa1703fb 	mov	x27, x23
   89be4:	f94093e0 	ldr	x0, [sp, #288]
   89be8:	1100042b 	add	w11, w1, #0x1
   89bec:	b9408be4 	ldr	w4, [sp, #136]
   89bf0:	b94093e8 	ldr	w8, [sp, #144]
   89bf4:	29560fec 	ldp	w12, w3, [sp, #176]
   89bf8:	7102019f 	cmp	w12, #0x80
   89bfc:	54000860 	b.eq	89d08 <_vfiprintf_r+0x4c8>  // b.none
   89c00:	4b190063 	sub	w3, w3, w25
   89c04:	7100007f 	cmp	w3, #0x0
   89c08:	5400124c 	b.gt	89e50 <_vfiprintf_r+0x610>
   89c0c:	93407f29 	sxtw	x9, w25
   89c10:	a900277c 	stp	x28, x9, [x27]
   89c14:	8b000120 	add	x0, x9, x0
   89c18:	b9011beb 	str	w11, [sp, #280]
   89c1c:	f90093e0 	str	x0, [sp, #288]
   89c20:	71001d7f 	cmp	w11, #0x7
   89c24:	540006ed 	b.le	89d00 <_vfiprintf_r+0x4c0>
   89c28:	b4002780 	cbz	x0, 8a118 <_vfiprintf_r+0x8d8>
   89c2c:	910443e2 	add	x2, sp, #0x110
   89c30:	aa1603e1 	mov	x1, x22
   89c34:	aa1303e0 	mov	x0, x19
   89c38:	b9008be4 	str	w4, [sp, #136]
   89c3c:	b900b3e8 	str	w8, [sp, #176]
   89c40:	97fffec0 	bl	89740 <__sprint_r.part.0>
   89c44:	35fff3a0 	cbnz	w0, 89ab8 <_vfiprintf_r+0x278>
   89c48:	f94093e0 	ldr	x0, [sp, #288]
   89c4c:	aa1703fb 	mov	x27, x23
   89c50:	b9408be4 	ldr	w4, [sp, #136]
   89c54:	b940b3e8 	ldr	w8, [sp, #176]
   89c58:	36100094 	tbz	w20, #2, 89c68 <_vfiprintf_r+0x428>
   89c5c:	4b040114 	sub	w20, w8, w4
   89c60:	7100029f 	cmp	w20, #0x0
   89c64:	5400266c 	b.gt	8a130 <_vfiprintf_r+0x8f0>
   89c68:	b94063e1 	ldr	w1, [sp, #96]
   89c6c:	6b04011f 	cmp	w8, w4
   89c70:	1a84a104 	csel	w4, w8, w4, ge	// ge = tcont
   89c74:	0b040021 	add	w1, w1, w4
   89c78:	b90063e1 	str	w1, [sp, #96]
   89c7c:	b5fff140 	cbnz	x0, 89aa4 <_vfiprintf_r+0x264>
   89c80:	f94037e0 	ldr	x0, [sp, #104]
   89c84:	b9011bff 	str	wzr, [sp, #280]
   89c88:	b4000080 	cbz	x0, 89c98 <_vfiprintf_r+0x458>
   89c8c:	aa0003e1 	mov	x1, x0
   89c90:	aa1303e0 	mov	x0, x19
   89c94:	940016cb 	bl	8f7c0 <_free_r>
   89c98:	aa1703fb 	mov	x27, x23
   89c9c:	17ffff1f 	b	89918 <_vfiprintf_r+0xd8>
   89ca0:	5100c001 	sub	w1, w0, #0x30
   89ca4:	52800019 	mov	w25, #0x0                   	// #0
   89ca8:	38401740 	ldrb	w0, [x26], #1
   89cac:	0b190b28 	add	w8, w25, w25, lsl #2
   89cb0:	0b080439 	add	w25, w1, w8, lsl #1
   89cb4:	5100c001 	sub	w1, w0, #0x30
   89cb8:	7100243f 	cmp	w1, #0x9
   89cbc:	54ffff69 	b.ls	89ca8 <_vfiprintf_r+0x468>  // b.plast
   89cc0:	17ffff71 	b	89a84 <_vfiprintf_r+0x244>
   89cc4:	39400340 	ldrb	w0, [x26]
   89cc8:	321c0294 	orr	w20, w20, #0x10
   89ccc:	17ffff6d 	b	89a80 <_vfiprintf_r+0x240>
   89cd0:	2a0003f4 	mov	w20, w0
   89cd4:	cb1a0380 	sub	x0, x28, x26
   89cd8:	2a0003f9 	mov	w25, w0
   89cdc:	34ffec20 	cbz	w0, 89a60 <_vfiprintf_r+0x220>
   89ce0:	17ffff4a 	b	89a08 <_vfiprintf_r+0x1c8>
   89ce4:	aa1703fb 	mov	x27, x23
   89ce8:	93407f20 	sxtw	x0, w25
   89cec:	52800021 	mov	w1, #0x1                   	// #1
   89cf0:	b9011be1 	str	w1, [sp, #280]
   89cf4:	f90093e0 	str	x0, [sp, #288]
   89cf8:	a91903fc 	stp	x28, x0, [sp, #400]
   89cfc:	d503201f 	nop
   89d00:	9100437b 	add	x27, x27, #0x10
   89d04:	17ffffd5 	b	89c58 <_vfiprintf_r+0x418>
   89d08:	4b04010c 	sub	w12, w8, w4
   89d0c:	7100019f 	cmp	w12, #0x0
   89d10:	54fff78d 	b.le	89c00 <_vfiprintf_r+0x3c0>
   89d14:	7100419f 	cmp	w12, #0x10
   89d18:	54009bad 	b.le	8b08c <_vfiprintf_r+0x184c>
   89d1c:	aa1a03e2 	mov	x2, x26
   89d20:	9000006a 	adrp	x10, 95000 <pmu_event_descr+0x60>
   89d24:	9122814a 	add	x10, x10, #0x8a0
   89d28:	2a1903fa 	mov	w26, w25
   89d2c:	d280020b 	mov	x11, #0x10                  	// #16
   89d30:	2a0303f9 	mov	w25, w3
   89d34:	aa1b03e3 	mov	x3, x27
   89d38:	aa0203fb 	mov	x27, x2
   89d3c:	f90047f8 	str	x24, [sp, #136]
   89d40:	aa0a03f8 	mov	x24, x10
   89d44:	b90093f4 	str	w20, [sp, #144]
   89d48:	2a0c03f4 	mov	w20, w12
   89d4c:	291623e4 	stp	w4, w8, [sp, #176]
   89d50:	14000007 	b	89d6c <_vfiprintf_r+0x52c>
   89d54:	1100082d 	add	w13, w1, #0x2
   89d58:	91004063 	add	x3, x3, #0x10
   89d5c:	2a0203e1 	mov	w1, w2
   89d60:	51004294 	sub	w20, w20, #0x10
   89d64:	7100429f 	cmp	w20, #0x10
   89d68:	540002cd 	b.le	89dc0 <_vfiprintf_r+0x580>
   89d6c:	91004000 	add	x0, x0, #0x10
   89d70:	11000422 	add	w2, w1, #0x1
   89d74:	a9002c78 	stp	x24, x11, [x3]
   89d78:	b9011be2 	str	w2, [sp, #280]
   89d7c:	f90093e0 	str	x0, [sp, #288]
   89d80:	71001c5f 	cmp	w2, #0x7
   89d84:	54fffe8d 	b.le	89d54 <_vfiprintf_r+0x514>
   89d88:	b4004aa0 	cbz	x0, 8a6dc <_vfiprintf_r+0xe9c>
   89d8c:	910443e2 	add	x2, sp, #0x110
   89d90:	aa1603e1 	mov	x1, x22
   89d94:	aa1303e0 	mov	x0, x19
   89d98:	97fffe6a 	bl	89740 <__sprint_r.part.0>
   89d9c:	35ffe8e0 	cbnz	w0, 89ab8 <_vfiprintf_r+0x278>
   89da0:	b9411be1 	ldr	w1, [sp, #280]
   89da4:	51004294 	sub	w20, w20, #0x10
   89da8:	f94093e0 	ldr	x0, [sp, #288]
   89dac:	aa1703e3 	mov	x3, x23
   89db0:	1100042d 	add	w13, w1, #0x1
   89db4:	d280020b 	mov	x11, #0x10                  	// #16
   89db8:	7100429f 	cmp	w20, #0x10
   89dbc:	54fffd8c 	b.gt	89d6c <_vfiprintf_r+0x52c>
   89dc0:	aa1b03e1 	mov	x1, x27
   89dc4:	2a1403ec 	mov	w12, w20
   89dc8:	aa1803ea 	mov	x10, x24
   89dcc:	b94093f4 	ldr	w20, [sp, #144]
   89dd0:	f94047f8 	ldr	x24, [sp, #136]
   89dd4:	aa0303fb 	mov	x27, x3
   89dd8:	295623e4 	ldp	w4, w8, [sp, #176]
   89ddc:	2a1903e3 	mov	w3, w25
   89de0:	2a1a03f9 	mov	w25, w26
   89de4:	aa0103fa 	mov	x26, x1
   89de8:	93407d81 	sxtw	x1, w12
   89dec:	a900076a 	stp	x10, x1, [x27]
   89df0:	8b010000 	add	x0, x0, x1
   89df4:	b9011bed 	str	w13, [sp, #280]
   89df8:	f90093e0 	str	x0, [sp, #288]
   89dfc:	71001dbf 	cmp	w13, #0x7
   89e00:	54004d4d 	b.le	8a7a8 <_vfiprintf_r+0xf68>
   89e04:	b4007f20 	cbz	x0, 8ade8 <_vfiprintf_r+0x15a8>
   89e08:	910443e2 	add	x2, sp, #0x110
   89e0c:	aa1603e1 	mov	x1, x22
   89e10:	aa1303e0 	mov	x0, x19
   89e14:	b9008be4 	str	w4, [sp, #136]
   89e18:	b90093e3 	str	w3, [sp, #144]
   89e1c:	b900b3e8 	str	w8, [sp, #176]
   89e20:	97fffe48 	bl	89740 <__sprint_r.part.0>
   89e24:	35ffe4a0 	cbnz	w0, 89ab8 <_vfiprintf_r+0x278>
   89e28:	b94093e3 	ldr	w3, [sp, #144]
   89e2c:	aa1703fb 	mov	x27, x23
   89e30:	b9411be1 	ldr	w1, [sp, #280]
   89e34:	4b190063 	sub	w3, w3, w25
   89e38:	b9408be4 	ldr	w4, [sp, #136]
   89e3c:	f94093e0 	ldr	x0, [sp, #288]
   89e40:	1100042b 	add	w11, w1, #0x1
   89e44:	b940b3e8 	ldr	w8, [sp, #176]
   89e48:	7100007f 	cmp	w3, #0x0
   89e4c:	54ffee0d 	b.le	89c0c <_vfiprintf_r+0x3cc>
   89e50:	9000006a 	adrp	x10, 95000 <pmu_event_descr+0x60>
   89e54:	9122814a 	add	x10, x10, #0x8a0
   89e58:	7100407f 	cmp	w3, #0x10
   89e5c:	5400060d 	b.le	89f1c <_vfiprintf_r+0x6dc>
   89e60:	d280020c 	mov	x12, #0x10                  	// #16
   89e64:	f90047f8 	str	x24, [sp, #136]
   89e68:	aa0a03f8 	mov	x24, x10
   89e6c:	b90093f4 	str	w20, [sp, #144]
   89e70:	2a0303f4 	mov	w20, w3
   89e74:	b900b3e4 	str	w4, [sp, #176]
   89e78:	aa1b03e4 	mov	x4, x27
   89e7c:	aa1a03fb 	mov	x27, x26
   89e80:	2a1903fa 	mov	w26, w25
   89e84:	2a0803f9 	mov	w25, w8
   89e88:	14000007 	b	89ea4 <_vfiprintf_r+0x664>
   89e8c:	1100082b 	add	w11, w1, #0x2
   89e90:	91004084 	add	x4, x4, #0x10
   89e94:	2a0203e1 	mov	w1, w2
   89e98:	51004294 	sub	w20, w20, #0x10
   89e9c:	7100429f 	cmp	w20, #0x10
   89ea0:	540002cd 	b.le	89ef8 <_vfiprintf_r+0x6b8>
   89ea4:	91004000 	add	x0, x0, #0x10
   89ea8:	11000422 	add	w2, w1, #0x1
   89eac:	a9003098 	stp	x24, x12, [x4]
   89eb0:	b9011be2 	str	w2, [sp, #280]
   89eb4:	f90093e0 	str	x0, [sp, #288]
   89eb8:	71001c5f 	cmp	w2, #0x7
   89ebc:	54fffe8d 	b.le	89e8c <_vfiprintf_r+0x64c>
   89ec0:	b40005a0 	cbz	x0, 89f74 <_vfiprintf_r+0x734>
   89ec4:	910443e2 	add	x2, sp, #0x110
   89ec8:	aa1603e1 	mov	x1, x22
   89ecc:	aa1303e0 	mov	x0, x19
   89ed0:	97fffe1c 	bl	89740 <__sprint_r.part.0>
   89ed4:	35ffdf20 	cbnz	w0, 89ab8 <_vfiprintf_r+0x278>
   89ed8:	b9411be1 	ldr	w1, [sp, #280]
   89edc:	51004294 	sub	w20, w20, #0x10
   89ee0:	f94093e0 	ldr	x0, [sp, #288]
   89ee4:	aa1703e4 	mov	x4, x23
   89ee8:	1100042b 	add	w11, w1, #0x1
   89eec:	d280020c 	mov	x12, #0x10                  	// #16
   89ef0:	7100429f 	cmp	w20, #0x10
   89ef4:	54fffd8c 	b.gt	89ea4 <_vfiprintf_r+0x664>
   89ef8:	2a1903e8 	mov	w8, w25
   89efc:	2a1403e3 	mov	w3, w20
   89f00:	2a1a03f9 	mov	w25, w26
   89f04:	aa1803ea 	mov	x10, x24
   89f08:	f94047f8 	ldr	x24, [sp, #136]
   89f0c:	aa1b03fa 	mov	x26, x27
   89f10:	b94093f4 	ldr	w20, [sp, #144]
   89f14:	aa0403fb 	mov	x27, x4
   89f18:	b940b3e4 	ldr	w4, [sp, #176]
   89f1c:	93407c63 	sxtw	x3, w3
   89f20:	a9000f6a 	stp	x10, x3, [x27]
   89f24:	8b030000 	add	x0, x0, x3
   89f28:	b9011beb 	str	w11, [sp, #280]
   89f2c:	f90093e0 	str	x0, [sp, #288]
   89f30:	71001d7f 	cmp	w11, #0x7
   89f34:	540018ad 	b.le	8a248 <_vfiprintf_r+0xa08>
   89f38:	b4ffed60 	cbz	x0, 89ce4 <_vfiprintf_r+0x4a4>
   89f3c:	910443e2 	add	x2, sp, #0x110
   89f40:	aa1603e1 	mov	x1, x22
   89f44:	aa1303e0 	mov	x0, x19
   89f48:	b9008be4 	str	w4, [sp, #136]
   89f4c:	b900b3e8 	str	w8, [sp, #176]
   89f50:	97fffdfc 	bl	89740 <__sprint_r.part.0>
   89f54:	35ffdb20 	cbnz	w0, 89ab8 <_vfiprintf_r+0x278>
   89f58:	b9411beb 	ldr	w11, [sp, #280]
   89f5c:	aa1703fb 	mov	x27, x23
   89f60:	f94093e0 	ldr	x0, [sp, #288]
   89f64:	1100056b 	add	w11, w11, #0x1
   89f68:	b9408be4 	ldr	w4, [sp, #136]
   89f6c:	b940b3e8 	ldr	w8, [sp, #176]
   89f70:	17ffff27 	b	89c0c <_vfiprintf_r+0x3cc>
   89f74:	aa1703e4 	mov	x4, x23
   89f78:	5280002b 	mov	w11, #0x1                   	// #1
   89f7c:	52800001 	mov	w1, #0x0                   	// #0
   89f80:	17ffffc6 	b	89e98 <_vfiprintf_r+0x658>
   89f84:	b4000260 	cbz	x0, 89fd0 <_vfiprintf_r+0x790>
   89f88:	910443e2 	add	x2, sp, #0x110
   89f8c:	aa1603e1 	mov	x1, x22
   89f90:	aa1303e0 	mov	x0, x19
   89f94:	b9008be4 	str	w4, [sp, #136]
   89f98:	b90093ec 	str	w12, [sp, #144]
   89f9c:	291623ee 	stp	w14, w8, [sp, #176]
   89fa0:	b900bbe3 	str	w3, [sp, #184]
   89fa4:	97fffde7 	bl	89740 <__sprint_r.part.0>
   89fa8:	35ffd880 	cbnz	w0, 89ab8 <_vfiprintf_r+0x278>
   89fac:	b9411be1 	ldr	w1, [sp, #280]
   89fb0:	aa1703fb 	mov	x27, x23
   89fb4:	f94093e0 	ldr	x0, [sp, #288]
   89fb8:	1100042b 	add	w11, w1, #0x1
   89fbc:	b9408be4 	ldr	w4, [sp, #136]
   89fc0:	b94093ec 	ldr	w12, [sp, #144]
   89fc4:	295623ee 	ldp	w14, w8, [sp, #176]
   89fc8:	b940bbe3 	ldr	w3, [sp, #184]
   89fcc:	17fffef2 	b	89b94 <_vfiprintf_r+0x354>
   89fd0:	3400426e 	cbz	w14, 8a81c <_vfiprintf_r+0xfdc>
   89fd4:	9103c3e0 	add	x0, sp, #0xf0
   89fd8:	d2800041 	mov	x1, #0x2                   	// #2
   89fdc:	aa1703fb 	mov	x27, x23
   89fe0:	a91907e0 	stp	x0, x1, [sp, #400]
   89fe4:	aa0103e0 	mov	x0, x1
   89fe8:	5280002b 	mov	w11, #0x1                   	// #1
   89fec:	d503201f 	nop
   89ff0:	2a0b03e1 	mov	w1, w11
   89ff4:	9100437b 	add	x27, x27, #0x10
   89ff8:	1100056b 	add	w11, w11, #0x1
   89ffc:	17fffeff 	b	89bf8 <_vfiprintf_r+0x3b8>
   8a000:	7100415f 	cmp	w10, #0x10
   8a004:	540081ed 	b.le	8b040 <_vfiprintf_r+0x1800>
   8a008:	f000004b 	adrp	x11, 95000 <pmu_event_descr+0x60>
   8a00c:	9122c16b 	add	x11, x11, #0x8b0
   8a010:	291633e4 	stp	w4, w12, [sp, #176]
   8a014:	aa1a03e4 	mov	x4, x26
   8a018:	d280020d 	mov	x13, #0x10                  	// #16
   8a01c:	2a1903fa 	mov	w26, w25
   8a020:	2a0303f9 	mov	w25, w3
   8a024:	aa1b03e3 	mov	x3, x27
   8a028:	aa0403fb 	mov	x27, x4
   8a02c:	f90047f8 	str	x24, [sp, #136]
   8a030:	aa0b03f8 	mov	x24, x11
   8a034:	b90093ee 	str	w14, [sp, #144]
   8a038:	291723f4 	stp	w20, w8, [sp, #184]
   8a03c:	2a0a03f4 	mov	w20, w10
   8a040:	14000008 	b	8a060 <_vfiprintf_r+0x820>
   8a044:	1100082f 	add	w15, w1, #0x2
   8a048:	91004063 	add	x3, x3, #0x10
   8a04c:	2a0203e1 	mov	w1, w2
   8a050:	51004294 	sub	w20, w20, #0x10
   8a054:	7100429f 	cmp	w20, #0x10
   8a058:	540002cd 	b.le	8a0b0 <_vfiprintf_r+0x870>
   8a05c:	11000422 	add	w2, w1, #0x1
   8a060:	91004000 	add	x0, x0, #0x10
   8a064:	a9003478 	stp	x24, x13, [x3]
   8a068:	b9011be2 	str	w2, [sp, #280]
   8a06c:	f90093e0 	str	x0, [sp, #288]
   8a070:	71001c5f 	cmp	w2, #0x7
   8a074:	54fffe8d 	b.le	8a044 <_vfiprintf_r+0x804>
   8a078:	b4000480 	cbz	x0, 8a108 <_vfiprintf_r+0x8c8>
   8a07c:	910443e2 	add	x2, sp, #0x110
   8a080:	aa1603e1 	mov	x1, x22
   8a084:	aa1303e0 	mov	x0, x19
   8a088:	97fffdae 	bl	89740 <__sprint_r.part.0>
   8a08c:	35ffd160 	cbnz	w0, 89ab8 <_vfiprintf_r+0x278>
   8a090:	b9411be1 	ldr	w1, [sp, #280]
   8a094:	51004294 	sub	w20, w20, #0x10
   8a098:	f94093e0 	ldr	x0, [sp, #288]
   8a09c:	aa1703e3 	mov	x3, x23
   8a0a0:	1100042f 	add	w15, w1, #0x1
   8a0a4:	d280020d 	mov	x13, #0x10                  	// #16
   8a0a8:	7100429f 	cmp	w20, #0x10
   8a0ac:	54fffd8c 	b.gt	8a05c <_vfiprintf_r+0x81c>
   8a0b0:	aa1b03e1 	mov	x1, x27
   8a0b4:	2a1403ea 	mov	w10, w20
   8a0b8:	aa1803eb 	mov	x11, x24
   8a0bc:	b94093ee 	ldr	w14, [sp, #144]
   8a0c0:	f94047f8 	ldr	x24, [sp, #136]
   8a0c4:	aa0303fb 	mov	x27, x3
   8a0c8:	295633e4 	ldp	w4, w12, [sp, #176]
   8a0cc:	2a1903e3 	mov	w3, w25
   8a0d0:	295723f4 	ldp	w20, w8, [sp, #184]
   8a0d4:	2a1a03f9 	mov	w25, w26
   8a0d8:	aa0103fa 	mov	x26, x1
   8a0dc:	93407d4a 	sxtw	x10, w10
   8a0e0:	a9002b6b 	stp	x11, x10, [x27]
   8a0e4:	8b0a0000 	add	x0, x0, x10
   8a0e8:	b9011bef 	str	w15, [sp, #280]
   8a0ec:	f90093e0 	str	x0, [sp, #288]
   8a0f0:	71001dff 	cmp	w15, #0x7
   8a0f4:	540032cc 	b.gt	8a74c <_vfiprintf_r+0xf0c>
   8a0f8:	9100437b 	add	x27, x27, #0x10
   8a0fc:	110005eb 	add	w11, w15, #0x1
   8a100:	2a0f03e1 	mov	w1, w15
   8a104:	17fffe96 	b	89b5c <_vfiprintf_r+0x31c>
   8a108:	aa1703e3 	mov	x3, x23
   8a10c:	52800001 	mov	w1, #0x0                   	// #0
   8a110:	5280002f 	mov	w15, #0x1                   	// #1
   8a114:	17ffffcf 	b	8a050 <_vfiprintf_r+0x810>
   8a118:	b9011bff 	str	wzr, [sp, #280]
   8a11c:	361008b4 	tbz	w20, #2, 8a230 <_vfiprintf_r+0x9f0>
   8a120:	4b040114 	sub	w20, w8, w4
   8a124:	7100029f 	cmp	w20, #0x0
   8a128:	5400084d 	b.le	8a230 <_vfiprintf_r+0x9f0>
   8a12c:	aa1703fb 	mov	x27, x23
   8a130:	b9411be2 	ldr	w2, [sp, #280]
   8a134:	7100429f 	cmp	w20, #0x10
   8a138:	540078cd 	b.le	8b050 <_vfiprintf_r+0x1810>
   8a13c:	f000004b 	adrp	x11, 95000 <pmu_event_descr+0x60>
   8a140:	9122c16b 	add	x11, x11, #0x8b0
   8a144:	2a0403fc 	mov	w28, w4
   8a148:	d2800219 	mov	x25, #0x10                  	// #16
   8a14c:	f90047f8 	str	x24, [sp, #136]
   8a150:	aa0b03f8 	mov	x24, x11
   8a154:	b900b3e8 	str	w8, [sp, #176]
   8a158:	14000007 	b	8a174 <_vfiprintf_r+0x934>
   8a15c:	11000846 	add	w6, w2, #0x2
   8a160:	9100437b 	add	x27, x27, #0x10
   8a164:	2a0103e2 	mov	w2, w1
   8a168:	51004294 	sub	w20, w20, #0x10
   8a16c:	7100429f 	cmp	w20, #0x10
   8a170:	540002ad 	b.le	8a1c4 <_vfiprintf_r+0x984>
   8a174:	91004000 	add	x0, x0, #0x10
   8a178:	11000441 	add	w1, w2, #0x1
   8a17c:	a9006778 	stp	x24, x25, [x27]
   8a180:	b9011be1 	str	w1, [sp, #280]
   8a184:	f90093e0 	str	x0, [sp, #288]
   8a188:	71001c3f 	cmp	w1, #0x7
   8a18c:	54fffe8d 	b.le	8a15c <_vfiprintf_r+0x91c>
   8a190:	b4000480 	cbz	x0, 8a220 <_vfiprintf_r+0x9e0>
   8a194:	910443e2 	add	x2, sp, #0x110
   8a198:	aa1603e1 	mov	x1, x22
   8a19c:	aa1303e0 	mov	x0, x19
   8a1a0:	97fffd68 	bl	89740 <__sprint_r.part.0>
   8a1a4:	35ffc8a0 	cbnz	w0, 89ab8 <_vfiprintf_r+0x278>
   8a1a8:	b9411be2 	ldr	w2, [sp, #280]
   8a1ac:	51004294 	sub	w20, w20, #0x10
   8a1b0:	f94093e0 	ldr	x0, [sp, #288]
   8a1b4:	aa1703fb 	mov	x27, x23
   8a1b8:	11000446 	add	w6, w2, #0x1
   8a1bc:	7100429f 	cmp	w20, #0x10
   8a1c0:	54fffdac 	b.gt	8a174 <_vfiprintf_r+0x934>
   8a1c4:	aa1803eb 	mov	x11, x24
   8a1c8:	b940b3e8 	ldr	w8, [sp, #176]
   8a1cc:	f94047f8 	ldr	x24, [sp, #136]
   8a1d0:	2a1c03e4 	mov	w4, w28
   8a1d4:	93407e83 	sxtw	x3, w20
   8a1d8:	a9000f6b 	stp	x11, x3, [x27]
   8a1dc:	8b030000 	add	x0, x0, x3
   8a1e0:	b9011be6 	str	w6, [sp, #280]
   8a1e4:	f90093e0 	str	x0, [sp, #288]
   8a1e8:	71001cdf 	cmp	w6, #0x7
   8a1ec:	54ffd3ed 	b.le	89c68 <_vfiprintf_r+0x428>
   8a1f0:	b4000200 	cbz	x0, 8a230 <_vfiprintf_r+0x9f0>
   8a1f4:	910443e2 	add	x2, sp, #0x110
   8a1f8:	aa1603e1 	mov	x1, x22
   8a1fc:	aa1303e0 	mov	x0, x19
   8a200:	b9008be4 	str	w4, [sp, #136]
   8a204:	b900b3e8 	str	w8, [sp, #176]
   8a208:	97fffd4e 	bl	89740 <__sprint_r.part.0>
   8a20c:	35ffc560 	cbnz	w0, 89ab8 <_vfiprintf_r+0x278>
   8a210:	f94093e0 	ldr	x0, [sp, #288]
   8a214:	b9408be4 	ldr	w4, [sp, #136]
   8a218:	b940b3e8 	ldr	w8, [sp, #176]
   8a21c:	17fffe93 	b	89c68 <_vfiprintf_r+0x428>
   8a220:	aa1703fb 	mov	x27, x23
   8a224:	52800026 	mov	w6, #0x1                   	// #1
   8a228:	52800002 	mov	w2, #0x0                   	// #0
   8a22c:	17ffffcf 	b	8a168 <_vfiprintf_r+0x928>
   8a230:	b94063e0 	ldr	w0, [sp, #96]
   8a234:	6b04011f 	cmp	w8, w4
   8a238:	1a84a104 	csel	w4, w8, w4, ge	// ge = tcont
   8a23c:	0b040000 	add	w0, w0, w4
   8a240:	b90063e0 	str	w0, [sp, #96]
   8a244:	17fffe8f 	b	89c80 <_vfiprintf_r+0x440>
   8a248:	9100437b 	add	x27, x27, #0x10
   8a24c:	1100056b 	add	w11, w11, #0x1
   8a250:	17fffe6f 	b	89c0c <_vfiprintf_r+0x3cc>
   8a254:	374fc420 	tbnz	w0, #9, 89ad8 <_vfiprintf_r+0x298>
   8a258:	f94052c0 	ldr	x0, [x22, #160]
   8a25c:	94000745 	bl	8bf70 <__retarget_lock_release_recursive>
   8a260:	79c022c0 	ldrsh	w0, [x22, #16]
   8a264:	17fffe1d 	b	89ad8 <_vfiprintf_r+0x298>
   8a268:	b94067e1 	ldr	w1, [sp, #100]
   8a26c:	2a1903e8 	mov	w8, w25
   8a270:	2a1c03e3 	mov	w3, w28
   8a274:	37f82f21 	tbnz	w1, #31, 8a858 <_vfiprintf_r+0x1018>
   8a278:	91003f01 	add	x1, x24, #0xf
   8a27c:	927df021 	and	x1, x1, #0xfffffffffffffff8
   8a280:	f90047e1 	str	x1, [sp, #136]
   8a284:	f940031c 	ldr	x28, [x24]
   8a288:	3903bfff 	strb	wzr, [sp, #239]
   8a28c:	b4004d5c 	cbz	x28, 8ac34 <_vfiprintf_r+0x13f4>
   8a290:	71014c1f 	cmp	w0, #0x53
   8a294:	54003e20 	b.eq	8aa58 <_vfiprintf_r+0x1218>  // b.none
   8a298:	37203e14 	tbnz	w20, #4, 8aa58 <_vfiprintf_r+0x1218>
   8a29c:	3100047f 	cmn	w3, #0x1
   8a2a0:	54006ba0 	b.eq	8b014 <_vfiprintf_r+0x17d4>  // b.none
   8a2a4:	93407c62 	sxtw	x2, w3
   8a2a8:	aa1c03e0 	mov	x0, x28
   8a2ac:	52800001 	mov	w1, #0x0                   	// #0
   8a2b0:	b90093e8 	str	w8, [sp, #144]
   8a2b4:	b900b3e3 	str	w3, [sp, #176]
   8a2b8:	94000ac2 	bl	8cdc0 <memchr>
   8a2bc:	f90037e0 	str	x0, [sp, #104]
   8a2c0:	b94093e8 	ldr	w8, [sp, #144]
   8a2c4:	b940b3e3 	ldr	w3, [sp, #176]
   8a2c8:	b4006520 	cbz	x0, 8af6c <_vfiprintf_r+0x172c>
   8a2cc:	cb1c0004 	sub	x4, x0, x28
   8a2d0:	52800003 	mov	w3, #0x0                   	// #0
   8a2d4:	7100009f 	cmp	w4, #0x0
   8a2d8:	2a0403f9 	mov	w25, w4
   8a2dc:	f94047f8 	ldr	x24, [sp, #136]
   8a2e0:	1a9fa084 	csel	w4, w4, wzr, ge	// ge = tcont
   8a2e4:	f90037ff 	str	xzr, [sp, #104]
   8a2e8:	14000081 	b	8a4ec <_vfiprintf_r+0xcac>
   8a2ec:	2a1903e8 	mov	w8, w25
   8a2f0:	71010c1f 	cmp	w0, #0x43
   8a2f4:	54000040 	b.eq	8a2fc <_vfiprintf_r+0xabc>  // b.none
   8a2f8:	36202d54 	tbz	w20, #4, 8a8a0 <_vfiprintf_r+0x1060>
   8a2fc:	910423e0 	add	x0, sp, #0x108
   8a300:	d2800102 	mov	x2, #0x8                   	// #8
   8a304:	52800001 	mov	w1, #0x0                   	// #0
   8a308:	b9006be8 	str	w8, [sp, #104]
   8a30c:	94000cad 	bl	8d5c0 <memset>
   8a310:	294ca3e0 	ldp	w0, w8, [sp, #100]
   8a314:	37f850e0 	tbnz	w0, #31, 8ad30 <_vfiprintf_r+0x14f0>
   8a318:	91002f01 	add	x1, x24, #0xb
   8a31c:	aa1803e0 	mov	x0, x24
   8a320:	927df038 	and	x24, x1, #0xfffffffffffffff8
   8a324:	b9400002 	ldr	w2, [x0]
   8a328:	9104a3fc 	add	x28, sp, #0x128
   8a32c:	910423e3 	add	x3, sp, #0x108
   8a330:	aa1c03e1 	mov	x1, x28
   8a334:	aa1303e0 	mov	x0, x19
   8a338:	b9006be8 	str	w8, [sp, #104]
   8a33c:	9400069d 	bl	8bdb0 <_wcrtomb_r>
   8a340:	2a0003f9 	mov	w25, w0
   8a344:	b9406be8 	ldr	w8, [sp, #104]
   8a348:	3100041f 	cmn	w0, #0x1
   8a34c:	540082e0 	b.eq	8b3a8 <_vfiprintf_r+0x1b68>  // b.none
   8a350:	7100001f 	cmp	w0, #0x0
   8a354:	3903bfff 	strb	wzr, [sp, #239]
   8a358:	1a9fa004 	csel	w4, w0, wzr, ge	// ge = tcont
   8a35c:	17fffdf0 	b	89b1c <_vfiprintf_r+0x2dc>
   8a360:	4b1903f9 	neg	w25, w25
   8a364:	aa0003f8 	mov	x24, x0
   8a368:	39400340 	ldrb	w0, [x26]
   8a36c:	321e0294 	orr	w20, w20, #0x4
   8a370:	17fffdc4 	b	89a80 <_vfiprintf_r+0x240>
   8a374:	52800560 	mov	w0, #0x2b                  	// #43
   8a378:	3903bfe0 	strb	w0, [sp, #239]
   8a37c:	39400340 	ldrb	w0, [x26]
   8a380:	17fffdc0 	b	89a80 <_vfiprintf_r+0x240>
   8a384:	39400340 	ldrb	w0, [x26]
   8a388:	32190294 	orr	w20, w20, #0x80
   8a38c:	17fffdbd 	b	89a80 <_vfiprintf_r+0x240>
   8a390:	aa1a03e2 	mov	x2, x26
   8a394:	38401440 	ldrb	w0, [x2], #1
   8a398:	7100a81f 	cmp	w0, #0x2a
   8a39c:	54007b00 	b.eq	8b2fc <_vfiprintf_r+0x1abc>  // b.none
   8a3a0:	5100c001 	sub	w1, w0, #0x30
   8a3a4:	aa0203fa 	mov	x26, x2
   8a3a8:	5280001c 	mov	w28, #0x0                   	// #0
   8a3ac:	7100243f 	cmp	w1, #0x9
   8a3b0:	54ffb6a8 	b.hi	89a84 <_vfiprintf_r+0x244>  // b.pmore
   8a3b4:	d503201f 	nop
   8a3b8:	38401740 	ldrb	w0, [x26], #1
   8a3bc:	0b1c0b83 	add	w3, w28, w28, lsl #2
   8a3c0:	0b03043c 	add	w28, w1, w3, lsl #1
   8a3c4:	5100c001 	sub	w1, w0, #0x30
   8a3c8:	7100243f 	cmp	w1, #0x9
   8a3cc:	54ffff69 	b.ls	8a3b8 <_vfiprintf_r+0xb78>  // b.plast
   8a3d0:	17fffdad 	b	89a84 <_vfiprintf_r+0x244>
   8a3d4:	b94067e0 	ldr	w0, [sp, #100]
   8a3d8:	37f82300 	tbnz	w0, #31, 8a838 <_vfiprintf_r+0xff8>
   8a3dc:	91002f00 	add	x0, x24, #0xb
   8a3e0:	927df000 	and	x0, x0, #0xfffffffffffffff8
   8a3e4:	b9400319 	ldr	w25, [x24]
   8a3e8:	37fffbd9 	tbnz	w25, #31, 8a360 <_vfiprintf_r+0xb20>
   8a3ec:	aa0003f8 	mov	x24, x0
   8a3f0:	39400340 	ldrb	w0, [x26]
   8a3f4:	17fffda3 	b	89a80 <_vfiprintf_r+0x240>
   8a3f8:	aa1303e0 	mov	x0, x19
   8a3fc:	94000a15 	bl	8cc50 <_localeconv_r>
   8a400:	f9400400 	ldr	x0, [x0, #8]
   8a404:	f90057e0 	str	x0, [sp, #168]
   8a408:	97ffe15e 	bl	82980 <strlen>
   8a40c:	aa0003e1 	mov	x1, x0
   8a410:	aa1303e0 	mov	x0, x19
   8a414:	f9004fe1 	str	x1, [sp, #152]
   8a418:	94000a0e 	bl	8cc50 <_localeconv_r>
   8a41c:	f9404fe1 	ldr	x1, [sp, #152]
   8a420:	f9400800 	ldr	x0, [x0, #16]
   8a424:	f90053e0 	str	x0, [sp, #160]
   8a428:	f100003f 	cmp	x1, #0x0
   8a42c:	fa401804 	ccmp	x0, #0x0, #0x4, ne	// ne = any
   8a430:	54001c40 	b.eq	8a7b8 <_vfiprintf_r+0xf78>  // b.none
   8a434:	39400000 	ldrb	w0, [x0]
   8a438:	32160281 	orr	w1, w20, #0x400
   8a43c:	7100001f 	cmp	w0, #0x0
   8a440:	39400340 	ldrb	w0, [x26]
   8a444:	1a941034 	csel	w20, w1, w20, ne	// ne = any
   8a448:	17fffd8e 	b	89a80 <_vfiprintf_r+0x240>
   8a44c:	39400340 	ldrb	w0, [x26]
   8a450:	32000294 	orr	w20, w20, #0x1
   8a454:	17fffd8b 	b	89a80 <_vfiprintf_r+0x240>
   8a458:	3943bfe1 	ldrb	w1, [sp, #239]
   8a45c:	39400340 	ldrb	w0, [x26]
   8a460:	35ffb101 	cbnz	w1, 89a80 <_vfiprintf_r+0x240>
   8a464:	52800401 	mov	w1, #0x20                  	// #32
   8a468:	3903bfe1 	strb	w1, [sp, #239]
   8a46c:	17fffd85 	b	89a80 <_vfiprintf_r+0x240>
   8a470:	2a1903e8 	mov	w8, w25
   8a474:	2a1c03e3 	mov	w3, w28
   8a478:	321c0294 	orr	w20, w20, #0x10
   8a47c:	b94067e0 	ldr	w0, [sp, #100]
   8a480:	37280054 	tbnz	w20, #5, 8a488 <_vfiprintf_r+0xc48>
   8a484:	36201af4 	tbz	w20, #4, 8a7e0 <_vfiprintf_r+0xfa0>
   8a488:	37f82cc0 	tbnz	w0, #31, 8aa20 <_vfiprintf_r+0x11e0>
   8a48c:	91003f01 	add	x1, x24, #0xf
   8a490:	aa1803e0 	mov	x0, x24
   8a494:	927df038 	and	x24, x1, #0xfffffffffffffff8
   8a498:	f9400001 	ldr	x1, [x0]
   8a49c:	12157a84 	and	w4, w20, #0xfffffbff
   8a4a0:	52800000 	mov	w0, #0x0                   	// #0
   8a4a4:	52800002 	mov	w2, #0x0                   	// #0
   8a4a8:	3903bfe2 	strb	w2, [sp, #239]
   8a4ac:	3100047f 	cmn	w3, #0x1
   8a4b0:	54000d40 	b.eq	8a658 <_vfiprintf_r+0xe18>  // b.none
   8a4b4:	f100003f 	cmp	x1, #0x0
   8a4b8:	12187894 	and	w20, w4, #0xffffff7f
   8a4bc:	7a400860 	ccmp	w3, #0x0, #0x0, eq	// eq = none
   8a4c0:	54000ca1 	b.ne	8a654 <_vfiprintf_r+0xe14>  // b.any
   8a4c4:	350005c0 	cbnz	w0, 8a57c <_vfiprintf_r+0xd3c>
   8a4c8:	12000099 	and	w25, w4, #0x1
   8a4cc:	36001284 	tbz	w4, #0, 8a71c <_vfiprintf_r+0xedc>
   8a4d0:	91062ffc 	add	x28, sp, #0x18b
   8a4d4:	52800600 	mov	w0, #0x30                  	// #48
   8a4d8:	52800003 	mov	w3, #0x0                   	// #0
   8a4dc:	39062fe0 	strb	w0, [sp, #395]
   8a4e0:	6b03033f 	cmp	w25, w3
   8a4e4:	f90037ff 	str	xzr, [sp, #104]
   8a4e8:	1a83a324 	csel	w4, w25, w3, ge	// ge = tcont
   8a4ec:	3943bfe0 	ldrb	w0, [sp, #239]
   8a4f0:	7100001f 	cmp	w0, #0x0
   8a4f4:	1a840484 	cinc	w4, w4, ne	// ne = any
   8a4f8:	17fffd8c 	b	89b28 <_vfiprintf_r+0x2e8>
   8a4fc:	2a1903e8 	mov	w8, w25
   8a500:	2a1c03e3 	mov	w3, w28
   8a504:	321c0284 	orr	w4, w20, #0x10
   8a508:	b94067e0 	ldr	w0, [sp, #100]
   8a50c:	37280044 	tbnz	w4, #5, 8a514 <_vfiprintf_r+0xcd4>
   8a510:	36201584 	tbz	w4, #4, 8a7c0 <_vfiprintf_r+0xf80>
   8a514:	37f82740 	tbnz	w0, #31, 8a9fc <_vfiprintf_r+0x11bc>
   8a518:	91003f01 	add	x1, x24, #0xf
   8a51c:	aa1803e0 	mov	x0, x24
   8a520:	927df038 	and	x24, x1, #0xfffffffffffffff8
   8a524:	f9400001 	ldr	x1, [x0]
   8a528:	52800020 	mov	w0, #0x1                   	// #1
   8a52c:	17ffffde 	b	8a4a4 <_vfiprintf_r+0xc64>
   8a530:	2a1903e8 	mov	w8, w25
   8a534:	2a1c03e3 	mov	w3, w28
   8a538:	321c0294 	orr	w20, w20, #0x10
   8a53c:	b94067e0 	ldr	w0, [sp, #100]
   8a540:	37280054 	tbnz	w20, #5, 8a548 <_vfiprintf_r+0xd08>
   8a544:	362015d4 	tbz	w20, #4, 8a7fc <_vfiprintf_r+0xfbc>
   8a548:	37f82480 	tbnz	w0, #31, 8a9d8 <_vfiprintf_r+0x1198>
   8a54c:	91003f01 	add	x1, x24, #0xf
   8a550:	aa1803e0 	mov	x0, x24
   8a554:	927df038 	and	x24, x1, #0xfffffffffffffff8
   8a558:	f9400000 	ldr	x0, [x0]
   8a55c:	aa0003e1 	mov	x1, x0
   8a560:	b7f80ec0 	tbnz	x0, #63, 8a738 <_vfiprintf_r+0xef8>
   8a564:	3100047f 	cmn	w3, #0x1
   8a568:	54000c20 	b.eq	8a6ec <_vfiprintf_r+0xeac>  // b.none
   8a56c:	f100003f 	cmp	x1, #0x0
   8a570:	12187a94 	and	w20, w20, #0xffffff7f
   8a574:	7a400860 	ccmp	w3, #0x0, #0x0, eq	// eq = none
   8a578:	54000ba1 	b.ne	8a6ec <_vfiprintf_r+0xeac>  // b.any
   8a57c:	910633fc 	add	x28, sp, #0x18c
   8a580:	52800003 	mov	w3, #0x0                   	// #0
   8a584:	52800019 	mov	w25, #0x0                   	// #0
   8a588:	17ffffd6 	b	8a4e0 <_vfiprintf_r+0xca0>
   8a58c:	b94067e0 	ldr	w0, [sp, #100]
   8a590:	37280194 	tbnz	w20, #5, 8a5c0 <_vfiprintf_r+0xd80>
   8a594:	37200174 	tbnz	w20, #4, 8a5c0 <_vfiprintf_r+0xd80>
   8a598:	37304314 	tbnz	w20, #6, 8adf8 <_vfiprintf_r+0x15b8>
   8a59c:	36486194 	tbz	w20, #9, 8b1cc <_vfiprintf_r+0x198c>
   8a5a0:	37f869c0 	tbnz	w0, #31, 8b2d8 <_vfiprintf_r+0x1a98>
   8a5a4:	91003f01 	add	x1, x24, #0xf
   8a5a8:	aa1803e0 	mov	x0, x24
   8a5ac:	927df038 	and	x24, x1, #0xfffffffffffffff8
   8a5b0:	f9400000 	ldr	x0, [x0]
   8a5b4:	394183e1 	ldrb	w1, [sp, #96]
   8a5b8:	39000001 	strb	w1, [x0]
   8a5bc:	17fffcd7 	b	89918 <_vfiprintf_r+0xd8>
   8a5c0:	37f81880 	tbnz	w0, #31, 8a8d0 <_vfiprintf_r+0x1090>
   8a5c4:	91003f01 	add	x1, x24, #0xf
   8a5c8:	aa1803e0 	mov	x0, x24
   8a5cc:	927df038 	and	x24, x1, #0xfffffffffffffff8
   8a5d0:	f9400000 	ldr	x0, [x0]
   8a5d4:	b98063e1 	ldrsw	x1, [sp, #96]
   8a5d8:	f9000001 	str	x1, [x0]
   8a5dc:	17fffccf 	b	89918 <_vfiprintf_r+0xd8>
   8a5e0:	39400340 	ldrb	w0, [x26]
   8a5e4:	7101b01f 	cmp	w0, #0x6c
   8a5e8:	54003160 	b.eq	8ac14 <_vfiprintf_r+0x13d4>  // b.none
   8a5ec:	321c0294 	orr	w20, w20, #0x10
   8a5f0:	17fffd24 	b	89a80 <_vfiprintf_r+0x240>
   8a5f4:	39400340 	ldrb	w0, [x26]
   8a5f8:	7101a01f 	cmp	w0, #0x68
   8a5fc:	54003140 	b.eq	8ac24 <_vfiprintf_r+0x13e4>  // b.none
   8a600:	321a0294 	orr	w20, w20, #0x40
   8a604:	17fffd1f 	b	89a80 <_vfiprintf_r+0x240>
   8a608:	39400340 	ldrb	w0, [x26]
   8a60c:	321b0294 	orr	w20, w20, #0x20
   8a610:	17fffd1c 	b	89a80 <_vfiprintf_r+0x240>
   8a614:	b94067e0 	ldr	w0, [sp, #100]
   8a618:	2a1903e8 	mov	w8, w25
   8a61c:	2a1c03e3 	mov	w3, w28
   8a620:	37f812e0 	tbnz	w0, #31, 8a87c <_vfiprintf_r+0x103c>
   8a624:	91003f01 	add	x1, x24, #0xf
   8a628:	aa1803e0 	mov	x0, x24
   8a62c:	927df038 	and	x24, x1, #0xfffffffffffffff8
   8a630:	f9400001 	ldr	x1, [x0]
   8a634:	528f0600 	mov	w0, #0x7830                	// #30768
   8a638:	f0000042 	adrp	x2, 95000 <pmu_event_descr+0x60>
   8a63c:	321f0284 	orr	w4, w20, #0x2
   8a640:	9117a042 	add	x2, x2, #0x5e8
   8a644:	f90043e2 	str	x2, [sp, #128]
   8a648:	7901e3e0 	strh	w0, [sp, #240]
   8a64c:	52800040 	mov	w0, #0x2                   	// #2
   8a650:	17ffff95 	b	8a4a4 <_vfiprintf_r+0xc64>
   8a654:	2a1403e4 	mov	w4, w20
   8a658:	7100041f 	cmp	w0, #0x1
   8a65c:	540004a0 	b.eq	8a6f0 <_vfiprintf_r+0xeb0>  // b.none
   8a660:	910633f9 	add	x25, sp, #0x18c
   8a664:	aa1903fc 	mov	x28, x25
   8a668:	7100081f 	cmp	w0, #0x2
   8a66c:	54000161 	b.ne	8a698 <_vfiprintf_r+0xe58>  // b.any
   8a670:	f94043e2 	ldr	x2, [sp, #128]
   8a674:	d503201f 	nop
   8a678:	92400c20 	and	x0, x1, #0xf
   8a67c:	d344fc21 	lsr	x1, x1, #4
   8a680:	38606840 	ldrb	w0, [x2, x0]
   8a684:	381fff80 	strb	w0, [x28, #-1]!
   8a688:	b5ffff81 	cbnz	x1, 8a678 <_vfiprintf_r+0xe38>
   8a68c:	4b1c0339 	sub	w25, w25, w28
   8a690:	2a0403f4 	mov	w20, w4
   8a694:	17ffff93 	b	8a4e0 <_vfiprintf_r+0xca0>
   8a698:	12000820 	and	w0, w1, #0x7
   8a69c:	aa1c03e2 	mov	x2, x28
   8a6a0:	1100c000 	add	w0, w0, #0x30
   8a6a4:	381fff80 	strb	w0, [x28, #-1]!
   8a6a8:	d343fc21 	lsr	x1, x1, #3
   8a6ac:	b5ffff61 	cbnz	x1, 8a698 <_vfiprintf_r+0xe58>
   8a6b0:	7100c01f 	cmp	w0, #0x30
   8a6b4:	1a9f07e0 	cset	w0, ne	// ne = any
   8a6b8:	6a00009f 	tst	w4, w0
   8a6bc:	54fffe80 	b.eq	8a68c <_vfiprintf_r+0xe4c>  // b.none
   8a6c0:	d1000842 	sub	x2, x2, #0x2
   8a6c4:	52800600 	mov	w0, #0x30                  	// #48
   8a6c8:	2a0403f4 	mov	w20, w4
   8a6cc:	4b020339 	sub	w25, w25, w2
   8a6d0:	381ff380 	sturb	w0, [x28, #-1]
   8a6d4:	aa0203fc 	mov	x28, x2
   8a6d8:	17ffff82 	b	8a4e0 <_vfiprintf_r+0xca0>
   8a6dc:	aa1703e3 	mov	x3, x23
   8a6e0:	5280002d 	mov	w13, #0x1                   	// #1
   8a6e4:	52800001 	mov	w1, #0x0                   	// #0
   8a6e8:	17fffd9e 	b	89d60 <_vfiprintf_r+0x520>
   8a6ec:	2a1403e4 	mov	w4, w20
   8a6f0:	f100243f 	cmp	x1, #0x9
   8a6f4:	54002368 	b.hi	8ab60 <_vfiprintf_r+0x1320>  // b.pmore
   8a6f8:	1100c021 	add	w1, w1, #0x30
   8a6fc:	2a0403f4 	mov	w20, w4
   8a700:	91062ffc 	add	x28, sp, #0x18b
   8a704:	52800039 	mov	w25, #0x1                   	// #1
   8a708:	39062fe1 	strb	w1, [sp, #395]
   8a70c:	17ffff75 	b	8a4e0 <_vfiprintf_r+0xca0>
   8a710:	aa1703fb 	mov	x27, x23
   8a714:	b9011bff 	str	wzr, [sp, #280]
   8a718:	17fffcce 	b	89a50 <_vfiprintf_r+0x210>
   8a71c:	910633fc 	add	x28, sp, #0x18c
   8a720:	52800003 	mov	w3, #0x0                   	// #0
   8a724:	17ffff6f 	b	8a4e0 <_vfiprintf_r+0xca0>
   8a728:	aa1703fb 	mov	x27, x23
   8a72c:	5280002b 	mov	w11, #0x1                   	// #1
   8a730:	52800001 	mov	w1, #0x0                   	// #0
   8a734:	17fffd31 	b	89bf8 <_vfiprintf_r+0x3b8>
   8a738:	cb0103e1 	neg	x1, x1
   8a73c:	2a1403e4 	mov	w4, w20
   8a740:	528005a2 	mov	w2, #0x2d                  	// #45
   8a744:	52800020 	mov	w0, #0x1                   	// #1
   8a748:	17ffff58 	b	8a4a8 <_vfiprintf_r+0xc68>
   8a74c:	b4000d40 	cbz	x0, 8a8f4 <_vfiprintf_r+0x10b4>
   8a750:	910443e2 	add	x2, sp, #0x110
   8a754:	aa1603e1 	mov	x1, x22
   8a758:	aa1303e0 	mov	x0, x19
   8a75c:	b9008be4 	str	w4, [sp, #136]
   8a760:	b90093ec 	str	w12, [sp, #144]
   8a764:	291623ee 	stp	w14, w8, [sp, #176]
   8a768:	b900bbe3 	str	w3, [sp, #184]
   8a76c:	97fffbf5 	bl	89740 <__sprint_r.part.0>
   8a770:	35ff9a40 	cbnz	w0, 89ab8 <_vfiprintf_r+0x278>
   8a774:	b9411be1 	ldr	w1, [sp, #280]
   8a778:	aa1703fb 	mov	x27, x23
   8a77c:	f94093e0 	ldr	x0, [sp, #288]
   8a780:	1100042b 	add	w11, w1, #0x1
   8a784:	b9408be4 	ldr	w4, [sp, #136]
   8a788:	b94093ec 	ldr	w12, [sp, #144]
   8a78c:	295623ee 	ldp	w14, w8, [sp, #176]
   8a790:	b940bbe3 	ldr	w3, [sp, #184]
   8a794:	17fffcf2 	b	89b5c <_vfiprintf_r+0x31c>
   8a798:	f94052c0 	ldr	x0, [x22, #160]
   8a79c:	940005e5 	bl	8bf30 <__retarget_lock_acquire_recursive>
   8a7a0:	79c022c0 	ldrsh	w0, [x22, #16]
   8a7a4:	17fffc41 	b	898a8 <_vfiprintf_r+0x68>
   8a7a8:	9100437b 	add	x27, x27, #0x10
   8a7ac:	110005ab 	add	w11, w13, #0x1
   8a7b0:	2a0d03e1 	mov	w1, w13
   8a7b4:	17fffd13 	b	89c00 <_vfiprintf_r+0x3c0>
   8a7b8:	39400340 	ldrb	w0, [x26]
   8a7bc:	17fffcb1 	b	89a80 <_vfiprintf_r+0x240>
   8a7c0:	36302544 	tbz	w4, #6, 8ac68 <_vfiprintf_r+0x1428>
   8a7c4:	37f83640 	tbnz	w0, #31, 8ae8c <_vfiprintf_r+0x164c>
   8a7c8:	91002f01 	add	x1, x24, #0xb
   8a7cc:	aa1803e0 	mov	x0, x24
   8a7d0:	927df038 	and	x24, x1, #0xfffffffffffffff8
   8a7d4:	79400001 	ldrh	w1, [x0]
   8a7d8:	52800020 	mov	w0, #0x1                   	// #1
   8a7dc:	17ffff32 	b	8a4a4 <_vfiprintf_r+0xc64>
   8a7e0:	36302554 	tbz	w20, #6, 8ac88 <_vfiprintf_r+0x1448>
   8a7e4:	37f83960 	tbnz	w0, #31, 8af10 <_vfiprintf_r+0x16d0>
   8a7e8:	aa1803e0 	mov	x0, x24
   8a7ec:	91002f01 	add	x1, x24, #0xb
   8a7f0:	927df038 	and	x24, x1, #0xfffffffffffffff8
   8a7f4:	79400001 	ldrh	w1, [x0]
   8a7f8:	17ffff29 	b	8a49c <_vfiprintf_r+0xc5c>
   8a7fc:	36302814 	tbz	w20, #6, 8acfc <_vfiprintf_r+0x14bc>
   8a800:	37f83760 	tbnz	w0, #31, 8aeec <_vfiprintf_r+0x16ac>
   8a804:	91002f01 	add	x1, x24, #0xb
   8a808:	aa1803e0 	mov	x0, x24
   8a80c:	927df038 	and	x24, x1, #0xfffffffffffffff8
   8a810:	79800001 	ldrsh	x1, [x0]
   8a814:	aa0103e0 	mov	x0, x1
   8a818:	17ffff52 	b	8a560 <_vfiprintf_r+0xd20>
   8a81c:	aa1703fb 	mov	x27, x23
   8a820:	52800001 	mov	w1, #0x0                   	// #0
   8a824:	5280002b 	mov	w11, #0x1                   	// #1
   8a828:	17fffcf4 	b	89bf8 <_vfiprintf_r+0x3b8>
   8a82c:	2a1903e8 	mov	w8, w25
   8a830:	2a1c03e3 	mov	w3, w28
   8a834:	17ffff42 	b	8a53c <_vfiprintf_r+0xcfc>
   8a838:	b94067e0 	ldr	w0, [sp, #100]
   8a83c:	11002001 	add	w1, w0, #0x8
   8a840:	7100003f 	cmp	w1, #0x0
   8a844:	54002b6d 	b.le	8adb0 <_vfiprintf_r+0x1570>
   8a848:	91002f00 	add	x0, x24, #0xb
   8a84c:	b90067e1 	str	w1, [sp, #100]
   8a850:	927df000 	and	x0, x0, #0xfffffffffffffff8
   8a854:	17fffee4 	b	8a3e4 <_vfiprintf_r+0xba4>
   8a858:	b94067e1 	ldr	w1, [sp, #100]
   8a85c:	11002021 	add	w1, w1, #0x8
   8a860:	7100003f 	cmp	w1, #0x0
   8a864:	54002b4d 	b.le	8adcc <_vfiprintf_r+0x158c>
   8a868:	91003f02 	add	x2, x24, #0xf
   8a86c:	b90067e1 	str	w1, [sp, #100]
   8a870:	927df041 	and	x1, x2, #0xfffffffffffffff8
   8a874:	f90047e1 	str	x1, [sp, #136]
   8a878:	17fffe83 	b	8a284 <_vfiprintf_r+0xa44>
   8a87c:	b94067e0 	ldr	w0, [sp, #100]
   8a880:	11002001 	add	w1, w0, #0x8
   8a884:	7100003f 	cmp	w1, #0x0
   8a888:	540028ad 	b.le	8ad9c <_vfiprintf_r+0x155c>
   8a88c:	91003f02 	add	x2, x24, #0xf
   8a890:	aa1803e0 	mov	x0, x24
   8a894:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8a898:	b90067e1 	str	w1, [sp, #100]
   8a89c:	17ffff65 	b	8a630 <_vfiprintf_r+0xdf0>
   8a8a0:	b94067e0 	ldr	w0, [sp, #100]
   8a8a4:	37f836e0 	tbnz	w0, #31, 8af80 <_vfiprintf_r+0x1740>
   8a8a8:	91002f01 	add	x1, x24, #0xb
   8a8ac:	aa1803e0 	mov	x0, x24
   8a8b0:	927df038 	and	x24, x1, #0xfffffffffffffff8
   8a8b4:	b9400000 	ldr	w0, [x0]
   8a8b8:	52800024 	mov	w4, #0x1                   	// #1
   8a8bc:	9104a3fc 	add	x28, sp, #0x128
   8a8c0:	2a0403f9 	mov	w25, w4
   8a8c4:	3903bfff 	strb	wzr, [sp, #239]
   8a8c8:	3904a3e0 	strb	w0, [sp, #296]
   8a8cc:	17fffc94 	b	89b1c <_vfiprintf_r+0x2dc>
   8a8d0:	b94067e0 	ldr	w0, [sp, #100]
   8a8d4:	11002001 	add	w1, w0, #0x8
   8a8d8:	7100003f 	cmp	w1, #0x0
   8a8dc:	5400392d 	b.le	8b000 <_vfiprintf_r+0x17c0>
   8a8e0:	91003f02 	add	x2, x24, #0xf
   8a8e4:	aa1803e0 	mov	x0, x24
   8a8e8:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8a8ec:	b90067e1 	str	w1, [sp, #100]
   8a8f0:	17ffff38 	b	8a5d0 <_vfiprintf_r+0xd90>
   8a8f4:	3943bfe1 	ldrb	w1, [sp, #239]
   8a8f8:	340029e1 	cbz	w1, 8ae34 <_vfiprintf_r+0x15f4>
   8a8fc:	d2800020 	mov	x0, #0x1                   	// #1
   8a900:	9103bfe1 	add	x1, sp, #0xef
   8a904:	aa1703fb 	mov	x27, x23
   8a908:	2a0003eb 	mov	w11, w0
   8a90c:	a91903e1 	stp	x1, x0, [sp, #400]
   8a910:	17fffc9e 	b	89b88 <_vfiprintf_r+0x348>
   8a914:	2a1903e8 	mov	w8, w25
   8a918:	2a1c03e3 	mov	w3, w28
   8a91c:	f0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8a920:	91180021 	add	x1, x1, #0x600
   8a924:	f90043e1 	str	x1, [sp, #128]
   8a928:	b94067e1 	ldr	w1, [sp, #100]
   8a92c:	372802d4 	tbnz	w20, #5, 8a984 <_vfiprintf_r+0x1144>
   8a930:	372002b4 	tbnz	w20, #4, 8a984 <_vfiprintf_r+0x1144>
   8a934:	36301c34 	tbz	w20, #6, 8acb8 <_vfiprintf_r+0x1478>
   8a938:	37f82bc1 	tbnz	w1, #31, 8aeb0 <_vfiprintf_r+0x1670>
   8a93c:	aa1803e1 	mov	x1, x24
   8a940:	91002f02 	add	x2, x24, #0xb
   8a944:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8a948:	79400021 	ldrh	w1, [x1]
   8a94c:	14000013 	b	8a998 <_vfiprintf_r+0x1158>
   8a950:	2a1903e8 	mov	w8, w25
   8a954:	2a1c03e3 	mov	w3, w28
   8a958:	2a1403e4 	mov	w4, w20
   8a95c:	17fffeeb 	b	8a508 <_vfiprintf_r+0xcc8>
   8a960:	f0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8a964:	2a1903e8 	mov	w8, w25
   8a968:	9117a021 	add	x1, x1, #0x5e8
   8a96c:	2a1c03e3 	mov	w3, w28
   8a970:	f90043e1 	str	x1, [sp, #128]
   8a974:	17ffffed 	b	8a928 <_vfiprintf_r+0x10e8>
   8a978:	2a1903e8 	mov	w8, w25
   8a97c:	2a1c03e3 	mov	w3, w28
   8a980:	17fffebf 	b	8a47c <_vfiprintf_r+0xc3c>
   8a984:	37f80181 	tbnz	w1, #31, 8a9b4 <_vfiprintf_r+0x1174>
   8a988:	91003f02 	add	x2, x24, #0xf
   8a98c:	aa1803e1 	mov	x1, x24
   8a990:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8a994:	f9400021 	ldr	x1, [x1]
   8a998:	f100003f 	cmp	x1, #0x0
   8a99c:	1a9f07e2 	cset	w2, ne	// ne = any
   8a9a0:	6a02029f 	tst	w20, w2
   8a9a4:	54000501 	b.ne	8aa44 <_vfiprintf_r+0x1204>  // b.any
   8a9a8:	12157a84 	and	w4, w20, #0xfffffbff
   8a9ac:	52800040 	mov	w0, #0x2                   	// #2
   8a9b0:	17fffebd 	b	8a4a4 <_vfiprintf_r+0xc64>
   8a9b4:	b94067e1 	ldr	w1, [sp, #100]
   8a9b8:	11002022 	add	w2, w1, #0x8
   8a9bc:	7100005f 	cmp	w2, #0x0
   8a9c0:	5400172d 	b.le	8aca4 <_vfiprintf_r+0x1464>
   8a9c4:	91003f04 	add	x4, x24, #0xf
   8a9c8:	aa1803e1 	mov	x1, x24
   8a9cc:	927df098 	and	x24, x4, #0xfffffffffffffff8
   8a9d0:	b90067e2 	str	w2, [sp, #100]
   8a9d4:	17fffff0 	b	8a994 <_vfiprintf_r+0x1154>
   8a9d8:	b94067e0 	ldr	w0, [sp, #100]
   8a9dc:	11002001 	add	w1, w0, #0x8
   8a9e0:	7100003f 	cmp	w1, #0x0
   8a9e4:	5400182d 	b.le	8ace8 <_vfiprintf_r+0x14a8>
   8a9e8:	91003f02 	add	x2, x24, #0xf
   8a9ec:	aa1803e0 	mov	x0, x24
   8a9f0:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8a9f4:	b90067e1 	str	w1, [sp, #100]
   8a9f8:	17fffed8 	b	8a558 <_vfiprintf_r+0xd18>
   8a9fc:	b94067e0 	ldr	w0, [sp, #100]
   8aa00:	11002001 	add	w1, w0, #0x8
   8aa04:	7100003f 	cmp	w1, #0x0
   8aa08:	540018ad 	b.le	8ad1c <_vfiprintf_r+0x14dc>
   8aa0c:	91003f02 	add	x2, x24, #0xf
   8aa10:	aa1803e0 	mov	x0, x24
   8aa14:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8aa18:	b90067e1 	str	w1, [sp, #100]
   8aa1c:	17fffec2 	b	8a524 <_vfiprintf_r+0xce4>
   8aa20:	b94067e0 	ldr	w0, [sp, #100]
   8aa24:	11002001 	add	w1, w0, #0x8
   8aa28:	7100003f 	cmp	w1, #0x0
   8aa2c:	5400154d 	b.le	8acd4 <_vfiprintf_r+0x1494>
   8aa30:	91003f02 	add	x2, x24, #0xf
   8aa34:	aa1803e0 	mov	x0, x24
   8aa38:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8aa3c:	b90067e1 	str	w1, [sp, #100]
   8aa40:	17fffe96 	b	8a498 <_vfiprintf_r+0xc58>
   8aa44:	321f0294 	orr	w20, w20, #0x2
   8aa48:	3903c7e0 	strb	w0, [sp, #241]
   8aa4c:	52800600 	mov	w0, #0x30                  	// #48
   8aa50:	3903c3e0 	strb	w0, [sp, #240]
   8aa54:	17ffffd5 	b	8a9a8 <_vfiprintf_r+0x1168>
   8aa58:	910403e0 	add	x0, sp, #0x100
   8aa5c:	d2800102 	mov	x2, #0x8                   	// #8
   8aa60:	52800001 	mov	w1, #0x0                   	// #0
   8aa64:	b9006be8 	str	w8, [sp, #104]
   8aa68:	b900b3e3 	str	w3, [sp, #176]
   8aa6c:	f90087fc 	str	x28, [sp, #264]
   8aa70:	94000ad4 	bl	8d5c0 <memset>
   8aa74:	b940b3e3 	ldr	w3, [sp, #176]
   8aa78:	b9406be8 	ldr	w8, [sp, #104]
   8aa7c:	3100047f 	cmn	w3, #0x1
   8aa80:	540016a0 	b.eq	8ad54 <_vfiprintf_r+0x1514>  // b.none
   8aa84:	aa1603e0 	mov	x0, x22
   8aa88:	d2800018 	mov	x24, #0x0                   	// #0
   8aa8c:	52800019 	mov	w25, #0x0                   	// #0
   8aa90:	aa1803f6 	mov	x22, x24
   8aa94:	2a1903f8 	mov	w24, w25
   8aa98:	aa0003f9 	mov	x25, x0
   8aa9c:	b9006bf4 	str	w20, [sp, #104]
   8aaa0:	2a0303f4 	mov	w20, w3
   8aaa4:	b900b3e8 	str	w8, [sp, #176]
   8aaa8:	1400000d 	b	8aadc <_vfiprintf_r+0x129c>
   8aaac:	910403e3 	add	x3, sp, #0x100
   8aab0:	9104a3e1 	add	x1, sp, #0x128
   8aab4:	aa1303e0 	mov	x0, x19
   8aab8:	940004be 	bl	8bdb0 <_wcrtomb_r>
   8aabc:	3100041f 	cmn	w0, #0x1
   8aac0:	54003560 	b.eq	8b16c <_vfiprintf_r+0x192c>  // b.none
   8aac4:	0b000300 	add	w0, w24, w0
   8aac8:	6b14001f 	cmp	w0, w20
   8aacc:	540000ec 	b.gt	8aae8 <_vfiprintf_r+0x12a8>
   8aad0:	910012d6 	add	x22, x22, #0x4
   8aad4:	54003420 	b.eq	8b158 <_vfiprintf_r+0x1918>  // b.none
   8aad8:	2a0003f8 	mov	w24, w0
   8aadc:	f94087e0 	ldr	x0, [sp, #264]
   8aae0:	b8766802 	ldr	w2, [x0, x22]
   8aae4:	35fffe42 	cbnz	w2, 8aaac <_vfiprintf_r+0x126c>
   8aae8:	b9406bf4 	ldr	w20, [sp, #104]
   8aaec:	aa1903f6 	mov	x22, x25
   8aaf0:	b940b3e8 	ldr	w8, [sp, #176]
   8aaf4:	2a1803f9 	mov	w25, w24
   8aaf8:	34001499 	cbz	w25, 8ad88 <_vfiprintf_r+0x1548>
   8aafc:	71018f3f 	cmp	w25, #0x63
   8ab00:	540021cc 	b.gt	8af38 <_vfiprintf_r+0x16f8>
   8ab04:	9104a3fc 	add	x28, sp, #0x128
   8ab08:	f90037ff 	str	xzr, [sp, #104]
   8ab0c:	93407f38 	sxtw	x24, w25
   8ab10:	d2800102 	mov	x2, #0x8                   	// #8
   8ab14:	52800001 	mov	w1, #0x0                   	// #0
   8ab18:	910403e0 	add	x0, sp, #0x100
   8ab1c:	b900b3e8 	str	w8, [sp, #176]
   8ab20:	94000aa8 	bl	8d5c0 <memset>
   8ab24:	910403e4 	add	x4, sp, #0x100
   8ab28:	aa1803e3 	mov	x3, x24
   8ab2c:	910423e2 	add	x2, sp, #0x108
   8ab30:	aa1c03e1 	mov	x1, x28
   8ab34:	aa1303e0 	mov	x0, x19
   8ab38:	94000b22 	bl	8d7c0 <_wcsrtombs_r>
   8ab3c:	b940b3e8 	ldr	w8, [sp, #176]
   8ab40:	eb00031f 	cmp	x24, x0
   8ab44:	54004841 	b.ne	8b44c <_vfiprintf_r+0x1c0c>  // b.any
   8ab48:	7100033f 	cmp	w25, #0x0
   8ab4c:	52800003 	mov	w3, #0x0                   	// #0
   8ab50:	f94047f8 	ldr	x24, [sp, #136]
   8ab54:	1a9fa324 	csel	w4, w25, wzr, ge	// ge = tcont
   8ab58:	3839cb9f 	strb	wzr, [x28, w25, sxtw]
   8ab5c:	17fffe64 	b	8a4ec <_vfiprintf_r+0xcac>
   8ab60:	910633f9 	add	x25, sp, #0x18c
   8ab64:	1216008a 	and	w10, w4, #0x400
   8ab68:	b202e7e6 	mov	x6, #0xcccccccccccccccc    	// #-3689348814741910324
   8ab6c:	aa1903e2 	mov	x2, x25
   8ab70:	aa1a03e5 	mov	x5, x26
   8ab74:	aa1903e7 	mov	x7, x25
   8ab78:	aa1603fa 	mov	x26, x22
   8ab7c:	aa1303f9 	mov	x25, x19
   8ab80:	f94053f6 	ldr	x22, [sp, #160]
   8ab84:	2a0a03f3 	mov	w19, w10
   8ab88:	5280000b 	mov	w11, #0x0                   	// #0
   8ab8c:	f29999a6 	movk	x6, #0xcccd
   8ab90:	14000007 	b	8abac <_vfiprintf_r+0x136c>
   8ab94:	9bc67c34 	umulh	x20, x1, x6
   8ab98:	d343fe94 	lsr	x20, x20, #3
   8ab9c:	f100243f 	cmp	x1, #0x9
   8aba0:	54000249 	b.ls	8abe8 <_vfiprintf_r+0x13a8>  // b.plast
   8aba4:	aa1403e1 	mov	x1, x20
   8aba8:	aa1c03e2 	mov	x2, x28
   8abac:	9bc67c34 	umulh	x20, x1, x6
   8abb0:	1100056b 	add	w11, w11, #0x1
   8abb4:	d100045c 	sub	x28, x2, #0x1
   8abb8:	d343fe94 	lsr	x20, x20, #3
   8abbc:	8b140a80 	add	x0, x20, x20, lsl #2
   8abc0:	cb000420 	sub	x0, x1, x0, lsl #1
   8abc4:	1100c000 	add	w0, w0, #0x30
   8abc8:	381ff040 	sturb	w0, [x2, #-1]
   8abcc:	34fffe53 	cbz	w19, 8ab94 <_vfiprintf_r+0x1354>
   8abd0:	394002c0 	ldrb	w0, [x22]
   8abd4:	7103fc1f 	cmp	w0, #0xff
   8abd8:	7a4b1000 	ccmp	w0, w11, #0x0, ne	// ne = any
   8abdc:	54fffdc1 	b.ne	8ab94 <_vfiprintf_r+0x1354>  // b.any
   8abe0:	f100243f 	cmp	x1, #0x9
   8abe4:	54001e08 	b.hi	8afa4 <_vfiprintf_r+0x1764>  // b.pmore
   8abe8:	aa1903f3 	mov	x19, x25
   8abec:	aa0703f9 	mov	x25, x7
   8abf0:	4b1c0339 	sub	w25, w25, w28
   8abf4:	2a0403f4 	mov	w20, w4
   8abf8:	f90053f6 	str	x22, [sp, #160]
   8abfc:	aa1a03f6 	mov	x22, x26
   8ac00:	aa0503fa 	mov	x26, x5
   8ac04:	17fffe37 	b	8a4e0 <_vfiprintf_r+0xca0>
   8ac08:	aa1303e0 	mov	x0, x19
   8ac0c:	97ffde7d 	bl	82600 <__sinit>
   8ac10:	17fffb22 	b	89898 <_vfiprintf_r+0x58>
   8ac14:	39400740 	ldrb	w0, [x26, #1]
   8ac18:	321b0294 	orr	w20, w20, #0x20
   8ac1c:	9100075a 	add	x26, x26, #0x1
   8ac20:	17fffb98 	b	89a80 <_vfiprintf_r+0x240>
   8ac24:	39400740 	ldrb	w0, [x26, #1]
   8ac28:	32170294 	orr	w20, w20, #0x200
   8ac2c:	9100075a 	add	x26, x26, #0x1
   8ac30:	17fffb94 	b	89a80 <_vfiprintf_r+0x240>
   8ac34:	7100187f 	cmp	w3, #0x6
   8ac38:	528000c9 	mov	w9, #0x6                   	// #6
   8ac3c:	1a899079 	csel	w25, w3, w9, ls	// ls = plast
   8ac40:	f0000047 	adrp	x7, 95000 <pmu_event_descr+0x60>
   8ac44:	f94047f8 	ldr	x24, [sp, #136]
   8ac48:	2a1903e4 	mov	w4, w25
   8ac4c:	911860fc 	add	x28, x7, #0x618
   8ac50:	17fffbb3 	b	89b1c <_vfiprintf_r+0x2dc>
   8ac54:	f94093e0 	ldr	x0, [sp, #288]
   8ac58:	b5002040 	cbnz	x0, 8b060 <_vfiprintf_r+0x1820>
   8ac5c:	79c022c0 	ldrsh	w0, [x22, #16]
   8ac60:	b9011bff 	str	wzr, [sp, #280]
   8ac64:	17fffb9b 	b	89ad0 <_vfiprintf_r+0x290>
   8ac68:	36481044 	tbz	w4, #9, 8ae70 <_vfiprintf_r+0x1630>
   8ac6c:	37f82500 	tbnz	w0, #31, 8b10c <_vfiprintf_r+0x18cc>
   8ac70:	91002f01 	add	x1, x24, #0xb
   8ac74:	aa1803e0 	mov	x0, x24
   8ac78:	927df038 	and	x24, x1, #0xfffffffffffffff8
   8ac7c:	39400001 	ldrb	w1, [x0]
   8ac80:	52800020 	mov	w0, #0x1                   	// #1
   8ac84:	17fffe08 	b	8a4a4 <_vfiprintf_r+0xc64>
   8ac88:	36480dd4 	tbz	w20, #9, 8ae40 <_vfiprintf_r+0x1600>
   8ac8c:	37f82520 	tbnz	w0, #31, 8b130 <_vfiprintf_r+0x18f0>
   8ac90:	aa1803e0 	mov	x0, x24
   8ac94:	91002f01 	add	x1, x24, #0xb
   8ac98:	927df038 	and	x24, x1, #0xfffffffffffffff8
   8ac9c:	39400001 	ldrb	w1, [x0]
   8aca0:	17fffdff 	b	8a49c <_vfiprintf_r+0xc5c>
   8aca4:	f9403fe4 	ldr	x4, [sp, #120]
   8aca8:	b94067e1 	ldr	w1, [sp, #100]
   8acac:	b90067e2 	str	w2, [sp, #100]
   8acb0:	8b21c081 	add	x1, x4, w1, sxtw
   8acb4:	17ffff38 	b	8a994 <_vfiprintf_r+0x1154>
   8acb8:	36480d14 	tbz	w20, #9, 8ae58 <_vfiprintf_r+0x1618>
   8acbc:	37f82021 	tbnz	w1, #31, 8b0c0 <_vfiprintf_r+0x1880>
   8acc0:	aa1803e1 	mov	x1, x24
   8acc4:	91002f02 	add	x2, x24, #0xb
   8acc8:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8accc:	39400021 	ldrb	w1, [x1]
   8acd0:	17ffff32 	b	8a998 <_vfiprintf_r+0x1158>
   8acd4:	f9403fe2 	ldr	x2, [sp, #120]
   8acd8:	b94067e0 	ldr	w0, [sp, #100]
   8acdc:	b90067e1 	str	w1, [sp, #100]
   8ace0:	8b20c040 	add	x0, x2, w0, sxtw
   8ace4:	17fffded 	b	8a498 <_vfiprintf_r+0xc58>
   8ace8:	f9403fe2 	ldr	x2, [sp, #120]
   8acec:	b94067e0 	ldr	w0, [sp, #100]
   8acf0:	b90067e1 	str	w1, [sp, #100]
   8acf4:	8b20c040 	add	x0, x2, w0, sxtw
   8acf8:	17fffe18 	b	8a558 <_vfiprintf_r+0xd18>
   8acfc:	364808f4 	tbz	w20, #9, 8ae18 <_vfiprintf_r+0x15d8>
   8ad00:	37f82760 	tbnz	w0, #31, 8b1ec <_vfiprintf_r+0x19ac>
   8ad04:	91002f01 	add	x1, x24, #0xb
   8ad08:	aa1803e0 	mov	x0, x24
   8ad0c:	927df038 	and	x24, x1, #0xfffffffffffffff8
   8ad10:	39800001 	ldrsb	x1, [x0]
   8ad14:	aa0103e0 	mov	x0, x1
   8ad18:	17fffe12 	b	8a560 <_vfiprintf_r+0xd20>
   8ad1c:	f9403fe2 	ldr	x2, [sp, #120]
   8ad20:	b94067e0 	ldr	w0, [sp, #100]
   8ad24:	b90067e1 	str	w1, [sp, #100]
   8ad28:	8b20c040 	add	x0, x2, w0, sxtw
   8ad2c:	17fffdfe 	b	8a524 <_vfiprintf_r+0xce4>
   8ad30:	b94067e0 	ldr	w0, [sp, #100]
   8ad34:	11002001 	add	w1, w0, #0x8
   8ad38:	7100003f 	cmp	w1, #0x0
   8ad3c:	54000ced 	b.le	8aed8 <_vfiprintf_r+0x1698>
   8ad40:	91002f02 	add	x2, x24, #0xb
   8ad44:	aa1803e0 	mov	x0, x24
   8ad48:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8ad4c:	b90067e1 	str	w1, [sp, #100]
   8ad50:	17fffd75 	b	8a324 <_vfiprintf_r+0xae4>
   8ad54:	910403e4 	add	x4, sp, #0x100
   8ad58:	910423e2 	add	x2, sp, #0x108
   8ad5c:	aa1303e0 	mov	x0, x19
   8ad60:	d2800003 	mov	x3, #0x0                   	// #0
   8ad64:	d2800001 	mov	x1, #0x0                   	// #0
   8ad68:	b9006be8 	str	w8, [sp, #104]
   8ad6c:	94000a95 	bl	8d7c0 <_wcsrtombs_r>
   8ad70:	2a0003f9 	mov	w25, w0
   8ad74:	b9406be8 	ldr	w8, [sp, #104]
   8ad78:	3100041f 	cmn	w0, #0x1
   8ad7c:	54003160 	b.eq	8b3a8 <_vfiprintf_r+0x1b68>  // b.none
   8ad80:	f90087fc 	str	x28, [sp, #264]
   8ad84:	17ffff5d 	b	8aaf8 <_vfiprintf_r+0x12b8>
   8ad88:	f94047f8 	ldr	x24, [sp, #136]
   8ad8c:	52800004 	mov	w4, #0x0                   	// #0
   8ad90:	52800003 	mov	w3, #0x0                   	// #0
   8ad94:	f90037ff 	str	xzr, [sp, #104]
   8ad98:	17fffdd5 	b	8a4ec <_vfiprintf_r+0xcac>
   8ad9c:	f9403fe2 	ldr	x2, [sp, #120]
   8ada0:	b94067e0 	ldr	w0, [sp, #100]
   8ada4:	b90067e1 	str	w1, [sp, #100]
   8ada8:	8b20c040 	add	x0, x2, w0, sxtw
   8adac:	17fffe21 	b	8a630 <_vfiprintf_r+0xdf0>
   8adb0:	f9403fe2 	ldr	x2, [sp, #120]
   8adb4:	b94067e0 	ldr	w0, [sp, #100]
   8adb8:	b90067e1 	str	w1, [sp, #100]
   8adbc:	8b20c042 	add	x2, x2, w0, sxtw
   8adc0:	aa1803e0 	mov	x0, x24
   8adc4:	aa0203f8 	mov	x24, x2
   8adc8:	17fffd87 	b	8a3e4 <_vfiprintf_r+0xba4>
   8adcc:	f9403fe4 	ldr	x4, [sp, #120]
   8add0:	f90047f8 	str	x24, [sp, #136]
   8add4:	b94067e2 	ldr	w2, [sp, #100]
   8add8:	b90067e1 	str	w1, [sp, #100]
   8addc:	8b22c082 	add	x2, x4, w2, sxtw
   8ade0:	aa0203f8 	mov	x24, x2
   8ade4:	17fffd28 	b	8a284 <_vfiprintf_r+0xa44>
   8ade8:	aa1703fb 	mov	x27, x23
   8adec:	5280002b 	mov	w11, #0x1                   	// #1
   8adf0:	52800001 	mov	w1, #0x0                   	// #0
   8adf4:	17fffb83 	b	89c00 <_vfiprintf_r+0x3c0>
   8adf8:	37f81780 	tbnz	w0, #31, 8b0e8 <_vfiprintf_r+0x18a8>
   8adfc:	91003f01 	add	x1, x24, #0xf
   8ae00:	aa1803e0 	mov	x0, x24
   8ae04:	927df038 	and	x24, x1, #0xfffffffffffffff8
   8ae08:	f9400000 	ldr	x0, [x0]
   8ae0c:	7940c3e1 	ldrh	w1, [sp, #96]
   8ae10:	79000001 	strh	w1, [x0]
   8ae14:	17fffac1 	b	89918 <_vfiprintf_r+0xd8>
   8ae18:	37f81fc0 	tbnz	w0, #31, 8b210 <_vfiprintf_r+0x19d0>
   8ae1c:	91002f01 	add	x1, x24, #0xb
   8ae20:	aa1803e0 	mov	x0, x24
   8ae24:	927df038 	and	x24, x1, #0xfffffffffffffff8
   8ae28:	b9800001 	ldrsw	x1, [x0]
   8ae2c:	aa0103e0 	mov	x0, x1
   8ae30:	17fffdcc 	b	8a560 <_vfiprintf_r+0xd20>
   8ae34:	aa1703fb 	mov	x27, x23
   8ae38:	5280002b 	mov	w11, #0x1                   	// #1
   8ae3c:	17fffb56 	b	89b94 <_vfiprintf_r+0x354>
   8ae40:	37f81b20 	tbnz	w0, #31, 8b1a4 <_vfiprintf_r+0x1964>
   8ae44:	aa1803e0 	mov	x0, x24
   8ae48:	91002f01 	add	x1, x24, #0xb
   8ae4c:	927df038 	and	x24, x1, #0xfffffffffffffff8
   8ae50:	b9400001 	ldr	w1, [x0]
   8ae54:	17fffd92 	b	8a49c <_vfiprintf_r+0xc5c>
   8ae58:	37f81ee1 	tbnz	w1, #31, 8b234 <_vfiprintf_r+0x19f4>
   8ae5c:	aa1803e1 	mov	x1, x24
   8ae60:	91002f02 	add	x2, x24, #0xb
   8ae64:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8ae68:	b9400021 	ldr	w1, [x1]
   8ae6c:	17fffecb 	b	8a998 <_vfiprintf_r+0x1158>
   8ae70:	37f81880 	tbnz	w0, #31, 8b180 <_vfiprintf_r+0x1940>
   8ae74:	91002f01 	add	x1, x24, #0xb
   8ae78:	aa1803e0 	mov	x0, x24
   8ae7c:	927df038 	and	x24, x1, #0xfffffffffffffff8
   8ae80:	b9400001 	ldr	w1, [x0]
   8ae84:	52800020 	mov	w0, #0x1                   	// #1
   8ae88:	17fffd87 	b	8a4a4 <_vfiprintf_r+0xc64>
   8ae8c:	b94067e0 	ldr	w0, [sp, #100]
   8ae90:	11002001 	add	w1, w0, #0x8
   8ae94:	7100003f 	cmp	w1, #0x0
   8ae98:	54001ecd 	b.le	8b270 <_vfiprintf_r+0x1a30>
   8ae9c:	91002f02 	add	x2, x24, #0xb
   8aea0:	aa1803e0 	mov	x0, x24
   8aea4:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8aea8:	b90067e1 	str	w1, [sp, #100]
   8aeac:	17fffe4a 	b	8a7d4 <_vfiprintf_r+0xf94>
   8aeb0:	b94067e1 	ldr	w1, [sp, #100]
   8aeb4:	11002022 	add	w2, w1, #0x8
   8aeb8:	7100005f 	cmp	w2, #0x0
   8aebc:	54001f0d 	b.le	8b29c <_vfiprintf_r+0x1a5c>
   8aec0:	aa1803e1 	mov	x1, x24
   8aec4:	91002f04 	add	x4, x24, #0xb
   8aec8:	927df098 	and	x24, x4, #0xfffffffffffffff8
   8aecc:	b90067e2 	str	w2, [sp, #100]
   8aed0:	79400021 	ldrh	w1, [x1]
   8aed4:	17fffeb1 	b	8a998 <_vfiprintf_r+0x1158>
   8aed8:	f9403fe2 	ldr	x2, [sp, #120]
   8aedc:	b94067e0 	ldr	w0, [sp, #100]
   8aee0:	b90067e1 	str	w1, [sp, #100]
   8aee4:	8b20c040 	add	x0, x2, w0, sxtw
   8aee8:	17fffd0f 	b	8a324 <_vfiprintf_r+0xae4>
   8aeec:	b94067e0 	ldr	w0, [sp, #100]
   8aef0:	11002001 	add	w1, w0, #0x8
   8aef4:	7100003f 	cmp	w1, #0x0
   8aef8:	54001b2d 	b.le	8b25c <_vfiprintf_r+0x1a1c>
   8aefc:	91002f02 	add	x2, x24, #0xb
   8af00:	aa1803e0 	mov	x0, x24
   8af04:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8af08:	b90067e1 	str	w1, [sp, #100]
   8af0c:	17fffe41 	b	8a810 <_vfiprintf_r+0xfd0>
   8af10:	b94067e0 	ldr	w0, [sp, #100]
   8af14:	11002001 	add	w1, w0, #0x8
   8af18:	7100003f 	cmp	w1, #0x0
   8af1c:	54001b4d 	b.le	8b284 <_vfiprintf_r+0x1a44>
   8af20:	aa1803e0 	mov	x0, x24
   8af24:	91002f02 	add	x2, x24, #0xb
   8af28:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8af2c:	b90067e1 	str	w1, [sp, #100]
   8af30:	79400001 	ldrh	w1, [x0]
   8af34:	17fffd5a 	b	8a49c <_vfiprintf_r+0xc5c>
   8af38:	11000721 	add	w1, w25, #0x1
   8af3c:	aa1303e0 	mov	x0, x19
   8af40:	b9006be8 	str	w8, [sp, #104]
   8af44:	93407c21 	sxtw	x1, w1
   8af48:	9400018e 	bl	8b580 <_malloc_r>
   8af4c:	b9406be8 	ldr	w8, [sp, #104]
   8af50:	aa0003fc 	mov	x28, x0
   8af54:	b40022a0 	cbz	x0, 8b3a8 <_vfiprintf_r+0x1b68>
   8af58:	f90037e0 	str	x0, [sp, #104]
   8af5c:	17fffeec 	b	8ab0c <_vfiprintf_r+0x12cc>
   8af60:	f94052c0 	ldr	x0, [x22, #160]
   8af64:	94000403 	bl	8bf70 <__retarget_lock_release_recursive>
   8af68:	17fffa8d 	b	8999c <_vfiprintf_r+0x15c>
   8af6c:	f94047f8 	ldr	x24, [sp, #136]
   8af70:	2a0303e4 	mov	w4, w3
   8af74:	2a0303f9 	mov	w25, w3
   8af78:	52800003 	mov	w3, #0x0                   	// #0
   8af7c:	17fffd5c 	b	8a4ec <_vfiprintf_r+0xcac>
   8af80:	b94067e0 	ldr	w0, [sp, #100]
   8af84:	11002001 	add	w1, w0, #0x8
   8af88:	7100003f 	cmp	w1, #0x0
   8af8c:	5400076d 	b.le	8b078 <_vfiprintf_r+0x1838>
   8af90:	91002f02 	add	x2, x24, #0xb
   8af94:	aa1803e0 	mov	x0, x24
   8af98:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8af9c:	b90067e1 	str	w1, [sp, #100]
   8afa0:	17fffe45 	b	8a8b4 <_vfiprintf_r+0x1074>
   8afa4:	f9404fe0 	ldr	x0, [sp, #152]
   8afa8:	b9006be4 	str	w4, [sp, #104]
   8afac:	f94057e1 	ldr	x1, [sp, #168]
   8afb0:	cb00039c 	sub	x28, x28, x0
   8afb4:	aa0003e2 	mov	x2, x0
   8afb8:	aa1c03e0 	mov	x0, x28
   8afbc:	b9008be8 	str	w8, [sp, #136]
   8afc0:	f9004be5 	str	x5, [sp, #144]
   8afc4:	f90053e7 	str	x7, [sp, #160]
   8afc8:	b900b3e3 	str	w3, [sp, #176]
   8afcc:	940013b1 	bl	8fe90 <strncpy>
   8afd0:	394006c0 	ldrb	w0, [x22, #1]
   8afd4:	b202e7e6 	mov	x6, #0xcccccccccccccccc    	// #-3689348814741910324
   8afd8:	f9404be5 	ldr	x5, [sp, #144]
   8afdc:	7100001f 	cmp	w0, #0x0
   8afe0:	f94053e7 	ldr	x7, [sp, #160]
   8afe4:	9a9606d6 	cinc	x22, x22, ne	// ne = any
   8afe8:	b9406be4 	ldr	w4, [sp, #104]
   8afec:	5280000b 	mov	w11, #0x0                   	// #0
   8aff0:	b9408be8 	ldr	w8, [sp, #136]
   8aff4:	f29999a6 	movk	x6, #0xcccd
   8aff8:	b940b3e3 	ldr	w3, [sp, #176]
   8affc:	17fffeea 	b	8aba4 <_vfiprintf_r+0x1364>
   8b000:	f9403fe2 	ldr	x2, [sp, #120]
   8b004:	b94067e0 	ldr	w0, [sp, #100]
   8b008:	b90067e1 	str	w1, [sp, #100]
   8b00c:	8b20c040 	add	x0, x2, w0, sxtw
   8b010:	17fffd70 	b	8a5d0 <_vfiprintf_r+0xd90>
   8b014:	aa1c03e0 	mov	x0, x28
   8b018:	b900b3e8 	str	w8, [sp, #176]
   8b01c:	97ffde59 	bl	82980 <strlen>
   8b020:	7100001f 	cmp	w0, #0x0
   8b024:	f94047f8 	ldr	x24, [sp, #136]
   8b028:	2a0003f9 	mov	w25, w0
   8b02c:	b940b3e8 	ldr	w8, [sp, #176]
   8b030:	1a9fa004 	csel	w4, w0, wzr, ge	// ge = tcont
   8b034:	52800003 	mov	w3, #0x0                   	// #0
   8b038:	f90037ff 	str	xzr, [sp, #104]
   8b03c:	17fffd2c 	b	8a4ec <_vfiprintf_r+0xcac>
   8b040:	d000004b 	adrp	x11, 95000 <pmu_event_descr+0x60>
   8b044:	2a0203ef 	mov	w15, w2
   8b048:	9122c16b 	add	x11, x11, #0x8b0
   8b04c:	17fffc24 	b	8a0dc <_vfiprintf_r+0x89c>
   8b050:	d000004b 	adrp	x11, 95000 <pmu_event_descr+0x60>
   8b054:	11000446 	add	w6, w2, #0x1
   8b058:	9122c16b 	add	x11, x11, #0x8b0
   8b05c:	17fffc5e 	b	8a1d4 <_vfiprintf_r+0x994>
   8b060:	aa1303e0 	mov	x0, x19
   8b064:	910443e2 	add	x2, sp, #0x110
   8b068:	aa1603e1 	mov	x1, x22
   8b06c:	97fff9b5 	bl	89740 <__sprint_r.part.0>
   8b070:	34ffdf60 	cbz	w0, 8ac5c <_vfiprintf_r+0x141c>
   8b074:	17fffa96 	b	89acc <_vfiprintf_r+0x28c>
   8b078:	f9403fe2 	ldr	x2, [sp, #120]
   8b07c:	b94067e0 	ldr	w0, [sp, #100]
   8b080:	b90067e1 	str	w1, [sp, #100]
   8b084:	8b20c040 	add	x0, x2, w0, sxtw
   8b088:	17fffe0b 	b	8a8b4 <_vfiprintf_r+0x1074>
   8b08c:	d000004a 	adrp	x10, 95000 <pmu_event_descr+0x60>
   8b090:	2a0b03ed 	mov	w13, w11
   8b094:	9122814a 	add	x10, x10, #0x8a0
   8b098:	17fffb54 	b	89de8 <_vfiprintf_r+0x5a8>
   8b09c:	b940b2c0 	ldr	w0, [x22, #176]
   8b0a0:	370000a0 	tbnz	w0, #0, 8b0b4 <_vfiprintf_r+0x1874>
   8b0a4:	794022c0 	ldrh	w0, [x22, #16]
   8b0a8:	37480060 	tbnz	w0, #9, 8b0b4 <_vfiprintf_r+0x1874>
   8b0ac:	f94052c0 	ldr	x0, [x22, #160]
   8b0b0:	940003b0 	bl	8bf70 <__retarget_lock_release_recursive>
   8b0b4:	12800000 	mov	w0, #0xffffffff            	// #-1
   8b0b8:	b90063e0 	str	w0, [sp, #96]
   8b0bc:	17fffa89 	b	89ae0 <_vfiprintf_r+0x2a0>
   8b0c0:	b94067e1 	ldr	w1, [sp, #100]
   8b0c4:	11002022 	add	w2, w1, #0x8
   8b0c8:	7100005f 	cmp	w2, #0x0
   8b0cc:	540014cd 	b.le	8b364 <_vfiprintf_r+0x1b24>
   8b0d0:	aa1803e1 	mov	x1, x24
   8b0d4:	91002f04 	add	x4, x24, #0xb
   8b0d8:	927df098 	and	x24, x4, #0xfffffffffffffff8
   8b0dc:	b90067e2 	str	w2, [sp, #100]
   8b0e0:	39400021 	ldrb	w1, [x1]
   8b0e4:	17fffe2d 	b	8a998 <_vfiprintf_r+0x1158>
   8b0e8:	b94067e0 	ldr	w0, [sp, #100]
   8b0ec:	11002001 	add	w1, w0, #0x8
   8b0f0:	7100003f 	cmp	w1, #0x0
   8b0f4:	5400144d 	b.le	8b37c <_vfiprintf_r+0x1b3c>
   8b0f8:	91003f02 	add	x2, x24, #0xf
   8b0fc:	aa1803e0 	mov	x0, x24
   8b100:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8b104:	b90067e1 	str	w1, [sp, #100]
   8b108:	17ffff40 	b	8ae08 <_vfiprintf_r+0x15c8>
   8b10c:	b94067e0 	ldr	w0, [sp, #100]
   8b110:	11002001 	add	w1, w0, #0x8
   8b114:	7100003f 	cmp	w1, #0x0
   8b118:	5400150d 	b.le	8b3b8 <_vfiprintf_r+0x1b78>
   8b11c:	91002f02 	add	x2, x24, #0xb
   8b120:	aa1803e0 	mov	x0, x24
   8b124:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8b128:	b90067e1 	str	w1, [sp, #100]
   8b12c:	17fffed4 	b	8ac7c <_vfiprintf_r+0x143c>
   8b130:	b94067e0 	ldr	w0, [sp, #100]
   8b134:	11002001 	add	w1, w0, #0x8
   8b138:	7100003f 	cmp	w1, #0x0
   8b13c:	540015cd 	b.le	8b3f4 <_vfiprintf_r+0x1bb4>
   8b140:	aa1803e0 	mov	x0, x24
   8b144:	91002f02 	add	x2, x24, #0xb
   8b148:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8b14c:	b90067e1 	str	w1, [sp, #100]
   8b150:	39400001 	ldrb	w1, [x0]
   8b154:	17fffcd2 	b	8a49c <_vfiprintf_r+0xc5c>
   8b158:	aa1903f6 	mov	x22, x25
   8b15c:	b940b3e8 	ldr	w8, [sp, #176]
   8b160:	2a1403f9 	mov	w25, w20
   8b164:	b9406bf4 	ldr	w20, [sp, #104]
   8b168:	17fffe64 	b	8aaf8 <_vfiprintf_r+0x12b8>
   8b16c:	79c02320 	ldrsh	w0, [x25, #16]
   8b170:	aa1903f6 	mov	x22, x25
   8b174:	321a0000 	orr	w0, w0, #0x40
   8b178:	79002320 	strh	w0, [x25, #16]
   8b17c:	17fffa55 	b	89ad0 <_vfiprintf_r+0x290>
   8b180:	b94067e0 	ldr	w0, [sp, #100]
   8b184:	11002001 	add	w1, w0, #0x8
   8b188:	7100003f 	cmp	w1, #0x0
   8b18c:	5400120d 	b.le	8b3cc <_vfiprintf_r+0x1b8c>
   8b190:	91002f02 	add	x2, x24, #0xb
   8b194:	aa1803e0 	mov	x0, x24
   8b198:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8b19c:	b90067e1 	str	w1, [sp, #100]
   8b1a0:	17ffff38 	b	8ae80 <_vfiprintf_r+0x1640>
   8b1a4:	b94067e0 	ldr	w0, [sp, #100]
   8b1a8:	11002001 	add	w1, w0, #0x8
   8b1ac:	7100003f 	cmp	w1, #0x0
   8b1b0:	5400138d 	b.le	8b420 <_vfiprintf_r+0x1be0>
   8b1b4:	aa1803e0 	mov	x0, x24
   8b1b8:	91002f02 	add	x2, x24, #0xb
   8b1bc:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8b1c0:	b90067e1 	str	w1, [sp, #100]
   8b1c4:	b9400001 	ldr	w1, [x0]
   8b1c8:	17fffcb5 	b	8a49c <_vfiprintf_r+0xc5c>
   8b1cc:	37f80740 	tbnz	w0, #31, 8b2b4 <_vfiprintf_r+0x1a74>
   8b1d0:	91003f01 	add	x1, x24, #0xf
   8b1d4:	aa1803e0 	mov	x0, x24
   8b1d8:	927df038 	and	x24, x1, #0xfffffffffffffff8
   8b1dc:	f9400000 	ldr	x0, [x0]
   8b1e0:	b94063e1 	ldr	w1, [sp, #96]
   8b1e4:	b9000001 	str	w1, [x0]
   8b1e8:	17fff9cc 	b	89918 <_vfiprintf_r+0xd8>
   8b1ec:	b94067e0 	ldr	w0, [sp, #100]
   8b1f0:	11002001 	add	w1, w0, #0x8
   8b1f4:	7100003f 	cmp	w1, #0x0
   8b1f8:	540010ad 	b.le	8b40c <_vfiprintf_r+0x1bcc>
   8b1fc:	91002f02 	add	x2, x24, #0xb
   8b200:	aa1803e0 	mov	x0, x24
   8b204:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8b208:	b90067e1 	str	w1, [sp, #100]
   8b20c:	17fffec1 	b	8ad10 <_vfiprintf_r+0x14d0>
   8b210:	b94067e0 	ldr	w0, [sp, #100]
   8b214:	11002001 	add	w1, w0, #0x8
   8b218:	7100003f 	cmp	w1, #0x0
   8b21c:	54000e2d 	b.le	8b3e0 <_vfiprintf_r+0x1ba0>
   8b220:	91002f02 	add	x2, x24, #0xb
   8b224:	aa1803e0 	mov	x0, x24
   8b228:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8b22c:	b90067e1 	str	w1, [sp, #100]
   8b230:	17fffefe 	b	8ae28 <_vfiprintf_r+0x15e8>
   8b234:	b94067e1 	ldr	w1, [sp, #100]
   8b238:	11002022 	add	w2, w1, #0x8
   8b23c:	7100005f 	cmp	w2, #0x0
   8b240:	54000a8d 	b.le	8b390 <_vfiprintf_r+0x1b50>
   8b244:	aa1803e1 	mov	x1, x24
   8b248:	91002f04 	add	x4, x24, #0xb
   8b24c:	927df098 	and	x24, x4, #0xfffffffffffffff8
   8b250:	b90067e2 	str	w2, [sp, #100]
   8b254:	b9400021 	ldr	w1, [x1]
   8b258:	17fffdd0 	b	8a998 <_vfiprintf_r+0x1158>
   8b25c:	f9403fe2 	ldr	x2, [sp, #120]
   8b260:	b94067e0 	ldr	w0, [sp, #100]
   8b264:	b90067e1 	str	w1, [sp, #100]
   8b268:	8b20c040 	add	x0, x2, w0, sxtw
   8b26c:	17fffd69 	b	8a810 <_vfiprintf_r+0xfd0>
   8b270:	f9403fe2 	ldr	x2, [sp, #120]
   8b274:	b94067e0 	ldr	w0, [sp, #100]
   8b278:	b90067e1 	str	w1, [sp, #100]
   8b27c:	8b20c040 	add	x0, x2, w0, sxtw
   8b280:	17fffd55 	b	8a7d4 <_vfiprintf_r+0xf94>
   8b284:	f9403fe2 	ldr	x2, [sp, #120]
   8b288:	b94067e0 	ldr	w0, [sp, #100]
   8b28c:	b90067e1 	str	w1, [sp, #100]
   8b290:	8b20c040 	add	x0, x2, w0, sxtw
   8b294:	79400001 	ldrh	w1, [x0]
   8b298:	17fffc81 	b	8a49c <_vfiprintf_r+0xc5c>
   8b29c:	f9403fe4 	ldr	x4, [sp, #120]
   8b2a0:	b94067e1 	ldr	w1, [sp, #100]
   8b2a4:	b90067e2 	str	w2, [sp, #100]
   8b2a8:	8b21c081 	add	x1, x4, w1, sxtw
   8b2ac:	79400021 	ldrh	w1, [x1]
   8b2b0:	17fffdba 	b	8a998 <_vfiprintf_r+0x1158>
   8b2b4:	b94067e0 	ldr	w0, [sp, #100]
   8b2b8:	11002001 	add	w1, w0, #0x8
   8b2bc:	7100003f 	cmp	w1, #0x0
   8b2c0:	54000bcd 	b.le	8b438 <_vfiprintf_r+0x1bf8>
   8b2c4:	91003f02 	add	x2, x24, #0xf
   8b2c8:	aa1803e0 	mov	x0, x24
   8b2cc:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8b2d0:	b90067e1 	str	w1, [sp, #100]
   8b2d4:	17ffffc2 	b	8b1dc <_vfiprintf_r+0x199c>
   8b2d8:	b94067e0 	ldr	w0, [sp, #100]
   8b2dc:	11002001 	add	w1, w0, #0x8
   8b2e0:	7100003f 	cmp	w1, #0x0
   8b2e4:	5400024d 	b.le	8b32c <_vfiprintf_r+0x1aec>
   8b2e8:	91003f02 	add	x2, x24, #0xf
   8b2ec:	aa1803e0 	mov	x0, x24
   8b2f0:	927df058 	and	x24, x2, #0xfffffffffffffff8
   8b2f4:	b90067e1 	str	w1, [sp, #100]
   8b2f8:	17fffcae 	b	8a5b0 <_vfiprintf_r+0xd70>
   8b2fc:	b94067e0 	ldr	w0, [sp, #100]
   8b300:	37f80200 	tbnz	w0, #31, 8b340 <_vfiprintf_r+0x1b00>
   8b304:	91002f01 	add	x1, x24, #0xb
   8b308:	927df021 	and	x1, x1, #0xfffffffffffffff8
   8b30c:	b9400303 	ldr	w3, [x24]
   8b310:	aa0103f8 	mov	x24, x1
   8b314:	b90067e0 	str	w0, [sp, #100]
   8b318:	7100007f 	cmp	w3, #0x0
   8b31c:	39400740 	ldrb	w0, [x26, #1]
   8b320:	5a9fa07c 	csinv	w28, w3, wzr, ge	// ge = tcont
   8b324:	aa0203fa 	mov	x26, x2
   8b328:	17fff9d6 	b	89a80 <_vfiprintf_r+0x240>
   8b32c:	f9403fe2 	ldr	x2, [sp, #120]
   8b330:	b94067e0 	ldr	w0, [sp, #100]
   8b334:	b90067e1 	str	w1, [sp, #100]
   8b338:	8b20c040 	add	x0, x2, w0, sxtw
   8b33c:	17fffc9d 	b	8a5b0 <_vfiprintf_r+0xd70>
   8b340:	b94067e0 	ldr	w0, [sp, #100]
   8b344:	11002000 	add	w0, w0, #0x8
   8b348:	7100001f 	cmp	w0, #0x0
   8b34c:	54fffdcc 	b.gt	8b304 <_vfiprintf_r+0x1ac4>
   8b350:	f9403fe4 	ldr	x4, [sp, #120]
   8b354:	aa1803e1 	mov	x1, x24
   8b358:	b94067e3 	ldr	w3, [sp, #100]
   8b35c:	8b23c098 	add	x24, x4, w3, sxtw
   8b360:	17ffffeb 	b	8b30c <_vfiprintf_r+0x1acc>
   8b364:	f9403fe4 	ldr	x4, [sp, #120]
   8b368:	b94067e1 	ldr	w1, [sp, #100]
   8b36c:	b90067e2 	str	w2, [sp, #100]
   8b370:	8b21c081 	add	x1, x4, w1, sxtw
   8b374:	39400021 	ldrb	w1, [x1]
   8b378:	17fffd88 	b	8a998 <_vfiprintf_r+0x1158>
   8b37c:	f9403fe2 	ldr	x2, [sp, #120]
   8b380:	b94067e0 	ldr	w0, [sp, #100]
   8b384:	b90067e1 	str	w1, [sp, #100]
   8b388:	8b20c040 	add	x0, x2, w0, sxtw
   8b38c:	17fffe9f 	b	8ae08 <_vfiprintf_r+0x15c8>
   8b390:	f9403fe4 	ldr	x4, [sp, #120]
   8b394:	b94067e1 	ldr	w1, [sp, #100]
   8b398:	b90067e2 	str	w2, [sp, #100]
   8b39c:	8b21c081 	add	x1, x4, w1, sxtw
   8b3a0:	b9400021 	ldr	w1, [x1]
   8b3a4:	17fffd7d 	b	8a998 <_vfiprintf_r+0x1158>
   8b3a8:	79c022c0 	ldrsh	w0, [x22, #16]
   8b3ac:	321a0000 	orr	w0, w0, #0x40
   8b3b0:	790022c0 	strh	w0, [x22, #16]
   8b3b4:	17fff9c7 	b	89ad0 <_vfiprintf_r+0x290>
   8b3b8:	f9403fe2 	ldr	x2, [sp, #120]
   8b3bc:	b94067e0 	ldr	w0, [sp, #100]
   8b3c0:	b90067e1 	str	w1, [sp, #100]
   8b3c4:	8b20c040 	add	x0, x2, w0, sxtw
   8b3c8:	17fffe2d 	b	8ac7c <_vfiprintf_r+0x143c>
   8b3cc:	f9403fe2 	ldr	x2, [sp, #120]
   8b3d0:	b94067e0 	ldr	w0, [sp, #100]
   8b3d4:	b90067e1 	str	w1, [sp, #100]
   8b3d8:	8b20c040 	add	x0, x2, w0, sxtw
   8b3dc:	17fffea9 	b	8ae80 <_vfiprintf_r+0x1640>
   8b3e0:	f9403fe2 	ldr	x2, [sp, #120]
   8b3e4:	b94067e0 	ldr	w0, [sp, #100]
   8b3e8:	b90067e1 	str	w1, [sp, #100]
   8b3ec:	8b20c040 	add	x0, x2, w0, sxtw
   8b3f0:	17fffe8e 	b	8ae28 <_vfiprintf_r+0x15e8>
   8b3f4:	f9403fe2 	ldr	x2, [sp, #120]
   8b3f8:	b94067e0 	ldr	w0, [sp, #100]
   8b3fc:	b90067e1 	str	w1, [sp, #100]
   8b400:	8b20c040 	add	x0, x2, w0, sxtw
   8b404:	39400001 	ldrb	w1, [x0]
   8b408:	17fffc25 	b	8a49c <_vfiprintf_r+0xc5c>
   8b40c:	f9403fe2 	ldr	x2, [sp, #120]
   8b410:	b94067e0 	ldr	w0, [sp, #100]
   8b414:	b90067e1 	str	w1, [sp, #100]
   8b418:	8b20c040 	add	x0, x2, w0, sxtw
   8b41c:	17fffe3d 	b	8ad10 <_vfiprintf_r+0x14d0>
   8b420:	f9403fe2 	ldr	x2, [sp, #120]
   8b424:	b94067e0 	ldr	w0, [sp, #100]
   8b428:	b90067e1 	str	w1, [sp, #100]
   8b42c:	8b20c040 	add	x0, x2, w0, sxtw
   8b430:	b9400001 	ldr	w1, [x0]
   8b434:	17fffc1a 	b	8a49c <_vfiprintf_r+0xc5c>
   8b438:	f9403fe2 	ldr	x2, [sp, #120]
   8b43c:	b94067e0 	ldr	w0, [sp, #100]
   8b440:	b90067e1 	str	w1, [sp, #100]
   8b444:	8b20c040 	add	x0, x2, w0, sxtw
   8b448:	17ffff65 	b	8b1dc <_vfiprintf_r+0x199c>
   8b44c:	794022c0 	ldrh	w0, [x22, #16]
   8b450:	321a0000 	orr	w0, w0, #0x40
   8b454:	790022c0 	strh	w0, [x22, #16]
   8b458:	17fff998 	b	89ab8 <_vfiprintf_r+0x278>
   8b45c:	00000000 	udf	#0

000000000008b460 <vfiprintf>:
   8b460:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   8b464:	f0000044 	adrp	x4, 96000 <JIS_state_table+0x70>
   8b468:	aa0003e3 	mov	x3, x0
   8b46c:	910003fd 	mov	x29, sp
   8b470:	ad400440 	ldp	q0, q1, [x2]
   8b474:	aa0103e2 	mov	x2, x1
   8b478:	f9410080 	ldr	x0, [x4, #512]
   8b47c:	aa0303e1 	mov	x1, x3
   8b480:	910043e3 	add	x3, sp, #0x10
   8b484:	ad0087e0 	stp	q0, q1, [sp, #16]
   8b488:	97fff8ee 	bl	89840 <_vfiprintf_r>
   8b48c:	a8c37bfd 	ldp	x29, x30, [sp], #48
   8b490:	d65f03c0 	ret
	...

000000000008b4a0 <__sbprintf>:
   8b4a0:	d11443ff 	sub	sp, sp, #0x510
   8b4a4:	a9007bfd 	stp	x29, x30, [sp]
   8b4a8:	910003fd 	mov	x29, sp
   8b4ac:	a90153f3 	stp	x19, x20, [sp, #16]
   8b4b0:	aa0103f3 	mov	x19, x1
   8b4b4:	79402021 	ldrh	w1, [x1, #16]
   8b4b8:	aa0303f4 	mov	x20, x3
   8b4bc:	910443e3 	add	x3, sp, #0x110
   8b4c0:	f9401a66 	ldr	x6, [x19, #48]
   8b4c4:	121e7821 	and	w1, w1, #0xfffffffd
   8b4c8:	f9402265 	ldr	x5, [x19, #64]
   8b4cc:	a9025bf5 	stp	x21, x22, [sp, #32]
   8b4d0:	79402667 	ldrh	w7, [x19, #18]
   8b4d4:	b940b264 	ldr	w4, [x19, #176]
   8b4d8:	aa0203f6 	mov	x22, x2
   8b4dc:	52808002 	mov	w2, #0x400                 	// #1024
   8b4e0:	aa0003f5 	mov	x21, x0
   8b4e4:	9103e3e0 	add	x0, sp, #0xf8
   8b4e8:	f9002fe3 	str	x3, [sp, #88]
   8b4ec:	b90067e2 	str	w2, [sp, #100]
   8b4f0:	7900d3e1 	strh	w1, [sp, #104]
   8b4f4:	7900d7e7 	strh	w7, [sp, #106]
   8b4f8:	f9003be3 	str	x3, [sp, #112]
   8b4fc:	b9007be2 	str	w2, [sp, #120]
   8b500:	b90083ff 	str	wzr, [sp, #128]
   8b504:	f90047e6 	str	x6, [sp, #136]
   8b508:	f9004fe5 	str	x5, [sp, #152]
   8b50c:	b9010be4 	str	w4, [sp, #264]
   8b510:	94000278 	bl	8bef0 <__retarget_lock_init_recursive>
   8b514:	ad400680 	ldp	q0, q1, [x20]
   8b518:	aa1603e2 	mov	x2, x22
   8b51c:	9100c3e3 	add	x3, sp, #0x30
   8b520:	aa1503e0 	mov	x0, x21
   8b524:	910163e1 	add	x1, sp, #0x58
   8b528:	ad0187e0 	stp	q0, q1, [sp, #48]
   8b52c:	97fff8c5 	bl	89840 <_vfiprintf_r>
   8b530:	2a0003f4 	mov	w20, w0
   8b534:	37f800c0 	tbnz	w0, #31, 8b54c <__sbprintf+0xac>
   8b538:	910163e1 	add	x1, sp, #0x58
   8b53c:	aa1503e0 	mov	x0, x21
   8b540:	94000e44 	bl	8ee50 <_fflush_r>
   8b544:	7100001f 	cmp	w0, #0x0
   8b548:	5a9f0294 	csinv	w20, w20, wzr, eq	// eq = none
   8b54c:	7940d3e0 	ldrh	w0, [sp, #104]
   8b550:	36300080 	tbz	w0, #6, 8b560 <__sbprintf+0xc0>
   8b554:	79402260 	ldrh	w0, [x19, #16]
   8b558:	321a0000 	orr	w0, w0, #0x40
   8b55c:	79002260 	strh	w0, [x19, #16]
   8b560:	f9407fe0 	ldr	x0, [sp, #248]
   8b564:	9400026b 	bl	8bf10 <__retarget_lock_close_recursive>
   8b568:	a9407bfd 	ldp	x29, x30, [sp]
   8b56c:	2a1403e0 	mov	w0, w20
   8b570:	a94153f3 	ldp	x19, x20, [sp, #16]
   8b574:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8b578:	911443ff 	add	sp, sp, #0x510
   8b57c:	d65f03c0 	ret

000000000008b580 <_malloc_r>:
   8b580:	a9ba7bfd 	stp	x29, x30, [sp, #-96]!
   8b584:	910003fd 	mov	x29, sp
   8b588:	a90153f3 	stp	x19, x20, [sp, #16]
   8b58c:	91005c33 	add	x19, x1, #0x17
   8b590:	a9025bf5 	stp	x21, x22, [sp, #32]
   8b594:	aa0003f5 	mov	x21, x0
   8b598:	a9046bf9 	stp	x25, x26, [sp, #64]
   8b59c:	f100ba7f 	cmp	x19, #0x2e
   8b5a0:	54000cc8 	b.hi	8b738 <_malloc_r+0x1b8>  // b.pmore
   8b5a4:	f100803f 	cmp	x1, #0x20
   8b5a8:	54001928 	b.hi	8b8cc <_malloc_r+0x34c>  // b.pmore
   8b5ac:	9400087d 	bl	8d7a0 <__malloc_lock>
   8b5b0:	d2800413 	mov	x19, #0x20                  	// #32
   8b5b4:	d2800a01 	mov	x1, #0x50                  	// #80
   8b5b8:	52800080 	mov	w0, #0x4                   	// #4
   8b5bc:	f0000054 	adrp	x20, 96000 <JIS_state_table+0x70>
   8b5c0:	910e4294 	add	x20, x20, #0x390
   8b5c4:	8b010281 	add	x1, x20, x1
   8b5c8:	11000800 	add	w0, w0, #0x2
   8b5cc:	d1004021 	sub	x1, x1, #0x10
   8b5d0:	f9400c22 	ldr	x2, [x1, #24]
   8b5d4:	eb01005f 	cmp	x2, x1
   8b5d8:	54001d61 	b.ne	8b984 <_malloc_r+0x404>  // b.any
   8b5dc:	f9401285 	ldr	x5, [x20, #32]
   8b5e0:	f0000047 	adrp	x7, 96000 <JIS_state_table+0x70>
   8b5e4:	910e80e7 	add	x7, x7, #0x3a0
   8b5e8:	eb0700bf 	cmp	x5, x7
   8b5ec:	54000f80 	b.eq	8b7dc <_malloc_r+0x25c>  // b.none
   8b5f0:	f94004a1 	ldr	x1, [x5, #8]
   8b5f4:	927ef421 	and	x1, x1, #0xfffffffffffffffc
   8b5f8:	cb130022 	sub	x2, x1, x19
   8b5fc:	f1007c5f 	cmp	x2, #0x1f
   8b600:	540028cc 	b.gt	8bb18 <_malloc_r+0x598>
   8b604:	a9021e87 	stp	x7, x7, [x20, #32]
   8b608:	b6f81722 	tbz	x2, #63, 8b8ec <_malloc_r+0x36c>
   8b60c:	f9400686 	ldr	x6, [x20, #8]
   8b610:	f107fc3f 	cmp	x1, #0x1ff
   8b614:	54001fc8 	b.hi	8ba0c <_malloc_r+0x48c>  // b.pmore
   8b618:	d343fc22 	lsr	x2, x1, #3
   8b61c:	d2800023 	mov	x3, #0x1                   	// #1
   8b620:	11000441 	add	w1, w2, #0x1
   8b624:	13027c42 	asr	w2, w2, #2
   8b628:	531f7821 	lsl	w1, w1, #1
   8b62c:	9ac22062 	lsl	x2, x3, x2
   8b630:	aa0200c6 	orr	x6, x6, x2
   8b634:	8b21ce81 	add	x1, x20, w1, sxtw #3
   8b638:	f85f0422 	ldr	x2, [x1], #-16
   8b63c:	f9000686 	str	x6, [x20, #8]
   8b640:	a90104a2 	stp	x2, x1, [x5, #16]
   8b644:	f9000825 	str	x5, [x1, #16]
   8b648:	f9000c45 	str	x5, [x2, #24]
   8b64c:	13027c01 	asr	w1, w0, #2
   8b650:	d2800024 	mov	x4, #0x1                   	// #1
   8b654:	9ac12084 	lsl	x4, x4, x1
   8b658:	eb06009f 	cmp	x4, x6
   8b65c:	54000cc8 	b.hi	8b7f4 <_malloc_r+0x274>  // b.pmore
   8b660:	ea06009f 	tst	x4, x6
   8b664:	540000e1 	b.ne	8b680 <_malloc_r+0x100>  // b.any
   8b668:	121e7400 	and	w0, w0, #0xfffffffc
   8b66c:	d503201f 	nop
   8b670:	d37ff884 	lsl	x4, x4, #1
   8b674:	11001000 	add	w0, w0, #0x4
   8b678:	ea06009f 	tst	x4, x6
   8b67c:	54ffffa0 	b.eq	8b670 <_malloc_r+0xf0>  // b.none
   8b680:	928001ea 	mov	x10, #0xfffffffffffffff0    	// #-16
   8b684:	11000408 	add	w8, w0, #0x1
   8b688:	2a0003e9 	mov	w9, w0
   8b68c:	531f7908 	lsl	w8, w8, #1
   8b690:	8b28cd48 	add	x8, x10, w8, sxtw #3
   8b694:	8b080288 	add	x8, x20, x8
   8b698:	aa0803e5 	mov	x5, x8
   8b69c:	f9400ca1 	ldr	x1, [x5, #24]
   8b6a0:	14000009 	b	8b6c4 <_malloc_r+0x144>
   8b6a4:	f9400422 	ldr	x2, [x1, #8]
   8b6a8:	aa0103e6 	mov	x6, x1
   8b6ac:	f9400c21 	ldr	x1, [x1, #24]
   8b6b0:	927ef442 	and	x2, x2, #0xfffffffffffffffc
   8b6b4:	cb130043 	sub	x3, x2, x19
   8b6b8:	f1007c7f 	cmp	x3, #0x1f
   8b6bc:	54001f0c 	b.gt	8ba9c <_malloc_r+0x51c>
   8b6c0:	b6f820c3 	tbz	x3, #63, 8bad8 <_malloc_r+0x558>
   8b6c4:	eb0100bf 	cmp	x5, x1
   8b6c8:	54fffee1 	b.ne	8b6a4 <_malloc_r+0x124>  // b.any
   8b6cc:	7100f93f 	cmp	w9, #0x3e
   8b6d0:	5400252d 	b.le	8bb74 <_malloc_r+0x5f4>
   8b6d4:	910040a5 	add	x5, x5, #0x10
   8b6d8:	11000529 	add	w9, w9, #0x1
   8b6dc:	f240053f 	tst	x9, #0x3
   8b6e0:	54fffde1 	b.ne	8b69c <_malloc_r+0x11c>  // b.any
   8b6e4:	14000005 	b	8b6f8 <_malloc_r+0x178>
   8b6e8:	f85f0501 	ldr	x1, [x8], #-16
   8b6ec:	51000400 	sub	w0, w0, #0x1
   8b6f0:	eb08003f 	cmp	x1, x8
   8b6f4:	54003561 	b.ne	8bda0 <_malloc_r+0x820>  // b.any
   8b6f8:	f240041f 	tst	x0, #0x3
   8b6fc:	54ffff61 	b.ne	8b6e8 <_malloc_r+0x168>  // b.any
   8b700:	f9400680 	ldr	x0, [x20, #8]
   8b704:	8a240000 	bic	x0, x0, x4
   8b708:	f9000680 	str	x0, [x20, #8]
   8b70c:	d37ff884 	lsl	x4, x4, #1
   8b710:	d1000481 	sub	x1, x4, #0x1
   8b714:	eb00003f 	cmp	x1, x0
   8b718:	54000083 	b.cc	8b728 <_malloc_r+0x1a8>  // b.lo, b.ul, b.last
   8b71c:	14000036 	b	8b7f4 <_malloc_r+0x274>
   8b720:	d37ff884 	lsl	x4, x4, #1
   8b724:	11001129 	add	w9, w9, #0x4
   8b728:	ea00009f 	tst	x4, x0
   8b72c:	54ffffa0 	b.eq	8b720 <_malloc_r+0x1a0>  // b.none
   8b730:	2a0903e0 	mov	w0, w9
   8b734:	17ffffd4 	b	8b684 <_malloc_r+0x104>
   8b738:	927cee73 	and	x19, x19, #0xfffffffffffffff0
   8b73c:	b2407be2 	mov	x2, #0x7fffffff            	// #2147483647
   8b740:	eb02027f 	cmp	x19, x2
   8b744:	fa539022 	ccmp	x1, x19, #0x2, ls	// ls = plast
   8b748:	54000c28 	b.hi	8b8cc <_malloc_r+0x34c>  // b.pmore
   8b74c:	94000815 	bl	8d7a0 <__malloc_lock>
   8b750:	f107de7f 	cmp	x19, #0x1f7
   8b754:	54001d89 	b.ls	8bb04 <_malloc_r+0x584>  // b.plast
   8b758:	d349fe61 	lsr	x1, x19, #9
   8b75c:	b4000c01 	cbz	x1, 8b8dc <_malloc_r+0x35c>
   8b760:	f100103f 	cmp	x1, #0x4
   8b764:	54001888 	b.hi	8ba74 <_malloc_r+0x4f4>  // b.pmore
   8b768:	d346fe61 	lsr	x1, x19, #6
   8b76c:	1100e420 	add	w0, w1, #0x39
   8b770:	1100e026 	add	w6, w1, #0x38
   8b774:	531f7805 	lsl	w5, w0, #1
   8b778:	937d7ca5 	sbfiz	x5, x5, #3, #32
   8b77c:	f0000054 	adrp	x20, 96000 <JIS_state_table+0x70>
   8b780:	910e4294 	add	x20, x20, #0x390
   8b784:	8b050285 	add	x5, x20, x5
   8b788:	d10040a5 	sub	x5, x5, #0x10
   8b78c:	f9400ca2 	ldr	x2, [x5, #24]
   8b790:	eb0200bf 	cmp	x5, x2
   8b794:	540000e1 	b.ne	8b7b0 <_malloc_r+0x230>  // b.any
   8b798:	17ffff91 	b	8b5dc <_malloc_r+0x5c>
   8b79c:	f9400c44 	ldr	x4, [x2, #24]
   8b7a0:	b6f81163 	tbz	x3, #63, 8b9cc <_malloc_r+0x44c>
   8b7a4:	aa0403e2 	mov	x2, x4
   8b7a8:	eb0400bf 	cmp	x5, x4
   8b7ac:	54fff180 	b.eq	8b5dc <_malloc_r+0x5c>  // b.none
   8b7b0:	f9400441 	ldr	x1, [x2, #8]
   8b7b4:	927ef421 	and	x1, x1, #0xfffffffffffffffc
   8b7b8:	cb130023 	sub	x3, x1, x19
   8b7bc:	f1007c7f 	cmp	x3, #0x1f
   8b7c0:	54fffeed 	b.le	8b79c <_malloc_r+0x21c>
   8b7c4:	f9401285 	ldr	x5, [x20, #32]
   8b7c8:	f0000047 	adrp	x7, 96000 <JIS_state_table+0x70>
   8b7cc:	910e80e7 	add	x7, x7, #0x3a0
   8b7d0:	2a0603e0 	mov	w0, w6
   8b7d4:	eb0700bf 	cmp	x5, x7
   8b7d8:	54fff0c1 	b.ne	8b5f0 <_malloc_r+0x70>  // b.any
   8b7dc:	f9400686 	ldr	x6, [x20, #8]
   8b7e0:	13027c01 	asr	w1, w0, #2
   8b7e4:	d2800024 	mov	x4, #0x1                   	// #1
   8b7e8:	9ac12084 	lsl	x4, x4, x1
   8b7ec:	eb06009f 	cmp	x4, x6
   8b7f0:	54fff389 	b.ls	8b660 <_malloc_r+0xe0>  // b.plast
   8b7f4:	f9400a9a 	ldr	x26, [x20, #16]
   8b7f8:	a90363f7 	stp	x23, x24, [sp, #48]
   8b7fc:	f9400741 	ldr	x1, [x26, #8]
   8b800:	927ef437 	and	x23, x1, #0xfffffffffffffffc
   8b804:	cb1302e0 	sub	x0, x23, x19
   8b808:	f1007c1f 	cmp	x0, #0x1f
   8b80c:	fa53c2e0 	ccmp	x23, x19, #0x0, gt
   8b810:	540009a2 	b.cs	8b944 <_malloc_r+0x3c4>  // b.hs, b.nlast
   8b814:	f00013a1 	adrp	x1, 302000 <irq_handlers+0x1370>
   8b818:	a90573fb 	stp	x27, x28, [sp, #80]
   8b81c:	f000005c 	adrp	x28, 96000 <JIS_state_table+0x70>
   8b820:	f9478c21 	ldr	x1, [x1, #3864]
   8b824:	d28203e3 	mov	x3, #0x101f                	// #4127
   8b828:	f941bf82 	ldr	x2, [x28, #888]
   8b82c:	8b010261 	add	x1, x19, x1
   8b830:	8b030036 	add	x22, x1, x3
   8b834:	91008021 	add	x1, x1, #0x20
   8b838:	b100045f 	cmn	x2, #0x1
   8b83c:	9274ced6 	and	x22, x22, #0xfffffffffffff000
   8b840:	9a8112d6 	csel	x22, x22, x1, ne	// ne = any
   8b844:	aa1503e0 	mov	x0, x21
   8b848:	aa1603e1 	mov	x1, x22
   8b84c:	8b17035b 	add	x27, x26, x23
   8b850:	94001498 	bl	90ab0 <_sbrk_r>
   8b854:	aa0003f8 	mov	x24, x0
   8b858:	b100041f 	cmn	x0, #0x1
   8b85c:	54000660 	b.eq	8b928 <_malloc_r+0x3a8>  // b.none
   8b860:	eb00037f 	cmp	x27, x0
   8b864:	540005e8 	b.hi	8b920 <_malloc_r+0x3a0>  // b.pmore
   8b868:	f00013b9 	adrp	x25, 302000 <irq_handlers+0x1370>
   8b86c:	b94ee323 	ldr	w3, [x25, #3808]
   8b870:	0b160063 	add	w3, w3, w22
   8b874:	b90ee323 	str	w3, [x25, #3808]
   8b878:	2a0303e0 	mov	w0, w3
   8b87c:	540018a1 	b.ne	8bb90 <_malloc_r+0x610>  // b.any
   8b880:	f2402f1f 	tst	x24, #0xfff
   8b884:	54001861 	b.ne	8bb90 <_malloc_r+0x610>  // b.any
   8b888:	f9400a98 	ldr	x24, [x20, #16]
   8b88c:	8b1602f6 	add	x22, x23, x22
   8b890:	b24002d6 	orr	x22, x22, #0x1
   8b894:	f9000716 	str	x22, [x24, #8]
   8b898:	f00013a0 	adrp	x0, 302000 <irq_handlers+0x1370>
   8b89c:	93407c63 	sxtw	x3, w3
   8b8a0:	f9478801 	ldr	x1, [x0, #3856]
   8b8a4:	eb01007f 	cmp	x3, x1
   8b8a8:	54000049 	b.ls	8b8b0 <_malloc_r+0x330>  // b.plast
   8b8ac:	f9078803 	str	x3, [x0, #3856]
   8b8b0:	f00013a0 	adrp	x0, 302000 <irq_handlers+0x1370>
   8b8b4:	f9478401 	ldr	x1, [x0, #3848]
   8b8b8:	eb01007f 	cmp	x3, x1
   8b8bc:	54000049 	b.ls	8b8c4 <_malloc_r+0x344>  // b.plast
   8b8c0:	f9078403 	str	x3, [x0, #3848]
   8b8c4:	aa1803fa 	mov	x26, x24
   8b8c8:	1400001a 	b	8b930 <_malloc_r+0x3b0>
   8b8cc:	52800180 	mov	w0, #0xc                   	// #12
   8b8d0:	d280001a 	mov	x26, #0x0                   	// #0
   8b8d4:	b90002a0 	str	w0, [x21]
   8b8d8:	1400000c 	b	8b908 <_malloc_r+0x388>
   8b8dc:	d2808005 	mov	x5, #0x400                 	// #1024
   8b8e0:	52800800 	mov	w0, #0x40                  	// #64
   8b8e4:	528007e6 	mov	w6, #0x3f                  	// #63
   8b8e8:	17ffffa5 	b	8b77c <_malloc_r+0x1fc>
   8b8ec:	8b0100a1 	add	x1, x5, x1
   8b8f0:	aa1503e0 	mov	x0, x21
   8b8f4:	910040ba 	add	x26, x5, #0x10
   8b8f8:	f9400422 	ldr	x2, [x1, #8]
   8b8fc:	b2400042 	orr	x2, x2, #0x1
   8b900:	f9000422 	str	x2, [x1, #8]
   8b904:	940007ab 	bl	8d7b0 <__malloc_unlock>
   8b908:	a94153f3 	ldp	x19, x20, [sp, #16]
   8b90c:	aa1a03e0 	mov	x0, x26
   8b910:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8b914:	a9446bf9 	ldp	x25, x26, [sp, #64]
   8b918:	a8c67bfd 	ldp	x29, x30, [sp], #96
   8b91c:	d65f03c0 	ret
   8b920:	eb14035f 	cmp	x26, x20
   8b924:	540012e0 	b.eq	8bb80 <_malloc_r+0x600>  // b.none
   8b928:	f9400a9a 	ldr	x26, [x20, #16]
   8b92c:	f9400756 	ldr	x22, [x26, #8]
   8b930:	927ef6c0 	and	x0, x22, #0xfffffffffffffffc
   8b934:	eb130000 	subs	x0, x0, x19
   8b938:	fa5f2804 	ccmp	x0, #0x1f, #0x4, cs	// cs = hs, nlast
   8b93c:	54001bad 	b.le	8bcb0 <_malloc_r+0x730>
   8b940:	a94573fb 	ldp	x27, x28, [sp, #80]
   8b944:	8b130343 	add	x3, x26, x19
   8b948:	b2400261 	orr	x1, x19, #0x1
   8b94c:	f9000741 	str	x1, [x26, #8]
   8b950:	f9000a83 	str	x3, [x20, #16]
   8b954:	b2400000 	orr	x0, x0, #0x1
   8b958:	f9000460 	str	x0, [x3, #8]
   8b95c:	9100435a 	add	x26, x26, #0x10
   8b960:	aa1503e0 	mov	x0, x21
   8b964:	94000793 	bl	8d7b0 <__malloc_unlock>
   8b968:	a94153f3 	ldp	x19, x20, [sp, #16]
   8b96c:	aa1a03e0 	mov	x0, x26
   8b970:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8b974:	a94363f7 	ldp	x23, x24, [sp, #48]
   8b978:	a9446bf9 	ldp	x25, x26, [sp, #64]
   8b97c:	a8c67bfd 	ldp	x29, x30, [sp], #96
   8b980:	d65f03c0 	ret
   8b984:	a9409041 	ldp	x1, x4, [x2, #8]
   8b988:	9100405a 	add	x26, x2, #0x10
   8b98c:	f9400c43 	ldr	x3, [x2, #24]
   8b990:	aa1503e0 	mov	x0, x21
   8b994:	927ef421 	and	x1, x1, #0xfffffffffffffffc
   8b998:	8b010041 	add	x1, x2, x1
   8b99c:	f9400422 	ldr	x2, [x1, #8]
   8b9a0:	f9000c83 	str	x3, [x4, #24]
   8b9a4:	f9000864 	str	x4, [x3, #16]
   8b9a8:	b2400042 	orr	x2, x2, #0x1
   8b9ac:	f9000422 	str	x2, [x1, #8]
   8b9b0:	94000780 	bl	8d7b0 <__malloc_unlock>
   8b9b4:	a94153f3 	ldp	x19, x20, [sp, #16]
   8b9b8:	aa1a03e0 	mov	x0, x26
   8b9bc:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8b9c0:	a9446bf9 	ldp	x25, x26, [sp, #64]
   8b9c4:	a8c67bfd 	ldp	x29, x30, [sp], #96
   8b9c8:	d65f03c0 	ret
   8b9cc:	8b010041 	add	x1, x2, x1
   8b9d0:	9100405a 	add	x26, x2, #0x10
   8b9d4:	f9400843 	ldr	x3, [x2, #16]
   8b9d8:	aa1503e0 	mov	x0, x21
   8b9dc:	f9400422 	ldr	x2, [x1, #8]
   8b9e0:	f9000c64 	str	x4, [x3, #24]
   8b9e4:	b2400042 	orr	x2, x2, #0x1
   8b9e8:	f9000883 	str	x3, [x4, #16]
   8b9ec:	f9000422 	str	x2, [x1, #8]
   8b9f0:	94000770 	bl	8d7b0 <__malloc_unlock>
   8b9f4:	a94153f3 	ldp	x19, x20, [sp, #16]
   8b9f8:	aa1a03e0 	mov	x0, x26
   8b9fc:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8ba00:	a9446bf9 	ldp	x25, x26, [sp, #64]
   8ba04:	a8c67bfd 	ldp	x29, x30, [sp], #96
   8ba08:	d65f03c0 	ret
   8ba0c:	d349fc22 	lsr	x2, x1, #9
   8ba10:	f127fc3f 	cmp	x1, #0x9ff
   8ba14:	540009a9 	b.ls	8bb48 <_malloc_r+0x5c8>  // b.plast
   8ba18:	f100505f 	cmp	x2, #0x14
   8ba1c:	54001568 	b.hi	8bcc8 <_malloc_r+0x748>  // b.pmore
   8ba20:	11017044 	add	w4, w2, #0x5c
   8ba24:	11016c43 	add	w3, w2, #0x5b
   8ba28:	531f7884 	lsl	w4, w4, #1
   8ba2c:	937d7c84 	sbfiz	x4, x4, #3, #32
   8ba30:	8b040284 	add	x4, x20, x4
   8ba34:	f85f0482 	ldr	x2, [x4], #-16
   8ba38:	eb02009f 	cmp	x4, x2
   8ba3c:	540000a1 	b.ne	8ba50 <_malloc_r+0x4d0>  // b.any
   8ba40:	1400008a 	b	8bc68 <_malloc_r+0x6e8>
   8ba44:	f9400842 	ldr	x2, [x2, #16]
   8ba48:	eb02009f 	cmp	x4, x2
   8ba4c:	540000a0 	b.eq	8ba60 <_malloc_r+0x4e0>  // b.none
   8ba50:	f9400443 	ldr	x3, [x2, #8]
   8ba54:	927ef463 	and	x3, x3, #0xfffffffffffffffc
   8ba58:	eb01007f 	cmp	x3, x1
   8ba5c:	54ffff48 	b.hi	8ba44 <_malloc_r+0x4c4>  // b.pmore
   8ba60:	f9400c44 	ldr	x4, [x2, #24]
   8ba64:	a90110a2 	stp	x2, x4, [x5, #16]
   8ba68:	f9000885 	str	x5, [x4, #16]
   8ba6c:	f9000c45 	str	x5, [x2, #24]
   8ba70:	17fffef7 	b	8b64c <_malloc_r+0xcc>
   8ba74:	f100503f 	cmp	x1, #0x14
   8ba78:	54000749 	b.ls	8bb60 <_malloc_r+0x5e0>  // b.plast
   8ba7c:	f101503f 	cmp	x1, #0x54
   8ba80:	54001348 	b.hi	8bce8 <_malloc_r+0x768>  // b.pmore
   8ba84:	d34cfe61 	lsr	x1, x19, #12
   8ba88:	1101bc20 	add	w0, w1, #0x6f
   8ba8c:	1101b826 	add	w6, w1, #0x6e
   8ba90:	531f7805 	lsl	w5, w0, #1
   8ba94:	937d7ca5 	sbfiz	x5, x5, #3, #32
   8ba98:	17ffff39 	b	8b77c <_malloc_r+0x1fc>
   8ba9c:	f94008c5 	ldr	x5, [x6, #16]
   8baa0:	b2400260 	orr	x0, x19, #0x1
   8baa4:	f90004c0 	str	x0, [x6, #8]
   8baa8:	8b1300c4 	add	x4, x6, x19
   8baac:	b2400068 	orr	x8, x3, #0x1
   8bab0:	910040da 	add	x26, x6, #0x10
   8bab4:	f9000ca1 	str	x1, [x5, #24]
   8bab8:	aa1503e0 	mov	x0, x21
   8babc:	f9000825 	str	x5, [x1, #16]
   8bac0:	a9021284 	stp	x4, x4, [x20, #32]
   8bac4:	a9009c88 	stp	x8, x7, [x4, #8]
   8bac8:	f9000c87 	str	x7, [x4, #24]
   8bacc:	f82268c3 	str	x3, [x6, x2]
   8bad0:	94000738 	bl	8d7b0 <__malloc_unlock>
   8bad4:	17ffff8d 	b	8b908 <_malloc_r+0x388>
   8bad8:	8b0200c2 	add	x2, x6, x2
   8badc:	aa0603fa 	mov	x26, x6
   8bae0:	aa1503e0 	mov	x0, x21
   8bae4:	f9400443 	ldr	x3, [x2, #8]
   8bae8:	f8410f44 	ldr	x4, [x26, #16]!
   8baec:	b2400063 	orr	x3, x3, #0x1
   8baf0:	f9000443 	str	x3, [x2, #8]
   8baf4:	f9000c81 	str	x1, [x4, #24]
   8baf8:	f9000824 	str	x4, [x1, #16]
   8bafc:	9400072d 	bl	8d7b0 <__malloc_unlock>
   8bb00:	17ffff82 	b	8b908 <_malloc_r+0x388>
   8bb04:	d343fe60 	lsr	x0, x19, #3
   8bb08:	11000401 	add	w1, w0, #0x1
   8bb0c:	531f7821 	lsl	w1, w1, #1
   8bb10:	937d7c21 	sbfiz	x1, x1, #3, #32
   8bb14:	17fffeaa 	b	8b5bc <_malloc_r+0x3c>
   8bb18:	8b1300a3 	add	x3, x5, x19
   8bb1c:	b2400273 	orr	x19, x19, #0x1
   8bb20:	f90004b3 	str	x19, [x5, #8]
   8bb24:	b2400044 	orr	x4, x2, #0x1
   8bb28:	a9020e83 	stp	x3, x3, [x20, #32]
   8bb2c:	aa1503e0 	mov	x0, x21
   8bb30:	910040ba 	add	x26, x5, #0x10
   8bb34:	a9009c64 	stp	x4, x7, [x3, #8]
   8bb38:	f9000c67 	str	x7, [x3, #24]
   8bb3c:	f82168a2 	str	x2, [x5, x1]
   8bb40:	9400071c 	bl	8d7b0 <__malloc_unlock>
   8bb44:	17ffff71 	b	8b908 <_malloc_r+0x388>
   8bb48:	d346fc22 	lsr	x2, x1, #6
   8bb4c:	1100e444 	add	w4, w2, #0x39
   8bb50:	1100e043 	add	w3, w2, #0x38
   8bb54:	531f7884 	lsl	w4, w4, #1
   8bb58:	937d7c84 	sbfiz	x4, x4, #3, #32
   8bb5c:	17ffffb5 	b	8ba30 <_malloc_r+0x4b0>
   8bb60:	11017020 	add	w0, w1, #0x5c
   8bb64:	11016c26 	add	w6, w1, #0x5b
   8bb68:	531f7805 	lsl	w5, w0, #1
   8bb6c:	937d7ca5 	sbfiz	x5, x5, #3, #32
   8bb70:	17ffff03 	b	8b77c <_malloc_r+0x1fc>
   8bb74:	11000529 	add	w9, w9, #0x1
   8bb78:	910080a5 	add	x5, x5, #0x20
   8bb7c:	17fffed7 	b	8b6d8 <_malloc_r+0x158>
   8bb80:	f00013b9 	adrp	x25, 302000 <irq_handlers+0x1370>
   8bb84:	b94ee320 	ldr	w0, [x25, #3808]
   8bb88:	0b160000 	add	w0, w0, w22
   8bb8c:	b90ee320 	str	w0, [x25, #3808]
   8bb90:	f941bf81 	ldr	x1, [x28, #888]
   8bb94:	b100043f 	cmn	x1, #0x1
   8bb98:	54000b80 	b.eq	8bd08 <_malloc_r+0x788>  // b.none
   8bb9c:	cb1b031b 	sub	x27, x24, x27
   8bba0:	0b1b0000 	add	w0, w0, w27
   8bba4:	b90ee320 	str	w0, [x25, #3808]
   8bba8:	f2400f1c 	ands	x28, x24, #0xf
   8bbac:	540006a0 	b.eq	8bc80 <_malloc_r+0x700>  // b.none
   8bbb0:	cb1c0318 	sub	x24, x24, x28
   8bbb4:	d282021b 	mov	x27, #0x1010                	// #4112
   8bbb8:	91004318 	add	x24, x24, #0x10
   8bbbc:	cb1c037b 	sub	x27, x27, x28
   8bbc0:	8b160316 	add	x22, x24, x22
   8bbc4:	aa1503e0 	mov	x0, x21
   8bbc8:	cb16037b 	sub	x27, x27, x22
   8bbcc:	92402f7b 	and	x27, x27, #0xfff
   8bbd0:	aa1b03e1 	mov	x1, x27
   8bbd4:	940013b7 	bl	90ab0 <_sbrk_r>
   8bbd8:	b100041f 	cmn	x0, #0x1
   8bbdc:	54000ba0 	b.eq	8bd50 <_malloc_r+0x7d0>  // b.none
   8bbe0:	cb180000 	sub	x0, x0, x24
   8bbe4:	2a1b03e3 	mov	w3, w27
   8bbe8:	8b1b0016 	add	x22, x0, x27
   8bbec:	b94ee320 	ldr	w0, [x25, #3808]
   8bbf0:	b24002d6 	orr	x22, x22, #0x1
   8bbf4:	f9000a98 	str	x24, [x20, #16]
   8bbf8:	0b000063 	add	w3, w3, w0
   8bbfc:	b90ee323 	str	w3, [x25, #3808]
   8bc00:	f9000716 	str	x22, [x24, #8]
   8bc04:	eb14035f 	cmp	x26, x20
   8bc08:	54ffe480 	b.eq	8b898 <_malloc_r+0x318>  // b.none
   8bc0c:	f1007eff 	cmp	x23, #0x1f
   8bc10:	540004c9 	b.ls	8bca8 <_malloc_r+0x728>  // b.plast
   8bc14:	f9400740 	ldr	x0, [x26, #8]
   8bc18:	d0000042 	adrp	x2, 95000 <pmu_event_descr+0x60>
   8bc1c:	d10062e1 	sub	x1, x23, #0x18
   8bc20:	3dc23040 	ldr	q0, [x2, #2240]
   8bc24:	927cec21 	and	x1, x1, #0xfffffffffffffff0
   8bc28:	8b010342 	add	x2, x26, x1
   8bc2c:	92400000 	and	x0, x0, #0x1
   8bc30:	aa010000 	orr	x0, x0, x1
   8bc34:	f9000740 	str	x0, [x26, #8]
   8bc38:	3c808040 	stur	q0, [x2, #8]
   8bc3c:	f1007c3f 	cmp	x1, #0x1f
   8bc40:	54000068 	b.hi	8bc4c <_malloc_r+0x6cc>  // b.pmore
   8bc44:	f9400716 	ldr	x22, [x24, #8]
   8bc48:	17ffff14 	b	8b898 <_malloc_r+0x318>
   8bc4c:	91004341 	add	x1, x26, #0x10
   8bc50:	aa1503e0 	mov	x0, x21
   8bc54:	94000edb 	bl	8f7c0 <_free_r>
   8bc58:	f9400a98 	ldr	x24, [x20, #16]
   8bc5c:	b94ee323 	ldr	w3, [x25, #3808]
   8bc60:	f9400716 	ldr	x22, [x24, #8]
   8bc64:	17ffff0d 	b	8b898 <_malloc_r+0x318>
   8bc68:	13027c63 	asr	w3, w3, #2
   8bc6c:	d2800021 	mov	x1, #0x1                   	// #1
   8bc70:	9ac32021 	lsl	x1, x1, x3
   8bc74:	aa0100c6 	orr	x6, x6, x1
   8bc78:	f9000686 	str	x6, [x20, #8]
   8bc7c:	17ffff7a 	b	8ba64 <_malloc_r+0x4e4>
   8bc80:	8b16031b 	add	x27, x24, x22
   8bc84:	aa1503e0 	mov	x0, x21
   8bc88:	cb1b03fb 	neg	x27, x27
   8bc8c:	92402f7b 	and	x27, x27, #0xfff
   8bc90:	aa1b03e1 	mov	x1, x27
   8bc94:	94001387 	bl	90ab0 <_sbrk_r>
   8bc98:	52800003 	mov	w3, #0x0                   	// #0
   8bc9c:	b100041f 	cmn	x0, #0x1
   8bca0:	54fffa01 	b.ne	8bbe0 <_malloc_r+0x660>  // b.any
   8bca4:	17ffffd2 	b	8bbec <_malloc_r+0x66c>
   8bca8:	d2800020 	mov	x0, #0x1                   	// #1
   8bcac:	f9000700 	str	x0, [x24, #8]
   8bcb0:	aa1503e0 	mov	x0, x21
   8bcb4:	d280001a 	mov	x26, #0x0                   	// #0
   8bcb8:	940006be 	bl	8d7b0 <__malloc_unlock>
   8bcbc:	a94363f7 	ldp	x23, x24, [sp, #48]
   8bcc0:	a94573fb 	ldp	x27, x28, [sp, #80]
   8bcc4:	17ffff11 	b	8b908 <_malloc_r+0x388>
   8bcc8:	f101505f 	cmp	x2, #0x54
   8bccc:	54000228 	b.hi	8bd10 <_malloc_r+0x790>  // b.pmore
   8bcd0:	d34cfc22 	lsr	x2, x1, #12
   8bcd4:	1101bc44 	add	w4, w2, #0x6f
   8bcd8:	1101b843 	add	w3, w2, #0x6e
   8bcdc:	531f7884 	lsl	w4, w4, #1
   8bce0:	937d7c84 	sbfiz	x4, x4, #3, #32
   8bce4:	17ffff53 	b	8ba30 <_malloc_r+0x4b0>
   8bce8:	f105503f 	cmp	x1, #0x154
   8bcec:	54000228 	b.hi	8bd30 <_malloc_r+0x7b0>  // b.pmore
   8bcf0:	d34ffe61 	lsr	x1, x19, #15
   8bcf4:	1101e020 	add	w0, w1, #0x78
   8bcf8:	1101dc26 	add	w6, w1, #0x77
   8bcfc:	531f7805 	lsl	w5, w0, #1
   8bd00:	937d7ca5 	sbfiz	x5, x5, #3, #32
   8bd04:	17fffe9e 	b	8b77c <_malloc_r+0x1fc>
   8bd08:	f901bf98 	str	x24, [x28, #888]
   8bd0c:	17ffffa7 	b	8bba8 <_malloc_r+0x628>
   8bd10:	f105505f 	cmp	x2, #0x154
   8bd14:	54000288 	b.hi	8bd64 <_malloc_r+0x7e4>  // b.pmore
   8bd18:	d34ffc22 	lsr	x2, x1, #15
   8bd1c:	1101e044 	add	w4, w2, #0x78
   8bd20:	1101dc43 	add	w3, w2, #0x77
   8bd24:	531f7884 	lsl	w4, w4, #1
   8bd28:	937d7c84 	sbfiz	x4, x4, #3, #32
   8bd2c:	17ffff41 	b	8ba30 <_malloc_r+0x4b0>
   8bd30:	f115503f 	cmp	x1, #0x554
   8bd34:	54000288 	b.hi	8bd84 <_malloc_r+0x804>  // b.pmore
   8bd38:	d352fe61 	lsr	x1, x19, #18
   8bd3c:	1101f420 	add	w0, w1, #0x7d
   8bd40:	1101f026 	add	w6, w1, #0x7c
   8bd44:	531f7805 	lsl	w5, w0, #1
   8bd48:	937d7ca5 	sbfiz	x5, x5, #3, #32
   8bd4c:	17fffe8c 	b	8b77c <_malloc_r+0x1fc>
   8bd50:	d100439c 	sub	x28, x28, #0x10
   8bd54:	52800003 	mov	w3, #0x0                   	// #0
   8bd58:	8b1c02d6 	add	x22, x22, x28
   8bd5c:	cb1802d6 	sub	x22, x22, x24
   8bd60:	17ffffa3 	b	8bbec <_malloc_r+0x66c>
   8bd64:	f115505f 	cmp	x2, #0x554
   8bd68:	54000168 	b.hi	8bd94 <_malloc_r+0x814>  // b.pmore
   8bd6c:	d352fc22 	lsr	x2, x1, #18
   8bd70:	1101f444 	add	w4, w2, #0x7d
   8bd74:	1101f043 	add	w3, w2, #0x7c
   8bd78:	531f7884 	lsl	w4, w4, #1
   8bd7c:	937d7c84 	sbfiz	x4, x4, #3, #32
   8bd80:	17ffff2c 	b	8ba30 <_malloc_r+0x4b0>
   8bd84:	d280fe05 	mov	x5, #0x7f0                 	// #2032
   8bd88:	52800fe0 	mov	w0, #0x7f                  	// #127
   8bd8c:	52800fc6 	mov	w6, #0x7e                  	// #126
   8bd90:	17fffe7b 	b	8b77c <_malloc_r+0x1fc>
   8bd94:	d280fe04 	mov	x4, #0x7f0                 	// #2032
   8bd98:	52800fc3 	mov	w3, #0x7e                  	// #126
   8bd9c:	17ffff25 	b	8ba30 <_malloc_r+0x4b0>
   8bda0:	f9400680 	ldr	x0, [x20, #8]
   8bda4:	17fffe5a 	b	8b70c <_malloc_r+0x18c>
	...

000000000008bdb0 <_wcrtomb_r>:
   8bdb0:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   8bdb4:	9104f004 	add	x4, x0, #0x13c
   8bdb8:	910003fd 	mov	x29, sp
   8bdbc:	a90153f3 	stp	x19, x20, [sp, #16]
   8bdc0:	aa0303f3 	mov	x19, x3
   8bdc4:	f100027f 	cmp	x19, #0x0
   8bdc8:	f0000043 	adrp	x3, 96000 <JIS_state_table+0x70>
   8bdcc:	9a930093 	csel	x19, x4, x19, eq	// eq = none
   8bdd0:	aa0003f4 	mov	x20, x0
   8bdd4:	f946b864 	ldr	x4, [x3, #3440]
   8bdd8:	aa1303e3 	mov	x3, x19
   8bddc:	b4000121 	cbz	x1, 8be00 <_wcrtomb_r+0x50>
   8bde0:	d63f0080 	blr	x4
   8bde4:	2a0003e1 	mov	w1, w0
   8bde8:	93407c20 	sxtw	x0, w1
   8bdec:	3100043f 	cmn	w1, #0x1
   8bdf0:	54000160 	b.eq	8be1c <_wcrtomb_r+0x6c>  // b.none
   8bdf4:	a94153f3 	ldp	x19, x20, [sp, #16]
   8bdf8:	a8c37bfd 	ldp	x29, x30, [sp], #48
   8bdfc:	d65f03c0 	ret
   8be00:	910083e1 	add	x1, sp, #0x20
   8be04:	52800002 	mov	w2, #0x0                   	// #0
   8be08:	d63f0080 	blr	x4
   8be0c:	2a0003e1 	mov	w1, w0
   8be10:	93407c20 	sxtw	x0, w1
   8be14:	3100043f 	cmn	w1, #0x1
   8be18:	54fffee1 	b.ne	8bdf4 <_wcrtomb_r+0x44>  // b.any
   8be1c:	b900027f 	str	wzr, [x19]
   8be20:	52801141 	mov	w1, #0x8a                  	// #138
   8be24:	b9000281 	str	w1, [x20]
   8be28:	92800000 	mov	x0, #0xffffffffffffffff    	// #-1
   8be2c:	a94153f3 	ldp	x19, x20, [sp, #16]
   8be30:	a8c37bfd 	ldp	x29, x30, [sp], #48
   8be34:	d65f03c0 	ret
	...

000000000008be40 <wcrtomb>:
   8be40:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   8be44:	f0000044 	adrp	x4, 96000 <JIS_state_table+0x70>
   8be48:	f0000043 	adrp	x3, 96000 <JIS_state_table+0x70>
   8be4c:	910003fd 	mov	x29, sp
   8be50:	a90153f3 	stp	x19, x20, [sp, #16]
   8be54:	f100005f 	cmp	x2, #0x0
   8be58:	f9410094 	ldr	x20, [x4, #512]
   8be5c:	9104f284 	add	x4, x20, #0x13c
   8be60:	9a820093 	csel	x19, x4, x2, eq	// eq = none
   8be64:	f946b864 	ldr	x4, [x3, #3440]
   8be68:	b40001a0 	cbz	x0, 8be9c <wcrtomb+0x5c>
   8be6c:	2a0103e2 	mov	w2, w1
   8be70:	aa0003e1 	mov	x1, x0
   8be74:	aa1303e3 	mov	x3, x19
   8be78:	aa1403e0 	mov	x0, x20
   8be7c:	d63f0080 	blr	x4
   8be80:	2a0003e1 	mov	w1, w0
   8be84:	93407c20 	sxtw	x0, w1
   8be88:	3100043f 	cmn	w1, #0x1
   8be8c:	540001a0 	b.eq	8bec0 <wcrtomb+0x80>  // b.none
   8be90:	a94153f3 	ldp	x19, x20, [sp, #16]
   8be94:	a8c37bfd 	ldp	x29, x30, [sp], #48
   8be98:	d65f03c0 	ret
   8be9c:	910083e1 	add	x1, sp, #0x20
   8bea0:	aa1303e3 	mov	x3, x19
   8bea4:	aa1403e0 	mov	x0, x20
   8bea8:	52800002 	mov	w2, #0x0                   	// #0
   8beac:	d63f0080 	blr	x4
   8beb0:	2a0003e1 	mov	w1, w0
   8beb4:	93407c20 	sxtw	x0, w1
   8beb8:	3100043f 	cmn	w1, #0x1
   8bebc:	54fffea1 	b.ne	8be90 <wcrtomb+0x50>  // b.any
   8bec0:	b900027f 	str	wzr, [x19]
   8bec4:	52801141 	mov	w1, #0x8a                  	// #138
   8bec8:	b9000281 	str	w1, [x20]
   8becc:	92800000 	mov	x0, #0xffffffffffffffff    	// #-1
   8bed0:	a94153f3 	ldp	x19, x20, [sp, #16]
   8bed4:	a8c37bfd 	ldp	x29, x30, [sp], #48
   8bed8:	d65f03c0 	ret
   8bedc:	00000000 	udf	#0

000000000008bee0 <__retarget_lock_init>:
   8bee0:	d65f03c0 	ret
	...

000000000008bef0 <__retarget_lock_init_recursive>:
   8bef0:	d65f03c0 	ret
	...

000000000008bf00 <__retarget_lock_close>:
   8bf00:	d65f03c0 	ret
	...

000000000008bf10 <__retarget_lock_close_recursive>:
   8bf10:	d65f03c0 	ret
	...

000000000008bf20 <__retarget_lock_acquire>:
   8bf20:	d65f03c0 	ret
	...

000000000008bf30 <__retarget_lock_acquire_recursive>:
   8bf30:	d65f03c0 	ret
	...

000000000008bf40 <__retarget_lock_try_acquire>:
   8bf40:	52800020 	mov	w0, #0x1                   	// #1
   8bf44:	d65f03c0 	ret
	...

000000000008bf50 <__retarget_lock_try_acquire_recursive>:
   8bf50:	52800020 	mov	w0, #0x1                   	// #1
   8bf54:	d65f03c0 	ret
	...

000000000008bf60 <__retarget_lock_release>:
   8bf60:	d65f03c0 	ret
	...

000000000008bf70 <__retarget_lock_release_recursive>:
   8bf70:	d65f03c0 	ret
	...

000000000008bf80 <currentlocale>:
   8bf80:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
   8bf84:	910003fd 	mov	x29, sp
   8bf88:	a90153f3 	stp	x19, x20, [sp, #16]
   8bf8c:	f0000054 	adrp	x20, 96000 <JIS_state_table+0x70>
   8bf90:	91324294 	add	x20, x20, #0xc90
   8bf94:	a9025bf5 	stp	x21, x22, [sp, #32]
   8bf98:	f0000055 	adrp	x21, 96000 <JIS_state_table+0x70>
   8bf9c:	913342b5 	add	x21, x21, #0xcd0
   8bfa0:	f9001bf7 	str	x23, [sp, #48]
   8bfa4:	f0000057 	adrp	x23, 96000 <JIS_state_table+0x70>
   8bfa8:	912e82f7 	add	x23, x23, #0xba0
   8bfac:	f0000056 	adrp	x22, 96000 <JIS_state_table+0x70>
   8bfb0:	aa1503f3 	mov	x19, x21
   8bfb4:	9132c2c1 	add	x1, x22, #0xcb0
   8bfb8:	91038294 	add	x20, x20, #0xe0
   8bfbc:	9132c2d6 	add	x22, x22, #0xcb0
   8bfc0:	aa1703e0 	mov	x0, x23
   8bfc4:	9400106f 	bl	90180 <strcpy>
   8bfc8:	aa1303e1 	mov	x1, x19
   8bfcc:	aa1603e0 	mov	x0, x22
   8bfd0:	91008273 	add	x19, x19, #0x20
   8bfd4:	9400102b 	bl	90080 <strcmp>
   8bfd8:	35000120 	cbnz	w0, 8bffc <currentlocale+0x7c>
   8bfdc:	eb14027f 	cmp	x19, x20
   8bfe0:	54ffff41 	b.ne	8bfc8 <currentlocale+0x48>  // b.any
   8bfe4:	a94153f3 	ldp	x19, x20, [sp, #16]
   8bfe8:	aa1703e0 	mov	x0, x23
   8bfec:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8bff0:	f9401bf7 	ldr	x23, [sp, #48]
   8bff4:	a8c47bfd 	ldp	x29, x30, [sp], #64
   8bff8:	d65f03c0 	ret
   8bffc:	d0000053 	adrp	x19, 95000 <pmu_event_descr+0x60>
   8c000:	91234273 	add	x19, x19, #0x8d0
   8c004:	d503201f 	nop
   8c008:	aa1303e1 	mov	x1, x19
   8c00c:	aa1703e0 	mov	x0, x23
   8c010:	94001be8 	bl	92fb0 <strcat>
   8c014:	aa1503e1 	mov	x1, x21
   8c018:	aa1703e0 	mov	x0, x23
   8c01c:	910082b5 	add	x21, x21, #0x20
   8c020:	94001be4 	bl	92fb0 <strcat>
   8c024:	eb1402bf 	cmp	x21, x20
   8c028:	54ffff01 	b.ne	8c008 <currentlocale+0x88>  // b.any
   8c02c:	a94153f3 	ldp	x19, x20, [sp, #16]
   8c030:	aa1703e0 	mov	x0, x23
   8c034:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8c038:	f9401bf7 	ldr	x23, [sp, #48]
   8c03c:	a8c47bfd 	ldp	x29, x30, [sp], #64
   8c040:	d65f03c0 	ret
	...

000000000008c050 <__loadlocale>:
   8c050:	a9b67bfd 	stp	x29, x30, [sp, #-160]!
   8c054:	910003fd 	mov	x29, sp
   8c058:	a90153f3 	stp	x19, x20, [sp, #16]
   8c05c:	937b7c34 	sbfiz	x20, x1, #5, #32
   8c060:	8b140014 	add	x20, x0, x20
   8c064:	aa0203f3 	mov	x19, x2
   8c068:	a9025bf5 	stp	x21, x22, [sp, #32]
   8c06c:	aa0003f6 	mov	x22, x0
   8c070:	aa0203e0 	mov	x0, x2
   8c074:	a90363f7 	stp	x23, x24, [sp, #48]
   8c078:	2a0103f7 	mov	w23, w1
   8c07c:	aa1403e1 	mov	x1, x20
   8c080:	94001000 	bl	90080 <strcmp>
   8c084:	350000e0 	cbnz	w0, 8c0a0 <__loadlocale+0x50>
   8c088:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8c08c:	aa1403e0 	mov	x0, x20
   8c090:	a94153f3 	ldp	x19, x20, [sp, #16]
   8c094:	a94363f7 	ldp	x23, x24, [sp, #48]
   8c098:	a8ca7bfd 	ldp	x29, x30, [sp], #160
   8c09c:	d65f03c0 	ret
   8c0a0:	aa1303e0 	mov	x0, x19
   8c0a4:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c0a8:	b0000055 	adrp	x21, 95000 <pmu_event_descr+0x60>
   8c0ac:	91236021 	add	x1, x1, #0x8d8
   8c0b0:	912382b5 	add	x21, x21, #0x8e0
   8c0b4:	94000ff3 	bl	90080 <strcmp>
   8c0b8:	34000ca0 	cbz	w0, 8c24c <__loadlocale+0x1fc>
   8c0bc:	aa1503e1 	mov	x1, x21
   8c0c0:	aa1303e0 	mov	x0, x19
   8c0c4:	94000fef 	bl	90080 <strcmp>
   8c0c8:	34000b40 	cbz	w0, 8c230 <__loadlocale+0x1e0>
   8c0cc:	39400260 	ldrb	w0, [x19]
   8c0d0:	71010c1f 	cmp	w0, #0x43
   8c0d4:	54000ca0 	b.eq	8c268 <__loadlocale+0x218>  // b.none
   8c0d8:	51018400 	sub	w0, w0, #0x61
   8c0dc:	12001c00 	and	w0, w0, #0xff
   8c0e0:	7100641f 	cmp	w0, #0x19
   8c0e4:	54000a28 	b.hi	8c228 <__loadlocale+0x1d8>  // b.pmore
   8c0e8:	39400660 	ldrb	w0, [x19, #1]
   8c0ec:	51018400 	sub	w0, w0, #0x61
   8c0f0:	12001c00 	and	w0, w0, #0xff
   8c0f4:	7100641f 	cmp	w0, #0x19
   8c0f8:	54000988 	b.hi	8c228 <__loadlocale+0x1d8>  // b.pmore
   8c0fc:	39400a60 	ldrb	w0, [x19, #2]
   8c100:	91000a78 	add	x24, x19, #0x2
   8c104:	51018401 	sub	w1, w0, #0x61
   8c108:	12001c21 	and	w1, w1, #0xff
   8c10c:	7100643f 	cmp	w1, #0x19
   8c110:	54000068 	b.hi	8c11c <__loadlocale+0xcc>  // b.pmore
   8c114:	39400e60 	ldrb	w0, [x19, #3]
   8c118:	91000e78 	add	x24, x19, #0x3
   8c11c:	71017c1f 	cmp	w0, #0x5f
   8c120:	54000cc0 	b.eq	8c2b8 <__loadlocale+0x268>  // b.none
   8c124:	7100b81f 	cmp	w0, #0x2e
   8c128:	54002e40 	b.eq	8c6f0 <__loadlocale+0x6a0>  // b.none
   8c12c:	528017e1 	mov	w1, #0xbf                  	// #191
   8c130:	6a01001f 	tst	w0, w1
   8c134:	540007a1 	b.ne	8c228 <__loadlocale+0x1d8>  // b.any
   8c138:	910203f5 	add	x21, sp, #0x80
   8c13c:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c140:	aa1503e0 	mov	x0, x21
   8c144:	9123c021 	add	x1, x1, #0x8f0
   8c148:	a9046bf9 	stp	x25, x26, [sp, #64]
   8c14c:	9400100d 	bl	90180 <strcpy>
   8c150:	39400300 	ldrb	w0, [x24]
   8c154:	7101001f 	cmp	w0, #0x40
   8c158:	54002d20 	b.eq	8c6fc <__loadlocale+0x6ac>  // b.none
   8c15c:	52800018 	mov	w24, #0x0                   	// #0
   8c160:	52800019 	mov	w25, #0x0                   	// #0
   8c164:	5280001a 	mov	w26, #0x0                   	// #0
   8c168:	394203e1 	ldrb	w1, [sp, #128]
   8c16c:	51010421 	sub	w1, w1, #0x41
   8c170:	7100d03f 	cmp	w1, #0x34
   8c174:	54000748 	b.hi	8c25c <__loadlocale+0x20c>  // b.pmore
   8c178:	b0000040 	adrp	x0, 95000 <pmu_event_descr+0x60>
   8c17c:	9127c000 	add	x0, x0, #0x9f0
   8c180:	a90573fb 	stp	x27, x28, [sp, #80]
   8c184:	78615800 	ldrh	w0, [x0, w1, uxtw #1]
   8c188:	10000061 	adr	x1, 8c194 <__loadlocale+0x144>
   8c18c:	8b20a820 	add	x0, x1, w0, sxth #2
   8c190:	d61f0000 	br	x0
   8c194:	394207e0 	ldrb	w0, [sp, #129]
   8c198:	121a7800 	and	w0, w0, #0xffffffdf
   8c19c:	12001c00 	and	w0, w0, #0xff
   8c1a0:	7101401f 	cmp	w0, #0x50
   8c1a4:	540003e1 	b.ne	8c220 <__loadlocale+0x1d0>  // b.any
   8c1a8:	d2800042 	mov	x2, #0x2                   	// #2
   8c1ac:	aa1503e0 	mov	x0, x21
   8c1b0:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c1b4:	91260021 	add	x1, x1, #0x980
   8c1b8:	94000f36 	bl	8fe90 <strncpy>
   8c1bc:	9101e3e1 	add	x1, sp, #0x78
   8c1c0:	91020be0 	add	x0, sp, #0x82
   8c1c4:	52800142 	mov	w2, #0xa                   	// #10
   8c1c8:	94000eb6 	bl	8fca0 <strtol>
   8c1cc:	f9403fe1 	ldr	x1, [sp, #120]
   8c1d0:	39400021 	ldrb	w1, [x1]
   8c1d4:	35000261 	cbnz	w1, 8c220 <__loadlocale+0x1d0>
   8c1d8:	f10e901f 	cmp	x0, #0x3a4
   8c1dc:	54001e20 	b.eq	8c5a0 <__loadlocale+0x550>  // b.none
   8c1e0:	54002dac 	b.gt	8c794 <__loadlocale+0x744>
   8c1e4:	f10d881f 	cmp	x0, #0x362
   8c1e8:	54002d0c 	b.gt	8c788 <__loadlocale+0x738>
   8c1ec:	f10d441f 	cmp	x0, #0x351
   8c1f0:	54002c0c 	b.gt	8c770 <__loadlocale+0x720>
   8c1f4:	f106d41f 	cmp	x0, #0x1b5
   8c1f8:	54000d80 	b.eq	8c3a8 <__loadlocale+0x358>  // b.none
   8c1fc:	d10b4000 	sub	x0, x0, #0x2d0
   8c200:	f100dc1f 	cmp	x0, #0x37
   8c204:	540000e8 	b.hi	8c220 <__loadlocale+0x1d0>  // b.pmore
   8c208:	d2800021 	mov	x1, #0x1                   	// #1
   8c20c:	f2a00041 	movk	x1, #0x2, lsl #16
   8c210:	f2e01001 	movk	x1, #0x80, lsl #48
   8c214:	9ac02420 	lsr	x0, x1, x0
   8c218:	37000c80 	tbnz	w0, #0, 8c3a8 <__loadlocale+0x358>
   8c21c:	d503201f 	nop
   8c220:	a9446bf9 	ldp	x25, x26, [sp, #64]
   8c224:	a94573fb 	ldp	x27, x28, [sp, #80]
   8c228:	d2800014 	mov	x20, #0x0                   	// #0
   8c22c:	17ffff97 	b	8c088 <__loadlocale+0x38>
   8c230:	910203f5 	add	x21, sp, #0x80
   8c234:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c238:	aa1503e0 	mov	x0, x21
   8c23c:	9123a021 	add	x1, x1, #0x8e8
   8c240:	a9046bf9 	stp	x25, x26, [sp, #64]
   8c244:	94000fcf 	bl	90180 <strcpy>
   8c248:	17ffffc5 	b	8c15c <__loadlocale+0x10c>
   8c24c:	aa1503e1 	mov	x1, x21
   8c250:	aa1303e0 	mov	x0, x19
   8c254:	94000fcb 	bl	90180 <strcpy>
   8c258:	17ffff99 	b	8c0bc <__loadlocale+0x6c>
   8c25c:	a9446bf9 	ldp	x25, x26, [sp, #64]
   8c260:	d2800014 	mov	x20, #0x0                   	// #0
   8c264:	17ffff89 	b	8c088 <__loadlocale+0x38>
   8c268:	39400660 	ldrb	w0, [x19, #1]
   8c26c:	5100b400 	sub	w0, w0, #0x2d
   8c270:	12001c00 	and	w0, w0, #0xff
   8c274:	7100041f 	cmp	w0, #0x1
   8c278:	54fffd88 	b.hi	8c228 <__loadlocale+0x1d8>  // b.pmore
   8c27c:	91000a78 	add	x24, x19, #0x2
   8c280:	a9046bf9 	stp	x25, x26, [sp, #64]
   8c284:	910203f5 	add	x21, sp, #0x80
   8c288:	aa1803e1 	mov	x1, x24
   8c28c:	aa1503e0 	mov	x0, x21
   8c290:	94000fbc 	bl	90180 <strcpy>
   8c294:	aa1503e0 	mov	x0, x21
   8c298:	52800801 	mov	w1, #0x40                  	// #64
   8c29c:	94000b4b 	bl	8efc8 <strchr>
   8c2a0:	b4000040 	cbz	x0, 8c2a8 <__loadlocale+0x258>
   8c2a4:	3900001f 	strb	wzr, [x0]
   8c2a8:	aa1503e0 	mov	x0, x21
   8c2ac:	97ffd9b5 	bl	82980 <strlen>
   8c2b0:	8b000318 	add	x24, x24, x0
   8c2b4:	17ffffa7 	b	8c150 <__loadlocale+0x100>
   8c2b8:	39400700 	ldrb	w0, [x24, #1]
   8c2bc:	51010400 	sub	w0, w0, #0x41
   8c2c0:	12001c00 	and	w0, w0, #0xff
   8c2c4:	7100641f 	cmp	w0, #0x19
   8c2c8:	54fffb08 	b.hi	8c228 <__loadlocale+0x1d8>  // b.pmore
   8c2cc:	39400b00 	ldrb	w0, [x24, #2]
   8c2d0:	51010400 	sub	w0, w0, #0x41
   8c2d4:	12001c00 	and	w0, w0, #0xff
   8c2d8:	7100641f 	cmp	w0, #0x19
   8c2dc:	54fffa68 	b.hi	8c228 <__loadlocale+0x1d8>  // b.pmore
   8c2e0:	39400f00 	ldrb	w0, [x24, #3]
   8c2e4:	91000f18 	add	x24, x24, #0x3
   8c2e8:	17ffff8f 	b	8c124 <__loadlocale+0xd4>
   8c2ec:	b000005b 	adrp	x27, 95000 <pmu_event_descr+0x60>
   8c2f0:	9124a37b 	add	x27, x27, #0x928
   8c2f4:	aa1b03e1 	mov	x1, x27
   8c2f8:	aa1503e0 	mov	x0, x21
   8c2fc:	94001b11 	bl	92f40 <strcasecmp>
   8c300:	340000c0 	cbz	w0, 8c318 <__loadlocale+0x2c8>
   8c304:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c308:	aa1503e0 	mov	x0, x21
   8c30c:	9124c021 	add	x1, x1, #0x930
   8c310:	94001b0c 	bl	92f40 <strcasecmp>
   8c314:	35fff860 	cbnz	w0, 8c220 <__loadlocale+0x1d0>
   8c318:	aa1b03e1 	mov	x1, x27
   8c31c:	aa1503e0 	mov	x0, x21
   8c320:	94000f98 	bl	90180 <strcpy>
   8c324:	d000003b 	adrp	x27, 92000 <_svfiprintf_r+0x1300>
   8c328:	90000022 	adrp	x2, 90000 <_lseek_r+0x40>
   8c32c:	9120837b 	add	x27, x27, #0x820
   8c330:	911f0042 	add	x2, x2, #0x7c0
   8c334:	528000dc 	mov	w28, #0x6                   	// #6
   8c338:	71000aff 	cmp	w23, #0x2
   8c33c:	54001ac0 	b.eq	8c694 <__loadlocale+0x644>  // b.none
   8c340:	71001aff 	cmp	w23, #0x6
   8c344:	54000081 	b.ne	8c354 <__loadlocale+0x304>  // b.any
   8c348:	aa1503e1 	mov	x1, x21
   8c34c:	91060ac0 	add	x0, x22, #0x182
   8c350:	94000f8c 	bl	90180 <strcpy>
   8c354:	aa1303e1 	mov	x1, x19
   8c358:	aa1403e0 	mov	x0, x20
   8c35c:	94000f89 	bl	90180 <strcpy>
   8c360:	aa0003f4 	mov	x20, x0
   8c364:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8c368:	aa1403e0 	mov	x0, x20
   8c36c:	a94153f3 	ldp	x19, x20, [sp, #16]
   8c370:	a94363f7 	ldp	x23, x24, [sp, #48]
   8c374:	a9446bf9 	ldp	x25, x26, [sp, #64]
   8c378:	a94573fb 	ldp	x27, x28, [sp, #80]
   8c37c:	a8ca7bfd 	ldp	x29, x30, [sp], #160
   8c380:	d65f03c0 	ret
   8c384:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c388:	aa1503e0 	mov	x0, x21
   8c38c:	91272021 	add	x1, x1, #0x9c8
   8c390:	94001aec 	bl	92f40 <strcasecmp>
   8c394:	35fff460 	cbnz	w0, 8c220 <__loadlocale+0x1d0>
   8c398:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c39c:	aa1503e0 	mov	x0, x21
   8c3a0:	91274021 	add	x1, x1, #0x9d0
   8c3a4:	94000f77 	bl	90180 <strcpy>
   8c3a8:	d000003b 	adrp	x27, 92000 <_svfiprintf_r+0x1300>
   8c3ac:	90000022 	adrp	x2, 90000 <_lseek_r+0x40>
   8c3b0:	911f437b 	add	x27, x27, #0x7d0
   8c3b4:	911e0042 	add	x2, x2, #0x780
   8c3b8:	5280003c 	mov	w28, #0x1                   	// #1
   8c3bc:	17ffffdf 	b	8c338 <__loadlocale+0x2e8>
   8c3c0:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c3c4:	aa1503e0 	mov	x0, x21
   8c3c8:	91262021 	add	x1, x1, #0x988
   8c3cc:	d2800082 	mov	x2, #0x4                   	// #4
   8c3d0:	94000e48 	bl	8fcf0 <strncasecmp>
   8c3d4:	35fff260 	cbnz	w0, 8c220 <__loadlocale+0x1d0>
   8c3d8:	394213e0 	ldrb	w0, [sp, #132]
   8c3dc:	394217e1 	ldrb	w1, [sp, #133]
   8c3e0:	7100b41f 	cmp	w0, #0x2d
   8c3e4:	1a800020 	csel	w0, w1, w0, eq	// eq = none
   8c3e8:	121a7800 	and	w0, w0, #0xffffffdf
   8c3ec:	12001c00 	and	w0, w0, #0xff
   8c3f0:	7101481f 	cmp	w0, #0x52
   8c3f4:	54001dc0 	b.eq	8c7ac <__loadlocale+0x75c>  // b.none
   8c3f8:	7101541f 	cmp	w0, #0x55
   8c3fc:	54001e20 	b.eq	8c7c0 <__loadlocale+0x770>  // b.none
   8c400:	7101501f 	cmp	w0, #0x54
   8c404:	54fff0e1 	b.ne	8c220 <__loadlocale+0x1d0>  // b.any
   8c408:	aa1503e0 	mov	x0, x21
   8c40c:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c410:	91268021 	add	x1, x1, #0x9a0
   8c414:	94000f5b 	bl	90180 <strcpy>
   8c418:	17ffffe4 	b	8c3a8 <__loadlocale+0x358>
   8c41c:	b000005b 	adrp	x27, 95000 <pmu_event_descr+0x60>
   8c420:	9124e37b 	add	x27, x27, #0x938
   8c424:	aa1b03e1 	mov	x1, x27
   8c428:	aa1503e0 	mov	x0, x21
   8c42c:	94001ac5 	bl	92f40 <strcasecmp>
   8c430:	35ffef80 	cbnz	w0, 8c220 <__loadlocale+0x1d0>
   8c434:	aa1b03e1 	mov	x1, x27
   8c438:	aa1503e0 	mov	x0, x21
   8c43c:	94000f51 	bl	90180 <strcpy>
   8c440:	d000003b 	adrp	x27, 92000 <_svfiprintf_r+0x1300>
   8c444:	90000022 	adrp	x2, 90000 <_lseek_r+0x40>
   8c448:	9133837b 	add	x27, x27, #0xce0
   8c44c:	9127c042 	add	x2, x2, #0x9f0
   8c450:	5280011c 	mov	w28, #0x8                   	// #8
   8c454:	17ffffb9 	b	8c338 <__loadlocale+0x2e8>
   8c458:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c45c:	aa1503e0 	mov	x0, x21
   8c460:	91258021 	add	x1, x1, #0x960
   8c464:	d2800062 	mov	x2, #0x3                   	// #3
   8c468:	94000e22 	bl	8fcf0 <strncasecmp>
   8c46c:	35ffeda0 	cbnz	w0, 8c220 <__loadlocale+0x1d0>
   8c470:	39420fe0 	ldrb	w0, [sp, #131]
   8c474:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c478:	d2800082 	mov	x2, #0x4                   	// #4
   8c47c:	9125a021 	add	x1, x1, #0x968
   8c480:	7100b41f 	cmp	w0, #0x2d
   8c484:	910283e0 	add	x0, sp, #0xa0
   8c488:	9a80141b 	cinc	x27, x0, eq	// eq = none
   8c48c:	d100777b 	sub	x27, x27, #0x1d
   8c490:	aa1b03e0 	mov	x0, x27
   8c494:	94000e17 	bl	8fcf0 <strncasecmp>
   8c498:	35ffec40 	cbnz	w0, 8c220 <__loadlocale+0x1d0>
   8c49c:	39401360 	ldrb	w0, [x27, #4]
   8c4a0:	9101e3e1 	add	x1, sp, #0x78
   8c4a4:	52800142 	mov	w2, #0xa                   	// #10
   8c4a8:	7100b41f 	cmp	w0, #0x2d
   8c4ac:	9a9b1760 	cinc	x0, x27, eq	// eq = none
   8c4b0:	91001000 	add	x0, x0, #0x4
   8c4b4:	94000dfb 	bl	8fca0 <strtol>
   8c4b8:	aa0003fb 	mov	x27, x0
   8c4bc:	d1000400 	sub	x0, x0, #0x1
   8c4c0:	f1003c1f 	cmp	x0, #0xf
   8c4c4:	fa4c9b64 	ccmp	x27, #0xc, #0x4, ls	// ls = plast
   8c4c8:	54ffeac0 	b.eq	8c220 <__loadlocale+0x1d0>  // b.none
   8c4cc:	f9403fe0 	ldr	x0, [sp, #120]
   8c4d0:	39400000 	ldrb	w0, [x0]
   8c4d4:	35ffea60 	cbnz	w0, 8c220 <__loadlocale+0x1d0>
   8c4d8:	aa1503e0 	mov	x0, x21
   8c4dc:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c4e0:	9125c021 	add	x1, x1, #0x970
   8c4e4:	94000f27 	bl	90180 <strcpy>
   8c4e8:	910227e2 	add	x2, sp, #0x89
   8c4ec:	f1002b7f 	cmp	x27, #0xa
   8c4f0:	5400008d 	b.le	8c500 <__loadlocale+0x4b0>
   8c4f4:	91022be2 	add	x2, sp, #0x8a
   8c4f8:	52800620 	mov	w0, #0x31                  	// #49
   8c4fc:	390227e0 	strb	w0, [sp, #137]
   8c500:	b203e7e1 	mov	x1, #0x6666666666666666    	// #7378697629483820646
   8c504:	3900045f 	strb	wzr, [x2, #1]
   8c508:	f28ccce1 	movk	x1, #0x6667
   8c50c:	9b417f61 	smulh	x1, x27, x1
   8c510:	9342fc21 	asr	x1, x1, #2
   8c514:	cb9bfc21 	sub	x1, x1, x27, asr #63
   8c518:	8b010821 	add	x1, x1, x1, lsl #2
   8c51c:	cb010760 	sub	x0, x27, x1, lsl #1
   8c520:	1100c000 	add	w0, w0, #0x30
   8c524:	39000040 	strb	w0, [x2]
   8c528:	17ffffa0 	b	8c3a8 <__loadlocale+0x358>
   8c52c:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c530:	aa1503e0 	mov	x0, x21
   8c534:	91276021 	add	x1, x1, #0x9d8
   8c538:	d2800062 	mov	x2, #0x3                   	// #3
   8c53c:	94000ded 	bl	8fcf0 <strncasecmp>
   8c540:	35ffe700 	cbnz	w0, 8c220 <__loadlocale+0x1d0>
   8c544:	39420fe0 	ldrb	w0, [sp, #131]
   8c548:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c54c:	91278021 	add	x1, x1, #0x9e0
   8c550:	7100b41f 	cmp	w0, #0x2d
   8c554:	910283e0 	add	x0, sp, #0xa0
   8c558:	9a801400 	cinc	x0, x0, eq	// eq = none
   8c55c:	d1007400 	sub	x0, x0, #0x1d
   8c560:	94000ec8 	bl	90080 <strcmp>
   8c564:	35ffe5e0 	cbnz	w0, 8c220 <__loadlocale+0x1d0>
   8c568:	aa1503e0 	mov	x0, x21
   8c56c:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c570:	9127a021 	add	x1, x1, #0x9e8
   8c574:	94000f03 	bl	90180 <strcpy>
   8c578:	17ffff8c 	b	8c3a8 <__loadlocale+0x358>
   8c57c:	b000005b 	adrp	x27, 95000 <pmu_event_descr+0x60>
   8c580:	9125637b 	add	x27, x27, #0x958
   8c584:	aa1b03e1 	mov	x1, x27
   8c588:	aa1503e0 	mov	x0, x21
   8c58c:	94001a6d 	bl	92f40 <strcasecmp>
   8c590:	35ffe480 	cbnz	w0, 8c220 <__loadlocale+0x1d0>
   8c594:	aa1b03e1 	mov	x1, x27
   8c598:	aa1503e0 	mov	x0, x21
   8c59c:	94000ef9 	bl	90180 <strcpy>
   8c5a0:	d000003b 	adrp	x27, 92000 <_svfiprintf_r+0x1300>
   8c5a4:	90000022 	adrp	x2, 90000 <_lseek_r+0x40>
   8c5a8:	912b837b 	add	x27, x27, #0xae0
   8c5ac:	9122c042 	add	x2, x2, #0x8b0
   8c5b0:	5280005c 	mov	w28, #0x2                   	// #2
   8c5b4:	17ffff61 	b	8c338 <__loadlocale+0x2e8>
   8c5b8:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c5bc:	aa1503e0 	mov	x0, x21
   8c5c0:	9126a021 	add	x1, x1, #0x9a8
   8c5c4:	d2800102 	mov	x2, #0x8                   	// #8
   8c5c8:	94000dca 	bl	8fcf0 <strncasecmp>
   8c5cc:	35ffe2a0 	cbnz	w0, 8c220 <__loadlocale+0x1d0>
   8c5d0:	394223e0 	ldrb	w0, [sp, #136]
   8c5d4:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c5d8:	9126e021 	add	x1, x1, #0x9b8
   8c5dc:	7100b41f 	cmp	w0, #0x2d
   8c5e0:	910283e0 	add	x0, sp, #0xa0
   8c5e4:	9a801400 	cinc	x0, x0, eq	// eq = none
   8c5e8:	d1006000 	sub	x0, x0, #0x18
   8c5ec:	94001a55 	bl	92f40 <strcasecmp>
   8c5f0:	35ffe180 	cbnz	w0, 8c220 <__loadlocale+0x1d0>
   8c5f4:	aa1503e0 	mov	x0, x21
   8c5f8:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c5fc:	91270021 	add	x1, x1, #0x9c0
   8c600:	94000ee0 	bl	90180 <strcpy>
   8c604:	17ffff69 	b	8c3a8 <__loadlocale+0x358>
   8c608:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c60c:	aa1503e0 	mov	x0, x21
   8c610:	91250021 	add	x1, x1, #0x940
   8c614:	d2800062 	mov	x2, #0x3                   	// #3
   8c618:	94000db6 	bl	8fcf0 <strncasecmp>
   8c61c:	35ffe020 	cbnz	w0, 8c220 <__loadlocale+0x1d0>
   8c620:	39420fe0 	ldrb	w0, [sp, #131]
   8c624:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c628:	91252021 	add	x1, x1, #0x948
   8c62c:	7100b41f 	cmp	w0, #0x2d
   8c630:	910283e0 	add	x0, sp, #0xa0
   8c634:	9a801400 	cinc	x0, x0, eq	// eq = none
   8c638:	d1007400 	sub	x0, x0, #0x1d
   8c63c:	94001a41 	bl	92f40 <strcasecmp>
   8c640:	35ffdf00 	cbnz	w0, 8c220 <__loadlocale+0x1d0>
   8c644:	aa1503e0 	mov	x0, x21
   8c648:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c64c:	91254021 	add	x1, x1, #0x950
   8c650:	94000ecc 	bl	90180 <strcpy>
   8c654:	d000003b 	adrp	x27, 92000 <_svfiprintf_r+0x1300>
   8c658:	90000022 	adrp	x2, 90000 <_lseek_r+0x40>
   8c65c:	912ec37b 	add	x27, x27, #0xbb0
   8c660:	91250042 	add	x2, x2, #0x940
   8c664:	5280007c 	mov	w28, #0x3                   	// #3
   8c668:	17ffff34 	b	8c338 <__loadlocale+0x2e8>
   8c66c:	b000005b 	adrp	x27, 95000 <pmu_event_descr+0x60>
   8c670:	9123a37b 	add	x27, x27, #0x8e8
   8c674:	aa1b03e1 	mov	x1, x27
   8c678:	aa1503e0 	mov	x0, x21
   8c67c:	94001a31 	bl	92f40 <strcasecmp>
   8c680:	35ffdd00 	cbnz	w0, 8c220 <__loadlocale+0x1d0>
   8c684:	aa1b03e1 	mov	x1, x27
   8c688:	aa1503e0 	mov	x0, x21
   8c68c:	94000ebd 	bl	90180 <strcpy>
   8c690:	17ffff46 	b	8c3a8 <__loadlocale+0x358>
   8c694:	aa1503e1 	mov	x1, x21
   8c698:	91058ac0 	add	x0, x22, #0x162
   8c69c:	f90037e2 	str	x2, [sp, #104]
   8c6a0:	94000eb8 	bl	90180 <strcpy>
   8c6a4:	f94037e2 	ldr	x2, [sp, #104]
   8c6a8:	a90e6ec2 	stp	x2, x27, [x22, #224]
   8c6ac:	aa1503e1 	mov	x1, x21
   8c6b0:	390582dc 	strb	w28, [x22, #352]
   8c6b4:	aa1603e0 	mov	x0, x22
   8c6b8:	9400091e 	bl	8eb30 <__set_ctype>
   8c6bc:	35000138 	cbnz	w24, 8c6e0 <__loadlocale+0x690>
   8c6c0:	7100079f 	cmp	w28, #0x1
   8c6c4:	52000339 	eor	w25, w25, #0x1
   8c6c8:	1a9fd7e0 	cset	w0, gt
   8c6cc:	6a00033f 	tst	w25, w0
   8c6d0:	54000080 	b.eq	8c6e0 <__loadlocale+0x690>  // b.none
   8c6d4:	394203e0 	ldrb	w0, [sp, #128]
   8c6d8:	7101541f 	cmp	w0, #0x55
   8c6dc:	1a9f07f8 	cset	w24, ne	// ne = any
   8c6e0:	7100035f 	cmp	w26, #0x0
   8c6e4:	5a9f0318 	csinv	w24, w24, wzr, eq	// eq = none
   8c6e8:	b900f2d8 	str	w24, [x22, #240]
   8c6ec:	17ffff1a 	b	8c354 <__loadlocale+0x304>
   8c6f0:	91000718 	add	x24, x24, #0x1
   8c6f4:	a9046bf9 	stp	x25, x26, [sp, #64]
   8c6f8:	17fffee3 	b	8c284 <__loadlocale+0x234>
   8c6fc:	a90573fb 	stp	x27, x28, [sp, #80]
   8c700:	9100071b 	add	x27, x24, #0x1
   8c704:	aa1b03e0 	mov	x0, x27
   8c708:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c70c:	52800018 	mov	w24, #0x0                   	// #0
   8c710:	91240021 	add	x1, x1, #0x900
   8c714:	5280003a 	mov	w26, #0x1                   	// #1
   8c718:	94000e5a 	bl	90080 <strcmp>
   8c71c:	2a0003f9 	mov	w25, w0
   8c720:	35000060 	cbnz	w0, 8c72c <__loadlocale+0x6dc>
   8c724:	a94573fb 	ldp	x27, x28, [sp, #80]
   8c728:	17fffe90 	b	8c168 <__loadlocale+0x118>
   8c72c:	aa1b03e0 	mov	x0, x27
   8c730:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c734:	5280001a 	mov	w26, #0x0                   	// #0
   8c738:	91244021 	add	x1, x1, #0x910
   8c73c:	52800039 	mov	w25, #0x1                   	// #1
   8c740:	94000e50 	bl	90080 <strcmp>
   8c744:	2a0003f8 	mov	w24, w0
   8c748:	34fffee0 	cbz	w0, 8c724 <__loadlocale+0x6d4>
   8c74c:	aa1b03e0 	mov	x0, x27
   8c750:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c754:	91248021 	add	x1, x1, #0x920
   8c758:	94000e4a 	bl	90080 <strcmp>
   8c75c:	7100001f 	cmp	w0, #0x0
   8c760:	52800019 	mov	w25, #0x0                   	// #0
   8c764:	a94573fb 	ldp	x27, x28, [sp, #80]
   8c768:	1a9f17f8 	cset	w24, eq	// eq = none
   8c76c:	17fffe7f 	b	8c168 <__loadlocale+0x118>
   8c770:	d10d4800 	sub	x0, x0, #0x352
   8c774:	d28234a1 	mov	x1, #0x11a5                	// #4517
   8c778:	f2a00021 	movk	x1, #0x1, lsl #16
   8c77c:	9ac02420 	lsr	x0, x1, x0
   8c780:	3607d500 	tbz	w0, #0, 8c220 <__loadlocale+0x1d0>
   8c784:	17ffff09 	b	8c3a8 <__loadlocale+0x358>
   8c788:	f10da81f 	cmp	x0, #0x36a
   8c78c:	54ffd4a1 	b.ne	8c220 <__loadlocale+0x1d0>  // b.any
   8c790:	17ffff06 	b	8c3a8 <__loadlocale+0x358>
   8c794:	f111941f 	cmp	x0, #0x465
   8c798:	54ffe080 	b.eq	8c3a8 <__loadlocale+0x358>  // b.none
   8c79c:	d1138800 	sub	x0, x0, #0x4e2
   8c7a0:	f100201f 	cmp	x0, #0x8
   8c7a4:	54ffd3e8 	b.hi	8c220 <__loadlocale+0x1d0>  // b.pmore
   8c7a8:	17ffff00 	b	8c3a8 <__loadlocale+0x358>
   8c7ac:	aa1503e0 	mov	x0, x21
   8c7b0:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c7b4:	91264021 	add	x1, x1, #0x990
   8c7b8:	94000e72 	bl	90180 <strcpy>
   8c7bc:	17fffefb 	b	8c3a8 <__loadlocale+0x358>
   8c7c0:	aa1503e0 	mov	x0, x21
   8c7c4:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c7c8:	91266021 	add	x1, x1, #0x998
   8c7cc:	94000e6d 	bl	90180 <strcpy>
   8c7d0:	17fffef6 	b	8c3a8 <__loadlocale+0x358>
	...

000000000008c7e0 <__get_locale_env>:
   8c7e0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   8c7e4:	910003fd 	mov	x29, sp
   8c7e8:	a90153f3 	stp	x19, x20, [sp, #16]
   8c7ec:	2a0103f4 	mov	w20, w1
   8c7f0:	aa0003f3 	mov	x19, x0
   8c7f4:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c7f8:	91298021 	add	x1, x1, #0xa60
   8c7fc:	94000d9d 	bl	8fe70 <_getenv_r>
   8c800:	b4000060 	cbz	x0, 8c80c <__get_locale_env+0x2c>
   8c804:	39400001 	ldrb	w1, [x0]
   8c808:	35000241 	cbnz	w1, 8c850 <__get_locale_env+0x70>
   8c80c:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c810:	91320021 	add	x1, x1, #0xc80
   8c814:	aa1303e0 	mov	x0, x19
   8c818:	f874d821 	ldr	x1, [x1, w20, sxtw #3]
   8c81c:	94000d95 	bl	8fe70 <_getenv_r>
   8c820:	b4000060 	cbz	x0, 8c82c <__get_locale_env+0x4c>
   8c824:	39400001 	ldrb	w1, [x0]
   8c828:	35000141 	cbnz	w1, 8c850 <__get_locale_env+0x70>
   8c82c:	b0000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8c830:	aa1303e0 	mov	x0, x19
   8c834:	9129a021 	add	x1, x1, #0xa68
   8c838:	94000d8e 	bl	8fe70 <_getenv_r>
   8c83c:	b4000060 	cbz	x0, 8c848 <__get_locale_env+0x68>
   8c840:	39400001 	ldrb	w1, [x0]
   8c844:	35000061 	cbnz	w1, 8c850 <__get_locale_env+0x70>
   8c848:	d0000040 	adrp	x0, 96000 <JIS_state_table+0x70>
   8c84c:	91390000 	add	x0, x0, #0xe40
   8c850:	a94153f3 	ldp	x19, x20, [sp, #16]
   8c854:	a8c27bfd 	ldp	x29, x30, [sp], #32
   8c858:	d65f03c0 	ret
   8c85c:	00000000 	udf	#0

000000000008c860 <_setlocale_r>:
   8c860:	a9ba7bfd 	stp	x29, x30, [sp, #-96]!
   8c864:	910003fd 	mov	x29, sp
   8c868:	a90153f3 	stp	x19, x20, [sp, #16]
   8c86c:	a9025bf5 	stp	x21, x22, [sp, #32]
   8c870:	a90363f7 	stp	x23, x24, [sp, #48]
   8c874:	aa0003f8 	mov	x24, x0
   8c878:	7100183f 	cmp	w1, #0x6
   8c87c:	54000c28 	b.hi	8ca00 <_setlocale_r+0x1a0>  // b.pmore
   8c880:	a9046bf9 	stp	x25, x26, [sp, #64]
   8c884:	aa0203f9 	mov	x25, x2
   8c888:	f9002bfb 	str	x27, [sp, #80]
   8c88c:	2a0103fb 	mov	w27, w1
   8c890:	b4001142 	cbz	x2, 8cab8 <_setlocale_r+0x258>
   8c894:	f00013b7 	adrp	x23, 303000 <saved_categories.0+0xa0>
   8c898:	d0000055 	adrp	x21, 96000 <JIS_state_table+0x70>
   8c89c:	910182f7 	add	x23, x23, #0x60
   8c8a0:	9132c2b5 	add	x21, x21, #0xcb0
   8c8a4:	f00013b6 	adrp	x22, 303000 <saved_categories.0+0xa0>
   8c8a8:	910102d6 	add	x22, x22, #0x40
   8c8ac:	aa1703f3 	mov	x19, x23
   8c8b0:	aa1503f4 	mov	x20, x21
   8c8b4:	910382da 	add	x26, x22, #0xe0
   8c8b8:	aa1403e1 	mov	x1, x20
   8c8bc:	aa1303e0 	mov	x0, x19
   8c8c0:	91008273 	add	x19, x19, #0x20
   8c8c4:	94000e2f 	bl	90180 <strcpy>
   8c8c8:	91008294 	add	x20, x20, #0x20
   8c8cc:	eb1a027f 	cmp	x19, x26
   8c8d0:	54ffff41 	b.ne	8c8b8 <_setlocale_r+0x58>  // b.any
   8c8d4:	39400320 	ldrb	w0, [x25]
   8c8d8:	350005e0 	cbnz	w0, 8c994 <_setlocale_r+0x134>
   8c8dc:	350010fb 	cbnz	w27, 8caf8 <_setlocale_r+0x298>
   8c8e0:	aa1703f6 	mov	x22, x23
   8c8e4:	52800033 	mov	w19, #0x1                   	// #1
   8c8e8:	2a1303e1 	mov	w1, w19
   8c8ec:	aa1803e0 	mov	x0, x24
   8c8f0:	97ffffbc 	bl	8c7e0 <__get_locale_env>
   8c8f4:	aa0003f4 	mov	x20, x0
   8c8f8:	11000673 	add	w19, w19, #0x1
   8c8fc:	97ffd821 	bl	82980 <strlen>
   8c900:	aa0003e2 	mov	x2, x0
   8c904:	aa1403e1 	mov	x1, x20
   8c908:	aa1603e0 	mov	x0, x22
   8c90c:	f1007c5f 	cmp	x2, #0x1f
   8c910:	54000748 	b.hi	8c9f8 <_setlocale_r+0x198>  // b.pmore
   8c914:	910082d6 	add	x22, x22, #0x20
   8c918:	94000e1a 	bl	90180 <strcpy>
   8c91c:	71001e7f 	cmp	w19, #0x7
   8c920:	54fffe41 	b.ne	8c8e8 <_setlocale_r+0x88>  // b.any
   8c924:	d00013ba 	adrp	x26, 302000 <irq_handlers+0x1370>
   8c928:	913e035a 	add	x26, x26, #0xf80
   8c92c:	d0000059 	adrp	x25, 96000 <JIS_state_table+0x70>
   8c930:	aa1a03f6 	mov	x22, x26
   8c934:	aa1703f4 	mov	x20, x23
   8c938:	91324339 	add	x25, x25, #0xc90
   8c93c:	52800033 	mov	w19, #0x1                   	// #1
   8c940:	aa1503e1 	mov	x1, x21
   8c944:	aa1603e0 	mov	x0, x22
   8c948:	94000e0e 	bl	90180 <strcpy>
   8c94c:	aa1403e2 	mov	x2, x20
   8c950:	2a1303e1 	mov	w1, w19
   8c954:	aa1903e0 	mov	x0, x25
   8c958:	97fffdbe 	bl	8c050 <__loadlocale>
   8c95c:	b4000e80 	cbz	x0, 8cb2c <_setlocale_r+0x2cc>
   8c960:	11000673 	add	w19, w19, #0x1
   8c964:	910082d6 	add	x22, x22, #0x20
   8c968:	910082b5 	add	x21, x21, #0x20
   8c96c:	91008294 	add	x20, x20, #0x20
   8c970:	71001e7f 	cmp	w19, #0x7
   8c974:	54fffe61 	b.ne	8c940 <_setlocale_r+0xe0>  // b.any
   8c978:	a94153f3 	ldp	x19, x20, [sp, #16]
   8c97c:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8c980:	a94363f7 	ldp	x23, x24, [sp, #48]
   8c984:	a9446bf9 	ldp	x25, x26, [sp, #64]
   8c988:	f9402bfb 	ldr	x27, [sp, #80]
   8c98c:	a8c67bfd 	ldp	x29, x30, [sp], #96
   8c990:	17fffd7c 	b	8bf80 <currentlocale>
   8c994:	340003fb 	cbz	w27, 8ca10 <_setlocale_r+0x1b0>
   8c998:	aa1903e0 	mov	x0, x25
   8c99c:	97ffd7f9 	bl	82980 <strlen>
   8c9a0:	f1007c1f 	cmp	x0, #0x1f
   8c9a4:	540002a8 	b.hi	8c9f8 <_setlocale_r+0x198>  // b.pmore
   8c9a8:	937b7f60 	sbfiz	x0, x27, #5, #32
   8c9ac:	aa1903e1 	mov	x1, x25
   8c9b0:	8b0002d6 	add	x22, x22, x0
   8c9b4:	aa1603e0 	mov	x0, x22
   8c9b8:	94000df2 	bl	90180 <strcpy>
   8c9bc:	2a1b03e1 	mov	w1, w27
   8c9c0:	aa1603e2 	mov	x2, x22
   8c9c4:	d0000040 	adrp	x0, 96000 <JIS_state_table+0x70>
   8c9c8:	91324000 	add	x0, x0, #0xc90
   8c9cc:	97fffda1 	bl	8c050 <__loadlocale>
   8c9d0:	aa0003f3 	mov	x19, x0
   8c9d4:	97fffd6b 	bl	8bf80 <currentlocale>
   8c9d8:	a9446bf9 	ldp	x25, x26, [sp, #64]
   8c9dc:	f9402bfb 	ldr	x27, [sp, #80]
   8c9e0:	aa1303e0 	mov	x0, x19
   8c9e4:	a94153f3 	ldp	x19, x20, [sp, #16]
   8c9e8:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8c9ec:	a94363f7 	ldp	x23, x24, [sp, #48]
   8c9f0:	a8c67bfd 	ldp	x29, x30, [sp], #96
   8c9f4:	d65f03c0 	ret
   8c9f8:	a9446bf9 	ldp	x25, x26, [sp, #64]
   8c9fc:	f9402bfb 	ldr	x27, [sp, #80]
   8ca00:	528002d5 	mov	w21, #0x16                  	// #22
   8ca04:	d2800013 	mov	x19, #0x0                   	// #0
   8ca08:	b9000315 	str	w21, [x24]
   8ca0c:	17fffff5 	b	8c9e0 <_setlocale_r+0x180>
   8ca10:	aa1903e0 	mov	x0, x25
   8ca14:	528005e1 	mov	w1, #0x2f                  	// #47
   8ca18:	9400096c 	bl	8efc8 <strchr>
   8ca1c:	aa0003f3 	mov	x19, x0
   8ca20:	b5000060 	cbnz	x0, 8ca2c <_setlocale_r+0x1cc>
   8ca24:	1400006d 	b	8cbd8 <_setlocale_r+0x378>
   8ca28:	91000673 	add	x19, x19, #0x1
   8ca2c:	39400660 	ldrb	w0, [x19, #1]
   8ca30:	7100bc1f 	cmp	w0, #0x2f
   8ca34:	54ffffa0 	b.eq	8ca28 <_setlocale_r+0x1c8>  // b.none
   8ca38:	34fffe00 	cbz	w0, 8c9f8 <_setlocale_r+0x198>
   8ca3c:	aa1703fa 	mov	x26, x23
   8ca40:	52800034 	mov	w20, #0x1                   	// #1
   8ca44:	cb190262 	sub	x2, x19, x25
   8ca48:	71007c5f 	cmp	w2, #0x1f
   8ca4c:	54fffd6c 	b.gt	8c9f8 <_setlocale_r+0x198>
   8ca50:	11000442 	add	w2, w2, #0x1
   8ca54:	aa1903e1 	mov	x1, x25
   8ca58:	aa1a03e0 	mov	x0, x26
   8ca5c:	11000694 	add	w20, w20, #0x1
   8ca60:	93407c42 	sxtw	x2, w2
   8ca64:	94000aff 	bl	8f660 <strlcpy>
   8ca68:	39400261 	ldrb	w1, [x19]
   8ca6c:	7100bc3f 	cmp	w1, #0x2f
   8ca70:	540000a1 	b.ne	8ca84 <_setlocale_r+0x224>  // b.any
   8ca74:	d503201f 	nop
   8ca78:	38401e61 	ldrb	w1, [x19, #1]!
   8ca7c:	7100bc3f 	cmp	w1, #0x2f
   8ca80:	54ffffc0 	b.eq	8ca78 <_setlocale_r+0x218>  // b.none
   8ca84:	34000921 	cbz	w1, 8cba8 <_setlocale_r+0x348>
   8ca88:	aa1303e3 	mov	x3, x19
   8ca8c:	d503201f 	nop
   8ca90:	38401c61 	ldrb	w1, [x3, #1]!
   8ca94:	7100bc3f 	cmp	w1, #0x2f
   8ca98:	7a401824 	ccmp	w1, #0x0, #0x4, ne	// ne = any
   8ca9c:	54ffffa1 	b.ne	8ca90 <_setlocale_r+0x230>  // b.any
   8caa0:	9100835a 	add	x26, x26, #0x20
   8caa4:	71001e9f 	cmp	w20, #0x7
   8caa8:	54fff3e0 	b.eq	8c924 <_setlocale_r+0xc4>  // b.none
   8caac:	aa1303f9 	mov	x25, x19
   8cab0:	aa0303f3 	mov	x19, x3
   8cab4:	17ffffe4 	b	8ca44 <_setlocale_r+0x1e4>
   8cab8:	937b7c20 	sbfiz	x0, x1, #5, #32
   8cabc:	d0000041 	adrp	x1, 96000 <JIS_state_table+0x70>
   8cac0:	91324021 	add	x1, x1, #0xc90
   8cac4:	7100037f 	cmp	w27, #0x0
   8cac8:	8b010000 	add	x0, x0, x1
   8cacc:	d0000053 	adrp	x19, 96000 <JIS_state_table+0x70>
   8cad0:	912e8273 	add	x19, x19, #0xba0
   8cad4:	9a800273 	csel	x19, x19, x0, eq	// eq = none
   8cad8:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8cadc:	aa1303e0 	mov	x0, x19
   8cae0:	a94153f3 	ldp	x19, x20, [sp, #16]
   8cae4:	a94363f7 	ldp	x23, x24, [sp, #48]
   8cae8:	a9446bf9 	ldp	x25, x26, [sp, #64]
   8caec:	f9402bfb 	ldr	x27, [sp, #80]
   8caf0:	a8c67bfd 	ldp	x29, x30, [sp], #96
   8caf4:	d65f03c0 	ret
   8caf8:	2a1b03e1 	mov	w1, w27
   8cafc:	aa1803e0 	mov	x0, x24
   8cb00:	97ffff38 	bl	8c7e0 <__get_locale_env>
   8cb04:	aa0003f3 	mov	x19, x0
   8cb08:	97ffd79e 	bl	82980 <strlen>
   8cb0c:	f1007c1f 	cmp	x0, #0x1f
   8cb10:	54fff748 	b.hi	8c9f8 <_setlocale_r+0x198>  // b.pmore
   8cb14:	937b7f60 	sbfiz	x0, x27, #5, #32
   8cb18:	aa1303e1 	mov	x1, x19
   8cb1c:	8b0002d6 	add	x22, x22, x0
   8cb20:	aa1603e0 	mov	x0, x22
   8cb24:	94000d97 	bl	90180 <strcpy>
   8cb28:	17ffffa5 	b	8c9bc <_setlocale_r+0x15c>
   8cb2c:	b0000040 	adrp	x0, 95000 <pmu_event_descr+0x60>
   8cb30:	b9400315 	ldr	w21, [x24]
   8cb34:	91238016 	add	x22, x0, #0x8e0
   8cb38:	52800034 	mov	w20, #0x1                   	// #1
   8cb3c:	6b14027f 	cmp	w19, w20
   8cb40:	540000e1 	b.ne	8cb5c <_setlocale_r+0x2fc>  // b.any
   8cb44:	14000016 	b	8cb9c <_setlocale_r+0x33c>
   8cb48:	11000694 	add	w20, w20, #0x1
   8cb4c:	910082f7 	add	x23, x23, #0x20
   8cb50:	9100835a 	add	x26, x26, #0x20
   8cb54:	6b13029f 	cmp	w20, w19
   8cb58:	54000220 	b.eq	8cb9c <_setlocale_r+0x33c>  // b.none
   8cb5c:	aa1a03e1 	mov	x1, x26
   8cb60:	aa1703e0 	mov	x0, x23
   8cb64:	94000d87 	bl	90180 <strcpy>
   8cb68:	aa1703e2 	mov	x2, x23
   8cb6c:	2a1403e1 	mov	w1, w20
   8cb70:	aa1903e0 	mov	x0, x25
   8cb74:	97fffd37 	bl	8c050 <__loadlocale>
   8cb78:	b5fffe80 	cbnz	x0, 8cb48 <_setlocale_r+0x2e8>
   8cb7c:	aa1603e1 	mov	x1, x22
   8cb80:	aa1703e0 	mov	x0, x23
   8cb84:	94000d7f 	bl	90180 <strcpy>
   8cb88:	aa1703e2 	mov	x2, x23
   8cb8c:	2a1403e1 	mov	w1, w20
   8cb90:	aa1903e0 	mov	x0, x25
   8cb94:	97fffd2f 	bl	8c050 <__loadlocale>
   8cb98:	17ffffec 	b	8cb48 <_setlocale_r+0x2e8>
   8cb9c:	a9446bf9 	ldp	x25, x26, [sp, #64]
   8cba0:	f9402bfb 	ldr	x27, [sp, #80]
   8cba4:	17ffff98 	b	8ca04 <_setlocale_r+0x1a4>
   8cba8:	71001e9f 	cmp	w20, #0x7
   8cbac:	54ffebc0 	b.eq	8c924 <_setlocale_r+0xc4>  // b.none
   8cbb0:	937b7e80 	sbfiz	x0, x20, #5, #32
   8cbb4:	8b0002d6 	add	x22, x22, x0
   8cbb8:	d10082c1 	sub	x1, x22, #0x20
   8cbbc:	aa1603e0 	mov	x0, x22
   8cbc0:	11000694 	add	w20, w20, #0x1
   8cbc4:	94000d6f 	bl	90180 <strcpy>
   8cbc8:	910082d6 	add	x22, x22, #0x20
   8cbcc:	71001e9f 	cmp	w20, #0x7
   8cbd0:	54ffff41 	b.ne	8cbb8 <_setlocale_r+0x358>  // b.any
   8cbd4:	17ffff54 	b	8c924 <_setlocale_r+0xc4>
   8cbd8:	aa1903e0 	mov	x0, x25
   8cbdc:	97ffd769 	bl	82980 <strlen>
   8cbe0:	f1007c1f 	cmp	x0, #0x1f
   8cbe4:	54fff0a8 	b.hi	8c9f8 <_setlocale_r+0x198>  // b.pmore
   8cbe8:	aa1703f3 	mov	x19, x23
   8cbec:	d503201f 	nop
   8cbf0:	aa1303e0 	mov	x0, x19
   8cbf4:	aa1903e1 	mov	x1, x25
   8cbf8:	91008273 	add	x19, x19, #0x20
   8cbfc:	94000d61 	bl	90180 <strcpy>
   8cc00:	eb1a027f 	cmp	x19, x26
   8cc04:	54ffff61 	b.ne	8cbf0 <_setlocale_r+0x390>  // b.any
   8cc08:	17ffff47 	b	8c924 <_setlocale_r+0xc4>
   8cc0c:	00000000 	udf	#0

000000000008cc10 <__locale_mb_cur_max>:
   8cc10:	d0000040 	adrp	x0, 96000 <JIS_state_table+0x70>
   8cc14:	3977c000 	ldrb	w0, [x0, #3568]
   8cc18:	d65f03c0 	ret
   8cc1c:	00000000 	udf	#0

000000000008cc20 <setlocale>:
   8cc20:	d0000043 	adrp	x3, 96000 <JIS_state_table+0x70>
   8cc24:	aa0103e2 	mov	x2, x1
   8cc28:	2a0003e1 	mov	w1, w0
   8cc2c:	f9410060 	ldr	x0, [x3, #512]
   8cc30:	17ffff0c 	b	8c860 <_setlocale_r>
	...

000000000008cc40 <__localeconv_l>:
   8cc40:	91040000 	add	x0, x0, #0x100
   8cc44:	d65f03c0 	ret
	...

000000000008cc50 <_localeconv_r>:
   8cc50:	d0000040 	adrp	x0, 96000 <JIS_state_table+0x70>
   8cc54:	91364000 	add	x0, x0, #0xd90
   8cc58:	d65f03c0 	ret
   8cc5c:	00000000 	udf	#0

000000000008cc60 <localeconv>:
   8cc60:	d0000040 	adrp	x0, 96000 <JIS_state_table+0x70>
   8cc64:	91364000 	add	x0, x0, #0xd90
   8cc68:	d65f03c0 	ret
   8cc6c:	00000000 	udf	#0

000000000008cc70 <_fclose_r>:
   8cc70:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   8cc74:	910003fd 	mov	x29, sp
   8cc78:	f90013f5 	str	x21, [sp, #32]
   8cc7c:	b4000661 	cbz	x1, 8cd48 <_fclose_r+0xd8>
   8cc80:	a90153f3 	stp	x19, x20, [sp, #16]
   8cc84:	aa0103f3 	mov	x19, x1
   8cc88:	aa0003f4 	mov	x20, x0
   8cc8c:	b4000060 	cbz	x0, 8cc98 <_fclose_r+0x28>
   8cc90:	f9402401 	ldr	x1, [x0, #72]
   8cc94:	b4000641 	cbz	x1, 8cd5c <_fclose_r+0xec>
   8cc98:	b940b260 	ldr	w0, [x19, #176]
   8cc9c:	79c02261 	ldrsh	w1, [x19, #16]
   8cca0:	37000500 	tbnz	w0, #0, 8cd40 <_fclose_r+0xd0>
   8cca4:	36480601 	tbz	w1, #9, 8cd64 <_fclose_r+0xf4>
   8cca8:	aa1303e1 	mov	x1, x19
   8ccac:	aa1403e0 	mov	x0, x20
   8ccb0:	940007e4 	bl	8ec40 <__sflush_r>
   8ccb4:	2a0003f5 	mov	w21, w0
   8ccb8:	f9402a62 	ldr	x2, [x19, #80]
   8ccbc:	b40000c2 	cbz	x2, 8ccd4 <_fclose_r+0x64>
   8ccc0:	f9401a61 	ldr	x1, [x19, #48]
   8ccc4:	aa1403e0 	mov	x0, x20
   8ccc8:	d63f0040 	blr	x2
   8cccc:	7100001f 	cmp	w0, #0x0
   8ccd0:	5a9fa2b5 	csinv	w21, w21, wzr, ge	// ge = tcont
   8ccd4:	79402260 	ldrh	w0, [x19, #16]
   8ccd8:	37380620 	tbnz	w0, #7, 8cd9c <_fclose_r+0x12c>
   8ccdc:	f9402e61 	ldr	x1, [x19, #88]
   8cce0:	b40000e1 	cbz	x1, 8ccfc <_fclose_r+0x8c>
   8cce4:	9101d260 	add	x0, x19, #0x74
   8cce8:	eb00003f 	cmp	x1, x0
   8ccec:	54000060 	b.eq	8ccf8 <_fclose_r+0x88>  // b.none
   8ccf0:	aa1403e0 	mov	x0, x20
   8ccf4:	94000ab3 	bl	8f7c0 <_free_r>
   8ccf8:	f9002e7f 	str	xzr, [x19, #88]
   8ccfc:	f9403e61 	ldr	x1, [x19, #120]
   8cd00:	b4000081 	cbz	x1, 8cd10 <_fclose_r+0xa0>
   8cd04:	aa1403e0 	mov	x0, x20
   8cd08:	94000aae 	bl	8f7c0 <_free_r>
   8cd0c:	f9003e7f 	str	xzr, [x19, #120]
   8cd10:	97ffd658 	bl	82670 <__sfp_lock_acquire>
   8cd14:	7900227f 	strh	wzr, [x19, #16]
   8cd18:	b940b260 	ldr	w0, [x19, #176]
   8cd1c:	360003a0 	tbz	w0, #0, 8cd90 <_fclose_r+0x120>
   8cd20:	f9405260 	ldr	x0, [x19, #160]
   8cd24:	97fffc7b 	bl	8bf10 <__retarget_lock_close_recursive>
   8cd28:	97ffd656 	bl	82680 <__sfp_lock_release>
   8cd2c:	a94153f3 	ldp	x19, x20, [sp, #16]
   8cd30:	2a1503e0 	mov	w0, w21
   8cd34:	f94013f5 	ldr	x21, [sp, #32]
   8cd38:	a8c37bfd 	ldp	x29, x30, [sp], #48
   8cd3c:	d65f03c0 	ret
   8cd40:	35fffb41 	cbnz	w1, 8cca8 <_fclose_r+0x38>
   8cd44:	a94153f3 	ldp	x19, x20, [sp, #16]
   8cd48:	52800015 	mov	w21, #0x0                   	// #0
   8cd4c:	2a1503e0 	mov	w0, w21
   8cd50:	f94013f5 	ldr	x21, [sp, #32]
   8cd54:	a8c37bfd 	ldp	x29, x30, [sp], #48
   8cd58:	d65f03c0 	ret
   8cd5c:	97ffd629 	bl	82600 <__sinit>
   8cd60:	17ffffce 	b	8cc98 <_fclose_r+0x28>
   8cd64:	f9405260 	ldr	x0, [x19, #160]
   8cd68:	97fffc72 	bl	8bf30 <__retarget_lock_acquire_recursive>
   8cd6c:	79c02260 	ldrsh	w0, [x19, #16]
   8cd70:	35fff9c0 	cbnz	w0, 8cca8 <_fclose_r+0x38>
   8cd74:	b940b260 	ldr	w0, [x19, #176]
   8cd78:	3707fe60 	tbnz	w0, #0, 8cd44 <_fclose_r+0xd4>
   8cd7c:	f9405260 	ldr	x0, [x19, #160]
   8cd80:	52800015 	mov	w21, #0x0                   	// #0
   8cd84:	97fffc7b 	bl	8bf70 <__retarget_lock_release_recursive>
   8cd88:	a94153f3 	ldp	x19, x20, [sp, #16]
   8cd8c:	17fffff0 	b	8cd4c <_fclose_r+0xdc>
   8cd90:	f9405260 	ldr	x0, [x19, #160]
   8cd94:	97fffc77 	bl	8bf70 <__retarget_lock_release_recursive>
   8cd98:	17ffffe2 	b	8cd20 <_fclose_r+0xb0>
   8cd9c:	f9400e61 	ldr	x1, [x19, #24]
   8cda0:	aa1403e0 	mov	x0, x20
   8cda4:	94000a87 	bl	8f7c0 <_free_r>
   8cda8:	17ffffcd 	b	8ccdc <_fclose_r+0x6c>
   8cdac:	00000000 	udf	#0

000000000008cdb0 <fclose>:
   8cdb0:	d0000042 	adrp	x2, 96000 <JIS_state_table+0x70>
   8cdb4:	aa0003e1 	mov	x1, x0
   8cdb8:	f9410040 	ldr	x0, [x2, #512]
   8cdbc:	17ffffad 	b	8cc70 <_fclose_r>

000000000008cdc0 <memchr>:
   8cdc0:	b4000682 	cbz	x2, 8ce90 <memchr+0xd0>
   8cdc4:	52808025 	mov	w5, #0x401                 	// #1025
   8cdc8:	72a80205 	movk	w5, #0x4010, lsl #16
   8cdcc:	4e010c20 	dup	v0.16b, w1
   8cdd0:	927be803 	and	x3, x0, #0xffffffffffffffe0
   8cdd4:	4e040ca5 	dup	v5.4s, w5
   8cdd8:	f2401009 	ands	x9, x0, #0x1f
   8cddc:	9240104a 	and	x10, x2, #0x1f
   8cde0:	54000200 	b.eq	8ce20 <memchr+0x60>  // b.none
   8cde4:	4cdfa061 	ld1	{v1.16b, v2.16b}, [x3], #32
   8cde8:	d1008124 	sub	x4, x9, #0x20
   8cdec:	ab040042 	adds	x2, x2, x4
   8cdf0:	6e208c23 	cmeq	v3.16b, v1.16b, v0.16b
   8cdf4:	6e208c44 	cmeq	v4.16b, v2.16b, v0.16b
   8cdf8:	4e251c63 	and	v3.16b, v3.16b, v5.16b
   8cdfc:	4e251c84 	and	v4.16b, v4.16b, v5.16b
   8ce00:	4e24bc66 	addp	v6.16b, v3.16b, v4.16b
   8ce04:	4e26bcc6 	addp	v6.16b, v6.16b, v6.16b
   8ce08:	4e083cc6 	mov	x6, v6.d[0]
   8ce0c:	d37ff924 	lsl	x4, x9, #1
   8ce10:	9ac424c6 	lsr	x6, x6, x4
   8ce14:	9ac420c6 	lsl	x6, x6, x4
   8ce18:	54000229 	b.ls	8ce5c <memchr+0x9c>  // b.plast
   8ce1c:	b50002c6 	cbnz	x6, 8ce74 <memchr+0xb4>
   8ce20:	4cdfa061 	ld1	{v1.16b, v2.16b}, [x3], #32
   8ce24:	f1008042 	subs	x2, x2, #0x20
   8ce28:	6e208c23 	cmeq	v3.16b, v1.16b, v0.16b
   8ce2c:	6e208c44 	cmeq	v4.16b, v2.16b, v0.16b
   8ce30:	540000a9 	b.ls	8ce44 <memchr+0x84>  // b.plast
   8ce34:	4ea41c66 	orr	v6.16b, v3.16b, v4.16b
   8ce38:	4ee6bcc6 	addp	v6.2d, v6.2d, v6.2d
   8ce3c:	4e083cc6 	mov	x6, v6.d[0]
   8ce40:	b4ffff06 	cbz	x6, 8ce20 <memchr+0x60>
   8ce44:	4e251c63 	and	v3.16b, v3.16b, v5.16b
   8ce48:	4e251c84 	and	v4.16b, v4.16b, v5.16b
   8ce4c:	4e24bc66 	addp	v6.16b, v3.16b, v4.16b
   8ce50:	4e26bcc6 	addp	v6.16b, v6.16b, v6.16b
   8ce54:	4e083cc6 	mov	x6, v6.d[0]
   8ce58:	540000e8 	b.hi	8ce74 <memchr+0xb4>  // b.pmore
   8ce5c:	8b090144 	add	x4, x10, x9
   8ce60:	92401084 	and	x4, x4, #0x1f
   8ce64:	d1008084 	sub	x4, x4, #0x20
   8ce68:	cb0407e4 	neg	x4, x4, lsl #1
   8ce6c:	9ac420c6 	lsl	x6, x6, x4
   8ce70:	9ac424c6 	lsr	x6, x6, x4
   8ce74:	dac000c6 	rbit	x6, x6
   8ce78:	d1008063 	sub	x3, x3, #0x20
   8ce7c:	f10000df 	cmp	x6, #0x0
   8ce80:	dac010c6 	clz	x6, x6
   8ce84:	8b460460 	add	x0, x3, x6, lsr #1
   8ce88:	9a8003e0 	csel	x0, xzr, x0, eq	// eq = none
   8ce8c:	d65f03c0 	ret
   8ce90:	d2800000 	mov	x0, #0x0                   	// #0
   8ce94:	d65f03c0 	ret
	...

000000000008cea0 <__swsetup_r>:
   8cea0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   8cea4:	d0000042 	adrp	x2, 96000 <JIS_state_table+0x70>
   8cea8:	910003fd 	mov	x29, sp
   8ceac:	a90153f3 	stp	x19, x20, [sp, #16]
   8ceb0:	aa0003f4 	mov	x20, x0
   8ceb4:	aa0103f3 	mov	x19, x1
   8ceb8:	f9410040 	ldr	x0, [x2, #512]
   8cebc:	b4000060 	cbz	x0, 8cec8 <__swsetup_r+0x28>
   8cec0:	f9402401 	ldr	x1, [x0, #72]
   8cec4:	b4000761 	cbz	x1, 8cfb0 <__swsetup_r+0x110>
   8cec8:	79c02262 	ldrsh	w2, [x19, #16]
   8cecc:	36180462 	tbz	w2, #3, 8cf58 <__swsetup_r+0xb8>
   8ced0:	f9400e61 	ldr	x1, [x19, #24]
   8ced4:	b40002c1 	cbz	x1, 8cf2c <__swsetup_r+0x8c>
   8ced8:	36000142 	tbz	w2, #0, 8cf00 <__swsetup_r+0x60>
   8cedc:	b9402260 	ldr	w0, [x19, #32]
   8cee0:	b9000e7f 	str	wzr, [x19, #12]
   8cee4:	4b0003e0 	neg	w0, w0
   8cee8:	b9002a60 	str	w0, [x19, #40]
   8ceec:	52800000 	mov	w0, #0x0                   	// #0
   8cef0:	b4000141 	cbz	x1, 8cf18 <__swsetup_r+0x78>
   8cef4:	a94153f3 	ldp	x19, x20, [sp, #16]
   8cef8:	a8c27bfd 	ldp	x29, x30, [sp], #32
   8cefc:	d65f03c0 	ret
   8cf00:	52800000 	mov	w0, #0x0                   	// #0
   8cf04:	37080042 	tbnz	w2, #1, 8cf0c <__swsetup_r+0x6c>
   8cf08:	b9402260 	ldr	w0, [x19, #32]
   8cf0c:	b9000e60 	str	w0, [x19, #12]
   8cf10:	52800000 	mov	w0, #0x0                   	// #0
   8cf14:	b5ffff01 	cbnz	x1, 8cef4 <__swsetup_r+0x54>
   8cf18:	363ffee2 	tbz	w2, #7, 8cef4 <__swsetup_r+0x54>
   8cf1c:	321a0042 	orr	w2, w2, #0x40
   8cf20:	12800000 	mov	w0, #0xffffffff            	// #-1
   8cf24:	79002262 	strh	w2, [x19, #16]
   8cf28:	17fffff3 	b	8cef4 <__swsetup_r+0x54>
   8cf2c:	52805000 	mov	w0, #0x280                 	// #640
   8cf30:	0a000040 	and	w0, w2, w0
   8cf34:	7108001f 	cmp	w0, #0x200
   8cf38:	54fffd00 	b.eq	8ced8 <__swsetup_r+0x38>  // b.none
   8cf3c:	aa1303e1 	mov	x1, x19
   8cf40:	aa1403e0 	mov	x0, x20
   8cf44:	94000023 	bl	8cfd0 <__smakebuf_r>
   8cf48:	79c02262 	ldrsh	w2, [x19, #16]
   8cf4c:	f9400e61 	ldr	x1, [x19, #24]
   8cf50:	3607fd82 	tbz	w2, #0, 8cf00 <__swsetup_r+0x60>
   8cf54:	17ffffe2 	b	8cedc <__swsetup_r+0x3c>
   8cf58:	36200302 	tbz	w2, #4, 8cfb8 <__swsetup_r+0x118>
   8cf5c:	371000c2 	tbnz	w2, #2, 8cf74 <__swsetup_r+0xd4>
   8cf60:	f9400e61 	ldr	x1, [x19, #24]
   8cf64:	321d0042 	orr	w2, w2, #0x8
   8cf68:	79002262 	strh	w2, [x19, #16]
   8cf6c:	b5fffb61 	cbnz	x1, 8ced8 <__swsetup_r+0x38>
   8cf70:	17ffffef 	b	8cf2c <__swsetup_r+0x8c>
   8cf74:	f9402e61 	ldr	x1, [x19, #88]
   8cf78:	b4000101 	cbz	x1, 8cf98 <__swsetup_r+0xf8>
   8cf7c:	9101d260 	add	x0, x19, #0x74
   8cf80:	eb00003f 	cmp	x1, x0
   8cf84:	54000080 	b.eq	8cf94 <__swsetup_r+0xf4>  // b.none
   8cf88:	aa1403e0 	mov	x0, x20
   8cf8c:	94000a0d 	bl	8f7c0 <_free_r>
   8cf90:	79c02262 	ldrsh	w2, [x19, #16]
   8cf94:	f9002e7f 	str	xzr, [x19, #88]
   8cf98:	f9400e61 	ldr	x1, [x19, #24]
   8cf9c:	12800480 	mov	w0, #0xffffffdb            	// #-37
   8cfa0:	0a000042 	and	w2, w2, w0
   8cfa4:	f9000261 	str	x1, [x19]
   8cfa8:	b9000a7f 	str	wzr, [x19, #8]
   8cfac:	17ffffee 	b	8cf64 <__swsetup_r+0xc4>
   8cfb0:	97ffd594 	bl	82600 <__sinit>
   8cfb4:	17ffffc5 	b	8cec8 <__swsetup_r+0x28>
   8cfb8:	52800120 	mov	w0, #0x9                   	// #9
   8cfbc:	321a0042 	orr	w2, w2, #0x40
   8cfc0:	b9000280 	str	w0, [x20]
   8cfc4:	17ffffd7 	b	8cf20 <__swsetup_r+0x80>
	...

000000000008cfd0 <__smakebuf_r>:
   8cfd0:	a9b57bfd 	stp	x29, x30, [sp, #-176]!
   8cfd4:	910003fd 	mov	x29, sp
   8cfd8:	79c02022 	ldrsh	w2, [x1, #16]
   8cfdc:	a90153f3 	stp	x19, x20, [sp, #16]
   8cfe0:	aa0103f3 	mov	x19, x1
   8cfe4:	36080122 	tbz	w2, #1, 8d008 <__smakebuf_r+0x38>
   8cfe8:	9101dc20 	add	x0, x1, #0x77
   8cfec:	52800021 	mov	w1, #0x1                   	// #1
   8cff0:	f9000260 	str	x0, [x19]
   8cff4:	f9000e60 	str	x0, [x19, #24]
   8cff8:	b9002261 	str	w1, [x19, #32]
   8cffc:	a94153f3 	ldp	x19, x20, [sp, #16]
   8d000:	a8cb7bfd 	ldp	x29, x30, [sp], #176
   8d004:	d65f03c0 	ret
   8d008:	79c02421 	ldrsh	w1, [x1, #18]
   8d00c:	aa0003f4 	mov	x20, x0
   8d010:	a9025bf5 	stp	x21, x22, [sp, #32]
   8d014:	f9001bf7 	str	x23, [sp, #48]
   8d018:	37f80381 	tbnz	w1, #31, 8d088 <__smakebuf_r+0xb8>
   8d01c:	910123e2 	add	x2, sp, #0x48
   8d020:	94000bc0 	bl	8ff20 <_fstat_r>
   8d024:	37f80300 	tbnz	w0, #31, 8d084 <__smakebuf_r+0xb4>
   8d028:	b9404fe0 	ldr	w0, [sp, #76]
   8d02c:	d2808016 	mov	x22, #0x400                 	// #1024
   8d030:	52810015 	mov	w21, #0x800                 	// #2048
   8d034:	aa1603e1 	mov	x1, x22
   8d038:	12140c00 	and	w0, w0, #0xf000
   8d03c:	7140081f 	cmp	w0, #0x2, lsl #12
   8d040:	aa1403e0 	mov	x0, x20
   8d044:	1a9f17f7 	cset	w23, eq	// eq = none
   8d048:	97fff94e 	bl	8b580 <_malloc_r>
   8d04c:	b5000320 	cbnz	x0, 8d0b0 <__smakebuf_r+0xe0>
   8d050:	79c02260 	ldrsh	w0, [x19, #16]
   8d054:	37480560 	tbnz	w0, #9, 8d100 <__smakebuf_r+0x130>
   8d058:	121e7400 	and	w0, w0, #0xfffffffc
   8d05c:	9101de61 	add	x1, x19, #0x77
   8d060:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8d064:	321f0000 	orr	w0, w0, #0x2
   8d068:	f9401bf7 	ldr	x23, [sp, #48]
   8d06c:	52800022 	mov	w2, #0x1                   	// #1
   8d070:	f9000261 	str	x1, [x19]
   8d074:	79002260 	strh	w0, [x19, #16]
   8d078:	f9000e61 	str	x1, [x19, #24]
   8d07c:	b9002262 	str	w2, [x19, #32]
   8d080:	17ffffdf 	b	8cffc <__smakebuf_r+0x2c>
   8d084:	79c02262 	ldrsh	w2, [x19, #16]
   8d088:	f279005f 	tst	x2, #0x80
   8d08c:	d2800800 	mov	x0, #0x40                  	// #64
   8d090:	d2808016 	mov	x22, #0x400                 	// #1024
   8d094:	9a8002d6 	csel	x22, x22, x0, eq	// eq = none
   8d098:	aa1603e1 	mov	x1, x22
   8d09c:	aa1403e0 	mov	x0, x20
   8d0a0:	52800017 	mov	w23, #0x0                   	// #0
   8d0a4:	52800015 	mov	w21, #0x0                   	// #0
   8d0a8:	97fff936 	bl	8b580 <_malloc_r>
   8d0ac:	b4fffd20 	cbz	x0, 8d050 <__smakebuf_r+0x80>
   8d0b0:	79c02262 	ldrsh	w2, [x19, #16]
   8d0b4:	f9000260 	str	x0, [x19]
   8d0b8:	32190042 	orr	w2, w2, #0x80
   8d0bc:	79002262 	strh	w2, [x19, #16]
   8d0c0:	f9000e60 	str	x0, [x19, #24]
   8d0c4:	b9002276 	str	w22, [x19, #32]
   8d0c8:	35000117 	cbnz	w23, 8d0e8 <__smakebuf_r+0x118>
   8d0cc:	2a150042 	orr	w2, w2, w21
   8d0d0:	79002262 	strh	w2, [x19, #16]
   8d0d4:	a94153f3 	ldp	x19, x20, [sp, #16]
   8d0d8:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8d0dc:	f9401bf7 	ldr	x23, [sp, #48]
   8d0e0:	a8cb7bfd 	ldp	x29, x30, [sp], #176
   8d0e4:	d65f03c0 	ret
   8d0e8:	79c02661 	ldrsh	w1, [x19, #18]
   8d0ec:	aa1403e0 	mov	x0, x20
   8d0f0:	94000ba0 	bl	8ff70 <_isatty_r>
   8d0f4:	350000c0 	cbnz	w0, 8d10c <__smakebuf_r+0x13c>
   8d0f8:	79c02262 	ldrsh	w2, [x19, #16]
   8d0fc:	17fffff4 	b	8d0cc <__smakebuf_r+0xfc>
   8d100:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8d104:	f9401bf7 	ldr	x23, [sp, #48]
   8d108:	17ffffbd 	b	8cffc <__smakebuf_r+0x2c>
   8d10c:	79402262 	ldrh	w2, [x19, #16]
   8d110:	121e7442 	and	w2, w2, #0xfffffffc
   8d114:	32000042 	orr	w2, w2, #0x1
   8d118:	13003c42 	sxth	w2, w2
   8d11c:	17ffffec 	b	8d0cc <__smakebuf_r+0xfc>

000000000008d120 <__swhatbuf_r>:
   8d120:	a9b67bfd 	stp	x29, x30, [sp, #-160]!
   8d124:	910003fd 	mov	x29, sp
   8d128:	a90153f3 	stp	x19, x20, [sp, #16]
   8d12c:	aa0103f3 	mov	x19, x1
   8d130:	79c02421 	ldrsh	w1, [x1, #18]
   8d134:	f90013f5 	str	x21, [sp, #32]
   8d138:	aa0203f4 	mov	x20, x2
   8d13c:	aa0303f5 	mov	x21, x3
   8d140:	37f80201 	tbnz	w1, #31, 8d180 <__swhatbuf_r+0x60>
   8d144:	9100e3e2 	add	x2, sp, #0x38
   8d148:	94000b76 	bl	8ff20 <_fstat_r>
   8d14c:	37f801a0 	tbnz	w0, #31, 8d180 <__swhatbuf_r+0x60>
   8d150:	b9403fe2 	ldr	w2, [sp, #60]
   8d154:	d2808001 	mov	x1, #0x400                 	// #1024
   8d158:	52810000 	mov	w0, #0x800                 	// #2048
   8d15c:	12140c42 	and	w2, w2, #0xf000
   8d160:	7140085f 	cmp	w2, #0x2, lsl #12
   8d164:	1a9f17e2 	cset	w2, eq	// eq = none
   8d168:	b90002a2 	str	w2, [x21]
   8d16c:	f94013f5 	ldr	x21, [sp, #32]
   8d170:	f9000281 	str	x1, [x20]
   8d174:	a94153f3 	ldp	x19, x20, [sp, #16]
   8d178:	a8ca7bfd 	ldp	x29, x30, [sp], #160
   8d17c:	d65f03c0 	ret
   8d180:	79402264 	ldrh	w4, [x19, #16]
   8d184:	52800002 	mov	w2, #0x0                   	// #0
   8d188:	b90002a2 	str	w2, [x21]
   8d18c:	d2808003 	mov	x3, #0x400                 	// #1024
   8d190:	f94013f5 	ldr	x21, [sp, #32]
   8d194:	f279009f 	tst	x4, #0x80
   8d198:	d2800801 	mov	x1, #0x40                  	// #64
   8d19c:	9a831021 	csel	x1, x1, x3, ne	// ne = any
   8d1a0:	f9000281 	str	x1, [x20]
   8d1a4:	52800000 	mov	w0, #0x0                   	// #0
   8d1a8:	a94153f3 	ldp	x19, x20, [sp, #16]
   8d1ac:	a8ca7bfd 	ldp	x29, x30, [sp], #160
   8d1b0:	d65f03c0 	ret
	...

000000000008d1c0 <memcpy>:
   8d1c0:	f9800020 	prfm	pldl1keep, [x1]
   8d1c4:	8b020024 	add	x4, x1, x2
   8d1c8:	8b020005 	add	x5, x0, x2
   8d1cc:	f100405f 	cmp	x2, #0x10
   8d1d0:	54000209 	b.ls	8d210 <memcpy+0x50>  // b.plast
   8d1d4:	f101805f 	cmp	x2, #0x60
   8d1d8:	54000648 	b.hi	8d2a0 <memcpy+0xe0>  // b.pmore
   8d1dc:	d1000449 	sub	x9, x2, #0x1
   8d1e0:	a9401c26 	ldp	x6, x7, [x1]
   8d1e4:	37300469 	tbnz	w9, #6, 8d270 <memcpy+0xb0>
   8d1e8:	a97f348c 	ldp	x12, x13, [x4, #-16]
   8d1ec:	362800a9 	tbz	w9, #5, 8d200 <memcpy+0x40>
   8d1f0:	a9412428 	ldp	x8, x9, [x1, #16]
   8d1f4:	a97e2c8a 	ldp	x10, x11, [x4, #-32]
   8d1f8:	a9012408 	stp	x8, x9, [x0, #16]
   8d1fc:	a93e2caa 	stp	x10, x11, [x5, #-32]
   8d200:	a9001c06 	stp	x6, x7, [x0]
   8d204:	a93f34ac 	stp	x12, x13, [x5, #-16]
   8d208:	d65f03c0 	ret
   8d20c:	d503201f 	nop
   8d210:	f100205f 	cmp	x2, #0x8
   8d214:	540000e3 	b.cc	8d230 <memcpy+0x70>  // b.lo, b.ul, b.last
   8d218:	f9400026 	ldr	x6, [x1]
   8d21c:	f85f8087 	ldur	x7, [x4, #-8]
   8d220:	f9000006 	str	x6, [x0]
   8d224:	f81f80a7 	stur	x7, [x5, #-8]
   8d228:	d65f03c0 	ret
   8d22c:	d503201f 	nop
   8d230:	361000c2 	tbz	w2, #2, 8d248 <memcpy+0x88>
   8d234:	b9400026 	ldr	w6, [x1]
   8d238:	b85fc087 	ldur	w7, [x4, #-4]
   8d23c:	b9000006 	str	w6, [x0]
   8d240:	b81fc0a7 	stur	w7, [x5, #-4]
   8d244:	d65f03c0 	ret
   8d248:	b4000102 	cbz	x2, 8d268 <memcpy+0xa8>
   8d24c:	d341fc49 	lsr	x9, x2, #1
   8d250:	39400026 	ldrb	w6, [x1]
   8d254:	385ff087 	ldurb	w7, [x4, #-1]
   8d258:	38696828 	ldrb	w8, [x1, x9]
   8d25c:	39000006 	strb	w6, [x0]
   8d260:	38296808 	strb	w8, [x0, x9]
   8d264:	381ff0a7 	sturb	w7, [x5, #-1]
   8d268:	d65f03c0 	ret
   8d26c:	d503201f 	nop
   8d270:	a9412428 	ldp	x8, x9, [x1, #16]
   8d274:	a9422c2a 	ldp	x10, x11, [x1, #32]
   8d278:	a943342c 	ldp	x12, x13, [x1, #48]
   8d27c:	a97e0881 	ldp	x1, x2, [x4, #-32]
   8d280:	a97f0c84 	ldp	x4, x3, [x4, #-16]
   8d284:	a9001c06 	stp	x6, x7, [x0]
   8d288:	a9012408 	stp	x8, x9, [x0, #16]
   8d28c:	a9022c0a 	stp	x10, x11, [x0, #32]
   8d290:	a903340c 	stp	x12, x13, [x0, #48]
   8d294:	a93e08a1 	stp	x1, x2, [x5, #-32]
   8d298:	a93f0ca4 	stp	x4, x3, [x5, #-16]
   8d29c:	d65f03c0 	ret
   8d2a0:	92400c09 	and	x9, x0, #0xf
   8d2a4:	927cec03 	and	x3, x0, #0xfffffffffffffff0
   8d2a8:	a940342c 	ldp	x12, x13, [x1]
   8d2ac:	cb090021 	sub	x1, x1, x9
   8d2b0:	8b090042 	add	x2, x2, x9
   8d2b4:	a9411c26 	ldp	x6, x7, [x1, #16]
   8d2b8:	a900340c 	stp	x12, x13, [x0]
   8d2bc:	a9422428 	ldp	x8, x9, [x1, #32]
   8d2c0:	a9432c2a 	ldp	x10, x11, [x1, #48]
   8d2c4:	a9c4342c 	ldp	x12, x13, [x1, #64]!
   8d2c8:	f1024042 	subs	x2, x2, #0x90
   8d2cc:	54000169 	b.ls	8d2f8 <memcpy+0x138>  // b.plast
   8d2d0:	a9011c66 	stp	x6, x7, [x3, #16]
   8d2d4:	a9411c26 	ldp	x6, x7, [x1, #16]
   8d2d8:	a9022468 	stp	x8, x9, [x3, #32]
   8d2dc:	a9422428 	ldp	x8, x9, [x1, #32]
   8d2e0:	a9032c6a 	stp	x10, x11, [x3, #48]
   8d2e4:	a9432c2a 	ldp	x10, x11, [x1, #48]
   8d2e8:	a984346c 	stp	x12, x13, [x3, #64]!
   8d2ec:	a9c4342c 	ldp	x12, x13, [x1, #64]!
   8d2f0:	f1010042 	subs	x2, x2, #0x40
   8d2f4:	54fffee8 	b.hi	8d2d0 <memcpy+0x110>  // b.pmore
   8d2f8:	a97c0881 	ldp	x1, x2, [x4, #-64]
   8d2fc:	a9011c66 	stp	x6, x7, [x3, #16]
   8d300:	a97d1c86 	ldp	x6, x7, [x4, #-48]
   8d304:	a9022468 	stp	x8, x9, [x3, #32]
   8d308:	a97e2488 	ldp	x8, x9, [x4, #-32]
   8d30c:	a9032c6a 	stp	x10, x11, [x3, #48]
   8d310:	a97f2c8a 	ldp	x10, x11, [x4, #-16]
   8d314:	a904346c 	stp	x12, x13, [x3, #64]
   8d318:	a93c08a1 	stp	x1, x2, [x5, #-64]
   8d31c:	a93d1ca6 	stp	x6, x7, [x5, #-48]
   8d320:	a93e24a8 	stp	x8, x9, [x5, #-32]
   8d324:	a93f2caa 	stp	x10, x11, [x5, #-16]
   8d328:	d65f03c0 	ret
	...

000000000008d340 <memmove>:
   8d340:	cb010005 	sub	x5, x0, x1
   8d344:	f101805f 	cmp	x2, #0x60
   8d348:	fa4280a2 	ccmp	x5, x2, #0x2, hi	// hi = pmore
   8d34c:	54fff3a2 	b.cs	8d1c0 <memcpy>  // b.hs, b.nlast
   8d350:	b40004c5 	cbz	x5, 8d3e8 <memmove+0xa8>
   8d354:	8b020004 	add	x4, x0, x2
   8d358:	8b020023 	add	x3, x1, x2
   8d35c:	92400c85 	and	x5, x4, #0xf
   8d360:	a97f346c 	ldp	x12, x13, [x3, #-16]
   8d364:	cb050063 	sub	x3, x3, x5
   8d368:	cb050042 	sub	x2, x2, x5
   8d36c:	a97f1c66 	ldp	x6, x7, [x3, #-16]
   8d370:	a93f348c 	stp	x12, x13, [x4, #-16]
   8d374:	a97e2468 	ldp	x8, x9, [x3, #-32]
   8d378:	a97d2c6a 	ldp	x10, x11, [x3, #-48]
   8d37c:	a9fc346c 	ldp	x12, x13, [x3, #-64]!
   8d380:	cb050084 	sub	x4, x4, x5
   8d384:	f1020042 	subs	x2, x2, #0x80
   8d388:	54000189 	b.ls	8d3b8 <memmove+0x78>  // b.plast
   8d38c:	d503201f 	nop
   8d390:	a93f1c86 	stp	x6, x7, [x4, #-16]
   8d394:	a97f1c66 	ldp	x6, x7, [x3, #-16]
   8d398:	a93e2488 	stp	x8, x9, [x4, #-32]
   8d39c:	a97e2468 	ldp	x8, x9, [x3, #-32]
   8d3a0:	a93d2c8a 	stp	x10, x11, [x4, #-48]
   8d3a4:	a97d2c6a 	ldp	x10, x11, [x3, #-48]
   8d3a8:	a9bc348c 	stp	x12, x13, [x4, #-64]!
   8d3ac:	a9fc346c 	ldp	x12, x13, [x3, #-64]!
   8d3b0:	f1010042 	subs	x2, x2, #0x40
   8d3b4:	54fffee8 	b.hi	8d390 <memmove+0x50>  // b.pmore
   8d3b8:	a9431422 	ldp	x2, x5, [x1, #48]
   8d3bc:	a93f1c86 	stp	x6, x7, [x4, #-16]
   8d3c0:	a9421c26 	ldp	x6, x7, [x1, #32]
   8d3c4:	a93e2488 	stp	x8, x9, [x4, #-32]
   8d3c8:	a9412428 	ldp	x8, x9, [x1, #16]
   8d3cc:	a93d2c8a 	stp	x10, x11, [x4, #-48]
   8d3d0:	a9402c2a 	ldp	x10, x11, [x1]
   8d3d4:	a93c348c 	stp	x12, x13, [x4, #-64]
   8d3d8:	a9031402 	stp	x2, x5, [x0, #48]
   8d3dc:	a9021c06 	stp	x6, x7, [x0, #32]
   8d3e0:	a9012408 	stp	x8, x9, [x0, #16]
   8d3e4:	a9002c0a 	stp	x10, x11, [x0]
   8d3e8:	d65f03c0 	ret
   8d3ec:	00000000 	udf	#0

000000000008d3f0 <_putc_r>:
   8d3f0:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   8d3f4:	910003fd 	mov	x29, sp
   8d3f8:	a90153f3 	stp	x19, x20, [sp, #16]
   8d3fc:	2a0103f4 	mov	w20, w1
   8d400:	aa0203f3 	mov	x19, x2
   8d404:	f90013f5 	str	x21, [sp, #32]
   8d408:	aa0003f5 	mov	x21, x0
   8d40c:	b4000060 	cbz	x0, 8d418 <_putc_r+0x28>
   8d410:	f9402401 	ldr	x1, [x0, #72]
   8d414:	b40005a1 	cbz	x1, 8d4c8 <_putc_r+0xd8>
   8d418:	b940b260 	ldr	w0, [x19, #176]
   8d41c:	37000060 	tbnz	w0, #0, 8d428 <_putc_r+0x38>
   8d420:	79402260 	ldrh	w0, [x19, #16]
   8d424:	364803e0 	tbz	w0, #9, 8d4a0 <_putc_r+0xb0>
   8d428:	b9400e62 	ldr	w2, [x19, #12]
   8d42c:	51000442 	sub	w2, w2, #0x1
   8d430:	b9000e62 	str	w2, [x19, #12]
   8d434:	36f800e2 	tbz	w2, #31, 8d450 <_putc_r+0x60>
   8d438:	b9402a60 	ldr	w0, [x19, #40]
   8d43c:	6b00005f 	cmp	w2, w0
   8d440:	5400024b 	b.lt	8d488 <_putc_r+0x98>  // b.tstop
   8d444:	12001e80 	and	w0, w20, #0xff
   8d448:	7100281f 	cmp	w0, #0xa
   8d44c:	540001e0 	b.eq	8d488 <_putc_r+0x98>  // b.none
   8d450:	f9400260 	ldr	x0, [x19]
   8d454:	12001e95 	and	w21, w20, #0xff
   8d458:	91000401 	add	x1, x0, #0x1
   8d45c:	f9000261 	str	x1, [x19]
   8d460:	39000014 	strb	w20, [x0]
   8d464:	b940b260 	ldr	w0, [x19, #176]
   8d468:	37000060 	tbnz	w0, #0, 8d474 <_putc_r+0x84>
   8d46c:	79402260 	ldrh	w0, [x19, #16]
   8d470:	364801e0 	tbz	w0, #9, 8d4ac <_putc_r+0xbc>
   8d474:	a94153f3 	ldp	x19, x20, [sp, #16]
   8d478:	2a1503e0 	mov	w0, w21
   8d47c:	f94013f5 	ldr	x21, [sp, #32]
   8d480:	a8c37bfd 	ldp	x29, x30, [sp], #48
   8d484:	d65f03c0 	ret
   8d488:	aa1503e0 	mov	x0, x21
   8d48c:	2a1403e1 	mov	w1, w20
   8d490:	aa1303e2 	mov	x2, x19
   8d494:	94001473 	bl	92660 <__swbuf_r>
   8d498:	2a0003f5 	mov	w21, w0
   8d49c:	17fffff2 	b	8d464 <_putc_r+0x74>
   8d4a0:	f9405260 	ldr	x0, [x19, #160]
   8d4a4:	97fffaa3 	bl	8bf30 <__retarget_lock_acquire_recursive>
   8d4a8:	17ffffe0 	b	8d428 <_putc_r+0x38>
   8d4ac:	f9405260 	ldr	x0, [x19, #160]
   8d4b0:	97fffab0 	bl	8bf70 <__retarget_lock_release_recursive>
   8d4b4:	a94153f3 	ldp	x19, x20, [sp, #16]
   8d4b8:	2a1503e0 	mov	w0, w21
   8d4bc:	f94013f5 	ldr	x21, [sp, #32]
   8d4c0:	a8c37bfd 	ldp	x29, x30, [sp], #48
   8d4c4:	d65f03c0 	ret
   8d4c8:	97ffd44e 	bl	82600 <__sinit>
   8d4cc:	17ffffd3 	b	8d418 <_putc_r+0x28>

000000000008d4d0 <putc>:
   8d4d0:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   8d4d4:	b0000042 	adrp	x2, 96000 <JIS_state_table+0x70>
   8d4d8:	910003fd 	mov	x29, sp
   8d4dc:	f90013f5 	str	x21, [sp, #32]
   8d4e0:	f9410055 	ldr	x21, [x2, #512]
   8d4e4:	a90153f3 	stp	x19, x20, [sp, #16]
   8d4e8:	2a0003f4 	mov	w20, w0
   8d4ec:	aa0103f3 	mov	x19, x1
   8d4f0:	b4000075 	cbz	x21, 8d4fc <putc+0x2c>
   8d4f4:	f94026a0 	ldr	x0, [x21, #72]
   8d4f8:	b40005a0 	cbz	x0, 8d5ac <putc+0xdc>
   8d4fc:	b940b260 	ldr	w0, [x19, #176]
   8d500:	37000060 	tbnz	w0, #0, 8d50c <putc+0x3c>
   8d504:	79402260 	ldrh	w0, [x19, #16]
   8d508:	364803e0 	tbz	w0, #9, 8d584 <putc+0xb4>
   8d50c:	b9400e62 	ldr	w2, [x19, #12]
   8d510:	51000442 	sub	w2, w2, #0x1
   8d514:	b9000e62 	str	w2, [x19, #12]
   8d518:	36f800e2 	tbz	w2, #31, 8d534 <putc+0x64>
   8d51c:	b9402a60 	ldr	w0, [x19, #40]
   8d520:	6b00005f 	cmp	w2, w0
   8d524:	5400024b 	b.lt	8d56c <putc+0x9c>  // b.tstop
   8d528:	12001e80 	and	w0, w20, #0xff
   8d52c:	7100281f 	cmp	w0, #0xa
   8d530:	540001e0 	b.eq	8d56c <putc+0x9c>  // b.none
   8d534:	f9400260 	ldr	x0, [x19]
   8d538:	12001e95 	and	w21, w20, #0xff
   8d53c:	91000401 	add	x1, x0, #0x1
   8d540:	f9000261 	str	x1, [x19]
   8d544:	39000014 	strb	w20, [x0]
   8d548:	b940b260 	ldr	w0, [x19, #176]
   8d54c:	37000060 	tbnz	w0, #0, 8d558 <putc+0x88>
   8d550:	79402260 	ldrh	w0, [x19, #16]
   8d554:	364801e0 	tbz	w0, #9, 8d590 <putc+0xc0>
   8d558:	a94153f3 	ldp	x19, x20, [sp, #16]
   8d55c:	2a1503e0 	mov	w0, w21
   8d560:	f94013f5 	ldr	x21, [sp, #32]
   8d564:	a8c37bfd 	ldp	x29, x30, [sp], #48
   8d568:	d65f03c0 	ret
   8d56c:	aa1503e0 	mov	x0, x21
   8d570:	2a1403e1 	mov	w1, w20
   8d574:	aa1303e2 	mov	x2, x19
   8d578:	9400143a 	bl	92660 <__swbuf_r>
   8d57c:	2a0003f5 	mov	w21, w0
   8d580:	17fffff2 	b	8d548 <putc+0x78>
   8d584:	f9405260 	ldr	x0, [x19, #160]
   8d588:	97fffa6a 	bl	8bf30 <__retarget_lock_acquire_recursive>
   8d58c:	17ffffe0 	b	8d50c <putc+0x3c>
   8d590:	f9405260 	ldr	x0, [x19, #160]
   8d594:	97fffa77 	bl	8bf70 <__retarget_lock_release_recursive>
   8d598:	a94153f3 	ldp	x19, x20, [sp, #16]
   8d59c:	2a1503e0 	mov	w0, w21
   8d5a0:	f94013f5 	ldr	x21, [sp, #32]
   8d5a4:	a8c37bfd 	ldp	x29, x30, [sp], #48
   8d5a8:	d65f03c0 	ret
   8d5ac:	aa1503e0 	mov	x0, x21
   8d5b0:	97ffd414 	bl	82600 <__sinit>
   8d5b4:	17ffffd2 	b	8d4fc <putc+0x2c>
	...

000000000008d5c0 <memset>:
   8d5c0:	4e010c20 	dup	v0.16b, w1
   8d5c4:	8b020004 	add	x4, x0, x2
   8d5c8:	f101805f 	cmp	x2, #0x60
   8d5cc:	540003c8 	b.hi	8d644 <memset+0x84>  // b.pmore
   8d5d0:	f100405f 	cmp	x2, #0x10
   8d5d4:	54000202 	b.cs	8d614 <memset+0x54>  // b.hs, b.nlast
   8d5d8:	4e083c01 	mov	x1, v0.d[0]
   8d5dc:	361800a2 	tbz	w2, #3, 8d5f0 <memset+0x30>
   8d5e0:	f9000001 	str	x1, [x0]
   8d5e4:	f81f8081 	stur	x1, [x4, #-8]
   8d5e8:	d65f03c0 	ret
   8d5ec:	d503201f 	nop
   8d5f0:	36100082 	tbz	w2, #2, 8d600 <memset+0x40>
   8d5f4:	b9000001 	str	w1, [x0]
   8d5f8:	b81fc081 	stur	w1, [x4, #-4]
   8d5fc:	d65f03c0 	ret
   8d600:	b4000082 	cbz	x2, 8d610 <memset+0x50>
   8d604:	39000001 	strb	w1, [x0]
   8d608:	36080042 	tbz	w2, #1, 8d610 <memset+0x50>
   8d60c:	781fe081 	sturh	w1, [x4, #-2]
   8d610:	d65f03c0 	ret
   8d614:	3d800000 	str	q0, [x0]
   8d618:	373000c2 	tbnz	w2, #6, 8d630 <memset+0x70>
   8d61c:	3c9f0080 	stur	q0, [x4, #-16]
   8d620:	36280062 	tbz	w2, #5, 8d62c <memset+0x6c>
   8d624:	3d800400 	str	q0, [x0, #16]
   8d628:	3c9e0080 	stur	q0, [x4, #-32]
   8d62c:	d65f03c0 	ret
   8d630:	3d800400 	str	q0, [x0, #16]
   8d634:	ad010000 	stp	q0, q0, [x0, #32]
   8d638:	ad3f0080 	stp	q0, q0, [x4, #-32]
   8d63c:	d65f03c0 	ret
   8d640:	d503201f 	nop
   8d644:	12001c21 	and	w1, w1, #0xff
   8d648:	927cec03 	and	x3, x0, #0xfffffffffffffff0
   8d64c:	3d800000 	str	q0, [x0]
   8d650:	f104005f 	cmp	x2, #0x100
   8d654:	7a402820 	ccmp	w1, #0x0, #0x0, cs	// cs = hs, nlast
   8d658:	54000180 	b.eq	8d688 <memset+0xc8>  // b.none
   8d65c:	cb030082 	sub	x2, x4, x3
   8d660:	d1004063 	sub	x3, x3, #0x10
   8d664:	d1014042 	sub	x2, x2, #0x50
   8d668:	ad010060 	stp	q0, q0, [x3, #32]
   8d66c:	ad820060 	stp	q0, q0, [x3, #64]!
   8d670:	f1010042 	subs	x2, x2, #0x40
   8d674:	54ffffa8 	b.hi	8d668 <memset+0xa8>  // b.pmore
   8d678:	ad3e0080 	stp	q0, q0, [x4, #-64]
   8d67c:	ad3f0080 	stp	q0, q0, [x4, #-32]
   8d680:	d65f03c0 	ret
   8d684:	d503201f 	nop
   8d688:	d53b00e5 	mrs	x5, dczid_el0
   8d68c:	3727fe85 	tbnz	w5, #4, 8d65c <memset+0x9c>
   8d690:	12000ca5 	and	w5, w5, #0xf
   8d694:	710010bf 	cmp	w5, #0x4
   8d698:	54000281 	b.ne	8d6e8 <memset+0x128>  // b.any
   8d69c:	3d800460 	str	q0, [x3, #16]
   8d6a0:	ad010060 	stp	q0, q0, [x3, #32]
   8d6a4:	927ae463 	and	x3, x3, #0xffffffffffffffc0
   8d6a8:	ad020060 	stp	q0, q0, [x3, #64]
   8d6ac:	ad030060 	stp	q0, q0, [x3, #96]
   8d6b0:	cb030082 	sub	x2, x4, x3
   8d6b4:	d1040042 	sub	x2, x2, #0x100
   8d6b8:	91020063 	add	x3, x3, #0x80
   8d6bc:	d503201f 	nop
   8d6c0:	d50b7423 	dc	zva, x3
   8d6c4:	91010063 	add	x3, x3, #0x40
   8d6c8:	f1010042 	subs	x2, x2, #0x40
   8d6cc:	54ffffa8 	b.hi	8d6c0 <memset+0x100>  // b.pmore
   8d6d0:	ad000060 	stp	q0, q0, [x3]
   8d6d4:	ad010060 	stp	q0, q0, [x3, #32]
   8d6d8:	ad3e0080 	stp	q0, q0, [x4, #-64]
   8d6dc:	ad3f0080 	stp	q0, q0, [x4, #-32]
   8d6e0:	d65f03c0 	ret
   8d6e4:	d503201f 	nop
   8d6e8:	710014bf 	cmp	w5, #0x5
   8d6ec:	54000241 	b.ne	8d734 <memset+0x174>  // b.any
   8d6f0:	3d800460 	str	q0, [x3, #16]
   8d6f4:	ad010060 	stp	q0, q0, [x3, #32]
   8d6f8:	ad020060 	stp	q0, q0, [x3, #64]
   8d6fc:	ad030060 	stp	q0, q0, [x3, #96]
   8d700:	9279e063 	and	x3, x3, #0xffffffffffffff80
   8d704:	cb030082 	sub	x2, x4, x3
   8d708:	d1040042 	sub	x2, x2, #0x100
   8d70c:	91020063 	add	x3, x3, #0x80
   8d710:	d50b7423 	dc	zva, x3
   8d714:	91020063 	add	x3, x3, #0x80
   8d718:	f1020042 	subs	x2, x2, #0x80
   8d71c:	54ffffa8 	b.hi	8d710 <memset+0x150>  // b.pmore
   8d720:	ad3c0080 	stp	q0, q0, [x4, #-128]
   8d724:	ad3d0080 	stp	q0, q0, [x4, #-96]
   8d728:	ad3e0080 	stp	q0, q0, [x4, #-64]
   8d72c:	ad3f0080 	stp	q0, q0, [x4, #-32]
   8d730:	d65f03c0 	ret
   8d734:	52800086 	mov	w6, #0x4                   	// #4
   8d738:	1ac520c7 	lsl	w7, w6, w5
   8d73c:	910100e5 	add	x5, x7, #0x40
   8d740:	eb05005f 	cmp	x2, x5
   8d744:	54fff8c3 	b.cc	8d65c <memset+0x9c>  // b.lo, b.ul, b.last
   8d748:	d10004e6 	sub	x6, x7, #0x1
   8d74c:	8b070065 	add	x5, x3, x7
   8d750:	91004063 	add	x3, x3, #0x10
   8d754:	eb0300a2 	subs	x2, x5, x3
   8d758:	8a2600a5 	bic	x5, x5, x6
   8d75c:	540000a0 	b.eq	8d770 <memset+0x1b0>  // b.none
   8d760:	ac820060 	stp	q0, q0, [x3], #64
   8d764:	ad3f0060 	stp	q0, q0, [x3, #-32]
   8d768:	f1010042 	subs	x2, x2, #0x40
   8d76c:	54ffffa8 	b.hi	8d760 <memset+0x1a0>  // b.pmore
   8d770:	aa0503e3 	mov	x3, x5
   8d774:	cb050082 	sub	x2, x4, x5
   8d778:	eb070042 	subs	x2, x2, x7
   8d77c:	540000a3 	b.cc	8d790 <memset+0x1d0>  // b.lo, b.ul, b.last
   8d780:	d50b7423 	dc	zva, x3
   8d784:	8b070063 	add	x3, x3, x7
   8d788:	eb070042 	subs	x2, x2, x7
   8d78c:	54ffffa2 	b.cs	8d780 <memset+0x1c0>  // b.hs, b.nlast
   8d790:	8b070042 	add	x2, x2, x7
   8d794:	d1008063 	sub	x3, x3, #0x20
   8d798:	17ffffb6 	b	8d670 <memset+0xb0>
   8d79c:	00000000 	udf	#0

000000000008d7a0 <__malloc_lock>:
   8d7a0:	b00013a0 	adrp	x0, 302000 <irq_handlers+0x1370>
   8d7a4:	913d0000 	add	x0, x0, #0xf40
   8d7a8:	17fff9e2 	b	8bf30 <__retarget_lock_acquire_recursive>
   8d7ac:	00000000 	udf	#0

000000000008d7b0 <__malloc_unlock>:
   8d7b0:	b00013a0 	adrp	x0, 302000 <irq_handlers+0x1370>
   8d7b4:	913d0000 	add	x0, x0, #0xf40
   8d7b8:	17fff9ee 	b	8bf70 <__retarget_lock_release_recursive>
   8d7bc:	00000000 	udf	#0

000000000008d7c0 <_wcsrtombs_r>:
   8d7c0:	aa0403e5 	mov	x5, x4
   8d7c4:	aa0303e4 	mov	x4, x3
   8d7c8:	92800003 	mov	x3, #0xffffffffffffffff    	// #-1
   8d7cc:	14001ac5 	b	942e0 <_wcsnrtombs_r>

000000000008d7d0 <wcsrtombs>:
   8d7d0:	b0000046 	adrp	x6, 96000 <JIS_state_table+0x70>
   8d7d4:	aa0003e4 	mov	x4, x0
   8d7d8:	aa0103e5 	mov	x5, x1
   8d7dc:	aa0403e1 	mov	x1, x4
   8d7e0:	f94100c0 	ldr	x0, [x6, #512]
   8d7e4:	aa0203e4 	mov	x4, x2
   8d7e8:	aa0503e2 	mov	x2, x5
   8d7ec:	aa0303e5 	mov	x5, x3
   8d7f0:	92800003 	mov	x3, #0xffffffffffffffff    	// #-1
   8d7f4:	14001abb 	b	942e0 <_wcsnrtombs_r>
	...

000000000008d800 <quorem>:
   8d800:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
   8d804:	910003fd 	mov	x29, sp
   8d808:	a90153f3 	stp	x19, x20, [sp, #16]
   8d80c:	b9401434 	ldr	w20, [x1, #20]
   8d810:	a90363f7 	stp	x23, x24, [sp, #48]
   8d814:	aa0003f8 	mov	x24, x0
   8d818:	b9401400 	ldr	w0, [x0, #20]
   8d81c:	6b14001f 	cmp	w0, w20
   8d820:	54000b8b 	b.lt	8d990 <quorem+0x190>  // b.tstop
   8d824:	51000694 	sub	w20, w20, #0x1
   8d828:	91006033 	add	x19, x1, #0x18
   8d82c:	91006317 	add	x23, x24, #0x18
   8d830:	a9025bf5 	stp	x21, x22, [sp, #32]
   8d834:	93407e8a 	sxtw	x10, w20
   8d838:	937e7e80 	sbfiz	x0, x20, #2, #32
   8d83c:	8b000276 	add	x22, x19, x0
   8d840:	8b0002eb 	add	x11, x23, x0
   8d844:	b86a7a62 	ldr	w2, [x19, x10, lsl #2]
   8d848:	b86a7ae3 	ldr	w3, [x23, x10, lsl #2]
   8d84c:	11000442 	add	w2, w2, #0x1
   8d850:	1ac20875 	udiv	w21, w3, w2
   8d854:	6b02007f 	cmp	w3, w2
   8d858:	540004c3 	b.cc	8d8f0 <quorem+0xf0>  // b.lo, b.ul, b.last
   8d85c:	aa1303e7 	mov	x7, x19
   8d860:	aa1703e6 	mov	x6, x23
   8d864:	52800009 	mov	w9, #0x0                   	// #0
   8d868:	52800008 	mov	w8, #0x0                   	// #0
   8d86c:	d503201f 	nop
   8d870:	b84044e3 	ldr	w3, [x7], #4
   8d874:	b94000c4 	ldr	w4, [x6]
   8d878:	12003c65 	and	w5, w3, #0xffff
   8d87c:	53107c63 	lsr	w3, w3, #16
   8d880:	12003c82 	and	w2, w4, #0xffff
   8d884:	1b1524a5 	madd	w5, w5, w21, w9
   8d888:	53107ca9 	lsr	w9, w5, #16
   8d88c:	4b252042 	sub	w2, w2, w5, uxth
   8d890:	0b080042 	add	w2, w2, w8
   8d894:	1b152463 	madd	w3, w3, w21, w9
   8d898:	13107c40 	asr	w0, w2, #16
   8d89c:	4b232000 	sub	w0, w0, w3, uxth
   8d8a0:	53107c69 	lsr	w9, w3, #16
   8d8a4:	0b444003 	add	w3, w0, w4, lsr #16
   8d8a8:	33103c62 	bfi	w2, w3, #16, #16
   8d8ac:	b80044c2 	str	w2, [x6], #4
   8d8b0:	13107c68 	asr	w8, w3, #16
   8d8b4:	eb0702df 	cmp	x22, x7
   8d8b8:	54fffdc2 	b.cs	8d870 <quorem+0x70>  // b.hs, b.nlast
   8d8bc:	b86a7ae0 	ldr	w0, [x23, x10, lsl #2]
   8d8c0:	35000180 	cbnz	w0, 8d8f0 <quorem+0xf0>
   8d8c4:	d1001160 	sub	x0, x11, #0x4
   8d8c8:	eb0002ff 	cmp	x23, x0
   8d8cc:	540000a3 	b.cc	8d8e0 <quorem+0xe0>  // b.lo, b.ul, b.last
   8d8d0:	14000007 	b	8d8ec <quorem+0xec>
   8d8d4:	51000694 	sub	w20, w20, #0x1
   8d8d8:	eb0002ff 	cmp	x23, x0
   8d8dc:	54000082 	b.cs	8d8ec <quorem+0xec>  // b.hs, b.nlast
   8d8e0:	b9400002 	ldr	w2, [x0]
   8d8e4:	d1001000 	sub	x0, x0, #0x4
   8d8e8:	34ffff62 	cbz	w2, 8d8d4 <quorem+0xd4>
   8d8ec:	b9001714 	str	w20, [x24, #20]
   8d8f0:	aa1803e0 	mov	x0, x24
   8d8f4:	94001823 	bl	93980 <__mcmp>
   8d8f8:	37f80400 	tbnz	w0, #31, 8d978 <quorem+0x178>
   8d8fc:	aa1703e0 	mov	x0, x23
   8d900:	52800004 	mov	w4, #0x0                   	// #0
   8d904:	d503201f 	nop
   8d908:	b8404663 	ldr	w3, [x19], #4
   8d90c:	b9400002 	ldr	w2, [x0]
   8d910:	12003c41 	and	w1, w2, #0xffff
   8d914:	4b232021 	sub	w1, w1, w3, uxth
   8d918:	0b040021 	add	w1, w1, w4
   8d91c:	13107c24 	asr	w4, w1, #16
   8d920:	4b434083 	sub	w3, w4, w3, lsr #16
   8d924:	0b424062 	add	w2, w3, w2, lsr #16
   8d928:	33103c41 	bfi	w1, w2, #16, #16
   8d92c:	b8004401 	str	w1, [x0], #4
   8d930:	13107c44 	asr	w4, w2, #16
   8d934:	eb1302df 	cmp	x22, x19
   8d938:	54fffe82 	b.cs	8d908 <quorem+0x108>  // b.hs, b.nlast
   8d93c:	b874dae1 	ldr	w1, [x23, w20, sxtw #2]
   8d940:	8b34cae0 	add	x0, x23, w20, sxtw #2
   8d944:	35000181 	cbnz	w1, 8d974 <quorem+0x174>
   8d948:	d1001000 	sub	x0, x0, #0x4
   8d94c:	eb0002ff 	cmp	x23, x0
   8d950:	540000a3 	b.cc	8d964 <quorem+0x164>  // b.lo, b.ul, b.last
   8d954:	14000007 	b	8d970 <quorem+0x170>
   8d958:	51000694 	sub	w20, w20, #0x1
   8d95c:	eb0002ff 	cmp	x23, x0
   8d960:	54000082 	b.cs	8d970 <quorem+0x170>  // b.hs, b.nlast
   8d964:	b9400001 	ldr	w1, [x0]
   8d968:	d1001000 	sub	x0, x0, #0x4
   8d96c:	34ffff61 	cbz	w1, 8d958 <quorem+0x158>
   8d970:	b9001714 	str	w20, [x24, #20]
   8d974:	110006b5 	add	w21, w21, #0x1
   8d978:	a94153f3 	ldp	x19, x20, [sp, #16]
   8d97c:	2a1503e0 	mov	w0, w21
   8d980:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8d984:	a94363f7 	ldp	x23, x24, [sp, #48]
   8d988:	a8c47bfd 	ldp	x29, x30, [sp], #64
   8d98c:	d65f03c0 	ret
   8d990:	a94153f3 	ldp	x19, x20, [sp, #16]
   8d994:	52800000 	mov	w0, #0x0                   	// #0
   8d998:	a94363f7 	ldp	x23, x24, [sp, #48]
   8d99c:	a8c47bfd 	ldp	x29, x30, [sp], #64
   8d9a0:	d65f03c0 	ret
	...

000000000008d9b0 <_dtoa_r>:
   8d9b0:	a9b47bfd 	stp	x29, x30, [sp, #-192]!
   8d9b4:	910003fd 	mov	x29, sp
   8d9b8:	f9402806 	ldr	x6, [x0, #80]
   8d9bc:	a90153f3 	stp	x19, x20, [sp, #16]
   8d9c0:	aa0003f3 	mov	x19, x0
   8d9c4:	a9025bf5 	stp	x21, x22, [sp, #32]
   8d9c8:	aa0403f4 	mov	x20, x4
   8d9cc:	2a0103f5 	mov	w21, w1
   8d9d0:	a90363f7 	stp	x23, x24, [sp, #48]
   8d9d4:	aa0503f8 	mov	x24, x5
   8d9d8:	a9046bf9 	stp	x25, x26, [sp, #64]
   8d9dc:	9e66001a 	fmov	x26, d0
   8d9e0:	a90573fb 	stp	x27, x28, [sp, #80]
   8d9e4:	2a0203fb 	mov	w27, w2
   8d9e8:	f9003fe3 	str	x3, [sp, #120]
   8d9ec:	6d0627e8 	stp	d8, d9, [sp, #96]
   8d9f0:	1e604008 	fmov	d8, d0
   8d9f4:	b4000106 	cbz	x6, 8da14 <_dtoa_r+0x64>
   8d9f8:	b9405803 	ldr	w3, [x0, #88]
   8d9fc:	52800022 	mov	w2, #0x1                   	// #1
   8da00:	aa0603e1 	mov	x1, x6
   8da04:	1ac32042 	lsl	w2, w2, w3
   8da08:	290108c3 	stp	w3, w2, [x6, #8]
   8da0c:	940015ad 	bl	930c0 <_Bfree>
   8da10:	f9002a7f 	str	xzr, [x19, #80]
   8da14:	9e660100 	fmov	x0, d8
   8da18:	1e604109 	fmov	d9, d8
   8da1c:	52800001 	mov	w1, #0x0                   	// #0
   8da20:	d360fc00 	lsr	x0, x0, #32
   8da24:	2a0003f6 	mov	w22, w0
   8da28:	36f800a0 	tbz	w0, #31, 8da3c <_dtoa_r+0x8c>
   8da2c:	12007816 	and	w22, w0, #0x7fffffff
   8da30:	52800021 	mov	w1, #0x1                   	// #1
   8da34:	b3607eda 	bfi	x26, x22, #32, #32
   8da38:	9e670349 	fmov	d9, x26
   8da3c:	120c2ac2 	and	w2, w22, #0x7ff00000
   8da40:	b9000281 	str	w1, [x20]
   8da44:	52affe00 	mov	w0, #0x7ff00000            	// #2146435072
   8da48:	6b00005f 	cmp	w2, w0
   8da4c:	54001e20 	b.eq	8de10 <_dtoa_r+0x460>  // b.none
   8da50:	1e602128 	fcmp	d9, #0.0
   8da54:	54000261 	b.ne	8daa0 <_dtoa_r+0xf0>  // b.any
   8da58:	f9403fe1 	ldr	x1, [sp, #120]
   8da5c:	52800020 	mov	w0, #0x1                   	// #1
   8da60:	b9000020 	str	w0, [x1]
   8da64:	b4000098 	cbz	x24, 8da74 <_dtoa_r+0xc4>
   8da68:	90000040 	adrp	x0, 95000 <pmu_event_descr+0x60>
   8da6c:	91188400 	add	x0, x0, #0x621
   8da70:	f9000300 	str	x0, [x24]
   8da74:	90000055 	adrp	x21, 95000 <pmu_event_descr+0x60>
   8da78:	911882b5 	add	x21, x21, #0x620
   8da7c:	a94153f3 	ldp	x19, x20, [sp, #16]
   8da80:	aa1503e0 	mov	x0, x21
   8da84:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8da88:	a94363f7 	ldp	x23, x24, [sp, #48]
   8da8c:	a9446bf9 	ldp	x25, x26, [sp, #64]
   8da90:	a94573fb 	ldp	x27, x28, [sp, #80]
   8da94:	6d4627e8 	ldp	d8, d9, [sp, #96]
   8da98:	a8cc7bfd 	ldp	x29, x30, [sp], #192
   8da9c:	d65f03c0 	ret
   8daa0:	1e604120 	fmov	d0, d9
   8daa4:	9102e3e2 	add	x2, sp, #0xb8
   8daa8:	9102f3e1 	add	x1, sp, #0xbc
   8daac:	aa1303e0 	mov	x0, x19
   8dab0:	940018b8 	bl	93d90 <__d2b>
   8dab4:	aa0003f4 	mov	x20, x0
   8dab8:	53147ec0 	lsr	w0, w22, #20
   8dabc:	35001c40 	cbnz	w0, 8de44 <_dtoa_r+0x494>
   8dac0:	295707e3 	ldp	w3, w1, [sp, #184]
   8dac4:	9e660100 	fmov	x0, d8
   8dac8:	0b010061 	add	w1, w3, w1
   8dacc:	1110c822 	add	w2, w1, #0x432
   8dad0:	7100805f 	cmp	w2, #0x20
   8dad4:	5400210d 	b.le	8def4 <_dtoa_r+0x544>
   8dad8:	11104825 	add	w5, w1, #0x412
   8dadc:	52800804 	mov	w4, #0x40                  	// #64
   8dae0:	4b020082 	sub	w2, w4, w2
   8dae4:	1ac52400 	lsr	w0, w0, w5
   8dae8:	1ac222d6 	lsl	w22, w22, w2
   8daec:	2a0002c0 	orr	w0, w22, w0
   8daf0:	1e630000 	ucvtf	d0, w0
   8daf4:	51000420 	sub	w0, w1, #0x1
   8daf8:	52800021 	mov	w1, #0x1                   	// #1
   8dafc:	b900a7e1 	str	w1, [sp, #164]
   8db00:	52bfc204 	mov	w4, #0xfe100000            	// #-32505856
   8db04:	9e660002 	fmov	x2, d0
   8db08:	d360fc41 	lsr	x1, x2, #32
   8db0c:	0b040021 	add	w1, w1, w4
   8db10:	b3607c22 	bfi	x2, x1, #32, #32
   8db14:	9e670042 	fmov	d2, x2
   8db18:	1e6f1001 	fmov	d1, #1.500000000000000000e+00
   8db1c:	90000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8db20:	1e620003 	scvtf	d3, w0
   8db24:	1e613841 	fsub	d1, d2, d1
   8db28:	fd46a424 	ldr	d4, [x1, #3400]
   8db2c:	90000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8db30:	fd46a820 	ldr	d0, [x1, #3408]
   8db34:	90000041 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8db38:	1f440020 	fmadd	d0, d1, d4, d0
   8db3c:	fd46ac22 	ldr	d2, [x1, #3416]
   8db40:	1f420060 	fmadd	d0, d3, d2, d0
   8db44:	1e602018 	fcmpe	d0, #0.0
   8db48:	1e780005 	fcvtzs	w5, d0
   8db4c:	54001ca4 	b.mi	8dee0 <_dtoa_r+0x530>  // b.first
   8db50:	4b000060 	sub	w0, w3, w0
   8db54:	51000406 	sub	w6, w0, #0x1
   8db58:	710058bf 	cmp	w5, #0x16
   8db5c:	54001928 	b.hi	8de80 <_dtoa_r+0x4d0>  // b.pmore
   8db60:	b0000042 	adrp	x2, 96000 <JIS_state_table+0x70>
   8db64:	9103c044 	add	x4, x2, #0xf0
   8db68:	fc65d880 	ldr	d0, [x4, w5, sxtw #3]
   8db6c:	1e692010 	fcmpe	d0, d9
   8db70:	54001c8c 	b.gt	8df00 <_dtoa_r+0x550>
   8db74:	b9009bff 	str	wzr, [sp, #152]
   8db78:	52800007 	mov	w7, #0x0                   	// #0
   8db7c:	7100001f 	cmp	w0, #0x0
   8db80:	5400008c 	b.gt	8db90 <_dtoa_r+0x1e0>
   8db84:	52800027 	mov	w7, #0x1                   	// #1
   8db88:	4b0000e7 	sub	w7, w7, w0
   8db8c:	52800006 	mov	w6, #0x0                   	// #0
   8db90:	b90083e5 	str	w5, [sp, #128]
   8db94:	0b0500c6 	add	w6, w6, w5
   8db98:	5280001c 	mov	w28, #0x0                   	// #0
   8db9c:	710026bf 	cmp	w21, #0x9
   8dba0:	54001868 	b.hi	8deac <_dtoa_r+0x4fc>  // b.pmore
   8dba4:	710016bf 	cmp	w21, #0x5
   8dba8:	54001b2d 	b.le	8df0c <_dtoa_r+0x55c>
   8dbac:	510012b5 	sub	w21, w21, #0x4
   8dbb0:	52800019 	mov	w25, #0x0                   	// #0
   8dbb4:	71000ebf 	cmp	w21, #0x3
   8dbb8:	540060e0 	b.eq	8e7d4 <_dtoa_r+0xe24>  // b.none
   8dbbc:	5400570d 	b.le	8e69c <_dtoa_r+0xcec>
   8dbc0:	710012bf 	cmp	w21, #0x4
   8dbc4:	54003e60 	b.eq	8e390 <_dtoa_r+0x9e0>  // b.none
   8dbc8:	52800020 	mov	w0, #0x1                   	// #1
   8dbcc:	528000b5 	mov	w21, #0x5                   	// #5
   8dbd0:	b9008be0 	str	w0, [sp, #136]
   8dbd4:	b94083e0 	ldr	w0, [sp, #128]
   8dbd8:	0b000360 	add	w0, w27, w0
   8dbdc:	b900abe0 	str	w0, [sp, #168]
   8dbe0:	11000416 	add	w22, w0, #0x1
   8dbe4:	710002df 	cmp	w22, #0x0
   8dbe8:	1a9fc6c0 	csinc	w0, w22, wzr, gt
   8dbec:	93407c04 	sxtw	x4, w0
   8dbf0:	71007c1f 	cmp	w0, #0x1f
   8dbf4:	5400168d 	b.le	8dec4 <_dtoa_r+0x514>
   8dbf8:	52800023 	mov	w3, #0x1                   	// #1
   8dbfc:	52800082 	mov	w2, #0x4                   	// #4
   8dc00:	531f7842 	lsl	w2, w2, #1
   8dc04:	2a0303e1 	mov	w1, w3
   8dc08:	11000463 	add	w3, w3, #0x1
   8dc0c:	93407c40 	sxtw	x0, w2
   8dc10:	91007000 	add	x0, x0, #0x1c
   8dc14:	eb04001f 	cmp	x0, x4
   8dc18:	54ffff49 	b.ls	8dc00 <_dtoa_r+0x250>  // b.plast
   8dc1c:	b9005a61 	str	w1, [x19, #88]
   8dc20:	aa1303e0 	mov	x0, x19
   8dc24:	291197e7 	stp	w7, w5, [sp, #140]
   8dc28:	b900a3e6 	str	w6, [sp, #160]
   8dc2c:	94001501 	bl	93030 <_Balloc>
   8dc30:	295197e7 	ldp	w7, w5, [sp, #140]
   8dc34:	aa0003f7 	mov	x23, x0
   8dc38:	b940a3e6 	ldr	w6, [sp, #160]
   8dc3c:	b4007680 	cbz	x0, 8eb0c <_dtoa_r+0x115c>
   8dc40:	71003adf 	cmp	w22, #0xe
   8dc44:	f9002a77 	str	x23, [x19, #80]
   8dc48:	1a9f87e0 	cset	w0, ls	// ls = plast
   8dc4c:	2a1603e3 	mov	w3, w22
   8dc50:	6a190000 	ands	w0, w0, w25
   8dc54:	54000b20 	b.eq	8ddb8 <_dtoa_r+0x408>  // b.none
   8dc58:	b94083e1 	ldr	w1, [sp, #128]
   8dc5c:	7100003f 	cmp	w1, #0x0
   8dc60:	5400194d 	b.le	8df88 <_dtoa_r+0x5d8>
   8dc64:	2a0103e0 	mov	w0, w1
   8dc68:	b0000042 	adrp	x2, 96000 <JIS_state_table+0x70>
   8dc6c:	aa0003e1 	mov	x1, x0
   8dc70:	9103c044 	add	x4, x2, #0xf0
   8dc74:	92400c21 	and	x1, x1, #0xf
   8dc78:	2a0003e2 	mov	w2, w0
   8dc7c:	13047c00 	asr	w0, w0, #4
   8dc80:	fc617880 	ldr	d0, [x4, x1, lsl #3]
   8dc84:	aa0203e1 	mov	x1, x2
   8dc88:	36404701 	tbz	w1, #8, 8e568 <_dtoa_r+0xbb8>
   8dc8c:	b0000041 	adrp	x1, 96000 <JIS_state_table+0x70>
   8dc90:	12000c00 	and	w0, w0, #0xf
   8dc94:	52800062 	mov	w2, #0x3                   	// #3
   8dc98:	fd407021 	ldr	d1, [x1, #224]
   8dc9c:	1e611921 	fdiv	d1, d9, d1
   8dca0:	34000160 	cbz	w0, 8dccc <_dtoa_r+0x31c>
   8dca4:	b0000041 	adrp	x1, 96000 <JIS_state_table+0x70>
   8dca8:	91030021 	add	x1, x1, #0xc0
   8dcac:	d503201f 	nop
   8dcb0:	36000080 	tbz	w0, #0, 8dcc0 <_dtoa_r+0x310>
   8dcb4:	fd400022 	ldr	d2, [x1]
   8dcb8:	11000442 	add	w2, w2, #0x1
   8dcbc:	1e620800 	fmul	d0, d0, d2
   8dcc0:	13017c00 	asr	w0, w0, #1
   8dcc4:	91002021 	add	x1, x1, #0x8
   8dcc8:	35ffff40 	cbnz	w0, 8dcb0 <_dtoa_r+0x300>
   8dccc:	1e601821 	fdiv	d1, d1, d0
   8dcd0:	b9409be0 	ldr	w0, [sp, #152]
   8dcd4:	34000080 	cbz	w0, 8dce4 <_dtoa_r+0x334>
   8dcd8:	1e6e1000 	fmov	d0, #1.000000000000000000e+00
   8dcdc:	1e602030 	fcmpe	d1, d0
   8dce0:	540057e4 	b.mi	8e7dc <_dtoa_r+0xe2c>  // b.first
   8dce4:	1e620042 	scvtf	d2, w2
   8dce8:	1e639000 	fmov	d0, #7.000000000000000000e+00
   8dcec:	52bf9802 	mov	w2, #0xfcc00000            	// #-54525952
   8dcf0:	1f410040 	fmadd	d0, d2, d1, d0
   8dcf4:	9e660000 	fmov	x0, d0
   8dcf8:	d360fc01 	lsr	x1, x0, #32
   8dcfc:	0b020021 	add	w1, w1, w2
   8dd00:	b3607c20 	bfi	x0, x1, #32, #32
   8dd04:	340012f6 	cbz	w22, 8df60 <_dtoa_r+0x5b0>
   8dd08:	b94083fa 	ldr	w26, [sp, #128]
   8dd0c:	2a1603e8 	mov	w8, w22
   8dd10:	1e780021 	fcvtzs	w1, d1
   8dd14:	9e670002 	fmov	d2, x0
   8dd18:	b0000042 	adrp	x2, 96000 <JIS_state_table+0x70>
   8dd1c:	51000509 	sub	w9, w8, #0x1
   8dd20:	9103c044 	add	x4, x2, #0xf0
   8dd24:	910006e2 	add	x2, x23, #0x1
   8dd28:	1e620020 	scvtf	d0, w1
   8dd2c:	1100c020 	add	w0, w1, #0x30
   8dd30:	b9408be1 	ldr	w1, [sp, #136]
   8dd34:	12001c00 	and	w0, w0, #0xff
   8dd38:	fc69d883 	ldr	d3, [x4, w9, sxtw #3]
   8dd3c:	1e603821 	fsub	d1, d1, d0
   8dd40:	340015a1 	cbz	w1, 8dff4 <_dtoa_r+0x644>
   8dd44:	1e6c1000 	fmov	d0, #5.000000000000000000e-01
   8dd48:	390002e0 	strb	w0, [x23]
   8dd4c:	1e631800 	fdiv	d0, d0, d3
   8dd50:	1e623800 	fsub	d0, d0, d2
   8dd54:	1e612010 	fcmpe	d0, d1
   8dd58:	540045ac 	b.gt	8e60c <_dtoa_r+0xc5c>
   8dd5c:	aa0203e0 	mov	x0, x2
   8dd60:	1e6e1004 	fmov	d4, #1.000000000000000000e+00
   8dd64:	52800022 	mov	w2, #0x1                   	// #1
   8dd68:	1e649003 	fmov	d3, #1.000000000000000000e+01
   8dd6c:	4b000042 	sub	w2, w2, w0
   8dd70:	1400000a 	b	8dd98 <_dtoa_r+0x3e8>
   8dd74:	1e630821 	fmul	d1, d1, d3
   8dd78:	1e630800 	fmul	d0, d0, d3
   8dd7c:	1e780021 	fcvtzs	w1, d1
   8dd80:	1e620022 	scvtf	d2, w1
   8dd84:	1100c021 	add	w1, w1, #0x30
   8dd88:	38001401 	strb	w1, [x0], #1
   8dd8c:	1e623821 	fsub	d1, d1, d2
   8dd90:	1e602030 	fcmpe	d1, d0
   8dd94:	54006064 	b.mi	8e9a0 <_dtoa_r+0xff0>  // b.first
   8dd98:	1e613882 	fsub	d2, d4, d1
   8dd9c:	1e602050 	fcmpe	d2, d0
   8dda0:	54003ee4 	b.mi	8e57c <_dtoa_r+0xbcc>  // b.first
   8dda4:	0b000041 	add	w1, w2, w0
   8dda8:	6b08003f 	cmp	w1, w8
   8ddac:	54fffe4b 	b.lt	8dd74 <_dtoa_r+0x3c4>  // b.tstop
   8ddb0:	9e66013a 	fmov	x26, d9
   8ddb4:	d503201f 	nop
   8ddb8:	b940bfe0 	ldr	w0, [sp, #188]
   8ddbc:	b0000042 	adrp	x2, 96000 <JIS_state_table+0x70>
   8ddc0:	b94083e1 	ldr	w1, [sp, #128]
   8ddc4:	9103c044 	add	x4, x2, #0xf0
   8ddc8:	7100001f 	cmp	w0, #0x0
   8ddcc:	7a4ea820 	ccmp	w1, #0xe, #0x0, ge	// ge = tcont
   8ddd0:	54002c2d 	b.le	8e354 <_dtoa_r+0x9a4>
   8ddd4:	b9408be1 	ldr	w1, [sp, #136]
   8ddd8:	34001481 	cbz	w1, 8e068 <_dtoa_r+0x6b8>
   8dddc:	710006bf 	cmp	w21, #0x1
   8dde0:	5400522d 	b.le	8e824 <_dtoa_r+0xe74>
   8dde4:	510006c3 	sub	w3, w22, #0x1
   8dde8:	6b03039f 	cmp	w28, w3
   8ddec:	5400422b 	b.lt	8e630 <_dtoa_r+0xc80>  // b.tstop
   8ddf0:	4b1600e0 	sub	w0, w7, w22
   8ddf4:	b9008fe0 	str	w0, [sp, #140]
   8ddf8:	4b030383 	sub	w3, w28, w3
   8ddfc:	37f84296 	tbnz	w22, #31, 8e64c <_dtoa_r+0xc9c>
   8de00:	0b1600c6 	add	w6, w6, w22
   8de04:	b9008fe7 	str	w7, [sp, #140]
   8de08:	0b0702c7 	add	w7, w22, w7
   8de0c:	14000210 	b	8e64c <_dtoa_r+0xc9c>
   8de10:	f9403fe1 	ldr	x1, [sp, #120]
   8de14:	5284e1e0 	mov	w0, #0x270f                	// #9999
   8de18:	b9000020 	str	w0, [x1]
   8de1c:	9e660120 	fmov	x0, d9
   8de20:	f240cc1f 	tst	x0, #0xfffffffffffff
   8de24:	54000201 	b.ne	8de64 <_dtoa_r+0x4b4>  // b.any
   8de28:	90000055 	adrp	x21, 95000 <pmu_event_descr+0x60>
   8de2c:	b40050d8 	cbz	x24, 8e844 <_dtoa_r+0xe94>
   8de30:	90000040 	adrp	x0, 95000 <pmu_event_descr+0x60>
   8de34:	9132e2b5 	add	x21, x21, #0xcb8
   8de38:	91330000 	add	x0, x0, #0xcc0
   8de3c:	f9000300 	str	x0, [x24]
   8de40:	17ffff0f 	b	8da7c <_dtoa_r+0xcc>
   8de44:	9e660122 	fmov	x2, d9
   8de48:	b940bbe3 	ldr	w3, [sp, #184]
   8de4c:	510ffc00 	sub	w0, w0, #0x3ff
   8de50:	b900a7ff 	str	wzr, [sp, #164]
   8de54:	d360cc41 	ubfx	x1, x2, #32, #20
   8de58:	320c2421 	orr	w1, w1, #0x3ff00000
   8de5c:	b3607c22 	bfi	x2, x1, #32, #32
   8de60:	17ffff2d 	b	8db14 <_dtoa_r+0x164>
   8de64:	90000055 	adrp	x21, 95000 <pmu_event_descr+0x60>
   8de68:	b4004f38 	cbz	x24, 8e84c <_dtoa_r+0xe9c>
   8de6c:	90000040 	adrp	x0, 95000 <pmu_event_descr+0x60>
   8de70:	913322b5 	add	x21, x21, #0xcc8
   8de74:	91332c00 	add	x0, x0, #0xccb
   8de78:	f9000300 	str	x0, [x24]
   8de7c:	17ffff00 	b	8da7c <_dtoa_r+0xcc>
   8de80:	52800021 	mov	w1, #0x1                   	// #1
   8de84:	b9009be1 	str	w1, [sp, #152]
   8de88:	52800007 	mov	w7, #0x0                   	// #0
   8de8c:	37f80226 	tbnz	w6, #31, 8ded0 <_dtoa_r+0x520>
   8de90:	36ffe805 	tbz	w5, #31, 8db90 <_dtoa_r+0x1e0>
   8de94:	b90083e5 	str	w5, [sp, #128]
   8de98:	4b0500e7 	sub	w7, w7, w5
   8de9c:	4b0503fc 	neg	w28, w5
   8dea0:	52800005 	mov	w5, #0x0                   	// #0
   8dea4:	710026bf 	cmp	w21, #0x9
   8dea8:	54ffe7e9 	b.ls	8dba4 <_dtoa_r+0x1f4>  // b.plast
   8deac:	52800039 	mov	w25, #0x1                   	// #1
   8deb0:	52800015 	mov	w21, #0x0                   	// #0
   8deb4:	12800016 	mov	w22, #0xffffffff            	// #-1
   8deb8:	5280001b 	mov	w27, #0x0                   	// #0
   8debc:	b9008bf9 	str	w25, [sp, #136]
   8dec0:	b900abf6 	str	w22, [sp, #168]
   8dec4:	52800001 	mov	w1, #0x0                   	// #0
   8dec8:	b9005a7f 	str	wzr, [x19, #88]
   8decc:	17ffff55 	b	8dc20 <_dtoa_r+0x270>
   8ded0:	52800027 	mov	w7, #0x1                   	// #1
   8ded4:	52800006 	mov	w6, #0x0                   	// #0
   8ded8:	4b0000e7 	sub	w7, w7, w0
   8dedc:	17ffffed 	b	8de90 <_dtoa_r+0x4e0>
   8dee0:	1e6200a1 	scvtf	d1, w5
   8dee4:	1e602020 	fcmp	d1, d0
   8dee8:	1a9f07e1 	cset	w1, ne	// ne = any
   8deec:	4b0100a5 	sub	w5, w5, w1
   8def0:	17ffff18 	b	8db50 <_dtoa_r+0x1a0>
   8def4:	4b0203e2 	neg	w2, w2
   8def8:	1ac22000 	lsl	w0, w0, w2
   8defc:	17fffefd 	b	8daf0 <_dtoa_r+0x140>
   8df00:	510004a5 	sub	w5, w5, #0x1
   8df04:	b9009bff 	str	wzr, [sp, #152]
   8df08:	17ffffe0 	b	8de88 <_dtoa_r+0x4d8>
   8df0c:	52800039 	mov	w25, #0x1                   	// #1
   8df10:	71000ebf 	cmp	w21, #0x3
   8df14:	54004600 	b.eq	8e7d4 <_dtoa_r+0xe24>  // b.none
   8df18:	54ffe54c 	b.gt	8dbc0 <_dtoa_r+0x210>
   8df1c:	b9008bff 	str	wzr, [sp, #136]
   8df20:	71000abf 	cmp	w21, #0x2
   8df24:	54005d01 	b.ne	8eac4 <_dtoa_r+0x1114>  // b.any
   8df28:	7100037f 	cmp	w27, #0x0
   8df2c:	5400238d 	b.le	8e39c <_dtoa_r+0x9ec>
   8df30:	2a1b03f6 	mov	w22, w27
   8df34:	2a1b03e0 	mov	w0, w27
   8df38:	b900abfb 	str	w27, [sp, #168]
   8df3c:	17ffff2c 	b	8dbec <_dtoa_r+0x23c>
   8df40:	1e620042 	scvtf	d2, w2
   8df44:	1e639000 	fmov	d0, #7.000000000000000000e+00
   8df48:	52bf9802 	mov	w2, #0xfcc00000            	// #-54525952
   8df4c:	1f410040 	fmadd	d0, d2, d1, d0
   8df50:	9e660000 	fmov	x0, d0
   8df54:	d360fc01 	lsr	x1, x0, #32
   8df58:	0b020021 	add	w1, w1, w2
   8df5c:	b3607c20 	bfi	x0, x1, #32, #32
   8df60:	1e629002 	fmov	d2, #5.000000000000000000e+00
   8df64:	9e670000 	fmov	d0, x0
   8df68:	1e623821 	fsub	d1, d1, d2
   8df6c:	1e602030 	fcmpe	d1, d0
   8df70:	5400208c 	b.gt	8e380 <_dtoa_r+0x9d0>
   8df74:	1e614000 	fneg	d0, d0
   8df78:	1e602030 	fcmpe	d1, d0
   8df7c:	54003544 	b.mi	8e624 <_dtoa_r+0xc74>  // b.first
   8df80:	9e66013a 	fmov	x26, d9
   8df84:	17ffff8d 	b	8ddb8 <_dtoa_r+0x408>
   8df88:	54003480 	b.eq	8e618 <_dtoa_r+0xc68>  // b.none
   8df8c:	b94083e1 	ldr	w1, [sp, #128]
   8df90:	b0000042 	adrp	x2, 96000 <JIS_state_table+0x70>
   8df94:	9103c044 	add	x4, x2, #0xf0
   8df98:	4b0103e1 	neg	w1, w1
   8df9c:	92400c28 	and	x8, x1, #0xf
   8dfa0:	13047c21 	asr	w1, w1, #4
   8dfa4:	fc687882 	ldr	d2, [x4, x8, lsl #3]
   8dfa8:	1e620922 	fmul	d2, d9, d2
   8dfac:	34005661 	cbz	w1, 8ea78 <_dtoa_r+0x10c8>
   8dfb0:	1e604041 	fmov	d1, d2
   8dfb4:	b0000044 	adrp	x4, 96000 <JIS_state_table+0x70>
   8dfb8:	91030084 	add	x4, x4, #0xc0
   8dfbc:	52800008 	mov	w8, #0x0                   	// #0
   8dfc0:	52800042 	mov	w2, #0x2                   	// #2
   8dfc4:	d503201f 	nop
   8dfc8:	360000a1 	tbz	w1, #0, 8dfdc <_dtoa_r+0x62c>
   8dfcc:	fd400080 	ldr	d0, [x4]
   8dfd0:	11000442 	add	w2, w2, #0x1
   8dfd4:	2a0003e8 	mov	w8, w0
   8dfd8:	1e600821 	fmul	d1, d1, d0
   8dfdc:	13017c21 	asr	w1, w1, #1
   8dfe0:	91002084 	add	x4, x4, #0x8
   8dfe4:	35ffff21 	cbnz	w1, 8dfc8 <_dtoa_r+0x618>
   8dfe8:	7100011f 	cmp	w8, #0x0
   8dfec:	1e621c21 	fcsel	d1, d1, d2, ne	// ne = any
   8dff0:	17ffff38 	b	8dcd0 <_dtoa_r+0x320>
   8dff4:	390002e0 	strb	w0, [x23]
   8dff8:	1e630842 	fmul	d2, d2, d3
   8dffc:	8b2842e0 	add	x0, x23, w8, uxtw
   8e000:	1e649003 	fmov	d3, #1.000000000000000000e+01
   8e004:	7100051f 	cmp	w8, #0x1
   8e008:	54005160 	b.eq	8ea34 <_dtoa_r+0x1084>  // b.none
   8e00c:	d503201f 	nop
   8e010:	1e630821 	fmul	d1, d1, d3
   8e014:	1e780021 	fcvtzs	w1, d1
   8e018:	1e620020 	scvtf	d0, w1
   8e01c:	1100c021 	add	w1, w1, #0x30
   8e020:	38001441 	strb	w1, [x2], #1
   8e024:	1e603821 	fsub	d1, d1, d0
   8e028:	eb00005f 	cmp	x2, x0
   8e02c:	54ffff21 	b.ne	8e010 <_dtoa_r+0x660>  // b.any
   8e030:	1e6c1000 	fmov	d0, #5.000000000000000000e-01
   8e034:	1e602843 	fadd	d3, d2, d0
   8e038:	1e612070 	fcmpe	d3, d1
   8e03c:	54002a04 	b.mi	8e57c <_dtoa_r+0xbcc>  // b.first
   8e040:	1e623800 	fsub	d0, d0, d2
   8e044:	1e612010 	fcmpe	d0, d1
   8e048:	54002dac 	b.gt	8e5fc <_dtoa_r+0xc4c>
   8e04c:	b940bfe0 	ldr	w0, [sp, #188]
   8e050:	9e66013a 	fmov	x26, d9
   8e054:	7100001f 	cmp	w0, #0x0
   8e058:	b94083e0 	ldr	w0, [sp, #128]
   8e05c:	7a4ea800 	ccmp	w0, #0xe, #0x0, ge	// ge = tcont
   8e060:	540017ad 	b.le	8e354 <_dtoa_r+0x9a4>
   8e064:	d503201f 	nop
   8e068:	2a1c03e3 	mov	w3, w28
   8e06c:	d2800019 	mov	x25, #0x0                   	// #0
   8e070:	29111fff 	stp	wzr, w7, [sp, #136]
   8e074:	b9408fe1 	ldr	w1, [sp, #140]
   8e078:	7100003f 	cmp	w1, #0x0
   8e07c:	7a40c8c4 	ccmp	w6, #0x0, #0x4, gt
   8e080:	540000ed 	b.le	8e09c <_dtoa_r+0x6ec>
   8e084:	6b06003f 	cmp	w1, w6
   8e088:	1a86d020 	csel	w0, w1, w6, le
   8e08c:	4b0000e7 	sub	w7, w7, w0
   8e090:	4b0000c6 	sub	w6, w6, w0
   8e094:	4b000021 	sub	w1, w1, w0
   8e098:	b9008fe1 	str	w1, [sp, #140]
   8e09c:	340001bc 	cbz	w28, 8e0d0 <_dtoa_r+0x720>
   8e0a0:	b9408be0 	ldr	w0, [sp, #136]
   8e0a4:	34003d80 	cbz	w0, 8e854 <_dtoa_r+0xea4>
   8e0a8:	35003003 	cbnz	w3, 8e6a8 <_dtoa_r+0xcf8>
   8e0ac:	aa1403e1 	mov	x1, x20
   8e0b0:	2a1c03e2 	mov	w2, w28
   8e0b4:	aa1303e0 	mov	x0, x19
   8e0b8:	b90093e7 	str	w7, [sp, #144]
   8e0bc:	29141be5 	stp	w5, w6, [sp, #160]
   8e0c0:	9400158c 	bl	936f0 <__pow5mult>
   8e0c4:	b94093e7 	ldr	w7, [sp, #144]
   8e0c8:	aa0003f4 	mov	x20, x0
   8e0cc:	29541be5 	ldp	w5, w6, [sp, #160]
   8e0d0:	aa1303e0 	mov	x0, x19
   8e0d4:	52800021 	mov	w1, #0x1                   	// #1
   8e0d8:	b90093e7 	str	w7, [sp, #144]
   8e0dc:	29141be5 	stp	w5, w6, [sp, #160]
   8e0e0:	940014d8 	bl	93440 <__i2b>
   8e0e4:	29541be5 	ldp	w5, w6, [sp, #160]
   8e0e8:	aa0003fc 	mov	x28, x0
   8e0ec:	b94093e7 	ldr	w7, [sp, #144]
   8e0f0:	350020c5 	cbnz	w5, 8e508 <_dtoa_r+0xb58>
   8e0f4:	710006bf 	cmp	w21, #0x1
   8e0f8:	5400018d 	b.le	8e128 <_dtoa_r+0x778>
   8e0fc:	52800020 	mov	w0, #0x1                   	// #1
   8e100:	0b060000 	add	w0, w0, w6
   8e104:	72001000 	ands	w0, w0, #0x1f
   8e108:	54000240 	b.eq	8e150 <_dtoa_r+0x7a0>  // b.none
   8e10c:	52800401 	mov	w1, #0x20                  	// #32
   8e110:	4b000021 	sub	w1, w1, w0
   8e114:	7100103f 	cmp	w1, #0x4
   8e118:	5400246d 	b.le	8e5a4 <_dtoa_r+0xbf4>
   8e11c:	52800381 	mov	w1, #0x1c                  	// #28
   8e120:	4b000020 	sub	w0, w1, w0
   8e124:	1400000c 	b	8e154 <_dtoa_r+0x7a4>
   8e128:	f240cf5f 	tst	x26, #0xfffffffffffff
   8e12c:	54fffe81 	b.ne	8e0fc <_dtoa_r+0x74c>  // b.any
   8e130:	d360ff40 	lsr	x0, x26, #32
   8e134:	f26c281f 	tst	x0, #0x7ff00000
   8e138:	54fffe20 	b.eq	8e0fc <_dtoa_r+0x74c>  // b.none
   8e13c:	52800025 	mov	w5, #0x1                   	// #1
   8e140:	110004e7 	add	w7, w7, #0x1
   8e144:	110004c6 	add	w6, w6, #0x1
   8e148:	2a0503e0 	mov	w0, w5
   8e14c:	17ffffed 	b	8e100 <_dtoa_r+0x750>
   8e150:	52800380 	mov	w0, #0x1c                  	// #28
   8e154:	b9408fe1 	ldr	w1, [sp, #140]
   8e158:	0b0000e7 	add	w7, w7, w0
   8e15c:	0b0000c6 	add	w6, w6, w0
   8e160:	0b000021 	add	w1, w1, w0
   8e164:	b9008fe1 	str	w1, [sp, #140]
   8e168:	710000ff 	cmp	w7, #0x0
   8e16c:	5400014d 	b.le	8e194 <_dtoa_r+0x7e4>
   8e170:	aa1403e1 	mov	x1, x20
   8e174:	2a0703e2 	mov	w2, w7
   8e178:	aa1303e0 	mov	x0, x19
   8e17c:	b90093e5 	str	w5, [sp, #144]
   8e180:	b900a3e6 	str	w6, [sp, #160]
   8e184:	940015a3 	bl	93810 <__lshift>
   8e188:	b94093e5 	ldr	w5, [sp, #144]
   8e18c:	aa0003f4 	mov	x20, x0
   8e190:	b940a3e6 	ldr	w6, [sp, #160]
   8e194:	710000df 	cmp	w6, #0x0
   8e198:	5400010d 	b.le	8e1b8 <_dtoa_r+0x808>
   8e19c:	aa1c03e1 	mov	x1, x28
   8e1a0:	2a0603e2 	mov	w2, w6
   8e1a4:	aa1303e0 	mov	x0, x19
   8e1a8:	b90093e5 	str	w5, [sp, #144]
   8e1ac:	94001599 	bl	93810 <__lshift>
   8e1b0:	aa0003fc 	mov	x28, x0
   8e1b4:	b94093e5 	ldr	w5, [sp, #144]
   8e1b8:	b9409be0 	ldr	w0, [sp, #152]
   8e1bc:	71000abf 	cmp	w21, #0x2
   8e1c0:	1a9fd7e4 	cset	w4, gt
   8e1c4:	35000f20 	cbnz	w0, 8e3a8 <_dtoa_r+0x9f8>
   8e1c8:	710002df 	cmp	w22, #0x0
   8e1cc:	7a40d884 	ccmp	w4, #0x0, #0x4, le
   8e1d0:	540002a0 	b.eq	8e224 <_dtoa_r+0x874>  // b.none
   8e1d4:	34001f16 	cbz	w22, 8e5b4 <_dtoa_r+0xc04>
   8e1d8:	2a3b03fa 	mvn	w26, w27
   8e1dc:	aa1703f5 	mov	x21, x23
   8e1e0:	aa1c03e1 	mov	x1, x28
   8e1e4:	aa1303e0 	mov	x0, x19
   8e1e8:	940013b6 	bl	930c0 <_Bfree>
   8e1ec:	b4000099 	cbz	x25, 8e1fc <_dtoa_r+0x84c>
   8e1f0:	aa1903e1 	mov	x1, x25
   8e1f4:	aa1303e0 	mov	x0, x19
   8e1f8:	940013b2 	bl	930c0 <_Bfree>
   8e1fc:	aa1403e1 	mov	x1, x20
   8e200:	aa1303e0 	mov	x0, x19
   8e204:	940013af 	bl	930c0 <_Bfree>
   8e208:	390002ff 	strb	wzr, [x23]
   8e20c:	f9403fe1 	ldr	x1, [sp, #120]
   8e210:	11000740 	add	w0, w26, #0x1
   8e214:	b9000020 	str	w0, [x1]
   8e218:	b4ffc338 	cbz	x24, 8da7c <_dtoa_r+0xcc>
   8e21c:	f9000317 	str	x23, [x24]
   8e220:	17fffe17 	b	8da7c <_dtoa_r+0xcc>
   8e224:	b9408be0 	ldr	w0, [sp, #136]
   8e228:	34000f80 	cbz	w0, 8e418 <_dtoa_r+0xa68>
   8e22c:	b9408fe2 	ldr	w2, [sp, #140]
   8e230:	7100005f 	cmp	w2, #0x0
   8e234:	540000ed 	b.le	8e250 <_dtoa_r+0x8a0>
   8e238:	aa1903e1 	mov	x1, x25
   8e23c:	aa1303e0 	mov	x0, x19
   8e240:	b9008be5 	str	w5, [sp, #136]
   8e244:	94001573 	bl	93810 <__lshift>
   8e248:	b9408be5 	ldr	w5, [sp, #136]
   8e24c:	aa0003f9 	mov	x25, x0
   8e250:	aa1903fb 	mov	x27, x25
   8e254:	35003845 	cbnz	w5, 8e95c <_dtoa_r+0xfac>
   8e258:	8b36c2f6 	add	x22, x23, w22, sxtw
   8e25c:	12000340 	and	w0, w26, #0x1
   8e260:	f9004bf7 	str	x23, [sp, #144]
   8e264:	b900abe0 	str	w0, [sp, #168]
   8e268:	aa1c03e1 	mov	x1, x28
   8e26c:	aa1403e0 	mov	x0, x20
   8e270:	97fffd64 	bl	8d800 <quorem>
   8e274:	b9008fe0 	str	w0, [sp, #140]
   8e278:	aa1903e1 	mov	x1, x25
   8e27c:	aa1403e0 	mov	x0, x20
   8e280:	940015c0 	bl	93980 <__mcmp>
   8e284:	b9008be0 	str	w0, [sp, #136]
   8e288:	aa1c03e1 	mov	x1, x28
   8e28c:	aa1b03e2 	mov	x2, x27
   8e290:	aa1303e0 	mov	x0, x19
   8e294:	940015cf 	bl	939d0 <__mdiff>
   8e298:	b9408fe1 	ldr	w1, [sp, #140]
   8e29c:	1100c023 	add	w3, w1, #0x30
   8e2a0:	aa0003e1 	mov	x1, x0
   8e2a4:	b9401000 	ldr	w0, [x0, #16]
   8e2a8:	350022c0 	cbnz	w0, 8e700 <_dtoa_r+0xd50>
   8e2ac:	aa1403e0 	mov	x0, x20
   8e2b0:	f9004fe1 	str	x1, [sp, #152]
   8e2b4:	b900a7e3 	str	w3, [sp, #164]
   8e2b8:	940015b2 	bl	93980 <__mcmp>
   8e2bc:	f9404fe1 	ldr	x1, [sp, #152]
   8e2c0:	2a0003e2 	mov	w2, w0
   8e2c4:	aa1303e0 	mov	x0, x19
   8e2c8:	b900a3e2 	str	w2, [sp, #160]
   8e2cc:	9400137d 	bl	930c0 <_Bfree>
   8e2d0:	29540fe2 	ldp	w2, w3, [sp, #160]
   8e2d4:	2a0202a0 	orr	w0, w21, w2
   8e2d8:	350025c0 	cbnz	w0, 8e790 <_dtoa_r+0xde0>
   8e2dc:	b940abe0 	ldr	w0, [sp, #168]
   8e2e0:	34003920 	cbz	w0, 8ea04 <_dtoa_r+0x1054>
   8e2e4:	b9408be0 	ldr	w0, [sp, #136]
   8e2e8:	37f82400 	tbnz	w0, #31, 8e768 <_dtoa_r+0xdb8>
   8e2ec:	f9404be0 	ldr	x0, [sp, #144]
   8e2f0:	38001403 	strb	w3, [x0], #1
   8e2f4:	f9004be0 	str	x0, [sp, #144]
   8e2f8:	eb0002df 	cmp	x22, x0
   8e2fc:	540036e0 	b.eq	8e9d8 <_dtoa_r+0x1028>  // b.none
   8e300:	aa1403e1 	mov	x1, x20
   8e304:	52800003 	mov	w3, #0x0                   	// #0
   8e308:	52800142 	mov	w2, #0xa                   	// #10
   8e30c:	aa1303e0 	mov	x0, x19
   8e310:	94001374 	bl	930e0 <__multadd>
   8e314:	aa0003f4 	mov	x20, x0
   8e318:	aa1903e1 	mov	x1, x25
   8e31c:	aa1303e0 	mov	x0, x19
   8e320:	52800003 	mov	w3, #0x0                   	// #0
   8e324:	52800142 	mov	w2, #0xa                   	// #10
   8e328:	eb1b033f 	cmp	x25, x27
   8e32c:	540022a0 	b.eq	8e780 <_dtoa_r+0xdd0>  // b.none
   8e330:	9400136c 	bl	930e0 <__multadd>
   8e334:	aa0003f9 	mov	x25, x0
   8e338:	aa1b03e1 	mov	x1, x27
   8e33c:	aa1303e0 	mov	x0, x19
   8e340:	52800003 	mov	w3, #0x0                   	// #0
   8e344:	52800142 	mov	w2, #0xa                   	// #10
   8e348:	94001366 	bl	930e0 <__multadd>
   8e34c:	aa0003fb 	mov	x27, x0
   8e350:	17ffffc6 	b	8e268 <_dtoa_r+0x8b8>
   8e354:	b94083e0 	ldr	w0, [sp, #128]
   8e358:	7100037f 	cmp	w27, #0x0
   8e35c:	7a40bac0 	ccmp	w22, #0x0, #0x0, lt	// lt = tstop
   8e360:	fc60d881 	ldr	d1, [x4, w0, sxtw #3]
   8e364:	540028cc 	b.gt	8e87c <_dtoa_r+0xecc>
   8e368:	350015f6 	cbnz	w22, 8e624 <_dtoa_r+0xc74>
   8e36c:	1e629000 	fmov	d0, #5.000000000000000000e+00
   8e370:	1e600821 	fmul	d1, d1, d0
   8e374:	9e670340 	fmov	d0, x26
   8e378:	1e602030 	fcmpe	d1, d0
   8e37c:	5400154a 	b.ge	8e624 <_dtoa_r+0xc74>  // b.tcont
   8e380:	aa1703f5 	mov	x21, x23
   8e384:	d280001c 	mov	x28, #0x0                   	// #0
   8e388:	d2800019 	mov	x25, #0x0                   	// #0
   8e38c:	14000096 	b	8e5e4 <_dtoa_r+0xc34>
   8e390:	52800020 	mov	w0, #0x1                   	// #1
   8e394:	b9008be0 	str	w0, [sp, #136]
   8e398:	17fffee4 	b	8df28 <_dtoa_r+0x578>
   8e39c:	5280003b 	mov	w27, #0x1                   	// #1
   8e3a0:	2a1b03f6 	mov	w22, w27
   8e3a4:	17fffec7 	b	8dec0 <_dtoa_r+0x510>
   8e3a8:	aa1c03e1 	mov	x1, x28
   8e3ac:	aa1403e0 	mov	x0, x20
   8e3b0:	b90093e5 	str	w5, [sp, #144]
   8e3b4:	b900a3e4 	str	w4, [sp, #160]
   8e3b8:	94001572 	bl	93980 <__mcmp>
   8e3bc:	b94093e5 	ldr	w5, [sp, #144]
   8e3c0:	b940a3e4 	ldr	w4, [sp, #160]
   8e3c4:	36fff020 	tbz	w0, #31, 8e1c8 <_dtoa_r+0x818>
   8e3c8:	aa1403e1 	mov	x1, x20
   8e3cc:	aa1303e0 	mov	x0, x19
   8e3d0:	52800003 	mov	w3, #0x0                   	// #0
   8e3d4:	52800142 	mov	w2, #0xa                   	// #10
   8e3d8:	b90093e5 	str	w5, [sp, #144]
   8e3dc:	b900a3e4 	str	w4, [sp, #160]
   8e3e0:	94001340 	bl	930e0 <__multadd>
   8e3e4:	b94083e1 	ldr	w1, [sp, #128]
   8e3e8:	aa0003f4 	mov	x20, x0
   8e3ec:	b9408be0 	ldr	w0, [sp, #136]
   8e3f0:	51000421 	sub	w1, w1, #0x1
   8e3f4:	b90083e1 	str	w1, [sp, #128]
   8e3f8:	b94093e5 	ldr	w5, [sp, #144]
   8e3fc:	b940a3e4 	ldr	w4, [sp, #160]
   8e400:	350031e0 	cbnz	w0, 8ea3c <_dtoa_r+0x108c>
   8e404:	b940abe0 	ldr	w0, [sp, #168]
   8e408:	7100001f 	cmp	w0, #0x0
   8e40c:	2a0003f6 	mov	w22, w0
   8e410:	7a40d884 	ccmp	w4, #0x0, #0x4, le
   8e414:	54ffee01 	b.ne	8e1d4 <_dtoa_r+0x824>  // b.any
   8e418:	d2800015 	mov	x21, #0x0                   	// #0
   8e41c:	14000007 	b	8e438 <_dtoa_r+0xa88>
   8e420:	aa1403e1 	mov	x1, x20
   8e424:	aa1303e0 	mov	x0, x19
   8e428:	52800003 	mov	w3, #0x0                   	// #0
   8e42c:	52800142 	mov	w2, #0xa                   	// #10
   8e430:	9400132c 	bl	930e0 <__multadd>
   8e434:	aa0003f4 	mov	x20, x0
   8e438:	aa1c03e1 	mov	x1, x28
   8e43c:	aa1403e0 	mov	x0, x20
   8e440:	97fffcf0 	bl	8d800 <quorem>
   8e444:	1100c003 	add	w3, w0, #0x30
   8e448:	38356ae3 	strb	w3, [x23, x21]
   8e44c:	910006b5 	add	x21, x21, #0x1
   8e450:	6b1502df 	cmp	w22, w21
   8e454:	54fffe6c 	b.gt	8e420 <_dtoa_r+0xa70>
   8e458:	710002df 	cmp	w22, #0x0
   8e45c:	510006d6 	sub	w22, w22, #0x1
   8e460:	d2800020 	mov	x0, #0x1                   	// #1
   8e464:	9a96d416 	csinc	x22, x0, x22, le
   8e468:	8b1602f6 	add	x22, x23, x22
   8e46c:	d2800015 	mov	x21, #0x0                   	// #0
   8e470:	52800022 	mov	w2, #0x1                   	// #1
   8e474:	aa1403e1 	mov	x1, x20
   8e478:	aa1303e0 	mov	x0, x19
   8e47c:	b9008be3 	str	w3, [sp, #136]
   8e480:	940014e4 	bl	93810 <__lshift>
   8e484:	aa0003f4 	mov	x20, x0
   8e488:	aa1c03e1 	mov	x1, x28
   8e48c:	9400153d 	bl	93980 <__mcmp>
   8e490:	7100001f 	cmp	w0, #0x0
   8e494:	5400008c 	b.gt	8e4a4 <_dtoa_r+0xaf4>
   8e498:	14000117 	b	8e8f4 <_dtoa_r+0xf44>
   8e49c:	eb1602ff 	cmp	x23, x22
   8e4a0:	540023e0 	b.eq	8e91c <_dtoa_r+0xf6c>  // b.none
   8e4a4:	aa1603e2 	mov	x2, x22
   8e4a8:	d10006d6 	sub	x22, x22, #0x1
   8e4ac:	385ff040 	ldurb	w0, [x2, #-1]
   8e4b0:	7100e41f 	cmp	w0, #0x39
   8e4b4:	54ffff40 	b.eq	8e49c <_dtoa_r+0xaec>  // b.none
   8e4b8:	b94083fa 	ldr	w26, [sp, #128]
   8e4bc:	11000400 	add	w0, w0, #0x1
   8e4c0:	390002c0 	strb	w0, [x22]
   8e4c4:	aa1c03e1 	mov	x1, x28
   8e4c8:	aa1303e0 	mov	x0, x19
   8e4cc:	f90043e2 	str	x2, [sp, #128]
   8e4d0:	940012fc 	bl	930c0 <_Bfree>
   8e4d4:	f94043e2 	ldr	x2, [sp, #128]
   8e4d8:	b40009b9 	cbz	x25, 8e60c <_dtoa_r+0xc5c>
   8e4dc:	f10002bf 	cmp	x21, #0x0
   8e4e0:	fa5912a4 	ccmp	x21, x25, #0x4, ne	// ne = any
   8e4e4:	540000c0 	b.eq	8e4fc <_dtoa_r+0xb4c>  // b.none
   8e4e8:	aa1503e1 	mov	x1, x21
   8e4ec:	aa1303e0 	mov	x0, x19
   8e4f0:	f90043e2 	str	x2, [sp, #128]
   8e4f4:	940012f3 	bl	930c0 <_Bfree>
   8e4f8:	f94043e2 	ldr	x2, [sp, #128]
   8e4fc:	aa1703f5 	mov	x21, x23
   8e500:	aa0203f7 	mov	x23, x2
   8e504:	17ffff3b 	b	8e1f0 <_dtoa_r+0x840>
   8e508:	aa0003e1 	mov	x1, x0
   8e50c:	2a0503e2 	mov	w2, w5
   8e510:	aa1303e0 	mov	x0, x19
   8e514:	b90093e7 	str	w7, [sp, #144]
   8e518:	b900a3e6 	str	w6, [sp, #160]
   8e51c:	94001475 	bl	936f0 <__pow5mult>
   8e520:	b94093e7 	ldr	w7, [sp, #144]
   8e524:	aa0003fc 	mov	x28, x0
   8e528:	b940a3e6 	ldr	w6, [sp, #160]
   8e52c:	710006bf 	cmp	w21, #0x1
   8e530:	54000a4d 	b.le	8e678 <_dtoa_r+0xcc8>
   8e534:	52800005 	mov	w5, #0x0                   	// #0
   8e538:	b9401780 	ldr	w0, [x28, #20]
   8e53c:	b90093e7 	str	w7, [sp, #144]
   8e540:	51000400 	sub	w0, w0, #0x1
   8e544:	29141be5 	stp	w5, w6, [sp, #160]
   8e548:	8b20cb80 	add	x0, x28, w0, sxtw #2
   8e54c:	b9401800 	ldr	w0, [x0, #24]
   8e550:	94001374 	bl	93320 <__hi0bits>
   8e554:	52800401 	mov	w1, #0x20                  	// #32
   8e558:	b94093e7 	ldr	w7, [sp, #144]
   8e55c:	29541be5 	ldp	w5, w6, [sp, #160]
   8e560:	4b000020 	sub	w0, w1, w0
   8e564:	17fffee7 	b	8e100 <_dtoa_r+0x750>
   8e568:	1e604121 	fmov	d1, d9
   8e56c:	52800042 	mov	w2, #0x2                   	// #2
   8e570:	17fffdcc 	b	8dca0 <_dtoa_r+0x2f0>
   8e574:	eb0002ff 	cmp	x23, x0
   8e578:	54001dc0 	b.eq	8e930 <_dtoa_r+0xf80>  // b.none
   8e57c:	aa0003e2 	mov	x2, x0
   8e580:	385ffc01 	ldrb	w1, [x0, #-1]!
   8e584:	7100e43f 	cmp	w1, #0x39
   8e588:	54ffff60 	b.eq	8e574 <_dtoa_r+0xbc4>  // b.none
   8e58c:	11000421 	add	w1, w1, #0x1
   8e590:	12001c21 	and	w1, w1, #0xff
   8e594:	aa1703f5 	mov	x21, x23
   8e598:	aa0203f7 	mov	x23, x2
   8e59c:	39000001 	strb	w1, [x0]
   8e5a0:	17ffff17 	b	8e1fc <_dtoa_r+0x84c>
   8e5a4:	52800781 	mov	w1, #0x3c                  	// #60
   8e5a8:	4b000020 	sub	w0, w1, w0
   8e5ac:	54ffdde0 	b.eq	8e168 <_dtoa_r+0x7b8>  // b.none
   8e5b0:	17fffee9 	b	8e154 <_dtoa_r+0x7a4>
   8e5b4:	52800003 	mov	w3, #0x0                   	// #0
   8e5b8:	528000a2 	mov	w2, #0x5                   	// #5
   8e5bc:	aa1c03e1 	mov	x1, x28
   8e5c0:	aa1303e0 	mov	x0, x19
   8e5c4:	940012c7 	bl	930e0 <__multadd>
   8e5c8:	aa0003fc 	mov	x28, x0
   8e5cc:	aa1c03e1 	mov	x1, x28
   8e5d0:	aa1403e0 	mov	x0, x20
   8e5d4:	aa1703f5 	mov	x21, x23
   8e5d8:	940014ea 	bl	93980 <__mcmp>
   8e5dc:	7100001f 	cmp	w0, #0x0
   8e5e0:	54ffdfcd 	b.le	8e1d8 <_dtoa_r+0x828>
   8e5e4:	b94083e0 	ldr	w0, [sp, #128]
   8e5e8:	910006f7 	add	x23, x23, #0x1
   8e5ec:	1100041a 	add	w26, w0, #0x1
   8e5f0:	52800620 	mov	w0, #0x31                  	// #49
   8e5f4:	390002a0 	strb	w0, [x21]
   8e5f8:	17fffefa 	b	8e1e0 <_dtoa_r+0x830>
   8e5fc:	aa0003e2 	mov	x2, x0
   8e600:	385ffc01 	ldrb	w1, [x0, #-1]!
   8e604:	7100c03f 	cmp	w1, #0x30
   8e608:	54ffffa0 	b.eq	8e5fc <_dtoa_r+0xc4c>  // b.none
   8e60c:	aa1703f5 	mov	x21, x23
   8e610:	aa0203f7 	mov	x23, x2
   8e614:	17fffefa 	b	8e1fc <_dtoa_r+0x84c>
   8e618:	1e604121 	fmov	d1, d9
   8e61c:	52800042 	mov	w2, #0x2                   	// #2
   8e620:	17fffdac 	b	8dcd0 <_dtoa_r+0x320>
   8e624:	d280001c 	mov	x28, #0x0                   	// #0
   8e628:	d2800019 	mov	x25, #0x0                   	// #0
   8e62c:	17fffeeb 	b	8e1d8 <_dtoa_r+0x828>
   8e630:	4b1c0060 	sub	w0, w3, w28
   8e634:	0b1600c6 	add	w6, w6, w22
   8e638:	0b0000a5 	add	w5, w5, w0
   8e63c:	b9008fe7 	str	w7, [sp, #140]
   8e640:	0b0702c7 	add	w7, w22, w7
   8e644:	2a0303fc 	mov	w28, w3
   8e648:	52800003 	mov	w3, #0x0                   	// #0
   8e64c:	aa1303e0 	mov	x0, x19
   8e650:	52800021 	mov	w1, #0x1                   	// #1
   8e654:	b90093e7 	str	w7, [sp, #144]
   8e658:	29140fe5 	stp	w5, w3, [sp, #160]
   8e65c:	b900afe6 	str	w6, [sp, #172]
   8e660:	94001378 	bl	93440 <__i2b>
   8e664:	b94093e7 	ldr	w7, [sp, #144]
   8e668:	aa0003f9 	mov	x25, x0
   8e66c:	29540fe5 	ldp	w5, w3, [sp, #160]
   8e670:	b940afe6 	ldr	w6, [sp, #172]
   8e674:	17fffe80 	b	8e074 <_dtoa_r+0x6c4>
   8e678:	f240cf5f 	tst	x26, #0xfffffffffffff
   8e67c:	54fff5c1 	b.ne	8e534 <_dtoa_r+0xb84>  // b.any
   8e680:	d360ff40 	lsr	x0, x26, #32
   8e684:	f26c281f 	tst	x0, #0x7ff00000
   8e688:	54fff560 	b.eq	8e534 <_dtoa_r+0xb84>  // b.none
   8e68c:	110004e7 	add	w7, w7, #0x1
   8e690:	110004c6 	add	w6, w6, #0x1
   8e694:	52800025 	mov	w5, #0x1                   	// #1
   8e698:	17ffffa8 	b	8e538 <_dtoa_r+0xb88>
   8e69c:	52800055 	mov	w21, #0x2                   	// #2
   8e6a0:	b9008bff 	str	wzr, [sp, #136]
   8e6a4:	17fffe21 	b	8df28 <_dtoa_r+0x578>
   8e6a8:	2a0303e2 	mov	w2, w3
   8e6ac:	aa1903e1 	mov	x1, x25
   8e6b0:	aa1303e0 	mov	x0, x19
   8e6b4:	b90093e3 	str	w3, [sp, #144]
   8e6b8:	291417e7 	stp	w7, w5, [sp, #160]
   8e6bc:	b900afe6 	str	w6, [sp, #172]
   8e6c0:	9400140c 	bl	936f0 <__pow5mult>
   8e6c4:	aa1403e2 	mov	x2, x20
   8e6c8:	aa0003f9 	mov	x25, x0
   8e6cc:	aa1903e1 	mov	x1, x25
   8e6d0:	aa1303e0 	mov	x0, x19
   8e6d4:	9400138b 	bl	93500 <__multiply>
   8e6d8:	aa1403e1 	mov	x1, x20
   8e6dc:	aa0003f4 	mov	x20, x0
   8e6e0:	aa1303e0 	mov	x0, x19
   8e6e4:	94001277 	bl	930c0 <_Bfree>
   8e6e8:	b94093e3 	ldr	w3, [sp, #144]
   8e6ec:	295417e7 	ldp	w7, w5, [sp, #160]
   8e6f0:	6b03039c 	subs	w28, w28, w3
   8e6f4:	b940afe6 	ldr	w6, [sp, #172]
   8e6f8:	54ffcec0 	b.eq	8e0d0 <_dtoa_r+0x720>  // b.none
   8e6fc:	17fffe6c 	b	8e0ac <_dtoa_r+0x6fc>
   8e700:	aa1303e0 	mov	x0, x19
   8e704:	b900a3e3 	str	w3, [sp, #160]
   8e708:	9400126e 	bl	930c0 <_Bfree>
   8e70c:	b9408be0 	ldr	w0, [sp, #136]
   8e710:	b940a3e3 	ldr	w3, [sp, #160]
   8e714:	37f800c0 	tbnz	w0, #31, 8e72c <_dtoa_r+0xd7c>
   8e718:	b9408be0 	ldr	w0, [sp, #136]
   8e71c:	1200035a 	and	w26, w26, #0x1
   8e720:	2a0002a0 	orr	w0, w21, w0
   8e724:	2a00035a 	orr	w26, w26, w0
   8e728:	3500045a 	cbnz	w26, 8e7b0 <_dtoa_r+0xe00>
   8e72c:	52800022 	mov	w2, #0x1                   	// #1
   8e730:	aa1403e1 	mov	x1, x20
   8e734:	aa1303e0 	mov	x0, x19
   8e738:	b9008be3 	str	w3, [sp, #136]
   8e73c:	94001435 	bl	93810 <__lshift>
   8e740:	aa0003f4 	mov	x20, x0
   8e744:	aa1c03e1 	mov	x1, x28
   8e748:	9400148e 	bl	93980 <__mcmp>
   8e74c:	b9408be3 	ldr	w3, [sp, #136]
   8e750:	7100001f 	cmp	w0, #0x0
   8e754:	5400198d 	b.le	8ea84 <_dtoa_r+0x10d4>
   8e758:	7100e47f 	cmp	w3, #0x39
   8e75c:	54001440 	b.eq	8e9e4 <_dtoa_r+0x1034>  // b.none
   8e760:	b9408fe0 	ldr	w0, [sp, #140]
   8e764:	1100c403 	add	w3, w0, #0x31
   8e768:	f9404be2 	ldr	x2, [sp, #144]
   8e76c:	aa1903f5 	mov	x21, x25
   8e770:	b94083fa 	ldr	w26, [sp, #128]
   8e774:	aa1b03f9 	mov	x25, x27
   8e778:	38001443 	strb	w3, [x2], #1
   8e77c:	17ffff52 	b	8e4c4 <_dtoa_r+0xb14>
   8e780:	94001258 	bl	930e0 <__multadd>
   8e784:	aa0003f9 	mov	x25, x0
   8e788:	aa0003fb 	mov	x27, x0
   8e78c:	17fffeb7 	b	8e268 <_dtoa_r+0x8b8>
   8e790:	b9408be0 	ldr	w0, [sp, #136]
   8e794:	37f81920 	tbnz	w0, #31, 8eab8 <_dtoa_r+0x1108>
   8e798:	b940abe1 	ldr	w1, [sp, #168]
   8e79c:	2a0002a0 	orr	w0, w21, w0
   8e7a0:	2a000020 	orr	w0, w1, w0
   8e7a4:	340018a0 	cbz	w0, 8eab8 <_dtoa_r+0x1108>
   8e7a8:	7100005f 	cmp	w2, #0x0
   8e7ac:	54ffda0d 	b.le	8e2ec <_dtoa_r+0x93c>
   8e7b0:	7100e47f 	cmp	w3, #0x39
   8e7b4:	54001180 	b.eq	8e9e4 <_dtoa_r+0x1034>  // b.none
   8e7b8:	f9404be2 	ldr	x2, [sp, #144]
   8e7bc:	11000463 	add	w3, w3, #0x1
   8e7c0:	aa1903f5 	mov	x21, x25
   8e7c4:	b94083fa 	ldr	w26, [sp, #128]
   8e7c8:	aa1b03f9 	mov	x25, x27
   8e7cc:	38001443 	strb	w3, [x2], #1
   8e7d0:	17ffff3d 	b	8e4c4 <_dtoa_r+0xb14>
   8e7d4:	b9008bff 	str	wzr, [sp, #136]
   8e7d8:	17fffcff 	b	8dbd4 <_dtoa_r+0x224>
   8e7dc:	34ffbb36 	cbz	w22, 8df40 <_dtoa_r+0x590>
   8e7e0:	b940abe8 	ldr	w8, [sp, #168]
   8e7e4:	7100011f 	cmp	w8, #0x0
   8e7e8:	54ffae4d 	b.le	8ddb0 <_dtoa_r+0x400>
   8e7ec:	11000442 	add	w2, w2, #0x1
   8e7f0:	1e649003 	fmov	d3, #1.000000000000000000e+01
   8e7f4:	1e639000 	fmov	d0, #7.000000000000000000e+00
   8e7f8:	b94083e0 	ldr	w0, [sp, #128]
   8e7fc:	1e620042 	scvtf	d2, w2
   8e800:	1e630821 	fmul	d1, d1, d3
   8e804:	5100041a 	sub	w26, w0, #0x1
   8e808:	52bf9804 	mov	w4, #0xfcc00000            	// #-54525952
   8e80c:	1f420020 	fmadd	d0, d1, d2, d0
   8e810:	9e660000 	fmov	x0, d0
   8e814:	d360fc01 	lsr	x1, x0, #32
   8e818:	0b040021 	add	w1, w1, w4
   8e81c:	b3607c20 	bfi	x0, x1, #32, #32
   8e820:	17fffd3c 	b	8dd10 <_dtoa_r+0x360>
   8e824:	b940a7e1 	ldr	w1, [sp, #164]
   8e828:	340008a1 	cbz	w1, 8e93c <_dtoa_r+0xf8c>
   8e82c:	1110cc00 	add	w0, w0, #0x433
   8e830:	2a1c03e3 	mov	w3, w28
   8e834:	0b0000c6 	add	w6, w6, w0
   8e838:	b9008fe7 	str	w7, [sp, #140]
   8e83c:	0b0000e7 	add	w7, w7, w0
   8e840:	17ffff83 	b	8e64c <_dtoa_r+0xc9c>
   8e844:	9132e2b5 	add	x21, x21, #0xcb8
   8e848:	17fffc8d 	b	8da7c <_dtoa_r+0xcc>
   8e84c:	913322b5 	add	x21, x21, #0xcc8
   8e850:	17fffc8b 	b	8da7c <_dtoa_r+0xcc>
   8e854:	aa1403e1 	mov	x1, x20
   8e858:	2a1c03e2 	mov	w2, w28
   8e85c:	aa1303e0 	mov	x0, x19
   8e860:	b90093e7 	str	w7, [sp, #144]
   8e864:	29141be5 	stp	w5, w6, [sp, #160]
   8e868:	940013a2 	bl	936f0 <__pow5mult>
   8e86c:	b94093e7 	ldr	w7, [sp, #144]
   8e870:	aa0003f4 	mov	x20, x0
   8e874:	29541be5 	ldp	w5, w6, [sp, #160]
   8e878:	17fffe16 	b	8e0d0 <_dtoa_r+0x720>
   8e87c:	9e670340 	fmov	d0, x26
   8e880:	aa1703e1 	mov	x1, x23
   8e884:	1e611802 	fdiv	d2, d0, d1
   8e888:	1e780042 	fcvtzs	w2, d2
   8e88c:	1e620042 	scvtf	d2, w2
   8e890:	1100c040 	add	w0, w2, #0x30
   8e894:	38001420 	strb	w0, [x1], #1
   8e898:	1f418040 	fmsub	d0, d2, d1, d0
   8e89c:	710006df 	cmp	w22, #0x1
   8e8a0:	54000860 	b.eq	8e9ac <_dtoa_r+0xffc>  // b.none
   8e8a4:	51000860 	sub	w0, w3, #0x2
   8e8a8:	1e649003 	fmov	d3, #1.000000000000000000e+01
   8e8ac:	91000800 	add	x0, x0, #0x2
   8e8b0:	8b0002e0 	add	x0, x23, x0
   8e8b4:	14000009 	b	8e8d8 <_dtoa_r+0xf28>
   8e8b8:	1e611802 	fdiv	d2, d0, d1
   8e8bc:	1e780042 	fcvtzs	w2, d2
   8e8c0:	1e620042 	scvtf	d2, w2
   8e8c4:	1100c043 	add	w3, w2, #0x30
   8e8c8:	38001423 	strb	w3, [x1], #1
   8e8cc:	1f418040 	fmsub	d0, d2, d1, d0
   8e8d0:	eb01001f 	cmp	x0, x1
   8e8d4:	540006e0 	b.eq	8e9b0 <_dtoa_r+0x1000>  // b.none
   8e8d8:	1e630800 	fmul	d0, d0, d3
   8e8dc:	1e602008 	fcmp	d0, #0.0
   8e8e0:	54fffec1 	b.ne	8e8b8 <_dtoa_r+0xf08>  // b.any
   8e8e4:	aa1703f5 	mov	x21, x23
   8e8e8:	b94083fa 	ldr	w26, [sp, #128]
   8e8ec:	aa0103f7 	mov	x23, x1
   8e8f0:	17fffe43 	b	8e1fc <_dtoa_r+0x84c>
   8e8f4:	54000061 	b.ne	8e900 <_dtoa_r+0xf50>  // b.any
   8e8f8:	b9408be3 	ldr	w3, [sp, #136]
   8e8fc:	3707dd43 	tbnz	w3, #0, 8e4a4 <_dtoa_r+0xaf4>
   8e900:	aa1603e2 	mov	x2, x22
   8e904:	d10006d6 	sub	x22, x22, #0x1
   8e908:	385ff040 	ldurb	w0, [x2, #-1]
   8e90c:	7100c01f 	cmp	w0, #0x30
   8e910:	54ffff80 	b.eq	8e900 <_dtoa_r+0xf50>  // b.none
   8e914:	b94083fa 	ldr	w26, [sp, #128]
   8e918:	17fffeeb 	b	8e4c4 <_dtoa_r+0xb14>
   8e91c:	b94083e0 	ldr	w0, [sp, #128]
   8e920:	1100041a 	add	w26, w0, #0x1
   8e924:	52800620 	mov	w0, #0x31                  	// #49
   8e928:	390002e0 	strb	w0, [x23]
   8e92c:	17fffee6 	b	8e4c4 <_dtoa_r+0xb14>
   8e930:	1100075a 	add	w26, w26, #0x1
   8e934:	52800621 	mov	w1, #0x31                  	// #49
   8e938:	17ffff17 	b	8e594 <_dtoa_r+0xbe4>
   8e93c:	b940bbe1 	ldr	w1, [sp, #184]
   8e940:	528006c0 	mov	w0, #0x36                  	// #54
   8e944:	2a1c03e3 	mov	w3, w28
   8e948:	b9008fe7 	str	w7, [sp, #140]
   8e94c:	4b010000 	sub	w0, w0, w1
   8e950:	0b0000c6 	add	w6, w6, w0
   8e954:	0b0000e7 	add	w7, w7, w0
   8e958:	17ffff3d 	b	8e64c <_dtoa_r+0xc9c>
   8e95c:	b9400b21 	ldr	w1, [x25, #8]
   8e960:	aa1303e0 	mov	x0, x19
   8e964:	940011b3 	bl	93030 <_Balloc>
   8e968:	aa0003fb 	mov	x27, x0
   8e96c:	b4000980 	cbz	x0, 8ea9c <_dtoa_r+0x10ec>
   8e970:	b9801722 	ldrsw	x2, [x25, #20]
   8e974:	91004321 	add	x1, x25, #0x10
   8e978:	91004000 	add	x0, x0, #0x10
   8e97c:	91000842 	add	x2, x2, #0x2
   8e980:	d37ef442 	lsl	x2, x2, #2
   8e984:	97fffa0f 	bl	8d1c0 <memcpy>
   8e988:	aa1b03e1 	mov	x1, x27
   8e98c:	aa1303e0 	mov	x0, x19
   8e990:	52800022 	mov	w2, #0x1                   	// #1
   8e994:	9400139f 	bl	93810 <__lshift>
   8e998:	aa0003fb 	mov	x27, x0
   8e99c:	17fffe2f 	b	8e258 <_dtoa_r+0x8a8>
   8e9a0:	aa1703f5 	mov	x21, x23
   8e9a4:	aa0003f7 	mov	x23, x0
   8e9a8:	17fffe15 	b	8e1fc <_dtoa_r+0x84c>
   8e9ac:	aa0103e0 	mov	x0, x1
   8e9b0:	1e602800 	fadd	d0, d0, d0
   8e9b4:	1e612010 	fcmpe	d0, d1
   8e9b8:	5400022c 	b.gt	8e9fc <_dtoa_r+0x104c>
   8e9bc:	1e612000 	fcmp	d0, d1
   8e9c0:	54000041 	b.ne	8e9c8 <_dtoa_r+0x1018>  // b.any
   8e9c4:	370001c2 	tbnz	w2, #0, 8e9fc <_dtoa_r+0x104c>
   8e9c8:	aa1703f5 	mov	x21, x23
   8e9cc:	b94083fa 	ldr	w26, [sp, #128]
   8e9d0:	aa0003f7 	mov	x23, x0
   8e9d4:	17fffe0a 	b	8e1fc <_dtoa_r+0x84c>
   8e9d8:	aa1903f5 	mov	x21, x25
   8e9dc:	aa1b03f9 	mov	x25, x27
   8e9e0:	17fffea4 	b	8e470 <_dtoa_r+0xac0>
   8e9e4:	f9404bf6 	ldr	x22, [sp, #144]
   8e9e8:	aa1903f5 	mov	x21, x25
   8e9ec:	52800720 	mov	w0, #0x39                  	// #57
   8e9f0:	aa1b03f9 	mov	x25, x27
   8e9f4:	380016c0 	strb	w0, [x22], #1
   8e9f8:	17fffeab 	b	8e4a4 <_dtoa_r+0xaf4>
   8e9fc:	b94083fa 	ldr	w26, [sp, #128]
   8ea00:	17fffedf 	b	8e57c <_dtoa_r+0xbcc>
   8ea04:	7100e47f 	cmp	w3, #0x39
   8ea08:	54fffee0 	b.eq	8e9e4 <_dtoa_r+0x1034>  // b.none
   8ea0c:	f9404be2 	ldr	x2, [sp, #144]
   8ea10:	aa1903f5 	mov	x21, x25
   8ea14:	295103e1 	ldp	w1, w0, [sp, #136]
   8ea18:	aa1b03f9 	mov	x25, x27
   8ea1c:	b94083fa 	ldr	w26, [sp, #128]
   8ea20:	1100c400 	add	w0, w0, #0x31
   8ea24:	7100003f 	cmp	w1, #0x0
   8ea28:	1a83c003 	csel	w3, w0, w3, gt
   8ea2c:	38001443 	strb	w3, [x2], #1
   8ea30:	17fffea5 	b	8e4c4 <_dtoa_r+0xb14>
   8ea34:	aa0203e0 	mov	x0, x2
   8ea38:	17fffd7e 	b	8e030 <_dtoa_r+0x680>
   8ea3c:	aa1903e1 	mov	x1, x25
   8ea40:	aa1303e0 	mov	x0, x19
   8ea44:	52800003 	mov	w3, #0x0                   	// #0
   8ea48:	52800142 	mov	w2, #0xa                   	// #10
   8ea4c:	b9008be5 	str	w5, [sp, #136]
   8ea50:	b90093e4 	str	w4, [sp, #144]
   8ea54:	940011a3 	bl	930e0 <__multadd>
   8ea58:	b940abf6 	ldr	w22, [sp, #168]
   8ea5c:	aa0003f9 	mov	x25, x0
   8ea60:	b94093e4 	ldr	w4, [sp, #144]
   8ea64:	710002df 	cmp	w22, #0x0
   8ea68:	7a40d884 	ccmp	w4, #0x0, #0x4, le
   8ea6c:	54000121 	b.ne	8ea90 <_dtoa_r+0x10e0>  // b.any
   8ea70:	b9408be5 	ldr	w5, [sp, #136]
   8ea74:	17fffdee 	b	8e22c <_dtoa_r+0x87c>
   8ea78:	1e604041 	fmov	d1, d2
   8ea7c:	52800042 	mov	w2, #0x2                   	// #2
   8ea80:	17fffc94 	b	8dcd0 <_dtoa_r+0x320>
   8ea84:	54ffe721 	b.ne	8e768 <_dtoa_r+0xdb8>  // b.any
   8ea88:	3707e683 	tbnz	w3, #0, 8e758 <_dtoa_r+0xda8>
   8ea8c:	17ffff37 	b	8e768 <_dtoa_r+0xdb8>
   8ea90:	b940abf6 	ldr	w22, [sp, #168]
   8ea94:	35ffba36 	cbnz	w22, 8e1d8 <_dtoa_r+0x828>
   8ea98:	17fffec7 	b	8e5b4 <_dtoa_r+0xc04>
   8ea9c:	f0000023 	adrp	x3, 95000 <pmu_event_descr+0x60>
   8eaa0:	f0000020 	adrp	x0, 95000 <pmu_event_descr+0x60>
   8eaa4:	91334063 	add	x3, x3, #0xcd0
   8eaa8:	9133a000 	add	x0, x0, #0xce8
   8eaac:	d2800002 	mov	x2, #0x0                   	// #0
   8eab0:	52805de1 	mov	w1, #0x2ef                 	// #751
   8eab4:	94001103 	bl	92ec0 <__assert_func>
   8eab8:	7100005f 	cmp	w2, #0x0
   8eabc:	54ffe38c 	b.gt	8e72c <_dtoa_r+0xd7c>
   8eac0:	17ffff2a 	b	8e768 <_dtoa_r+0xdb8>
   8eac4:	b9005a7f 	str	wzr, [x19, #88]
   8eac8:	aa1303e0 	mov	x0, x19
   8eacc:	52800001 	mov	w1, #0x0                   	// #0
   8ead0:	291117e7 	stp	w7, w5, [sp, #136]
   8ead4:	b90093e6 	str	w6, [sp, #144]
   8ead8:	94001156 	bl	93030 <_Balloc>
   8eadc:	295117e7 	ldp	w7, w5, [sp, #136]
   8eae0:	aa0003f7 	mov	x23, x0
   8eae4:	b94093e6 	ldr	w6, [sp, #144]
   8eae8:	b4000120 	cbz	x0, 8eb0c <_dtoa_r+0x115c>
   8eaec:	12800000 	mov	w0, #0xffffffff            	// #-1
   8eaf0:	5280001b 	mov	w27, #0x0                   	// #0
   8eaf4:	2a0003e3 	mov	w3, w0
   8eaf8:	2a0003f6 	mov	w22, w0
   8eafc:	f9002a77 	str	x23, [x19, #80]
   8eb00:	b9008bf9 	str	w25, [sp, #136]
   8eb04:	b900abe0 	str	w0, [sp, #168]
   8eb08:	17fffcac 	b	8ddb8 <_dtoa_r+0x408>
   8eb0c:	f0000023 	adrp	x3, 95000 <pmu_event_descr+0x60>
   8eb10:	f0000020 	adrp	x0, 95000 <pmu_event_descr+0x60>
   8eb14:	91334063 	add	x3, x3, #0xcd0
   8eb18:	9133a000 	add	x0, x0, #0xce8
   8eb1c:	d2800002 	mov	x2, #0x0                   	// #0
   8eb20:	528035e1 	mov	w1, #0x1af                 	// #431
   8eb24:	940010e7 	bl	92ec0 <__assert_func>
	...

000000000008eb30 <__set_ctype>:
   8eb30:	f0000021 	adrp	x1, 95000 <pmu_event_descr+0x60>
   8eb34:	91358021 	add	x1, x1, #0xd60
   8eb38:	f9007c01 	str	x1, [x0, #248]
   8eb3c:	d65f03c0 	ret

000000000008eb40 <_close_r>:
   8eb40:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   8eb44:	910003fd 	mov	x29, sp
   8eb48:	a90153f3 	stp	x19, x20, [sp, #16]
   8eb4c:	b00013b4 	adrp	x20, 303000 <saved_categories.0+0xa0>
   8eb50:	aa0003f3 	mov	x19, x0
   8eb54:	b9012a9f 	str	wzr, [x20, #296]
   8eb58:	2a0103e0 	mov	w0, w1
   8eb5c:	97ffc8bd 	bl	80e50 <_close>
   8eb60:	3100041f 	cmn	w0, #0x1
   8eb64:	54000080 	b.eq	8eb74 <_close_r+0x34>  // b.none
   8eb68:	a94153f3 	ldp	x19, x20, [sp, #16]
   8eb6c:	a8c27bfd 	ldp	x29, x30, [sp], #32
   8eb70:	d65f03c0 	ret
   8eb74:	b9412a81 	ldr	w1, [x20, #296]
   8eb78:	34ffff81 	cbz	w1, 8eb68 <_close_r+0x28>
   8eb7c:	b9000261 	str	w1, [x19]
   8eb80:	a94153f3 	ldp	x19, x20, [sp, #16]
   8eb84:	a8c27bfd 	ldp	x29, x30, [sp], #32
   8eb88:	d65f03c0 	ret
   8eb8c:	00000000 	udf	#0

000000000008eb90 <_reclaim_reent>:
   8eb90:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   8eb94:	90000041 	adrp	x1, 96000 <JIS_state_table+0x70>
   8eb98:	910003fd 	mov	x29, sp
   8eb9c:	a90153f3 	stp	x19, x20, [sp, #16]
   8eba0:	aa0003f4 	mov	x20, x0
   8eba4:	f9410020 	ldr	x0, [x1, #512]
   8eba8:	eb14001f 	cmp	x0, x20
   8ebac:	54000440 	b.eq	8ec34 <_reclaim_reent+0xa4>  // b.none
   8ebb0:	f9403681 	ldr	x1, [x20, #104]
   8ebb4:	b4000221 	cbz	x1, 8ebf8 <_reclaim_reent+0x68>
   8ebb8:	f90013f5 	str	x21, [sp, #32]
   8ebbc:	d2800015 	mov	x21, #0x0                   	// #0
   8ebc0:	f8756833 	ldr	x19, [x1, x21]
   8ebc4:	b40000f3 	cbz	x19, 8ebe0 <_reclaim_reent+0x50>
   8ebc8:	aa1303e1 	mov	x1, x19
   8ebcc:	aa1403e0 	mov	x0, x20
   8ebd0:	f9400273 	ldr	x19, [x19]
   8ebd4:	940002fb 	bl	8f7c0 <_free_r>
   8ebd8:	b5ffff93 	cbnz	x19, 8ebc8 <_reclaim_reent+0x38>
   8ebdc:	f9403681 	ldr	x1, [x20, #104]
   8ebe0:	910022b5 	add	x21, x21, #0x8
   8ebe4:	f10802bf 	cmp	x21, #0x200
   8ebe8:	54fffec1 	b.ne	8ebc0 <_reclaim_reent+0x30>  // b.any
   8ebec:	aa1403e0 	mov	x0, x20
   8ebf0:	940002f4 	bl	8f7c0 <_free_r>
   8ebf4:	f94013f5 	ldr	x21, [sp, #32]
   8ebf8:	f9402a81 	ldr	x1, [x20, #80]
   8ebfc:	b4000061 	cbz	x1, 8ec08 <_reclaim_reent+0x78>
   8ec00:	aa1403e0 	mov	x0, x20
   8ec04:	940002ef 	bl	8f7c0 <_free_r>
   8ec08:	f9403e81 	ldr	x1, [x20, #120]
   8ec0c:	b4000061 	cbz	x1, 8ec18 <_reclaim_reent+0x88>
   8ec10:	aa1403e0 	mov	x0, x20
   8ec14:	940002eb 	bl	8f7c0 <_free_r>
   8ec18:	f9402681 	ldr	x1, [x20, #72]
   8ec1c:	b40000c1 	cbz	x1, 8ec34 <_reclaim_reent+0xa4>
   8ec20:	aa1403e0 	mov	x0, x20
   8ec24:	aa0103f0 	mov	x16, x1
   8ec28:	a94153f3 	ldp	x19, x20, [sp, #16]
   8ec2c:	a8c37bfd 	ldp	x29, x30, [sp], #48
   8ec30:	d61f0200 	br	x16
   8ec34:	a94153f3 	ldp	x19, x20, [sp, #16]
   8ec38:	a8c37bfd 	ldp	x29, x30, [sp], #48
   8ec3c:	d65f03c0 	ret

000000000008ec40 <__sflush_r>:
   8ec40:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   8ec44:	910003fd 	mov	x29, sp
   8ec48:	79c02022 	ldrsh	w2, [x1, #16]
   8ec4c:	a90153f3 	stp	x19, x20, [sp, #16]
   8ec50:	aa0103f3 	mov	x19, x1
   8ec54:	a9025bf5 	stp	x21, x22, [sp, #32]
   8ec58:	aa0003f6 	mov	x22, x0
   8ec5c:	371807c2 	tbnz	w2, #3, 8ed54 <__sflush_r+0x114>
   8ec60:	32150040 	orr	w0, w2, #0x800
   8ec64:	79002020 	strh	w0, [x1, #16]
   8ec68:	b9400821 	ldr	w1, [x1, #8]
   8ec6c:	7100003f 	cmp	w1, #0x0
   8ec70:	54000b6d 	b.le	8eddc <__sflush_r+0x19c>
   8ec74:	f9402664 	ldr	x4, [x19, #72]
   8ec78:	b4000644 	cbz	x4, 8ed40 <__sflush_r+0x100>
   8ec7c:	f9401a61 	ldr	x1, [x19, #48]
   8ec80:	b94002d4 	ldr	w20, [x22]
   8ec84:	b90002df 	str	wzr, [x22]
   8ec88:	37600b42 	tbnz	w2, #12, 8edf0 <__sflush_r+0x1b0>
   8ec8c:	d2800002 	mov	x2, #0x0                   	// #0
   8ec90:	aa1603e0 	mov	x0, x22
   8ec94:	52800023 	mov	w3, #0x1                   	// #1
   8ec98:	d63f0080 	blr	x4
   8ec9c:	aa0003e2 	mov	x2, x0
   8eca0:	b100041f 	cmn	x0, #0x1
   8eca4:	54000bc0 	b.eq	8ee1c <__sflush_r+0x1dc>  // b.none
   8eca8:	f9401a61 	ldr	x1, [x19, #48]
   8ecac:	f9402664 	ldr	x4, [x19, #72]
   8ecb0:	79c02260 	ldrsh	w0, [x19, #16]
   8ecb4:	361000e0 	tbz	w0, #2, 8ecd0 <__sflush_r+0x90>
   8ecb8:	f9402e60 	ldr	x0, [x19, #88]
   8ecbc:	b9800a63 	ldrsw	x3, [x19, #8]
   8ecc0:	cb030042 	sub	x2, x2, x3
   8ecc4:	b4000060 	cbz	x0, 8ecd0 <__sflush_r+0x90>
   8ecc8:	b9807260 	ldrsw	x0, [x19, #112]
   8eccc:	cb000042 	sub	x2, x2, x0
   8ecd0:	aa1603e0 	mov	x0, x22
   8ecd4:	52800003 	mov	w3, #0x0                   	// #0
   8ecd8:	d63f0080 	blr	x4
   8ecdc:	b100041f 	cmn	x0, #0x1
   8ece0:	540008c1 	b.ne	8edf8 <__sflush_r+0x1b8>  // b.any
   8ece4:	b94002c2 	ldr	w2, [x22]
   8ece8:	7100745f 	cmp	w2, #0x1d
   8ecec:	54000688 	b.hi	8edbc <__sflush_r+0x17c>  // b.pmore
   8ecf0:	92800023 	mov	x3, #0xfffffffffffffffe    	// #-2
   8ecf4:	79c02261 	ldrsh	w1, [x19, #16]
   8ecf8:	f2bbf7e3 	movk	x3, #0xdfbf, lsl #16
   8ecfc:	9ac22863 	asr	x3, x3, x2
   8ed00:	37000603 	tbnz	w3, #0, 8edc0 <__sflush_r+0x180>
   8ed04:	f9400e64 	ldr	x4, [x19, #24]
   8ed08:	12147823 	and	w3, w1, #0xfffff7ff
   8ed0c:	f9000264 	str	x4, [x19]
   8ed10:	b9000a7f 	str	wzr, [x19, #8]
   8ed14:	79002263 	strh	w3, [x19, #16]
   8ed18:	37600921 	tbnz	w1, #12, 8ee3c <__sflush_r+0x1fc>
   8ed1c:	f9402e61 	ldr	x1, [x19, #88]
   8ed20:	b90002d4 	str	w20, [x22]
   8ed24:	b40000e1 	cbz	x1, 8ed40 <__sflush_r+0x100>
   8ed28:	9101d260 	add	x0, x19, #0x74
   8ed2c:	eb00003f 	cmp	x1, x0
   8ed30:	54000060 	b.eq	8ed3c <__sflush_r+0xfc>  // b.none
   8ed34:	aa1603e0 	mov	x0, x22
   8ed38:	940002a2 	bl	8f7c0 <_free_r>
   8ed3c:	f9002e7f 	str	xzr, [x19, #88]
   8ed40:	52800000 	mov	w0, #0x0                   	// #0
   8ed44:	a94153f3 	ldp	x19, x20, [sp, #16]
   8ed48:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8ed4c:	a8c37bfd 	ldp	x29, x30, [sp], #48
   8ed50:	d65f03c0 	ret
   8ed54:	f9400c35 	ldr	x21, [x1, #24]
   8ed58:	b4ffff55 	cbz	x21, 8ed40 <__sflush_r+0x100>
   8ed5c:	f9400021 	ldr	x1, [x1]
   8ed60:	f9000275 	str	x21, [x19]
   8ed64:	52800000 	mov	w0, #0x0                   	// #0
   8ed68:	cb150021 	sub	x1, x1, x21
   8ed6c:	2a0103f4 	mov	w20, w1
   8ed70:	f240045f 	tst	x2, #0x3
   8ed74:	54000041 	b.ne	8ed7c <__sflush_r+0x13c>  // b.any
   8ed78:	b9402260 	ldr	w0, [x19, #32]
   8ed7c:	b9000e60 	str	w0, [x19, #12]
   8ed80:	7100003f 	cmp	w1, #0x0
   8ed84:	540000ac 	b.gt	8ed98 <__sflush_r+0x158>
   8ed88:	17ffffee 	b	8ed40 <__sflush_r+0x100>
   8ed8c:	8b20c2b5 	add	x21, x21, w0, sxtw
   8ed90:	7100029f 	cmp	w20, #0x0
   8ed94:	54fffd6d 	b.le	8ed40 <__sflush_r+0x100>
   8ed98:	f9401a61 	ldr	x1, [x19, #48]
   8ed9c:	2a1403e3 	mov	w3, w20
   8eda0:	f9402264 	ldr	x4, [x19, #64]
   8eda4:	aa1503e2 	mov	x2, x21
   8eda8:	aa1603e0 	mov	x0, x22
   8edac:	d63f0080 	blr	x4
   8edb0:	4b000294 	sub	w20, w20, w0
   8edb4:	7100001f 	cmp	w0, #0x0
   8edb8:	54fffeac 	b.gt	8ed8c <__sflush_r+0x14c>
   8edbc:	79c02261 	ldrsh	w1, [x19, #16]
   8edc0:	321a0021 	orr	w1, w1, #0x40
   8edc4:	79002261 	strh	w1, [x19, #16]
   8edc8:	a94153f3 	ldp	x19, x20, [sp, #16]
   8edcc:	12800000 	mov	w0, #0xffffffff            	// #-1
   8edd0:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8edd4:	a8c37bfd 	ldp	x29, x30, [sp], #48
   8edd8:	d65f03c0 	ret
   8eddc:	b9407261 	ldr	w1, [x19, #112]
   8ede0:	7100003f 	cmp	w1, #0x0
   8ede4:	54fff48c 	b.gt	8ec74 <__sflush_r+0x34>
   8ede8:	52800000 	mov	w0, #0x0                   	// #0
   8edec:	17ffffd6 	b	8ed44 <__sflush_r+0x104>
   8edf0:	f9404a62 	ldr	x2, [x19, #144]
   8edf4:	17ffffb0 	b	8ecb4 <__sflush_r+0x74>
   8edf8:	79c02261 	ldrsh	w1, [x19, #16]
   8edfc:	f9400e63 	ldr	x3, [x19, #24]
   8ee00:	12147822 	and	w2, w1, #0xfffff7ff
   8ee04:	f9000263 	str	x3, [x19]
   8ee08:	b9000a7f 	str	wzr, [x19, #8]
   8ee0c:	79002262 	strh	w2, [x19, #16]
   8ee10:	3667f861 	tbz	w1, #12, 8ed1c <__sflush_r+0xdc>
   8ee14:	f9004a60 	str	x0, [x19, #144]
   8ee18:	17ffffc1 	b	8ed1c <__sflush_r+0xdc>
   8ee1c:	b94002c0 	ldr	w0, [x22]
   8ee20:	34fff440 	cbz	w0, 8eca8 <__sflush_r+0x68>
   8ee24:	7100741f 	cmp	w0, #0x1d
   8ee28:	7a561804 	ccmp	w0, #0x16, #0x4, ne	// ne = any
   8ee2c:	54fffc81 	b.ne	8edbc <__sflush_r+0x17c>  // b.any
   8ee30:	52800000 	mov	w0, #0x0                   	// #0
   8ee34:	b90002d4 	str	w20, [x22]
   8ee38:	17ffffc3 	b	8ed44 <__sflush_r+0x104>
   8ee3c:	35fff702 	cbnz	w2, 8ed1c <__sflush_r+0xdc>
   8ee40:	f9004a60 	str	x0, [x19, #144]
   8ee44:	17ffffb6 	b	8ed1c <__sflush_r+0xdc>
	...

000000000008ee50 <_fflush_r>:
   8ee50:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   8ee54:	910003fd 	mov	x29, sp
   8ee58:	a90153f3 	stp	x19, x20, [sp, #16]
   8ee5c:	aa0103f3 	mov	x19, x1
   8ee60:	aa0003f4 	mov	x20, x0
   8ee64:	f90013f5 	str	x21, [sp, #32]
   8ee68:	b4000060 	cbz	x0, 8ee74 <_fflush_r+0x24>
   8ee6c:	f9402401 	ldr	x1, [x0, #72]
   8ee70:	b4000481 	cbz	x1, 8ef00 <_fflush_r+0xb0>
   8ee74:	79c02260 	ldrsh	w0, [x19, #16]
   8ee78:	52800015 	mov	w21, #0x0                   	// #0
   8ee7c:	34000180 	cbz	w0, 8eeac <_fflush_r+0x5c>
   8ee80:	b940b261 	ldr	w1, [x19, #176]
   8ee84:	37000041 	tbnz	w1, #0, 8ee8c <_fflush_r+0x3c>
   8ee88:	364801c0 	tbz	w0, #9, 8eec0 <_fflush_r+0x70>
   8ee8c:	aa1303e1 	mov	x1, x19
   8ee90:	aa1403e0 	mov	x0, x20
   8ee94:	97ffff6b 	bl	8ec40 <__sflush_r>
   8ee98:	2a0003f5 	mov	w21, w0
   8ee9c:	b940b261 	ldr	w1, [x19, #176]
   8eea0:	37000061 	tbnz	w1, #0, 8eeac <_fflush_r+0x5c>
   8eea4:	79402260 	ldrh	w0, [x19, #16]
   8eea8:	364801e0 	tbz	w0, #9, 8eee4 <_fflush_r+0x94>
   8eeac:	a94153f3 	ldp	x19, x20, [sp, #16]
   8eeb0:	2a1503e0 	mov	w0, w21
   8eeb4:	f94013f5 	ldr	x21, [sp, #32]
   8eeb8:	a8c37bfd 	ldp	x29, x30, [sp], #48
   8eebc:	d65f03c0 	ret
   8eec0:	f9405260 	ldr	x0, [x19, #160]
   8eec4:	97fff41b 	bl	8bf30 <__retarget_lock_acquire_recursive>
   8eec8:	aa1303e1 	mov	x1, x19
   8eecc:	aa1403e0 	mov	x0, x20
   8eed0:	97ffff5c 	bl	8ec40 <__sflush_r>
   8eed4:	2a0003f5 	mov	w21, w0
   8eed8:	b940b261 	ldr	w1, [x19, #176]
   8eedc:	3707fe81 	tbnz	w1, #0, 8eeac <_fflush_r+0x5c>
   8eee0:	17fffff1 	b	8eea4 <_fflush_r+0x54>
   8eee4:	f9405260 	ldr	x0, [x19, #160]
   8eee8:	97fff422 	bl	8bf70 <__retarget_lock_release_recursive>
   8eeec:	a94153f3 	ldp	x19, x20, [sp, #16]
   8eef0:	2a1503e0 	mov	w0, w21
   8eef4:	f94013f5 	ldr	x21, [sp, #32]
   8eef8:	a8c37bfd 	ldp	x29, x30, [sp], #48
   8eefc:	d65f03c0 	ret
   8ef00:	97ffcdc0 	bl	82600 <__sinit>
   8ef04:	17ffffdc 	b	8ee74 <_fflush_r+0x24>
	...

000000000008ef10 <fflush>:
   8ef10:	b40004e0 	cbz	x0, 8efac <fflush+0x9c>
   8ef14:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   8ef18:	910003fd 	mov	x29, sp
   8ef1c:	a90153f3 	stp	x19, x20, [sp, #16]
   8ef20:	aa0003f3 	mov	x19, x0
   8ef24:	90000040 	adrp	x0, 96000 <JIS_state_table+0x70>
   8ef28:	f90013f5 	str	x21, [sp, #32]
   8ef2c:	f9410015 	ldr	x21, [x0, #512]
   8ef30:	b4000075 	cbz	x21, 8ef3c <fflush+0x2c>
   8ef34:	f94026a0 	ldr	x0, [x21, #72]
   8ef38:	b4000280 	cbz	x0, 8ef88 <fflush+0x78>
   8ef3c:	79c02260 	ldrsh	w0, [x19, #16]
   8ef40:	52800014 	mov	w20, #0x0                   	// #0
   8ef44:	34000180 	cbz	w0, 8ef74 <fflush+0x64>
   8ef48:	b940b261 	ldr	w1, [x19, #176]
   8ef4c:	37000041 	tbnz	w1, #0, 8ef54 <fflush+0x44>
   8ef50:	36480220 	tbz	w0, #9, 8ef94 <fflush+0x84>
   8ef54:	aa1303e1 	mov	x1, x19
   8ef58:	aa1503e0 	mov	x0, x21
   8ef5c:	97ffff39 	bl	8ec40 <__sflush_r>
   8ef60:	2a0003f4 	mov	w20, w0
   8ef64:	b940b261 	ldr	w1, [x19, #176]
   8ef68:	37000061 	tbnz	w1, #0, 8ef74 <fflush+0x64>
   8ef6c:	79402260 	ldrh	w0, [x19, #16]
   8ef70:	36480180 	tbz	w0, #9, 8efa0 <fflush+0x90>
   8ef74:	f94013f5 	ldr	x21, [sp, #32]
   8ef78:	2a1403e0 	mov	w0, w20
   8ef7c:	a94153f3 	ldp	x19, x20, [sp, #16]
   8ef80:	a8c37bfd 	ldp	x29, x30, [sp], #48
   8ef84:	d65f03c0 	ret
   8ef88:	aa1503e0 	mov	x0, x21
   8ef8c:	97ffcd9d 	bl	82600 <__sinit>
   8ef90:	17ffffeb 	b	8ef3c <fflush+0x2c>
   8ef94:	f9405260 	ldr	x0, [x19, #160]
   8ef98:	97fff3e6 	bl	8bf30 <__retarget_lock_acquire_recursive>
   8ef9c:	17ffffee 	b	8ef54 <fflush+0x44>
   8efa0:	f9405260 	ldr	x0, [x19, #160]
   8efa4:	97fff3f3 	bl	8bf70 <__retarget_lock_release_recursive>
   8efa8:	17fffff3 	b	8ef74 <fflush+0x64>
   8efac:	90000042 	adrp	x2, 96000 <JIS_state_table+0x70>
   8efb0:	90000001 	adrp	x1, 8e000 <_dtoa_r+0x650>
   8efb4:	90000040 	adrp	x0, 96000 <JIS_state_table+0x70>
   8efb8:	910d8042 	add	x2, x2, #0x360
   8efbc:	91394021 	add	x1, x1, #0xe50
   8efc0:	91082000 	add	x0, x0, #0x208
   8efc4:	17ffd057 	b	83120 <_fwalk_sglue>

000000000008efc8 <strchr>:
   8efc8:	52808024 	mov	w4, #0x401                 	// #1025
   8efcc:	72a80204 	movk	w4, #0x4010, lsl #16
   8efd0:	4e010c20 	dup	v0.16b, w1
   8efd4:	927be802 	and	x2, x0, #0xffffffffffffffe0
   8efd8:	4e040c90 	dup	v16.4s, w4
   8efdc:	f2401003 	ands	x3, x0, #0x1f
   8efe0:	4eb08607 	add	v7.4s, v16.4s, v16.4s
   8efe4:	540002a0 	b.eq	8f038 <strchr+0x70>  // b.none
   8efe8:	4cdfa041 	ld1	{v1.16b, v2.16b}, [x2], #32
   8efec:	cb0303e3 	neg	x3, x3
   8eff0:	4e209823 	cmeq	v3.16b, v1.16b, #0
   8eff4:	6e208c25 	cmeq	v5.16b, v1.16b, v0.16b
   8eff8:	4e209844 	cmeq	v4.16b, v2.16b, #0
   8effc:	6e208c46 	cmeq	v6.16b, v2.16b, v0.16b
   8f000:	4e271c63 	and	v3.16b, v3.16b, v7.16b
   8f004:	4e271c84 	and	v4.16b, v4.16b, v7.16b
   8f008:	4e301ca5 	and	v5.16b, v5.16b, v16.16b
   8f00c:	4e301cc6 	and	v6.16b, v6.16b, v16.16b
   8f010:	4ea51c71 	orr	v17.16b, v3.16b, v5.16b
   8f014:	4ea61c92 	orr	v18.16b, v4.16b, v6.16b
   8f018:	d37ff863 	lsl	x3, x3, #1
   8f01c:	4e32be31 	addp	v17.16b, v17.16b, v18.16b
   8f020:	92800005 	mov	x5, #0xffffffffffffffff    	// #-1
   8f024:	4e32be31 	addp	v17.16b, v17.16b, v18.16b
   8f028:	9ac324a3 	lsr	x3, x5, x3
   8f02c:	4e083e25 	mov	x5, v17.d[0]
   8f030:	8a2300a3 	bic	x3, x5, x3
   8f034:	b50002a3 	cbnz	x3, 8f088 <strchr+0xc0>
   8f038:	4cdfa041 	ld1	{v1.16b, v2.16b}, [x2], #32
   8f03c:	4e209823 	cmeq	v3.16b, v1.16b, #0
   8f040:	6e208c25 	cmeq	v5.16b, v1.16b, v0.16b
   8f044:	4e209844 	cmeq	v4.16b, v2.16b, #0
   8f048:	6e208c46 	cmeq	v6.16b, v2.16b, v0.16b
   8f04c:	4ea51c71 	orr	v17.16b, v3.16b, v5.16b
   8f050:	4ea61c92 	orr	v18.16b, v4.16b, v6.16b
   8f054:	4eb21e31 	orr	v17.16b, v17.16b, v18.16b
   8f058:	4ef1be31 	addp	v17.2d, v17.2d, v17.2d
   8f05c:	4e083e23 	mov	x3, v17.d[0]
   8f060:	b4fffec3 	cbz	x3, 8f038 <strchr+0x70>
   8f064:	4e271c63 	and	v3.16b, v3.16b, v7.16b
   8f068:	4e271c84 	and	v4.16b, v4.16b, v7.16b
   8f06c:	4e301ca5 	and	v5.16b, v5.16b, v16.16b
   8f070:	4e301cc6 	and	v6.16b, v6.16b, v16.16b
   8f074:	4ea51c71 	orr	v17.16b, v3.16b, v5.16b
   8f078:	4ea61c92 	orr	v18.16b, v4.16b, v6.16b
   8f07c:	4e32be31 	addp	v17.16b, v17.16b, v18.16b
   8f080:	4e32be31 	addp	v17.16b, v17.16b, v18.16b
   8f084:	4e083e23 	mov	x3, v17.d[0]
   8f088:	dac00063 	rbit	x3, x3
   8f08c:	d1008042 	sub	x2, x2, #0x20
   8f090:	dac01063 	clz	x3, x3
   8f094:	f240007f 	tst	x3, #0x1
   8f098:	8b430440 	add	x0, x2, x3, lsr #1
   8f09c:	9a9f0000 	csel	x0, x0, xzr, eq	// eq = none
   8f0a0:	d65f03c0 	ret
	...

000000000008f0b0 <frexp>:
   8f0b0:	9e660002 	fmov	x2, d0
   8f0b4:	b900001f 	str	wzr, [x0]
   8f0b8:	12b00204 	mov	w4, #0x7fefffff            	// #2146435071
   8f0bc:	d360f841 	ubfx	x1, x2, #32, #31
   8f0c0:	d360fc43 	lsr	x3, x2, #32
   8f0c4:	6b04003f 	cmp	w1, w4
   8f0c8:	540002e8 	b.hi	8f124 <frexp+0x74>  // b.pmore
   8f0cc:	2a020022 	orr	w2, w1, w2
   8f0d0:	340002a2 	cbz	w2, 8f124 <frexp+0x74>
   8f0d4:	52800004 	mov	w4, #0x0                   	// #0
   8f0d8:	f26c287f 	tst	x3, #0x7ff00000
   8f0dc:	54000121 	b.ne	8f100 <frexp+0x50>  // b.any
   8f0e0:	d2e86a01 	mov	x1, #0x4350000000000000    	// #4850376798678024192
   8f0e4:	9e670021 	fmov	d1, x1
   8f0e8:	128006a4 	mov	w4, #0xffffffca            	// #-54
   8f0ec:	1e610800 	fmul	d0, d0, d1
   8f0f0:	9e660001 	fmov	x1, d0
   8f0f4:	d360fc21 	lsr	x1, x1, #32
   8f0f8:	2a0103e3 	mov	w3, w1
   8f0fc:	12007821 	and	w1, w1, #0x7fffffff
   8f100:	9e660002 	fmov	x2, d0
   8f104:	12015063 	and	w3, w3, #0x800fffff
   8f108:	13147c21 	asr	w1, w1, #20
   8f10c:	320b2063 	orr	w3, w3, #0x3fe00000
   8f110:	510ff821 	sub	w1, w1, #0x3fe
   8f114:	0b040021 	add	w1, w1, w4
   8f118:	b9000001 	str	w1, [x0]
   8f11c:	b3607c62 	bfi	x2, x3, #32, #32
   8f120:	9e670040 	fmov	d0, x2
   8f124:	d65f03c0 	ret
	...

000000000008f130 <_realloc_r>:
   8f130:	a9ba7bfd 	stp	x29, x30, [sp, #-96]!
   8f134:	910003fd 	mov	x29, sp
   8f138:	a9025bf5 	stp	x21, x22, [sp, #32]
   8f13c:	aa0203f5 	mov	x21, x2
   8f140:	b4001021 	cbz	x1, 8f344 <_realloc_r+0x214>
   8f144:	a90363f7 	stp	x23, x24, [sp, #48]
   8f148:	d1004038 	sub	x24, x1, #0x10
   8f14c:	aa0003f6 	mov	x22, x0
   8f150:	a90153f3 	stp	x19, x20, [sp, #16]
   8f154:	aa0103f3 	mov	x19, x1
   8f158:	91005eb4 	add	x20, x21, #0x17
   8f15c:	a9046bf9 	stp	x25, x26, [sp, #64]
   8f160:	97fff990 	bl	8d7a0 <__malloc_lock>
   8f164:	aa1803f9 	mov	x25, x24
   8f168:	f9400700 	ldr	x0, [x24, #8]
   8f16c:	927ef417 	and	x23, x0, #0xfffffffffffffffc
   8f170:	f100ba9f 	cmp	x20, #0x2e
   8f174:	54000908 	b.hi	8f294 <_realloc_r+0x164>  // b.pmore
   8f178:	52800001 	mov	w1, #0x0                   	// #0
   8f17c:	7100003f 	cmp	w1, #0x0
   8f180:	d2800414 	mov	x20, #0x20                  	// #32
   8f184:	fa550280 	ccmp	x20, x21, #0x0, eq	// eq = none
   8f188:	54000943 	b.cc	8f2b0 <_realloc_r+0x180>  // b.lo, b.ul, b.last
   8f18c:	eb1402ff 	cmp	x23, x20
   8f190:	54000a4a 	b.ge	8f2d8 <_realloc_r+0x1a8>  // b.tcont
   8f194:	f0000021 	adrp	x1, 96000 <JIS_state_table+0x70>
   8f198:	a90573fb 	stp	x27, x28, [sp, #80]
   8f19c:	910e403c 	add	x28, x1, #0x390
   8f1a0:	8b170302 	add	x2, x24, x23
   8f1a4:	f9400b83 	ldr	x3, [x28, #16]
   8f1a8:	f9400441 	ldr	x1, [x2, #8]
   8f1ac:	eb02007f 	cmp	x3, x2
   8f1b0:	54000ea0 	b.eq	8f384 <_realloc_r+0x254>  // b.none
   8f1b4:	927ff823 	and	x3, x1, #0xfffffffffffffffe
   8f1b8:	8b030043 	add	x3, x2, x3
   8f1bc:	f9400463 	ldr	x3, [x3, #8]
   8f1c0:	37000b63 	tbnz	w3, #0, 8f32c <_realloc_r+0x1fc>
   8f1c4:	927ef421 	and	x1, x1, #0xfffffffffffffffc
   8f1c8:	8b0102e3 	add	x3, x23, x1
   8f1cc:	eb03029f 	cmp	x20, x3
   8f1d0:	5400078d 	b.le	8f2c0 <_realloc_r+0x190>
   8f1d4:	37000180 	tbnz	w0, #0, 8f204 <_realloc_r+0xd4>
   8f1d8:	f85f027b 	ldur	x27, [x19, #-16]
   8f1dc:	cb1b031b 	sub	x27, x24, x27
   8f1e0:	f9400760 	ldr	x0, [x27, #8]
   8f1e4:	927ef400 	and	x0, x0, #0xfffffffffffffffc
   8f1e8:	8b000021 	add	x1, x1, x0
   8f1ec:	8b17003a 	add	x26, x1, x23
   8f1f0:	eb1a029f 	cmp	x20, x26
   8f1f4:	540018ed 	b.le	8f510 <_realloc_r+0x3e0>
   8f1f8:	8b0002fa 	add	x26, x23, x0
   8f1fc:	eb1a029f 	cmp	x20, x26
   8f200:	5400146d 	b.le	8f48c <_realloc_r+0x35c>
   8f204:	aa1503e1 	mov	x1, x21
   8f208:	aa1603e0 	mov	x0, x22
   8f20c:	97fff0dd 	bl	8b580 <_malloc_r>
   8f210:	aa0003f5 	mov	x21, x0
   8f214:	b4001d20 	cbz	x0, 8f5b8 <_realloc_r+0x488>
   8f218:	f9400701 	ldr	x1, [x24, #8]
   8f21c:	d1004002 	sub	x2, x0, #0x10
   8f220:	927ff821 	and	x1, x1, #0xfffffffffffffffe
   8f224:	8b010301 	add	x1, x24, x1
   8f228:	eb02003f 	cmp	x1, x2
   8f22c:	54001140 	b.eq	8f454 <_realloc_r+0x324>  // b.none
   8f230:	d10022e2 	sub	x2, x23, #0x8
   8f234:	f101205f 	cmp	x2, #0x48
   8f238:	54001668 	b.hi	8f504 <_realloc_r+0x3d4>  // b.pmore
   8f23c:	f1009c5f 	cmp	x2, #0x27
   8f240:	54001148 	b.hi	8f468 <_realloc_r+0x338>  // b.pmore
   8f244:	aa1303e1 	mov	x1, x19
   8f248:	f9400022 	ldr	x2, [x1]
   8f24c:	f9000002 	str	x2, [x0]
   8f250:	f9400422 	ldr	x2, [x1, #8]
   8f254:	f9000402 	str	x2, [x0, #8]
   8f258:	f9400821 	ldr	x1, [x1, #16]
   8f25c:	f9000801 	str	x1, [x0, #16]
   8f260:	aa1303e1 	mov	x1, x19
   8f264:	aa1603e0 	mov	x0, x22
   8f268:	94000156 	bl	8f7c0 <_free_r>
   8f26c:	aa1603e0 	mov	x0, x22
   8f270:	97fff950 	bl	8d7b0 <__malloc_unlock>
   8f274:	a94153f3 	ldp	x19, x20, [sp, #16]
   8f278:	aa1503e0 	mov	x0, x21
   8f27c:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8f280:	a94363f7 	ldp	x23, x24, [sp, #48]
   8f284:	a9446bf9 	ldp	x25, x26, [sp, #64]
   8f288:	a94573fb 	ldp	x27, x28, [sp, #80]
   8f28c:	a8c67bfd 	ldp	x29, x30, [sp], #96
   8f290:	d65f03c0 	ret
   8f294:	927cee94 	and	x20, x20, #0xfffffffffffffff0
   8f298:	b2407be1 	mov	x1, #0x7fffffff            	// #2147483647
   8f29c:	eb01029f 	cmp	x20, x1
   8f2a0:	1a9f97e1 	cset	w1, hi	// hi = pmore
   8f2a4:	7100003f 	cmp	w1, #0x0
   8f2a8:	fa550280 	ccmp	x20, x21, #0x0, eq	// eq = none
   8f2ac:	54fff702 	b.cs	8f18c <_realloc_r+0x5c>  // b.hs, b.nlast
   8f2b0:	52800180 	mov	w0, #0xc                   	// #12
   8f2b4:	d2800015 	mov	x21, #0x0                   	// #0
   8f2b8:	b90002c0 	str	w0, [x22]
   8f2bc:	14000015 	b	8f310 <_realloc_r+0x1e0>
   8f2c0:	a9410041 	ldp	x1, x0, [x2, #16]
   8f2c4:	aa0303f7 	mov	x23, x3
   8f2c8:	a94573fb 	ldp	x27, x28, [sp, #80]
   8f2cc:	f9000c20 	str	x0, [x1, #24]
   8f2d0:	f9000801 	str	x1, [x0, #16]
   8f2d4:	d503201f 	nop
   8f2d8:	f9400721 	ldr	x1, [x25, #8]
   8f2dc:	cb1402e0 	sub	x0, x23, x20
   8f2e0:	8b170322 	add	x2, x25, x23
   8f2e4:	92400021 	and	x1, x1, #0x1
   8f2e8:	f1007c1f 	cmp	x0, #0x1f
   8f2ec:	54000348 	b.hi	8f354 <_realloc_r+0x224>  // b.pmore
   8f2f0:	aa0102e1 	orr	x1, x23, x1
   8f2f4:	f9000721 	str	x1, [x25, #8]
   8f2f8:	f9400440 	ldr	x0, [x2, #8]
   8f2fc:	b2400000 	orr	x0, x0, #0x1
   8f300:	f9000440 	str	x0, [x2, #8]
   8f304:	aa1603e0 	mov	x0, x22
   8f308:	aa1303f5 	mov	x21, x19
   8f30c:	97fff929 	bl	8d7b0 <__malloc_unlock>
   8f310:	a94153f3 	ldp	x19, x20, [sp, #16]
   8f314:	aa1503e0 	mov	x0, x21
   8f318:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8f31c:	a94363f7 	ldp	x23, x24, [sp, #48]
   8f320:	a9446bf9 	ldp	x25, x26, [sp, #64]
   8f324:	a8c67bfd 	ldp	x29, x30, [sp], #96
   8f328:	d65f03c0 	ret
   8f32c:	3707f6c0 	tbnz	w0, #0, 8f204 <_realloc_r+0xd4>
   8f330:	f85f027b 	ldur	x27, [x19, #-16]
   8f334:	cb1b031b 	sub	x27, x24, x27
   8f338:	f9400760 	ldr	x0, [x27, #8]
   8f33c:	927ef400 	and	x0, x0, #0xfffffffffffffffc
   8f340:	17ffffae 	b	8f1f8 <_realloc_r+0xc8>
   8f344:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8f348:	aa0203e1 	mov	x1, x2
   8f34c:	a8c67bfd 	ldp	x29, x30, [sp], #96
   8f350:	17fff08c 	b	8b580 <_malloc_r>
   8f354:	8b140324 	add	x4, x25, x20
   8f358:	aa010281 	orr	x1, x20, x1
   8f35c:	f9000721 	str	x1, [x25, #8]
   8f360:	b2400003 	orr	x3, x0, #0x1
   8f364:	91004081 	add	x1, x4, #0x10
   8f368:	aa1603e0 	mov	x0, x22
   8f36c:	f9000483 	str	x3, [x4, #8]
   8f370:	f9400443 	ldr	x3, [x2, #8]
   8f374:	b2400063 	orr	x3, x3, #0x1
   8f378:	f9000443 	str	x3, [x2, #8]
   8f37c:	94000111 	bl	8f7c0 <_free_r>
   8f380:	17ffffe1 	b	8f304 <_realloc_r+0x1d4>
   8f384:	927ef421 	and	x1, x1, #0xfffffffffffffffc
   8f388:	91008283 	add	x3, x20, #0x20
   8f38c:	8b170022 	add	x2, x1, x23
   8f390:	eb03005f 	cmp	x2, x3
   8f394:	54000e4a 	b.ge	8f55c <_realloc_r+0x42c>  // b.tcont
   8f398:	3707f360 	tbnz	w0, #0, 8f204 <_realloc_r+0xd4>
   8f39c:	f85f027b 	ldur	x27, [x19, #-16]
   8f3a0:	cb1b031b 	sub	x27, x24, x27
   8f3a4:	f9400760 	ldr	x0, [x27, #8]
   8f3a8:	927ef400 	and	x0, x0, #0xfffffffffffffffc
   8f3ac:	8b000021 	add	x1, x1, x0
   8f3b0:	8b17003a 	add	x26, x1, x23
   8f3b4:	eb1a007f 	cmp	x3, x26
   8f3b8:	54fff20c 	b.gt	8f1f8 <_realloc_r+0xc8>
   8f3bc:	aa1b03f5 	mov	x21, x27
   8f3c0:	d10022e2 	sub	x2, x23, #0x8
   8f3c4:	f9400f60 	ldr	x0, [x27, #24]
   8f3c8:	f8410ea1 	ldr	x1, [x21, #16]!
   8f3cc:	f9000c20 	str	x0, [x1, #24]
   8f3d0:	f9000801 	str	x1, [x0, #16]
   8f3d4:	f101205f 	cmp	x2, #0x48
   8f3d8:	54001168 	b.hi	8f604 <_realloc_r+0x4d4>  // b.pmore
   8f3dc:	aa1503e0 	mov	x0, x21
   8f3e0:	f1009c5f 	cmp	x2, #0x27
   8f3e4:	54000129 	b.ls	8f408 <_realloc_r+0x2d8>  // b.plast
   8f3e8:	f9400260 	ldr	x0, [x19]
   8f3ec:	f9000b60 	str	x0, [x27, #16]
   8f3f0:	f9400660 	ldr	x0, [x19, #8]
   8f3f4:	f9000f60 	str	x0, [x27, #24]
   8f3f8:	f100dc5f 	cmp	x2, #0x37
   8f3fc:	540010c8 	b.hi	8f614 <_realloc_r+0x4e4>  // b.pmore
   8f400:	91004273 	add	x19, x19, #0x10
   8f404:	91008360 	add	x0, x27, #0x20
   8f408:	f9400261 	ldr	x1, [x19]
   8f40c:	f9000001 	str	x1, [x0]
   8f410:	f9400661 	ldr	x1, [x19, #8]
   8f414:	f9000401 	str	x1, [x0, #8]
   8f418:	f9400a61 	ldr	x1, [x19, #16]
   8f41c:	f9000801 	str	x1, [x0, #16]
   8f420:	8b140362 	add	x2, x27, x20
   8f424:	cb140341 	sub	x1, x26, x20
   8f428:	f9000b82 	str	x2, [x28, #16]
   8f42c:	b2400021 	orr	x1, x1, #0x1
   8f430:	aa1603e0 	mov	x0, x22
   8f434:	f9000441 	str	x1, [x2, #8]
   8f438:	f9400761 	ldr	x1, [x27, #8]
   8f43c:	92400021 	and	x1, x1, #0x1
   8f440:	aa140021 	orr	x1, x1, x20
   8f444:	f9000761 	str	x1, [x27, #8]
   8f448:	97fff8da 	bl	8d7b0 <__malloc_unlock>
   8f44c:	a94573fb 	ldp	x27, x28, [sp, #80]
   8f450:	17ffffb0 	b	8f310 <_realloc_r+0x1e0>
   8f454:	f9400420 	ldr	x0, [x1, #8]
   8f458:	a94573fb 	ldp	x27, x28, [sp, #80]
   8f45c:	927ef400 	and	x0, x0, #0xfffffffffffffffc
   8f460:	8b0002f7 	add	x23, x23, x0
   8f464:	17ffff9d 	b	8f2d8 <_realloc_r+0x1a8>
   8f468:	f9400260 	ldr	x0, [x19]
   8f46c:	f90002a0 	str	x0, [x21]
   8f470:	f9400660 	ldr	x0, [x19, #8]
   8f474:	f90006a0 	str	x0, [x21, #8]
   8f478:	f100dc5f 	cmp	x2, #0x37
   8f47c:	540005e8 	b.hi	8f538 <_realloc_r+0x408>  // b.pmore
   8f480:	91004261 	add	x1, x19, #0x10
   8f484:	910042a0 	add	x0, x21, #0x10
   8f488:	17ffff70 	b	8f248 <_realloc_r+0x118>
   8f48c:	aa1b03f5 	mov	x21, x27
   8f490:	d10022e2 	sub	x2, x23, #0x8
   8f494:	f8410ea1 	ldr	x1, [x21, #16]!
   8f498:	f9400f60 	ldr	x0, [x27, #24]
   8f49c:	f9000c20 	str	x0, [x1, #24]
   8f4a0:	f9000801 	str	x1, [x0, #16]
   8f4a4:	f101205f 	cmp	x2, #0x48
   8f4a8:	54000408 	b.hi	8f528 <_realloc_r+0x3f8>  // b.pmore
   8f4ac:	aa1503e0 	mov	x0, x21
   8f4b0:	f1009c5f 	cmp	x2, #0x27
   8f4b4:	54000129 	b.ls	8f4d8 <_realloc_r+0x3a8>  // b.plast
   8f4b8:	f9400260 	ldr	x0, [x19]
   8f4bc:	f9000b60 	str	x0, [x27, #16]
   8f4c0:	f9400660 	ldr	x0, [x19, #8]
   8f4c4:	f9000f60 	str	x0, [x27, #24]
   8f4c8:	f100dc5f 	cmp	x2, #0x37
   8f4cc:	54000648 	b.hi	8f594 <_realloc_r+0x464>  // b.pmore
   8f4d0:	91004273 	add	x19, x19, #0x10
   8f4d4:	91008360 	add	x0, x27, #0x20
   8f4d8:	f9400261 	ldr	x1, [x19]
   8f4dc:	f9000001 	str	x1, [x0]
   8f4e0:	f9400661 	ldr	x1, [x19, #8]
   8f4e4:	f9000401 	str	x1, [x0, #8]
   8f4e8:	f9400a61 	ldr	x1, [x19, #16]
   8f4ec:	f9000801 	str	x1, [x0, #16]
   8f4f0:	aa1b03f9 	mov	x25, x27
   8f4f4:	aa1503f3 	mov	x19, x21
   8f4f8:	a94573fb 	ldp	x27, x28, [sp, #80]
   8f4fc:	aa1a03f7 	mov	x23, x26
   8f500:	17ffff76 	b	8f2d8 <_realloc_r+0x1a8>
   8f504:	aa1303e1 	mov	x1, x19
   8f508:	97fff78e 	bl	8d340 <memmove>
   8f50c:	17ffff55 	b	8f260 <_realloc_r+0x130>
   8f510:	a9410041 	ldp	x1, x0, [x2, #16]
   8f514:	f9000c20 	str	x0, [x1, #24]
   8f518:	aa1b03f5 	mov	x21, x27
   8f51c:	d10022e2 	sub	x2, x23, #0x8
   8f520:	f9000801 	str	x1, [x0, #16]
   8f524:	17ffffdc 	b	8f494 <_realloc_r+0x364>
   8f528:	aa1303e1 	mov	x1, x19
   8f52c:	aa1503e0 	mov	x0, x21
   8f530:	97fff784 	bl	8d340 <memmove>
   8f534:	17ffffef 	b	8f4f0 <_realloc_r+0x3c0>
   8f538:	f9400a60 	ldr	x0, [x19, #16]
   8f53c:	f9000aa0 	str	x0, [x21, #16]
   8f540:	f9400e60 	ldr	x0, [x19, #24]
   8f544:	f9000ea0 	str	x0, [x21, #24]
   8f548:	f101205f 	cmp	x2, #0x48
   8f54c:	54000400 	b.eq	8f5cc <_realloc_r+0x49c>  // b.none
   8f550:	91008261 	add	x1, x19, #0x20
   8f554:	910082a0 	add	x0, x21, #0x20
   8f558:	17ffff3c 	b	8f248 <_realloc_r+0x118>
   8f55c:	8b140303 	add	x3, x24, x20
   8f560:	cb140041 	sub	x1, x2, x20
   8f564:	f9000b83 	str	x3, [x28, #16]
   8f568:	b2400021 	orr	x1, x1, #0x1
   8f56c:	aa1603e0 	mov	x0, x22
   8f570:	aa1303f5 	mov	x21, x19
   8f574:	f9000461 	str	x1, [x3, #8]
   8f578:	f9400701 	ldr	x1, [x24, #8]
   8f57c:	92400021 	and	x1, x1, #0x1
   8f580:	aa140021 	orr	x1, x1, x20
   8f584:	f9000701 	str	x1, [x24, #8]
   8f588:	97fff88a 	bl	8d7b0 <__malloc_unlock>
   8f58c:	a94573fb 	ldp	x27, x28, [sp, #80]
   8f590:	17ffff60 	b	8f310 <_realloc_r+0x1e0>
   8f594:	f9400a60 	ldr	x0, [x19, #16]
   8f598:	f9001360 	str	x0, [x27, #32]
   8f59c:	f9400e60 	ldr	x0, [x19, #24]
   8f5a0:	f9001760 	str	x0, [x27, #40]
   8f5a4:	f101205f 	cmp	x2, #0x48
   8f5a8:	54000200 	b.eq	8f5e8 <_realloc_r+0x4b8>  // b.none
   8f5ac:	91008273 	add	x19, x19, #0x20
   8f5b0:	9100c360 	add	x0, x27, #0x30
   8f5b4:	17ffffc9 	b	8f4d8 <_realloc_r+0x3a8>
   8f5b8:	aa1603e0 	mov	x0, x22
   8f5bc:	d2800015 	mov	x21, #0x0                   	// #0
   8f5c0:	97fff87c 	bl	8d7b0 <__malloc_unlock>
   8f5c4:	a94573fb 	ldp	x27, x28, [sp, #80]
   8f5c8:	17ffff52 	b	8f310 <_realloc_r+0x1e0>
   8f5cc:	f9401260 	ldr	x0, [x19, #32]
   8f5d0:	f90012a0 	str	x0, [x21, #32]
   8f5d4:	9100c261 	add	x1, x19, #0x30
   8f5d8:	9100c2a0 	add	x0, x21, #0x30
   8f5dc:	f9401662 	ldr	x2, [x19, #40]
   8f5e0:	f90016a2 	str	x2, [x21, #40]
   8f5e4:	17ffff19 	b	8f248 <_realloc_r+0x118>
   8f5e8:	f9401260 	ldr	x0, [x19, #32]
   8f5ec:	f9001b60 	str	x0, [x27, #48]
   8f5f0:	9100c273 	add	x19, x19, #0x30
   8f5f4:	91010360 	add	x0, x27, #0x40
   8f5f8:	f85f8261 	ldur	x1, [x19, #-8]
   8f5fc:	f9001f61 	str	x1, [x27, #56]
   8f600:	17ffffb6 	b	8f4d8 <_realloc_r+0x3a8>
   8f604:	aa1303e1 	mov	x1, x19
   8f608:	aa1503e0 	mov	x0, x21
   8f60c:	97fff74d 	bl	8d340 <memmove>
   8f610:	17ffff84 	b	8f420 <_realloc_r+0x2f0>
   8f614:	f9400a60 	ldr	x0, [x19, #16]
   8f618:	f9001360 	str	x0, [x27, #32]
   8f61c:	f9400e60 	ldr	x0, [x19, #24]
   8f620:	f9001760 	str	x0, [x27, #40]
   8f624:	f101205f 	cmp	x2, #0x48
   8f628:	54000080 	b.eq	8f638 <_realloc_r+0x508>  // b.none
   8f62c:	91008273 	add	x19, x19, #0x20
   8f630:	9100c360 	add	x0, x27, #0x30
   8f634:	17ffff75 	b	8f408 <_realloc_r+0x2d8>
   8f638:	f9401260 	ldr	x0, [x19, #32]
   8f63c:	f9001b60 	str	x0, [x27, #48]
   8f640:	9100c273 	add	x19, x19, #0x30
   8f644:	91010360 	add	x0, x27, #0x40
   8f648:	f85f8261 	ldur	x1, [x19, #-8]
   8f64c:	f9001f61 	str	x1, [x27, #56]
   8f650:	17ffff6e 	b	8f408 <_realloc_r+0x2d8>
	...

000000000008f660 <strlcpy>:
   8f660:	aa0103e3 	mov	x3, x1
   8f664:	b50000a2 	cbnz	x2, 8f678 <strlcpy+0x18>
   8f668:	14000008 	b	8f688 <strlcpy+0x28>
   8f66c:	38401464 	ldrb	w4, [x3], #1
   8f670:	38001404 	strb	w4, [x0], #1
   8f674:	340000e4 	cbz	w4, 8f690 <strlcpy+0x30>
   8f678:	f1000442 	subs	x2, x2, #0x1
   8f67c:	54ffff81 	b.ne	8f66c <strlcpy+0xc>  // b.any
   8f680:	3900001f 	strb	wzr, [x0]
   8f684:	d503201f 	nop
   8f688:	38401460 	ldrb	w0, [x3], #1
   8f68c:	35ffffe0 	cbnz	w0, 8f688 <strlcpy+0x28>
   8f690:	cb010060 	sub	x0, x3, x1
   8f694:	d1000400 	sub	x0, x0, #0x1
   8f698:	d65f03c0 	ret
   8f69c:	00000000 	udf	#0

000000000008f6a0 <_malloc_trim_r>:
   8f6a0:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
   8f6a4:	910003fd 	mov	x29, sp
   8f6a8:	a9025bf5 	stp	x21, x22, [sp, #32]
   8f6ac:	f0000036 	adrp	x22, 96000 <JIS_state_table+0x70>
   8f6b0:	910e42d6 	add	x22, x22, #0x390
   8f6b4:	aa0003f5 	mov	x21, x0
   8f6b8:	a90153f3 	stp	x19, x20, [sp, #16]
   8f6bc:	f9001bf7 	str	x23, [sp, #48]
   8f6c0:	aa0103f7 	mov	x23, x1
   8f6c4:	97fff837 	bl	8d7a0 <__malloc_lock>
   8f6c8:	f9400ac0 	ldr	x0, [x22, #16]
   8f6cc:	f9400414 	ldr	x20, [x0, #8]
   8f6d0:	927ef694 	and	x20, x20, #0xfffffffffffffffc
   8f6d4:	913f7e93 	add	x19, x20, #0xfdf
   8f6d8:	cb170273 	sub	x19, x19, x23
   8f6dc:	9274ce73 	and	x19, x19, #0xfffffffffffff000
   8f6e0:	d1400673 	sub	x19, x19, #0x1, lsl #12
   8f6e4:	f13ffe7f 	cmp	x19, #0xfff
   8f6e8:	5400010d 	b.le	8f708 <_malloc_trim_r+0x68>
   8f6ec:	d2800001 	mov	x1, #0x0                   	// #0
   8f6f0:	aa1503e0 	mov	x0, x21
   8f6f4:	940004ef 	bl	90ab0 <_sbrk_r>
   8f6f8:	f9400ac1 	ldr	x1, [x22, #16]
   8f6fc:	8b140021 	add	x1, x1, x20
   8f700:	eb01001f 	cmp	x0, x1
   8f704:	54000120 	b.eq	8f728 <_malloc_trim_r+0x88>  // b.none
   8f708:	aa1503e0 	mov	x0, x21
   8f70c:	97fff829 	bl	8d7b0 <__malloc_unlock>
   8f710:	a94153f3 	ldp	x19, x20, [sp, #16]
   8f714:	52800000 	mov	w0, #0x0                   	// #0
   8f718:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8f71c:	f9401bf7 	ldr	x23, [sp, #48]
   8f720:	a8c47bfd 	ldp	x29, x30, [sp], #64
   8f724:	d65f03c0 	ret
   8f728:	cb1303e1 	neg	x1, x19
   8f72c:	aa1503e0 	mov	x0, x21
   8f730:	940004e0 	bl	90ab0 <_sbrk_r>
   8f734:	b100041f 	cmn	x0, #0x1
   8f738:	54000220 	b.eq	8f77c <_malloc_trim_r+0xdc>  // b.none
   8f73c:	f0001382 	adrp	x2, 302000 <irq_handlers+0x1370>
   8f740:	cb130294 	sub	x20, x20, x19
   8f744:	f9400ac3 	ldr	x3, [x22, #16]
   8f748:	b2400294 	orr	x20, x20, #0x1
   8f74c:	b94ee041 	ldr	w1, [x2, #3808]
   8f750:	aa1503e0 	mov	x0, x21
   8f754:	4b130021 	sub	w1, w1, w19
   8f758:	f9000474 	str	x20, [x3, #8]
   8f75c:	b90ee041 	str	w1, [x2, #3808]
   8f760:	97fff814 	bl	8d7b0 <__malloc_unlock>
   8f764:	a94153f3 	ldp	x19, x20, [sp, #16]
   8f768:	52800020 	mov	w0, #0x1                   	// #1
   8f76c:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8f770:	f9401bf7 	ldr	x23, [sp, #48]
   8f774:	a8c47bfd 	ldp	x29, x30, [sp], #64
   8f778:	d65f03c0 	ret
   8f77c:	d2800001 	mov	x1, #0x0                   	// #0
   8f780:	aa1503e0 	mov	x0, x21
   8f784:	940004cb 	bl	90ab0 <_sbrk_r>
   8f788:	f9400ac2 	ldr	x2, [x22, #16]
   8f78c:	cb020001 	sub	x1, x0, x2
   8f790:	f1007c3f 	cmp	x1, #0x1f
   8f794:	54fffbad 	b.le	8f708 <_malloc_trim_r+0x68>
   8f798:	f0000024 	adrp	x4, 96000 <JIS_state_table+0x70>
   8f79c:	b2400021 	orr	x1, x1, #0x1
   8f7a0:	f9000441 	str	x1, [x2, #8]
   8f7a4:	f0001383 	adrp	x3, 302000 <irq_handlers+0x1370>
   8f7a8:	f941bc81 	ldr	x1, [x4, #888]
   8f7ac:	cb010000 	sub	x0, x0, x1
   8f7b0:	b90ee060 	str	w0, [x3, #3808]
   8f7b4:	17ffffd5 	b	8f708 <_malloc_trim_r+0x68>
	...

000000000008f7c0 <_free_r>:
   8f7c0:	b4000a21 	cbz	x1, 8f904 <_free_r+0x144>
   8f7c4:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   8f7c8:	910003fd 	mov	x29, sp
   8f7cc:	a90153f3 	stp	x19, x20, [sp, #16]
   8f7d0:	aa0103f3 	mov	x19, x1
   8f7d4:	aa0003f4 	mov	x20, x0
   8f7d8:	97fff7f2 	bl	8d7a0 <__malloc_lock>
   8f7dc:	f85f8265 	ldur	x5, [x19, #-8]
   8f7e0:	d1004263 	sub	x3, x19, #0x10
   8f7e4:	f0000020 	adrp	x0, 96000 <JIS_state_table+0x70>
   8f7e8:	910e4000 	add	x0, x0, #0x390
   8f7ec:	927ff8a2 	and	x2, x5, #0xfffffffffffffffe
   8f7f0:	8b020064 	add	x4, x3, x2
   8f7f4:	f9400806 	ldr	x6, [x0, #16]
   8f7f8:	f9400481 	ldr	x1, [x4, #8]
   8f7fc:	927ef421 	and	x1, x1, #0xfffffffffffffffc
   8f800:	eb0400df 	cmp	x6, x4
   8f804:	54000c00 	b.eq	8f984 <_free_r+0x1c4>  // b.none
   8f808:	f9000481 	str	x1, [x4, #8]
   8f80c:	8b010086 	add	x6, x4, x1
   8f810:	37000345 	tbnz	w5, #0, 8f878 <_free_r+0xb8>
   8f814:	f85f0267 	ldur	x7, [x19, #-16]
   8f818:	f0000025 	adrp	x5, 96000 <JIS_state_table+0x70>
   8f81c:	f94004c6 	ldr	x6, [x6, #8]
   8f820:	cb070063 	sub	x3, x3, x7
   8f824:	8b070042 	add	x2, x2, x7
   8f828:	910e80a5 	add	x5, x5, #0x3a0
   8f82c:	924000c6 	and	x6, x6, #0x1
   8f830:	f9400867 	ldr	x7, [x3, #16]
   8f834:	eb0500ff 	cmp	x7, x5
   8f838:	54000940 	b.eq	8f960 <_free_r+0x1a0>  // b.none
   8f83c:	f9400c68 	ldr	x8, [x3, #24]
   8f840:	f9000ce8 	str	x8, [x7, #24]
   8f844:	f9000907 	str	x7, [x8, #16]
   8f848:	b50001c6 	cbnz	x6, 8f880 <_free_r+0xc0>
   8f84c:	8b010042 	add	x2, x2, x1
   8f850:	f9400881 	ldr	x1, [x4, #16]
   8f854:	eb05003f 	cmp	x1, x5
   8f858:	54000ea0 	b.eq	8fa2c <_free_r+0x26c>  // b.none
   8f85c:	f9400c85 	ldr	x5, [x4, #24]
   8f860:	f9000c25 	str	x5, [x1, #24]
   8f864:	b2400044 	orr	x4, x2, #0x1
   8f868:	f90008a1 	str	x1, [x5, #16]
   8f86c:	f9000464 	str	x4, [x3, #8]
   8f870:	f8226862 	str	x2, [x3, x2]
   8f874:	14000006 	b	8f88c <_free_r+0xcc>
   8f878:	f94004c5 	ldr	x5, [x6, #8]
   8f87c:	360006a5 	tbz	w5, #0, 8f950 <_free_r+0x190>
   8f880:	b2400041 	orr	x1, x2, #0x1
   8f884:	f9000461 	str	x1, [x3, #8]
   8f888:	f9000082 	str	x2, [x4]
   8f88c:	f107fc5f 	cmp	x2, #0x1ff
   8f890:	540003c9 	b.ls	8f908 <_free_r+0x148>  // b.plast
   8f894:	d349fc41 	lsr	x1, x2, #9
   8f898:	f127fc5f 	cmp	x2, #0x9ff
   8f89c:	540009c8 	b.hi	8f9d4 <_free_r+0x214>  // b.pmore
   8f8a0:	d346fc41 	lsr	x1, x2, #6
   8f8a4:	1100e424 	add	w4, w1, #0x39
   8f8a8:	1100e025 	add	w5, w1, #0x38
   8f8ac:	531f7884 	lsl	w4, w4, #1
   8f8b0:	937d7c84 	sbfiz	x4, x4, #3, #32
   8f8b4:	8b040004 	add	x4, x0, x4
   8f8b8:	f85f0481 	ldr	x1, [x4], #-16
   8f8bc:	eb01009f 	cmp	x4, x1
   8f8c0:	540000a1 	b.ne	8f8d4 <_free_r+0x114>  // b.any
   8f8c4:	14000053 	b	8fa10 <_free_r+0x250>
   8f8c8:	f9400821 	ldr	x1, [x1, #16]
   8f8cc:	eb01009f 	cmp	x4, x1
   8f8d0:	540000a0 	b.eq	8f8e4 <_free_r+0x124>  // b.none
   8f8d4:	f9400420 	ldr	x0, [x1, #8]
   8f8d8:	927ef400 	and	x0, x0, #0xfffffffffffffffc
   8f8dc:	eb02001f 	cmp	x0, x2
   8f8e0:	54ffff48 	b.hi	8f8c8 <_free_r+0x108>  // b.pmore
   8f8e4:	f9400c24 	ldr	x4, [x1, #24]
   8f8e8:	a9011061 	stp	x1, x4, [x3, #16]
   8f8ec:	aa1403e0 	mov	x0, x20
   8f8f0:	f9000883 	str	x3, [x4, #16]
   8f8f4:	f9000c23 	str	x3, [x1, #24]
   8f8f8:	a94153f3 	ldp	x19, x20, [sp, #16]
   8f8fc:	a8c27bfd 	ldp	x29, x30, [sp], #32
   8f900:	17fff7ac 	b	8d7b0 <__malloc_unlock>
   8f904:	d65f03c0 	ret
   8f908:	d343fc44 	lsr	x4, x2, #3
   8f90c:	d2800022 	mov	x2, #0x1                   	// #1
   8f910:	11000481 	add	w1, w4, #0x1
   8f914:	f9400405 	ldr	x5, [x0, #8]
   8f918:	531f7821 	lsl	w1, w1, #1
   8f91c:	13027c84 	asr	w4, w4, #2
   8f920:	8b21cc01 	add	x1, x0, w1, sxtw #3
   8f924:	9ac42042 	lsl	x2, x2, x4
   8f928:	aa050042 	orr	x2, x2, x5
   8f92c:	f9000402 	str	x2, [x0, #8]
   8f930:	f85f0420 	ldr	x0, [x1], #-16
   8f934:	a9010460 	stp	x0, x1, [x3, #16]
   8f938:	f9000823 	str	x3, [x1, #16]
   8f93c:	f9000c03 	str	x3, [x0, #24]
   8f940:	aa1403e0 	mov	x0, x20
   8f944:	a94153f3 	ldp	x19, x20, [sp, #16]
   8f948:	a8c27bfd 	ldp	x29, x30, [sp], #32
   8f94c:	17fff799 	b	8d7b0 <__malloc_unlock>
   8f950:	f0000025 	adrp	x5, 96000 <JIS_state_table+0x70>
   8f954:	8b010042 	add	x2, x2, x1
   8f958:	910e80a5 	add	x5, x5, #0x3a0
   8f95c:	17ffffbd 	b	8f850 <_free_r+0x90>
   8f960:	b5000986 	cbnz	x6, 8fa90 <_free_r+0x2d0>
   8f964:	a9410085 	ldp	x5, x0, [x4, #16]
   8f968:	8b020021 	add	x1, x1, x2
   8f96c:	f9000ca0 	str	x0, [x5, #24]
   8f970:	b2400022 	orr	x2, x1, #0x1
   8f974:	f9000805 	str	x5, [x0, #16]
   8f978:	f9000462 	str	x2, [x3, #8]
   8f97c:	f8216861 	str	x1, [x3, x1]
   8f980:	17fffff0 	b	8f940 <_free_r+0x180>
   8f984:	8b010041 	add	x1, x2, x1
   8f988:	370000e5 	tbnz	w5, #0, 8f9a4 <_free_r+0x1e4>
   8f98c:	f85f0262 	ldur	x2, [x19, #-16]
   8f990:	cb020063 	sub	x3, x3, x2
   8f994:	8b020021 	add	x1, x1, x2
   8f998:	a9410864 	ldp	x4, x2, [x3, #16]
   8f99c:	f9000c82 	str	x2, [x4, #24]
   8f9a0:	f9000844 	str	x4, [x2, #16]
   8f9a4:	f0000022 	adrp	x2, 96000 <JIS_state_table+0x70>
   8f9a8:	b2400024 	orr	x4, x1, #0x1
   8f9ac:	f9000464 	str	x4, [x3, #8]
   8f9b0:	f941c042 	ldr	x2, [x2, #896]
   8f9b4:	f9000803 	str	x3, [x0, #16]
   8f9b8:	eb01005f 	cmp	x2, x1
   8f9bc:	54fffc28 	b.hi	8f940 <_free_r+0x180>  // b.pmore
   8f9c0:	f0001381 	adrp	x1, 302000 <irq_handlers+0x1370>
   8f9c4:	aa1403e0 	mov	x0, x20
   8f9c8:	f9478c21 	ldr	x1, [x1, #3864]
   8f9cc:	97ffff35 	bl	8f6a0 <_malloc_trim_r>
   8f9d0:	17ffffdc 	b	8f940 <_free_r+0x180>
   8f9d4:	f100503f 	cmp	x1, #0x14
   8f9d8:	54000129 	b.ls	8f9fc <_free_r+0x23c>  // b.plast
   8f9dc:	f101503f 	cmp	x1, #0x54
   8f9e0:	54000328 	b.hi	8fa44 <_free_r+0x284>  // b.pmore
   8f9e4:	d34cfc41 	lsr	x1, x2, #12
   8f9e8:	1101bc24 	add	w4, w1, #0x6f
   8f9ec:	1101b825 	add	w5, w1, #0x6e
   8f9f0:	531f7884 	lsl	w4, w4, #1
   8f9f4:	937d7c84 	sbfiz	x4, x4, #3, #32
   8f9f8:	17ffffaf 	b	8f8b4 <_free_r+0xf4>
   8f9fc:	11017024 	add	w4, w1, #0x5c
   8fa00:	11016c25 	add	w5, w1, #0x5b
   8fa04:	531f7884 	lsl	w4, w4, #1
   8fa08:	937d7c84 	sbfiz	x4, x4, #3, #32
   8fa0c:	17ffffaa 	b	8f8b4 <_free_r+0xf4>
   8fa10:	f9400406 	ldr	x6, [x0, #8]
   8fa14:	13027ca5 	asr	w5, w5, #2
   8fa18:	d2800022 	mov	x2, #0x1                   	// #1
   8fa1c:	9ac52042 	lsl	x2, x2, x5
   8fa20:	aa060042 	orr	x2, x2, x6
   8fa24:	f9000402 	str	x2, [x0, #8]
   8fa28:	17ffffb0 	b	8f8e8 <_free_r+0x128>
   8fa2c:	a9020c03 	stp	x3, x3, [x0, #32]
   8fa30:	b2400041 	orr	x1, x2, #0x1
   8fa34:	a9009461 	stp	x1, x5, [x3, #8]
   8fa38:	f9000c65 	str	x5, [x3, #24]
   8fa3c:	f8226862 	str	x2, [x3, x2]
   8fa40:	17ffffc0 	b	8f940 <_free_r+0x180>
   8fa44:	f105503f 	cmp	x1, #0x154
   8fa48:	540000e8 	b.hi	8fa64 <_free_r+0x2a4>  // b.pmore
   8fa4c:	d34ffc41 	lsr	x1, x2, #15
   8fa50:	1101e024 	add	w4, w1, #0x78
   8fa54:	1101dc25 	add	w5, w1, #0x77
   8fa58:	531f7884 	lsl	w4, w4, #1
   8fa5c:	937d7c84 	sbfiz	x4, x4, #3, #32
   8fa60:	17ffff95 	b	8f8b4 <_free_r+0xf4>
   8fa64:	f115503f 	cmp	x1, #0x554
   8fa68:	540000e8 	b.hi	8fa84 <_free_r+0x2c4>  // b.pmore
   8fa6c:	d352fc41 	lsr	x1, x2, #18
   8fa70:	1101f424 	add	w4, w1, #0x7d
   8fa74:	1101f025 	add	w5, w1, #0x7c
   8fa78:	531f7884 	lsl	w4, w4, #1
   8fa7c:	937d7c84 	sbfiz	x4, x4, #3, #32
   8fa80:	17ffff8d 	b	8f8b4 <_free_r+0xf4>
   8fa84:	d280fe04 	mov	x4, #0x7f0                 	// #2032
   8fa88:	52800fc5 	mov	w5, #0x7e                  	// #126
   8fa8c:	17ffff8a 	b	8f8b4 <_free_r+0xf4>
   8fa90:	b2400040 	orr	x0, x2, #0x1
   8fa94:	f9000460 	str	x0, [x3, #8]
   8fa98:	f9000082 	str	x2, [x4]
   8fa9c:	17ffffa9 	b	8f940 <_free_r+0x180>

000000000008faa0 <_strtol_l.part.0>:
   8faa0:	d0000027 	adrp	x7, 95000 <pmu_event_descr+0x60>
   8faa4:	aa0003ec 	mov	x12, x0
   8faa8:	aa0103e6 	mov	x6, x1
   8faac:	913584e7 	add	x7, x7, #0xd61
   8fab0:	aa0603e8 	mov	x8, x6
   8fab4:	384014c5 	ldrb	w5, [x6], #1
   8fab8:	386548e4 	ldrb	w4, [x7, w5, uxtw]
   8fabc:	371fffa4 	tbnz	w4, #3, 8fab0 <_strtol_l.part.0+0x10>
   8fac0:	7100b4bf 	cmp	w5, #0x2d
   8fac4:	54000740 	b.eq	8fbac <_strtol_l.part.0+0x10c>  // b.none
   8fac8:	92f0000b 	mov	x11, #0x7fffffffffffffff    	// #9223372036854775807
   8facc:	5280000d 	mov	w13, #0x0                   	// #0
   8fad0:	7100acbf 	cmp	w5, #0x2b
   8fad4:	54000660 	b.eq	8fba0 <_strtol_l.part.0+0x100>  // b.none
   8fad8:	721b787f 	tst	w3, #0xffffffef
   8fadc:	540000e1 	b.ne	8faf8 <_strtol_l.part.0+0x58>  // b.any
   8fae0:	7100c0bf 	cmp	w5, #0x30
   8fae4:	540007e0 	b.eq	8fbe0 <_strtol_l.part.0+0x140>  // b.none
   8fae8:	35000083 	cbnz	w3, 8faf8 <_strtol_l.part.0+0x58>
   8faec:	d280014a 	mov	x10, #0xa                   	// #10
   8faf0:	2a0a03e3 	mov	w3, w10
   8faf4:	14000002 	b	8fafc <_strtol_l.part.0+0x5c>
   8faf8:	93407c6a 	sxtw	x10, w3
   8fafc:	9aca0968 	udiv	x8, x11, x10
   8fb00:	52800007 	mov	w7, #0x0                   	// #0
   8fb04:	d2800000 	mov	x0, #0x0                   	// #0
   8fb08:	1b0aad09 	msub	w9, w8, w10, w11
   8fb0c:	d503201f 	nop
   8fb10:	5100c0a4 	sub	w4, w5, #0x30
   8fb14:	7100249f 	cmp	w4, #0x9
   8fb18:	540000a9 	b.ls	8fb2c <_strtol_l.part.0+0x8c>  // b.plast
   8fb1c:	510104a4 	sub	w4, w5, #0x41
   8fb20:	7100649f 	cmp	w4, #0x19
   8fb24:	54000208 	b.hi	8fb64 <_strtol_l.part.0+0xc4>  // b.pmore
   8fb28:	5100dca4 	sub	w4, w5, #0x37
   8fb2c:	6b04007f 	cmp	w3, w4
   8fb30:	5400028d 	b.le	8fb80 <_strtol_l.part.0+0xe0>
   8fb34:	710000ff 	cmp	w7, #0x0
   8fb38:	12800007 	mov	w7, #0xffffffff            	// #-1
   8fb3c:	fa40a100 	ccmp	x8, x0, #0x0, ge	// ge = tcont
   8fb40:	540000e3 	b.cc	8fb5c <_strtol_l.part.0+0xbc>  // b.lo, b.ul, b.last
   8fb44:	eb00011f 	cmp	x8, x0
   8fb48:	7a440120 	ccmp	w9, w4, #0x0, eq	// eq = none
   8fb4c:	5400008b 	b.lt	8fb5c <_strtol_l.part.0+0xbc>  // b.tstop
   8fb50:	93407c84 	sxtw	x4, w4
   8fb54:	52800027 	mov	w7, #0x1                   	// #1
   8fb58:	9b0a1000 	madd	x0, x0, x10, x4
   8fb5c:	384014c5 	ldrb	w5, [x6], #1
   8fb60:	17ffffec 	b	8fb10 <_strtol_l.part.0+0x70>
   8fb64:	510184a4 	sub	w4, w5, #0x61
   8fb68:	7100649f 	cmp	w4, #0x19
   8fb6c:	540000a8 	b.hi	8fb80 <_strtol_l.part.0+0xe0>  // b.pmore
   8fb70:	51015ca4 	sub	w4, w5, #0x57
   8fb74:	6b04007f 	cmp	w3, w4
   8fb78:	54fffdec 	b.gt	8fb34 <_strtol_l.part.0+0x94>
   8fb7c:	d503201f 	nop
   8fb80:	310004ff 	cmn	w7, #0x1
   8fb84:	540001e0 	b.eq	8fbc0 <_strtol_l.part.0+0x120>  // b.none
   8fb88:	710001bf 	cmp	w13, #0x0
   8fb8c:	da800400 	cneg	x0, x0, ne	// ne = any
   8fb90:	b4000062 	cbz	x2, 8fb9c <_strtol_l.part.0+0xfc>
   8fb94:	35000387 	cbnz	w7, 8fc04 <_strtol_l.part.0+0x164>
   8fb98:	f9000041 	str	x1, [x2]
   8fb9c:	d65f03c0 	ret
   8fba0:	394000c5 	ldrb	w5, [x6]
   8fba4:	91000906 	add	x6, x8, #0x2
   8fba8:	17ffffcc 	b	8fad8 <_strtol_l.part.0+0x38>
   8fbac:	394000c5 	ldrb	w5, [x6]
   8fbb0:	d2f0000b 	mov	x11, #0x8000000000000000    	// #-9223372036854775808
   8fbb4:	91000906 	add	x6, x8, #0x2
   8fbb8:	5280002d 	mov	w13, #0x1                   	// #1
   8fbbc:	17ffffc7 	b	8fad8 <_strtol_l.part.0+0x38>
   8fbc0:	52800440 	mov	w0, #0x22                  	// #34
   8fbc4:	b9000180 	str	w0, [x12]
   8fbc8:	aa0b03e0 	mov	x0, x11
   8fbcc:	b4fffe82 	cbz	x2, 8fb9c <_strtol_l.part.0+0xfc>
   8fbd0:	d10004c1 	sub	x1, x6, #0x1
   8fbd4:	aa0b03e0 	mov	x0, x11
   8fbd8:	f9000041 	str	x1, [x2]
   8fbdc:	17fffff0 	b	8fb9c <_strtol_l.part.0+0xfc>
   8fbe0:	394000c0 	ldrb	w0, [x6]
   8fbe4:	121a7800 	and	w0, w0, #0xffffffdf
   8fbe8:	12001c00 	and	w0, w0, #0xff
   8fbec:	7101601f 	cmp	w0, #0x58
   8fbf0:	540000e0 	b.eq	8fc0c <_strtol_l.part.0+0x16c>  // b.none
   8fbf4:	35fff823 	cbnz	w3, 8faf8 <_strtol_l.part.0+0x58>
   8fbf8:	d280010a 	mov	x10, #0x8                   	// #8
   8fbfc:	2a0a03e3 	mov	w3, w10
   8fc00:	17ffffbf 	b	8fafc <_strtol_l.part.0+0x5c>
   8fc04:	aa0003eb 	mov	x11, x0
   8fc08:	17fffff2 	b	8fbd0 <_strtol_l.part.0+0x130>
   8fc0c:	394004c5 	ldrb	w5, [x6, #1]
   8fc10:	d280020a 	mov	x10, #0x10                  	// #16
   8fc14:	910008c6 	add	x6, x6, #0x2
   8fc18:	2a0a03e3 	mov	w3, w10
   8fc1c:	17ffffb8 	b	8fafc <_strtol_l.part.0+0x5c>

000000000008fc20 <_strtol_r>:
   8fc20:	7100907f 	cmp	w3, #0x24
   8fc24:	7a419864 	ccmp	w3, #0x1, #0x4, ls	// ls = plast
   8fc28:	54000040 	b.eq	8fc30 <_strtol_r+0x10>  // b.none
   8fc2c:	17ffff9d 	b	8faa0 <_strtol_l.part.0>
   8fc30:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   8fc34:	910003fd 	mov	x29, sp
   8fc38:	97ffc8f2 	bl	82000 <__errno>
   8fc3c:	528002c1 	mov	w1, #0x16                  	// #22
   8fc40:	b9000001 	str	w1, [x0]
   8fc44:	d2800000 	mov	x0, #0x0                   	// #0
   8fc48:	a8c17bfd 	ldp	x29, x30, [sp], #16
   8fc4c:	d65f03c0 	ret

000000000008fc50 <strtol_l>:
   8fc50:	f0000024 	adrp	x4, 96000 <JIS_state_table+0x70>
   8fc54:	7100905f 	cmp	w2, #0x24
   8fc58:	7a419844 	ccmp	w2, #0x1, #0x4, ls	// ls = plast
   8fc5c:	f9410084 	ldr	x4, [x4, #512]
   8fc60:	540000c0 	b.eq	8fc78 <strtol_l+0x28>  // b.none
   8fc64:	2a0203e3 	mov	w3, w2
   8fc68:	aa0103e2 	mov	x2, x1
   8fc6c:	aa0003e1 	mov	x1, x0
   8fc70:	aa0403e0 	mov	x0, x4
   8fc74:	17ffff8b 	b	8faa0 <_strtol_l.part.0>
   8fc78:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   8fc7c:	910003fd 	mov	x29, sp
   8fc80:	97ffc8e0 	bl	82000 <__errno>
   8fc84:	528002c1 	mov	w1, #0x16                  	// #22
   8fc88:	b9000001 	str	w1, [x0]
   8fc8c:	d2800000 	mov	x0, #0x0                   	// #0
   8fc90:	a8c17bfd 	ldp	x29, x30, [sp], #16
   8fc94:	d65f03c0 	ret
	...

000000000008fca0 <strtol>:
   8fca0:	f0000024 	adrp	x4, 96000 <JIS_state_table+0x70>
   8fca4:	7100905f 	cmp	w2, #0x24
   8fca8:	7a419844 	ccmp	w2, #0x1, #0x4, ls	// ls = plast
   8fcac:	f9410084 	ldr	x4, [x4, #512]
   8fcb0:	540000c0 	b.eq	8fcc8 <strtol+0x28>  // b.none
   8fcb4:	2a0203e3 	mov	w3, w2
   8fcb8:	aa0103e2 	mov	x2, x1
   8fcbc:	aa0003e1 	mov	x1, x0
   8fcc0:	aa0403e0 	mov	x0, x4
   8fcc4:	17ffff77 	b	8faa0 <_strtol_l.part.0>
   8fcc8:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   8fccc:	910003fd 	mov	x29, sp
   8fcd0:	97ffc8cc 	bl	82000 <__errno>
   8fcd4:	528002c1 	mov	w1, #0x16                  	// #22
   8fcd8:	b9000001 	str	w1, [x0]
   8fcdc:	d2800000 	mov	x0, #0x0                   	// #0
   8fce0:	a8c17bfd 	ldp	x29, x30, [sp], #16
   8fce4:	d65f03c0 	ret
	...

000000000008fcf0 <strncasecmp>:
   8fcf0:	aa0003e9 	mov	x9, x0
   8fcf4:	b4000342 	cbz	x2, 8fd5c <strncasecmp+0x6c>
   8fcf8:	d0000027 	adrp	x7, 95000 <pmu_event_descr+0x60>
   8fcfc:	d2800004 	mov	x4, #0x0                   	// #0
   8fd00:	913584e7 	add	x7, x7, #0xd61
   8fd04:	14000006 	b	8fd1c <strncasecmp+0x2c>
   8fd08:	6b000063 	subs	w3, w3, w0
   8fd0c:	540002c1 	b.ne	8fd64 <strncasecmp+0x74>  // b.any
   8fd10:	34000240 	cbz	w0, 8fd58 <strncasecmp+0x68>
   8fd14:	eb04005f 	cmp	x2, x4
   8fd18:	54000220 	b.eq	8fd5c <strncasecmp+0x6c>  // b.none
   8fd1c:	38646923 	ldrb	w3, [x9, x4]
   8fd20:	38646820 	ldrb	w0, [x1, x4]
   8fd24:	91000484 	add	x4, x4, #0x1
   8fd28:	11008068 	add	w8, w3, #0x20
   8fd2c:	386348e6 	ldrb	w6, [x7, w3, uxtw]
   8fd30:	386048e5 	ldrb	w5, [x7, w0, uxtw]
   8fd34:	120004c6 	and	w6, w6, #0x3
   8fd38:	710004df 	cmp	w6, #0x1
   8fd3c:	120004a5 	and	w5, w5, #0x3
   8fd40:	1a830103 	csel	w3, w8, w3, eq	// eq = none
   8fd44:	710004bf 	cmp	w5, #0x1
   8fd48:	54fffe01 	b.ne	8fd08 <strncasecmp+0x18>  // b.any
   8fd4c:	11008000 	add	w0, w0, #0x20
   8fd50:	6b000060 	subs	w0, w3, w0
   8fd54:	54fffe00 	b.eq	8fd14 <strncasecmp+0x24>  // b.none
   8fd58:	d65f03c0 	ret
   8fd5c:	52800000 	mov	w0, #0x0                   	// #0
   8fd60:	d65f03c0 	ret
   8fd64:	2a0303e0 	mov	w0, w3
   8fd68:	d65f03c0 	ret
   8fd6c:	00000000 	udf	#0

000000000008fd70 <_findenv_r>:
   8fd70:	a9bb7bfd 	stp	x29, x30, [sp, #-80]!
   8fd74:	910003fd 	mov	x29, sp
   8fd78:	a90363f7 	stp	x23, x24, [sp, #48]
   8fd7c:	f0000038 	adrp	x24, 96000 <JIS_state_table+0x70>
   8fd80:	aa0003f7 	mov	x23, x0
   8fd84:	a90153f3 	stp	x19, x20, [sp, #16]
   8fd88:	a9025bf5 	stp	x21, x22, [sp, #32]
   8fd8c:	aa0103f5 	mov	x21, x1
   8fd90:	aa0203f6 	mov	x22, x2
   8fd94:	9400116b 	bl	94340 <__env_lock>
   8fd98:	f9473314 	ldr	x20, [x24, #3680]
   8fd9c:	b40003f4 	cbz	x20, 8fe18 <_findenv_r+0xa8>
   8fda0:	394002a3 	ldrb	w3, [x21]
   8fda4:	aa1503f3 	mov	x19, x21
   8fda8:	7100f47f 	cmp	w3, #0x3d
   8fdac:	7a401864 	ccmp	w3, #0x0, #0x4, ne	// ne = any
   8fdb0:	540000c0 	b.eq	8fdc8 <_findenv_r+0x58>  // b.none
   8fdb4:	d503201f 	nop
   8fdb8:	38401e63 	ldrb	w3, [x19, #1]!
   8fdbc:	7100f47f 	cmp	w3, #0x3d
   8fdc0:	7a401864 	ccmp	w3, #0x0, #0x4, ne	// ne = any
   8fdc4:	54ffffa1 	b.ne	8fdb8 <_findenv_r+0x48>  // b.any
   8fdc8:	7100f47f 	cmp	w3, #0x3d
   8fdcc:	54000260 	b.eq	8fe18 <_findenv_r+0xa8>  // b.none
   8fdd0:	f9400280 	ldr	x0, [x20]
   8fdd4:	cb150273 	sub	x19, x19, x21
   8fdd8:	b4000200 	cbz	x0, 8fe18 <_findenv_r+0xa8>
   8fddc:	93407e73 	sxtw	x19, w19
   8fde0:	f90023f9 	str	x25, [sp, #64]
   8fde4:	d503201f 	nop
   8fde8:	aa1303e2 	mov	x2, x19
   8fdec:	aa1503e1 	mov	x1, x21
   8fdf0:	9400015b 	bl	9035c <strncmp>
   8fdf4:	350000c0 	cbnz	w0, 8fe0c <_findenv_r+0x9c>
   8fdf8:	f9400280 	ldr	x0, [x20]
   8fdfc:	8b130019 	add	x25, x0, x19
   8fe00:	38736800 	ldrb	w0, [x0, x19]
   8fe04:	7100f41f 	cmp	w0, #0x3d
   8fe08:	54000180 	b.eq	8fe38 <_findenv_r+0xc8>  // b.none
   8fe0c:	f8408e80 	ldr	x0, [x20, #8]!
   8fe10:	b5fffec0 	cbnz	x0, 8fde8 <_findenv_r+0x78>
   8fe14:	f94023f9 	ldr	x25, [sp, #64]
   8fe18:	aa1703e0 	mov	x0, x23
   8fe1c:	9400114d 	bl	94350 <__env_unlock>
   8fe20:	a94153f3 	ldp	x19, x20, [sp, #16]
   8fe24:	d2800000 	mov	x0, #0x0                   	// #0
   8fe28:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8fe2c:	a94363f7 	ldp	x23, x24, [sp, #48]
   8fe30:	a8c57bfd 	ldp	x29, x30, [sp], #80
   8fe34:	d65f03c0 	ret
   8fe38:	f9473301 	ldr	x1, [x24, #3680]
   8fe3c:	aa1703e0 	mov	x0, x23
   8fe40:	cb010281 	sub	x1, x20, x1
   8fe44:	9343fc21 	asr	x1, x1, #3
   8fe48:	b90002c1 	str	w1, [x22]
   8fe4c:	94001141 	bl	94350 <__env_unlock>
   8fe50:	a94153f3 	ldp	x19, x20, [sp, #16]
   8fe54:	91000720 	add	x0, x25, #0x1
   8fe58:	a9425bf5 	ldp	x21, x22, [sp, #32]
   8fe5c:	a94363f7 	ldp	x23, x24, [sp, #48]
   8fe60:	f94023f9 	ldr	x25, [sp, #64]
   8fe64:	a8c57bfd 	ldp	x29, x30, [sp], #80
   8fe68:	d65f03c0 	ret
   8fe6c:	00000000 	udf	#0

000000000008fe70 <_getenv_r>:
   8fe70:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   8fe74:	910003fd 	mov	x29, sp
   8fe78:	910073e2 	add	x2, sp, #0x1c
   8fe7c:	97ffffbd 	bl	8fd70 <_findenv_r>
   8fe80:	a8c27bfd 	ldp	x29, x30, [sp], #32
   8fe84:	d65f03c0 	ret
	...

000000000008fe90 <strncpy>:
   8fe90:	aa010003 	orr	x3, x0, x1
   8fe94:	aa0003e4 	mov	x4, x0
   8fe98:	f240087f 	tst	x3, #0x7
   8fe9c:	fa470840 	ccmp	x2, #0x7, #0x0, eq	// eq = none
   8fea0:	54000109 	b.ls	8fec0 <strncpy+0x30>  // b.plast
   8fea4:	14000011 	b	8fee8 <strncpy+0x58>
   8fea8:	38401425 	ldrb	w5, [x1], #1
   8feac:	d1000446 	sub	x6, x2, #0x1
   8feb0:	38001465 	strb	w5, [x3], #1
   8feb4:	340000c5 	cbz	w5, 8fecc <strncpy+0x3c>
   8feb8:	aa0303e4 	mov	x4, x3
   8febc:	aa0603e2 	mov	x2, x6
   8fec0:	aa0403e3 	mov	x3, x4
   8fec4:	b5ffff22 	cbnz	x2, 8fea8 <strncpy+0x18>
   8fec8:	d65f03c0 	ret
   8fecc:	8b020084 	add	x4, x4, x2
   8fed0:	b4ffffc6 	cbz	x6, 8fec8 <strncpy+0x38>
   8fed4:	d503201f 	nop
   8fed8:	3800147f 	strb	wzr, [x3], #1
   8fedc:	eb04007f 	cmp	x3, x4
   8fee0:	54ffffc1 	b.ne	8fed8 <strncpy+0x48>  // b.any
   8fee4:	d65f03c0 	ret
   8fee8:	b207dbe6 	mov	x6, #0xfefefefefefefefe    	// #-72340172838076674
   8feec:	f29fdfe6 	movk	x6, #0xfeff
   8fef0:	14000006 	b	8ff08 <strncpy+0x78>
   8fef4:	d1002042 	sub	x2, x2, #0x8
   8fef8:	f8008485 	str	x5, [x4], #8
   8fefc:	91002021 	add	x1, x1, #0x8
   8ff00:	f1001c5f 	cmp	x2, #0x7
   8ff04:	54fffde9 	b.ls	8fec0 <strncpy+0x30>  // b.plast
   8ff08:	f9400025 	ldr	x5, [x1]
   8ff0c:	8b0600a3 	add	x3, x5, x6
   8ff10:	8a250063 	bic	x3, x3, x5
   8ff14:	f201c07f 	tst	x3, #0x8080808080808080
   8ff18:	54fffee0 	b.eq	8fef4 <strncpy+0x64>  // b.none
   8ff1c:	17ffffe9 	b	8fec0 <strncpy+0x30>

000000000008ff20 <_fstat_r>:
   8ff20:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   8ff24:	910003fd 	mov	x29, sp
   8ff28:	a90153f3 	stp	x19, x20, [sp, #16]
   8ff2c:	900013b4 	adrp	x20, 303000 <saved_categories.0+0xa0>
   8ff30:	aa0003f3 	mov	x19, x0
   8ff34:	b9012a9f 	str	wzr, [x20, #296]
   8ff38:	2a0103e0 	mov	w0, w1
   8ff3c:	aa0203e1 	mov	x1, x2
   8ff40:	97ffc3c8 	bl	80e60 <_fstat>
   8ff44:	3100041f 	cmn	w0, #0x1
   8ff48:	54000080 	b.eq	8ff58 <_fstat_r+0x38>  // b.none
   8ff4c:	a94153f3 	ldp	x19, x20, [sp, #16]
   8ff50:	a8c27bfd 	ldp	x29, x30, [sp], #32
   8ff54:	d65f03c0 	ret
   8ff58:	b9412a81 	ldr	w1, [x20, #296]
   8ff5c:	34ffff81 	cbz	w1, 8ff4c <_fstat_r+0x2c>
   8ff60:	b9000261 	str	w1, [x19]
   8ff64:	a94153f3 	ldp	x19, x20, [sp, #16]
   8ff68:	a8c27bfd 	ldp	x29, x30, [sp], #32
   8ff6c:	d65f03c0 	ret

000000000008ff70 <_isatty_r>:
   8ff70:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   8ff74:	910003fd 	mov	x29, sp
   8ff78:	a90153f3 	stp	x19, x20, [sp, #16]
   8ff7c:	900013b4 	adrp	x20, 303000 <saved_categories.0+0xa0>
   8ff80:	aa0003f3 	mov	x19, x0
   8ff84:	b9012a9f 	str	wzr, [x20, #296]
   8ff88:	2a0103e0 	mov	w0, w1
   8ff8c:	97ffc3b9 	bl	80e70 <_isatty>
   8ff90:	3100041f 	cmn	w0, #0x1
   8ff94:	54000080 	b.eq	8ffa4 <_isatty_r+0x34>  // b.none
   8ff98:	a94153f3 	ldp	x19, x20, [sp, #16]
   8ff9c:	a8c27bfd 	ldp	x29, x30, [sp], #32
   8ffa0:	d65f03c0 	ret
   8ffa4:	b9412a81 	ldr	w1, [x20, #296]
   8ffa8:	34ffff81 	cbz	w1, 8ff98 <_isatty_r+0x28>
   8ffac:	b9000261 	str	w1, [x19]
   8ffb0:	a94153f3 	ldp	x19, x20, [sp, #16]
   8ffb4:	a8c27bfd 	ldp	x29, x30, [sp], #32
   8ffb8:	d65f03c0 	ret
   8ffbc:	00000000 	udf	#0

000000000008ffc0 <_lseek_r>:
   8ffc0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   8ffc4:	910003fd 	mov	x29, sp
   8ffc8:	a90153f3 	stp	x19, x20, [sp, #16]
   8ffcc:	900013b4 	adrp	x20, 303000 <saved_categories.0+0xa0>
   8ffd0:	aa0003f3 	mov	x19, x0
   8ffd4:	b9012a9f 	str	wzr, [x20, #296]
   8ffd8:	2a0103e0 	mov	w0, w1
   8ffdc:	aa0203e1 	mov	x1, x2
   8ffe0:	2a0303e2 	mov	w2, w3
   8ffe4:	97ffc390 	bl	80e24 <_lseek>
   8ffe8:	b100041f 	cmn	x0, #0x1
   8ffec:	54000080 	b.eq	8fffc <_lseek_r+0x3c>  // b.none
   8fff0:	a94153f3 	ldp	x19, x20, [sp, #16]
   8fff4:	a8c27bfd 	ldp	x29, x30, [sp], #32
   8fff8:	d65f03c0 	ret
   8fffc:	b9412a81 	ldr	w1, [x20, #296]
   90000:	34ffff81 	cbz	w1, 8fff0 <_lseek_r+0x30>
   90004:	b9000261 	str	w1, [x19]
   90008:	a94153f3 	ldp	x19, x20, [sp, #16]
   9000c:	a8c27bfd 	ldp	x29, x30, [sp], #32
   90010:	d65f03c0 	ret
	...

0000000000090020 <_read_r>:
   90020:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   90024:	910003fd 	mov	x29, sp
   90028:	a90153f3 	stp	x19, x20, [sp, #16]
   9002c:	f0001394 	adrp	x20, 303000 <saved_categories.0+0xa0>
   90030:	aa0003f3 	mov	x19, x0
   90034:	2a0103e0 	mov	w0, w1
   90038:	aa0203e1 	mov	x1, x2
   9003c:	b9012a9f 	str	wzr, [x20, #296]
   90040:	aa0303e2 	mov	x2, x3
   90044:	97ffc347 	bl	80d60 <_read>
   90048:	93407c01 	sxtw	x1, w0
   9004c:	3100041f 	cmn	w0, #0x1
   90050:	540000a0 	b.eq	90064 <_read_r+0x44>  // b.none
   90054:	a94153f3 	ldp	x19, x20, [sp, #16]
   90058:	aa0103e0 	mov	x0, x1
   9005c:	a8c27bfd 	ldp	x29, x30, [sp], #32
   90060:	d65f03c0 	ret
   90064:	b9412a80 	ldr	w0, [x20, #296]
   90068:	34ffff60 	cbz	w0, 90054 <_read_r+0x34>
   9006c:	b9000260 	str	w0, [x19]
   90070:	aa0103e0 	mov	x0, x1
   90074:	a94153f3 	ldp	x19, x20, [sp, #16]
   90078:	a8c27bfd 	ldp	x29, x30, [sp], #32
   9007c:	d65f03c0 	ret

0000000000090080 <strcmp>:
   90080:	ca010007 	eor	x7, x0, x1
   90084:	b200c3ea 	mov	x10, #0x101010101010101     	// #72340172838076673
   90088:	f24008ff 	tst	x7, #0x7
   9008c:	540003e1 	b.ne	90108 <strcmp+0x88>  // b.any
   90090:	f2400807 	ands	x7, x0, #0x7
   90094:	54000241 	b.ne	900dc <strcmp+0x5c>  // b.any
   90098:	f8408402 	ldr	x2, [x0], #8
   9009c:	f8408423 	ldr	x3, [x1], #8
   900a0:	cb0a0047 	sub	x7, x2, x10
   900a4:	b200d848 	orr	x8, x2, #0x7f7f7f7f7f7f7f7f
   900a8:	ca030045 	eor	x5, x2, x3
   900ac:	8a2800e4 	bic	x4, x7, x8
   900b0:	aa0400a6 	orr	x6, x5, x4
   900b4:	b4ffff26 	cbz	x6, 90098 <strcmp+0x18>
   900b8:	dac00cc6 	rev	x6, x6
   900bc:	dac00c42 	rev	x2, x2
   900c0:	dac010cb 	clz	x11, x6
   900c4:	dac00c63 	rev	x3, x3
   900c8:	9acb2042 	lsl	x2, x2, x11
   900cc:	9acb2063 	lsl	x3, x3, x11
   900d0:	d378fc42 	lsr	x2, x2, #56
   900d4:	cb43e040 	sub	x0, x2, x3, lsr #56
   900d8:	d65f03c0 	ret
   900dc:	927df000 	and	x0, x0, #0xfffffffffffffff8
   900e0:	927df021 	and	x1, x1, #0xfffffffffffffff8
   900e4:	d37df0e7 	lsl	x7, x7, #3
   900e8:	f8408402 	ldr	x2, [x0], #8
   900ec:	cb0703e7 	neg	x7, x7
   900f0:	f8408423 	ldr	x3, [x1], #8
   900f4:	92800008 	mov	x8, #0xffffffffffffffff    	// #-1
   900f8:	9ac72508 	lsr	x8, x8, x7
   900fc:	aa080042 	orr	x2, x2, x8
   90100:	aa080063 	orr	x3, x3, x8
   90104:	17ffffe7 	b	900a0 <strcmp+0x20>
   90108:	f240081f 	tst	x0, #0x7
   9010c:	54000100 	b.eq	9012c <strcmp+0xac>  // b.none
   90110:	38401402 	ldrb	w2, [x0], #1
   90114:	38401423 	ldrb	w3, [x1], #1
   90118:	7100045f 	cmp	w2, #0x1
   9011c:	7a432040 	ccmp	w2, w3, #0x0, cs	// cs = hs, nlast
   90120:	540001e1 	b.ne	9015c <strcmp+0xdc>  // b.any
   90124:	f240081f 	tst	x0, #0x7
   90128:	54ffff41 	b.ne	90110 <strcmp+0x90>  // b.any
   9012c:	927d2027 	and	x7, x1, #0xff8
   90130:	d27d20e7 	eor	x7, x7, #0xff8
   90134:	b4fffee7 	cbz	x7, 90110 <strcmp+0x90>
   90138:	f8408402 	ldr	x2, [x0], #8
   9013c:	f8408423 	ldr	x3, [x1], #8
   90140:	cb0a0047 	sub	x7, x2, x10
   90144:	b200d848 	orr	x8, x2, #0x7f7f7f7f7f7f7f7f
   90148:	ca030045 	eor	x5, x2, x3
   9014c:	8a2800e4 	bic	x4, x7, x8
   90150:	aa0400a6 	orr	x6, x5, x4
   90154:	b4fffec6 	cbz	x6, 9012c <strcmp+0xac>
   90158:	17ffffd8 	b	900b8 <strcmp+0x38>
   9015c:	cb030040 	sub	x0, x2, x3
   90160:	d65f03c0 	ret
	...

0000000000090180 <strcpy>:
   90180:	92402c29 	and	x9, x1, #0xfff
   90184:	b200c3ec 	mov	x12, #0x101010101010101     	// #72340172838076673
   90188:	92400c31 	and	x17, x1, #0xf
   9018c:	f13fc13f 	cmp	x9, #0xff0
   90190:	cb1103e8 	neg	x8, x17
   90194:	540008cc 	b.gt	902ac <strcpy+0x12c>
   90198:	a9401424 	ldp	x4, x5, [x1]
   9019c:	cb0c0088 	sub	x8, x4, x12
   901a0:	b200d889 	orr	x9, x4, #0x7f7f7f7f7f7f7f7f
   901a4:	ea290106 	bics	x6, x8, x9
   901a8:	540001c1 	b.ne	901e0 <strcpy+0x60>  // b.any
   901ac:	cb0c00aa 	sub	x10, x5, x12
   901b0:	b200d8ab 	orr	x11, x5, #0x7f7f7f7f7f7f7f7f
   901b4:	ea2b0147 	bics	x7, x10, x11
   901b8:	54000440 	b.eq	90240 <strcpy+0xc0>  // b.none
   901bc:	dac00ce7 	rev	x7, x7
   901c0:	dac010ef 	clz	x15, x7
   901c4:	d2800709 	mov	x9, #0x38                  	// #56
   901c8:	8b4f0c03 	add	x3, x0, x15, lsr #3
   901cc:	cb0f012f 	sub	x15, x9, x15
   901d0:	9acf20a5 	lsl	x5, x5, x15
   901d4:	f8001065 	stur	x5, [x3, #1]
   901d8:	f9000004 	str	x4, [x0]
   901dc:	d65f03c0 	ret
   901e0:	dac00cc6 	rev	x6, x6
   901e4:	dac010cf 	clz	x15, x6
   901e8:	8b4f0c03 	add	x3, x0, x15, lsr #3
   901ec:	f10061e9 	subs	x9, x15, #0x18
   901f0:	540000ab 	b.lt	90204 <strcpy+0x84>  // b.tstop
   901f4:	9ac92485 	lsr	x5, x4, x9
   901f8:	b81fd065 	stur	w5, [x3, #-3]
   901fc:	b9000004 	str	w4, [x0]
   90200:	d65f03c0 	ret
   90204:	b400004f 	cbz	x15, 9020c <strcpy+0x8c>
   90208:	79000004 	strh	w4, [x0]
   9020c:	3900007f 	strb	wzr, [x3]
   90210:	d65f03c0 	ret
   90214:	d503201f 	nop
   90218:	d503201f 	nop
   9021c:	d503201f 	nop
   90220:	d503201f 	nop
   90224:	d503201f 	nop
   90228:	d503201f 	nop
   9022c:	d503201f 	nop
   90230:	d503201f 	nop
   90234:	d503201f 	nop
   90238:	d503201f 	nop
   9023c:	d503201f 	nop
   90240:	d1004231 	sub	x17, x17, #0x10
   90244:	a9001404 	stp	x4, x5, [x0]
   90248:	cb110022 	sub	x2, x1, x17
   9024c:	cb110003 	sub	x3, x0, x17
   90250:	14000002 	b	90258 <strcpy+0xd8>
   90254:	a8811464 	stp	x4, x5, [x3], #16
   90258:	a8c11444 	ldp	x4, x5, [x2], #16
   9025c:	cb0c0088 	sub	x8, x4, x12
   90260:	b200d889 	orr	x9, x4, #0x7f7f7f7f7f7f7f7f
   90264:	cb0c00aa 	sub	x10, x5, x12
   90268:	b200d8ab 	orr	x11, x5, #0x7f7f7f7f7f7f7f7f
   9026c:	8a290106 	bic	x6, x8, x9
   90270:	ea2b0147 	bics	x7, x10, x11
   90274:	fa4008c0 	ccmp	x6, #0x0, #0x0, eq	// eq = none
   90278:	54fffee0 	b.eq	90254 <strcpy+0xd4>  // b.none
   9027c:	f10000df 	cmp	x6, #0x0
   90280:	9a8710c6 	csel	x6, x6, x7, ne	// ne = any
   90284:	dac00cc6 	rev	x6, x6
   90288:	dac010cf 	clz	x15, x6
   9028c:	910121e8 	add	x8, x15, #0x48
   90290:	910021ef 	add	x15, x15, #0x8
   90294:	9a8811ef 	csel	x15, x15, x8, ne	// ne = any
   90298:	8b4f0c42 	add	x2, x2, x15, lsr #3
   9029c:	8b4f0c63 	add	x3, x3, x15, lsr #3
   902a0:	a97e1444 	ldp	x4, x5, [x2, #-32]
   902a4:	a93f1464 	stp	x4, x5, [x3, #-16]
   902a8:	d65f03c0 	ret
   902ac:	927cec22 	and	x2, x1, #0xfffffffffffffff0
   902b0:	a9401444 	ldp	x4, x5, [x2]
   902b4:	d37df108 	lsl	x8, x8, #3
   902b8:	f2400a3f 	tst	x17, #0x7
   902bc:	da9f03e9 	csetm	x9, ne	// ne = any
   902c0:	9ac82529 	lsr	x9, x9, x8
   902c4:	aa090084 	orr	x4, x4, x9
   902c8:	aa0900ae 	orr	x14, x5, x9
   902cc:	f100223f 	cmp	x17, #0x8
   902d0:	da9fb084 	csinv	x4, x4, xzr, lt	// lt = tstop
   902d4:	9a8eb0a5 	csel	x5, x5, x14, lt	// lt = tstop
   902d8:	cb0c0088 	sub	x8, x4, x12
   902dc:	b200d889 	orr	x9, x4, #0x7f7f7f7f7f7f7f7f
   902e0:	cb0c00aa 	sub	x10, x5, x12
   902e4:	b200d8ab 	orr	x11, x5, #0x7f7f7f7f7f7f7f7f
   902e8:	8a290106 	bic	x6, x8, x9
   902ec:	ea2b0147 	bics	x7, x10, x11
   902f0:	fa4008c0 	ccmp	x6, #0x0, #0x0, eq	// eq = none
   902f4:	54fff520 	b.eq	90198 <strcpy+0x18>  // b.none
   902f8:	d37df228 	lsl	x8, x17, #3
   902fc:	cb110fe9 	neg	x9, x17, lsl #3
   90300:	9ac8248d 	lsr	x13, x4, x8
   90304:	9ac920ab 	lsl	x11, x5, x9
   90308:	9ac824a5 	lsr	x5, x5, x8
   9030c:	aa0d016b 	orr	x11, x11, x13
   90310:	f100223f 	cmp	x17, #0x8
   90314:	9a85b164 	csel	x4, x11, x5, lt	// lt = tstop
   90318:	cb0c0088 	sub	x8, x4, x12
   9031c:	b200d889 	orr	x9, x4, #0x7f7f7f7f7f7f7f7f
   90320:	cb0c00aa 	sub	x10, x5, x12
   90324:	b200d8ab 	orr	x11, x5, #0x7f7f7f7f7f7f7f7f
   90328:	8a290106 	bic	x6, x8, x9
   9032c:	b5fff5a6 	cbnz	x6, 901e0 <strcpy+0x60>
   90330:	8a2b0147 	bic	x7, x10, x11
   90334:	17ffffa2 	b	901bc <strcpy+0x3c>
	...
   90340:	d503201f 	nop
   90344:	d503201f 	nop
   90348:	d503201f 	nop
   9034c:	d503201f 	nop
   90350:	d503201f 	nop
   90354:	d503201f 	nop
   90358:	d503201f 	nop

000000000009035c <strncmp>:
   9035c:	b4000d82 	cbz	x2, 9050c <strncmp+0x1b0>
   90360:	ca010008 	eor	x8, x0, x1
   90364:	b200c3eb 	mov	x11, #0x101010101010101     	// #72340172838076673
   90368:	f240091f 	tst	x8, #0x7
   9036c:	9240080e 	and	x14, x0, #0x7
   90370:	54000681 	b.ne	90440 <strncmp+0xe4>  // b.any
   90374:	b500040e 	cbnz	x14, 903f4 <strncmp+0x98>
   90378:	d100044d 	sub	x13, x2, #0x1
   9037c:	d343fdad 	lsr	x13, x13, #3
   90380:	f8408403 	ldr	x3, [x0], #8
   90384:	f8408424 	ldr	x4, [x1], #8
   90388:	f10005ad 	subs	x13, x13, #0x1
   9038c:	cb0b0068 	sub	x8, x3, x11
   90390:	b200d869 	orr	x9, x3, #0x7f7f7f7f7f7f7f7f
   90394:	ca040066 	eor	x6, x3, x4
   90398:	da9f50cf 	csinv	x15, x6, xzr, pl	// pl = nfrst
   9039c:	ea290105 	bics	x5, x8, x9
   903a0:	fa4009e0 	ccmp	x15, #0x0, #0x0, eq	// eq = none
   903a4:	54fffee0 	b.eq	90380 <strncmp+0x24>  // b.none
   903a8:	b6f8012d 	tbz	x13, #63, 903cc <strncmp+0x70>
   903ac:	f2400842 	ands	x2, x2, #0x7
   903b0:	540000e0 	b.eq	903cc <strncmp+0x70>  // b.none
   903b4:	d37df042 	lsl	x2, x2, #3
   903b8:	9280000e 	mov	x14, #0xffffffffffffffff    	// #-1
   903bc:	9ac221ce 	lsl	x14, x14, x2
   903c0:	8a2e0063 	bic	x3, x3, x14
   903c4:	8a2e0084 	bic	x4, x4, x14
   903c8:	aa0e00a5 	orr	x5, x5, x14
   903cc:	aa0500c7 	orr	x7, x6, x5
   903d0:	dac00ce7 	rev	x7, x7
   903d4:	dac00c63 	rev	x3, x3
   903d8:	dac010ec 	clz	x12, x7
   903dc:	dac00c84 	rev	x4, x4
   903e0:	9acc2063 	lsl	x3, x3, x12
   903e4:	9acc2084 	lsl	x4, x4, x12
   903e8:	d378fc63 	lsr	x3, x3, #56
   903ec:	cb44e060 	sub	x0, x3, x4, lsr #56
   903f0:	d65f03c0 	ret
   903f4:	927df000 	and	x0, x0, #0xfffffffffffffff8
   903f8:	927df021 	and	x1, x1, #0xfffffffffffffff8
   903fc:	f8408403 	ldr	x3, [x0], #8
   90400:	cb0e0fea 	neg	x10, x14, lsl #3
   90404:	f8408424 	ldr	x4, [x1], #8
   90408:	92800009 	mov	x9, #0xffffffffffffffff    	// #-1
   9040c:	d100044d 	sub	x13, x2, #0x1
   90410:	9aca2529 	lsr	x9, x9, x10
   90414:	924009aa 	and	x10, x13, #0x7
   90418:	d343fdad 	lsr	x13, x13, #3
   9041c:	8b0e0042 	add	x2, x2, x14
   90420:	8b0e014a 	add	x10, x10, x14
   90424:	aa090063 	orr	x3, x3, x9
   90428:	aa090084 	orr	x4, x4, x9
   9042c:	8b4a0dad 	add	x13, x13, x10, lsr #3
   90430:	17ffffd6 	b	90388 <strncmp+0x2c>
   90434:	d503201f 	nop
   90438:	d503201f 	nop
   9043c:	d503201f 	nop
   90440:	f100405f 	cmp	x2, #0x10
   90444:	54000122 	b.cs	90468 <strncmp+0x10c>  // b.hs, b.nlast
   90448:	38401403 	ldrb	w3, [x0], #1
   9044c:	38401424 	ldrb	w4, [x1], #1
   90450:	f1000442 	subs	x2, x2, #0x1
   90454:	7a418860 	ccmp	w3, #0x1, #0x0, hi	// hi = pmore
   90458:	7a442060 	ccmp	w3, w4, #0x0, cs	// cs = hs, nlast
   9045c:	54ffff60 	b.eq	90448 <strncmp+0xec>  // b.none
   90460:	cb040060 	sub	x0, x3, x4
   90464:	d65f03c0 	ret
   90468:	d343fc4d 	lsr	x13, x2, #3
   9046c:	b400018e 	cbz	x14, 9049c <strncmp+0x140>
   90470:	cb0e03ee 	neg	x14, x14
   90474:	924009ce 	and	x14, x14, #0x7
   90478:	cb0e0042 	sub	x2, x2, x14
   9047c:	d343fc4d 	lsr	x13, x2, #3
   90480:	38401403 	ldrb	w3, [x0], #1
   90484:	38401424 	ldrb	w4, [x1], #1
   90488:	7100047f 	cmp	w3, #0x1
   9048c:	7a442060 	ccmp	w3, w4, #0x0, cs	// cs = hs, nlast
   90490:	54fffe81 	b.ne	90460 <strncmp+0x104>  // b.any
   90494:	f10005ce 	subs	x14, x14, #0x1
   90498:	54ffff48 	b.hi	90480 <strncmp+0x124>  // b.pmore
   9049c:	d280010e 	mov	x14, #0x8                   	// #8
   904a0:	f10005ad 	subs	x13, x13, #0x1
   904a4:	540001c3 	b.cc	904dc <strncmp+0x180>  // b.lo, b.ul, b.last
   904a8:	927d2029 	and	x9, x1, #0xff8
   904ac:	d27d2129 	eor	x9, x9, #0xff8
   904b0:	b4fffe89 	cbz	x9, 90480 <strncmp+0x124>
   904b4:	f8408403 	ldr	x3, [x0], #8
   904b8:	f8408424 	ldr	x4, [x1], #8
   904bc:	cb0b0068 	sub	x8, x3, x11
   904c0:	b200d869 	orr	x9, x3, #0x7f7f7f7f7f7f7f7f
   904c4:	ca040066 	eor	x6, x3, x4
   904c8:	ea290105 	bics	x5, x8, x9
   904cc:	fa4008c0 	ccmp	x6, #0x0, #0x0, eq	// eq = none
   904d0:	54fff7e1 	b.ne	903cc <strncmp+0x70>  // b.any
   904d4:	f10005ad 	subs	x13, x13, #0x1
   904d8:	54fffe85 	b.pl	904a8 <strncmp+0x14c>  // b.nfrst
   904dc:	92400842 	and	x2, x2, #0x7
   904e0:	b4fff762 	cbz	x2, 903cc <strncmp+0x70>
   904e4:	d1002000 	sub	x0, x0, #0x8
   904e8:	d1002021 	sub	x1, x1, #0x8
   904ec:	f8626803 	ldr	x3, [x0, x2]
   904f0:	f8626824 	ldr	x4, [x1, x2]
   904f4:	cb0b0068 	sub	x8, x3, x11
   904f8:	b200d869 	orr	x9, x3, #0x7f7f7f7f7f7f7f7f
   904fc:	ca040066 	eor	x6, x3, x4
   90500:	ea290105 	bics	x5, x8, x9
   90504:	fa4008c0 	ccmp	x6, #0x0, #0x0, eq	// eq = none
   90508:	54fff621 	b.ne	903cc <strncmp+0x70>  // b.any
   9050c:	d2800000 	mov	x0, #0x0                   	// #0
   90510:	d65f03c0 	ret
	...

0000000000090520 <__fputwc>:
   90520:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
   90524:	910003fd 	mov	x29, sp
   90528:	a90153f3 	stp	x19, x20, [sp, #16]
   9052c:	2a0103f4 	mov	w20, w1
   90530:	aa0203f3 	mov	x19, x2
   90534:	f90013f5 	str	x21, [sp, #32]
   90538:	aa0003f5 	mov	x21, x0
   9053c:	97fff1b5 	bl	8cc10 <__locale_mb_cur_max>
   90540:	7100041f 	cmp	w0, #0x1
   90544:	54000081 	b.ne	90554 <__fputwc+0x34>  // b.any
   90548:	51000680 	sub	w0, w20, #0x1
   9054c:	7103f81f 	cmp	w0, #0xfe
   90550:	540004a9 	b.ls	905e4 <__fputwc+0xc4>  // b.plast
   90554:	9102a263 	add	x3, x19, #0xa8
   90558:	2a1403e2 	mov	w2, w20
   9055c:	9100e3e1 	add	x1, sp, #0x38
   90560:	aa1503e0 	mov	x0, x21
   90564:	97ffee13 	bl	8bdb0 <_wcrtomb_r>
   90568:	b100041f 	cmn	x0, #0x1
   9056c:	54000400 	b.eq	905ec <__fputwc+0xcc>  // b.none
   90570:	b40001c0 	cbz	x0, 905a8 <__fputwc+0x88>
   90574:	b9400e63 	ldr	w3, [x19, #12]
   90578:	3940e3e1 	ldrb	w1, [sp, #56]
   9057c:	51000463 	sub	w3, w3, #0x1
   90580:	b9000e63 	str	w3, [x19, #12]
   90584:	36f800a3 	tbz	w3, #31, 90598 <__fputwc+0x78>
   90588:	b9402a64 	ldr	w4, [x19, #40]
   9058c:	6b04007f 	cmp	w3, w4
   90590:	7a4aa824 	ccmp	w1, #0xa, #0x4, ge	// ge = tcont
   90594:	54000140 	b.eq	905bc <__fputwc+0x9c>  // b.none
   90598:	f9400263 	ldr	x3, [x19]
   9059c:	91000464 	add	x4, x3, #0x1
   905a0:	f9000264 	str	x4, [x19]
   905a4:	39000061 	strb	w1, [x3]
   905a8:	f94013f5 	ldr	x21, [sp, #32]
   905ac:	2a1403e0 	mov	w0, w20
   905b0:	a94153f3 	ldp	x19, x20, [sp, #16]
   905b4:	a8c47bfd 	ldp	x29, x30, [sp], #64
   905b8:	d65f03c0 	ret
   905bc:	aa1303e2 	mov	x2, x19
   905c0:	aa1503e0 	mov	x0, x21
   905c4:	94000827 	bl	92660 <__swbuf_r>
   905c8:	3100041f 	cmn	w0, #0x1
   905cc:	54fffee1 	b.ne	905a8 <__fputwc+0x88>  // b.any
   905d0:	12800000 	mov	w0, #0xffffffff            	// #-1
   905d4:	a94153f3 	ldp	x19, x20, [sp, #16]
   905d8:	f94013f5 	ldr	x21, [sp, #32]
   905dc:	a8c47bfd 	ldp	x29, x30, [sp], #64
   905e0:	d65f03c0 	ret
   905e4:	3900e3f4 	strb	w20, [sp, #56]
   905e8:	17ffffe3 	b	90574 <__fputwc+0x54>
   905ec:	79402260 	ldrh	w0, [x19, #16]
   905f0:	321a0000 	orr	w0, w0, #0x40
   905f4:	79002260 	strh	w0, [x19, #16]
   905f8:	12800000 	mov	w0, #0xffffffff            	// #-1
   905fc:	17fffff6 	b	905d4 <__fputwc+0xb4>

0000000000090600 <_fputwc_r>:
   90600:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   90604:	910003fd 	mov	x29, sp
   90608:	a90153f3 	stp	x19, x20, [sp, #16]
   9060c:	aa0003f4 	mov	x20, x0
   90610:	b940b040 	ldr	w0, [x2, #176]
   90614:	aa0203f3 	mov	x19, x2
   90618:	79c02042 	ldrsh	w2, [x2, #16]
   9061c:	37000040 	tbnz	w0, #0, 90624 <_fputwc_r+0x24>
   90620:	36480322 	tbz	w2, #9, 90684 <_fputwc_r+0x84>
   90624:	376800c2 	tbnz	w2, #13, 9063c <_fputwc_r+0x3c>
   90628:	b940b260 	ldr	w0, [x19, #176]
   9062c:	32130042 	orr	w2, w2, #0x2000
   90630:	79002262 	strh	w2, [x19, #16]
   90634:	32130000 	orr	w0, w0, #0x2000
   90638:	b900b260 	str	w0, [x19, #176]
   9063c:	aa1403e0 	mov	x0, x20
   90640:	aa1303e2 	mov	x2, x19
   90644:	97ffffb7 	bl	90520 <__fputwc>
   90648:	2a0003f4 	mov	w20, w0
   9064c:	b940b261 	ldr	w1, [x19, #176]
   90650:	37000061 	tbnz	w1, #0, 9065c <_fputwc_r+0x5c>
   90654:	79402260 	ldrh	w0, [x19, #16]
   90658:	364800a0 	tbz	w0, #9, 9066c <_fputwc_r+0x6c>
   9065c:	2a1403e0 	mov	w0, w20
   90660:	a94153f3 	ldp	x19, x20, [sp, #16]
   90664:	a8c37bfd 	ldp	x29, x30, [sp], #48
   90668:	d65f03c0 	ret
   9066c:	f9405260 	ldr	x0, [x19, #160]
   90670:	97ffee40 	bl	8bf70 <__retarget_lock_release_recursive>
   90674:	2a1403e0 	mov	w0, w20
   90678:	a94153f3 	ldp	x19, x20, [sp, #16]
   9067c:	a8c37bfd 	ldp	x29, x30, [sp], #48
   90680:	d65f03c0 	ret
   90684:	f9405260 	ldr	x0, [x19, #160]
   90688:	b9002fe1 	str	w1, [sp, #44]
   9068c:	97ffee29 	bl	8bf30 <__retarget_lock_acquire_recursive>
   90690:	79c02262 	ldrsh	w2, [x19, #16]
   90694:	b9402fe1 	ldr	w1, [sp, #44]
   90698:	17ffffe3 	b	90624 <_fputwc_r+0x24>
   9069c:	00000000 	udf	#0

00000000000906a0 <fputwc>:
   906a0:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   906a4:	d0000022 	adrp	x2, 96000 <JIS_state_table+0x70>
   906a8:	910003fd 	mov	x29, sp
   906ac:	f90013f5 	str	x21, [sp, #32]
   906b0:	f9410055 	ldr	x21, [x2, #512]
   906b4:	a90153f3 	stp	x19, x20, [sp, #16]
   906b8:	2a0003f4 	mov	w20, w0
   906bc:	aa0103f3 	mov	x19, x1
   906c0:	b4000075 	cbz	x21, 906cc <fputwc+0x2c>
   906c4:	f94026a0 	ldr	x0, [x21, #72]
   906c8:	b4000480 	cbz	x0, 90758 <fputwc+0xb8>
   906cc:	b940b260 	ldr	w0, [x19, #176]
   906d0:	79c02262 	ldrsh	w2, [x19, #16]
   906d4:	37000040 	tbnz	w0, #0, 906dc <fputwc+0x3c>
   906d8:	36480382 	tbz	w2, #9, 90748 <fputwc+0xa8>
   906dc:	376800c2 	tbnz	w2, #13, 906f4 <fputwc+0x54>
   906e0:	b940b260 	ldr	w0, [x19, #176]
   906e4:	32130042 	orr	w2, w2, #0x2000
   906e8:	79002262 	strh	w2, [x19, #16]
   906ec:	32130000 	orr	w0, w0, #0x2000
   906f0:	b900b260 	str	w0, [x19, #176]
   906f4:	2a1403e1 	mov	w1, w20
   906f8:	aa1503e0 	mov	x0, x21
   906fc:	aa1303e2 	mov	x2, x19
   90700:	97ffff88 	bl	90520 <__fputwc>
   90704:	b940b261 	ldr	w1, [x19, #176]
   90708:	2a0003f4 	mov	w20, w0
   9070c:	37000061 	tbnz	w1, #0, 90718 <fputwc+0x78>
   90710:	79402260 	ldrh	w0, [x19, #16]
   90714:	364800c0 	tbz	w0, #9, 9072c <fputwc+0x8c>
   90718:	f94013f5 	ldr	x21, [sp, #32]
   9071c:	2a1403e0 	mov	w0, w20
   90720:	a94153f3 	ldp	x19, x20, [sp, #16]
   90724:	a8c37bfd 	ldp	x29, x30, [sp], #48
   90728:	d65f03c0 	ret
   9072c:	f9405260 	ldr	x0, [x19, #160]
   90730:	97ffee10 	bl	8bf70 <__retarget_lock_release_recursive>
   90734:	f94013f5 	ldr	x21, [sp, #32]
   90738:	2a1403e0 	mov	w0, w20
   9073c:	a94153f3 	ldp	x19, x20, [sp, #16]
   90740:	a8c37bfd 	ldp	x29, x30, [sp], #48
   90744:	d65f03c0 	ret
   90748:	f9405260 	ldr	x0, [x19, #160]
   9074c:	97ffedf9 	bl	8bf30 <__retarget_lock_acquire_recursive>
   90750:	79c02262 	ldrsh	w2, [x19, #16]
   90754:	17ffffe2 	b	906dc <fputwc+0x3c>
   90758:	aa1503e0 	mov	x0, x21
   9075c:	97ffc7a9 	bl	82600 <__sinit>
   90760:	17ffffdb 	b	906cc <fputwc+0x2c>
	...

0000000000090770 <_wctomb_r>:
   90770:	d0000024 	adrp	x4, 96000 <JIS_state_table+0x70>
   90774:	f946b884 	ldr	x4, [x4, #3440]
   90778:	aa0403f0 	mov	x16, x4
   9077c:	d61f0200 	br	x16

0000000000090780 <__ascii_wctomb>:
   90780:	aa0003e3 	mov	x3, x0
   90784:	b4000141 	cbz	x1, 907ac <__ascii_wctomb+0x2c>
   90788:	7103fc5f 	cmp	w2, #0xff
   9078c:	54000088 	b.hi	9079c <__ascii_wctomb+0x1c>  // b.pmore
   90790:	52800020 	mov	w0, #0x1                   	// #1
   90794:	39000022 	strb	w2, [x1]
   90798:	d65f03c0 	ret
   9079c:	52801141 	mov	w1, #0x8a                  	// #138
   907a0:	12800000 	mov	w0, #0xffffffff            	// #-1
   907a4:	b9000061 	str	w1, [x3]
   907a8:	d65f03c0 	ret
   907ac:	52800000 	mov	w0, #0x0                   	// #0
   907b0:	d65f03c0 	ret
	...

00000000000907c0 <__utf8_wctomb>:
   907c0:	aa0003e3 	mov	x3, x0
   907c4:	b40004e1 	cbz	x1, 90860 <__utf8_wctomb+0xa0>
   907c8:	7101fc5f 	cmp	w2, #0x7f
   907cc:	54000349 	b.ls	90834 <__utf8_wctomb+0x74>  // b.plast
   907d0:	51020040 	sub	w0, w2, #0x80
   907d4:	711dfc1f 	cmp	w0, #0x77f
   907d8:	54000349 	b.ls	90840 <__utf8_wctomb+0x80>  // b.plast
   907dc:	51200044 	sub	w4, w2, #0x800
   907e0:	529effe0 	mov	w0, #0xf7ff                	// #63487
   907e4:	6b00009f 	cmp	w4, w0
   907e8:	54000409 	b.ls	90868 <__utf8_wctomb+0xa8>  // b.plast
   907ec:	51404044 	sub	w4, w2, #0x10, lsl #12
   907f0:	12bffe00 	mov	w0, #0xfffff               	// #1048575
   907f4:	6b00009f 	cmp	w4, w0
   907f8:	540004e8 	b.hi	90894 <__utf8_wctomb+0xd4>  // b.pmore
   907fc:	53127c45 	lsr	w5, w2, #18
   90800:	d34c4444 	ubfx	x4, x2, #12, #6
   90804:	d3462c43 	ubfx	x3, x2, #6, #6
   90808:	12001442 	and	w2, w2, #0x3f
   9080c:	321c6ca5 	orr	w5, w5, #0xfffffff0
   90810:	32196084 	orr	w4, w4, #0xffffff80
   90814:	32196063 	orr	w3, w3, #0xffffff80
   90818:	32196042 	orr	w2, w2, #0xffffff80
   9081c:	52800080 	mov	w0, #0x4                   	// #4
   90820:	39000025 	strb	w5, [x1]
   90824:	39000424 	strb	w4, [x1, #1]
   90828:	39000823 	strb	w3, [x1, #2]
   9082c:	39000c22 	strb	w2, [x1, #3]
   90830:	d65f03c0 	ret
   90834:	52800020 	mov	w0, #0x1                   	// #1
   90838:	39000022 	strb	w2, [x1]
   9083c:	d65f03c0 	ret
   90840:	53067c43 	lsr	w3, w2, #6
   90844:	12001442 	and	w2, w2, #0x3f
   90848:	321a6463 	orr	w3, w3, #0xffffffc0
   9084c:	32196042 	orr	w2, w2, #0xffffff80
   90850:	52800040 	mov	w0, #0x2                   	// #2
   90854:	39000023 	strb	w3, [x1]
   90858:	39000422 	strb	w2, [x1, #1]
   9085c:	d65f03c0 	ret
   90860:	52800000 	mov	w0, #0x0                   	// #0
   90864:	d65f03c0 	ret
   90868:	530c7c44 	lsr	w4, w2, #12
   9086c:	d3462c43 	ubfx	x3, x2, #6, #6
   90870:	12001442 	and	w2, w2, #0x3f
   90874:	321b6884 	orr	w4, w4, #0xffffffe0
   90878:	32196063 	orr	w3, w3, #0xffffff80
   9087c:	32196042 	orr	w2, w2, #0xffffff80
   90880:	52800060 	mov	w0, #0x3                   	// #3
   90884:	39000024 	strb	w4, [x1]
   90888:	39000423 	strb	w3, [x1, #1]
   9088c:	39000822 	strb	w2, [x1, #2]
   90890:	d65f03c0 	ret
   90894:	52801141 	mov	w1, #0x8a                  	// #138
   90898:	12800000 	mov	w0, #0xffffffff            	// #-1
   9089c:	b9000061 	str	w1, [x3]
   908a0:	d65f03c0 	ret
	...

00000000000908b0 <__sjis_wctomb>:
   908b0:	aa0003e5 	mov	x5, x0
   908b4:	12001c44 	and	w4, w2, #0xff
   908b8:	d3483c43 	ubfx	x3, x2, #8, #8
   908bc:	b4000301 	cbz	x1, 9091c <__sjis_wctomb+0x6c>
   908c0:	34000283 	cbz	w3, 90910 <__sjis_wctomb+0x60>
   908c4:	1101fc60 	add	w0, w3, #0x7f
   908c8:	11008063 	add	w3, w3, #0x20
   908cc:	12001c00 	and	w0, w0, #0xff
   908d0:	12001c63 	and	w3, w3, #0xff
   908d4:	7100781f 	cmp	w0, #0x1e
   908d8:	7a4f8860 	ccmp	w3, #0xf, #0x0, hi	// hi = pmore
   908dc:	54000248 	b.hi	90924 <__sjis_wctomb+0x74>  // b.pmore
   908e0:	51010080 	sub	w0, w4, #0x40
   908e4:	51020084 	sub	w4, w4, #0x80
   908e8:	12001c00 	and	w0, w0, #0xff
   908ec:	12001c84 	and	w4, w4, #0xff
   908f0:	7100f81f 	cmp	w0, #0x3e
   908f4:	52800f80 	mov	w0, #0x7c                  	// #124
   908f8:	7a408080 	ccmp	w4, w0, #0x0, hi	// hi = pmore
   908fc:	54000148 	b.hi	90924 <__sjis_wctomb+0x74>  // b.pmore
   90900:	5ac00442 	rev16	w2, w2
   90904:	52800040 	mov	w0, #0x2                   	// #2
   90908:	79000022 	strh	w2, [x1]
   9090c:	d65f03c0 	ret
   90910:	52800020 	mov	w0, #0x1                   	// #1
   90914:	39000024 	strb	w4, [x1]
   90918:	d65f03c0 	ret
   9091c:	52800000 	mov	w0, #0x0                   	// #0
   90920:	d65f03c0 	ret
   90924:	52801141 	mov	w1, #0x8a                  	// #138
   90928:	12800000 	mov	w0, #0xffffffff            	// #-1
   9092c:	b90000a1 	str	w1, [x5]
   90930:	d65f03c0 	ret
	...

0000000000090940 <__eucjp_wctomb>:
   90940:	aa0003e4 	mov	x4, x0
   90944:	12001c43 	and	w3, w2, #0xff
   90948:	d3483c45 	ubfx	x5, x2, #8, #8
   9094c:	b40003a1 	cbz	x1, 909c0 <__eucjp_wctomb+0x80>
   90950:	34000325 	cbz	w5, 909b4 <__eucjp_wctomb+0x74>
   90954:	11017ca0 	add	w0, w5, #0x5f
   90958:	1101c8a6 	add	w6, w5, #0x72
   9095c:	12001c00 	and	w0, w0, #0xff
   90960:	12001cc6 	and	w6, w6, #0xff
   90964:	7101741f 	cmp	w0, #0x5d
   90968:	7a4188c0 	ccmp	w6, #0x1, #0x0, hi	// hi = pmore
   9096c:	54000368 	b.hi	909d8 <__eucjp_wctomb+0x98>  // b.pmore
   90970:	11017c66 	add	w6, w3, #0x5f
   90974:	12001cc6 	and	w6, w6, #0xff
   90978:	710174df 	cmp	w6, #0x5d
   9097c:	54000269 	b.ls	909c8 <__eucjp_wctomb+0x88>  // b.plast
   90980:	7101741f 	cmp	w0, #0x5d
   90984:	540002a8 	b.hi	909d8 <__eucjp_wctomb+0x98>  // b.pmore
   90988:	32190063 	orr	w3, w3, #0x80
   9098c:	11017c60 	add	w0, w3, #0x5f
   90990:	12001c00 	and	w0, w0, #0xff
   90994:	7101741f 	cmp	w0, #0x5d
   90998:	54000208 	b.hi	909d8 <__eucjp_wctomb+0x98>  // b.pmore
   9099c:	12800e02 	mov	w2, #0xffffff8f            	// #-113
   909a0:	52800060 	mov	w0, #0x3                   	// #3
   909a4:	39000022 	strb	w2, [x1]
   909a8:	39000425 	strb	w5, [x1, #1]
   909ac:	39000823 	strb	w3, [x1, #2]
   909b0:	d65f03c0 	ret
   909b4:	52800020 	mov	w0, #0x1                   	// #1
   909b8:	39000023 	strb	w3, [x1]
   909bc:	d65f03c0 	ret
   909c0:	52800000 	mov	w0, #0x0                   	// #0
   909c4:	d65f03c0 	ret
   909c8:	5ac00442 	rev16	w2, w2
   909cc:	52800040 	mov	w0, #0x2                   	// #2
   909d0:	79000022 	strh	w2, [x1]
   909d4:	d65f03c0 	ret
   909d8:	52801141 	mov	w1, #0x8a                  	// #138
   909dc:	12800000 	mov	w0, #0xffffffff            	// #-1
   909e0:	b9000081 	str	w1, [x4]
   909e4:	d65f03c0 	ret
	...

00000000000909f0 <__jis_wctomb>:
   909f0:	aa0003e6 	mov	x6, x0
   909f4:	12001c45 	and	w5, w2, #0xff
   909f8:	d3483c44 	ubfx	x4, x2, #8, #8
   909fc:	b40004c1 	cbz	x1, 90a94 <__jis_wctomb+0xa4>
   90a00:	34000304 	cbz	w4, 90a60 <__jis_wctomb+0x70>
   90a04:	51008484 	sub	w4, w4, #0x21
   90a08:	12001c84 	and	w4, w4, #0xff
   90a0c:	7101749f 	cmp	w4, #0x5d
   90a10:	54000468 	b.hi	90a9c <__jis_wctomb+0xac>  // b.pmore
   90a14:	510084a5 	sub	w5, w5, #0x21
   90a18:	12001ca5 	and	w5, w5, #0xff
   90a1c:	710174bf 	cmp	w5, #0x5d
   90a20:	540003e8 	b.hi	90a9c <__jis_wctomb+0xac>  // b.pmore
   90a24:	b9400064 	ldr	w4, [x3]
   90a28:	52800040 	mov	w0, #0x2                   	// #2
   90a2c:	35000144 	cbnz	w4, 90a54 <__jis_wctomb+0x64>
   90a30:	aa0103e4 	mov	x4, x1
   90a34:	52800020 	mov	w0, #0x1                   	// #1
   90a38:	b9000060 	str	w0, [x3]
   90a3c:	52848365 	mov	w5, #0x241b                	// #9243
   90a40:	52800843 	mov	w3, #0x42                  	// #66
   90a44:	528000a0 	mov	w0, #0x5                   	// #5
   90a48:	78003485 	strh	w5, [x4], #3
   90a4c:	39000823 	strb	w3, [x1, #2]
   90a50:	aa0403e1 	mov	x1, x4
   90a54:	5ac00442 	rev16	w2, w2
   90a58:	79000022 	strh	w2, [x1]
   90a5c:	d65f03c0 	ret
   90a60:	b9400062 	ldr	w2, [x3]
   90a64:	52800020 	mov	w0, #0x1                   	// #1
   90a68:	34000122 	cbz	w2, 90a8c <__jis_wctomb+0x9c>
   90a6c:	aa0103e2 	mov	x2, x1
   90a70:	b900007f 	str	wzr, [x3]
   90a74:	52850364 	mov	w4, #0x281b                	// #10267
   90a78:	52800843 	mov	w3, #0x42                  	// #66
   90a7c:	52800080 	mov	w0, #0x4                   	// #4
   90a80:	78003444 	strh	w4, [x2], #3
   90a84:	39000823 	strb	w3, [x1, #2]
   90a88:	aa0203e1 	mov	x1, x2
   90a8c:	39000025 	strb	w5, [x1]
   90a90:	d65f03c0 	ret
   90a94:	52800020 	mov	w0, #0x1                   	// #1
   90a98:	d65f03c0 	ret
   90a9c:	52801141 	mov	w1, #0x8a                  	// #138
   90aa0:	12800000 	mov	w0, #0xffffffff            	// #-1
   90aa4:	b90000c1 	str	w1, [x6]
   90aa8:	d65f03c0 	ret
   90aac:	00000000 	udf	#0

0000000000090ab0 <_sbrk_r>:
   90ab0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   90ab4:	910003fd 	mov	x29, sp
   90ab8:	a90153f3 	stp	x19, x20, [sp, #16]
   90abc:	f0001394 	adrp	x20, 303000 <saved_categories.0+0xa0>
   90ac0:	aa0003f3 	mov	x19, x0
   90ac4:	b9012a9f 	str	wzr, [x20, #296]
   90ac8:	aa0103e0 	mov	x0, x1
   90acc:	97ffc0f2 	bl	80e94 <_sbrk>
   90ad0:	b100041f 	cmn	x0, #0x1
   90ad4:	54000080 	b.eq	90ae4 <_sbrk_r+0x34>  // b.none
   90ad8:	a94153f3 	ldp	x19, x20, [sp, #16]
   90adc:	a8c27bfd 	ldp	x29, x30, [sp], #32
   90ae0:	d65f03c0 	ret
   90ae4:	b9412a81 	ldr	w1, [x20, #296]
   90ae8:	34ffff81 	cbz	w1, 90ad8 <_sbrk_r+0x28>
   90aec:	b9000261 	str	w1, [x19]
   90af0:	a94153f3 	ldp	x19, x20, [sp, #16]
   90af4:	a8c27bfd 	ldp	x29, x30, [sp], #32
   90af8:	d65f03c0 	ret
   90afc:	00000000 	udf	#0

0000000000090b00 <__ssprint_r>:
   90b00:	a9b97bfd 	stp	x29, x30, [sp, #-112]!
   90b04:	910003fd 	mov	x29, sp
   90b08:	f90037e0 	str	x0, [sp, #104]
   90b0c:	f9400840 	ldr	x0, [x2, #16]
   90b10:	a9025bf5 	stp	x21, x22, [sp, #32]
   90b14:	aa0203f6 	mov	x22, x2
   90b18:	a90573fb 	stp	x27, x28, [sp, #80]
   90b1c:	f940005b 	ldr	x27, [x2]
   90b20:	b40004e0 	cbz	x0, 90bbc <__ssprint_r+0xbc>
   90b24:	f9400023 	ldr	x3, [x1]
   90b28:	aa0103f5 	mov	x21, x1
   90b2c:	b9400c24 	ldr	w4, [x1, #12]
   90b30:	d280001c 	mov	x28, #0x0                   	// #0
   90b34:	a90153f3 	stp	x19, x20, [sp, #16]
   90b38:	d2800013 	mov	x19, #0x0                   	// #0
   90b3c:	a90363f7 	stp	x23, x24, [sp, #48]
   90b40:	52809017 	mov	w23, #0x480                 	// #1152
   90b44:	a9046bf9 	stp	x25, x26, [sp, #64]
   90b48:	2a0403f9 	mov	w25, w4
   90b4c:	aa0303e0 	mov	x0, x3
   90b50:	b4000433 	cbz	x19, 90bd4 <__ssprint_r+0xd4>
   90b54:	93407c9a 	sxtw	x26, w4
   90b58:	eb1a027f 	cmp	x19, x26
   90b5c:	54000422 	b.cs	90be0 <__ssprint_r+0xe0>  // b.hs, b.nlast
   90b60:	93407e61 	sxtw	x1, w19
   90b64:	aa0103f4 	mov	x20, x1
   90b68:	aa0303e0 	mov	x0, x3
   90b6c:	aa0103fa 	mov	x26, x1
   90b70:	2a1303f9 	mov	w25, w19
   90b74:	aa1c03e1 	mov	x1, x28
   90b78:	aa1a03e2 	mov	x2, x26
   90b7c:	97fff1f1 	bl	8d340 <memmove>
   90b80:	cb140273 	sub	x19, x19, x20
   90b84:	f94002a3 	ldr	x3, [x21]
   90b88:	8b14039c 	add	x28, x28, x20
   90b8c:	f9400ac0 	ldr	x0, [x22, #16]
   90b90:	8b1a0063 	add	x3, x3, x26
   90b94:	b9400ea4 	ldr	w4, [x21, #12]
   90b98:	f90002a3 	str	x3, [x21]
   90b9c:	cb140000 	sub	x0, x0, x20
   90ba0:	4b190084 	sub	w4, w4, w25
   90ba4:	b9000ea4 	str	w4, [x21, #12]
   90ba8:	f9000ac0 	str	x0, [x22, #16]
   90bac:	b5fffce0 	cbnz	x0, 90b48 <__ssprint_r+0x48>
   90bb0:	a94153f3 	ldp	x19, x20, [sp, #16]
   90bb4:	a94363f7 	ldp	x23, x24, [sp, #48]
   90bb8:	a9446bf9 	ldp	x25, x26, [sp, #64]
   90bbc:	52800000 	mov	w0, #0x0                   	// #0
   90bc0:	a94573fb 	ldp	x27, x28, [sp, #80]
   90bc4:	b9000adf 	str	wzr, [x22, #8]
   90bc8:	a9425bf5 	ldp	x21, x22, [sp, #32]
   90bcc:	a8c77bfd 	ldp	x29, x30, [sp], #112
   90bd0:	d65f03c0 	ret
   90bd4:	a9404f7c 	ldp	x28, x19, [x27]
   90bd8:	9100437b 	add	x27, x27, #0x10
   90bdc:	17ffffdb 	b	90b48 <__ssprint_r+0x48>
   90be0:	79c022a6 	ldrsh	w6, [x21, #16]
   90be4:	93407e74 	sxtw	x20, w19
   90be8:	6a1700df 	tst	w6, w23
   90bec:	54fffc40 	b.eq	90b74 <__ssprint_r+0x74>  // b.none
   90bf0:	b94022a4 	ldr	w4, [x21, #32]
   90bf4:	f9400ea1 	ldr	x1, [x21, #24]
   90bf8:	0b040484 	add	w4, w4, w4, lsl #1
   90bfc:	cb010074 	sub	x20, x3, x1
   90c00:	0b447c84 	add	w4, w4, w4, lsr #31
   90c04:	93407e9a 	sxtw	x26, w20
   90c08:	13017c98 	asr	w24, w4, #1
   90c0c:	91000740 	add	x0, x26, #0x1
   90c10:	8b130000 	add	x0, x0, x19
   90c14:	93407f02 	sxtw	x2, w24
   90c18:	eb00005f 	cmp	x2, x0
   90c1c:	54000082 	b.cs	90c2c <__ssprint_r+0x12c>  // b.hs, b.nlast
   90c20:	11000684 	add	w4, w20, #0x1
   90c24:	0b130098 	add	w24, w4, w19
   90c28:	93407f02 	sxtw	x2, w24
   90c2c:	36500386 	tbz	w6, #10, 90c9c <__ssprint_r+0x19c>
   90c30:	f94037e0 	ldr	x0, [sp, #104]
   90c34:	aa0203e1 	mov	x1, x2
   90c38:	97ffea52 	bl	8b580 <_malloc_r>
   90c3c:	aa0003f9 	mov	x25, x0
   90c40:	b40003c0 	cbz	x0, 90cb8 <__ssprint_r+0x1b8>
   90c44:	f9400ea1 	ldr	x1, [x21, #24]
   90c48:	aa1a03e2 	mov	x2, x26
   90c4c:	97fff15d 	bl	8d1c0 <memcpy>
   90c50:	794022a0 	ldrh	w0, [x21, #16]
   90c54:	12809001 	mov	w1, #0xfffffb7f            	// #-1153
   90c58:	0a010000 	and	w0, w0, w1
   90c5c:	32190000 	orr	w0, w0, #0x80
   90c60:	790022a0 	strh	w0, [x21, #16]
   90c64:	8b1a0320 	add	x0, x25, x26
   90c68:	4b140303 	sub	w3, w24, w20
   90c6c:	93407e74 	sxtw	x20, w19
   90c70:	f90002a0 	str	x0, [x21]
   90c74:	b9000ea3 	str	w3, [x21, #12]
   90c78:	aa1403e1 	mov	x1, x20
   90c7c:	f9000eb9 	str	x25, [x21, #24]
   90c80:	aa0003e3 	mov	x3, x0
   90c84:	b90022b8 	str	w24, [x21, #32]
   90c88:	2a1303f9 	mov	w25, w19
   90c8c:	eb13029f 	cmp	x20, x19
   90c90:	54fff6a8 	b.hi	90b64 <__ssprint_r+0x64>  // b.pmore
   90c94:	aa1403fa 	mov	x26, x20
   90c98:	17ffffb7 	b	90b74 <__ssprint_r+0x74>
   90c9c:	f94037e0 	ldr	x0, [sp, #104]
   90ca0:	97fff924 	bl	8f130 <_realloc_r>
   90ca4:	aa0003f9 	mov	x25, x0
   90ca8:	b5fffde0 	cbnz	x0, 90c64 <__ssprint_r+0x164>
   90cac:	f9400ea1 	ldr	x1, [x21, #24]
   90cb0:	f94037e0 	ldr	x0, [sp, #104]
   90cb4:	97fffac3 	bl	8f7c0 <_free_r>
   90cb8:	f94037e2 	ldr	x2, [sp, #104]
   90cbc:	52800180 	mov	w0, #0xc                   	// #12
   90cc0:	794022a1 	ldrh	w1, [x21, #16]
   90cc4:	a94153f3 	ldp	x19, x20, [sp, #16]
   90cc8:	321a0021 	orr	w1, w1, #0x40
   90ccc:	a94363f7 	ldp	x23, x24, [sp, #48]
   90cd0:	a9446bf9 	ldp	x25, x26, [sp, #64]
   90cd4:	b9000040 	str	w0, [x2]
   90cd8:	790022a1 	strh	w1, [x21, #16]
   90cdc:	12800000 	mov	w0, #0xffffffff            	// #-1
   90ce0:	a94573fb 	ldp	x27, x28, [sp, #80]
   90ce4:	b9000adf 	str	wzr, [x22, #8]
   90ce8:	f9000adf 	str	xzr, [x22, #16]
   90cec:	a9425bf5 	ldp	x21, x22, [sp, #32]
   90cf0:	a8c77bfd 	ldp	x29, x30, [sp], #112
   90cf4:	d65f03c0 	ret
	...

0000000000090d00 <_svfiprintf_r>:
   90d00:	a9a17bfd 	stp	x29, x30, [sp, #-496]!
   90d04:	910003fd 	mov	x29, sp
   90d08:	a90153f3 	stp	x19, x20, [sp, #16]
   90d0c:	aa0003f3 	mov	x19, x0
   90d10:	a90363f7 	stp	x23, x24, [sp, #48]
   90d14:	a9400078 	ldp	x24, x0, [x3]
   90d18:	a9025bf5 	stp	x21, x22, [sp, #32]
   90d1c:	aa0103f6 	mov	x22, x1
   90d20:	b9401861 	ldr	w1, [x3, #24]
   90d24:	a90573fb 	stp	x27, x28, [sp, #80]
   90d28:	aa0203fb 	mov	x27, x2
   90d2c:	d2800102 	mov	x2, #0x8                   	// #8
   90d30:	b90067e1 	str	w1, [sp, #100]
   90d34:	52800001 	mov	w1, #0x0                   	// #0
   90d38:	f9003fe0 	str	x0, [sp, #120]
   90d3c:	910363e0 	add	x0, sp, #0xd8
   90d40:	97fff220 	bl	8d5c0 <memset>
   90d44:	794022c0 	ldrh	w0, [x22, #16]
   90d48:	36380060 	tbz	w0, #7, 90d54 <_svfiprintf_r+0x54>
   90d4c:	f9400ec0 	ldr	x0, [x22, #24]
   90d50:	b4007be0 	cbz	x0, 91ccc <_svfiprintf_r+0xfcc>
   90d54:	a9046bf9 	stp	x25, x26, [sp, #64]
   90d58:	9105c3f7 	add	x23, sp, #0x170
   90d5c:	d0000035 	adrp	x21, 96000 <JIS_state_table+0x70>
   90d60:	aa1703fc 	mov	x28, x23
   90d64:	913242b5 	add	x21, x21, #0xc90
   90d68:	b0000020 	adrp	x0, 95000 <pmu_event_descr+0x60>
   90d6c:	91399000 	add	x0, x0, #0xe64
   90d70:	b90063ff 	str	wzr, [sp, #96]
   90d74:	f9003be0 	str	x0, [sp, #112]
   90d78:	f90043ff 	str	xzr, [sp, #128]
   90d7c:	a909ffff 	stp	xzr, xzr, [sp, #152]
   90d80:	f90057ff 	str	xzr, [sp, #168]
   90d84:	f9007bf7 	str	x23, [sp, #240]
   90d88:	b900fbff 	str	wzr, [sp, #248]
   90d8c:	f90083ff 	str	xzr, [sp, #256]
   90d90:	aa1b03fa 	mov	x26, x27
   90d94:	d503201f 	nop
   90d98:	f94076b4 	ldr	x20, [x21, #232]
   90d9c:	97ffef9d 	bl	8cc10 <__locale_mb_cur_max>
   90da0:	910363e4 	add	x4, sp, #0xd8
   90da4:	93407c03 	sxtw	x3, w0
   90da8:	aa1a03e2 	mov	x2, x26
   90dac:	910353e1 	add	x1, sp, #0xd4
   90db0:	aa1303e0 	mov	x0, x19
   90db4:	d63f0280 	blr	x20
   90db8:	7100001f 	cmp	w0, #0x0
   90dbc:	340001e0 	cbz	w0, 90df8 <_svfiprintf_r+0xf8>
   90dc0:	540000eb 	b.lt	90ddc <_svfiprintf_r+0xdc>  // b.tstop
   90dc4:	b940d7e1 	ldr	w1, [sp, #212]
   90dc8:	7100943f 	cmp	w1, #0x25
   90dcc:	54001540 	b.eq	91074 <_svfiprintf_r+0x374>  // b.none
   90dd0:	93407c00 	sxtw	x0, w0
   90dd4:	8b00035a 	add	x26, x26, x0
   90dd8:	17fffff0 	b	90d98 <_svfiprintf_r+0x98>
   90ddc:	910363e0 	add	x0, sp, #0xd8
   90de0:	d2800102 	mov	x2, #0x8                   	// #8
   90de4:	52800001 	mov	w1, #0x0                   	// #0
   90de8:	97fff1f6 	bl	8d5c0 <memset>
   90dec:	d2800020 	mov	x0, #0x1                   	// #1
   90df0:	8b00035a 	add	x26, x26, x0
   90df4:	17ffffe9 	b	90d98 <_svfiprintf_r+0x98>
   90df8:	2a0003f4 	mov	w20, w0
   90dfc:	cb1b0340 	sub	x0, x26, x27
   90e00:	2a0003f9 	mov	w25, w0
   90e04:	34008980 	cbz	w0, 91f34 <_svfiprintf_r+0x1234>
   90e08:	f94083e2 	ldr	x2, [sp, #256]
   90e0c:	93407f21 	sxtw	x1, w25
   90e10:	b940fbe0 	ldr	w0, [sp, #248]
   90e14:	8b010042 	add	x2, x2, x1
   90e18:	a900079b 	stp	x27, x1, [x28]
   90e1c:	11000400 	add	w0, w0, #0x1
   90e20:	b900fbe0 	str	w0, [sp, #248]
   90e24:	9100439c 	add	x28, x28, #0x10
   90e28:	f90083e2 	str	x2, [sp, #256]
   90e2c:	71001c1f 	cmp	w0, #0x7
   90e30:	5400278c 	b.gt	91320 <_svfiprintf_r+0x620>
   90e34:	b94063e0 	ldr	w0, [sp, #96]
   90e38:	0b190000 	add	w0, w0, w25
   90e3c:	b90063e0 	str	w0, [sp, #96]
   90e40:	340087b4 	cbz	w20, 91f34 <_svfiprintf_r+0x1234>
   90e44:	39400740 	ldrb	w0, [x26, #1]
   90e48:	9100075b 	add	x27, x26, #0x1
   90e4c:	12800003 	mov	w3, #0xffffffff            	// #-1
   90e50:	52800008 	mov	w8, #0x0                   	// #0
   90e54:	2a0303fa 	mov	w26, w3
   90e58:	2a0803f9 	mov	w25, w8
   90e5c:	52800014 	mov	w20, #0x0                   	// #0
   90e60:	39033fff 	strb	wzr, [sp, #207]
   90e64:	9100077b 	add	x27, x27, #0x1
   90e68:	51008001 	sub	w1, w0, #0x20
   90e6c:	7101683f 	cmp	w1, #0x5a
   90e70:	540000c8 	b.hi	90e88 <_svfiprintf_r+0x188>  // b.pmore
   90e74:	f9403be2 	ldr	x2, [sp, #112]
   90e78:	78615841 	ldrh	w1, [x2, w1, uxtw #1]
   90e7c:	10000062 	adr	x2, 90e88 <_svfiprintf_r+0x188>
   90e80:	8b21a841 	add	x1, x2, w1, sxth #2
   90e84:	d61f0020 	br	x1
   90e88:	2a1903e8 	mov	w8, w25
   90e8c:	34008540 	cbz	w0, 91f34 <_svfiprintf_r+0x1234>
   90e90:	52800024 	mov	w4, #0x1                   	// #1
   90e94:	910423fa 	add	x26, sp, #0x108
   90e98:	2a0403f9 	mov	w25, w4
   90e9c:	39033fff 	strb	wzr, [sp, #207]
   90ea0:	390423e0 	strb	w0, [sp, #264]
   90ea4:	52800003 	mov	w3, #0x0                   	// #0
   90ea8:	f90037ff 	str	xzr, [sp, #104]
   90eac:	d503201f 	nop
   90eb0:	11000881 	add	w1, w4, #0x2
   90eb4:	721f028c 	ands	w12, w20, #0x2
   90eb8:	1a841024 	csel	w4, w1, w4, ne	// ne = any
   90ebc:	52801082 	mov	w2, #0x84                  	// #132
   90ec0:	f94083e1 	ldr	x1, [sp, #256]
   90ec4:	6a02028d 	ands	w13, w20, w2
   90ec8:	b940fbe0 	ldr	w0, [sp, #248]
   90ecc:	54000081 	b.ne	90edc <_svfiprintf_r+0x1dc>  // b.any
   90ed0:	4b04010b 	sub	w11, w8, w4
   90ed4:	7100017f 	cmp	w11, #0x0
   90ed8:	5400232c 	b.gt	9133c <_svfiprintf_r+0x63c>
   90edc:	39433fe2 	ldrb	w2, [sp, #207]
   90ee0:	34000182 	cbz	w2, 90f10 <_svfiprintf_r+0x210>
   90ee4:	91033fe2 	add	x2, sp, #0xcf
   90ee8:	11000400 	add	w0, w0, #0x1
   90eec:	91000421 	add	x1, x1, #0x1
   90ef0:	f9000382 	str	x2, [x28]
   90ef4:	d2800022 	mov	x2, #0x1                   	// #1
   90ef8:	f9000782 	str	x2, [x28, #8]
   90efc:	b900fbe0 	str	w0, [sp, #248]
   90f00:	9100439c 	add	x28, x28, #0x10
   90f04:	f90083e1 	str	x1, [sp, #256]
   90f08:	71001c1f 	cmp	w0, #0x7
   90f0c:	5400082c 	b.gt	91010 <_svfiprintf_r+0x310>
   90f10:	3400016c 	cbz	w12, 90f3c <_svfiprintf_r+0x23c>
   90f14:	11000400 	add	w0, w0, #0x1
   90f18:	91000821 	add	x1, x1, #0x2
   90f1c:	910343ea 	add	x10, sp, #0xd0
   90f20:	d2800042 	mov	x2, #0x2                   	// #2
   90f24:	a9000b8a 	stp	x10, x2, [x28]
   90f28:	9100439c 	add	x28, x28, #0x10
   90f2c:	b900fbe0 	str	w0, [sp, #248]
   90f30:	f90083e1 	str	x1, [sp, #256]
   90f34:	71001c1f 	cmp	w0, #0x7
   90f38:	5400298c 	b.gt	91468 <_svfiprintf_r+0x768>
   90f3c:	710201bf 	cmp	w13, #0x80
   90f40:	54000a40 	b.eq	91088 <_svfiprintf_r+0x388>  // b.none
   90f44:	4b190063 	sub	w3, w3, w25
   90f48:	7100007f 	cmp	w3, #0x0
   90f4c:	5400136c 	b.gt	911b8 <_svfiprintf_r+0x4b8>
   90f50:	93407f29 	sxtw	x9, w25
   90f54:	11000400 	add	w0, w0, #0x1
   90f58:	8b010121 	add	x1, x9, x1
   90f5c:	a900279a 	stp	x26, x9, [x28]
   90f60:	9100439c 	add	x28, x28, #0x10
   90f64:	b900fbe0 	str	w0, [sp, #248]
   90f68:	f90083e1 	str	x1, [sp, #256]
   90f6c:	71001c1f 	cmp	w0, #0x7
   90f70:	5400038c 	b.gt	90fe0 <_svfiprintf_r+0x2e0>
   90f74:	36100094 	tbz	w20, #2, 90f84 <_svfiprintf_r+0x284>
   90f78:	4b040114 	sub	w20, w8, w4
   90f7c:	7100029f 	cmp	w20, #0x0
   90f80:	5400292c 	b.gt	914a4 <_svfiprintf_r+0x7a4>
   90f84:	b94063e0 	ldr	w0, [sp, #96]
   90f88:	6b04011f 	cmp	w8, w4
   90f8c:	1a84a104 	csel	w4, w8, w4, ge	// ge = tcont
   90f90:	0b040000 	add	w0, w0, w4
   90f94:	b90063e0 	str	w0, [sp, #96]
   90f98:	b50019a1 	cbnz	x1, 912cc <_svfiprintf_r+0x5cc>
   90f9c:	f94037e0 	ldr	x0, [sp, #104]
   90fa0:	b900fbff 	str	wzr, [sp, #248]
   90fa4:	b4000080 	cbz	x0, 90fb4 <_svfiprintf_r+0x2b4>
   90fa8:	f94037e1 	ldr	x1, [sp, #104]
   90fac:	aa1303e0 	mov	x0, x19
   90fb0:	97fffa04 	bl	8f7c0 <_free_r>
   90fb4:	aa1703fc 	mov	x28, x23
   90fb8:	17ffff76 	b	90d90 <_svfiprintf_r+0x90>
   90fbc:	5100c001 	sub	w1, w0, #0x30
   90fc0:	52800019 	mov	w25, #0x0                   	// #0
   90fc4:	38401760 	ldrb	w0, [x27], #1
   90fc8:	0b190b28 	add	w8, w25, w25, lsl #2
   90fcc:	0b080439 	add	w25, w1, w8, lsl #1
   90fd0:	5100c001 	sub	w1, w0, #0x30
   90fd4:	7100243f 	cmp	w1, #0x9
   90fd8:	54ffff69 	b.ls	90fc4 <_svfiprintf_r+0x2c4>  // b.plast
   90fdc:	17ffffa3 	b	90e68 <_svfiprintf_r+0x168>
   90fe0:	9103c3e2 	add	x2, sp, #0xf0
   90fe4:	aa1603e1 	mov	x1, x22
   90fe8:	aa1303e0 	mov	x0, x19
   90fec:	b9008be8 	str	w8, [sp, #136]
   90ff0:	b900b3e4 	str	w4, [sp, #176]
   90ff4:	97fffec3 	bl	90b00 <__ssprint_r>
   90ff8:	35001740 	cbnz	w0, 912e0 <_svfiprintf_r+0x5e0>
   90ffc:	f94083e1 	ldr	x1, [sp, #256]
   91000:	aa1703fc 	mov	x28, x23
   91004:	b9408be8 	ldr	w8, [sp, #136]
   91008:	b940b3e4 	ldr	w4, [sp, #176]
   9100c:	17ffffda 	b	90f74 <_svfiprintf_r+0x274>
   91010:	9103c3e2 	add	x2, sp, #0xf0
   91014:	aa1603e1 	mov	x1, x22
   91018:	aa1303e0 	mov	x0, x19
   9101c:	b9008bec 	str	w12, [sp, #136]
   91020:	b90093e8 	str	w8, [sp, #144]
   91024:	29160fed 	stp	w13, w3, [sp, #176]
   91028:	b900bbe4 	str	w4, [sp, #184]
   9102c:	97fffeb5 	bl	90b00 <__ssprint_r>
   91030:	35001580 	cbnz	w0, 912e0 <_svfiprintf_r+0x5e0>
   91034:	f94083e1 	ldr	x1, [sp, #256]
   91038:	aa1703fc 	mov	x28, x23
   9103c:	b9408bec 	ldr	w12, [sp, #136]
   91040:	b94093e8 	ldr	w8, [sp, #144]
   91044:	29560fed 	ldp	w13, w3, [sp, #176]
   91048:	b940bbe4 	ldr	w4, [sp, #184]
   9104c:	b940fbe0 	ldr	w0, [sp, #248]
   91050:	17ffffb0 	b	90f10 <_svfiprintf_r+0x210>
   91054:	39400360 	ldrb	w0, [x27]
   91058:	321c0294 	orr	w20, w20, #0x10
   9105c:	17ffff82 	b	90e64 <_svfiprintf_r+0x164>
   91060:	4b1903f9 	neg	w25, w25
   91064:	aa0003f8 	mov	x24, x0
   91068:	39400360 	ldrb	w0, [x27]
   9106c:	321e0294 	orr	w20, w20, #0x4
   91070:	17ffff7d 	b	90e64 <_svfiprintf_r+0x164>
   91074:	2a0003f4 	mov	w20, w0
   91078:	cb1b0340 	sub	x0, x26, x27
   9107c:	2a0003f9 	mov	w25, w0
   91080:	34ffee20 	cbz	w0, 90e44 <_svfiprintf_r+0x144>
   91084:	17ffff61 	b	90e08 <_svfiprintf_r+0x108>
   91088:	4b04010a 	sub	w10, w8, w4
   9108c:	7100015f 	cmp	w10, #0x0
   91090:	54fff5ad 	b.le	90f44 <_svfiprintf_r+0x244>
   91094:	9000002b 	adrp	x11, 95000 <pmu_event_descr+0x60>
   91098:	913c816b 	add	x11, x11, #0xf20
   9109c:	7100415f 	cmp	w10, #0x10
   910a0:	5400058d 	b.le	91150 <_svfiprintf_r+0x450>
   910a4:	aa1c03e2 	mov	x2, x28
   910a8:	d280020c 	mov	x12, #0x10                  	// #16
   910ac:	aa1b03fc 	mov	x28, x27
   910b0:	2a1903fb 	mov	w27, w25
   910b4:	2a0403f9 	mov	w25, w4
   910b8:	f90047f8 	str	x24, [sp, #136]
   910bc:	aa0b03f8 	mov	x24, x11
   910c0:	b90093e8 	str	w8, [sp, #144]
   910c4:	29160ff4 	stp	w20, w3, [sp, #176]
   910c8:	2a0a03f4 	mov	w20, w10
   910cc:	14000004 	b	910dc <_svfiprintf_r+0x3dc>
   910d0:	51004294 	sub	w20, w20, #0x10
   910d4:	7100429f 	cmp	w20, #0x10
   910d8:	540002ad 	b.le	9112c <_svfiprintf_r+0x42c>
   910dc:	91004021 	add	x1, x1, #0x10
   910e0:	11000400 	add	w0, w0, #0x1
   910e4:	a9003058 	stp	x24, x12, [x2]
   910e8:	91004042 	add	x2, x2, #0x10
   910ec:	b900fbe0 	str	w0, [sp, #248]
   910f0:	f90083e1 	str	x1, [sp, #256]
   910f4:	71001c1f 	cmp	w0, #0x7
   910f8:	54fffecd 	b.le	910d0 <_svfiprintf_r+0x3d0>
   910fc:	9103c3e2 	add	x2, sp, #0xf0
   91100:	aa1603e1 	mov	x1, x22
   91104:	aa1303e0 	mov	x0, x19
   91108:	97fffe7e 	bl	90b00 <__ssprint_r>
   9110c:	35000ea0 	cbnz	w0, 912e0 <_svfiprintf_r+0x5e0>
   91110:	51004294 	sub	w20, w20, #0x10
   91114:	b940fbe0 	ldr	w0, [sp, #248]
   91118:	f94083e1 	ldr	x1, [sp, #256]
   9111c:	aa1703e2 	mov	x2, x23
   91120:	d280020c 	mov	x12, #0x10                  	// #16
   91124:	7100429f 	cmp	w20, #0x10
   91128:	54fffdac 	b.gt	910dc <_svfiprintf_r+0x3dc>
   9112c:	2a1403ea 	mov	w10, w20
   91130:	aa1803eb 	mov	x11, x24
   91134:	f94047f8 	ldr	x24, [sp, #136]
   91138:	2a1903e4 	mov	w4, w25
   9113c:	b94093e8 	ldr	w8, [sp, #144]
   91140:	2a1b03f9 	mov	w25, w27
   91144:	29560ff4 	ldp	w20, w3, [sp, #176]
   91148:	aa1c03fb 	mov	x27, x28
   9114c:	aa0203fc 	mov	x28, x2
   91150:	93407d4a 	sxtw	x10, w10
   91154:	11000400 	add	w0, w0, #0x1
   91158:	8b0a0021 	add	x1, x1, x10
   9115c:	a9002b8b 	stp	x11, x10, [x28]
   91160:	9100439c 	add	x28, x28, #0x10
   91164:	b900fbe0 	str	w0, [sp, #248]
   91168:	f90083e1 	str	x1, [sp, #256]
   9116c:	71001c1f 	cmp	w0, #0x7
   91170:	54ffeead 	b.le	90f44 <_svfiprintf_r+0x244>
   91174:	9103c3e2 	add	x2, sp, #0xf0
   91178:	aa1603e1 	mov	x1, x22
   9117c:	aa1303e0 	mov	x0, x19
   91180:	b9008be8 	str	w8, [sp, #136]
   91184:	b90093e4 	str	w4, [sp, #144]
   91188:	b900b3e3 	str	w3, [sp, #176]
   9118c:	97fffe5d 	bl	90b00 <__ssprint_r>
   91190:	35000a80 	cbnz	w0, 912e0 <_svfiprintf_r+0x5e0>
   91194:	b940b3e3 	ldr	w3, [sp, #176]
   91198:	aa1703fc 	mov	x28, x23
   9119c:	f94083e1 	ldr	x1, [sp, #256]
   911a0:	4b190063 	sub	w3, w3, w25
   911a4:	b9408be8 	ldr	w8, [sp, #136]
   911a8:	b94093e4 	ldr	w4, [sp, #144]
   911ac:	b940fbe0 	ldr	w0, [sp, #248]
   911b0:	7100007f 	cmp	w3, #0x0
   911b4:	54ffeced 	b.le	90f50 <_svfiprintf_r+0x250>
   911b8:	9000002b 	adrp	x11, 95000 <pmu_event_descr+0x60>
   911bc:	913c816b 	add	x11, x11, #0xf20
   911c0:	7100407f 	cmp	w3, #0x10
   911c4:	5400058d 	b.le	91274 <_svfiprintf_r+0x574>
   911c8:	aa1c03e2 	mov	x2, x28
   911cc:	d280020a 	mov	x10, #0x10                  	// #16
   911d0:	aa1b03fc 	mov	x28, x27
   911d4:	2a1903fb 	mov	w27, w25
   911d8:	2a0403f9 	mov	w25, w4
   911dc:	f90047f8 	str	x24, [sp, #136]
   911e0:	aa0b03f8 	mov	x24, x11
   911e4:	b90093e8 	str	w8, [sp, #144]
   911e8:	b900b3f4 	str	w20, [sp, #176]
   911ec:	2a0303f4 	mov	w20, w3
   911f0:	14000004 	b	91200 <_svfiprintf_r+0x500>
   911f4:	51004294 	sub	w20, w20, #0x10
   911f8:	7100429f 	cmp	w20, #0x10
   911fc:	540002ad 	b.le	91250 <_svfiprintf_r+0x550>
   91200:	91004021 	add	x1, x1, #0x10
   91204:	11000400 	add	w0, w0, #0x1
   91208:	a9002858 	stp	x24, x10, [x2]
   9120c:	91004042 	add	x2, x2, #0x10
   91210:	b900fbe0 	str	w0, [sp, #248]
   91214:	f90083e1 	str	x1, [sp, #256]
   91218:	71001c1f 	cmp	w0, #0x7
   9121c:	54fffecd 	b.le	911f4 <_svfiprintf_r+0x4f4>
   91220:	9103c3e2 	add	x2, sp, #0xf0
   91224:	aa1603e1 	mov	x1, x22
   91228:	aa1303e0 	mov	x0, x19
   9122c:	97fffe35 	bl	90b00 <__ssprint_r>
   91230:	35000580 	cbnz	w0, 912e0 <_svfiprintf_r+0x5e0>
   91234:	51004294 	sub	w20, w20, #0x10
   91238:	b940fbe0 	ldr	w0, [sp, #248]
   9123c:	f94083e1 	ldr	x1, [sp, #256]
   91240:	aa1703e2 	mov	x2, x23
   91244:	d280020a 	mov	x10, #0x10                  	// #16
   91248:	7100429f 	cmp	w20, #0x10
   9124c:	54fffdac 	b.gt	91200 <_svfiprintf_r+0x500>
   91250:	2a1403e3 	mov	w3, w20
   91254:	aa1803eb 	mov	x11, x24
   91258:	f94047f8 	ldr	x24, [sp, #136]
   9125c:	2a1903e4 	mov	w4, w25
   91260:	b94093e8 	ldr	w8, [sp, #144]
   91264:	2a1b03f9 	mov	w25, w27
   91268:	b940b3f4 	ldr	w20, [sp, #176]
   9126c:	aa1c03fb 	mov	x27, x28
   91270:	aa0203fc 	mov	x28, x2
   91274:	93407c63 	sxtw	x3, w3
   91278:	11000400 	add	w0, w0, #0x1
   9127c:	8b030021 	add	x1, x1, x3
   91280:	a9000f8b 	stp	x11, x3, [x28]
   91284:	9100439c 	add	x28, x28, #0x10
   91288:	b900fbe0 	str	w0, [sp, #248]
   9128c:	f90083e1 	str	x1, [sp, #256]
   91290:	71001c1f 	cmp	w0, #0x7
   91294:	54ffe5ed 	b.le	90f50 <_svfiprintf_r+0x250>
   91298:	9103c3e2 	add	x2, sp, #0xf0
   9129c:	aa1603e1 	mov	x1, x22
   912a0:	aa1303e0 	mov	x0, x19
   912a4:	b9008be8 	str	w8, [sp, #136]
   912a8:	b900b3e4 	str	w4, [sp, #176]
   912ac:	97fffe15 	bl	90b00 <__ssprint_r>
   912b0:	35000180 	cbnz	w0, 912e0 <_svfiprintf_r+0x5e0>
   912b4:	f94083e1 	ldr	x1, [sp, #256]
   912b8:	aa1703fc 	mov	x28, x23
   912bc:	b9408be8 	ldr	w8, [sp, #136]
   912c0:	b940b3e4 	ldr	w4, [sp, #176]
   912c4:	b940fbe0 	ldr	w0, [sp, #248]
   912c8:	17ffff22 	b	90f50 <_svfiprintf_r+0x250>
   912cc:	9103c3e2 	add	x2, sp, #0xf0
   912d0:	aa1603e1 	mov	x1, x22
   912d4:	aa1303e0 	mov	x0, x19
   912d8:	97fffe0a 	bl	90b00 <__ssprint_r>
   912dc:	34ffe600 	cbz	w0, 90f9c <_svfiprintf_r+0x29c>
   912e0:	f94037e0 	ldr	x0, [sp, #104]
   912e4:	b4000080 	cbz	x0, 912f4 <_svfiprintf_r+0x5f4>
   912e8:	f94037e1 	ldr	x1, [sp, #104]
   912ec:	aa1303e0 	mov	x0, x19
   912f0:	97fff934 	bl	8f7c0 <_free_r>
   912f4:	794022c0 	ldrh	w0, [x22, #16]
   912f8:	121a0000 	and	w0, w0, #0x40
   912fc:	a9446bf9 	ldp	x25, x26, [sp, #64]
   91300:	35007e80 	cbnz	w0, 922d0 <_svfiprintf_r+0x15d0>
   91304:	a94153f3 	ldp	x19, x20, [sp, #16]
   91308:	a9425bf5 	ldp	x21, x22, [sp, #32]
   9130c:	a94363f7 	ldp	x23, x24, [sp, #48]
   91310:	a94573fb 	ldp	x27, x28, [sp, #80]
   91314:	b94063e0 	ldr	w0, [sp, #96]
   91318:	a8df7bfd 	ldp	x29, x30, [sp], #496
   9131c:	d65f03c0 	ret
   91320:	9103c3e2 	add	x2, sp, #0xf0
   91324:	aa1603e1 	mov	x1, x22
   91328:	aa1303e0 	mov	x0, x19
   9132c:	97fffdf5 	bl	90b00 <__ssprint_r>
   91330:	35fffe20 	cbnz	w0, 912f4 <_svfiprintf_r+0x5f4>
   91334:	aa1703fc 	mov	x28, x23
   91338:	17fffebf 	b	90e34 <_svfiprintf_r+0x134>
   9133c:	9000002a 	adrp	x10, 95000 <pmu_event_descr+0x60>
   91340:	913cc14a 	add	x10, x10, #0xf30
   91344:	7100417f 	cmp	w11, #0x10
   91348:	540005cd 	b.le	91400 <_svfiprintf_r+0x700>
   9134c:	aa1c03e2 	mov	x2, x28
   91350:	d280020e 	mov	x14, #0x10                  	// #16
   91354:	aa1b03fc 	mov	x28, x27
   91358:	2a1903fb 	mov	w27, w25
   9135c:	2a0403f9 	mov	w25, w4
   91360:	f90047f8 	str	x24, [sp, #136]
   91364:	aa0a03f8 	mov	x24, x10
   91368:	b90093ec 	str	w12, [sp, #144]
   9136c:	291637f4 	stp	w20, w13, [sp, #176]
   91370:	2a0b03f4 	mov	w20, w11
   91374:	29170fe8 	stp	w8, w3, [sp, #184]
   91378:	14000004 	b	91388 <_svfiprintf_r+0x688>
   9137c:	51004294 	sub	w20, w20, #0x10
   91380:	7100429f 	cmp	w20, #0x10
   91384:	540002ad 	b.le	913d8 <_svfiprintf_r+0x6d8>
   91388:	91004021 	add	x1, x1, #0x10
   9138c:	11000400 	add	w0, w0, #0x1
   91390:	a9003858 	stp	x24, x14, [x2]
   91394:	91004042 	add	x2, x2, #0x10
   91398:	b900fbe0 	str	w0, [sp, #248]
   9139c:	f90083e1 	str	x1, [sp, #256]
   913a0:	71001c1f 	cmp	w0, #0x7
   913a4:	54fffecd 	b.le	9137c <_svfiprintf_r+0x67c>
   913a8:	9103c3e2 	add	x2, sp, #0xf0
   913ac:	aa1603e1 	mov	x1, x22
   913b0:	aa1303e0 	mov	x0, x19
   913b4:	97fffdd3 	bl	90b00 <__ssprint_r>
   913b8:	35fff940 	cbnz	w0, 912e0 <_svfiprintf_r+0x5e0>
   913bc:	51004294 	sub	w20, w20, #0x10
   913c0:	b940fbe0 	ldr	w0, [sp, #248]
   913c4:	f94083e1 	ldr	x1, [sp, #256]
   913c8:	aa1703e2 	mov	x2, x23
   913cc:	d280020e 	mov	x14, #0x10                  	// #16
   913d0:	7100429f 	cmp	w20, #0x10
   913d4:	54fffdac 	b.gt	91388 <_svfiprintf_r+0x688>
   913d8:	2a1403eb 	mov	w11, w20
   913dc:	aa1803ea 	mov	x10, x24
   913e0:	f94047f8 	ldr	x24, [sp, #136]
   913e4:	2a1903e4 	mov	w4, w25
   913e8:	b94093ec 	ldr	w12, [sp, #144]
   913ec:	2a1b03f9 	mov	w25, w27
   913f0:	295637f4 	ldp	w20, w13, [sp, #176]
   913f4:	aa1c03fb 	mov	x27, x28
   913f8:	29570fe8 	ldp	w8, w3, [sp, #184]
   913fc:	aa0203fc 	mov	x28, x2
   91400:	93407d62 	sxtw	x2, w11
   91404:	11000400 	add	w0, w0, #0x1
   91408:	8b020021 	add	x1, x1, x2
   9140c:	a9000b8a 	stp	x10, x2, [x28]
   91410:	9100439c 	add	x28, x28, #0x10
   91414:	b900fbe0 	str	w0, [sp, #248]
   91418:	f90083e1 	str	x1, [sp, #256]
   9141c:	71001c1f 	cmp	w0, #0x7
   91420:	54ffd5ed 	b.le	90edc <_svfiprintf_r+0x1dc>
   91424:	9103c3e2 	add	x2, sp, #0xf0
   91428:	aa1603e1 	mov	x1, x22
   9142c:	aa1303e0 	mov	x0, x19
   91430:	b9008bec 	str	w12, [sp, #136]
   91434:	b90093e8 	str	w8, [sp, #144]
   91438:	29160fed 	stp	w13, w3, [sp, #176]
   9143c:	b900bbe4 	str	w4, [sp, #184]
   91440:	97fffdb0 	bl	90b00 <__ssprint_r>
   91444:	35fff4e0 	cbnz	w0, 912e0 <_svfiprintf_r+0x5e0>
   91448:	f94083e1 	ldr	x1, [sp, #256]
   9144c:	aa1703fc 	mov	x28, x23
   91450:	b9408bec 	ldr	w12, [sp, #136]
   91454:	b94093e8 	ldr	w8, [sp, #144]
   91458:	29560fed 	ldp	w13, w3, [sp, #176]
   9145c:	b940bbe4 	ldr	w4, [sp, #184]
   91460:	b940fbe0 	ldr	w0, [sp, #248]
   91464:	17fffe9e 	b	90edc <_svfiprintf_r+0x1dc>
   91468:	9103c3e2 	add	x2, sp, #0xf0
   9146c:	aa1603e1 	mov	x1, x22
   91470:	aa1303e0 	mov	x0, x19
   91474:	b9008bed 	str	w13, [sp, #136]
   91478:	b90093e3 	str	w3, [sp, #144]
   9147c:	291613e8 	stp	w8, w4, [sp, #176]
   91480:	97fffda0 	bl	90b00 <__ssprint_r>
   91484:	35fff2e0 	cbnz	w0, 912e0 <_svfiprintf_r+0x5e0>
   91488:	f94083e1 	ldr	x1, [sp, #256]
   9148c:	aa1703fc 	mov	x28, x23
   91490:	b9408bed 	ldr	w13, [sp, #136]
   91494:	b94093e3 	ldr	w3, [sp, #144]
   91498:	295613e8 	ldp	w8, w4, [sp, #176]
   9149c:	b940fbe0 	ldr	w0, [sp, #248]
   914a0:	17fffea7 	b	90f3c <_svfiprintf_r+0x23c>
   914a4:	9000002a 	adrp	x10, 95000 <pmu_event_descr+0x60>
   914a8:	b940fbe0 	ldr	w0, [sp, #248]
   914ac:	913cc14a 	add	x10, x10, #0xf30
   914b0:	7100429f 	cmp	w20, #0x10
   914b4:	5400042d 	b.le	91538 <_svfiprintf_r+0x838>
   914b8:	2a0803fa 	mov	w26, w8
   914bc:	d2800219 	mov	x25, #0x10                  	// #16
   914c0:	f90047f8 	str	x24, [sp, #136]
   914c4:	aa0a03f8 	mov	x24, x10
   914c8:	b900b3e4 	str	w4, [sp, #176]
   914cc:	14000004 	b	914dc <_svfiprintf_r+0x7dc>
   914d0:	51004294 	sub	w20, w20, #0x10
   914d4:	7100429f 	cmp	w20, #0x10
   914d8:	5400028d 	b.le	91528 <_svfiprintf_r+0x828>
   914dc:	91004021 	add	x1, x1, #0x10
   914e0:	11000400 	add	w0, w0, #0x1
   914e4:	a9006798 	stp	x24, x25, [x28]
   914e8:	9100439c 	add	x28, x28, #0x10
   914ec:	b900fbe0 	str	w0, [sp, #248]
   914f0:	f90083e1 	str	x1, [sp, #256]
   914f4:	71001c1f 	cmp	w0, #0x7
   914f8:	54fffecd 	b.le	914d0 <_svfiprintf_r+0x7d0>
   914fc:	9103c3e2 	add	x2, sp, #0xf0
   91500:	aa1603e1 	mov	x1, x22
   91504:	aa1303e0 	mov	x0, x19
   91508:	97fffd7e 	bl	90b00 <__ssprint_r>
   9150c:	35ffeea0 	cbnz	w0, 912e0 <_svfiprintf_r+0x5e0>
   91510:	51004294 	sub	w20, w20, #0x10
   91514:	b940fbe0 	ldr	w0, [sp, #248]
   91518:	f94083e1 	ldr	x1, [sp, #256]
   9151c:	aa1703fc 	mov	x28, x23
   91520:	7100429f 	cmp	w20, #0x10
   91524:	54fffdcc 	b.gt	914dc <_svfiprintf_r+0x7dc>
   91528:	aa1803ea 	mov	x10, x24
   9152c:	b940b3e4 	ldr	w4, [sp, #176]
   91530:	f94047f8 	ldr	x24, [sp, #136]
   91534:	2a1a03e8 	mov	w8, w26
   91538:	93407e83 	sxtw	x3, w20
   9153c:	11000400 	add	w0, w0, #0x1
   91540:	8b030021 	add	x1, x1, x3
   91544:	a9000f8a 	stp	x10, x3, [x28]
   91548:	b900fbe0 	str	w0, [sp, #248]
   9154c:	f90083e1 	str	x1, [sp, #256]
   91550:	71001c1f 	cmp	w0, #0x7
   91554:	54ffd18d 	b.le	90f84 <_svfiprintf_r+0x284>
   91558:	9103c3e2 	add	x2, sp, #0xf0
   9155c:	aa1603e1 	mov	x1, x22
   91560:	aa1303e0 	mov	x0, x19
   91564:	b9008be8 	str	w8, [sp, #136]
   91568:	b900b3e4 	str	w4, [sp, #176]
   9156c:	97fffd65 	bl	90b00 <__ssprint_r>
   91570:	35ffeb80 	cbnz	w0, 912e0 <_svfiprintf_r+0x5e0>
   91574:	f94083e1 	ldr	x1, [sp, #256]
   91578:	b9408be8 	ldr	w8, [sp, #136]
   9157c:	b940b3e4 	ldr	w4, [sp, #176]
   91580:	17fffe81 	b	90f84 <_svfiprintf_r+0x284>
   91584:	b94067e1 	ldr	w1, [sp, #100]
   91588:	2a1903e8 	mov	w8, w25
   9158c:	2a1a03e3 	mov	w3, w26
   91590:	37f84a01 	tbnz	w1, #31, 91ed0 <_svfiprintf_r+0x11d0>
   91594:	91003f01 	add	x1, x24, #0xf
   91598:	927df021 	and	x1, x1, #0xfffffffffffffff8
   9159c:	f90047e1 	str	x1, [sp, #136]
   915a0:	f940031a 	ldr	x26, [x24]
   915a4:	39033fff 	strb	wzr, [sp, #207]
   915a8:	b4004b7a 	cbz	x26, 91f14 <_svfiprintf_r+0x1214>
   915ac:	71014c1f 	cmp	w0, #0x53
   915b0:	54000040 	b.eq	915b8 <_svfiprintf_r+0x8b8>  // b.none
   915b4:	36203354 	tbz	w20, #4, 91c1c <_svfiprintf_r+0xf1c>
   915b8:	910383e0 	add	x0, sp, #0xe0
   915bc:	d2800102 	mov	x2, #0x8                   	// #8
   915c0:	52800001 	mov	w1, #0x0                   	// #0
   915c4:	b9006be8 	str	w8, [sp, #104]
   915c8:	b900b3e3 	str	w3, [sp, #176]
   915cc:	f90077fa 	str	x26, [sp, #232]
   915d0:	97ffeffc 	bl	8d5c0 <memset>
   915d4:	b940b3e3 	ldr	w3, [sp, #176]
   915d8:	b9406be8 	ldr	w8, [sp, #104]
   915dc:	3100047f 	cmn	w3, #0x1
   915e0:	54005040 	b.eq	91fe8 <_svfiprintf_r+0x12e8>  // b.none
   915e4:	aa1603e0 	mov	x0, x22
   915e8:	52800019 	mov	w25, #0x0                   	// #0
   915ec:	d2800018 	mov	x24, #0x0                   	// #0
   915f0:	2a1903f6 	mov	w22, w25
   915f4:	aa0003f9 	mov	x25, x0
   915f8:	b9006bf4 	str	w20, [sp, #104]
   915fc:	2a0303f4 	mov	w20, w3
   91600:	b900b3e8 	str	w8, [sp, #176]
   91604:	1400000d 	b	91638 <_svfiprintf_r+0x938>
   91608:	910383e3 	add	x3, sp, #0xe0
   9160c:	910423e1 	add	x1, sp, #0x108
   91610:	aa1303e0 	mov	x0, x19
   91614:	97ffe9e7 	bl	8bdb0 <_wcrtomb_r>
   91618:	3100041f 	cmn	w0, #0x1
   9161c:	54006500 	b.eq	922bc <_svfiprintf_r+0x15bc>  // b.none
   91620:	0b0002c0 	add	w0, w22, w0
   91624:	6b14001f 	cmp	w0, w20
   91628:	540000ec 	b.gt	91644 <_svfiprintf_r+0x944>
   9162c:	91001318 	add	x24, x24, #0x4
   91630:	540067c0 	b.eq	92328 <_svfiprintf_r+0x1628>  // b.none
   91634:	2a0003f6 	mov	w22, w0
   91638:	f94077e0 	ldr	x0, [sp, #232]
   9163c:	b8786802 	ldr	w2, [x0, x24]
   91640:	35fffe42 	cbnz	w2, 91608 <_svfiprintf_r+0x908>
   91644:	aa1903e0 	mov	x0, x25
   91648:	b9406bf4 	ldr	w20, [sp, #104]
   9164c:	b940b3e8 	ldr	w8, [sp, #176]
   91650:	2a1603f9 	mov	w25, w22
   91654:	aa0003f6 	mov	x22, x0
   91658:	34004e39 	cbz	w25, 9201c <_svfiprintf_r+0x131c>
   9165c:	71018f3f 	cmp	w25, #0x63
   91660:	5400564c 	b.gt	92128 <_svfiprintf_r+0x1428>
   91664:	910423fa 	add	x26, sp, #0x108
   91668:	f90037ff 	str	xzr, [sp, #104]
   9166c:	93407f38 	sxtw	x24, w25
   91670:	d2800102 	mov	x2, #0x8                   	// #8
   91674:	52800001 	mov	w1, #0x0                   	// #0
   91678:	910383e0 	add	x0, sp, #0xe0
   9167c:	b900b3e8 	str	w8, [sp, #176]
   91680:	97ffefd0 	bl	8d5c0 <memset>
   91684:	910383e4 	add	x4, sp, #0xe0
   91688:	aa1803e3 	mov	x3, x24
   9168c:	9103a3e2 	add	x2, sp, #0xe8
   91690:	aa1a03e1 	mov	x1, x26
   91694:	aa1303e0 	mov	x0, x19
   91698:	97fff04a 	bl	8d7c0 <_wcsrtombs_r>
   9169c:	b940b3e8 	ldr	w8, [sp, #176]
   916a0:	eb00031f 	cmp	x24, x0
   916a4:	54007ce1 	b.ne	92640 <_svfiprintf_r+0x1940>  // b.any
   916a8:	7100033f 	cmp	w25, #0x0
   916ac:	52800003 	mov	w3, #0x0                   	// #0
   916b0:	f94047f8 	ldr	x24, [sp, #136]
   916b4:	1a9fa324 	csel	w4, w25, wzr, ge	// ge = tcont
   916b8:	3839cb5f 	strb	wzr, [x26, w25, sxtw]
   916bc:	14000050 	b	917fc <_svfiprintf_r+0xafc>
   916c0:	2a1903e8 	mov	w8, w25
   916c4:	71010c1f 	cmp	w0, #0x43
   916c8:	540001c0 	b.eq	91700 <_svfiprintf_r+0xa00>  // b.none
   916cc:	372001b4 	tbnz	w20, #4, 91700 <_svfiprintf_r+0xa00>
   916d0:	b94067e0 	ldr	w0, [sp, #100]
   916d4:	37f84b80 	tbnz	w0, #31, 92044 <_svfiprintf_r+0x1344>
   916d8:	91002f01 	add	x1, x24, #0xb
   916dc:	aa1803e0 	mov	x0, x24
   916e0:	927df038 	and	x24, x1, #0xfffffffffffffff8
   916e4:	b9400000 	ldr	w0, [x0]
   916e8:	52800024 	mov	w4, #0x1                   	// #1
   916ec:	910423fa 	add	x26, sp, #0x108
   916f0:	2a0403f9 	mov	w25, w4
   916f4:	39033fff 	strb	wzr, [sp, #207]
   916f8:	390423e0 	strb	w0, [sp, #264]
   916fc:	17fffdea 	b	90ea4 <_svfiprintf_r+0x1a4>
   91700:	9103a3e0 	add	x0, sp, #0xe8
   91704:	d2800102 	mov	x2, #0x8                   	// #8
   91708:	52800001 	mov	w1, #0x0                   	// #0
   9170c:	b9006be8 	str	w8, [sp, #104]
   91710:	97ffefac 	bl	8d5c0 <memset>
   91714:	294ca3e0 	ldp	w0, w8, [sp, #100]
   91718:	37f82c80 	tbnz	w0, #31, 91ca8 <_svfiprintf_r+0xfa8>
   9171c:	91002f01 	add	x1, x24, #0xb
   91720:	aa1803e0 	mov	x0, x24
   91724:	927df038 	and	x24, x1, #0xfffffffffffffff8
   91728:	b9400002 	ldr	w2, [x0]
   9172c:	910423fa 	add	x26, sp, #0x108
   91730:	9103a3e3 	add	x3, sp, #0xe8
   91734:	aa1a03e1 	mov	x1, x26
   91738:	aa1303e0 	mov	x0, x19
   9173c:	b9006be8 	str	w8, [sp, #104]
   91740:	97ffe99c 	bl	8bdb0 <_wcrtomb_r>
   91744:	2a0003f9 	mov	w25, w0
   91748:	b9406be8 	ldr	w8, [sp, #104]
   9174c:	3100041f 	cmn	w0, #0x1
   91750:	54005b80 	b.eq	922c0 <_svfiprintf_r+0x15c0>  // b.none
   91754:	7100001f 	cmp	w0, #0x0
   91758:	39033fff 	strb	wzr, [sp, #207]
   9175c:	1a9fa004 	csel	w4, w0, wzr, ge	// ge = tcont
   91760:	17fffdd1 	b	90ea4 <_svfiprintf_r+0x1a4>
   91764:	2a1903e8 	mov	w8, w25
   91768:	2a1a03e3 	mov	w3, w26
   9176c:	321c0294 	orr	w20, w20, #0x10
   91770:	b94067e0 	ldr	w0, [sp, #100]
   91774:	37280134 	tbnz	w20, #5, 91798 <_svfiprintf_r+0xa98>
   91778:	37200114 	tbnz	w20, #4, 91798 <_svfiprintf_r+0xa98>
   9177c:	36303ff4 	tbz	w20, #6, 91f78 <_svfiprintf_r+0x1278>
   91780:	37f85660 	tbnz	w0, #31, 9224c <_svfiprintf_r+0x154c>
   91784:	aa1803e0 	mov	x0, x24
   91788:	91002f01 	add	x1, x24, #0xb
   9178c:	927df038 	and	x24, x1, #0xfffffffffffffff8
   91790:	79400001 	ldrh	w1, [x0]
   91794:	14000006 	b	917ac <_svfiprintf_r+0xaac>
   91798:	37f82140 	tbnz	w0, #31, 91bc0 <_svfiprintf_r+0xec0>
   9179c:	91003f01 	add	x1, x24, #0xf
   917a0:	aa1803e0 	mov	x0, x24
   917a4:	927df038 	and	x24, x1, #0xfffffffffffffff8
   917a8:	f9400001 	ldr	x1, [x0]
   917ac:	12157a84 	and	w4, w20, #0xfffffbff
   917b0:	52800000 	mov	w0, #0x0                   	// #0
   917b4:	52800002 	mov	w2, #0x0                   	// #0
   917b8:	39033fe2 	strb	w2, [sp, #207]
   917bc:	3100047f 	cmn	w3, #0x1
   917c0:	54000c40 	b.eq	91948 <_svfiprintf_r+0xc48>  // b.none
   917c4:	f100003f 	cmp	x1, #0x0
   917c8:	12187894 	and	w20, w4, #0xffffff7f
   917cc:	7a400860 	ccmp	w3, #0x0, #0x0, eq	// eq = none
   917d0:	54001d01 	b.ne	91b70 <_svfiprintf_r+0xe70>  // b.any
   917d4:	35000960 	cbnz	w0, 91900 <_svfiprintf_r+0xc00>
   917d8:	12000099 	and	w25, w4, #0x1
   917dc:	36001c44 	tbz	w4, #0, 91b64 <_svfiprintf_r+0xe64>
   917e0:	9105affa 	add	x26, sp, #0x16b
   917e4:	52800600 	mov	w0, #0x30                  	// #48
   917e8:	52800003 	mov	w3, #0x0                   	// #0
   917ec:	3905afe0 	strb	w0, [sp, #363]
   917f0:	6b19007f 	cmp	w3, w25
   917f4:	f90037ff 	str	xzr, [sp, #104]
   917f8:	1a99a064 	csel	w4, w3, w25, ge	// ge = tcont
   917fc:	39433fe0 	ldrb	w0, [sp, #207]
   91800:	7100001f 	cmp	w0, #0x0
   91804:	1a840484 	cinc	w4, w4, ne	// ne = any
   91808:	17fffdaa 	b	90eb0 <_svfiprintf_r+0x1b0>
   9180c:	39400360 	ldrb	w0, [x27]
   91810:	32190294 	orr	w20, w20, #0x80
   91814:	17fffd94 	b	90e64 <_svfiprintf_r+0x164>
   91818:	aa1b03e2 	mov	x2, x27
   9181c:	38401440 	ldrb	w0, [x2], #1
   91820:	7100a81f 	cmp	w0, #0x2a
   91824:	54006ba0 	b.eq	92598 <_svfiprintf_r+0x1898>  // b.none
   91828:	5100c001 	sub	w1, w0, #0x30
   9182c:	aa0203fb 	mov	x27, x2
   91830:	5280001a 	mov	w26, #0x0                   	// #0
   91834:	7100243f 	cmp	w1, #0x9
   91838:	54ffb188 	b.hi	90e68 <_svfiprintf_r+0x168>  // b.pmore
   9183c:	d503201f 	nop
   91840:	38401760 	ldrb	w0, [x27], #1
   91844:	0b1a0b43 	add	w3, w26, w26, lsl #2
   91848:	0b03043a 	add	w26, w1, w3, lsl #1
   9184c:	5100c001 	sub	w1, w0, #0x30
   91850:	7100243f 	cmp	w1, #0x9
   91854:	54ffff69 	b.ls	91840 <_svfiprintf_r+0xb40>  // b.plast
   91858:	17fffd84 	b	90e68 <_svfiprintf_r+0x168>
   9185c:	2a1903e8 	mov	w8, w25
   91860:	2a1a03e3 	mov	w3, w26
   91864:	321c0284 	orr	w4, w20, #0x10
   91868:	b94067e0 	ldr	w0, [sp, #100]
   9186c:	37280144 	tbnz	w4, #5, 91894 <_svfiprintf_r+0xb94>
   91870:	37200124 	tbnz	w4, #4, 91894 <_svfiprintf_r+0xb94>
   91874:	36303904 	tbz	w4, #6, 91f94 <_svfiprintf_r+0x1294>
   91878:	37f84fe0 	tbnz	w0, #31, 92274 <_svfiprintf_r+0x1574>
   9187c:	91002f01 	add	x1, x24, #0xb
   91880:	aa1803e0 	mov	x0, x24
   91884:	927df038 	and	x24, x1, #0xfffffffffffffff8
   91888:	79400001 	ldrh	w1, [x0]
   9188c:	52800020 	mov	w0, #0x1                   	// #1
   91890:	17ffffc9 	b	917b4 <_svfiprintf_r+0xab4>
   91894:	37f81840 	tbnz	w0, #31, 91b9c <_svfiprintf_r+0xe9c>
   91898:	91003f01 	add	x1, x24, #0xf
   9189c:	aa1803e0 	mov	x0, x24
   918a0:	927df038 	and	x24, x1, #0xfffffffffffffff8
   918a4:	f9400001 	ldr	x1, [x0]
   918a8:	52800020 	mov	w0, #0x1                   	// #1
   918ac:	17ffffc2 	b	917b4 <_svfiprintf_r+0xab4>
   918b0:	2a1903e8 	mov	w8, w25
   918b4:	2a1a03e3 	mov	w3, w26
   918b8:	321c0294 	orr	w20, w20, #0x10
   918bc:	b94067e0 	ldr	w0, [sp, #100]
   918c0:	37280294 	tbnz	w20, #5, 91910 <_svfiprintf_r+0xc10>
   918c4:	37200274 	tbnz	w20, #4, 91910 <_svfiprintf_r+0xc10>
   918c8:	36303494 	tbz	w20, #6, 91f58 <_svfiprintf_r+0x1258>
   918cc:	37f84e60 	tbnz	w0, #31, 92298 <_svfiprintf_r+0x1598>
   918d0:	91002f01 	add	x1, x24, #0xb
   918d4:	aa1803e0 	mov	x0, x24
   918d8:	927df038 	and	x24, x1, #0xfffffffffffffff8
   918dc:	79800001 	ldrsh	x1, [x0]
   918e0:	aa0103e0 	mov	x0, x1
   918e4:	b7f80240 	tbnz	x0, #63, 9192c <_svfiprintf_r+0xc2c>
   918e8:	3100047f 	cmn	w3, #0x1
   918ec:	54001080 	b.eq	91afc <_svfiprintf_r+0xdfc>  // b.none
   918f0:	7100007f 	cmp	w3, #0x0
   918f4:	12187a94 	and	w20, w20, #0xffffff7f
   918f8:	fa400820 	ccmp	x1, #0x0, #0x0, eq	// eq = none
   918fc:	54001001 	b.ne	91afc <_svfiprintf_r+0xdfc>  // b.any
   91900:	9105b3fa 	add	x26, sp, #0x16c
   91904:	52800003 	mov	w3, #0x0                   	// #0
   91908:	52800019 	mov	w25, #0x0                   	// #0
   9190c:	17ffffb9 	b	917f0 <_svfiprintf_r+0xaf0>
   91910:	37f81340 	tbnz	w0, #31, 91b78 <_svfiprintf_r+0xe78>
   91914:	91003f01 	add	x1, x24, #0xf
   91918:	aa1803e0 	mov	x0, x24
   9191c:	927df038 	and	x24, x1, #0xfffffffffffffff8
   91920:	f9400000 	ldr	x0, [x0]
   91924:	aa0003e1 	mov	x1, x0
   91928:	b6fffe00 	tbz	x0, #63, 918e8 <_svfiprintf_r+0xbe8>
   9192c:	528005a2 	mov	w2, #0x2d                  	// #45
   91930:	39033fe2 	strb	w2, [sp, #207]
   91934:	cb0103e1 	neg	x1, x1
   91938:	2a1403e4 	mov	w4, w20
   9193c:	52800020 	mov	w0, #0x1                   	// #1
   91940:	3100047f 	cmn	w3, #0x1
   91944:	54fff401 	b.ne	917c4 <_svfiprintf_r+0xac4>  // b.any
   91948:	7100041f 	cmp	w0, #0x1
   9194c:	54000da0 	b.eq	91b00 <_svfiprintf_r+0xe00>  // b.none
   91950:	9105b3f9 	add	x25, sp, #0x16c
   91954:	aa1903fa 	mov	x26, x25
   91958:	7100081f 	cmp	w0, #0x2
   9195c:	54000e21 	b.ne	91b20 <_svfiprintf_r+0xe20>  // b.any
   91960:	f94043e2 	ldr	x2, [sp, #128]
   91964:	d503201f 	nop
   91968:	92400c20 	and	x0, x1, #0xf
   9196c:	d344fc21 	lsr	x1, x1, #4
   91970:	38606840 	ldrb	w0, [x2, x0]
   91974:	381fff40 	strb	w0, [x26, #-1]!
   91978:	b5ffff81 	cbnz	x1, 91968 <_svfiprintf_r+0xc68>
   9197c:	4b1a0339 	sub	w25, w25, w26
   91980:	2a0403f4 	mov	w20, w4
   91984:	17ffff9b 	b	917f0 <_svfiprintf_r+0xaf0>
   91988:	b94067e0 	ldr	w0, [sp, #100]
   9198c:	37280194 	tbnz	w20, #5, 919bc <_svfiprintf_r+0xcbc>
   91990:	37200174 	tbnz	w20, #4, 919bc <_svfiprintf_r+0xcbc>
   91994:	37303ad4 	tbnz	w20, #6, 920ec <_svfiprintf_r+0x13ec>
   91998:	36484fb4 	tbz	w20, #9, 9238c <_svfiprintf_r+0x168c>
   9199c:	37f858e0 	tbnz	w0, #31, 924b8 <_svfiprintf_r+0x17b8>
   919a0:	91003f01 	add	x1, x24, #0xf
   919a4:	aa1803e0 	mov	x0, x24
   919a8:	927df038 	and	x24, x1, #0xfffffffffffffff8
   919ac:	f9400000 	ldr	x0, [x0]
   919b0:	394183e1 	ldrb	w1, [sp, #96]
   919b4:	39000001 	strb	w1, [x0]
   919b8:	17fffcf6 	b	90d90 <_svfiprintf_r+0x90>
   919bc:	37f811e0 	tbnz	w0, #31, 91bf8 <_svfiprintf_r+0xef8>
   919c0:	91003f01 	add	x1, x24, #0xf
   919c4:	aa1803e0 	mov	x0, x24
   919c8:	927df038 	and	x24, x1, #0xfffffffffffffff8
   919cc:	f9400000 	ldr	x0, [x0]
   919d0:	b98063e1 	ldrsw	x1, [sp, #96]
   919d4:	f9000001 	str	x1, [x0]
   919d8:	17fffcee 	b	90d90 <_svfiprintf_r+0x90>
   919dc:	39400360 	ldrb	w0, [x27]
   919e0:	7101b01f 	cmp	w0, #0x6c
   919e4:	54002900 	b.eq	91f04 <_svfiprintf_r+0x1204>  // b.none
   919e8:	321c0294 	orr	w20, w20, #0x10
   919ec:	17fffd1e 	b	90e64 <_svfiprintf_r+0x164>
   919f0:	39400360 	ldrb	w0, [x27]
   919f4:	7101a01f 	cmp	w0, #0x68
   919f8:	540027e0 	b.eq	91ef4 <_svfiprintf_r+0x11f4>  // b.none
   919fc:	321a0294 	orr	w20, w20, #0x40
   91a00:	17fffd19 	b	90e64 <_svfiprintf_r+0x164>
   91a04:	39400360 	ldrb	w0, [x27]
   91a08:	321b0294 	orr	w20, w20, #0x20
   91a0c:	17fffd16 	b	90e64 <_svfiprintf_r+0x164>
   91a10:	b94067e0 	ldr	w0, [sp, #100]
   91a14:	2a1903e8 	mov	w8, w25
   91a18:	2a1a03e3 	mov	w3, w26
   91a1c:	37f82480 	tbnz	w0, #31, 91eac <_svfiprintf_r+0x11ac>
   91a20:	91003f01 	add	x1, x24, #0xf
   91a24:	aa1803e0 	mov	x0, x24
   91a28:	927df038 	and	x24, x1, #0xfffffffffffffff8
   91a2c:	f9400001 	ldr	x1, [x0]
   91a30:	528f0600 	mov	w0, #0x7830                	// #30768
   91a34:	90000022 	adrp	x2, 95000 <pmu_event_descr+0x60>
   91a38:	321f0284 	orr	w4, w20, #0x2
   91a3c:	9117a042 	add	x2, x2, #0x5e8
   91a40:	f90043e2 	str	x2, [sp, #128]
   91a44:	7901a3e0 	strh	w0, [sp, #208]
   91a48:	52800040 	mov	w0, #0x2                   	// #2
   91a4c:	17ffff5a 	b	917b4 <_svfiprintf_r+0xab4>
   91a50:	52800560 	mov	w0, #0x2b                  	// #43
   91a54:	39033fe0 	strb	w0, [sp, #207]
   91a58:	39400360 	ldrb	w0, [x27]
   91a5c:	17fffd02 	b	90e64 <_svfiprintf_r+0x164>
   91a60:	b94067e0 	ldr	w0, [sp, #100]
   91a64:	37f82140 	tbnz	w0, #31, 91e8c <_svfiprintf_r+0x118c>
   91a68:	91002f00 	add	x0, x24, #0xb
   91a6c:	927df000 	and	x0, x0, #0xfffffffffffffff8
   91a70:	b9400319 	ldr	w25, [x24]
   91a74:	37ffaf79 	tbnz	w25, #31, 91060 <_svfiprintf_r+0x360>
   91a78:	aa0003f8 	mov	x24, x0
   91a7c:	39400360 	ldrb	w0, [x27]
   91a80:	17fffcf9 	b	90e64 <_svfiprintf_r+0x164>
   91a84:	aa1303e0 	mov	x0, x19
   91a88:	97ffec72 	bl	8cc50 <_localeconv_r>
   91a8c:	f9400400 	ldr	x0, [x0, #8]
   91a90:	f90057e0 	str	x0, [sp, #168]
   91a94:	97ffc3bb 	bl	82980 <strlen>
   91a98:	aa0003e1 	mov	x1, x0
   91a9c:	aa1303e0 	mov	x0, x19
   91aa0:	f9004fe1 	str	x1, [sp, #152]
   91aa4:	97ffec6b 	bl	8cc50 <_localeconv_r>
   91aa8:	f9404fe1 	ldr	x1, [sp, #152]
   91aac:	f9400800 	ldr	x0, [x0, #16]
   91ab0:	f90053e0 	str	x0, [sp, #160]
   91ab4:	f100003f 	cmp	x1, #0x0
   91ab8:	fa401804 	ccmp	x0, #0x0, #0x4, ne	// ne = any
   91abc:	54000940 	b.eq	91be4 <_svfiprintf_r+0xee4>  // b.none
   91ac0:	39400000 	ldrb	w0, [x0]
   91ac4:	32160281 	orr	w1, w20, #0x400
   91ac8:	7100001f 	cmp	w0, #0x0
   91acc:	39400360 	ldrb	w0, [x27]
   91ad0:	1a941034 	csel	w20, w1, w20, ne	// ne = any
   91ad4:	17fffce4 	b	90e64 <_svfiprintf_r+0x164>
   91ad8:	39400360 	ldrb	w0, [x27]
   91adc:	32000294 	orr	w20, w20, #0x1
   91ae0:	17fffce1 	b	90e64 <_svfiprintf_r+0x164>
   91ae4:	39433fe1 	ldrb	w1, [sp, #207]
   91ae8:	39400360 	ldrb	w0, [x27]
   91aec:	35ff9bc1 	cbnz	w1, 90e64 <_svfiprintf_r+0x164>
   91af0:	52800401 	mov	w1, #0x20                  	// #32
   91af4:	39033fe1 	strb	w1, [sp, #207]
   91af8:	17fffcdb 	b	90e64 <_svfiprintf_r+0x164>
   91afc:	2a1403e4 	mov	w4, w20
   91b00:	f100243f 	cmp	x1, #0x9
   91b04:	54001708 	b.hi	91de4 <_svfiprintf_r+0x10e4>  // b.pmore
   91b08:	1100c021 	add	w1, w1, #0x30
   91b0c:	2a0403f4 	mov	w20, w4
   91b10:	9105affa 	add	x26, sp, #0x16b
   91b14:	52800039 	mov	w25, #0x1                   	// #1
   91b18:	3905afe1 	strb	w1, [sp, #363]
   91b1c:	17ffff35 	b	917f0 <_svfiprintf_r+0xaf0>
   91b20:	12000820 	and	w0, w1, #0x7
   91b24:	aa1a03e2 	mov	x2, x26
   91b28:	1100c000 	add	w0, w0, #0x30
   91b2c:	381fff40 	strb	w0, [x26, #-1]!
   91b30:	d343fc21 	lsr	x1, x1, #3
   91b34:	b5ffff61 	cbnz	x1, 91b20 <_svfiprintf_r+0xe20>
   91b38:	7100c01f 	cmp	w0, #0x30
   91b3c:	1a9f07e0 	cset	w0, ne	// ne = any
   91b40:	6a00009f 	tst	w4, w0
   91b44:	54fff1c0 	b.eq	9197c <_svfiprintf_r+0xc7c>  // b.none
   91b48:	d1000842 	sub	x2, x2, #0x2
   91b4c:	52800600 	mov	w0, #0x30                  	// #48
   91b50:	2a0403f4 	mov	w20, w4
   91b54:	4b020339 	sub	w25, w25, w2
   91b58:	381ff340 	sturb	w0, [x26, #-1]
   91b5c:	aa0203fa 	mov	x26, x2
   91b60:	17ffff24 	b	917f0 <_svfiprintf_r+0xaf0>
   91b64:	9105b3fa 	add	x26, sp, #0x16c
   91b68:	52800003 	mov	w3, #0x0                   	// #0
   91b6c:	17ffff21 	b	917f0 <_svfiprintf_r+0xaf0>
   91b70:	2a1403e4 	mov	w4, w20
   91b74:	17ffff75 	b	91948 <_svfiprintf_r+0xc48>
   91b78:	b94067e0 	ldr	w0, [sp, #100]
   91b7c:	11002001 	add	w1, w0, #0x8
   91b80:	7100003f 	cmp	w1, #0x0
   91b84:	5400088d 	b.le	91c94 <_svfiprintf_r+0xf94>
   91b88:	91003f02 	add	x2, x24, #0xf
   91b8c:	aa1803e0 	mov	x0, x24
   91b90:	927df058 	and	x24, x2, #0xfffffffffffffff8
   91b94:	b90067e1 	str	w1, [sp, #100]
   91b98:	17ffff62 	b	91920 <_svfiprintf_r+0xc20>
   91b9c:	b94067e0 	ldr	w0, [sp, #100]
   91ba0:	11002001 	add	w1, w0, #0x8
   91ba4:	7100003f 	cmp	w1, #0x0
   91ba8:	540006cd 	b.le	91c80 <_svfiprintf_r+0xf80>
   91bac:	91003f02 	add	x2, x24, #0xf
   91bb0:	aa1803e0 	mov	x0, x24
   91bb4:	927df058 	and	x24, x2, #0xfffffffffffffff8
   91bb8:	b90067e1 	str	w1, [sp, #100]
   91bbc:	17ffff3a 	b	918a4 <_svfiprintf_r+0xba4>
   91bc0:	b94067e0 	ldr	w0, [sp, #100]
   91bc4:	11002001 	add	w1, w0, #0x8
   91bc8:	7100003f 	cmp	w1, #0x0
   91bcc:	5400050d 	b.le	91c6c <_svfiprintf_r+0xf6c>
   91bd0:	91003f02 	add	x2, x24, #0xf
   91bd4:	aa1803e0 	mov	x0, x24
   91bd8:	927df058 	and	x24, x2, #0xfffffffffffffff8
   91bdc:	b90067e1 	str	w1, [sp, #100]
   91be0:	17fffef2 	b	917a8 <_svfiprintf_r+0xaa8>
   91be4:	39400360 	ldrb	w0, [x27]
   91be8:	17fffc9f 	b	90e64 <_svfiprintf_r+0x164>
   91bec:	2a1903e8 	mov	w8, w25
   91bf0:	2a1a03e3 	mov	w3, w26
   91bf4:	17ffff32 	b	918bc <_svfiprintf_r+0xbbc>
   91bf8:	b94067e0 	ldr	w0, [sp, #100]
   91bfc:	11002001 	add	w1, w0, #0x8
   91c00:	7100003f 	cmp	w1, #0x0
   91c04:	54002e8d 	b.le	921d4 <_svfiprintf_r+0x14d4>
   91c08:	91003f02 	add	x2, x24, #0xf
   91c0c:	aa1803e0 	mov	x0, x24
   91c10:	927df058 	and	x24, x2, #0xfffffffffffffff8
   91c14:	b90067e1 	str	w1, [sp, #100]
   91c18:	17ffff6d 	b	919cc <_svfiprintf_r+0xccc>
   91c1c:	3100047f 	cmn	w3, #0x1
   91c20:	54002e40 	b.eq	921e8 <_svfiprintf_r+0x14e8>  // b.none
   91c24:	93407c62 	sxtw	x2, w3
   91c28:	aa1a03e0 	mov	x0, x26
   91c2c:	52800001 	mov	w1, #0x0                   	// #0
   91c30:	b90093e8 	str	w8, [sp, #144]
   91c34:	b900b3e3 	str	w3, [sp, #176]
   91c38:	97ffec62 	bl	8cdc0 <memchr>
   91c3c:	f90037e0 	str	x0, [sp, #104]
   91c40:	b94093e8 	ldr	w8, [sp, #144]
   91c44:	b940b3e3 	ldr	w3, [sp, #176]
   91c48:	b40028e0 	cbz	x0, 92164 <_svfiprintf_r+0x1464>
   91c4c:	cb1a0004 	sub	x4, x0, x26
   91c50:	52800003 	mov	w3, #0x0                   	// #0
   91c54:	7100009f 	cmp	w4, #0x0
   91c58:	2a0403f9 	mov	w25, w4
   91c5c:	f94047f8 	ldr	x24, [sp, #136]
   91c60:	1a9fa084 	csel	w4, w4, wzr, ge	// ge = tcont
   91c64:	f90037ff 	str	xzr, [sp, #104]
   91c68:	17fffee5 	b	917fc <_svfiprintf_r+0xafc>
   91c6c:	f9403fe2 	ldr	x2, [sp, #120]
   91c70:	b94067e0 	ldr	w0, [sp, #100]
   91c74:	b90067e1 	str	w1, [sp, #100]
   91c78:	8b20c040 	add	x0, x2, w0, sxtw
   91c7c:	17fffecb 	b	917a8 <_svfiprintf_r+0xaa8>
   91c80:	f9403fe2 	ldr	x2, [sp, #120]
   91c84:	b94067e0 	ldr	w0, [sp, #100]
   91c88:	b90067e1 	str	w1, [sp, #100]
   91c8c:	8b20c040 	add	x0, x2, w0, sxtw
   91c90:	17ffff05 	b	918a4 <_svfiprintf_r+0xba4>
   91c94:	f9403fe2 	ldr	x2, [sp, #120]
   91c98:	b94067e0 	ldr	w0, [sp, #100]
   91c9c:	b90067e1 	str	w1, [sp, #100]
   91ca0:	8b20c040 	add	x0, x2, w0, sxtw
   91ca4:	17ffff1f 	b	91920 <_svfiprintf_r+0xc20>
   91ca8:	b94067e0 	ldr	w0, [sp, #100]
   91cac:	11002001 	add	w1, w0, #0x8
   91cb0:	7100003f 	cmp	w1, #0x0
   91cb4:	54002b0d 	b.le	92214 <_svfiprintf_r+0x1514>
   91cb8:	91002f02 	add	x2, x24, #0xb
   91cbc:	aa1803e0 	mov	x0, x24
   91cc0:	927df058 	and	x24, x2, #0xfffffffffffffff8
   91cc4:	b90067e1 	str	w1, [sp, #100]
   91cc8:	17fffe98 	b	91728 <_svfiprintf_r+0xa28>
   91ccc:	aa1303e0 	mov	x0, x19
   91cd0:	d2800801 	mov	x1, #0x40                  	// #64
   91cd4:	97ffe62b 	bl	8b580 <_malloc_r>
   91cd8:	f90002c0 	str	x0, [x22]
   91cdc:	f9000ec0 	str	x0, [x22, #24]
   91ce0:	b4004b80 	cbz	x0, 92650 <_svfiprintf_r+0x1950>
   91ce4:	a9046bf9 	stp	x25, x26, [sp, #64]
   91ce8:	52800800 	mov	w0, #0x40                  	// #64
   91cec:	b90022c0 	str	w0, [x22, #32]
   91cf0:	17fffc1a 	b	90d58 <_svfiprintf_r+0x58>
   91cf4:	90000021 	adrp	x1, 95000 <pmu_event_descr+0x60>
   91cf8:	91180021 	add	x1, x1, #0x600
   91cfc:	f90043e1 	str	x1, [sp, #128]
   91d00:	2a1903e8 	mov	w8, w25
   91d04:	b94067e1 	ldr	w1, [sp, #100]
   91d08:	2a1a03e3 	mov	w3, w26
   91d0c:	37280374 	tbnz	w20, #5, 91d78 <_svfiprintf_r+0x1078>
   91d10:	37200354 	tbnz	w20, #4, 91d78 <_svfiprintf_r+0x1078>
   91d14:	36301514 	tbz	w20, #6, 91fb4 <_svfiprintf_r+0x12b4>
   91d18:	37f82881 	tbnz	w1, #31, 92228 <_svfiprintf_r+0x1528>
   91d1c:	91002f02 	add	x2, x24, #0xb
   91d20:	aa1803e1 	mov	x1, x24
   91d24:	927df058 	and	x24, x2, #0xfffffffffffffff8
   91d28:	79400021 	ldrh	w1, [x1]
   91d2c:	f100003f 	cmp	x1, #0x0
   91d30:	1a9f07e2 	cset	w2, ne	// ne = any
   91d34:	6a02029f 	tst	w20, w2
   91d38:	54000321 	b.ne	91d9c <_svfiprintf_r+0x109c>  // b.any
   91d3c:	d503201f 	nop
   91d40:	12157a84 	and	w4, w20, #0xfffffbff
   91d44:	52800040 	mov	w0, #0x2                   	// #2
   91d48:	17fffe9b 	b	917b4 <_svfiprintf_r+0xab4>
   91d4c:	2a1903e8 	mov	w8, w25
   91d50:	2a1a03e3 	mov	w3, w26
   91d54:	2a1403e4 	mov	w4, w20
   91d58:	17fffec4 	b	91868 <_svfiprintf_r+0xb68>
   91d5c:	90000021 	adrp	x1, 95000 <pmu_event_descr+0x60>
   91d60:	9117a021 	add	x1, x1, #0x5e8
   91d64:	f90043e1 	str	x1, [sp, #128]
   91d68:	2a1903e8 	mov	w8, w25
   91d6c:	b94067e1 	ldr	w1, [sp, #100]
   91d70:	2a1a03e3 	mov	w3, w26
   91d74:	362ffcf4 	tbz	w20, #5, 91d10 <_svfiprintf_r+0x1010>
   91d78:	37f80221 	tbnz	w1, #31, 91dbc <_svfiprintf_r+0x10bc>
   91d7c:	aa1803e1 	mov	x1, x24
   91d80:	91003f02 	add	x2, x24, #0xf
   91d84:	927df058 	and	x24, x2, #0xfffffffffffffff8
   91d88:	f9400021 	ldr	x1, [x1]
   91d8c:	f100003f 	cmp	x1, #0x0
   91d90:	1a9f07e2 	cset	w2, ne	// ne = any
   91d94:	6a02029f 	tst	w20, w2
   91d98:	54fffd40 	b.eq	91d40 <_svfiprintf_r+0x1040>  // b.none
   91d9c:	321f0294 	orr	w20, w20, #0x2
   91da0:	390347e0 	strb	w0, [sp, #209]
   91da4:	52800600 	mov	w0, #0x30                  	// #48
   91da8:	390343e0 	strb	w0, [sp, #208]
   91dac:	17ffffe5 	b	91d40 <_svfiprintf_r+0x1040>
   91db0:	2a1903e8 	mov	w8, w25
   91db4:	2a1a03e3 	mov	w3, w26
   91db8:	17fffe6e 	b	91770 <_svfiprintf_r+0xa70>
   91dbc:	b94067e1 	ldr	w1, [sp, #100]
   91dc0:	11002022 	add	w2, w1, #0x8
   91dc4:	7100005f 	cmp	w2, #0x0
   91dc8:	5400104d 	b.le	91fd0 <_svfiprintf_r+0x12d0>
   91dcc:	aa1803e1 	mov	x1, x24
   91dd0:	b90067e2 	str	w2, [sp, #100]
   91dd4:	91003f04 	add	x4, x24, #0xf
   91dd8:	927df098 	and	x24, x4, #0xfffffffffffffff8
   91ddc:	f9400021 	ldr	x1, [x1]
   91de0:	17ffffeb 	b	91d8c <_svfiprintf_r+0x108c>
   91de4:	9105b3f9 	add	x25, sp, #0x16c
   91de8:	1216008a 	and	w10, w4, #0x400
   91dec:	b202e7e6 	mov	x6, #0xcccccccccccccccc    	// #-3689348814741910324
   91df0:	aa1903e2 	mov	x2, x25
   91df4:	aa1b03e5 	mov	x5, x27
   91df8:	aa1903e7 	mov	x7, x25
   91dfc:	aa1603fb 	mov	x27, x22
   91e00:	aa1303f9 	mov	x25, x19
   91e04:	f94053f6 	ldr	x22, [sp, #160]
   91e08:	2a0a03f3 	mov	w19, w10
   91e0c:	5280000b 	mov	w11, #0x0                   	// #0
   91e10:	f29999a6 	movk	x6, #0xcccd
   91e14:	14000007 	b	91e30 <_svfiprintf_r+0x1130>
   91e18:	9bc67c34 	umulh	x20, x1, x6
   91e1c:	d343fe94 	lsr	x20, x20, #3
   91e20:	f100243f 	cmp	x1, #0x9
   91e24:	54000249 	b.ls	91e6c <_svfiprintf_r+0x116c>  // b.plast
   91e28:	aa1403e1 	mov	x1, x20
   91e2c:	aa1a03e2 	mov	x2, x26
   91e30:	9bc67c34 	umulh	x20, x1, x6
   91e34:	1100056b 	add	w11, w11, #0x1
   91e38:	d100045a 	sub	x26, x2, #0x1
   91e3c:	d343fe94 	lsr	x20, x20, #3
   91e40:	8b140a80 	add	x0, x20, x20, lsl #2
   91e44:	cb000420 	sub	x0, x1, x0, lsl #1
   91e48:	1100c000 	add	w0, w0, #0x30
   91e4c:	381ff040 	sturb	w0, [x2, #-1]
   91e50:	34fffe53 	cbz	w19, 91e18 <_svfiprintf_r+0x1118>
   91e54:	394002c0 	ldrb	w0, [x22]
   91e58:	7103fc1f 	cmp	w0, #0xff
   91e5c:	7a4b1000 	ccmp	w0, w11, #0x0, ne	// ne = any
   91e60:	54fffdc1 	b.ne	91e18 <_svfiprintf_r+0x1118>  // b.any
   91e64:	f100243f 	cmp	x1, #0x9
   91e68:	54001888 	b.hi	92178 <_svfiprintf_r+0x1478>  // b.pmore
   91e6c:	aa1903f3 	mov	x19, x25
   91e70:	aa0703f9 	mov	x25, x7
   91e74:	4b1a0339 	sub	w25, w25, w26
   91e78:	2a0403f4 	mov	w20, w4
   91e7c:	f90053f6 	str	x22, [sp, #160]
   91e80:	aa1b03f6 	mov	x22, x27
   91e84:	aa0503fb 	mov	x27, x5
   91e88:	17fffe5a 	b	917f0 <_svfiprintf_r+0xaf0>
   91e8c:	b94067e0 	ldr	w0, [sp, #100]
   91e90:	11002001 	add	w1, w0, #0x8
   91e94:	7100003f 	cmp	w1, #0x0
   91e98:	54000e8d 	b.le	92068 <_svfiprintf_r+0x1368>
   91e9c:	91002f00 	add	x0, x24, #0xb
   91ea0:	b90067e1 	str	w1, [sp, #100]
   91ea4:	927df000 	and	x0, x0, #0xfffffffffffffff8
   91ea8:	17fffef2 	b	91a70 <_svfiprintf_r+0xd70>
   91eac:	b94067e0 	ldr	w0, [sp, #100]
   91eb0:	11002001 	add	w1, w0, #0x8
   91eb4:	7100003f 	cmp	w1, #0x0
   91eb8:	54000bcd 	b.le	92030 <_svfiprintf_r+0x1330>
   91ebc:	91003f02 	add	x2, x24, #0xf
   91ec0:	aa1803e0 	mov	x0, x24
   91ec4:	927df058 	and	x24, x2, #0xfffffffffffffff8
   91ec8:	b90067e1 	str	w1, [sp, #100]
   91ecc:	17fffed8 	b	91a2c <_svfiprintf_r+0xd2c>
   91ed0:	b94067e1 	ldr	w1, [sp, #100]
   91ed4:	11002021 	add	w1, w1, #0x8
   91ed8:	7100003f 	cmp	w1, #0x0
   91edc:	54000d4d 	b.le	92084 <_svfiprintf_r+0x1384>
   91ee0:	91003f02 	add	x2, x24, #0xf
   91ee4:	b90067e1 	str	w1, [sp, #100]
   91ee8:	927df041 	and	x1, x2, #0xfffffffffffffff8
   91eec:	f90047e1 	str	x1, [sp, #136]
   91ef0:	17fffdac 	b	915a0 <_svfiprintf_r+0x8a0>
   91ef4:	39400760 	ldrb	w0, [x27, #1]
   91ef8:	32170294 	orr	w20, w20, #0x200
   91efc:	9100077b 	add	x27, x27, #0x1
   91f00:	17fffbd9 	b	90e64 <_svfiprintf_r+0x164>
   91f04:	39400760 	ldrb	w0, [x27, #1]
   91f08:	321b0294 	orr	w20, w20, #0x20
   91f0c:	9100077b 	add	x27, x27, #0x1
   91f10:	17fffbd5 	b	90e64 <_svfiprintf_r+0x164>
   91f14:	7100187f 	cmp	w3, #0x6
   91f18:	528000c9 	mov	w9, #0x6                   	// #6
   91f1c:	1a899079 	csel	w25, w3, w9, ls	// ls = plast
   91f20:	90000027 	adrp	x7, 95000 <pmu_event_descr+0x60>
   91f24:	f94047f8 	ldr	x24, [sp, #136]
   91f28:	2a1903e4 	mov	w4, w25
   91f2c:	911860fa 	add	x26, x7, #0x618
   91f30:	17fffbdd 	b	90ea4 <_svfiprintf_r+0x1a4>
   91f34:	f94083e0 	ldr	x0, [sp, #256]
   91f38:	b4ff9de0 	cbz	x0, 912f4 <_svfiprintf_r+0x5f4>
   91f3c:	aa1303e0 	mov	x0, x19
   91f40:	9103c3e2 	add	x2, sp, #0xf0
   91f44:	aa1603e1 	mov	x1, x22
   91f48:	97fffaee 	bl	90b00 <__ssprint_r>
   91f4c:	794022c0 	ldrh	w0, [x22, #16]
   91f50:	121a0000 	and	w0, w0, #0x40
   91f54:	17fffcea 	b	912fc <_svfiprintf_r+0x5fc>
   91f58:	36480db4 	tbz	w20, #9, 9210c <_svfiprintf_r+0x140c>
   91f5c:	37f81c00 	tbnz	w0, #31, 922dc <_svfiprintf_r+0x15dc>
   91f60:	91002f01 	add	x1, x24, #0xb
   91f64:	aa1803e0 	mov	x0, x24
   91f68:	927df038 	and	x24, x1, #0xfffffffffffffff8
   91f6c:	39800001 	ldrsb	x1, [x0]
   91f70:	aa0103e0 	mov	x0, x1
   91f74:	17fffe5c 	b	918e4 <_svfiprintf_r+0xbe4>
   91f78:	36480af4 	tbz	w20, #9, 920d4 <_svfiprintf_r+0x13d4>
   91f7c:	37f81c20 	tbnz	w0, #31, 92300 <_svfiprintf_r+0x1600>
   91f80:	aa1803e0 	mov	x0, x24
   91f84:	91002f01 	add	x1, x24, #0xb
   91f88:	927df038 	and	x24, x1, #0xfffffffffffffff8
   91f8c:	39400001 	ldrb	w1, [x0]
   91f90:	17fffe07 	b	917ac <_svfiprintf_r+0xaac>
   91f94:	36480924 	tbz	w4, #9, 920b8 <_svfiprintf_r+0x13b8>
   91f98:	37f82540 	tbnz	w0, #31, 92440 <_svfiprintf_r+0x1740>
   91f9c:	91002f01 	add	x1, x24, #0xb
   91fa0:	aa1803e0 	mov	x0, x24
   91fa4:	927df038 	and	x24, x1, #0xfffffffffffffff8
   91fa8:	39400001 	ldrb	w1, [x0]
   91fac:	52800020 	mov	w0, #0x1                   	// #1
   91fb0:	17fffe01 	b	917b4 <_svfiprintf_r+0xab4>
   91fb4:	36480774 	tbz	w20, #9, 920a0 <_svfiprintf_r+0x13a0>
   91fb8:	37f81d61 	tbnz	w1, #31, 92364 <_svfiprintf_r+0x1664>
   91fbc:	aa1803e1 	mov	x1, x24
   91fc0:	91002f02 	add	x2, x24, #0xb
   91fc4:	927df058 	and	x24, x2, #0xfffffffffffffff8
   91fc8:	39400021 	ldrb	w1, [x1]
   91fcc:	17ffff58 	b	91d2c <_svfiprintf_r+0x102c>
   91fd0:	f9403fe4 	ldr	x4, [sp, #120]
   91fd4:	b94067e1 	ldr	w1, [sp, #100]
   91fd8:	b90067e2 	str	w2, [sp, #100]
   91fdc:	8b21c081 	add	x1, x4, w1, sxtw
   91fe0:	f9400021 	ldr	x1, [x1]
   91fe4:	17ffff6a 	b	91d8c <_svfiprintf_r+0x108c>
   91fe8:	910383e4 	add	x4, sp, #0xe0
   91fec:	9103a3e2 	add	x2, sp, #0xe8
   91ff0:	aa1303e0 	mov	x0, x19
   91ff4:	d2800003 	mov	x3, #0x0                   	// #0
   91ff8:	d2800001 	mov	x1, #0x0                   	// #0
   91ffc:	b9006be8 	str	w8, [sp, #104]
   92000:	97ffedf0 	bl	8d7c0 <_wcsrtombs_r>
   92004:	2a0003f9 	mov	w25, w0
   92008:	b9406be8 	ldr	w8, [sp, #104]
   9200c:	3100041f 	cmn	w0, #0x1
   92010:	54001580 	b.eq	922c0 <_svfiprintf_r+0x15c0>  // b.none
   92014:	f90077fa 	str	x26, [sp, #232]
   92018:	17fffd90 	b	91658 <_svfiprintf_r+0x958>
   9201c:	f94047f8 	ldr	x24, [sp, #136]
   92020:	52800004 	mov	w4, #0x0                   	// #0
   92024:	52800003 	mov	w3, #0x0                   	// #0
   92028:	f90037ff 	str	xzr, [sp, #104]
   9202c:	17fffdf4 	b	917fc <_svfiprintf_r+0xafc>
   92030:	f9403fe2 	ldr	x2, [sp, #120]
   92034:	b94067e0 	ldr	w0, [sp, #100]
   92038:	b90067e1 	str	w1, [sp, #100]
   9203c:	8b20c040 	add	x0, x2, w0, sxtw
   92040:	17fffe7b 	b	91a2c <_svfiprintf_r+0xd2c>
   92044:	b94067e0 	ldr	w0, [sp, #100]
   92048:	11002001 	add	w1, w0, #0x8
   9204c:	7100003f 	cmp	w1, #0x0
   92050:	5400080d 	b.le	92150 <_svfiprintf_r+0x1450>
   92054:	91002f02 	add	x2, x24, #0xb
   92058:	aa1803e0 	mov	x0, x24
   9205c:	927df058 	and	x24, x2, #0xfffffffffffffff8
   92060:	b90067e1 	str	w1, [sp, #100]
   92064:	17fffda0 	b	916e4 <_svfiprintf_r+0x9e4>
   92068:	f9403fe2 	ldr	x2, [sp, #120]
   9206c:	b94067e0 	ldr	w0, [sp, #100]
   92070:	b90067e1 	str	w1, [sp, #100]
   92074:	8b20c042 	add	x2, x2, w0, sxtw
   92078:	aa1803e0 	mov	x0, x24
   9207c:	aa0203f8 	mov	x24, x2
   92080:	17fffe7c 	b	91a70 <_svfiprintf_r+0xd70>
   92084:	f9403fe4 	ldr	x4, [sp, #120]
   92088:	f90047f8 	str	x24, [sp, #136]
   9208c:	b94067e2 	ldr	w2, [sp, #100]
   92090:	b90067e1 	str	w1, [sp, #100]
   92094:	8b22c082 	add	x2, x4, w2, sxtw
   92098:	aa0203f8 	mov	x24, x2
   9209c:	17fffd41 	b	915a0 <_svfiprintf_r+0x8a0>
   920a0:	37f814e1 	tbnz	w1, #31, 9233c <_svfiprintf_r+0x163c>
   920a4:	aa1803e1 	mov	x1, x24
   920a8:	91002f02 	add	x2, x24, #0xb
   920ac:	927df058 	and	x24, x2, #0xfffffffffffffff8
   920b0:	b9400021 	ldr	w1, [x1]
   920b4:	17ffff1e 	b	91d2c <_svfiprintf_r+0x102c>
   920b8:	37f817a0 	tbnz	w0, #31, 923ac <_svfiprintf_r+0x16ac>
   920bc:	91002f01 	add	x1, x24, #0xb
   920c0:	aa1803e0 	mov	x0, x24
   920c4:	927df038 	and	x24, x1, #0xfffffffffffffff8
   920c8:	b9400001 	ldr	w1, [x0]
   920cc:	52800020 	mov	w0, #0x1                   	// #1
   920d0:	17fffdb9 	b	917b4 <_svfiprintf_r+0xab4>
   920d4:	37f81900 	tbnz	w0, #31, 923f4 <_svfiprintf_r+0x16f4>
   920d8:	aa1803e0 	mov	x0, x24
   920dc:	91002f01 	add	x1, x24, #0xb
   920e0:	927df038 	and	x24, x1, #0xfffffffffffffff8
   920e4:	b9400001 	ldr	w1, [x0]
   920e8:	17fffdb1 	b	917ac <_svfiprintf_r+0xaac>
   920ec:	37f81720 	tbnz	w0, #31, 923d0 <_svfiprintf_r+0x16d0>
   920f0:	91003f01 	add	x1, x24, #0xf
   920f4:	aa1803e0 	mov	x0, x24
   920f8:	927df038 	and	x24, x1, #0xfffffffffffffff8
   920fc:	f9400000 	ldr	x0, [x0]
   92100:	7940c3e1 	ldrh	w1, [sp, #96]
   92104:	79000001 	strh	w1, [x0]
   92108:	17fffb22 	b	90d90 <_svfiprintf_r+0x90>
   9210c:	37f81880 	tbnz	w0, #31, 9241c <_svfiprintf_r+0x171c>
   92110:	91002f01 	add	x1, x24, #0xb
   92114:	aa1803e0 	mov	x0, x24
   92118:	927df038 	and	x24, x1, #0xfffffffffffffff8
   9211c:	b9800001 	ldrsw	x1, [x0]
   92120:	aa0103e0 	mov	x0, x1
   92124:	17fffdf0 	b	918e4 <_svfiprintf_r+0xbe4>
   92128:	11000721 	add	w1, w25, #0x1
   9212c:	aa1303e0 	mov	x0, x19
   92130:	b9006be8 	str	w8, [sp, #104]
   92134:	93407c21 	sxtw	x1, w1
   92138:	97ffe512 	bl	8b580 <_malloc_r>
   9213c:	b9406be8 	ldr	w8, [sp, #104]
   92140:	aa0003fa 	mov	x26, x0
   92144:	b4000be0 	cbz	x0, 922c0 <_svfiprintf_r+0x15c0>
   92148:	f90037e0 	str	x0, [sp, #104]
   9214c:	17fffd48 	b	9166c <_svfiprintf_r+0x96c>
   92150:	f9403fe2 	ldr	x2, [sp, #120]
   92154:	b94067e0 	ldr	w0, [sp, #100]
   92158:	b90067e1 	str	w1, [sp, #100]
   9215c:	8b20c040 	add	x0, x2, w0, sxtw
   92160:	17fffd61 	b	916e4 <_svfiprintf_r+0x9e4>
   92164:	f94047f8 	ldr	x24, [sp, #136]
   92168:	2a0303e4 	mov	w4, w3
   9216c:	2a0303f9 	mov	w25, w3
   92170:	52800003 	mov	w3, #0x0                   	// #0
   92174:	17fffda2 	b	917fc <_svfiprintf_r+0xafc>
   92178:	f9404fe0 	ldr	x0, [sp, #152]
   9217c:	b9006be4 	str	w4, [sp, #104]
   92180:	f94057e1 	ldr	x1, [sp, #168]
   92184:	cb00035a 	sub	x26, x26, x0
   92188:	aa0003e2 	mov	x2, x0
   9218c:	aa1a03e0 	mov	x0, x26
   92190:	b9008be8 	str	w8, [sp, #136]
   92194:	f9004be5 	str	x5, [sp, #144]
   92198:	f90053e7 	str	x7, [sp, #160]
   9219c:	b900b3e3 	str	w3, [sp, #176]
   921a0:	97fff73c 	bl	8fe90 <strncpy>
   921a4:	394006c0 	ldrb	w0, [x22, #1]
   921a8:	b202e7e6 	mov	x6, #0xcccccccccccccccc    	// #-3689348814741910324
   921ac:	f9404be5 	ldr	x5, [sp, #144]
   921b0:	7100001f 	cmp	w0, #0x0
   921b4:	f94053e7 	ldr	x7, [sp, #160]
   921b8:	9a9606d6 	cinc	x22, x22, ne	// ne = any
   921bc:	b9406be4 	ldr	w4, [sp, #104]
   921c0:	5280000b 	mov	w11, #0x0                   	// #0
   921c4:	b9408be8 	ldr	w8, [sp, #136]
   921c8:	f29999a6 	movk	x6, #0xcccd
   921cc:	b940b3e3 	ldr	w3, [sp, #176]
   921d0:	17ffff16 	b	91e28 <_svfiprintf_r+0x1128>
   921d4:	f9403fe2 	ldr	x2, [sp, #120]
   921d8:	b94067e0 	ldr	w0, [sp, #100]
   921dc:	b90067e1 	str	w1, [sp, #100]
   921e0:	8b20c040 	add	x0, x2, w0, sxtw
   921e4:	17fffdfa 	b	919cc <_svfiprintf_r+0xccc>
   921e8:	aa1a03e0 	mov	x0, x26
   921ec:	b900b3e8 	str	w8, [sp, #176]
   921f0:	97ffc1e4 	bl	82980 <strlen>
   921f4:	7100001f 	cmp	w0, #0x0
   921f8:	f94047f8 	ldr	x24, [sp, #136]
   921fc:	2a0003f9 	mov	w25, w0
   92200:	b940b3e8 	ldr	w8, [sp, #176]
   92204:	1a9fa004 	csel	w4, w0, wzr, ge	// ge = tcont
   92208:	52800003 	mov	w3, #0x0                   	// #0
   9220c:	f90037ff 	str	xzr, [sp, #104]
   92210:	17fffd7b 	b	917fc <_svfiprintf_r+0xafc>
   92214:	f9403fe2 	ldr	x2, [sp, #120]
   92218:	b94067e0 	ldr	w0, [sp, #100]
   9221c:	b90067e1 	str	w1, [sp, #100]
   92220:	8b20c040 	add	x0, x2, w0, sxtw
   92224:	17fffd41 	b	91728 <_svfiprintf_r+0xa28>
   92228:	b94067e1 	ldr	w1, [sp, #100]
   9222c:	11002022 	add	w2, w1, #0x8
   92230:	7100005f 	cmp	w2, #0x0
   92234:	5400124d 	b.le	9247c <_svfiprintf_r+0x177c>
   92238:	91002f04 	add	x4, x24, #0xb
   9223c:	aa1803e1 	mov	x1, x24
   92240:	927df098 	and	x24, x4, #0xfffffffffffffff8
   92244:	b90067e2 	str	w2, [sp, #100]
   92248:	17fffeb8 	b	91d28 <_svfiprintf_r+0x1028>
   9224c:	b94067e0 	ldr	w0, [sp, #100]
   92250:	11002001 	add	w1, w0, #0x8
   92254:	7100003f 	cmp	w1, #0x0
   92258:	5400106d 	b.le	92464 <_svfiprintf_r+0x1764>
   9225c:	aa1803e0 	mov	x0, x24
   92260:	91002f02 	add	x2, x24, #0xb
   92264:	927df058 	and	x24, x2, #0xfffffffffffffff8
   92268:	b90067e1 	str	w1, [sp, #100]
   9226c:	79400001 	ldrh	w1, [x0]
   92270:	17fffd4f 	b	917ac <_svfiprintf_r+0xaac>
   92274:	b94067e0 	ldr	w0, [sp, #100]
   92278:	11002001 	add	w1, w0, #0x8
   9227c:	7100003f 	cmp	w1, #0x0
   92280:	5400112d 	b.le	924a4 <_svfiprintf_r+0x17a4>
   92284:	91002f02 	add	x2, x24, #0xb
   92288:	aa1803e0 	mov	x0, x24
   9228c:	927df058 	and	x24, x2, #0xfffffffffffffff8
   92290:	b90067e1 	str	w1, [sp, #100]
   92294:	17fffd7d 	b	91888 <_svfiprintf_r+0xb88>
   92298:	b94067e0 	ldr	w0, [sp, #100]
   9229c:	11002001 	add	w1, w0, #0x8
   922a0:	7100003f 	cmp	w1, #0x0
   922a4:	54000f6d 	b.le	92490 <_svfiprintf_r+0x1790>
   922a8:	91002f02 	add	x2, x24, #0xb
   922ac:	aa1803e0 	mov	x0, x24
   922b0:	927df058 	and	x24, x2, #0xfffffffffffffff8
   922b4:	b90067e1 	str	w1, [sp, #100]
   922b8:	17fffd89 	b	918dc <_svfiprintf_r+0xbdc>
   922bc:	aa1903f6 	mov	x22, x25
   922c0:	a9446bf9 	ldp	x25, x26, [sp, #64]
   922c4:	794022c0 	ldrh	w0, [x22, #16]
   922c8:	321a0000 	orr	w0, w0, #0x40
   922cc:	790022c0 	strh	w0, [x22, #16]
   922d0:	12800000 	mov	w0, #0xffffffff            	// #-1
   922d4:	b90063e0 	str	w0, [sp, #96]
   922d8:	17fffc0b 	b	91304 <_svfiprintf_r+0x604>
   922dc:	b94067e0 	ldr	w0, [sp, #100]
   922e0:	11002001 	add	w1, w0, #0x8
   922e4:	7100003f 	cmp	w1, #0x0
   922e8:	5400142d 	b.le	9256c <_svfiprintf_r+0x186c>
   922ec:	91002f02 	add	x2, x24, #0xb
   922f0:	aa1803e0 	mov	x0, x24
   922f4:	927df058 	and	x24, x2, #0xfffffffffffffff8
   922f8:	b90067e1 	str	w1, [sp, #100]
   922fc:	17ffff1c 	b	91f6c <_svfiprintf_r+0x126c>
   92300:	b94067e0 	ldr	w0, [sp, #100]
   92304:	11002001 	add	w1, w0, #0x8
   92308:	7100003f 	cmp	w1, #0x0
   9230c:	540013ad 	b.le	92580 <_svfiprintf_r+0x1880>
   92310:	aa1803e0 	mov	x0, x24
   92314:	91002f02 	add	x2, x24, #0xb
   92318:	927df058 	and	x24, x2, #0xfffffffffffffff8
   9231c:	b90067e1 	str	w1, [sp, #100]
   92320:	39400001 	ldrb	w1, [x0]
   92324:	17fffd22 	b	917ac <_svfiprintf_r+0xaac>
   92328:	aa1903f6 	mov	x22, x25
   9232c:	b940b3e8 	ldr	w8, [sp, #176]
   92330:	2a1403f9 	mov	w25, w20
   92334:	b9406bf4 	ldr	w20, [sp, #104]
   92338:	17fffcc8 	b	91658 <_svfiprintf_r+0x958>
   9233c:	b94067e1 	ldr	w1, [sp, #100]
   92340:	11002022 	add	w2, w1, #0x8
   92344:	7100005f 	cmp	w2, #0x0
   92348:	5400140d 	b.le	925c8 <_svfiprintf_r+0x18c8>
   9234c:	aa1803e1 	mov	x1, x24
   92350:	91002f04 	add	x4, x24, #0xb
   92354:	927df098 	and	x24, x4, #0xfffffffffffffff8
   92358:	b90067e2 	str	w2, [sp, #100]
   9235c:	b9400021 	ldr	w1, [x1]
   92360:	17fffe73 	b	91d2c <_svfiprintf_r+0x102c>
   92364:	b94067e1 	ldr	w1, [sp, #100]
   92368:	11002022 	add	w2, w1, #0x8
   9236c:	7100005f 	cmp	w2, #0x0
   92370:	54000c8d 	b.le	92500 <_svfiprintf_r+0x1800>
   92374:	aa1803e1 	mov	x1, x24
   92378:	91002f04 	add	x4, x24, #0xb
   9237c:	927df098 	and	x24, x4, #0xfffffffffffffff8
   92380:	b90067e2 	str	w2, [sp, #100]
   92384:	39400021 	ldrb	w1, [x1]
   92388:	17fffe69 	b	91d2c <_svfiprintf_r+0x102c>
   9238c:	37f80a80 	tbnz	w0, #31, 924dc <_svfiprintf_r+0x17dc>
   92390:	91003f01 	add	x1, x24, #0xf
   92394:	aa1803e0 	mov	x0, x24
   92398:	927df038 	and	x24, x1, #0xfffffffffffffff8
   9239c:	f9400000 	ldr	x0, [x0]
   923a0:	b94063e1 	ldr	w1, [sp, #96]
   923a4:	b9000001 	str	w1, [x0]
   923a8:	17fffa7a 	b	90d90 <_svfiprintf_r+0x90>
   923ac:	b94067e0 	ldr	w0, [sp, #100]
   923b0:	11002001 	add	w1, w0, #0x8
   923b4:	7100003f 	cmp	w1, #0x0
   923b8:	54000c4d 	b.le	92540 <_svfiprintf_r+0x1840>
   923bc:	91002f02 	add	x2, x24, #0xb
   923c0:	aa1803e0 	mov	x0, x24
   923c4:	927df058 	and	x24, x2, #0xfffffffffffffff8
   923c8:	b90067e1 	str	w1, [sp, #100]
   923cc:	17ffff3f 	b	920c8 <_svfiprintf_r+0x13c8>
   923d0:	b94067e0 	ldr	w0, [sp, #100]
   923d4:	11002001 	add	w1, w0, #0x8
   923d8:	7100003f 	cmp	w1, #0x0
   923dc:	5400116d 	b.le	92608 <_svfiprintf_r+0x1908>
   923e0:	91003f02 	add	x2, x24, #0xf
   923e4:	aa1803e0 	mov	x0, x24
   923e8:	927df058 	and	x24, x2, #0xfffffffffffffff8
   923ec:	b90067e1 	str	w1, [sp, #100]
   923f0:	17ffff43 	b	920fc <_svfiprintf_r+0x13fc>
   923f4:	b94067e0 	ldr	w0, [sp, #100]
   923f8:	11002001 	add	w1, w0, #0x8
   923fc:	7100003f 	cmp	w1, #0x0
   92400:	54000aad 	b.le	92554 <_svfiprintf_r+0x1854>
   92404:	aa1803e0 	mov	x0, x24
   92408:	91002f02 	add	x2, x24, #0xb
   9240c:	927df058 	and	x24, x2, #0xfffffffffffffff8
   92410:	b90067e1 	str	w1, [sp, #100]
   92414:	b9400001 	ldr	w1, [x0]
   92418:	17fffce5 	b	917ac <_svfiprintf_r+0xaac>
   9241c:	b94067e0 	ldr	w0, [sp, #100]
   92420:	11002001 	add	w1, w0, #0x8
   92424:	7100003f 	cmp	w1, #0x0
   92428:	54000dcd 	b.le	925e0 <_svfiprintf_r+0x18e0>
   9242c:	91002f02 	add	x2, x24, #0xb
   92430:	aa1803e0 	mov	x0, x24
   92434:	927df058 	and	x24, x2, #0xfffffffffffffff8
   92438:	b90067e1 	str	w1, [sp, #100]
   9243c:	17ffff38 	b	9211c <_svfiprintf_r+0x141c>
   92440:	b94067e0 	ldr	w0, [sp, #100]
   92444:	11002001 	add	w1, w0, #0x8
   92448:	7100003f 	cmp	w1, #0x0
   9244c:	5400070d 	b.le	9252c <_svfiprintf_r+0x182c>
   92450:	91002f02 	add	x2, x24, #0xb
   92454:	aa1803e0 	mov	x0, x24
   92458:	927df058 	and	x24, x2, #0xfffffffffffffff8
   9245c:	b90067e1 	str	w1, [sp, #100]
   92460:	17fffed2 	b	91fa8 <_svfiprintf_r+0x12a8>
   92464:	f9403fe2 	ldr	x2, [sp, #120]
   92468:	b94067e0 	ldr	w0, [sp, #100]
   9246c:	b90067e1 	str	w1, [sp, #100]
   92470:	8b20c040 	add	x0, x2, w0, sxtw
   92474:	79400001 	ldrh	w1, [x0]
   92478:	17fffccd 	b	917ac <_svfiprintf_r+0xaac>
   9247c:	f9403fe4 	ldr	x4, [sp, #120]
   92480:	b94067e1 	ldr	w1, [sp, #100]
   92484:	b90067e2 	str	w2, [sp, #100]
   92488:	8b21c081 	add	x1, x4, w1, sxtw
   9248c:	17fffe27 	b	91d28 <_svfiprintf_r+0x1028>
   92490:	f9403fe2 	ldr	x2, [sp, #120]
   92494:	b94067e0 	ldr	w0, [sp, #100]
   92498:	b90067e1 	str	w1, [sp, #100]
   9249c:	8b20c040 	add	x0, x2, w0, sxtw
   924a0:	17fffd0f 	b	918dc <_svfiprintf_r+0xbdc>
   924a4:	f9403fe2 	ldr	x2, [sp, #120]
   924a8:	b94067e0 	ldr	w0, [sp, #100]
   924ac:	b90067e1 	str	w1, [sp, #100]
   924b0:	8b20c040 	add	x0, x2, w0, sxtw
   924b4:	17fffcf5 	b	91888 <_svfiprintf_r+0xb88>
   924b8:	b94067e0 	ldr	w0, [sp, #100]
   924bc:	11002001 	add	w1, w0, #0x8
   924c0:	7100003f 	cmp	w1, #0x0
   924c4:	5400098d 	b.le	925f4 <_svfiprintf_r+0x18f4>
   924c8:	91003f02 	add	x2, x24, #0xf
   924cc:	aa1803e0 	mov	x0, x24
   924d0:	927df058 	and	x24, x2, #0xfffffffffffffff8
   924d4:	b90067e1 	str	w1, [sp, #100]
   924d8:	17fffd35 	b	919ac <_svfiprintf_r+0xcac>
   924dc:	b94067e0 	ldr	w0, [sp, #100]
   924e0:	11002001 	add	w1, w0, #0x8
   924e4:	7100003f 	cmp	w1, #0x0
   924e8:	5400018d 	b.le	92518 <_svfiprintf_r+0x1818>
   924ec:	91003f02 	add	x2, x24, #0xf
   924f0:	aa1803e0 	mov	x0, x24
   924f4:	927df058 	and	x24, x2, #0xfffffffffffffff8
   924f8:	b90067e1 	str	w1, [sp, #100]
   924fc:	17ffffa8 	b	9239c <_svfiprintf_r+0x169c>
   92500:	f9403fe4 	ldr	x4, [sp, #120]
   92504:	b94067e1 	ldr	w1, [sp, #100]
   92508:	b90067e2 	str	w2, [sp, #100]
   9250c:	8b21c081 	add	x1, x4, w1, sxtw
   92510:	39400021 	ldrb	w1, [x1]
   92514:	17fffe06 	b	91d2c <_svfiprintf_r+0x102c>
   92518:	f9403fe2 	ldr	x2, [sp, #120]
   9251c:	b94067e0 	ldr	w0, [sp, #100]
   92520:	b90067e1 	str	w1, [sp, #100]
   92524:	8b20c040 	add	x0, x2, w0, sxtw
   92528:	17ffff9d 	b	9239c <_svfiprintf_r+0x169c>
   9252c:	f9403fe2 	ldr	x2, [sp, #120]
   92530:	b94067e0 	ldr	w0, [sp, #100]
   92534:	b90067e1 	str	w1, [sp, #100]
   92538:	8b20c040 	add	x0, x2, w0, sxtw
   9253c:	17fffe9b 	b	91fa8 <_svfiprintf_r+0x12a8>
   92540:	f9403fe2 	ldr	x2, [sp, #120]
   92544:	b94067e0 	ldr	w0, [sp, #100]
   92548:	b90067e1 	str	w1, [sp, #100]
   9254c:	8b20c040 	add	x0, x2, w0, sxtw
   92550:	17fffede 	b	920c8 <_svfiprintf_r+0x13c8>
   92554:	f9403fe2 	ldr	x2, [sp, #120]
   92558:	b94067e0 	ldr	w0, [sp, #100]
   9255c:	b90067e1 	str	w1, [sp, #100]
   92560:	8b20c040 	add	x0, x2, w0, sxtw
   92564:	b9400001 	ldr	w1, [x0]
   92568:	17fffc91 	b	917ac <_svfiprintf_r+0xaac>
   9256c:	f9403fe2 	ldr	x2, [sp, #120]
   92570:	b94067e0 	ldr	w0, [sp, #100]
   92574:	b90067e1 	str	w1, [sp, #100]
   92578:	8b20c040 	add	x0, x2, w0, sxtw
   9257c:	17fffe7c 	b	91f6c <_svfiprintf_r+0x126c>
   92580:	f9403fe2 	ldr	x2, [sp, #120]
   92584:	b94067e0 	ldr	w0, [sp, #100]
   92588:	b90067e1 	str	w1, [sp, #100]
   9258c:	8b20c040 	add	x0, x2, w0, sxtw
   92590:	39400001 	ldrb	w1, [x0]
   92594:	17fffc86 	b	917ac <_svfiprintf_r+0xaac>
   92598:	b94067e0 	ldr	w0, [sp, #100]
   9259c:	37f80400 	tbnz	w0, #31, 9261c <_svfiprintf_r+0x191c>
   925a0:	91002f01 	add	x1, x24, #0xb
   925a4:	927df021 	and	x1, x1, #0xfffffffffffffff8
   925a8:	b9400303 	ldr	w3, [x24]
   925ac:	aa0103f8 	mov	x24, x1
   925b0:	b90067e0 	str	w0, [sp, #100]
   925b4:	7100007f 	cmp	w3, #0x0
   925b8:	39400760 	ldrb	w0, [x27, #1]
   925bc:	5a9fa07a 	csinv	w26, w3, wzr, ge	// ge = tcont
   925c0:	aa0203fb 	mov	x27, x2
   925c4:	17fffa28 	b	90e64 <_svfiprintf_r+0x164>
   925c8:	f9403fe4 	ldr	x4, [sp, #120]
   925cc:	b94067e1 	ldr	w1, [sp, #100]
   925d0:	b90067e2 	str	w2, [sp, #100]
   925d4:	8b21c081 	add	x1, x4, w1, sxtw
   925d8:	b9400021 	ldr	w1, [x1]
   925dc:	17fffdd4 	b	91d2c <_svfiprintf_r+0x102c>
   925e0:	f9403fe2 	ldr	x2, [sp, #120]
   925e4:	b94067e0 	ldr	w0, [sp, #100]
   925e8:	b90067e1 	str	w1, [sp, #100]
   925ec:	8b20c040 	add	x0, x2, w0, sxtw
   925f0:	17fffecb 	b	9211c <_svfiprintf_r+0x141c>
   925f4:	f9403fe2 	ldr	x2, [sp, #120]
   925f8:	b94067e0 	ldr	w0, [sp, #100]
   925fc:	b90067e1 	str	w1, [sp, #100]
   92600:	8b20c040 	add	x0, x2, w0, sxtw
   92604:	17fffcea 	b	919ac <_svfiprintf_r+0xcac>
   92608:	f9403fe2 	ldr	x2, [sp, #120]
   9260c:	b94067e0 	ldr	w0, [sp, #100]
   92610:	b90067e1 	str	w1, [sp, #100]
   92614:	8b20c040 	add	x0, x2, w0, sxtw
   92618:	17fffeb9 	b	920fc <_svfiprintf_r+0x13fc>
   9261c:	b94067e0 	ldr	w0, [sp, #100]
   92620:	11002000 	add	w0, w0, #0x8
   92624:	7100001f 	cmp	w0, #0x0
   92628:	54fffbcc 	b.gt	925a0 <_svfiprintf_r+0x18a0>
   9262c:	f9403fe4 	ldr	x4, [sp, #120]
   92630:	aa1803e1 	mov	x1, x24
   92634:	b94067e3 	ldr	w3, [sp, #100]
   92638:	8b23c098 	add	x24, x4, w3, sxtw
   9263c:	17ffffdb 	b	925a8 <_svfiprintf_r+0x18a8>
   92640:	794022c0 	ldrh	w0, [x22, #16]
   92644:	321a0000 	orr	w0, w0, #0x40
   92648:	790022c0 	strh	w0, [x22, #16]
   9264c:	17fffb25 	b	912e0 <_svfiprintf_r+0x5e0>
   92650:	52800180 	mov	w0, #0xc                   	// #12
   92654:	b9000260 	str	w0, [x19]
   92658:	17ffff1e 	b	922d0 <_svfiprintf_r+0x15d0>
   9265c:	00000000 	udf	#0

0000000000092660 <__swbuf_r>:
   92660:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   92664:	910003fd 	mov	x29, sp
   92668:	a90153f3 	stp	x19, x20, [sp, #16]
   9266c:	2a0103f4 	mov	w20, w1
   92670:	aa0203f3 	mov	x19, x2
   92674:	a9025bf5 	stp	x21, x22, [sp, #32]
   92678:	aa0003f5 	mov	x21, x0
   9267c:	b4000060 	cbz	x0, 92688 <__swbuf_r+0x28>
   92680:	f9402401 	ldr	x1, [x0, #72]
   92684:	b4000861 	cbz	x1, 92790 <__swbuf_r+0x130>
   92688:	79c02260 	ldrsh	w0, [x19, #16]
   9268c:	b9402a61 	ldr	w1, [x19, #40]
   92690:	b9000e61 	str	w1, [x19, #12]
   92694:	361803e0 	tbz	w0, #3, 92710 <__swbuf_r+0xb0>
   92698:	f9400e61 	ldr	x1, [x19, #24]
   9269c:	b40003a1 	cbz	x1, 92710 <__swbuf_r+0xb0>
   926a0:	12001e96 	and	w22, w20, #0xff
   926a4:	12001e94 	and	w20, w20, #0xff
   926a8:	36680460 	tbz	w0, #13, 92734 <__swbuf_r+0xd4>
   926ac:	f9400260 	ldr	x0, [x19]
   926b0:	b9402262 	ldr	w2, [x19, #32]
   926b4:	cb010001 	sub	x1, x0, x1
   926b8:	6b01005f 	cmp	w2, w1
   926bc:	5400050d 	b.le	9275c <__swbuf_r+0xfc>
   926c0:	11000421 	add	w1, w1, #0x1
   926c4:	b9400e62 	ldr	w2, [x19, #12]
   926c8:	91000403 	add	x3, x0, #0x1
   926cc:	f9000263 	str	x3, [x19]
   926d0:	51000442 	sub	w2, w2, #0x1
   926d4:	b9000e62 	str	w2, [x19, #12]
   926d8:	39000016 	strb	w22, [x0]
   926dc:	b9402260 	ldr	w0, [x19, #32]
   926e0:	6b01001f 	cmp	w0, w1
   926e4:	540004a0 	b.eq	92778 <__swbuf_r+0x118>  // b.none
   926e8:	71002a9f 	cmp	w20, #0xa
   926ec:	79402260 	ldrh	w0, [x19, #16]
   926f0:	1a9f17e1 	cset	w1, eq	// eq = none
   926f4:	6a00003f 	tst	w1, w0
   926f8:	54000401 	b.ne	92778 <__swbuf_r+0x118>  // b.any
   926fc:	a9425bf5 	ldp	x21, x22, [sp, #32]
   92700:	2a1403e0 	mov	w0, w20
   92704:	a94153f3 	ldp	x19, x20, [sp, #16]
   92708:	a8c37bfd 	ldp	x29, x30, [sp], #48
   9270c:	d65f03c0 	ret
   92710:	aa1303e1 	mov	x1, x19
   92714:	aa1503e0 	mov	x0, x21
   92718:	97ffe9e2 	bl	8cea0 <__swsetup_r>
   9271c:	35000360 	cbnz	w0, 92788 <__swbuf_r+0x128>
   92720:	79c02260 	ldrsh	w0, [x19, #16]
   92724:	12001e96 	and	w22, w20, #0xff
   92728:	f9400e61 	ldr	x1, [x19, #24]
   9272c:	12001e94 	and	w20, w20, #0xff
   92730:	376ffbe0 	tbnz	w0, #13, 926ac <__swbuf_r+0x4c>
   92734:	b940b262 	ldr	w2, [x19, #176]
   92738:	32130000 	orr	w0, w0, #0x2000
   9273c:	79002260 	strh	w0, [x19, #16]
   92740:	12127840 	and	w0, w2, #0xffffdfff
   92744:	b900b260 	str	w0, [x19, #176]
   92748:	f9400260 	ldr	x0, [x19]
   9274c:	b9402262 	ldr	w2, [x19, #32]
   92750:	cb010001 	sub	x1, x0, x1
   92754:	6b01005f 	cmp	w2, w1
   92758:	54fffb4c 	b.gt	926c0 <__swbuf_r+0x60>
   9275c:	aa1303e1 	mov	x1, x19
   92760:	aa1503e0 	mov	x0, x21
   92764:	97fff1bb 	bl	8ee50 <_fflush_r>
   92768:	35000100 	cbnz	w0, 92788 <__swbuf_r+0x128>
   9276c:	f9400260 	ldr	x0, [x19]
   92770:	52800021 	mov	w1, #0x1                   	// #1
   92774:	17ffffd4 	b	926c4 <__swbuf_r+0x64>
   92778:	aa1303e1 	mov	x1, x19
   9277c:	aa1503e0 	mov	x0, x21
   92780:	97fff1b4 	bl	8ee50 <_fflush_r>
   92784:	34fffbc0 	cbz	w0, 926fc <__swbuf_r+0x9c>
   92788:	12800014 	mov	w20, #0xffffffff            	// #-1
   9278c:	17ffffdc 	b	926fc <__swbuf_r+0x9c>
   92790:	97ffbf9c 	bl	82600 <__sinit>
   92794:	17ffffbd 	b	92688 <__swbuf_r+0x28>
	...

00000000000927a0 <__swbuf>:
   927a0:	90000023 	adrp	x3, 96000 <JIS_state_table+0x70>
   927a4:	aa0103e2 	mov	x2, x1
   927a8:	2a0003e1 	mov	w1, w0
   927ac:	f9410060 	ldr	x0, [x3, #512]
   927b0:	17ffffac 	b	92660 <__swbuf_r>
	...

00000000000927c0 <_mbtowc_r>:
   927c0:	90000025 	adrp	x5, 96000 <JIS_state_table+0x70>
   927c4:	f946bca5 	ldr	x5, [x5, #3448]
   927c8:	aa0503f0 	mov	x16, x5
   927cc:	d61f0200 	br	x16

00000000000927d0 <__ascii_mbtowc>:
   927d0:	d10043ff 	sub	sp, sp, #0x10
   927d4:	f100003f 	cmp	x1, #0x0
   927d8:	910033e0 	add	x0, sp, #0xc
   927dc:	9a810001 	csel	x1, x0, x1, eq	// eq = none
   927e0:	b4000122 	cbz	x2, 92804 <__ascii_mbtowc+0x34>
   927e4:	b4000163 	cbz	x3, 92810 <__ascii_mbtowc+0x40>
   927e8:	39400040 	ldrb	w0, [x2]
   927ec:	b9000020 	str	w0, [x1]
   927f0:	39400040 	ldrb	w0, [x2]
   927f4:	7100001f 	cmp	w0, #0x0
   927f8:	1a9f07e0 	cset	w0, ne	// ne = any
   927fc:	910043ff 	add	sp, sp, #0x10
   92800:	d65f03c0 	ret
   92804:	52800000 	mov	w0, #0x0                   	// #0
   92808:	910043ff 	add	sp, sp, #0x10
   9280c:	d65f03c0 	ret
   92810:	12800020 	mov	w0, #0xfffffffe            	// #-2
   92814:	17fffffa 	b	927fc <__ascii_mbtowc+0x2c>
	...

0000000000092820 <__utf8_mbtowc>:
   92820:	d10043ff 	sub	sp, sp, #0x10
   92824:	f100003f 	cmp	x1, #0x0
   92828:	910033e5 	add	x5, sp, #0xc
   9282c:	9a8100a1 	csel	x1, x5, x1, eq	// eq = none
   92830:	b40004c2 	cbz	x2, 928c8 <__utf8_mbtowc+0xa8>
   92834:	b4001223 	cbz	x3, 92a78 <__utf8_mbtowc+0x258>
   92838:	b9400087 	ldr	w7, [x4]
   9283c:	aa0003e9 	mov	x9, x0
   92840:	350003a7 	cbnz	w7, 928b4 <__utf8_mbtowc+0x94>
   92844:	39400045 	ldrb	w5, [x2]
   92848:	52800026 	mov	w6, #0x1                   	// #1
   9284c:	340003a5 	cbz	w5, 928c0 <__utf8_mbtowc+0xa0>
   92850:	7101fcbf 	cmp	w5, #0x7f
   92854:	5400082d 	b.le	92958 <__utf8_mbtowc+0x138>
   92858:	510300a8 	sub	w8, w5, #0xc0
   9285c:	71007d1f 	cmp	w8, #0x1f
   92860:	540003a8 	b.hi	928d4 <__utf8_mbtowc+0xb4>  // b.pmore
   92864:	39001085 	strb	w5, [x4, #4]
   92868:	350000a7 	cbnz	w7, 9287c <__utf8_mbtowc+0x5c>
   9286c:	52800020 	mov	w0, #0x1                   	// #1
   92870:	b9000080 	str	w0, [x4]
   92874:	f100047f 	cmp	x3, #0x1
   92878:	54001000 	b.eq	92a78 <__utf8_mbtowc+0x258>  // b.none
   9287c:	3866c842 	ldrb	w2, [x2, w6, sxtw]
   92880:	110004c0 	add	w0, w6, #0x1
   92884:	51020043 	sub	w3, w2, #0x80
   92888:	7100fc7f 	cmp	w3, #0x3f
   9288c:	54000fe8 	b.hi	92a88 <__utf8_mbtowc+0x268>  // b.pmore
   92890:	710304bf 	cmp	w5, #0xc1
   92894:	54000fad 	b.le	92a88 <__utf8_mbtowc+0x268>
   92898:	12001442 	and	w2, w2, #0x3f
   9289c:	531a10a5 	ubfiz	w5, w5, #6, #5
   928a0:	b900009f 	str	wzr, [x4]
   928a4:	2a0200a5 	orr	w5, w5, w2
   928a8:	b9000025 	str	w5, [x1]
   928ac:	910043ff 	add	sp, sp, #0x10
   928b0:	d65f03c0 	ret
   928b4:	39401085 	ldrb	w5, [x4, #4]
   928b8:	52800006 	mov	w6, #0x0                   	// #0
   928bc:	35fffca5 	cbnz	w5, 92850 <__utf8_mbtowc+0x30>
   928c0:	b900003f 	str	wzr, [x1]
   928c4:	b900009f 	str	wzr, [x4]
   928c8:	52800000 	mov	w0, #0x0                   	// #0
   928cc:	910043ff 	add	sp, sp, #0x10
   928d0:	d65f03c0 	ret
   928d4:	510380a0 	sub	w0, w5, #0xe0
   928d8:	71003c1f 	cmp	w0, #0xf
   928dc:	54000488 	b.hi	9296c <__utf8_mbtowc+0x14c>  // b.pmore
   928e0:	39001085 	strb	w5, [x4, #4]
   928e4:	34000a07 	cbz	w7, 92a24 <__utf8_mbtowc+0x204>
   928e8:	b100047f 	cmn	x3, #0x1
   928ec:	9a830463 	cinc	x3, x3, ne	// ne = any
   928f0:	710004ff 	cmp	w7, #0x1
   928f4:	54000a00 	b.eq	92a34 <__utf8_mbtowc+0x214>  // b.none
   928f8:	39401488 	ldrb	w8, [x4, #5]
   928fc:	71027d1f 	cmp	w8, #0x9f
   92900:	52801c00 	mov	w0, #0xe0                  	// #224
   92904:	7a40d0a0 	ccmp	w5, w0, #0x0, le
   92908:	54000c00 	b.eq	92a88 <__utf8_mbtowc+0x268>  // b.none
   9290c:	51020100 	sub	w0, w8, #0x80
   92910:	7100fc1f 	cmp	w0, #0x3f
   92914:	54000ba8 	b.hi	92a88 <__utf8_mbtowc+0x268>  // b.pmore
   92918:	39001488 	strb	w8, [x4, #5]
   9291c:	710004ff 	cmp	w7, #0x1
   92920:	54000a20 	b.eq	92a64 <__utf8_mbtowc+0x244>  // b.none
   92924:	3866c843 	ldrb	w3, [x2, w6, sxtw]
   92928:	110004c0 	add	w0, w6, #0x1
   9292c:	51020062 	sub	w2, w3, #0x80
   92930:	7100fc5f 	cmp	w2, #0x3f
   92934:	54000aa8 	b.hi	92a88 <__utf8_mbtowc+0x268>  // b.pmore
   92938:	53140ca2 	ubfiz	w2, w5, #12, #4
   9293c:	531a1508 	ubfiz	w8, w8, #6, #6
   92940:	2a080042 	orr	w2, w2, w8
   92944:	12001463 	and	w3, w3, #0x3f
   92948:	b900009f 	str	wzr, [x4]
   9294c:	2a030042 	orr	w2, w2, w3
   92950:	b9000022 	str	w2, [x1]
   92954:	17ffffde 	b	928cc <__utf8_mbtowc+0xac>
   92958:	b900009f 	str	wzr, [x4]
   9295c:	52800020 	mov	w0, #0x1                   	// #1
   92960:	b9000025 	str	w5, [x1]
   92964:	910043ff 	add	sp, sp, #0x10
   92968:	d65f03c0 	ret
   9296c:	5103c0a0 	sub	w0, w5, #0xf0
   92970:	7100101f 	cmp	w0, #0x4
   92974:	540008a8 	b.hi	92a88 <__utf8_mbtowc+0x268>  // b.pmore
   92978:	39001085 	strb	w5, [x4, #4]
   9297c:	34000647 	cbz	w7, 92a44 <__utf8_mbtowc+0x224>
   92980:	b100047f 	cmn	x3, #0x1
   92984:	9a830463 	cinc	x3, x3, ne	// ne = any
   92988:	710004ff 	cmp	w7, #0x1
   9298c:	54000640 	b.eq	92a54 <__utf8_mbtowc+0x234>  // b.none
   92990:	39401488 	ldrb	w8, [x4, #5]
   92994:	7103c0bf 	cmp	w5, #0xf0
   92998:	54000740 	b.eq	92a80 <__utf8_mbtowc+0x260>  // b.none
   9299c:	71023d1f 	cmp	w8, #0x8f
   929a0:	52801e80 	mov	w0, #0xf4                  	// #244
   929a4:	7a40c0a0 	ccmp	w5, w0, #0x0, gt
   929a8:	54000700 	b.eq	92a88 <__utf8_mbtowc+0x268>  // b.none
   929ac:	51020100 	sub	w0, w8, #0x80
   929b0:	7100fc1f 	cmp	w0, #0x3f
   929b4:	540006a8 	b.hi	92a88 <__utf8_mbtowc+0x268>  // b.pmore
   929b8:	39001488 	strb	w8, [x4, #5]
   929bc:	710004ff 	cmp	w7, #0x1
   929c0:	540006c0 	b.eq	92a98 <__utf8_mbtowc+0x278>  // b.none
   929c4:	b9400080 	ldr	w0, [x4]
   929c8:	b100047f 	cmn	x3, #0x1
   929cc:	9a830463 	cinc	x3, x3, ne	// ne = any
   929d0:	7100081f 	cmp	w0, #0x2
   929d4:	540006a0 	b.eq	92aa8 <__utf8_mbtowc+0x288>  // b.none
   929d8:	39401887 	ldrb	w7, [x4, #6]
   929dc:	510200e0 	sub	w0, w7, #0x80
   929e0:	7100fc1f 	cmp	w0, #0x3f
   929e4:	54000528 	b.hi	92a88 <__utf8_mbtowc+0x268>  // b.pmore
   929e8:	3866c843 	ldrb	w3, [x2, w6, sxtw]
   929ec:	110004c0 	add	w0, w6, #0x1
   929f0:	51020062 	sub	w2, w3, #0x80
   929f4:	7100fc5f 	cmp	w2, #0x3f
   929f8:	54000488 	b.hi	92a88 <__utf8_mbtowc+0x268>  // b.pmore
   929fc:	530e08a2 	ubfiz	w2, w5, #18, #3
   92a00:	53141508 	ubfiz	w8, w8, #12, #6
   92a04:	531a14e7 	ubfiz	w7, w7, #6, #6
   92a08:	12001463 	and	w3, w3, #0x3f
   92a0c:	2a080042 	orr	w2, w2, w8
   92a10:	2a0300e7 	orr	w7, w7, w3
   92a14:	2a070042 	orr	w2, w2, w7
   92a18:	b9000022 	str	w2, [x1]
   92a1c:	b900009f 	str	wzr, [x4]
   92a20:	17ffffab 	b	928cc <__utf8_mbtowc+0xac>
   92a24:	52800020 	mov	w0, #0x1                   	// #1
   92a28:	b9000080 	str	w0, [x4]
   92a2c:	f100047f 	cmp	x3, #0x1
   92a30:	54000240 	b.eq	92a78 <__utf8_mbtowc+0x258>  // b.none
   92a34:	3866c848 	ldrb	w8, [x2, w6, sxtw]
   92a38:	52800027 	mov	w7, #0x1                   	// #1
   92a3c:	0b0700c6 	add	w6, w6, w7
   92a40:	17ffffaf 	b	928fc <__utf8_mbtowc+0xdc>
   92a44:	52800020 	mov	w0, #0x1                   	// #1
   92a48:	b9000080 	str	w0, [x4]
   92a4c:	f100047f 	cmp	x3, #0x1
   92a50:	54000140 	b.eq	92a78 <__utf8_mbtowc+0x258>  // b.none
   92a54:	3866c848 	ldrb	w8, [x2, w6, sxtw]
   92a58:	52800027 	mov	w7, #0x1                   	// #1
   92a5c:	0b0700c6 	add	w6, w6, w7
   92a60:	17ffffcd 	b	92994 <__utf8_mbtowc+0x174>
   92a64:	52800040 	mov	w0, #0x2                   	// #2
   92a68:	b9000080 	str	w0, [x4]
   92a6c:	f100087f 	cmp	x3, #0x2
   92a70:	54fff5a1 	b.ne	92924 <__utf8_mbtowc+0x104>  // b.any
   92a74:	d503201f 	nop
   92a78:	12800020 	mov	w0, #0xfffffffe            	// #-2
   92a7c:	17ffff94 	b	928cc <__utf8_mbtowc+0xac>
   92a80:	71023d1f 	cmp	w8, #0x8f
   92a84:	54fff94c 	b.gt	929ac <__utf8_mbtowc+0x18c>
   92a88:	52801141 	mov	w1, #0x8a                  	// #138
   92a8c:	12800000 	mov	w0, #0xffffffff            	// #-1
   92a90:	b9000121 	str	w1, [x9]
   92a94:	17ffff8e 	b	928cc <__utf8_mbtowc+0xac>
   92a98:	52800040 	mov	w0, #0x2                   	// #2
   92a9c:	b9000080 	str	w0, [x4]
   92aa0:	f100087f 	cmp	x3, #0x2
   92aa4:	54fffea0 	b.eq	92a78 <__utf8_mbtowc+0x258>  // b.none
   92aa8:	3866c847 	ldrb	w7, [x2, w6, sxtw]
   92aac:	110004c6 	add	w6, w6, #0x1
   92ab0:	510200e0 	sub	w0, w7, #0x80
   92ab4:	7100fc1f 	cmp	w0, #0x3f
   92ab8:	54fffe88 	b.hi	92a88 <__utf8_mbtowc+0x268>  // b.pmore
   92abc:	52800060 	mov	w0, #0x3                   	// #3
   92ac0:	b9000080 	str	w0, [x4]
   92ac4:	39001887 	strb	w7, [x4, #6]
   92ac8:	f1000c7f 	cmp	x3, #0x3
   92acc:	54fff8e1 	b.ne	929e8 <__utf8_mbtowc+0x1c8>  // b.any
   92ad0:	12800020 	mov	w0, #0xfffffffe            	// #-2
   92ad4:	17ffff7e 	b	928cc <__utf8_mbtowc+0xac>
	...

0000000000092ae0 <__sjis_mbtowc>:
   92ae0:	d10043ff 	sub	sp, sp, #0x10
   92ae4:	f100003f 	cmp	x1, #0x0
   92ae8:	910033e5 	add	x5, sp, #0xc
   92aec:	9a8100a1 	csel	x1, x5, x1, eq	// eq = none
   92af0:	b40004c2 	cbz	x2, 92b88 <__sjis_mbtowc+0xa8>
   92af4:	b4000503 	cbz	x3, 92b94 <__sjis_mbtowc+0xb4>
   92af8:	aa0003e6 	mov	x6, x0
   92afc:	b9400080 	ldr	w0, [x4]
   92b00:	39400045 	ldrb	w5, [x2]
   92b04:	35000320 	cbnz	w0, 92b68 <__sjis_mbtowc+0x88>
   92b08:	510204a7 	sub	w7, w5, #0x81
   92b0c:	510380a0 	sub	w0, w5, #0xe0
   92b10:	710078ff 	cmp	w7, #0x1e
   92b14:	7a4f8800 	ccmp	w0, #0xf, #0x0, hi	// hi = pmore
   92b18:	540002c8 	b.hi	92b70 <__sjis_mbtowc+0x90>  // b.pmore
   92b1c:	52800020 	mov	w0, #0x1                   	// #1
   92b20:	b9000080 	str	w0, [x4]
   92b24:	39001085 	strb	w5, [x4, #4]
   92b28:	f100047f 	cmp	x3, #0x1
   92b2c:	54000340 	b.eq	92b94 <__sjis_mbtowc+0xb4>  // b.none
   92b30:	39400445 	ldrb	w5, [x2, #1]
   92b34:	52800040 	mov	w0, #0x2                   	// #2
   92b38:	510100a3 	sub	w3, w5, #0x40
   92b3c:	510200a2 	sub	w2, w5, #0x80
   92b40:	7100f87f 	cmp	w3, #0x3e
   92b44:	52800f83 	mov	w3, #0x7c                  	// #124
   92b48:	7a438040 	ccmp	w2, w3, #0x0, hi	// hi = pmore
   92b4c:	54000288 	b.hi	92b9c <__sjis_mbtowc+0xbc>  // b.pmore
   92b50:	39401082 	ldrb	w2, [x4, #4]
   92b54:	0b0220a2 	add	w2, w5, w2, lsl #8
   92b58:	b9000022 	str	w2, [x1]
   92b5c:	b900009f 	str	wzr, [x4]
   92b60:	910043ff 	add	sp, sp, #0x10
   92b64:	d65f03c0 	ret
   92b68:	7100041f 	cmp	w0, #0x1
   92b6c:	54fffe60 	b.eq	92b38 <__sjis_mbtowc+0x58>  // b.none
   92b70:	b9000025 	str	w5, [x1]
   92b74:	39400040 	ldrb	w0, [x2]
   92b78:	7100001f 	cmp	w0, #0x0
   92b7c:	1a9f07e0 	cset	w0, ne	// ne = any
   92b80:	910043ff 	add	sp, sp, #0x10
   92b84:	d65f03c0 	ret
   92b88:	52800000 	mov	w0, #0x0                   	// #0
   92b8c:	910043ff 	add	sp, sp, #0x10
   92b90:	d65f03c0 	ret
   92b94:	12800020 	mov	w0, #0xfffffffe            	// #-2
   92b98:	17fffffa 	b	92b80 <__sjis_mbtowc+0xa0>
   92b9c:	52801141 	mov	w1, #0x8a                  	// #138
   92ba0:	12800000 	mov	w0, #0xffffffff            	// #-1
   92ba4:	b90000c1 	str	w1, [x6]
   92ba8:	17fffff6 	b	92b80 <__sjis_mbtowc+0xa0>
   92bac:	00000000 	udf	#0

0000000000092bb0 <__eucjp_mbtowc>:
   92bb0:	d10043ff 	sub	sp, sp, #0x10
   92bb4:	f100003f 	cmp	x1, #0x0
   92bb8:	910033e6 	add	x6, sp, #0xc
   92bbc:	9a8100c1 	csel	x1, x6, x1, eq	// eq = none
   92bc0:	b4000782 	cbz	x2, 92cb0 <__eucjp_mbtowc+0x100>
   92bc4:	b40007c3 	cbz	x3, 92cbc <__eucjp_mbtowc+0x10c>
   92bc8:	aa0003e5 	mov	x5, x0
   92bcc:	b9400080 	ldr	w0, [x4]
   92bd0:	39400046 	ldrb	w6, [x2]
   92bd4:	35000380 	cbnz	w0, 92c44 <__eucjp_mbtowc+0x94>
   92bd8:	510284c7 	sub	w7, w6, #0xa1
   92bdc:	510238c0 	sub	w0, w6, #0x8e
   92be0:	710174ff 	cmp	w7, #0x5d
   92be4:	7a418800 	ccmp	w0, #0x1, #0x0, hi	// hi = pmore
   92be8:	54000388 	b.hi	92c58 <__eucjp_mbtowc+0xa8>  // b.pmore
   92bec:	52800020 	mov	w0, #0x1                   	// #1
   92bf0:	b9000080 	str	w0, [x4]
   92bf4:	39001086 	strb	w6, [x4, #4]
   92bf8:	f100047f 	cmp	x3, #0x1
   92bfc:	54000600 	b.eq	92cbc <__eucjp_mbtowc+0x10c>  // b.none
   92c00:	39400447 	ldrb	w7, [x2, #1]
   92c04:	52800040 	mov	w0, #0x2                   	// #2
   92c08:	510284e6 	sub	w6, w7, #0xa1
   92c0c:	710174df 	cmp	w6, #0x5d
   92c10:	540005a8 	b.hi	92cc4 <__eucjp_mbtowc+0x114>  // b.pmore
   92c14:	39401086 	ldrb	w6, [x4, #4]
   92c18:	71023cdf 	cmp	w6, #0x8f
   92c1c:	54000401 	b.ne	92c9c <__eucjp_mbtowc+0xec>  // b.any
   92c20:	52800048 	mov	w8, #0x2                   	// #2
   92c24:	93407c06 	sxtw	x6, w0
   92c28:	b9000088 	str	w8, [x4]
   92c2c:	39001487 	strb	w7, [x4, #5]
   92c30:	eb0300df 	cmp	x6, x3
   92c34:	54000442 	b.cs	92cbc <__eucjp_mbtowc+0x10c>  // b.hs, b.nlast
   92c38:	38666847 	ldrb	w7, [x2, x6]
   92c3c:	11000400 	add	w0, w0, #0x1
   92c40:	1400000d 	b	92c74 <__eucjp_mbtowc+0xc4>
   92c44:	2a0603e7 	mov	w7, w6
   92c48:	7100041f 	cmp	w0, #0x1
   92c4c:	54fffde0 	b.eq	92c08 <__eucjp_mbtowc+0x58>  // b.none
   92c50:	7100081f 	cmp	w0, #0x2
   92c54:	540000e0 	b.eq	92c70 <__eucjp_mbtowc+0xc0>  // b.none
   92c58:	b9000026 	str	w6, [x1]
   92c5c:	39400040 	ldrb	w0, [x2]
   92c60:	7100001f 	cmp	w0, #0x0
   92c64:	1a9f07e0 	cset	w0, ne	// ne = any
   92c68:	910043ff 	add	sp, sp, #0x10
   92c6c:	d65f03c0 	ret
   92c70:	52800020 	mov	w0, #0x1                   	// #1
   92c74:	510284e2 	sub	w2, w7, #0xa1
   92c78:	7101745f 	cmp	w2, #0x5d
   92c7c:	54000248 	b.hi	92cc4 <__eucjp_mbtowc+0x114>  // b.pmore
   92c80:	39401482 	ldrb	w2, [x4, #5]
   92c84:	120018e7 	and	w7, w7, #0x7f
   92c88:	0b0220e2 	add	w2, w7, w2, lsl #8
   92c8c:	b9000022 	str	w2, [x1]
   92c90:	b900009f 	str	wzr, [x4]
   92c94:	910043ff 	add	sp, sp, #0x10
   92c98:	d65f03c0 	ret
   92c9c:	0b0620e6 	add	w6, w7, w6, lsl #8
   92ca0:	b9000026 	str	w6, [x1]
   92ca4:	b900009f 	str	wzr, [x4]
   92ca8:	910043ff 	add	sp, sp, #0x10
   92cac:	d65f03c0 	ret
   92cb0:	52800000 	mov	w0, #0x0                   	// #0
   92cb4:	910043ff 	add	sp, sp, #0x10
   92cb8:	d65f03c0 	ret
   92cbc:	12800020 	mov	w0, #0xfffffffe            	// #-2
   92cc0:	17ffffea 	b	92c68 <__eucjp_mbtowc+0xb8>
   92cc4:	52801141 	mov	w1, #0x8a                  	// #138
   92cc8:	12800000 	mov	w0, #0xffffffff            	// #-1
   92ccc:	b90000a1 	str	w1, [x5]
   92cd0:	17ffffe6 	b	92c68 <__eucjp_mbtowc+0xb8>
	...

0000000000092ce0 <__jis_mbtowc>:
   92ce0:	d10043ff 	sub	sp, sp, #0x10
   92ce4:	f100003f 	cmp	x1, #0x0
   92ce8:	910033e5 	add	x5, sp, #0xc
   92cec:	9a8100a1 	csel	x1, x5, x1, eq	// eq = none
   92cf0:	b4000d62 	cbz	x2, 92e9c <__jis_mbtowc+0x1bc>
   92cf4:	b4000a03 	cbz	x3, 92e34 <__jis_mbtowc+0x154>
   92cf8:	39400085 	ldrb	w5, [x4]
   92cfc:	f000000c 	adrp	x12, 95000 <pmu_event_descr+0x60>
   92d00:	f000000b 	adrp	x11, 95000 <pmu_event_descr+0x60>
   92d04:	aa0003ed 	mov	x13, x0
   92d08:	913d018c 	add	x12, x12, #0xf40
   92d0c:	913e416b 	add	x11, x11, #0xf90
   92d10:	aa0203ef 	mov	x15, x2
   92d14:	5280000a 	mov	w10, #0x0                   	// #0
   92d18:	d2800009 	mov	x9, #0x0                   	// #0
   92d1c:	38696847 	ldrb	w7, [x2, x9]
   92d20:	8b09004e 	add	x14, x2, x9
   92d24:	7100a0ff 	cmp	w7, #0x28
   92d28:	54000c20 	b.eq	92eac <__jis_mbtowc+0x1cc>  // b.none
   92d2c:	540004c8 	b.hi	92dc4 <__jis_mbtowc+0xe4>  // b.pmore
   92d30:	52800006 	mov	w6, #0x0                   	// #0
   92d34:	71006cff 	cmp	w7, #0x1b
   92d38:	54000080 	b.eq	92d48 <__jis_mbtowc+0x68>  // b.none
   92d3c:	52800026 	mov	w6, #0x1                   	// #1
   92d40:	710090ff 	cmp	w7, #0x24
   92d44:	540007c1 	b.ne	92e3c <__jis_mbtowc+0x15c>  // b.any
   92d48:	937d7ca0 	sbfiz	x0, x5, #3, #32
   92d4c:	8b25c005 	add	x5, x0, w5, sxtw
   92d50:	8b050180 	add	x0, x12, x5
   92d54:	8b050165 	add	x5, x11, x5
   92d58:	3866c808 	ldrb	w8, [x0, w6, sxtw]
   92d5c:	3866c8a5 	ldrb	w5, [x5, w6, sxtw]
   92d60:	71000d1f 	cmp	w8, #0x3
   92d64:	540005a0 	b.eq	92e18 <__jis_mbtowc+0x138>  // b.none
   92d68:	540001c8 	b.hi	92da0 <__jis_mbtowc+0xc0>  // b.pmore
   92d6c:	7100051f 	cmp	w8, #0x1
   92d70:	540007e0 	b.eq	92e6c <__jis_mbtowc+0x18c>  // b.none
   92d74:	7100091f 	cmp	w8, #0x2
   92d78:	54000861 	b.ne	92e84 <__jis_mbtowc+0x1a4>  // b.any
   92d7c:	52800020 	mov	w0, #0x1                   	// #1
   92d80:	b9000080 	str	w0, [x4]
   92d84:	39401082 	ldrb	w2, [x4, #4]
   92d88:	0b000140 	add	w0, w10, w0
   92d8c:	394001c3 	ldrb	w3, [x14]
   92d90:	0b022062 	add	w2, w3, w2, lsl #8
   92d94:	b9000022 	str	w2, [x1]
   92d98:	910043ff 	add	sp, sp, #0x10
   92d9c:	d65f03c0 	ret
   92da0:	7100111f 	cmp	w8, #0x4
   92da4:	540003e0 	b.eq	92e20 <__jis_mbtowc+0x140>  // b.none
   92da8:	7100151f 	cmp	w8, #0x5
   92dac:	54000561 	b.ne	92e58 <__jis_mbtowc+0x178>  // b.any
   92db0:	b900009f 	str	wzr, [x4]
   92db4:	52800000 	mov	w0, #0x0                   	// #0
   92db8:	b900003f 	str	wzr, [x1]
   92dbc:	910043ff 	add	sp, sp, #0x10
   92dc0:	d65f03c0 	ret
   92dc4:	52800086 	mov	w6, #0x4                   	// #4
   92dc8:	710108ff 	cmp	w7, #0x42
   92dcc:	54fffbe0 	b.eq	92d48 <__jis_mbtowc+0x68>  // b.none
   92dd0:	528000a6 	mov	w6, #0x5                   	// #5
   92dd4:	710128ff 	cmp	w7, #0x4a
   92dd8:	54fffb80 	b.eq	92d48 <__jis_mbtowc+0x68>  // b.none
   92ddc:	52800066 	mov	w6, #0x3                   	// #3
   92de0:	710100ff 	cmp	w7, #0x40
   92de4:	54fffb20 	b.eq	92d48 <__jis_mbtowc+0x68>  // b.none
   92de8:	510084e0 	sub	w0, w7, #0x21
   92dec:	7101741f 	cmp	w0, #0x5d
   92df0:	1a9f97e6 	cset	w6, hi	// hi = pmore
   92df4:	11001cc6 	add	w6, w6, #0x7
   92df8:	937d7ca0 	sbfiz	x0, x5, #3, #32
   92dfc:	8b25c005 	add	x5, x0, w5, sxtw
   92e00:	8b050180 	add	x0, x12, x5
   92e04:	8b050165 	add	x5, x11, x5
   92e08:	3866c808 	ldrb	w8, [x0, w6, sxtw]
   92e0c:	3866c8a5 	ldrb	w5, [x5, w6, sxtw]
   92e10:	71000d1f 	cmp	w8, #0x3
   92e14:	54fffaa1 	b.ne	92d68 <__jis_mbtowc+0x88>  // b.any
   92e18:	91000529 	add	x9, x9, #0x1
   92e1c:	8b09004f 	add	x15, x2, x9
   92e20:	11000549 	add	w9, w10, #0x1
   92e24:	aa0903ea 	mov	x10, x9
   92e28:	eb03013f 	cmp	x9, x3
   92e2c:	54fff783 	b.cc	92d1c <__jis_mbtowc+0x3c>  // b.lo, b.ul, b.last
   92e30:	b9000085 	str	w5, [x4]
   92e34:	12800020 	mov	w0, #0xfffffffe            	// #-2
   92e38:	17ffffd8 	b	92d98 <__jis_mbtowc+0xb8>
   92e3c:	528000c6 	mov	w6, #0x6                   	// #6
   92e40:	34fff847 	cbz	w7, 92d48 <__jis_mbtowc+0x68>
   92e44:	510084e0 	sub	w0, w7, #0x21
   92e48:	7101741f 	cmp	w0, #0x5d
   92e4c:	1a9f97e6 	cset	w6, hi	// hi = pmore
   92e50:	11001cc6 	add	w6, w6, #0x7
   92e54:	17ffffe9 	b	92df8 <__jis_mbtowc+0x118>
   92e58:	52801141 	mov	w1, #0x8a                  	// #138
   92e5c:	b90001a1 	str	w1, [x13]
   92e60:	12800000 	mov	w0, #0xffffffff            	// #-1
   92e64:	910043ff 	add	sp, sp, #0x10
   92e68:	d65f03c0 	ret
   92e6c:	11000549 	add	w9, w10, #0x1
   92e70:	39001087 	strb	w7, [x4, #4]
   92e74:	aa0903ea 	mov	x10, x9
   92e78:	eb03013f 	cmp	x9, x3
   92e7c:	54fff503 	b.cc	92d1c <__jis_mbtowc+0x3c>  // b.lo, b.ul, b.last
   92e80:	17ffffec 	b	92e30 <__jis_mbtowc+0x150>
   92e84:	b900009f 	str	wzr, [x4]
   92e88:	11000540 	add	w0, w10, #0x1
   92e8c:	394001e2 	ldrb	w2, [x15]
   92e90:	b9000022 	str	w2, [x1]
   92e94:	910043ff 	add	sp, sp, #0x10
   92e98:	d65f03c0 	ret
   92e9c:	b900009f 	str	wzr, [x4]
   92ea0:	52800020 	mov	w0, #0x1                   	// #1
   92ea4:	910043ff 	add	sp, sp, #0x10
   92ea8:	d65f03c0 	ret
   92eac:	52800046 	mov	w6, #0x2                   	// #2
   92eb0:	17ffffa6 	b	92d48 <__jis_mbtowc+0x68>
	...

0000000000092ec0 <__assert_func>:
   92ec0:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   92ec4:	90000024 	adrp	x4, 96000 <JIS_state_table+0x70>
   92ec8:	aa0303e5 	mov	x5, x3
   92ecc:	910003fd 	mov	x29, sp
   92ed0:	f9410087 	ldr	x7, [x4, #512]
   92ed4:	aa0003e3 	mov	x3, x0
   92ed8:	aa0203e6 	mov	x6, x2
   92edc:	2a0103e4 	mov	w4, w1
   92ee0:	aa0503e2 	mov	x2, x5
   92ee4:	f0000005 	adrp	x5, 95000 <pmu_event_descr+0x60>
   92ee8:	f9400ce0 	ldr	x0, [x7, #24]
   92eec:	913f60a5 	add	x5, x5, #0xfd8
   92ef0:	b40000a6 	cbz	x6, 92f04 <__assert_func+0x44>
   92ef4:	f0000001 	adrp	x1, 95000 <pmu_event_descr+0x60>
   92ef8:	913fa021 	add	x1, x1, #0xfe8
   92efc:	94000535 	bl	943d0 <fiprintf>
   92f00:	94000554 	bl	94450 <abort>
   92f04:	d0000005 	adrp	x5, 94000 <__any_on>
   92f08:	9137a0a5 	add	x5, x5, #0xde8
   92f0c:	aa0503e6 	mov	x6, x5
   92f10:	17fffff9 	b	92ef4 <__assert_func+0x34>
	...

0000000000092f20 <__assert>:
   92f20:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   92f24:	aa0203e3 	mov	x3, x2
   92f28:	d2800002 	mov	x2, #0x0                   	// #0
   92f2c:	910003fd 	mov	x29, sp
   92f30:	97ffffe4 	bl	92ec0 <__assert_func>
	...

0000000000092f40 <strcasecmp>:
   92f40:	f0000006 	adrp	x6, 95000 <pmu_event_descr+0x60>
   92f44:	aa0003e8 	mov	x8, x0
   92f48:	913584c6 	add	x6, x6, #0xd61
   92f4c:	d2800003 	mov	x3, #0x0                   	// #0
   92f50:	38636902 	ldrb	w2, [x8, x3]
   92f54:	38636820 	ldrb	w0, [x1, x3]
   92f58:	11008047 	add	w7, w2, #0x20
   92f5c:	386248c5 	ldrb	w5, [x6, w2, uxtw]
   92f60:	386048c4 	ldrb	w4, [x6, w0, uxtw]
   92f64:	120004a5 	and	w5, w5, #0x3
   92f68:	710004bf 	cmp	w5, #0x1
   92f6c:	12000484 	and	w4, w4, #0x3
   92f70:	1a8200e2 	csel	w2, w7, w2, eq	// eq = none
   92f74:	7100049f 	cmp	w4, #0x1
   92f78:	540000c0 	b.eq	92f90 <strcasecmp+0x50>  // b.none
   92f7c:	6b000042 	subs	w2, w2, w0
   92f80:	54000121 	b.ne	92fa4 <strcasecmp+0x64>  // b.any
   92f84:	91000463 	add	x3, x3, #0x1
   92f88:	35fffe40 	cbnz	w0, 92f50 <strcasecmp+0x10>
   92f8c:	d65f03c0 	ret
   92f90:	11008000 	add	w0, w0, #0x20
   92f94:	91000463 	add	x3, x3, #0x1
   92f98:	6b000040 	subs	w0, w2, w0
   92f9c:	54fffda0 	b.eq	92f50 <strcasecmp+0x10>  // b.none
   92fa0:	d65f03c0 	ret
   92fa4:	2a0203e0 	mov	w0, w2
   92fa8:	d65f03c0 	ret
   92fac:	00000000 	udf	#0

0000000000092fb0 <strcat>:
   92fb0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   92fb4:	910003fd 	mov	x29, sp
   92fb8:	f9000bf3 	str	x19, [sp, #16]
   92fbc:	aa0003f3 	mov	x19, x0
   92fc0:	f240081f 	tst	x0, #0x7
   92fc4:	540001c1 	b.ne	92ffc <strcat+0x4c>  // b.any
   92fc8:	f9400002 	ldr	x2, [x0]
   92fcc:	b207dbe4 	mov	x4, #0xfefefefefefefefe    	// #-72340172838076674
   92fd0:	f29fdfe4 	movk	x4, #0xfeff
   92fd4:	8b040043 	add	x3, x2, x4
   92fd8:	8a220062 	bic	x2, x3, x2
   92fdc:	f201c05f 	tst	x2, #0x8080808080808080
   92fe0:	540000e1 	b.ne	92ffc <strcat+0x4c>  // b.any
   92fe4:	d503201f 	nop
   92fe8:	f8408c02 	ldr	x2, [x0, #8]!
   92fec:	8b040043 	add	x3, x2, x4
   92ff0:	8a220062 	bic	x2, x3, x2
   92ff4:	f201c05f 	tst	x2, #0x8080808080808080
   92ff8:	54ffff80 	b.eq	92fe8 <strcat+0x38>  // b.none
   92ffc:	39400002 	ldrb	w2, [x0]
   93000:	34000082 	cbz	w2, 93010 <strcat+0x60>
   93004:	d503201f 	nop
   93008:	38401c02 	ldrb	w2, [x0, #1]!
   9300c:	35ffffe2 	cbnz	w2, 93008 <strcat+0x58>
   93010:	97fff45c 	bl	90180 <strcpy>
   93014:	aa1303e0 	mov	x0, x19
   93018:	f9400bf3 	ldr	x19, [sp, #16]
   9301c:	a8c27bfd 	ldp	x29, x30, [sp], #32
   93020:	d65f03c0 	ret
	...

0000000000093030 <_Balloc>:
   93030:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   93034:	910003fd 	mov	x29, sp
   93038:	f9403402 	ldr	x2, [x0, #104]
   9303c:	a90153f3 	stp	x19, x20, [sp, #16]
   93040:	aa0003f3 	mov	x19, x0
   93044:	2a0103f4 	mov	w20, w1
   93048:	b4000142 	cbz	x2, 93070 <_Balloc+0x40>
   9304c:	93407e81 	sxtw	x1, w20
   93050:	f8617840 	ldr	x0, [x2, x1, lsl #3]
   93054:	b40001e0 	cbz	x0, 93090 <_Balloc+0x60>
   93058:	f9400003 	ldr	x3, [x0]
   9305c:	f8217843 	str	x3, [x2, x1, lsl #3]
   93060:	f900081f 	str	xzr, [x0, #16]
   93064:	a94153f3 	ldp	x19, x20, [sp, #16]
   93068:	a8c27bfd 	ldp	x29, x30, [sp], #32
   9306c:	d65f03c0 	ret
   93070:	d2800822 	mov	x2, #0x41                  	// #65
   93074:	d2800101 	mov	x1, #0x8                   	// #8
   93078:	940003fe 	bl	94070 <_calloc_r>
   9307c:	f9003660 	str	x0, [x19, #104]
   93080:	aa0003e2 	mov	x2, x0
   93084:	b5fffe40 	cbnz	x0, 9304c <_Balloc+0x1c>
   93088:	d2800000 	mov	x0, #0x0                   	// #0
   9308c:	17fffff6 	b	93064 <_Balloc+0x34>
   93090:	52800021 	mov	w1, #0x1                   	// #1
   93094:	aa1303e0 	mov	x0, x19
   93098:	1ad42033 	lsl	w19, w1, w20
   9309c:	d2800021 	mov	x1, #0x1                   	// #1
   930a0:	93407e62 	sxtw	x2, w19
   930a4:	91001c42 	add	x2, x2, #0x7
   930a8:	d37ef442 	lsl	x2, x2, #2
   930ac:	940003f1 	bl	94070 <_calloc_r>
   930b0:	b4fffec0 	cbz	x0, 93088 <_Balloc+0x58>
   930b4:	29014c14 	stp	w20, w19, [x0, #8]
   930b8:	17ffffea 	b	93060 <_Balloc+0x30>
   930bc:	00000000 	udf	#0

00000000000930c0 <_Bfree>:
   930c0:	b40000c1 	cbz	x1, 930d8 <_Bfree+0x18>
   930c4:	f9403400 	ldr	x0, [x0, #104]
   930c8:	b9800822 	ldrsw	x2, [x1, #8]
   930cc:	f8627803 	ldr	x3, [x0, x2, lsl #3]
   930d0:	f9000023 	str	x3, [x1]
   930d4:	f8227801 	str	x1, [x0, x2, lsl #3]
   930d8:	d65f03c0 	ret
   930dc:	00000000 	udf	#0

00000000000930e0 <__multadd>:
   930e0:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
   930e4:	91006027 	add	x7, x1, #0x18
   930e8:	d2800005 	mov	x5, #0x0                   	// #0
   930ec:	910003fd 	mov	x29, sp
   930f0:	a90153f3 	stp	x19, x20, [sp, #16]
   930f4:	2a0303f3 	mov	w19, w3
   930f8:	b9401434 	ldr	w20, [x1, #20]
   930fc:	a9025bf5 	stp	x21, x22, [sp, #32]
   93100:	aa0103f5 	mov	x21, x1
   93104:	aa0003f6 	mov	x22, x0
   93108:	b86578e4 	ldr	w4, [x7, x5, lsl #2]
   9310c:	12003c83 	and	w3, w4, #0xffff
   93110:	53107c84 	lsr	w4, w4, #16
   93114:	1b024c63 	madd	w3, w3, w2, w19
   93118:	12003c66 	and	w6, w3, #0xffff
   9311c:	53107c63 	lsr	w3, w3, #16
   93120:	1b020c83 	madd	w3, w4, w2, w3
   93124:	0b0340c4 	add	w4, w6, w3, lsl #16
   93128:	b82578e4 	str	w4, [x7, x5, lsl #2]
   9312c:	910004a5 	add	x5, x5, #0x1
   93130:	53107c73 	lsr	w19, w3, #16
   93134:	6b05029f 	cmp	w20, w5
   93138:	54fffe8c 	b.gt	93108 <__multadd+0x28>
   9313c:	34000113 	cbz	w19, 9315c <__multadd+0x7c>
   93140:	b9400ea0 	ldr	w0, [x21, #12]
   93144:	6b14001f 	cmp	w0, w20
   93148:	5400014d 	b.le	93170 <__multadd+0x90>
   9314c:	8b34caa0 	add	x0, x21, w20, sxtw #2
   93150:	11000694 	add	w20, w20, #0x1
   93154:	b9001813 	str	w19, [x0, #24]
   93158:	b90016b4 	str	w20, [x21, #20]
   9315c:	a94153f3 	ldp	x19, x20, [sp, #16]
   93160:	aa1503e0 	mov	x0, x21
   93164:	a9425bf5 	ldp	x21, x22, [sp, #32]
   93168:	a8c47bfd 	ldp	x29, x30, [sp], #64
   9316c:	d65f03c0 	ret
   93170:	b9400aa1 	ldr	w1, [x21, #8]
   93174:	aa1603e0 	mov	x0, x22
   93178:	f9001bf7 	str	x23, [sp, #48]
   9317c:	11000421 	add	w1, w1, #0x1
   93180:	97ffffac 	bl	93030 <_Balloc>
   93184:	aa0003f7 	mov	x23, x0
   93188:	b4000260 	cbz	x0, 931d4 <__multadd+0xf4>
   9318c:	b98016a2 	ldrsw	x2, [x21, #20]
   93190:	910042a1 	add	x1, x21, #0x10
   93194:	91004000 	add	x0, x0, #0x10
   93198:	91000842 	add	x2, x2, #0x2
   9319c:	d37ef442 	lsl	x2, x2, #2
   931a0:	97ffe808 	bl	8d1c0 <memcpy>
   931a4:	f94036c0 	ldr	x0, [x22, #104]
   931a8:	b9800aa1 	ldrsw	x1, [x21, #8]
   931ac:	f8617802 	ldr	x2, [x0, x1, lsl #3]
   931b0:	f90002a2 	str	x2, [x21]
   931b4:	f8217815 	str	x21, [x0, x1, lsl #3]
   931b8:	aa1703f5 	mov	x21, x23
   931bc:	8b34caa0 	add	x0, x21, w20, sxtw #2
   931c0:	11000694 	add	w20, w20, #0x1
   931c4:	f9401bf7 	ldr	x23, [sp, #48]
   931c8:	b9001813 	str	w19, [x0, #24]
   931cc:	b90016b4 	str	w20, [x21, #20]
   931d0:	17ffffe3 	b	9315c <__multadd+0x7c>
   931d4:	d0000003 	adrp	x3, 95000 <pmu_event_descr+0x60>
   931d8:	f0000000 	adrp	x0, 96000 <JIS_state_table+0x70>
   931dc:	91334063 	add	x3, x3, #0xcd0
   931e0:	91006000 	add	x0, x0, #0x18
   931e4:	d2800002 	mov	x2, #0x0                   	// #0
   931e8:	52801741 	mov	w1, #0xba                  	// #186
   931ec:	97ffff35 	bl	92ec0 <__assert_func>

00000000000931f0 <__s2b>:
   931f0:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
   931f4:	5291c725 	mov	w5, #0x8e39                	// #36409
   931f8:	72a71c65 	movk	w5, #0x38e3, lsl #16
   931fc:	910003fd 	mov	x29, sp
   93200:	a9025bf5 	stp	x21, x22, [sp, #32]
   93204:	2a0303f5 	mov	w21, w3
   93208:	11002063 	add	w3, w3, #0x8
   9320c:	a90153f3 	stp	x19, x20, [sp, #16]
   93210:	2a0203f6 	mov	w22, w2
   93214:	aa0003f4 	mov	x20, x0
   93218:	9b257c65 	smull	x5, w3, w5
   9321c:	a90363f7 	stp	x23, x24, [sp, #48]
   93220:	aa0103f3 	mov	x19, x1
   93224:	2a0403f7 	mov	w23, w4
   93228:	9361fca5 	asr	x5, x5, #33
   9322c:	4b837ca2 	sub	w2, w5, w3, asr #31
   93230:	710026bf 	cmp	w21, #0x9
   93234:	5400064d 	b.le	932fc <__s2b+0x10c>
   93238:	52800020 	mov	w0, #0x1                   	// #1
   9323c:	52800001 	mov	w1, #0x0                   	// #0
   93240:	531f7800 	lsl	w0, w0, #1
   93244:	11000421 	add	w1, w1, #0x1
   93248:	6b00005f 	cmp	w2, w0
   9324c:	54ffffac 	b.gt	93240 <__s2b+0x50>
   93250:	aa1403e0 	mov	x0, x20
   93254:	97ffff77 	bl	93030 <_Balloc>
   93258:	aa0003e1 	mov	x1, x0
   9325c:	b4000540 	cbz	x0, 93304 <__s2b+0x114>
   93260:	52800020 	mov	w0, #0x1                   	// #1
   93264:	2902dc20 	stp	w0, w23, [x1, #20]
   93268:	710026df 	cmp	w22, #0x9
   9326c:	540002ac 	b.gt	932c0 <__s2b+0xd0>
   93270:	91002a73 	add	x19, x19, #0xa
   93274:	52800136 	mov	w22, #0x9                   	// #9
   93278:	6b1602bf 	cmp	w21, w22
   9327c:	5400016d 	b.le	932a8 <__s2b+0xb8>
   93280:	4b1602b5 	sub	w21, w21, w22
   93284:	8b150275 	add	x21, x19, x21
   93288:	38401663 	ldrb	w3, [x19], #1
   9328c:	aa1403e0 	mov	x0, x20
   93290:	52800142 	mov	w2, #0xa                   	// #10
   93294:	5100c063 	sub	w3, w3, #0x30
   93298:	97ffff92 	bl	930e0 <__multadd>
   9329c:	aa0003e1 	mov	x1, x0
   932a0:	eb15027f 	cmp	x19, x21
   932a4:	54ffff21 	b.ne	93288 <__s2b+0x98>  // b.any
   932a8:	a94153f3 	ldp	x19, x20, [sp, #16]
   932ac:	aa0103e0 	mov	x0, x1
   932b0:	a9425bf5 	ldp	x21, x22, [sp, #32]
   932b4:	a94363f7 	ldp	x23, x24, [sp, #48]
   932b8:	a8c47bfd 	ldp	x29, x30, [sp], #64
   932bc:	d65f03c0 	ret
   932c0:	91002678 	add	x24, x19, #0x9
   932c4:	8b364273 	add	x19, x19, w22, uxtw
   932c8:	aa1803f7 	mov	x23, x24
   932cc:	d503201f 	nop
   932d0:	384016e3 	ldrb	w3, [x23], #1
   932d4:	aa1403e0 	mov	x0, x20
   932d8:	52800142 	mov	w2, #0xa                   	// #10
   932dc:	5100c063 	sub	w3, w3, #0x30
   932e0:	97ffff80 	bl	930e0 <__multadd>
   932e4:	aa0003e1 	mov	x1, x0
   932e8:	eb1302ff 	cmp	x23, x19
   932ec:	54ffff21 	b.ne	932d0 <__s2b+0xe0>  // b.any
   932f0:	510022d3 	sub	w19, w22, #0x8
   932f4:	8b130313 	add	x19, x24, x19
   932f8:	17ffffe0 	b	93278 <__s2b+0x88>
   932fc:	52800001 	mov	w1, #0x0                   	// #0
   93300:	17ffffd4 	b	93250 <__s2b+0x60>
   93304:	d0000003 	adrp	x3, 95000 <pmu_event_descr+0x60>
   93308:	f0000000 	adrp	x0, 96000 <JIS_state_table+0x70>
   9330c:	91334063 	add	x3, x3, #0xcd0
   93310:	91006000 	add	x0, x0, #0x18
   93314:	d2800002 	mov	x2, #0x0                   	// #0
   93318:	52801a61 	mov	w1, #0xd3                  	// #211
   9331c:	97fffee9 	bl	92ec0 <__assert_func>

0000000000093320 <__hi0bits>:
   93320:	2a0003e1 	mov	w1, w0
   93324:	529fffe2 	mov	w2, #0xffff                	// #65535
   93328:	52800000 	mov	w0, #0x0                   	// #0
   9332c:	6b02003f 	cmp	w1, w2
   93330:	54000068 	b.hi	9333c <__hi0bits+0x1c>  // b.pmore
   93334:	53103c21 	lsl	w1, w1, #16
   93338:	52800200 	mov	w0, #0x10                  	// #16
   9333c:	12bfe002 	mov	w2, #0xffffff              	// #16777215
   93340:	6b02003f 	cmp	w1, w2
   93344:	54000068 	b.hi	93350 <__hi0bits+0x30>  // b.pmore
   93348:	11002000 	add	w0, w0, #0x8
   9334c:	53185c21 	lsl	w1, w1, #8
   93350:	12be0002 	mov	w2, #0xfffffff             	// #268435455
   93354:	6b02003f 	cmp	w1, w2
   93358:	54000068 	b.hi	93364 <__hi0bits+0x44>  // b.pmore
   9335c:	11001000 	add	w0, w0, #0x4
   93360:	531c6c21 	lsl	w1, w1, #4
   93364:	12b80002 	mov	w2, #0x3fffffff            	// #1073741823
   93368:	6b02003f 	cmp	w1, w2
   9336c:	54000089 	b.ls	9337c <__hi0bits+0x5c>  // b.plast
   93370:	2a2103e1 	mvn	w1, w1
   93374:	0b417c00 	add	w0, w0, w1, lsr #31
   93378:	d65f03c0 	ret
   9337c:	531e7422 	lsl	w2, w1, #2
   93380:	37e800c1 	tbnz	w1, #29, 93398 <__hi0bits+0x78>
   93384:	f262005f 	tst	x2, #0x40000000
   93388:	11000c00 	add	w0, w0, #0x3
   9338c:	52800401 	mov	w1, #0x20                  	// #32
   93390:	1a811000 	csel	w0, w0, w1, ne	// ne = any
   93394:	d65f03c0 	ret
   93398:	11000800 	add	w0, w0, #0x2
   9339c:	d65f03c0 	ret

00000000000933a0 <__lo0bits>:
   933a0:	aa0003e2 	mov	x2, x0
   933a4:	52800000 	mov	w0, #0x0                   	// #0
   933a8:	b9400041 	ldr	w1, [x2]
   933ac:	f240083f 	tst	x1, #0x7
   933b0:	540000e0 	b.eq	933cc <__lo0bits+0x2c>  // b.none
   933b4:	370000a1 	tbnz	w1, #0, 933c8 <__lo0bits+0x28>
   933b8:	360803a1 	tbz	w1, #1, 9342c <__lo0bits+0x8c>
   933bc:	53017c21 	lsr	w1, w1, #1
   933c0:	52800020 	mov	w0, #0x1                   	// #1
   933c4:	b9000041 	str	w1, [x2]
   933c8:	d65f03c0 	ret
   933cc:	72003c3f 	tst	w1, #0xffff
   933d0:	54000061 	b.ne	933dc <__lo0bits+0x3c>  // b.any
   933d4:	53107c21 	lsr	w1, w1, #16
   933d8:	52800200 	mov	w0, #0x10                  	// #16
   933dc:	72001c3f 	tst	w1, #0xff
   933e0:	54000061 	b.ne	933ec <__lo0bits+0x4c>  // b.any
   933e4:	11002000 	add	w0, w0, #0x8
   933e8:	53087c21 	lsr	w1, w1, #8
   933ec:	f2400c3f 	tst	x1, #0xf
   933f0:	54000061 	b.ne	933fc <__lo0bits+0x5c>  // b.any
   933f4:	11001000 	add	w0, w0, #0x4
   933f8:	53047c21 	lsr	w1, w1, #4
   933fc:	f240043f 	tst	x1, #0x3
   93400:	54000061 	b.ne	9340c <__lo0bits+0x6c>  // b.any
   93404:	11000800 	add	w0, w0, #0x2
   93408:	53027c21 	lsr	w1, w1, #2
   9340c:	37000081 	tbnz	w1, #0, 9341c <__lo0bits+0x7c>
   93410:	11000400 	add	w0, w0, #0x1
   93414:	53017c21 	lsr	w1, w1, #1
   93418:	34000061 	cbz	w1, 93424 <__lo0bits+0x84>
   9341c:	b9000041 	str	w1, [x2]
   93420:	d65f03c0 	ret
   93424:	52800400 	mov	w0, #0x20                  	// #32
   93428:	d65f03c0 	ret
   9342c:	53027c21 	lsr	w1, w1, #2
   93430:	52800040 	mov	w0, #0x2                   	// #2
   93434:	b9000041 	str	w1, [x2]
   93438:	d65f03c0 	ret
   9343c:	00000000 	udf	#0

0000000000093440 <__i2b>:
   93440:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   93444:	910003fd 	mov	x29, sp
   93448:	f9403402 	ldr	x2, [x0, #104]
   9344c:	a90153f3 	stp	x19, x20, [sp, #16]
   93450:	aa0003f3 	mov	x19, x0
   93454:	2a0103f4 	mov	w20, w1
   93458:	b4000182 	cbz	x2, 93488 <__i2b+0x48>
   9345c:	f9400440 	ldr	x0, [x2, #8]
   93460:	b40002e0 	cbz	x0, 934bc <__i2b+0x7c>
   93464:	f9400001 	ldr	x1, [x0]
   93468:	f9000441 	str	x1, [x2, #8]
   9346c:	f0000001 	adrp	x1, 96000 <JIS_state_table+0x70>
   93470:	b9001814 	str	w20, [x0, #24]
   93474:	a94153f3 	ldp	x19, x20, [sp, #16]
   93478:	fd40e020 	ldr	d0, [x1, #448]
   9347c:	fd000800 	str	d0, [x0, #16]
   93480:	a8c27bfd 	ldp	x29, x30, [sp], #32
   93484:	d65f03c0 	ret
   93488:	d2800822 	mov	x2, #0x41                  	// #65
   9348c:	d2800101 	mov	x1, #0x8                   	// #8
   93490:	940002f8 	bl	94070 <_calloc_r>
   93494:	f9003660 	str	x0, [x19, #104]
   93498:	aa0003e2 	mov	x2, x0
   9349c:	b5fffe00 	cbnz	x0, 9345c <__i2b+0x1c>
   934a0:	d0000003 	adrp	x3, 95000 <pmu_event_descr+0x60>
   934a4:	f0000000 	adrp	x0, 96000 <JIS_state_table+0x70>
   934a8:	91334063 	add	x3, x3, #0xcd0
   934ac:	91006000 	add	x0, x0, #0x18
   934b0:	d2800002 	mov	x2, #0x0                   	// #0
   934b4:	528028a1 	mov	w1, #0x145                 	// #325
   934b8:	97fffe82 	bl	92ec0 <__assert_func>
   934bc:	aa1303e0 	mov	x0, x19
   934c0:	d2800482 	mov	x2, #0x24                  	// #36
   934c4:	d2800021 	mov	x1, #0x1                   	// #1
   934c8:	940002ea 	bl	94070 <_calloc_r>
   934cc:	b4fffea0 	cbz	x0, 934a0 <__i2b+0x60>
   934d0:	f0000001 	adrp	x1, 96000 <JIS_state_table+0x70>
   934d4:	b9001814 	str	w20, [x0, #24]
   934d8:	a94153f3 	ldp	x19, x20, [sp, #16]
   934dc:	fd40dc20 	ldr	d0, [x1, #440]
   934e0:	f0000001 	adrp	x1, 96000 <JIS_state_table+0x70>
   934e4:	fd000400 	str	d0, [x0, #8]
   934e8:	fd40e020 	ldr	d0, [x1, #448]
   934ec:	fd000800 	str	d0, [x0, #16]
   934f0:	a8c27bfd 	ldp	x29, x30, [sp], #32
   934f4:	d65f03c0 	ret
	...

0000000000093500 <__multiply>:
   93500:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
   93504:	910003fd 	mov	x29, sp
   93508:	a9025bf5 	stp	x21, x22, [sp, #32]
   9350c:	aa0103f5 	mov	x21, x1
   93510:	b9401436 	ldr	w22, [x1, #20]
   93514:	f9001bf7 	str	x23, [sp, #48]
   93518:	b9401457 	ldr	w23, [x2, #20]
   9351c:	a90153f3 	stp	x19, x20, [sp, #16]
   93520:	aa0203f4 	mov	x20, x2
   93524:	6b1702df 	cmp	w22, w23
   93528:	540000eb 	b.lt	93544 <__multiply+0x44>  // b.tstop
   9352c:	2a1703e2 	mov	w2, w23
   93530:	aa1403e1 	mov	x1, x20
   93534:	2a1603f7 	mov	w23, w22
   93538:	aa1503f4 	mov	x20, x21
   9353c:	2a0203f6 	mov	w22, w2
   93540:	aa0103f5 	mov	x21, x1
   93544:	29410a81 	ldp	w1, w2, [x20, #8]
   93548:	0b1602f3 	add	w19, w23, w22
   9354c:	6b13005f 	cmp	w2, w19
   93550:	1a81a421 	cinc	w1, w1, lt	// lt = tstop
   93554:	97fffeb7 	bl	93030 <_Balloc>
   93558:	b4000b80 	cbz	x0, 936c8 <__multiply+0x1c8>
   9355c:	91006007 	add	x7, x0, #0x18
   93560:	8b33c8e8 	add	x8, x7, w19, sxtw #2
   93564:	aa0703e3 	mov	x3, x7
   93568:	eb0800ff 	cmp	x7, x8
   9356c:	54000082 	b.cs	9357c <__multiply+0x7c>  // b.hs, b.nlast
   93570:	b800447f 	str	wzr, [x3], #4
   93574:	eb03011f 	cmp	x8, x3
   93578:	54ffffc8 	b.hi	93570 <__multiply+0x70>  // b.pmore
   9357c:	910062a6 	add	x6, x21, #0x18
   93580:	9100628b 	add	x11, x20, #0x18
   93584:	8b36c8c9 	add	x9, x6, w22, sxtw #2
   93588:	8b37c965 	add	x5, x11, w23, sxtw #2
   9358c:	eb0900df 	cmp	x6, x9
   93590:	54000822 	b.cs	93694 <__multiply+0x194>  // b.hs, b.nlast
   93594:	cb1400aa 	sub	x10, x5, x20
   93598:	91006694 	add	x20, x20, #0x19
   9359c:	d100654a 	sub	x10, x10, #0x19
   935a0:	d2800081 	mov	x1, #0x4                   	// #4
   935a4:	927ef54a 	and	x10, x10, #0xfffffffffffffffc
   935a8:	eb1400bf 	cmp	x5, x20
   935ac:	8b01014a 	add	x10, x10, x1
   935b0:	9a81214a 	csel	x10, x10, x1, cs	// cs = hs, nlast
   935b4:	14000007 	b	935d0 <__multiply+0xd0>
   935b8:	53107c63 	lsr	w3, w3, #16
   935bc:	350003c3 	cbnz	w3, 93634 <__multiply+0x134>
   935c0:	910010c6 	add	x6, x6, #0x4
   935c4:	910010e7 	add	x7, x7, #0x4
   935c8:	eb06013f 	cmp	x9, x6
   935cc:	54000649 	b.ls	93694 <__multiply+0x194>  // b.plast
   935d0:	b94000c3 	ldr	w3, [x6]
   935d4:	72003c6d 	ands	w13, w3, #0xffff
   935d8:	54ffff00 	b.eq	935b8 <__multiply+0xb8>  // b.none
   935dc:	aa0703ec 	mov	x12, x7
   935e0:	aa0b03e4 	mov	x4, x11
   935e4:	5280000e 	mov	w14, #0x0                   	// #0
   935e8:	b8404481 	ldr	w1, [x4], #4
   935ec:	b9400183 	ldr	w3, [x12]
   935f0:	12003c22 	and	w2, w1, #0xffff
   935f4:	12003c6f 	and	w15, w3, #0xffff
   935f8:	53107c21 	lsr	w1, w1, #16
   935fc:	53107c63 	lsr	w3, w3, #16
   93600:	1b0d3c42 	madd	w2, w2, w13, w15
   93604:	1b0d0c21 	madd	w1, w1, w13, w3
   93608:	0b0e0042 	add	w2, w2, w14
   9360c:	0b424021 	add	w1, w1, w2, lsr #16
   93610:	33103c22 	bfi	w2, w1, #16, #16
   93614:	b8004582 	str	w2, [x12], #4
   93618:	53107c2e 	lsr	w14, w1, #16
   9361c:	eb0400bf 	cmp	x5, x4
   93620:	54fffe48 	b.hi	935e8 <__multiply+0xe8>  // b.pmore
   93624:	b82a68ee 	str	w14, [x7, x10]
   93628:	b94000c3 	ldr	w3, [x6]
   9362c:	53107c63 	lsr	w3, w3, #16
   93630:	34fffc83 	cbz	w3, 935c0 <__multiply+0xc0>
   93634:	b94000e1 	ldr	w1, [x7]
   93638:	aa0703ed 	mov	x13, x7
   9363c:	aa0b03e4 	mov	x4, x11
   93640:	5280000e 	mov	w14, #0x0                   	// #0
   93644:	2a0103ec 	mov	w12, w1
   93648:	79400082 	ldrh	w2, [x4]
   9364c:	1b033842 	madd	w2, w2, w3, w14
   93650:	0b4c4042 	add	w2, w2, w12, lsr #16
   93654:	33103c41 	bfi	w1, w2, #16, #16
   93658:	b80045a1 	str	w1, [x13], #4
   9365c:	b8404481 	ldr	w1, [x4], #4
   93660:	b94001ac 	ldr	w12, [x13]
   93664:	53107c21 	lsr	w1, w1, #16
   93668:	12003d8e 	and	w14, w12, #0xffff
   9366c:	1b033821 	madd	w1, w1, w3, w14
   93670:	0b424021 	add	w1, w1, w2, lsr #16
   93674:	53107c2e 	lsr	w14, w1, #16
   93678:	eb0400bf 	cmp	x5, x4
   9367c:	54fffe68 	b.hi	93648 <__multiply+0x148>  // b.pmore
   93680:	910010c6 	add	x6, x6, #0x4
   93684:	b82a68e1 	str	w1, [x7, x10]
   93688:	910010e7 	add	x7, x7, #0x4
   9368c:	eb06013f 	cmp	x9, x6
   93690:	54fffa08 	b.hi	935d0 <__multiply+0xd0>  // b.pmore
   93694:	7100027f 	cmp	w19, #0x0
   93698:	5400008c 	b.gt	936a8 <__multiply+0x1a8>
   9369c:	14000005 	b	936b0 <__multiply+0x1b0>
   936a0:	71000673 	subs	w19, w19, #0x1
   936a4:	54000060 	b.eq	936b0 <__multiply+0x1b0>  // b.none
   936a8:	b85fcd01 	ldr	w1, [x8, #-4]!
   936ac:	34ffffa1 	cbz	w1, 936a0 <__multiply+0x1a0>
   936b0:	a9425bf5 	ldp	x21, x22, [sp, #32]
   936b4:	f9401bf7 	ldr	x23, [sp, #48]
   936b8:	b9001413 	str	w19, [x0, #20]
   936bc:	a94153f3 	ldp	x19, x20, [sp, #16]
   936c0:	a8c47bfd 	ldp	x29, x30, [sp], #64
   936c4:	d65f03c0 	ret
   936c8:	d0000003 	adrp	x3, 95000 <pmu_event_descr+0x60>
   936cc:	f0000000 	adrp	x0, 96000 <JIS_state_table+0x70>
   936d0:	91334063 	add	x3, x3, #0xcd0
   936d4:	91006000 	add	x0, x0, #0x18
   936d8:	d2800002 	mov	x2, #0x0                   	// #0
   936dc:	52802c41 	mov	w1, #0x162                 	// #354
   936e0:	97fffdf8 	bl	92ec0 <__assert_func>
	...

00000000000936f0 <__pow5mult>:
   936f0:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   936f4:	910003fd 	mov	x29, sp
   936f8:	a90153f3 	stp	x19, x20, [sp, #16]
   936fc:	2a0203f3 	mov	w19, w2
   93700:	72000442 	ands	w2, w2, #0x3
   93704:	a9025bf5 	stp	x21, x22, [sp, #32]
   93708:	aa0003f6 	mov	x22, x0
   9370c:	aa0103f5 	mov	x21, x1
   93710:	540004c1 	b.ne	937a8 <__pow5mult+0xb8>  // b.any
   93714:	13027e73 	asr	w19, w19, #2
   93718:	340002f3 	cbz	w19, 93774 <__pow5mult+0x84>
   9371c:	f94032d4 	ldr	x20, [x22, #96]
   93720:	b4000554 	cbz	x20, 937c8 <__pow5mult+0xd8>
   93724:	370000f3 	tbnz	w19, #0, 93740 <__pow5mult+0x50>
   93728:	13017e73 	asr	w19, w19, #1
   9372c:	34000253 	cbz	w19, 93774 <__pow5mult+0x84>
   93730:	f9400280 	ldr	x0, [x20]
   93734:	b40002a0 	cbz	x0, 93788 <__pow5mult+0x98>
   93738:	aa0003f4 	mov	x20, x0
   9373c:	3607ff73 	tbz	w19, #0, 93728 <__pow5mult+0x38>
   93740:	aa1403e2 	mov	x2, x20
   93744:	aa1503e1 	mov	x1, x21
   93748:	aa1603e0 	mov	x0, x22
   9374c:	97ffff6d 	bl	93500 <__multiply>
   93750:	b40000d5 	cbz	x21, 93768 <__pow5mult+0x78>
   93754:	f94036c1 	ldr	x1, [x22, #104]
   93758:	b9800aa2 	ldrsw	x2, [x21, #8]
   9375c:	f8627823 	ldr	x3, [x1, x2, lsl #3]
   93760:	f90002a3 	str	x3, [x21]
   93764:	f8227835 	str	x21, [x1, x2, lsl #3]
   93768:	aa0003f5 	mov	x21, x0
   9376c:	13017e73 	asr	w19, w19, #1
   93770:	35fffe13 	cbnz	w19, 93730 <__pow5mult+0x40>
   93774:	a94153f3 	ldp	x19, x20, [sp, #16]
   93778:	aa1503e0 	mov	x0, x21
   9377c:	a9425bf5 	ldp	x21, x22, [sp, #32]
   93780:	a8c37bfd 	ldp	x29, x30, [sp], #48
   93784:	d65f03c0 	ret
   93788:	aa1403e2 	mov	x2, x20
   9378c:	aa1403e1 	mov	x1, x20
   93790:	aa1603e0 	mov	x0, x22
   93794:	97ffff5b 	bl	93500 <__multiply>
   93798:	f9000280 	str	x0, [x20]
   9379c:	aa0003f4 	mov	x20, x0
   937a0:	f900001f 	str	xzr, [x0]
   937a4:	17ffffe6 	b	9373c <__pow5mult+0x4c>
   937a8:	51000442 	sub	w2, w2, #0x1
   937ac:	f0000004 	adrp	x4, 96000 <JIS_state_table+0x70>
   937b0:	9101e084 	add	x4, x4, #0x78
   937b4:	52800003 	mov	w3, #0x0                   	// #0
   937b8:	b862d882 	ldr	w2, [x4, w2, sxtw #2]
   937bc:	97fffe49 	bl	930e0 <__multadd>
   937c0:	aa0003f5 	mov	x21, x0
   937c4:	17ffffd4 	b	93714 <__pow5mult+0x24>
   937c8:	aa1603e0 	mov	x0, x22
   937cc:	52800021 	mov	w1, #0x1                   	// #1
   937d0:	97fffe18 	bl	93030 <_Balloc>
   937d4:	aa0003f4 	mov	x20, x0
   937d8:	b40000e0 	cbz	x0, 937f4 <__pow5mult+0x104>
   937dc:	d2800020 	mov	x0, #0x1                   	// #1
   937e0:	f2c04e20 	movk	x0, #0x271, lsl #32
   937e4:	f8014280 	stur	x0, [x20, #20]
   937e8:	f90032d4 	str	x20, [x22, #96]
   937ec:	f900029f 	str	xzr, [x20]
   937f0:	17ffffcd 	b	93724 <__pow5mult+0x34>
   937f4:	d0000003 	adrp	x3, 95000 <pmu_event_descr+0x60>
   937f8:	f0000000 	adrp	x0, 96000 <JIS_state_table+0x70>
   937fc:	91334063 	add	x3, x3, #0xcd0
   93800:	91006000 	add	x0, x0, #0x18
   93804:	d2800002 	mov	x2, #0x0                   	// #0
   93808:	528028a1 	mov	w1, #0x145                 	// #325
   9380c:	97fffdad 	bl	92ec0 <__assert_func>

0000000000093810 <__lshift>:
   93810:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
   93814:	910003fd 	mov	x29, sp
   93818:	a90363f7 	stp	x23, x24, [sp, #48]
   9381c:	13057c58 	asr	w24, w2, #5
   93820:	b9401437 	ldr	w23, [x1, #20]
   93824:	b9400c23 	ldr	w3, [x1, #12]
   93828:	0b170317 	add	w23, w24, w23
   9382c:	a90153f3 	stp	x19, x20, [sp, #16]
   93830:	aa0103f4 	mov	x20, x1
   93834:	a9025bf5 	stp	x21, x22, [sp, #32]
   93838:	110006f5 	add	w21, w23, #0x1
   9383c:	b9400821 	ldr	w1, [x1, #8]
   93840:	2a0203f3 	mov	w19, w2
   93844:	aa0003f6 	mov	x22, x0
   93848:	6b0302bf 	cmp	w21, w3
   9384c:	540000ad 	b.le	93860 <__lshift+0x50>
   93850:	531f7863 	lsl	w3, w3, #1
   93854:	11000421 	add	w1, w1, #0x1
   93858:	6b0302bf 	cmp	w21, w3
   9385c:	54ffffac 	b.gt	93850 <__lshift+0x40>
   93860:	aa1603e0 	mov	x0, x22
   93864:	97fffdf3 	bl	93030 <_Balloc>
   93868:	b40007a0 	cbz	x0, 9395c <__lshift+0x14c>
   9386c:	91006005 	add	x5, x0, #0x18
   93870:	7100031f 	cmp	w24, #0x0
   93874:	5400012d 	b.le	93898 <__lshift+0x88>
   93878:	11001b04 	add	w4, w24, #0x6
   9387c:	aa0503e3 	mov	x3, x5
   93880:	8b24c804 	add	x4, x0, w4, sxtw #2
   93884:	d503201f 	nop
   93888:	b800447f 	str	wzr, [x3], #4
   9388c:	eb04007f 	cmp	x3, x4
   93890:	54ffffc1 	b.ne	93888 <__lshift+0x78>  // b.any
   93894:	8b3848a5 	add	x5, x5, w24, uxtw #2
   93898:	b9801686 	ldrsw	x6, [x20, #20]
   9389c:	91006283 	add	x3, x20, #0x18
   938a0:	72001267 	ands	w7, w19, #0x1f
   938a4:	8b060866 	add	x6, x3, x6, lsl #2
   938a8:	54000480 	b.eq	93938 <__lshift+0x128>  // b.none
   938ac:	52800408 	mov	w8, #0x20                  	// #32
   938b0:	aa0503e1 	mov	x1, x5
   938b4:	4b070108 	sub	w8, w8, w7
   938b8:	52800004 	mov	w4, #0x0                   	// #0
   938bc:	d503201f 	nop
   938c0:	b9400062 	ldr	w2, [x3]
   938c4:	1ac72042 	lsl	w2, w2, w7
   938c8:	2a040042 	orr	w2, w2, w4
   938cc:	b8004422 	str	w2, [x1], #4
   938d0:	b8404464 	ldr	w4, [x3], #4
   938d4:	1ac82484 	lsr	w4, w4, w8
   938d8:	eb0300df 	cmp	x6, x3
   938dc:	54ffff28 	b.hi	938c0 <__lshift+0xb0>  // b.pmore
   938e0:	cb1400c1 	sub	x1, x6, x20
   938e4:	91006682 	add	x2, x20, #0x19
   938e8:	d1006421 	sub	x1, x1, #0x19
   938ec:	eb0200df 	cmp	x6, x2
   938f0:	927ef421 	and	x1, x1, #0xfffffffffffffffc
   938f4:	d2800082 	mov	x2, #0x4                   	// #4
   938f8:	8b020021 	add	x1, x1, x2
   938fc:	9a822021 	csel	x1, x1, x2, cs	// cs = hs, nlast
   93900:	b82168a4 	str	w4, [x5, x1]
   93904:	35000044 	cbnz	w4, 9390c <__lshift+0xfc>
   93908:	2a1703f5 	mov	w21, w23
   9390c:	f94036c1 	ldr	x1, [x22, #104]
   93910:	b9800a82 	ldrsw	x2, [x20, #8]
   93914:	a94363f7 	ldp	x23, x24, [sp, #48]
   93918:	f8627823 	ldr	x3, [x1, x2, lsl #3]
   9391c:	b9001415 	str	w21, [x0, #20]
   93920:	a9425bf5 	ldp	x21, x22, [sp, #32]
   93924:	f9000283 	str	x3, [x20]
   93928:	f8227834 	str	x20, [x1, x2, lsl #3]
   9392c:	a94153f3 	ldp	x19, x20, [sp, #16]
   93930:	a8c47bfd 	ldp	x29, x30, [sp], #64
   93934:	d65f03c0 	ret
   93938:	b8404461 	ldr	w1, [x3], #4
   9393c:	b80044a1 	str	w1, [x5], #4
   93940:	eb0300df 	cmp	x6, x3
   93944:	54fffe29 	b.ls	93908 <__lshift+0xf8>  // b.plast
   93948:	b8404461 	ldr	w1, [x3], #4
   9394c:	b80044a1 	str	w1, [x5], #4
   93950:	eb0300df 	cmp	x6, x3
   93954:	54ffff28 	b.hi	93938 <__lshift+0x128>  // b.pmore
   93958:	17ffffec 	b	93908 <__lshift+0xf8>
   9395c:	d0000003 	adrp	x3, 95000 <pmu_event_descr+0x60>
   93960:	f0000000 	adrp	x0, 96000 <JIS_state_table+0x70>
   93964:	91334063 	add	x3, x3, #0xcd0
   93968:	91006000 	add	x0, x0, #0x18
   9396c:	d2800002 	mov	x2, #0x0                   	// #0
   93970:	52803bc1 	mov	w1, #0x1de                 	// #478
   93974:	97fffd53 	bl	92ec0 <__assert_func>
	...

0000000000093980 <__mcmp>:
   93980:	b9401422 	ldr	w2, [x1, #20]
   93984:	aa0003e5 	mov	x5, x0
   93988:	b9401400 	ldr	w0, [x0, #20]
   9398c:	6b020000 	subs	w0, w0, w2
   93990:	540001e1 	b.ne	939cc <__mcmp+0x4c>  // b.any
   93994:	937e7c43 	sbfiz	x3, x2, #2, #32
   93998:	910060a5 	add	x5, x5, #0x18
   9399c:	91006021 	add	x1, x1, #0x18
   939a0:	8b0300a2 	add	x2, x5, x3
   939a4:	8b030021 	add	x1, x1, x3
   939a8:	14000003 	b	939b4 <__mcmp+0x34>
   939ac:	eb0200bf 	cmp	x5, x2
   939b0:	540000e2 	b.cs	939cc <__mcmp+0x4c>  // b.hs, b.nlast
   939b4:	b85fcc44 	ldr	w4, [x2, #-4]!
   939b8:	b85fcc23 	ldr	w3, [x1, #-4]!
   939bc:	6b03009f 	cmp	w4, w3
   939c0:	54ffff60 	b.eq	939ac <__mcmp+0x2c>  // b.none
   939c4:	12800000 	mov	w0, #0xffffffff            	// #-1
   939c8:	1a9f3400 	csinc	w0, w0, wzr, cc	// cc = lo, ul, last
   939cc:	d65f03c0 	ret

00000000000939d0 <__mdiff>:
   939d0:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   939d4:	910003fd 	mov	x29, sp
   939d8:	a90153f3 	stp	x19, x20, [sp, #16]
   939dc:	aa0103f4 	mov	x20, x1
   939e0:	aa0203f3 	mov	x19, x2
   939e4:	f90013f5 	str	x21, [sp, #32]
   939e8:	b9401435 	ldr	w21, [x1, #20]
   939ec:	b9401441 	ldr	w1, [x2, #20]
   939f0:	6b0102b5 	subs	w21, w21, w1
   939f4:	35000255 	cbnz	w21, 93a3c <__mdiff+0x6c>
   939f8:	937e7c22 	sbfiz	x2, x1, #2, #32
   939fc:	91006264 	add	x4, x19, #0x18
   93a00:	91006281 	add	x1, x20, #0x18
   93a04:	8b020084 	add	x4, x4, x2
   93a08:	8b020023 	add	x3, x1, x2
   93a0c:	14000003 	b	93a18 <__mdiff+0x48>
   93a10:	eb03003f 	cmp	x1, x3
   93a14:	54000a22 	b.cs	93b58 <__mdiff+0x188>  // b.hs, b.nlast
   93a18:	b85fcc66 	ldr	w6, [x3, #-4]!
   93a1c:	b85fcc85 	ldr	w5, [x4, #-4]!
   93a20:	6b0500df 	cmp	w6, w5
   93a24:	54ffff60 	b.eq	93a10 <__mdiff+0x40>  // b.none
   93a28:	aa1403e1 	mov	x1, x20
   93a2c:	1a9f27f5 	cset	w21, cc	// cc = lo, ul, last
   93a30:	9a932294 	csel	x20, x20, x19, cs	// cs = hs, nlast
   93a34:	9a812273 	csel	x19, x19, x1, cs	// cs = hs, nlast
   93a38:	14000005 	b	93a4c <__mdiff+0x7c>
   93a3c:	aa1403e1 	mov	x1, x20
   93a40:	1a9f57f5 	cset	w21, mi	// mi = first
   93a44:	9a825294 	csel	x20, x20, x2, pl	// pl = nfrst
   93a48:	9a815053 	csel	x19, x2, x1, pl	// pl = nfrst
   93a4c:	b9400a81 	ldr	w1, [x20, #8]
   93a50:	97fffd78 	bl	93030 <_Balloc>
   93a54:	b4000ac0 	cbz	x0, 93bac <__mdiff+0x1dc>
   93a58:	b9801668 	ldrsw	x8, [x19, #20]
   93a5c:	91006289 	add	x9, x20, #0x18
   93a60:	b9401687 	ldr	w7, [x20, #20]
   93a64:	91006262 	add	x2, x19, #0x18
   93a68:	9100600b 	add	x11, x0, #0x18
   93a6c:	d2800305 	mov	x5, #0x18                  	// #24
   93a70:	8b080848 	add	x8, x2, x8, lsl #2
   93a74:	52800001 	mov	w1, #0x0                   	// #0
   93a78:	8b27c92a 	add	x10, x9, w7, sxtw #2
   93a7c:	b9001015 	str	w21, [x0, #16]
   93a80:	b8656a86 	ldr	w6, [x20, x5]
   93a84:	b8656a64 	ldr	w4, [x19, x5]
   93a88:	12003cc3 	and	w3, w6, #0xffff
   93a8c:	53107cc6 	lsr	w6, w6, #16
   93a90:	4b242063 	sub	w3, w3, w4, uxth
   93a94:	4b4440c4 	sub	w4, w6, w4, lsr #16
   93a98:	0b010063 	add	w3, w3, w1
   93a9c:	0b834084 	add	w4, w4, w3, asr #16
   93aa0:	33103c83 	bfi	w3, w4, #16, #16
   93aa4:	b8256803 	str	w3, [x0, x5]
   93aa8:	910010a5 	add	x5, x5, #0x4
   93aac:	13107c81 	asr	w1, w4, #16
   93ab0:	8b050264 	add	x4, x19, x5
   93ab4:	eb04011f 	cmp	x8, x4
   93ab8:	54fffe48 	b.hi	93a80 <__mdiff+0xb0>  // b.pmore
   93abc:	cb130104 	sub	x4, x8, x19
   93ac0:	91006662 	add	x2, x19, #0x19
   93ac4:	d1006484 	sub	x4, x4, #0x19
   93ac8:	eb02011f 	cmp	x8, x2
   93acc:	d2800086 	mov	x6, #0x4                   	// #4
   93ad0:	d342fc84 	lsr	x4, x4, #2
   93ad4:	91000485 	add	x5, x4, #0x1
   93ad8:	d37ef4a5 	lsl	x5, x5, #2
   93adc:	9a8620a5 	csel	x5, x5, x6, cs	// cs = hs, nlast
   93ae0:	8b050129 	add	x9, x9, x5
   93ae4:	8b050165 	add	x5, x11, x5
   93ae8:	eb09015f 	cmp	x10, x9
   93aec:	54000489 	b.ls	93b7c <__mdiff+0x1ac>  // b.plast
   93af0:	d100054a 	sub	x10, x10, #0x1
   93af4:	d2800004 	mov	x4, #0x0                   	// #0
   93af8:	cb09014a 	sub	x10, x10, x9
   93afc:	d342fd48 	lsr	x8, x10, #2
   93b00:	b8647922 	ldr	w2, [x9, x4, lsl #2]
   93b04:	eb04011f 	cmp	x8, x4
   93b08:	0b010043 	add	w3, w2, w1
   93b0c:	0b222021 	add	w1, w1, w2, uxth
   93b10:	53107c42 	lsr	w2, w2, #16
   93b14:	0b814041 	add	w1, w2, w1, asr #16
   93b18:	33103c23 	bfi	w3, w1, #16, #16
   93b1c:	b82478a3 	str	w3, [x5, x4, lsl #2]
   93b20:	13107c21 	asr	w1, w1, #16
   93b24:	91000484 	add	x4, x4, #0x1
   93b28:	54fffec1 	b.ne	93b00 <__mdiff+0x130>  // b.any
   93b2c:	927ef54a 	and	x10, x10, #0xfffffffffffffffc
   93b30:	8b0a00a1 	add	x1, x5, x10
   93b34:	35000083 	cbnz	w3, 93b44 <__mdiff+0x174>
   93b38:	b85fcc22 	ldr	w2, [x1, #-4]!
   93b3c:	510004e7 	sub	w7, w7, #0x1
   93b40:	34ffffc2 	cbz	w2, 93b38 <__mdiff+0x168>
   93b44:	b9001407 	str	w7, [x0, #20]
   93b48:	a94153f3 	ldp	x19, x20, [sp, #16]
   93b4c:	f94013f5 	ldr	x21, [sp, #32]
   93b50:	a8c37bfd 	ldp	x29, x30, [sp], #48
   93b54:	d65f03c0 	ret
   93b58:	52800001 	mov	w1, #0x0                   	// #0
   93b5c:	97fffd35 	bl	93030 <_Balloc>
   93b60:	b4000180 	cbz	x0, 93b90 <__mdiff+0x1c0>
   93b64:	d2800021 	mov	x1, #0x1                   	// #1
   93b68:	f8014001 	stur	x1, [x0, #20]
   93b6c:	a94153f3 	ldp	x19, x20, [sp, #16]
   93b70:	f94013f5 	ldr	x21, [sp, #32]
   93b74:	a8c37bfd 	ldp	x29, x30, [sp], #48
   93b78:	d65f03c0 	ret
   93b7c:	d37ef484 	lsl	x4, x4, #2
   93b80:	eb02011f 	cmp	x8, x2
   93b84:	9a9f2084 	csel	x4, x4, xzr, cs	// cs = hs, nlast
   93b88:	8b040161 	add	x1, x11, x4
   93b8c:	17ffffea 	b	93b34 <__mdiff+0x164>
   93b90:	d0000003 	adrp	x3, 95000 <pmu_event_descr+0x60>
   93b94:	f0000000 	adrp	x0, 96000 <JIS_state_table+0x70>
   93b98:	91334063 	add	x3, x3, #0xcd0
   93b9c:	91006000 	add	x0, x0, #0x18
   93ba0:	d2800002 	mov	x2, #0x0                   	// #0
   93ba4:	528046e1 	mov	w1, #0x237                 	// #567
   93ba8:	97fffcc6 	bl	92ec0 <__assert_func>
   93bac:	d0000003 	adrp	x3, 95000 <pmu_event_descr+0x60>
   93bb0:	f0000000 	adrp	x0, 96000 <JIS_state_table+0x70>
   93bb4:	91334063 	add	x3, x3, #0xcd0
   93bb8:	91006000 	add	x0, x0, #0x18
   93bbc:	d2800002 	mov	x2, #0x0                   	// #0
   93bc0:	528048a1 	mov	w1, #0x245                 	// #581
   93bc4:	97fffcbf 	bl	92ec0 <__assert_func>
	...

0000000000093bd0 <__ulp>:
   93bd0:	9e660000 	fmov	x0, d0
   93bd4:	52bf9801 	mov	w1, #0xfcc00000            	// #-54525952
   93bd8:	d360fc00 	lsr	x0, x0, #32
   93bdc:	120c2800 	and	w0, w0, #0x7ff00000
   93be0:	0b010000 	add	w0, w0, w1
   93be4:	52800001 	mov	w1, #0x0                   	// #0
   93be8:	7100001f 	cmp	w0, #0x0
   93bec:	540000ad 	b.le	93c00 <__ulp+0x30>
   93bf0:	2a0103e1 	mov	w1, w1
   93bf4:	aa008020 	orr	x0, x1, x0, lsl #32
   93bf8:	9e670000 	fmov	d0, x0
   93bfc:	d65f03c0 	ret
   93c00:	4b0003e0 	neg	w0, w0
   93c04:	13147c00 	asr	w0, w0, #20
   93c08:	71004c1f 	cmp	w0, #0x13
   93c0c:	5400010c 	b.gt	93c2c <__ulp+0x5c>
   93c10:	52a00102 	mov	w2, #0x80000               	// #524288
   93c14:	52800001 	mov	w1, #0x0                   	// #0
   93c18:	1ac02840 	asr	w0, w2, w0
   93c1c:	2a0103e1 	mov	w1, w1
   93c20:	aa008020 	orr	x0, x1, x0, lsl #32
   93c24:	9e670000 	fmov	d0, x0
   93c28:	d65f03c0 	ret
   93c2c:	51005002 	sub	w2, w0, #0x14
   93c30:	52b00001 	mov	w1, #0x80000000            	// #-2147483648
   93c34:	71007c5f 	cmp	w2, #0x1f
   93c38:	52800000 	mov	w0, #0x0                   	// #0
   93c3c:	1ac22421 	lsr	w1, w1, w2
   93c40:	1a9fb421 	csinc	w1, w1, wzr, lt	// lt = tstop
   93c44:	2a0103e1 	mov	w1, w1
   93c48:	aa008020 	orr	x0, x1, x0, lsl #32
   93c4c:	9e670000 	fmov	d0, x0
   93c50:	d65f03c0 	ret
	...

0000000000093c60 <__b2d>:
   93c60:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   93c64:	91006006 	add	x6, x0, #0x18
   93c68:	aa0103e5 	mov	x5, x1
   93c6c:	910003fd 	mov	x29, sp
   93c70:	b9801404 	ldrsw	x4, [x0, #20]
   93c74:	8b0408c4 	add	x4, x6, x4, lsl #2
   93c78:	d1001087 	sub	x7, x4, #0x4
   93c7c:	b85fc083 	ldur	w3, [x4, #-4]
   93c80:	2a0303e0 	mov	w0, w3
   93c84:	97fffda7 	bl	93320 <__hi0bits>
   93c88:	52800401 	mov	w1, #0x20                  	// #32
   93c8c:	4b000022 	sub	w2, w1, w0
   93c90:	b90000a2 	str	w2, [x5]
   93c94:	7100281f 	cmp	w0, #0xa
   93c98:	5400056d 	b.le	93d44 <__b2d+0xe4>
   93c9c:	51002c05 	sub	w5, w0, #0xb
   93ca0:	eb0700df 	cmp	x6, x7
   93ca4:	540002a2 	b.cs	93cf8 <__b2d+0x98>  // b.hs, b.nlast
   93ca8:	b85f8080 	ldur	w0, [x4, #-8]
   93cac:	340003e5 	cbz	w5, 93d28 <__b2d+0xc8>
   93cb0:	4b050022 	sub	w2, w1, w5
   93cb4:	1ac52063 	lsl	w3, w3, w5
   93cb8:	d2800001 	mov	x1, #0x0                   	// #0
   93cbc:	d1002087 	sub	x7, x4, #0x8
   93cc0:	1ac22408 	lsr	w8, w0, w2
   93cc4:	2a080063 	orr	w3, w3, w8
   93cc8:	320c2463 	orr	w3, w3, #0x3ff00000
   93ccc:	1ac52000 	lsl	w0, w0, w5
   93cd0:	b3607c61 	bfi	x1, x3, #32, #32
   93cd4:	eb0700df 	cmp	x6, x7
   93cd8:	540002e2 	b.cs	93d34 <__b2d+0xd4>  // b.hs, b.nlast
   93cdc:	b85f4083 	ldur	w3, [x4, #-12]
   93ce0:	a8c17bfd 	ldp	x29, x30, [sp], #16
   93ce4:	1ac22462 	lsr	w2, w3, w2
   93ce8:	2a020000 	orr	w0, w0, w2
   93cec:	b3407c01 	bfxil	x1, x0, #0, #32
   93cf0:	9e670020 	fmov	d0, x1
   93cf4:	d65f03c0 	ret
   93cf8:	71002c1f 	cmp	w0, #0xb
   93cfc:	54000140 	b.eq	93d24 <__b2d+0xc4>  // b.none
   93d00:	1ac52063 	lsl	w3, w3, w5
   93d04:	320c2463 	orr	w3, w3, #0x3ff00000
   93d08:	d2800001 	mov	x1, #0x0                   	// #0
   93d0c:	52800000 	mov	w0, #0x0                   	// #0
   93d10:	b3607c61 	bfi	x1, x3, #32, #32
   93d14:	a8c17bfd 	ldp	x29, x30, [sp], #16
   93d18:	b3407c01 	bfxil	x1, x0, #0, #32
   93d1c:	9e670020 	fmov	d0, x1
   93d20:	d65f03c0 	ret
   93d24:	52800000 	mov	w0, #0x0                   	// #0
   93d28:	320c2463 	orr	w3, w3, #0x3ff00000
   93d2c:	d2800001 	mov	x1, #0x0                   	// #0
   93d30:	b3607c61 	bfi	x1, x3, #32, #32
   93d34:	b3407c01 	bfxil	x1, x0, #0, #32
   93d38:	9e670020 	fmov	d0, x1
   93d3c:	a8c17bfd 	ldp	x29, x30, [sp], #16
   93d40:	d65f03c0 	ret
   93d44:	52800165 	mov	w5, #0xb                   	// #11
   93d48:	4b0000a5 	sub	w5, w5, w0
   93d4c:	d2800001 	mov	x1, #0x0                   	// #0
   93d50:	52800002 	mov	w2, #0x0                   	// #0
   93d54:	1ac52468 	lsr	w8, w3, w5
   93d58:	320c2508 	orr	w8, w8, #0x3ff00000
   93d5c:	b3607d01 	bfi	x1, x8, #32, #32
   93d60:	eb0700df 	cmp	x6, x7
   93d64:	54000062 	b.cs	93d70 <__b2d+0x110>  // b.hs, b.nlast
   93d68:	b85f8082 	ldur	w2, [x4, #-8]
   93d6c:	1ac52442 	lsr	w2, w2, w5
   93d70:	11005400 	add	w0, w0, #0x15
   93d74:	a8c17bfd 	ldp	x29, x30, [sp], #16
   93d78:	1ac02063 	lsl	w3, w3, w0
   93d7c:	2a020060 	orr	w0, w3, w2
   93d80:	b3407c01 	bfxil	x1, x0, #0, #32
   93d84:	9e670020 	fmov	d0, x1
   93d88:	d65f03c0 	ret
   93d8c:	00000000 	udf	#0

0000000000093d90 <__d2b>:
   93d90:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
   93d94:	910003fd 	mov	x29, sp
   93d98:	fd0013e8 	str	d8, [sp, #32]
   93d9c:	1e604008 	fmov	d8, d0
   93da0:	a90153f3 	stp	x19, x20, [sp, #16]
   93da4:	aa0103f4 	mov	x20, x1
   93da8:	aa0203f3 	mov	x19, x2
   93dac:	52800021 	mov	w1, #0x1                   	// #1
   93db0:	97fffca0 	bl	93030 <_Balloc>
   93db4:	b40007a0 	cbz	x0, 93ea8 <__d2b+0x118>
   93db8:	9e660103 	fmov	x3, d8
   93dbc:	aa0003e4 	mov	x4, x0
   93dc0:	d374f865 	ubfx	x5, x3, #52, #11
   93dc4:	d360cc60 	ubfx	x0, x3, #32, #20
   93dc8:	320c0001 	orr	w1, w0, #0x100000
   93dcc:	710000bf 	cmp	w5, #0x0
   93dd0:	1a801020 	csel	w0, w1, w0, ne	// ne = any
   93dd4:	b9003fe0 	str	w0, [sp, #60]
   93dd8:	35000283 	cbnz	w3, 93e28 <__d2b+0x98>
   93ddc:	9100f3e0 	add	x0, sp, #0x3c
   93de0:	97fffd70 	bl	933a0 <__lo0bits>
   93de4:	b9403fe1 	ldr	w1, [sp, #60]
   93de8:	52800023 	mov	w3, #0x1                   	// #1
   93dec:	b9001483 	str	w3, [x4, #20]
   93df0:	11008000 	add	w0, w0, #0x20
   93df4:	b9001881 	str	w1, [x4, #24]
   93df8:	340003a5 	cbz	w5, 93e6c <__d2b+0xdc>
   93dfc:	5110cca5 	sub	w5, w5, #0x433
   93e00:	fd4013e8 	ldr	d8, [sp, #32]
   93e04:	0b0000a5 	add	w5, w5, w0
   93e08:	b9000285 	str	w5, [x20]
   93e0c:	528006a3 	mov	w3, #0x35                  	// #53
   93e10:	4b000063 	sub	w3, w3, w0
   93e14:	b9000263 	str	w3, [x19]
   93e18:	aa0403e0 	mov	x0, x4
   93e1c:	a94153f3 	ldp	x19, x20, [sp, #16]
   93e20:	a8c47bfd 	ldp	x29, x30, [sp], #64
   93e24:	d65f03c0 	ret
   93e28:	9100e3e0 	add	x0, sp, #0x38
   93e2c:	bd003be8 	str	s8, [sp, #56]
   93e30:	97fffd5c 	bl	933a0 <__lo0bits>
   93e34:	b9403fe1 	ldr	w1, [sp, #60]
   93e38:	34000340 	cbz	w0, 93ea0 <__d2b+0x110>
   93e3c:	b9403be3 	ldr	w3, [sp, #56]
   93e40:	4b0003e2 	neg	w2, w0
   93e44:	1ac22022 	lsl	w2, w1, w2
   93e48:	2a030042 	orr	w2, w2, w3
   93e4c:	1ac02421 	lsr	w1, w1, w0
   93e50:	b9003fe1 	str	w1, [sp, #60]
   93e54:	7100003f 	cmp	w1, #0x0
   93e58:	29030482 	stp	w2, w1, [x4, #24]
   93e5c:	1a9f07e3 	cset	w3, ne	// ne = any
   93e60:	11000463 	add	w3, w3, #0x1
   93e64:	b9001483 	str	w3, [x4, #20]
   93e68:	35fffca5 	cbnz	w5, 93dfc <__d2b+0x6c>
   93e6c:	8b23c881 	add	x1, x4, w3, sxtw #2
   93e70:	5110c800 	sub	w0, w0, #0x432
   93e74:	b9000280 	str	w0, [x20]
   93e78:	531b6863 	lsl	w3, w3, #5
   93e7c:	b9401420 	ldr	w0, [x1, #20]
   93e80:	97fffd28 	bl	93320 <__hi0bits>
   93e84:	fd4013e8 	ldr	d8, [sp, #32]
   93e88:	4b000063 	sub	w3, w3, w0
   93e8c:	b9000263 	str	w3, [x19]
   93e90:	a94153f3 	ldp	x19, x20, [sp, #16]
   93e94:	aa0403e0 	mov	x0, x4
   93e98:	a8c47bfd 	ldp	x29, x30, [sp], #64
   93e9c:	d65f03c0 	ret
   93ea0:	b9403be2 	ldr	w2, [sp, #56]
   93ea4:	17ffffec 	b	93e54 <__d2b+0xc4>
   93ea8:	d0000003 	adrp	x3, 95000 <pmu_event_descr+0x60>
   93eac:	f0000000 	adrp	x0, 96000 <JIS_state_table+0x70>
   93eb0:	91334063 	add	x3, x3, #0xcd0
   93eb4:	91006000 	add	x0, x0, #0x18
   93eb8:	d2800002 	mov	x2, #0x0                   	// #0
   93ebc:	528061e1 	mov	w1, #0x30f                 	// #783
   93ec0:	97fffc00 	bl	92ec0 <__assert_func>
	...

0000000000093ed0 <__ratio>:
   93ed0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   93ed4:	aa0103e9 	mov	x9, x1
   93ed8:	aa0003ea 	mov	x10, x0
   93edc:	910003fd 	mov	x29, sp
   93ee0:	910063e1 	add	x1, sp, #0x18
   93ee4:	97ffff5f 	bl	93c60 <__b2d>
   93ee8:	aa0903e0 	mov	x0, x9
   93eec:	910073e1 	add	x1, sp, #0x1c
   93ef0:	1e604001 	fmov	d1, d0
   93ef4:	97ffff5b 	bl	93c60 <__b2d>
   93ef8:	b9401524 	ldr	w4, [x9, #20]
   93efc:	b9401540 	ldr	w0, [x10, #20]
   93f00:	29430fe1 	ldp	w1, w3, [sp, #24]
   93f04:	4b040000 	sub	w0, w0, w4
   93f08:	4b030021 	sub	w1, w1, w3
   93f0c:	0b001420 	add	w0, w1, w0, lsl #5
   93f10:	7100001f 	cmp	w0, #0x0
   93f14:	5400012d 	b.le	93f38 <__ratio+0x68>
   93f18:	9e660022 	fmov	x2, d1
   93f1c:	a8c27bfd 	ldp	x29, x30, [sp], #32
   93f20:	d360fc41 	lsr	x1, x2, #32
   93f24:	0b005020 	add	w0, w1, w0, lsl #20
   93f28:	b3607c02 	bfi	x2, x0, #32, #32
   93f2c:	9e670041 	fmov	d1, x2
   93f30:	1e601820 	fdiv	d0, d1, d0
   93f34:	d65f03c0 	ret
   93f38:	9e660001 	fmov	x1, d0
   93f3c:	a8c27bfd 	ldp	x29, x30, [sp], #32
   93f40:	d360fc22 	lsr	x2, x1, #32
   93f44:	4b005040 	sub	w0, w2, w0, lsl #20
   93f48:	b3607c01 	bfi	x1, x0, #32, #32
   93f4c:	9e670020 	fmov	d0, x1
   93f50:	1e601820 	fdiv	d0, d1, d0
   93f54:	d65f03c0 	ret
	...

0000000000093f60 <_mprec_log10>:
   93f60:	1e6e1000 	fmov	d0, #1.000000000000000000e+00
   93f64:	1e649001 	fmov	d1, #1.000000000000000000e+01
   93f68:	71005c1f 	cmp	w0, #0x17
   93f6c:	540000ad 	b.le	93f80 <_mprec_log10+0x20>
   93f70:	1e610800 	fmul	d0, d0, d1
   93f74:	71000400 	subs	w0, w0, #0x1
   93f78:	54ffffc1 	b.ne	93f70 <_mprec_log10+0x10>  // b.any
   93f7c:	d65f03c0 	ret
   93f80:	f0000001 	adrp	x1, 96000 <JIS_state_table+0x70>
   93f84:	9103c021 	add	x1, x1, #0xf0
   93f88:	fc60d820 	ldr	d0, [x1, w0, sxtw #3]
   93f8c:	d65f03c0 	ret

0000000000093f90 <__copybits>:
   93f90:	51000421 	sub	w1, w1, #0x1
   93f94:	91006046 	add	x6, x2, #0x18
   93f98:	13057c24 	asr	w4, w1, #5
   93f9c:	b9801441 	ldrsw	x1, [x2, #20]
   93fa0:	11000484 	add	w4, w4, #0x1
   93fa4:	8b0108c1 	add	x1, x6, x1, lsl #2
   93fa8:	8b24c804 	add	x4, x0, w4, sxtw #2
   93fac:	eb0100df 	cmp	x6, x1
   93fb0:	540001e2 	b.cs	93fec <__copybits+0x5c>  // b.hs, b.nlast
   93fb4:	cb020023 	sub	x3, x1, x2
   93fb8:	d2800001 	mov	x1, #0x0                   	// #0
   93fbc:	d1006463 	sub	x3, x3, #0x19
   93fc0:	d342fc63 	lsr	x3, x3, #2
   93fc4:	91000467 	add	x7, x3, #0x1
   93fc8:	b86178c5 	ldr	w5, [x6, x1, lsl #2]
   93fcc:	eb03003f 	cmp	x1, x3
   93fd0:	b8217805 	str	w5, [x0, x1, lsl #2]
   93fd4:	91000421 	add	x1, x1, #0x1
   93fd8:	54ffff81 	b.ne	93fc8 <__copybits+0x38>  // b.any
   93fdc:	8b070800 	add	x0, x0, x7, lsl #2
   93fe0:	eb00009f 	cmp	x4, x0
   93fe4:	54000089 	b.ls	93ff4 <__copybits+0x64>  // b.plast
   93fe8:	b800441f 	str	wzr, [x0], #4
   93fec:	eb00009f 	cmp	x4, x0
   93ff0:	54ffffc8 	b.hi	93fe8 <__copybits+0x58>  // b.pmore
   93ff4:	d65f03c0 	ret
	...

0000000000094000 <__any_on>:
   94000:	91006003 	add	x3, x0, #0x18
   94004:	b9401400 	ldr	w0, [x0, #20]
   94008:	13057c22 	asr	w2, w1, #5
   9400c:	6b02001f 	cmp	w0, w2
   94010:	5400012a 	b.ge	94034 <__any_on+0x34>  // b.tcont
   94014:	8b20c862 	add	x2, x3, w0, sxtw #2
   94018:	14000003 	b	94024 <__any_on+0x24>
   9401c:	b85fcc40 	ldr	w0, [x2, #-4]!
   94020:	35000220 	cbnz	w0, 94064 <__any_on+0x64>
   94024:	eb03005f 	cmp	x2, x3
   94028:	54ffffa8 	b.hi	9401c <__any_on+0x1c>  // b.pmore
   9402c:	52800000 	mov	w0, #0x0                   	// #0
   94030:	d65f03c0 	ret
   94034:	93407c40 	sxtw	x0, w2
   94038:	8b22c862 	add	x2, x3, w2, sxtw #2
   9403c:	54ffff4d 	b.le	94024 <__any_on+0x24>
   94040:	72001021 	ands	w1, w1, #0x1f
   94044:	54ffff00 	b.eq	94024 <__any_on+0x24>  // b.none
   94048:	b8607865 	ldr	w5, [x3, x0, lsl #2]
   9404c:	52800020 	mov	w0, #0x1                   	// #1
   94050:	1ac124a4 	lsr	w4, w5, w1
   94054:	1ac12081 	lsl	w1, w4, w1
   94058:	6b0100bf 	cmp	w5, w1
   9405c:	54fffe40 	b.eq	94024 <__any_on+0x24>  // b.none
   94060:	d65f03c0 	ret
   94064:	52800020 	mov	w0, #0x1                   	// #1
   94068:	d65f03c0 	ret
   9406c:	00000000 	udf	#0

0000000000094070 <_calloc_r>:
   94070:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   94074:	9bc27c23 	umulh	x3, x1, x2
   94078:	9b027c21 	mul	x1, x1, x2
   9407c:	910003fd 	mov	x29, sp
   94080:	f9000bf3 	str	x19, [sp, #16]
   94084:	b5000463 	cbnz	x3, 94110 <_calloc_r+0xa0>
   94088:	97ffdd3e 	bl	8b580 <_malloc_r>
   9408c:	aa0003f3 	mov	x19, x0
   94090:	b4000460 	cbz	x0, 9411c <_calloc_r+0xac>
   94094:	f85f8002 	ldur	x2, [x0, #-8]
   94098:	927ef442 	and	x2, x2, #0xfffffffffffffffc
   9409c:	d1002042 	sub	x2, x2, #0x8
   940a0:	f101205f 	cmp	x2, #0x48
   940a4:	540001c8 	b.hi	940dc <_calloc_r+0x6c>  // b.pmore
   940a8:	f1009c5f 	cmp	x2, #0x27
   940ac:	540000c9 	b.ls	940c4 <_calloc_r+0x54>  // b.plast
   940b0:	4f000400 	movi	v0.4s, #0x0
   940b4:	91004000 	add	x0, x0, #0x10
   940b8:	3c9f0000 	stur	q0, [x0, #-16]
   940bc:	f100dc5f 	cmp	x2, #0x37
   940c0:	540001a8 	b.hi	940f4 <_calloc_r+0x84>  // b.pmore
   940c4:	a9007c1f 	stp	xzr, xzr, [x0]
   940c8:	f900081f 	str	xzr, [x0, #16]
   940cc:	aa1303e0 	mov	x0, x19
   940d0:	f9400bf3 	ldr	x19, [sp, #16]
   940d4:	a8c27bfd 	ldp	x29, x30, [sp], #32
   940d8:	d65f03c0 	ret
   940dc:	52800001 	mov	w1, #0x0                   	// #0
   940e0:	97ffe538 	bl	8d5c0 <memset>
   940e4:	aa1303e0 	mov	x0, x19
   940e8:	f9400bf3 	ldr	x19, [sp, #16]
   940ec:	a8c27bfd 	ldp	x29, x30, [sp], #32
   940f0:	d65f03c0 	ret
   940f4:	3d800660 	str	q0, [x19, #16]
   940f8:	91008260 	add	x0, x19, #0x20
   940fc:	f101205f 	cmp	x2, #0x48
   94100:	54fffe21 	b.ne	940c4 <_calloc_r+0x54>  // b.any
   94104:	9100c260 	add	x0, x19, #0x30
   94108:	3d800a60 	str	q0, [x19, #32]
   9410c:	17ffffee 	b	940c4 <_calloc_r+0x54>
   94110:	97ffb7bc 	bl	82000 <__errno>
   94114:	52800181 	mov	w1, #0xc                   	// #12
   94118:	b9000001 	str	w1, [x0]
   9411c:	d2800013 	mov	x19, #0x0                   	// #0
   94120:	aa1303e0 	mov	x0, x19
   94124:	f9400bf3 	ldr	x19, [sp, #16]
   94128:	a8c27bfd 	ldp	x29, x30, [sp], #32
   9412c:	d65f03c0 	ret

0000000000094130 <_wcsnrtombs_l>:
   94130:	a9b87bfd 	stp	x29, x30, [sp, #-128]!
   94134:	f10000bf 	cmp	x5, #0x0
   94138:	910003fd 	mov	x29, sp
   9413c:	a90153f3 	stp	x19, x20, [sp, #16]
   94140:	aa0003f4 	mov	x20, x0
   94144:	91051000 	add	x0, x0, #0x144
   94148:	a9025bf5 	stp	x21, x22, [sp, #32]
   9414c:	aa0203f6 	mov	x22, x2
   94150:	aa0103f5 	mov	x21, x1
   94154:	a90363f7 	stp	x23, x24, [sp, #48]
   94158:	aa0603f7 	mov	x23, x6
   9415c:	a9046bf9 	stp	x25, x26, [sp, #64]
   94160:	9a850019 	csel	x25, x0, x5, eq	// eq = none
   94164:	a90573fb 	stp	x27, x28, [sp, #80]
   94168:	f940005c 	ldr	x28, [x2]
   9416c:	b4000901 	cbz	x1, 9428c <_wcsnrtombs_l+0x15c>
   94170:	aa0403f3 	mov	x19, x4
   94174:	b4000a84 	cbz	x4, 942c4 <_wcsnrtombs_l+0x194>
   94178:	d100047a 	sub	x26, x3, #0x1
   9417c:	b4000a43 	cbz	x3, 942c4 <_wcsnrtombs_l+0x194>
   94180:	d280001b 	mov	x27, #0x0                   	// #0
   94184:	f90037f5 	str	x21, [sp, #104]
   94188:	1400000a 	b	941b0 <_wcsnrtombs_l+0x80>
   9418c:	b50003f5 	cbnz	x21, 94208 <_wcsnrtombs_l+0xd8>
   94190:	b8404780 	ldr	w0, [x28], #4
   94194:	34000640 	cbz	w0, 9425c <_wcsnrtombs_l+0x12c>
   94198:	eb13009f 	cmp	x4, x19
   9419c:	54000982 	b.cs	942cc <_wcsnrtombs_l+0x19c>  // b.hs, b.nlast
   941a0:	d100075a 	sub	x26, x26, #0x1
   941a4:	aa0403fb 	mov	x27, x4
   941a8:	b100075f 	cmn	x26, #0x1
   941ac:	540001e0 	b.eq	941e8 <_wcsnrtombs_l+0xb8>  // b.none
   941b0:	f94072e4 	ldr	x4, [x23, #224]
   941b4:	aa1903e3 	mov	x3, x25
   941b8:	b9400382 	ldr	w2, [x28]
   941bc:	9101c3e1 	add	x1, sp, #0x70
   941c0:	f9400338 	ldr	x24, [x25]
   941c4:	aa1403e0 	mov	x0, x20
   941c8:	d63f0080 	blr	x4
   941cc:	3100041f 	cmn	w0, #0x1
   941d0:	54000620 	b.eq	94294 <_wcsnrtombs_l+0x164>  // b.none
   941d4:	93407c01 	sxtw	x1, w0
   941d8:	8b1b0024 	add	x4, x1, x27
   941dc:	eb13009f 	cmp	x4, x19
   941e0:	54fffd69 	b.ls	9418c <_wcsnrtombs_l+0x5c>  // b.plast
   941e4:	f9000338 	str	x24, [x25]
   941e8:	a94153f3 	ldp	x19, x20, [sp, #16]
   941ec:	aa1b03e0 	mov	x0, x27
   941f0:	a9425bf5 	ldp	x21, x22, [sp, #32]
   941f4:	a94363f7 	ldp	x23, x24, [sp, #48]
   941f8:	a9446bf9 	ldp	x25, x26, [sp, #64]
   941fc:	a94573fb 	ldp	x27, x28, [sp, #80]
   94200:	a8c87bfd 	ldp	x29, x30, [sp], #128
   94204:	d65f03c0 	ret
   94208:	7100001f 	cmp	w0, #0x0
   9420c:	540001ed 	b.le	94248 <_wcsnrtombs_l+0x118>
   94210:	f94037e2 	ldr	x2, [sp, #104]
   94214:	d2800027 	mov	x7, #0x1                   	// #1
   94218:	d1000443 	sub	x3, x2, #0x1
   9421c:	d503201f 	nop
   94220:	9101c3e2 	add	x2, sp, #0x70
   94224:	eb07003f 	cmp	x1, x7
   94228:	8b070042 	add	x2, x2, x7
   9422c:	385ff042 	ldurb	w2, [x2, #-1]
   94230:	38276862 	strb	w2, [x3, x7]
   94234:	910004e7 	add	x7, x7, #0x1
   94238:	54ffff41 	b.ne	94220 <_wcsnrtombs_l+0xf0>  // b.any
   9423c:	f94037e1 	ldr	x1, [sp, #104]
   94240:	8b204020 	add	x0, x1, w0, uxtw
   94244:	f90037e0 	str	x0, [sp, #104]
   94248:	f94002c0 	ldr	x0, [x22]
   9424c:	91001000 	add	x0, x0, #0x4
   94250:	f90002c0 	str	x0, [x22]
   94254:	b8404780 	ldr	w0, [x28], #4
   94258:	35fffa00 	cbnz	w0, 94198 <_wcsnrtombs_l+0x68>
   9425c:	b4000055 	cbz	x21, 94264 <_wcsnrtombs_l+0x134>
   94260:	f90002df 	str	xzr, [x22]
   94264:	b900033f 	str	wzr, [x25]
   94268:	d100049b 	sub	x27, x4, #0x1
   9426c:	a94153f3 	ldp	x19, x20, [sp, #16]
   94270:	aa1b03e0 	mov	x0, x27
   94274:	a9425bf5 	ldp	x21, x22, [sp, #32]
   94278:	a94363f7 	ldp	x23, x24, [sp, #48]
   9427c:	a9446bf9 	ldp	x25, x26, [sp, #64]
   94280:	a94573fb 	ldp	x27, x28, [sp, #80]
   94284:	a8c87bfd 	ldp	x29, x30, [sp], #128
   94288:	d65f03c0 	ret
   9428c:	92800013 	mov	x19, #0xffffffffffffffff    	// #-1
   94290:	17ffffba 	b	94178 <_wcsnrtombs_l+0x48>
   94294:	52801140 	mov	w0, #0x8a                  	// #138
   94298:	b9000280 	str	w0, [x20]
   9429c:	b900033f 	str	wzr, [x25]
   942a0:	9280001b 	mov	x27, #0xffffffffffffffff    	// #-1
   942a4:	a94153f3 	ldp	x19, x20, [sp, #16]
   942a8:	aa1b03e0 	mov	x0, x27
   942ac:	a9425bf5 	ldp	x21, x22, [sp, #32]
   942b0:	a94363f7 	ldp	x23, x24, [sp, #48]
   942b4:	a9446bf9 	ldp	x25, x26, [sp, #64]
   942b8:	a94573fb 	ldp	x27, x28, [sp, #80]
   942bc:	a8c87bfd 	ldp	x29, x30, [sp], #128
   942c0:	d65f03c0 	ret
   942c4:	d280001b 	mov	x27, #0x0                   	// #0
   942c8:	17ffffc8 	b	941e8 <_wcsnrtombs_l+0xb8>
   942cc:	aa0403fb 	mov	x27, x4
   942d0:	17ffffc6 	b	941e8 <_wcsnrtombs_l+0xb8>
	...

00000000000942e0 <_wcsnrtombs_r>:
   942e0:	d0000000 	adrp	x0, 96000 <JIS_state_table+0x70>
   942e4:	d0000006 	adrp	x6, 96000 <JIS_state_table+0x70>
   942e8:	913240c6 	add	x6, x6, #0xc90
   942ec:	f9410000 	ldr	x0, [x0, #512]
   942f0:	17ffff90 	b	94130 <_wcsnrtombs_l>
	...

0000000000094300 <wcsnrtombs>:
   94300:	d0000006 	adrp	x6, 96000 <JIS_state_table+0x70>
   94304:	aa0003e8 	mov	x8, x0
   94308:	aa0103e7 	mov	x7, x1
   9430c:	aa0203e5 	mov	x5, x2
   94310:	f94100c0 	ldr	x0, [x6, #512]
   94314:	aa0303e6 	mov	x6, x3
   94318:	aa0803e1 	mov	x1, x8
   9431c:	aa0503e3 	mov	x3, x5
   94320:	aa0703e2 	mov	x2, x7
   94324:	aa0403e5 	mov	x5, x4
   94328:	aa0603e4 	mov	x4, x6
   9432c:	d0000006 	adrp	x6, 96000 <JIS_state_table+0x70>
   94330:	913240c6 	add	x6, x6, #0xc90
   94334:	17ffff7f 	b	94130 <_wcsnrtombs_l>
	...

0000000000094340 <__env_lock>:
   94340:	d0001360 	adrp	x0, 302000 <irq_handlers+0x1370>
   94344:	913ce000 	add	x0, x0, #0xf38
   94348:	17ffdefa 	b	8bf30 <__retarget_lock_acquire_recursive>
   9434c:	00000000 	udf	#0

0000000000094350 <__env_unlock>:
   94350:	d0001360 	adrp	x0, 302000 <irq_handlers+0x1370>
   94354:	913ce000 	add	x0, x0, #0xf38
   94358:	17ffdf06 	b	8bf70 <__retarget_lock_release_recursive>
   9435c:	00000000 	udf	#0

0000000000094360 <_fiprintf_r>:
   94360:	a9b07bfd 	stp	x29, x30, [sp, #-256]!
   94364:	128004e9 	mov	w9, #0xffffffd8            	// #-40
   94368:	12800fe8 	mov	w8, #0xffffff80            	// #-128
   9436c:	910003fd 	mov	x29, sp
   94370:	910343ea 	add	x10, sp, #0xd0
   94374:	910403eb 	add	x11, sp, #0x100
   94378:	a9032feb 	stp	x11, x11, [sp, #48]
   9437c:	f90023ea 	str	x10, [sp, #64]
   94380:	290923e9 	stp	w9, w8, [sp, #72]
   94384:	3d8017e0 	str	q0, [sp, #80]
   94388:	ad41c3e0 	ldp	q0, q16, [sp, #48]
   9438c:	3d801be1 	str	q1, [sp, #96]
   94390:	3d801fe2 	str	q2, [sp, #112]
   94394:	ad00c3e0 	stp	q0, q16, [sp, #16]
   94398:	3d8023e3 	str	q3, [sp, #128]
   9439c:	3d8027e4 	str	q4, [sp, #144]
   943a0:	3d802be5 	str	q5, [sp, #160]
   943a4:	3d802fe6 	str	q6, [sp, #176]
   943a8:	3d8033e7 	str	q7, [sp, #192]
   943ac:	a90d93e3 	stp	x3, x4, [sp, #216]
   943b0:	910043e3 	add	x3, sp, #0x10
   943b4:	a90e9be5 	stp	x5, x6, [sp, #232]
   943b8:	f9007fe7 	str	x7, [sp, #248]
   943bc:	97ffd521 	bl	89840 <_vfiprintf_r>
   943c0:	a8d07bfd 	ldp	x29, x30, [sp], #256
   943c4:	d65f03c0 	ret
	...

00000000000943d0 <fiprintf>:
   943d0:	a9b07bfd 	stp	x29, x30, [sp, #-256]!
   943d4:	128005eb 	mov	w11, #0xffffffd0            	// #-48
   943d8:	12800fea 	mov	w10, #0xffffff80            	// #-128
   943dc:	910003fd 	mov	x29, sp
   943e0:	910403ec 	add	x12, sp, #0x100
   943e4:	910343e8 	add	x8, sp, #0xd0
   943e8:	d0000009 	adrp	x9, 96000 <JIS_state_table+0x70>
   943ec:	a90333ec 	stp	x12, x12, [sp, #48]
   943f0:	f90023e8 	str	x8, [sp, #64]
   943f4:	aa0103e8 	mov	x8, x1
   943f8:	29092beb 	stp	w11, w10, [sp, #72]
   943fc:	aa0003e1 	mov	x1, x0
   94400:	f9410120 	ldr	x0, [x9, #512]
   94404:	3d8017e0 	str	q0, [sp, #80]
   94408:	ad41c3e0 	ldp	q0, q16, [sp, #48]
   9440c:	3d801be1 	str	q1, [sp, #96]
   94410:	3d801fe2 	str	q2, [sp, #112]
   94414:	ad00c3e0 	stp	q0, q16, [sp, #16]
   94418:	3d8023e3 	str	q3, [sp, #128]
   9441c:	3d8027e4 	str	q4, [sp, #144]
   94420:	3d802be5 	str	q5, [sp, #160]
   94424:	3d802fe6 	str	q6, [sp, #176]
   94428:	3d8033e7 	str	q7, [sp, #192]
   9442c:	a90d0fe2 	stp	x2, x3, [sp, #208]
   94430:	910043e3 	add	x3, sp, #0x10
   94434:	aa0803e2 	mov	x2, x8
   94438:	a90e17e4 	stp	x4, x5, [sp, #224]
   9443c:	a90f1fe6 	stp	x6, x7, [sp, #240]
   94440:	97ffd500 	bl	89840 <_vfiprintf_r>
   94444:	a8d07bfd 	ldp	x29, x30, [sp], #256
   94448:	d65f03c0 	ret
   9444c:	00000000 	udf	#0

0000000000094450 <abort>:
   94450:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!
   94454:	528000c0 	mov	w0, #0x6                   	// #6
   94458:	910003fd 	mov	x29, sp
   9445c:	94000099 	bl	946c0 <raise>
   94460:	52800020 	mov	w0, #0x1                   	// #1
   94464:	97ffb293 	bl	80eb0 <_exit>
	...

0000000000094470 <_init_signal_r>:
   94470:	f940a801 	ldr	x1, [x0, #336]
   94474:	b4000061 	cbz	x1, 94480 <_init_signal_r+0x10>
   94478:	52800000 	mov	w0, #0x0                   	// #0
   9447c:	d65f03c0 	ret
   94480:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   94484:	d2802001 	mov	x1, #0x100                 	// #256
   94488:	910003fd 	mov	x29, sp
   9448c:	f9000bf3 	str	x19, [sp, #16]
   94490:	aa0003f3 	mov	x19, x0
   94494:	97ffdc3b 	bl	8b580 <_malloc_r>
   94498:	f900aa60 	str	x0, [x19, #336]
   9449c:	b4000140 	cbz	x0, 944c4 <_init_signal_r+0x54>
   944a0:	91040001 	add	x1, x0, #0x100
   944a4:	d503201f 	nop
   944a8:	f800841f 	str	xzr, [x0], #8
   944ac:	eb01001f 	cmp	x0, x1
   944b0:	54ffffc1 	b.ne	944a8 <_init_signal_r+0x38>  // b.any
   944b4:	52800000 	mov	w0, #0x0                   	// #0
   944b8:	f9400bf3 	ldr	x19, [sp, #16]
   944bc:	a8c27bfd 	ldp	x29, x30, [sp], #32
   944c0:	d65f03c0 	ret
   944c4:	12800000 	mov	w0, #0xffffffff            	// #-1
   944c8:	17fffffc 	b	944b8 <_init_signal_r+0x48>
   944cc:	00000000 	udf	#0

00000000000944d0 <_signal_r>:
   944d0:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   944d4:	910003fd 	mov	x29, sp
   944d8:	a90153f3 	stp	x19, x20, [sp, #16]
   944dc:	93407c33 	sxtw	x19, w1
   944e0:	aa0003f4 	mov	x20, x0
   944e4:	71007e7f 	cmp	w19, #0x1f
   944e8:	54000108 	b.hi	94508 <_signal_r+0x38>  // b.pmore
   944ec:	f940a801 	ldr	x1, [x0, #336]
   944f0:	b4000141 	cbz	x1, 94518 <_signal_r+0x48>
   944f4:	f8737820 	ldr	x0, [x1, x19, lsl #3]
   944f8:	f8337822 	str	x2, [x1, x19, lsl #3]
   944fc:	a94153f3 	ldp	x19, x20, [sp, #16]
   94500:	a8c37bfd 	ldp	x29, x30, [sp], #48
   94504:	d65f03c0 	ret
   94508:	528002c0 	mov	w0, #0x16                  	// #22
   9450c:	b9000280 	str	w0, [x20]
   94510:	92800000 	mov	x0, #0xffffffffffffffff    	// #-1
   94514:	17fffffa 	b	944fc <_signal_r+0x2c>
   94518:	d2802001 	mov	x1, #0x100                 	// #256
   9451c:	f90017e2 	str	x2, [sp, #40]
   94520:	97ffdc18 	bl	8b580 <_malloc_r>
   94524:	f900aa80 	str	x0, [x20, #336]
   94528:	f94017e2 	ldr	x2, [sp, #40]
   9452c:	aa0003e1 	mov	x1, x0
   94530:	b4ffff00 	cbz	x0, 94510 <_signal_r+0x40>
   94534:	91040003 	add	x3, x0, #0x100
   94538:	f800841f 	str	xzr, [x0], #8
   9453c:	eb03001f 	cmp	x0, x3
   94540:	54ffffc1 	b.ne	94538 <_signal_r+0x68>  // b.any
   94544:	17ffffec 	b	944f4 <_signal_r+0x24>
	...

0000000000094550 <_raise_r>:
   94550:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   94554:	910003fd 	mov	x29, sp
   94558:	a90153f3 	stp	x19, x20, [sp, #16]
   9455c:	aa0003f4 	mov	x20, x0
   94560:	71007c3f 	cmp	w1, #0x1f
   94564:	54000408 	b.hi	945e4 <_raise_r+0x94>  // b.pmore
   94568:	f940a800 	ldr	x0, [x0, #336]
   9456c:	2a0103f3 	mov	w19, w1
   94570:	b40001e0 	cbz	x0, 945ac <_raise_r+0x5c>
   94574:	93407c22 	sxtw	x2, w1
   94578:	f8627801 	ldr	x1, [x0, x2, lsl #3]
   9457c:	b4000181 	cbz	x1, 945ac <_raise_r+0x5c>
   94580:	f100043f 	cmp	x1, #0x1
   94584:	540000c0 	b.eq	9459c <_raise_r+0x4c>  // b.none
   94588:	b100043f 	cmn	x1, #0x1
   9458c:	54000200 	b.eq	945cc <_raise_r+0x7c>  // b.none
   94590:	f822781f 	str	xzr, [x0, x2, lsl #3]
   94594:	2a1303e0 	mov	w0, w19
   94598:	d63f0020 	blr	x1
   9459c:	52800000 	mov	w0, #0x0                   	// #0
   945a0:	a94153f3 	ldp	x19, x20, [sp, #16]
   945a4:	a8c27bfd 	ldp	x29, x30, [sp], #32
   945a8:	d65f03c0 	ret
   945ac:	aa1403e0 	mov	x0, x20
   945b0:	940000f0 	bl	94970 <_getpid_r>
   945b4:	2a1303e2 	mov	w2, w19
   945b8:	2a0003e1 	mov	w1, w0
   945bc:	aa1403e0 	mov	x0, x20
   945c0:	a94153f3 	ldp	x19, x20, [sp, #16]
   945c4:	a8c27bfd 	ldp	x29, x30, [sp], #32
   945c8:	140000d6 	b	94920 <_kill_r>
   945cc:	528002c1 	mov	w1, #0x16                  	// #22
   945d0:	b9000281 	str	w1, [x20]
   945d4:	a94153f3 	ldp	x19, x20, [sp, #16]
   945d8:	52800020 	mov	w0, #0x1                   	// #1
   945dc:	a8c27bfd 	ldp	x29, x30, [sp], #32
   945e0:	d65f03c0 	ret
   945e4:	528002c1 	mov	w1, #0x16                  	// #22
   945e8:	12800000 	mov	w0, #0xffffffff            	// #-1
   945ec:	b9000281 	str	w1, [x20]
   945f0:	17ffffec 	b	945a0 <_raise_r+0x50>
	...

0000000000094600 <__sigtramp_r>:
   94600:	71007c3f 	cmp	w1, #0x1f
   94604:	540005a8 	b.hi	946b8 <__sigtramp_r+0xb8>  // b.pmore
   94608:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   9460c:	910003fd 	mov	x29, sp
   94610:	a90153f3 	stp	x19, x20, [sp, #16]
   94614:	2a0103f3 	mov	w19, w1
   94618:	aa0003f4 	mov	x20, x0
   9461c:	f940a801 	ldr	x1, [x0, #336]
   94620:	b4000321 	cbz	x1, 94684 <__sigtramp_r+0x84>
   94624:	f873d822 	ldr	x2, [x1, w19, sxtw #3]
   94628:	8b33cc21 	add	x1, x1, w19, sxtw #3
   9462c:	b4000182 	cbz	x2, 9465c <__sigtramp_r+0x5c>
   94630:	b100045f 	cmn	x2, #0x1
   94634:	54000240 	b.eq	9467c <__sigtramp_r+0x7c>  // b.none
   94638:	f100045f 	cmp	x2, #0x1
   9463c:	54000180 	b.eq	9466c <__sigtramp_r+0x6c>  // b.none
   94640:	f900003f 	str	xzr, [x1]
   94644:	2a1303e0 	mov	w0, w19
   94648:	d63f0040 	blr	x2
   9464c:	52800000 	mov	w0, #0x0                   	// #0
   94650:	a94153f3 	ldp	x19, x20, [sp, #16]
   94654:	a8c27bfd 	ldp	x29, x30, [sp], #32
   94658:	d65f03c0 	ret
   9465c:	a94153f3 	ldp	x19, x20, [sp, #16]
   94660:	52800020 	mov	w0, #0x1                   	// #1
   94664:	a8c27bfd 	ldp	x29, x30, [sp], #32
   94668:	d65f03c0 	ret
   9466c:	a94153f3 	ldp	x19, x20, [sp, #16]
   94670:	52800060 	mov	w0, #0x3                   	// #3
   94674:	a8c27bfd 	ldp	x29, x30, [sp], #32
   94678:	d65f03c0 	ret
   9467c:	52800040 	mov	w0, #0x2                   	// #2
   94680:	17fffff4 	b	94650 <__sigtramp_r+0x50>
   94684:	d2802001 	mov	x1, #0x100                 	// #256
   94688:	97ffdbbe 	bl	8b580 <_malloc_r>
   9468c:	f900aa80 	str	x0, [x20, #336]
   94690:	aa0003e1 	mov	x1, x0
   94694:	b40000e0 	cbz	x0, 946b0 <__sigtramp_r+0xb0>
   94698:	91040002 	add	x2, x0, #0x100
   9469c:	d503201f 	nop
   946a0:	f800841f 	str	xzr, [x0], #8
   946a4:	eb00005f 	cmp	x2, x0
   946a8:	54ffffc1 	b.ne	946a0 <__sigtramp_r+0xa0>  // b.any
   946ac:	17ffffde 	b	94624 <__sigtramp_r+0x24>
   946b0:	12800000 	mov	w0, #0xffffffff            	// #-1
   946b4:	17ffffe7 	b	94650 <__sigtramp_r+0x50>
   946b8:	12800000 	mov	w0, #0xffffffff            	// #-1
   946bc:	d65f03c0 	ret

00000000000946c0 <raise>:
   946c0:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   946c4:	d0000001 	adrp	x1, 96000 <JIS_state_table+0x70>
   946c8:	910003fd 	mov	x29, sp
   946cc:	a90153f3 	stp	x19, x20, [sp, #16]
   946d0:	f9410034 	ldr	x20, [x1, #512]
   946d4:	71007c1f 	cmp	w0, #0x1f
   946d8:	540003e8 	b.hi	94754 <raise+0x94>  // b.pmore
   946dc:	f940aa82 	ldr	x2, [x20, #336]
   946e0:	2a0003f3 	mov	w19, w0
   946e4:	b40001c2 	cbz	x2, 9471c <raise+0x5c>
   946e8:	93407c03 	sxtw	x3, w0
   946ec:	f8637841 	ldr	x1, [x2, x3, lsl #3]
   946f0:	b4000161 	cbz	x1, 9471c <raise+0x5c>
   946f4:	f100043f 	cmp	x1, #0x1
   946f8:	540000a0 	b.eq	9470c <raise+0x4c>  // b.none
   946fc:	b100043f 	cmn	x1, #0x1
   94700:	540001e0 	b.eq	9473c <raise+0x7c>  // b.none
   94704:	f823785f 	str	xzr, [x2, x3, lsl #3]
   94708:	d63f0020 	blr	x1
   9470c:	52800000 	mov	w0, #0x0                   	// #0
   94710:	a94153f3 	ldp	x19, x20, [sp, #16]
   94714:	a8c27bfd 	ldp	x29, x30, [sp], #32
   94718:	d65f03c0 	ret
   9471c:	aa1403e0 	mov	x0, x20
   94720:	94000094 	bl	94970 <_getpid_r>
   94724:	2a1303e2 	mov	w2, w19
   94728:	2a0003e1 	mov	w1, w0
   9472c:	aa1403e0 	mov	x0, x20
   94730:	a94153f3 	ldp	x19, x20, [sp, #16]
   94734:	a8c27bfd 	ldp	x29, x30, [sp], #32
   94738:	1400007a 	b	94920 <_kill_r>
   9473c:	528002c1 	mov	w1, #0x16                  	// #22
   94740:	b9000281 	str	w1, [x20]
   94744:	a94153f3 	ldp	x19, x20, [sp, #16]
   94748:	52800020 	mov	w0, #0x1                   	// #1
   9474c:	a8c27bfd 	ldp	x29, x30, [sp], #32
   94750:	d65f03c0 	ret
   94754:	528002c1 	mov	w1, #0x16                  	// #22
   94758:	12800000 	mov	w0, #0xffffffff            	// #-1
   9475c:	b9000281 	str	w1, [x20]
   94760:	17ffffec 	b	94710 <raise+0x50>
	...

0000000000094770 <signal>:
   94770:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   94774:	d0000002 	adrp	x2, 96000 <JIS_state_table+0x70>
   94778:	910003fd 	mov	x29, sp
   9477c:	a90153f3 	stp	x19, x20, [sp, #16]
   94780:	93407c13 	sxtw	x19, w0
   94784:	f90013f5 	str	x21, [sp, #32]
   94788:	f9410055 	ldr	x21, [x2, #512]
   9478c:	71007e7f 	cmp	w19, #0x1f
   94790:	54000148 	b.hi	947b8 <signal+0x48>  // b.pmore
   94794:	aa0103f4 	mov	x20, x1
   94798:	f940aaa1 	ldr	x1, [x21, #336]
   9479c:	b4000161 	cbz	x1, 947c8 <signal+0x58>
   947a0:	f8737820 	ldr	x0, [x1, x19, lsl #3]
   947a4:	f8337834 	str	x20, [x1, x19, lsl #3]
   947a8:	a94153f3 	ldp	x19, x20, [sp, #16]
   947ac:	f94013f5 	ldr	x21, [sp, #32]
   947b0:	a8c37bfd 	ldp	x29, x30, [sp], #48
   947b4:	d65f03c0 	ret
   947b8:	528002c0 	mov	w0, #0x16                  	// #22
   947bc:	b90002a0 	str	w0, [x21]
   947c0:	92800000 	mov	x0, #0xffffffffffffffff    	// #-1
   947c4:	17fffff9 	b	947a8 <signal+0x38>
   947c8:	d2802001 	mov	x1, #0x100                 	// #256
   947cc:	aa1503e0 	mov	x0, x21
   947d0:	97ffdb6c 	bl	8b580 <_malloc_r>
   947d4:	f900aaa0 	str	x0, [x21, #336]
   947d8:	aa0003e1 	mov	x1, x0
   947dc:	b4ffff20 	cbz	x0, 947c0 <signal+0x50>
   947e0:	91040002 	add	x2, x0, #0x100
   947e4:	d503201f 	nop
   947e8:	f800841f 	str	xzr, [x0], #8
   947ec:	eb02001f 	cmp	x0, x2
   947f0:	54ffffc1 	b.ne	947e8 <signal+0x78>  // b.any
   947f4:	17ffffeb 	b	947a0 <signal+0x30>
	...

0000000000094800 <_init_signal>:
   94800:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   94804:	d0000000 	adrp	x0, 96000 <JIS_state_table+0x70>
   94808:	910003fd 	mov	x29, sp
   9480c:	f9000bf3 	str	x19, [sp, #16]
   94810:	f9410013 	ldr	x19, [x0, #512]
   94814:	f940aa60 	ldr	x0, [x19, #336]
   94818:	b40000a0 	cbz	x0, 9482c <_init_signal+0x2c>
   9481c:	52800000 	mov	w0, #0x0                   	// #0
   94820:	f9400bf3 	ldr	x19, [sp, #16]
   94824:	a8c27bfd 	ldp	x29, x30, [sp], #32
   94828:	d65f03c0 	ret
   9482c:	aa1303e0 	mov	x0, x19
   94830:	d2802001 	mov	x1, #0x100                 	// #256
   94834:	97ffdb53 	bl	8b580 <_malloc_r>
   94838:	f900aa60 	str	x0, [x19, #336]
   9483c:	b40000e0 	cbz	x0, 94858 <_init_signal+0x58>
   94840:	91040001 	add	x1, x0, #0x100
   94844:	d503201f 	nop
   94848:	f800841f 	str	xzr, [x0], #8
   9484c:	eb01001f 	cmp	x0, x1
   94850:	54ffffc1 	b.ne	94848 <_init_signal+0x48>  // b.any
   94854:	17fffff2 	b	9481c <_init_signal+0x1c>
   94858:	12800000 	mov	w0, #0xffffffff            	// #-1
   9485c:	17fffff1 	b	94820 <_init_signal+0x20>

0000000000094860 <__sigtramp>:
   94860:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   94864:	d0000001 	adrp	x1, 96000 <JIS_state_table+0x70>
   94868:	910003fd 	mov	x29, sp
   9486c:	a90153f3 	stp	x19, x20, [sp, #16]
   94870:	f9410034 	ldr	x20, [x1, #512]
   94874:	71007c1f 	cmp	w0, #0x1f
   94878:	54000508 	b.hi	94918 <__sigtramp+0xb8>  // b.pmore
   9487c:	2a0003f3 	mov	w19, w0
   94880:	f940aa80 	ldr	x0, [x20, #336]
   94884:	b4000320 	cbz	x0, 948e8 <__sigtramp+0x88>
   94888:	f873d801 	ldr	x1, [x0, w19, sxtw #3]
   9488c:	8b33cc00 	add	x0, x0, w19, sxtw #3
   94890:	b4000181 	cbz	x1, 948c0 <__sigtramp+0x60>
   94894:	b100043f 	cmn	x1, #0x1
   94898:	54000240 	b.eq	948e0 <__sigtramp+0x80>  // b.none
   9489c:	f100043f 	cmp	x1, #0x1
   948a0:	54000180 	b.eq	948d0 <__sigtramp+0x70>  // b.none
   948a4:	f900001f 	str	xzr, [x0]
   948a8:	2a1303e0 	mov	w0, w19
   948ac:	d63f0020 	blr	x1
   948b0:	52800000 	mov	w0, #0x0                   	// #0
   948b4:	a94153f3 	ldp	x19, x20, [sp, #16]
   948b8:	a8c27bfd 	ldp	x29, x30, [sp], #32
   948bc:	d65f03c0 	ret
   948c0:	a94153f3 	ldp	x19, x20, [sp, #16]
   948c4:	52800020 	mov	w0, #0x1                   	// #1
   948c8:	a8c27bfd 	ldp	x29, x30, [sp], #32
   948cc:	d65f03c0 	ret
   948d0:	a94153f3 	ldp	x19, x20, [sp, #16]
   948d4:	52800060 	mov	w0, #0x3                   	// #3
   948d8:	a8c27bfd 	ldp	x29, x30, [sp], #32
   948dc:	d65f03c0 	ret
   948e0:	52800040 	mov	w0, #0x2                   	// #2
   948e4:	17fffff4 	b	948b4 <__sigtramp+0x54>
   948e8:	aa1403e0 	mov	x0, x20
   948ec:	d2802001 	mov	x1, #0x100                 	// #256
   948f0:	97ffdb24 	bl	8b580 <_malloc_r>
   948f4:	f900aa80 	str	x0, [x20, #336]
   948f8:	b4000100 	cbz	x0, 94918 <__sigtramp+0xb8>
   948fc:	aa0003e1 	mov	x1, x0
   94900:	91040002 	add	x2, x0, #0x100
   94904:	d503201f 	nop
   94908:	f800843f 	str	xzr, [x1], #8
   9490c:	eb01005f 	cmp	x2, x1
   94910:	54ffffc1 	b.ne	94908 <__sigtramp+0xa8>  // b.any
   94914:	17ffffdd 	b	94888 <__sigtramp+0x28>
   94918:	12800000 	mov	w0, #0xffffffff            	// #-1
   9491c:	17ffffe6 	b	948b4 <__sigtramp+0x54>

0000000000094920 <_kill_r>:
   94920:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   94924:	910003fd 	mov	x29, sp
   94928:	a90153f3 	stp	x19, x20, [sp, #16]
   9492c:	f0001374 	adrp	x20, 303000 <saved_categories.0+0xa0>
   94930:	aa0003f3 	mov	x19, x0
   94934:	b9012a9f 	str	wzr, [x20, #296]
   94938:	2a0103e0 	mov	w0, w1
   9493c:	2a0203e1 	mov	w1, w2
   94940:	97ffb164 	bl	80ed0 <_kill>
   94944:	3100041f 	cmn	w0, #0x1
   94948:	54000080 	b.eq	94958 <_kill_r+0x38>  // b.none
   9494c:	a94153f3 	ldp	x19, x20, [sp, #16]
   94950:	a8c27bfd 	ldp	x29, x30, [sp], #32
   94954:	d65f03c0 	ret
   94958:	b9412a81 	ldr	w1, [x20, #296]
   9495c:	34ffff81 	cbz	w1, 9494c <_kill_r+0x2c>
   94960:	b9000261 	str	w1, [x19]
   94964:	a94153f3 	ldp	x19, x20, [sp, #16]
   94968:	a8c27bfd 	ldp	x29, x30, [sp], #32
   9496c:	d65f03c0 	ret

0000000000094970 <_getpid_r>:
   94970:	17ffb154 	b	80ec0 <_getpid>
	...

0000000000094980 <__trunctfdf2>:
   94980:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
   94984:	9e660002 	fmov	x2, d0
   94988:	9eae0003 	fmov	x3, v0.d[1]
   9498c:	910003fd 	mov	x29, sp
   94990:	f9000bf3 	str	x19, [sp, #16]
   94994:	d53b4405 	mrs	x5, fpcr
   94998:	aa0303e0 	mov	x0, x3
   9499c:	d37ffc63 	lsr	x3, x3, #63
   949a0:	aa0303f3 	mov	x19, x3
   949a4:	12001c66 	and	w6, w3, #0xff
   949a8:	d370f801 	ubfx	x1, x0, #48, #15
   949ac:	d37dbc00 	ubfiz	x0, x0, #3, #48
   949b0:	91000424 	add	x4, x1, #0x1
   949b4:	aa0303e7 	mov	x7, x3
   949b8:	aa42f400 	orr	x0, x0, x2, lsr #61
   949bc:	d37df043 	lsl	x3, x2, #3
   949c0:	f27f349f 	tst	x4, #0x7ffe
   949c4:	54000700 	b.eq	94aa4 <__trunctfdf2+0x124>  // b.none
   949c8:	92877fe4 	mov	x4, #0xffffffffffffc400    	// #-15360
   949cc:	8b040024 	add	x4, x1, x4
   949d0:	f11ff89f 	cmp	x4, #0x7fe
   949d4:	540003ad 	b.le	94a48 <__trunctfdf2+0xc8>
   949d8:	f26a04a5 	ands	x5, x5, #0xc00000
   949dc:	5280ffe0 	mov	w0, #0x7ff                 	// #2047
   949e0:	54000240 	b.eq	94a28 <__trunctfdf2+0xa8>  // b.none
   949e4:	f15000bf 	cmp	x5, #0x400, lsl #12
   949e8:	54001520 	b.eq	94c8c <__trunctfdf2+0x30c>  // b.none
   949ec:	f16000bf 	cmp	x5, #0x800, lsl #12
   949f0:	1a9f17e1 	cset	w1, eq	// eq = none
   949f4:	6a0100df 	tst	w6, w1
   949f8:	54001681 	b.ne	94cc8 <__trunctfdf2+0x348>  // b.any
   949fc:	f15000bf 	cmp	x5, #0x400, lsl #12
   94a00:	540014a0 	b.eq	94c94 <__trunctfdf2+0x314>  // b.none
   94a04:	f16000bf 	cmp	x5, #0x800, lsl #12
   94a08:	5280ffc0 	mov	w0, #0x7fe                 	// #2046
   94a0c:	1a9f17e1 	cset	w1, eq	// eq = none
   94a10:	5280ffe2 	mov	w2, #0x7ff                 	// #2047
   94a14:	6a0100c1 	ands	w1, w6, w1
   94a18:	92fc0005 	mov	x5, #0x1fffffffffffffff    	// #2305843009213693951
   94a1c:	1a820000 	csel	w0, w0, w2, eq	// eq = none
   94a20:	9a9f00a5 	csel	x5, x5, xzr, eq	// eq = none
   94a24:	d503201f 	nop
   94a28:	b34c2c05 	bfi	x5, x0, #52, #12
   94a2c:	52800280 	mov	w0, #0x14                  	// #20
   94a30:	aa13fcb3 	orr	x19, x5, x19, lsl #63
   94a34:	940000c3 	bl	94d40 <__sfp_handle_exceptions>
   94a38:	9e670260 	fmov	d0, x19
   94a3c:	f9400bf3 	ldr	x19, [sp, #16]
   94a40:	a8c27bfd 	ldp	x29, x30, [sp], #32
   94a44:	d65f03c0 	ret
   94a48:	f100009f 	cmp	x4, #0x0
   94a4c:	540007ed 	b.le	94b48 <__trunctfdf2+0x1c8>
   94a50:	eb021fff 	cmp	xzr, x2, lsl #7
   94a54:	52800007 	mov	w7, #0x0                   	// #0
   94a58:	9a9f07e1 	cset	x1, ne	// ne = any
   94a5c:	aa43f023 	orr	x3, x1, x3, lsr #60
   94a60:	aa001061 	orr	x1, x3, x0, lsl #4
   94a64:	92400863 	and	x3, x3, #0x7
   94a68:	b4001423 	cbz	x3, 94cec <__trunctfdf2+0x36c>
   94a6c:	926a04a5 	and	x5, x5, #0xc00000
   94a70:	f15000bf 	cmp	x5, #0x400, lsl #12
   94a74:	54000ac0 	b.eq	94bcc <__trunctfdf2+0x24c>  // b.none
   94a78:	f16000bf 	cmp	x5, #0x800, lsl #12
   94a7c:	54000fe0 	b.eq	94c78 <__trunctfdf2+0x2f8>  // b.none
   94a80:	b40008c5 	cbz	x5, 94b98 <__trunctfdf2+0x218>
   94a84:	35000c87 	cbnz	w7, 94c14 <__trunctfdf2+0x294>
   94a88:	d343fc21 	lsr	x1, x1, #3
   94a8c:	12002887 	and	w7, w4, #0x7ff
   94a90:	52800200 	mov	w0, #0x10                  	// #16
   94a94:	b34c2ce1 	bfi	x1, x7, #52, #12
   94a98:	aa13fc33 	orr	x19, x1, x19, lsl #63
   94a9c:	940000a9 	bl	94d40 <__sfp_handle_exceptions>
   94aa0:	17ffffe6 	b	94a38 <__trunctfdf2+0xb8>
   94aa4:	aa030002 	orr	x2, x0, x3
   94aa8:	b50001c1 	cbnz	x1, 94ae0 <__trunctfdf2+0x160>
   94aac:	b40004a2 	cbz	x2, 94b40 <__trunctfdf2+0x1c0>
   94ab0:	926a04a0 	and	x0, x5, #0xc00000
   94ab4:	f150001f 	cmp	x0, #0x400, lsl #12
   94ab8:	54000fc0 	b.eq	94cb0 <__trunctfdf2+0x330>  // b.none
   94abc:	f160001f 	cmp	x0, #0x800, lsl #12
   94ac0:	54000ae0 	b.eq	94c1c <__trunctfdf2+0x29c>  // b.none
   94ac4:	b4000a40 	cbz	x0, 94c0c <__trunctfdf2+0x28c>
   94ac8:	d2800007 	mov	x7, #0x0                   	// #0
   94acc:	d2800021 	mov	x1, #0x1                   	// #1
   94ad0:	d343fc21 	lsr	x1, x1, #3
   94ad4:	120028e7 	and	w7, w7, #0x7ff
   94ad8:	52800300 	mov	w0, #0x18                  	// #24
   94adc:	17ffffee 	b	94a94 <__trunctfdf2+0x114>
   94ae0:	b4000222 	cbz	x2, 94b24 <__trunctfdf2+0x1a4>
   94ae4:	d28fffe2 	mov	x2, #0x7fff                	// #32767
   94ae8:	93c3f003 	extr	x3, x0, x3, #60
   94aec:	d372fc00 	lsr	x0, x0, #50
   94af0:	eb02003f 	cmp	x1, x2
   94af4:	d343fc63 	lsr	x3, x3, #3
   94af8:	52000000 	eor	w0, w0, #0x1
   94afc:	b24d0061 	orr	x1, x3, #0x8000000000000
   94b00:	1a9f0000 	csel	w0, w0, wzr, eq	// eq = none
   94b04:	5280ffe2 	mov	w2, #0x7ff                 	// #2047
   94b08:	aa02d021 	orr	x1, x1, x2, lsl #52
   94b0c:	aa13fc33 	orr	x19, x1, x19, lsl #63
   94b10:	35fff920 	cbnz	w0, 94a34 <__trunctfdf2+0xb4>
   94b14:	9e670260 	fmov	d0, x19
   94b18:	f9400bf3 	ldr	x19, [sp, #16]
   94b1c:	a8c27bfd 	ldp	x29, x30, [sp], #32
   94b20:	d65f03c0 	ret
   94b24:	5280ffe0 	mov	w0, #0x7ff                 	// #2047
   94b28:	d34c2c00 	lsl	x0, x0, #52
   94b2c:	aa13fc13 	orr	x19, x0, x19, lsl #63
   94b30:	9e670260 	fmov	d0, x19
   94b34:	f9400bf3 	ldr	x19, [sp, #16]
   94b38:	a8c27bfd 	ldp	x29, x30, [sp], #32
   94b3c:	d65f03c0 	ret
   94b40:	52800000 	mov	w0, #0x0                   	// #0
   94b44:	17fffff9 	b	94b28 <__trunctfdf2+0x1a8>
   94b48:	b100d09f 	cmn	x4, #0x34
   94b4c:	54fffb2b 	b.lt	94ab0 <__trunctfdf2+0x130>  // b.tstop
   94b50:	d28007a2 	mov	x2, #0x3d                  	// #61
   94b54:	cb040047 	sub	x7, x2, x4
   94b58:	b24d0000 	orr	x0, x0, #0x8000000000000
   94b5c:	f100fcff 	cmp	x7, #0x3f
   94b60:	540006ec 	b.gt	94c3c <__trunctfdf2+0x2bc>
   94b64:	11000c81 	add	w1, w4, #0x3
   94b68:	4b040042 	sub	w2, w2, w4
   94b6c:	52800027 	mov	w7, #0x1                   	// #1
   94b70:	d2800004 	mov	x4, #0x0                   	// #0
   94b74:	9ac12068 	lsl	x8, x3, x1
   94b78:	f100011f 	cmp	x8, #0x0
   94b7c:	9a9f07e8 	cset	x8, ne	// ne = any
   94b80:	9ac22463 	lsr	x3, x3, x2
   94b84:	aa080063 	orr	x3, x3, x8
   94b88:	9ac12000 	lsl	x0, x0, x1
   94b8c:	aa030001 	orr	x1, x0, x3
   94b90:	92400823 	and	x3, x1, #0x7
   94b94:	17ffffb5 	b	94a68 <__trunctfdf2+0xe8>
   94b98:	92400c20 	and	x0, x1, #0xf
   94b9c:	f100101f 	cmp	x0, #0x4
   94ba0:	54fff720 	b.eq	94a84 <__trunctfdf2+0x104>  // b.none
   94ba4:	91001021 	add	x1, x1, #0x4
   94ba8:	92490020 	and	x0, x1, #0x80000000000000
   94bac:	35000187 	cbnz	w7, 94bdc <__trunctfdf2+0x25c>
   94bb0:	b4fff6c0 	cbz	x0, 94a88 <__trunctfdf2+0x108>
   94bb4:	91000482 	add	x2, x4, #0x1
   94bb8:	f11ff89f 	cmp	x4, #0x7fe
   94bbc:	540008a1 	b.ne	94cd0 <__trunctfdf2+0x350>  // b.any
   94bc0:	2a0203e0 	mov	w0, w2
   94bc4:	b4fff325 	cbz	x5, 94a28 <__trunctfdf2+0xa8>
   94bc8:	17ffff8d 	b	949fc <__trunctfdf2+0x7c>
   94bcc:	b5fff5d3 	cbnz	x19, 94a84 <__trunctfdf2+0x104>
   94bd0:	91002021 	add	x1, x1, #0x8
   94bd4:	92490020 	and	x0, x1, #0x80000000000000
   94bd8:	34fffec7 	cbz	w7, 94bb0 <__trunctfdf2+0x230>
   94bdc:	b40001c0 	cbz	x0, 94c14 <__trunctfdf2+0x294>
   94be0:	92fc0200 	mov	x0, #0x1fefffffffffffff    	// #2301339409586323455
   94be4:	f11ff89f 	cmp	x4, #0x7fe
   94be8:	8a410c01 	and	x1, x0, x1, lsr #3
   94bec:	91000482 	add	x2, x4, #0x1
   94bf0:	fa400824 	ccmp	x1, #0x0, #0x4, eq	// eq = none
   94bf4:	54000900 	b.eq	94d14 <__trunctfdf2+0x394>  // b.none
   94bf8:	b24d2c21 	orr	x1, x1, #0x7ff8000000000000
   94bfc:	52800300 	mov	w0, #0x18                  	// #24
   94c00:	aa13fc33 	orr	x19, x1, x19, lsl #63
   94c04:	9400004f 	bl	94d40 <__sfp_handle_exceptions>
   94c08:	17ffff8c 	b	94a38 <__trunctfdf2+0xb8>
   94c0c:	d28000a1 	mov	x1, #0x5                   	// #5
   94c10:	d2800004 	mov	x4, #0x0                   	// #0
   94c14:	aa0403e7 	mov	x7, x4
   94c18:	17ffffae 	b	94ad0 <__trunctfdf2+0x150>
   94c1c:	d2800021 	mov	x1, #0x1                   	// #1
   94c20:	b5000093 	cbnz	x19, 94c30 <__trunctfdf2+0x2b0>
   94c24:	aa0703e4 	mov	x4, x7
   94c28:	aa0403e7 	mov	x7, x4
   94c2c:	17ffffa9 	b	94ad0 <__trunctfdf2+0x150>
   94c30:	d2800007 	mov	x7, #0x0                   	// #0
   94c34:	d2800121 	mov	x1, #0x9                   	// #9
   94c38:	17ffffa6 	b	94ad0 <__trunctfdf2+0x150>
   94c3c:	11010c81 	add	w1, w4, #0x43
   94c40:	f10100ff 	cmp	x7, #0x40
   94c44:	12800042 	mov	w2, #0xfffffffd            	// #-3
   94c48:	4b040042 	sub	w2, w2, w4
   94c4c:	9ac12001 	lsl	x1, x0, x1
   94c50:	aa010061 	orr	x1, x3, x1
   94c54:	9a831023 	csel	x3, x1, x3, ne	// ne = any
   94c58:	9ac22400 	lsr	x0, x0, x2
   94c5c:	f100007f 	cmp	x3, #0x0
   94c60:	52800027 	mov	w7, #0x1                   	// #1
   94c64:	9a9f07e1 	cset	x1, ne	// ne = any
   94c68:	d2800004 	mov	x4, #0x0                   	// #0
   94c6c:	aa000021 	orr	x1, x1, x0
   94c70:	92400823 	and	x3, x1, #0x7
   94c74:	17ffff7d 	b	94a68 <__trunctfdf2+0xe8>
   94c78:	b5fffad3 	cbnz	x19, 94bd0 <__trunctfdf2+0x250>
   94c7c:	34fff067 	cbz	w7, 94a88 <__trunctfdf2+0x108>
   94c80:	aa0403e7 	mov	x7, x4
   94c84:	aa0703e4 	mov	x4, x7
   94c88:	17ffffe8 	b	94c28 <__trunctfdf2+0x2a8>
   94c8c:	d2800005 	mov	x5, #0x0                   	// #0
   94c90:	b4ffecd3 	cbz	x19, 94a28 <__trunctfdf2+0xa8>
   94c94:	f100027f 	cmp	x19, #0x0
   94c98:	5280ffc0 	mov	w0, #0x7fe                 	// #2046
   94c9c:	5280ffe1 	mov	w1, #0x7ff                 	// #2047
   94ca0:	92fc0005 	mov	x5, #0x1fffffffffffffff    	// #2305843009213693951
   94ca4:	1a811000 	csel	w0, w0, w1, ne	// ne = any
   94ca8:	9a9f10a5 	csel	x5, x5, xzr, ne	// ne = any
   94cac:	17ffff5f 	b	94a28 <__trunctfdf2+0xa8>
   94cb0:	d2800121 	mov	x1, #0x9                   	// #9
   94cb4:	b4fff0f3 	cbz	x19, 94ad0 <__trunctfdf2+0x150>
   94cb8:	d2800004 	mov	x4, #0x0                   	// #0
   94cbc:	d2800021 	mov	x1, #0x1                   	// #1
   94cc0:	aa0403e7 	mov	x7, x4
   94cc4:	17ffff83 	b	94ad0 <__trunctfdf2+0x150>
   94cc8:	d2800005 	mov	x5, #0x0                   	// #0
   94ccc:	17ffff57 	b	94a28 <__trunctfdf2+0xa8>
   94cd0:	92fc0203 	mov	x3, #0x1fefffffffffffff    	// #2301339409586323455
   94cd4:	52800200 	mov	w0, #0x10                  	// #16
   94cd8:	8a410c61 	and	x1, x3, x1, lsr #3
   94cdc:	aa02d022 	orr	x2, x1, x2, lsl #52
   94ce0:	aa13fc53 	orr	x19, x2, x19, lsl #63
   94ce4:	94000017 	bl	94d40 <__sfp_handle_exceptions>
   94ce8:	17ffff54 	b	94a38 <__trunctfdf2+0xb8>
   94cec:	d343fc21 	lsr	x1, x1, #3
   94cf0:	12002882 	and	w2, w4, #0x7ff
   94cf4:	34000167 	cbz	w7, 94d20 <__trunctfdf2+0x3a0>
   94cf8:	52800000 	mov	w0, #0x0                   	// #0
   94cfc:	365ff065 	tbz	w5, #11, 94b08 <__trunctfdf2+0x188>
   94d00:	52800100 	mov	w0, #0x8                   	// #8
   94d04:	aa02d021 	orr	x1, x1, x2, lsl #52
   94d08:	aa13fc33 	orr	x19, x1, x19, lsl #63
   94d0c:	9400000d 	bl	94d40 <__sfp_handle_exceptions>
   94d10:	17ffff4a 	b	94a38 <__trunctfdf2+0xb8>
   94d14:	12002842 	and	w2, w2, #0x7ff
   94d18:	52800300 	mov	w0, #0x18                  	// #24
   94d1c:	17fffffa 	b	94d04 <__trunctfdf2+0x384>
   94d20:	d2800013 	mov	x19, #0x0                   	// #0
   94d24:	b340cc33 	bfxil	x19, x1, #0, #52
   94d28:	b34c2853 	bfi	x19, x2, #52, #11
   94d2c:	b34100d3 	bfi	x19, x6, #63, #1
   94d30:	17ffff79 	b	94b14 <__trunctfdf2+0x194>
	...

0000000000094d40 <__sfp_handle_exceptions>:
   94d40:	36000080 	tbz	w0, #0, 94d50 <__sfp_handle_exceptions+0x10>
   94d44:	0f000401 	movi	v1.2s, #0x0
   94d48:	1e211820 	fdiv	s0, s1, s1
   94d4c:	d53b4421 	mrs	x1, fpsr
   94d50:	360800a0 	tbz	w0, #1, 94d64 <__sfp_handle_exceptions+0x24>
   94d54:	1e2e1001 	fmov	s1, #1.000000000000000000e+00
   94d58:	0f000402 	movi	v2.2s, #0x0
   94d5c:	1e221820 	fdiv	s0, s1, s2
   94d60:	d53b4421 	mrs	x1, fpsr
   94d64:	36100100 	tbz	w0, #2, 94d84 <__sfp_handle_exceptions+0x44>
   94d68:	5298b5c2 	mov	w2, #0xc5ae                	// #50606
   94d6c:	12b01001 	mov	w1, #0x7f7fffff            	// #2139095039
   94d70:	72ae93a2 	movk	w2, #0x749d, lsl #16
   94d74:	1e270021 	fmov	s1, w1
   94d78:	1e270042 	fmov	s2, w2
   94d7c:	1e222820 	fadd	s0, s1, s2
   94d80:	d53b4421 	mrs	x1, fpsr
   94d84:	36180080 	tbz	w0, #3, 94d94 <__sfp_handle_exceptions+0x54>
   94d88:	0f044401 	movi	v1.2s, #0x80, lsl #16
   94d8c:	1e210820 	fmul	s0, s1, s1
   94d90:	d53b4421 	mrs	x1, fpsr
   94d94:	362000c0 	tbz	w0, #4, 94dac <__sfp_handle_exceptions+0x6c>
   94d98:	12b01000 	mov	w0, #0x7f7fffff            	// #2139095039
   94d9c:	1e2e1002 	fmov	s2, #1.000000000000000000e+00
   94da0:	1e270001 	fmov	s1, w0
   94da4:	1e223820 	fsub	s0, s1, s2
   94da8:	d53b4420 	mrs	x0, fpsr
   94dac:	d65f03c0 	ret
