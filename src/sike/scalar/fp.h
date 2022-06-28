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

#endif
