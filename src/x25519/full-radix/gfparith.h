#ifndef _GFPARITH_H
#define _GFPARITH_H

#include "share.h"
#include "config.h"

void gfp_mul_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_sqr_sw(uint64_t *r, const uint64_t *a);
void gfp_mul64_sw(uint64_t *r, const uint64_t *a, const uint64_t b);
void gfp_add_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_sub_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);

#define gfp_mul   gfp_mul_sw
#define gfp_sqr   gfp_sqr_sw
#define gfp_mul64 gfp_mul64_sw
#define gfp_add   gfp_add_sw
#define gfp_sub   gfp_sub_sw

void gfp_inv(uint64_t *r, const uint64_t *a);

#endif 
