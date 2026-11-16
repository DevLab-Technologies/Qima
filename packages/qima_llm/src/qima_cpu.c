// Whether this CPU runs the instructions qima_llm is built with (AVX2, FMA,
// F16C, BMI2 on x86-64). Its own library, built without them, so asking
// can never itself fault on an older CPU.
#include "qima_llm.h"

#if defined(__x86_64__) || defined(_M_X64)

#if defined(_MSC_VER)
#include <immintrin.h>
#include <intrin.h>

static void cpuid(int leaf, int sub, int out[4]) { __cpuidex(out, leaf, sub); }
static unsigned long long xcr0(void) { return _xgetbv(0); }
#else
#include <cpuid.h>

static void cpuid(int leaf, int sub, int out[4]) {
    unsigned int a, b, c, d;
    __cpuid_count(leaf, sub, a, b, c, d);
    out[0] = (int)a;
    out[1] = (int)b;
    out[2] = (int)c;
    out[3] = (int)d;
}
static unsigned long long xcr0(void) {
    unsigned int lo, hi;
    __asm__ volatile("xgetbv" : "=a"(lo), "=d"(hi) : "c"(0));
    return ((unsigned long long)hi << 32) | lo;
}
#endif

QIMA_LLM_API int qima_cpu_ok(void) {
    int r[4];
    cpuid(0, 0, r);
    if (r[0] < 7) return 0;

    cpuid(1, 0, r);
    const unsigned ecx = (unsigned)r[2];
    const int fma = (ecx >> 12) & 1, osxsave = (ecx >> 27) & 1, avx = (ecx >> 28) & 1, f16c = (ecx >> 29) & 1;
    if (!fma || !osxsave || !avx || !f16c) return 0;
    // The OS saves the YMM registers.
    if ((xcr0() & 6) != 6) return 0;

    cpuid(7, 0, r);
    const unsigned ebx = (unsigned)r[1];
    const int avx2 = (ebx >> 5) & 1, bmi2 = (ebx >> 8) & 1;
    return avx2 && bmi2;
}

#else

// Arm64 builds target the baseline the toolchain sets.
QIMA_LLM_API int qima_cpu_ok(void) { return 1; }

#endif
