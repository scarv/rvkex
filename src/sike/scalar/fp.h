#ifndef _FP_H
#define _FP_H

#include "share.h"
#include "config.h"

void mp_mul_1w_v0(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_mul_1w_v1(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_mul_1w_v2(uint64_t *r, const uint64_t *a, const uint64_t *b);

void mp_mul_1w_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void mp_mul_1w_v1_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);

#endif
