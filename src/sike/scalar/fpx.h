#ifndef _FPX_H
#define _FPX_H

#include "fp.h"
#include "share.h"

typedef uint64_t felm_t[NLMB56];
typedef uint64_t dfelm_t[NLMB56*2];
typedef felm_t   f2elm_t[2];

void fp2mul_mont_v0(f2elm_t r, const f2elm_t a, const f2elm_t b);
void fp2mul_mont_v1(f2elm_t r, const f2elm_t a, const f2elm_t b);
void fp2sqr_mont_v0(f2elm_t r, const f2elm_t a);
void fp2sqr_mont_v1(f2elm_t r, const f2elm_t a);
void fp2add_v0(f2elm_t r, const f2elm_t a, const f2elm_t b);
void fp2sub_v0(f2elm_t r, const f2elm_t a, const f2elm_t b);
void fp2neg_v0(f2elm_t r);
void fp2div2_v0(f2elm_t r, const f2elm_t a);
void fp2correction_v0(f2elm_t r);
void fp2copy(f2elm_t r, const f2elm_t a);
void fp2zero(f2elm_t r);
void mp2_add_v0(f2elm_t r, const f2elm_t a, const f2elm_t b);
void mp2_add_v1(f2elm_t r, const f2elm_t a, const f2elm_t b);
void fp2inv_mont(f2elm_t r);
void to_fp2mont(f2elm_t r, const f2elm_t a);
void from_fp2mont(f2elm_t r, const f2elm_t a);

void fpmul_mont_v0(felm_t r, const felm_t a, const felm_t b);
void fpsqr_mont_v0(felm_t r, const felm_t a);
void fpcopy(felm_t r, const felm_t a);
void to_mont(felm_t r, const felm_t a);
void from_mont(felm_t r, const felm_t a);

#define fpmul_mont fpmul_mont_v0
#define fpsqr_mont fpsqr_mont_v0

#endif
