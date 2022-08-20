#ifndef FP_H
#define FP_H

#include <stdbool.h>
#include <stdint.h>

#include "params.h"

extern const fp uint_0;
extern const fp uint_1;

bool uint_eq(fp const *x, fp const *y);

void uint_set(fp *x, uint64_t y);

size_t uint_len(fp const *x);
bool uint_bit(fp const *x, uint64_t k);

bool uint_add3(fp *x, fp const *y, fp const *z); /* returns carry */
bool uint_sub3(fp *x, fp const *y, fp const *z); /* returns borrow */

void uint_mul3_64(fp *x, fp const *y, uint64_t z);

bool uint_eq(fp const *x, fp const *y);

void uint_random(fp *x, fp const *m);   /* uniform in the interval [0;m) */

extern const fp fp_0;
extern const fp fp_1;

bool fp_eq(fp const *x, fp const *y);

void fp_set(fp *x, uint64_t y);

void fp_enc(fp *x, fp const *y); /* encode to Montgomery representation */
void fp_dec(fp *x, fp const *y); /* decode from Montgomery representation */

void fp_add2(fp *x, fp const *y);
void fp_sub2(fp *x, fp const *y);
void fp_mul2(fp *x, fp const *y);
void fp_sq1(fp *x);

void fp_inv(fp *x);
bool fp_issquare(fp *x); /* destroys input! */

void fp_random(fp *x);

void fp_add3_c(fp *x, fp const *y, fp const *z);
void fp_sub3_c(fp *x, fp const *y, fp const *z);
void fp_mul3_c(fp *x, fp const *y, fp const *z);
void fp_sq2_c(fp *x, fp const *y);
void reduce_once_c(fp *x);

// -----------------------------------------------------------------------------

#if (RV64_TYPE1) | (RV64_TYPE2) | (RV64_TYPE3)
void fp_mul3_asm(fp *r, const fp *a, const fp *b);
void fp_sqr2_asm(fp *r, const fp *a);
#endif 

#if   (RV64_TYPE1) 
extern void uint_mul3_ps_sw(uint64_t *r, const fp *a, const fp *b);
extern void uint_sqr2_ps_sw(uint64_t *r, const fp *a);
extern void fp_rdc_mont_sw(fp *r, const uint64_t *a);
extern void reduce_once_cs_sw(fp *a);
extern void fp_add3_sw(fp *r, const fp *a, const fp *b);
extern void fp_sub3_sw(fp *r, const fp *a, const fp *b); 
#elif (RV64_TYPE2)
extern void uint_mul3_ps_ise(uint64_t *r, const fp *a, const fp *b);
extern void uint_sqr2_ps_ise(uint64_t *r, const fp *a);
extern void fp_rdc_mont_ise(fp *r, const uint64_t *a);
extern void reduce_once_cs_sw(fp *a);
extern void fp_add3_sw(fp *r, const fp *a, const fp *b);
extern void fp_sub3_sw(fp *r, const fp *a, const fp *b); 
#elif (RV64_TYPE3)
extern void uint_mul3_ps_ise(uint64_t *r, const fp *a, const fp *b);
extern void uint_sqr2_ps_ise(uint64_t *r, const fp *a);
extern void fp_rdc_mont_ise(fp *r, const uint64_t *a);
extern void reduce_once_ad_ise(fp *a);
extern void fp_add3_ise(fp *r, const fp *a, const fp *b);
extern void fp_sub3_ise(fp *r, const fp *a, const fp *b); 
#endif 

// -----------------------------------------------------------------------------

#if   (RV64_TYPE0)
#define fp_add3           fp_add3_c
#define fp_sub3           fp_sub3_c
#define fp_mul3           fp_mul3_c
#define fp_sq2            fp_sq2_c
#define reduce_once       reduce_once_c
#else 
#define fp_add3           fp_add3_asm
#define fp_sub3           fp_sub3_asm
#define fp_mul3           fp_mul3_asm
#define fp_sq2            fp_sqr2_asm
#define reduce_once       reduce_once_asm
#endif

#if   (RV64_TYPE1)
#define fp_add3_asm       fp_add3_sw
#define fp_sub3_asm       fp_sub3_sw
#define fp_rdc_mont_asm   fp_rdc_mont_sw
// mul and sqr are `product-scanning`
#define uint_mul3_asm     uint_mul3_ps_sw
#define uint_sqr2_asm     uint_sqr2_ps_sw
// reduce_once is `addition-based`
#define reduce_once_asm   reduce_once_cs_sw
#elif (RV64_TYPE2)
#define fp_add3_asm       fp_add3_sw
#define fp_sub3_asm       fp_sub3_sw
#define fp_rdc_mont_asm   fp_rdc_mont_ise
// mul and sqr are `product-scanning`
#define uint_mul3_asm     uint_mul3_ps_ise
#define uint_sqr2_asm     uint_sqr2_ps_ise
// reduce_once is `addition-based`
#define reduce_once_asm   reduce_once_cs_sw
#elif (RV64_TYPE3)
#define fp_add3_asm       fp_add3_ise
#define fp_sub3_asm       fp_sub3_ise
#define fp_rdc_mont_asm   fp_rdc_mont_ise
// mul and sqr are `product-scanning`
#define uint_mul3_asm     uint_mul3_ps_ise
#define uint_sqr2_asm     uint_sqr2_ps_ise
// reduce_once is `addition-based`
#define reduce_once_asm   reduce_once_ad_ise
#endif

// -----------------------------------------------------------------------------

#endif
