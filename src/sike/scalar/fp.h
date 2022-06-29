#ifndef _FP_H
#define _FP_H

#include "share.h"
#include "config.h"

void mp_mul_1w_v0(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_mul_1w_v1(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_mul_1w_v2(uint64_t *r, const uint64_t *a, const uint64_t *b);
void rdc_mont_1w_v0(uint64_t *r, const uint64_t *a);
void fpadd_1w_v0(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_sub_p2_1w_v0(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_sub_p4_1w_v0(uint64_t *r, const uint64_t *a, const uint64_t *b);
void fpsub_1w_v0(uint64_t *r, const uint64_t *a, const uint64_t *b);
void fpcorrection_1w_v0(uint64_t *r);
void fpneg_1w_v0(uint64_t *r);
void fpdiv2_1w_v0(uint64_t *r, const uint64_t *a);
void mp_add_1w_v0(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_dblsub_1w_v0(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_subadd_1w_v0(uint64_t *r, const uint64_t *a, const uint64_t *b);

void mp_mul_1w_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_mul_1w_v1_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void rdc_mont_1w_v0_ise(uint64_t *r, const uint64_t *a);
void fpadd_1w_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_sub_p2_1w_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_sub_p4_1w_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void fpsub_1w_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void fpcorrection_1w_v0_ise(uint64_t *r);
void fpneg_1w_v0_ise(uint64_t *r);
void fpdiv2_1w_v0_ise(uint64_t *r, const uint64_t *a);
void mp_add_1w_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_subadd_1w_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);

#if ISE
#define mp_mul     mp_mul_1w_v0_ise
#define rdc_mont   rdc_mont_1w_v0_ise
#define mp_add     mp_add_1w_v0_ise
#define mp_subadd  mp_subadd_1w_v0_ise
#else
#define mp_mul     mp_mul_1w_v2
#define rdc_mont   rdc_mont_1w_v0
#define mp_add     mp_add_1w_v0
#define mp_subadd  mp_subadd_1w_v0
#endif  
#define mp_dblsub  mp_dblsub_1w_v0

#endif
