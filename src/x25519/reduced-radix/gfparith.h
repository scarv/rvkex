#ifndef _GFPARITH_H
#define _GFPARITH_H

#include "share.h"

void gfp_mul_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_sqr_sw(uint64_t *r, const uint64_t *a);
void gfp_add_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_sub_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_mul51_sw(uint64_t *r, const uint64_t *a, const uint64_t b);

#if RV64_TYPE2
void gfp_mul_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_sqr_ise(uint64_t *r, const uint64_t *a);
void gfp_mul51_ise(uint64_t *r, const uint64_t *a, const uint64_t b);
#endif

#if RV64_TYPE2
#define gfp_mul   gfp_mul_ise
#define gfp_sqr   gfp_sqr_ise
#define gfp_mul51 gfp_mul51_ise
#elif RV64_TYPE1
#define gfp_mul   gfp_mul_sw
#define gfp_sqr   gfp_sqr_sw
#define gfp_mul51 gfp_mul51_sw
#endif 

#define gfp_add   gfp_add_sw
#define gfp_sub   gfp_sub_sw

void gfp_inv(uint64_t *r, const uint64_t *a);

#endif 
