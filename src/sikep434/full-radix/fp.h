#ifndef _FP_H
#define _FP_H

#include "share.h"

void mp_mul_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_mul_v1_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
void rdc_mont_v0_sw(uint64_t *r, const uint64_t *a);
void mp_add_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_sub_p2_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_sub_p4_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_dblsub_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_subadd_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
void fpadd_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
void fpsub_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
void fpneg_v0_sw(uint64_t *r);
void fpdiv2_v0_sw(uint64_t *r, const uint64_t *a);
void fpcorrection_v0_sw(uint64_t *r);

#define mp_mul        mp_mul_v0_sw
#define rdc_mont      rdc_mont_v0_sw
#define mp_subadd     mp_subadd_v0_sw
#define mp_add        mp_add_v0_sw
#define mp_dblsub     mp_dblsub_v0_sw
#define mp_sub_p2     mp_sub_p2_v0_sw
#define mp_sub_p4     mp_sub_p4_v0_sw
#define fpadd         fpadd_v0_sw
#define fpsub         fpsub_v0_sw
#define fpneg         fpneg_v0_sw
#define fpdiv2        fpdiv2_v0_sw
#define fpcorrection  fpcorrection_v0_sw

#endif
