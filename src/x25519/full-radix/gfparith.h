#ifndef _GFPARITH_H
#define _GFPARITH_H

#include "share.h"

void gfp_mul_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_sqr_sw(uint64_t *r, const uint64_t *a);
void gfp_mul64_sw(uint64_t *r, const uint64_t *a, const uint64_t b);
void gfp_add_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_sub_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);

#if RV64_TYPE2
void gfp_mul_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_sqr_ise(uint64_t *r, const uint64_t *a);
void gfp_mul64_ise(uint64_t *r, const uint64_t *a, const uint64_t b);
void gfp_add_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_sub_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
#endif 

#if RV64_TYPE2
#define gfp_mul         gfp_mul_ise
#define gfp_sqr(r, a)   gfp_mul_ise(r, a, a)
#define gfp_mul64       gfp_mul64_ise
#define gfp_sub         gfp_sub_ise
#define gfp_add         gfp_add_ise
// #define gfp_mul64       gfp_mul64_sw
// #define gfp_sub         gfp_sub_sw
// #define gfp_add         gfp_add_sw
#elif RV64_TYPE1
#define gfp_mul         gfp_mul_sw
#define gfp_sqr         gfp_sqr_sw
#define gfp_mul64       gfp_mul64_sw
#define gfp_sub         gfp_sub_sw
#define gfp_add         gfp_add_sw
#endif 

void gfp_inv(uint64_t *r, const uint64_t *a);

#endif 
