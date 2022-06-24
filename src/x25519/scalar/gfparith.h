#ifndef _GFPARITH_H
#define _GFPARITH_H

#include "share.h"
#include "config.h"

void gfp_mul_1w_v0(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_sqr_1w_v0(uint64_t *r, const uint64_t *a);
void gfp_add_1w_v0(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_sub_1w_v0(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_mul51_1w_v0(uint64_t *r, const uint64_t *a, const uint64_t b);

void gfp_mul_1w_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_sqr_1w_v0_ise(uint64_t *r, const uint64_t *a);
void gfp_mul51_1w_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t b);

#if ISE
#define gfp_mul_1w   gfp_mul_1w_v0_ise
#define gfp_sqr_1w   gfp_sqr_1w_v0_ise
#define gfp_mul51_1w gfp_mul51_1w_v0_ise
#else
#define gfp_mul_1w   gfp_mul_1w_v0
#define gfp_sqr_1w   gfp_sqr_1w_v0
#define gfp_mul51_1w gfp_mul51_1w_v0
#endif 
#define gfp_add_1w   gfp_add_1w_v0
#define gfp_sub_1w   gfp_sub_1w_v0

void gfp_inv_1w(uint64_t *r, const uint64_t *a);

#endif 
