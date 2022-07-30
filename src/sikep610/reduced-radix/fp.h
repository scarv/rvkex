#ifndef _FP_H
#define _FP_H

#include "share.h"

void mp_add_v1_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_dblsub_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);

void mp_mul_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void rdc_mont_v0_ise(uint64_t *r, const uint64_t *a);
void fpadd_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_sub_p2_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_sub_p4_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void fpsub_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void fpcorrection_v0_ise(uint64_t *r);
void fpneg_v0_ise(uint64_t *r);
void fpdiv2_v0_ise(uint64_t *r, const uint64_t *a);
void mp_add_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_subadd_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);


// single-version operations
#define fpadd         fpadd_v0_ise
#define mp_sub_p2     mp_sub_p2_v0_ise
#define mp_sub_p4     mp_sub_p4_v0_ise
#define fpneg         fpneg_v0_ise
#define fpsub         fpsub_v0_ise
#define mp_subadd     mp_subadd_v0_ise
#define mp_mul        mp_mul_v0_ise
#define rdc_mont      rdc_mont_v0_ise
#define fpdiv2        fpdiv2_v0_ise
#define fpcorrection  fpcorrection_v0_ise
#define mp_dblsub     mp_dblsub_v0_sw
// multi-version operations
#define mp_add_v0     mp_add_v0_ise
#define mp_add_v1     mp_add_v1_sw


#endif
