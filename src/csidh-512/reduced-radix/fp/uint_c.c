
#include <string.h>
#include <stddef.h>
#include <assert.h>

#include "../params.h"
#include "../fp.h"
#include "../rng.h"

/* assumes little-endian throughout. */

fp const uint_0 = {{0}};
fp const uint_1 = {{1}};

bool uint_eq(fp const *x, fp const *y)
{
  uint64_t r = 0;
  for (size_t k = 0; k < LIMBS; ++k)
    r |= x->c[k] ^ y->c[k];
  return !r;
}

void uint_set(fp *x, uint64_t y)
{
  x->c[0] = y;
  for (size_t i = 1; i < LIMBS; ++i)
    x->c[i] = 0;
}

size_t uint_len(fp const *x)
{
  for (size_t i = LIMBS - 1, j; i < LIMBS; --i) {
    uint64_t v = x->c[i];
    if (!v) continue;
    for (j = 0; v; ++j, v >>= 1);
    return RADIX*i+j;
  }
  return 0;
}

bool uint_bit(fp const *x,  uint64_t k)
{
  return 1 & (x->c[k / RADIX] >> k % RADIX);
}

bool uint_add3(fp *r, const fp *a, const fp *b)
{
  bool c = 0;
  int i;

  for (i = 0; i < LIMBS; i++) {
    r->c[i] = a->c[i] + b->c[i];
  }
  
  for (i = 0; i < LIMBS-1; i++) {
    r->c[i+1] = r->c[i+1] + (r->c[i] >> RADIX);
    r->c[i]   = r->c[i] & BMASK;
  }
  c = r->c[LIMBS-1] >> (RADIX-1);
  r->c[LIMBS-1] = r->c[LIMBS-1] & (BMASK>>1);

  return c;
}

bool uint_sub3(fp *r, const fp *a, const fp *b)
{
  bool c = 0;
  int i;

  for (i = 0; i < LIMBS; i++) {
    r->c[i] = a->c[i] - b->c[i];
  } 

  for (i = 0; i < LIMBS-1; i++) {
    r->c[i+1] = r->c[i+1] + ((int64_t) r->c[i] >> RADIX);
    r->c[i]   = r->c[i] & BMASK;
  }
  c = ((int64_t) r->c[LIMBS-1] >> (RADIX-1)) & 1;
  r->c[LIMBS-1] = r->c[LIMBS-1] & (BMASK>>1);

  return c;
}

void uint_mul3_64(fp *r, const fp *a, uint64_t b)
{
  uint64_t c = 0;
  int i = 0; 
  __uint128_t t;

  for (i = 0; i < LIMBS; i++) {
    t = a->c[i] * (__uint128_t) b + c;
    c = t >> RADIX;
    r->c[i] = t & BMASK;
  }
}
