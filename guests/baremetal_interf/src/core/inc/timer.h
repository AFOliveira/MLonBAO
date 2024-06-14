#ifndef TIMER_H_
#define TIMER_H_

#include <arch/timer.h>

static inline void timer_wait(uint64_t n) {
    uint64_t start = timer_get();
    while(timer_get() < (start+n));
}

#define TIME_US(us) ((TIMER_FREQ)*(us)/(1000000ull))
#define TIME_MS(ms) (TIME_US((ms)*1000))
#define TIME_S(s)   (TIME_MS((s)*1000))

#endif
