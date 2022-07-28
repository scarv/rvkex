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
void fp2add(f2elm_t r, const f2elm_t a, const f2elm_t b);
void fp2sub(f2elm_t r, const f2elm_t a, const f2elm_t b);
void fp2neg(f2elm_t r);
void fp2div2(f2elm_t r, const f2elm_t a);
void fp2correction(f2elm_t r);
void fp2copy(f2elm_t r, const f2elm_t a);
void fp2zero(f2elm_t r);
void mp2_add_v0(f2elm_t r, const f2elm_t a, const f2elm_t b);
void mp2_add_v1(f2elm_t r, const f2elm_t a, const f2elm_t b);
void mp2_sub_p2(f2elm_t r, const f2elm_t a, const f2elm_t b);
void fp2inv_mont(f2elm_t r);
void to_fp2mont(f2elm_t r, const f2elm_t a);
void from_fp2mont(f2elm_t r, const f2elm_t a);

void fpmul_mont_v0(felm_t r, const felm_t a, const felm_t b);
void fpsqr_mont_v0(felm_t r, const felm_t a);
void fpcopy(felm_t r, const felm_t a);
void fpzero(felm_t r);
void to_mont(felm_t r, const felm_t a);
void from_mont(felm_t r, const felm_t a);

#define fpmul_mont fpmul_mont_v0
#define fpsqr_mont fpsqr_mont_v0

void decode_to_digits(const unsigned char* x, uint64_t* dec, int nbytes, int ndigits);
void fp2_encode(const f2elm_t x, unsigned char *enc);
void fp2_decode(const unsigned char *x, f2elm_t dec);
int8_t ct_compare(const uint8_t *a, const uint8_t *b, unsigned int len);
void ct_cmov(uint8_t *r, const uint8_t *a, unsigned int len, int8_t selector);

#endif
