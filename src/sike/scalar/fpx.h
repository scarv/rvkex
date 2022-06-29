#ifndef _FPX_H
#define _FPX_H

#include "fp.h"

typedef uint64_t felm_t[NLMB56];
typedef uint64_t dfelm_t[NLMB56*2];
typedef felm_t   f2elm_t[2];

void fp2mul_mont_v0(f2elm_t r, const f2elm_t a, const f2elm_t b);
void fp2sqr_mont_v0(f2elm_t r, const f2elm_t a);

#endif
