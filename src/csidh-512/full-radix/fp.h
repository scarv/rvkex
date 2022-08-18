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

void fp_add3_c(fp *x, fp const *y, fp const *z);
void fp_sub3_c(fp *x, fp const *y, fp const *z);
void fp_mul3_c(fp *x, fp const *y, fp const *z);

void fp_sq1(fp *x);
void fp_sq2(fp *x, fp const *y);
void fp_inv(fp *x);
bool fp_issquare(fp *x); /* destroys input! */

void fp_random(fp *x);

void reduce_once(fp *x);


// assembly prototypes 
extern void uint_mul3_ps_sw(uint64_t *r, const fp *a, const fp *b);
extern void fp_rdc_mont_sw(fp *r, const uint64_t *a);
extern void fp_add3_sw(fp *r, const fp *a, const fp *b);
extern void fp_sub3_sw(fp *r, const fp *a, const fp *b);

void fp_mul3_asm(fp *r, const fp *a, const fp *b);
void fp_add3_asm(fp *r, const fp *a, const fp *b);
void fp_sub3_asm(fp *r, const fp *a, const fp *b);

#define fp_mul3 fp_mul3_asm
#define fp_add3 fp_add3_asm
#define fp_sub3 fp_sub3_asm

#endif
