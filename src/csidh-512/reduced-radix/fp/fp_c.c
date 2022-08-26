
#include <stddef.h>
#include <string.h>
#include <assert.h>

#include "../params.h"
#include "../fp.h"
#include "../rng.h"

bool fp_eq(fp const *x, fp const *y)
{
  return uint_eq(x, y);
}

void fp_set(fp *x, uint64_t y)
{
  uint_set((fp *) x, y);
  fp_enc(x, (fp *) x);
}

void reduce_once_c(fp *x)
{
  fp t;
  if (!uint_sub3(&t, x, &p))
      *x = t;
}

void fp_add3_c(fp *x, fp const *y, fp const *z)
{
  bool c = uint_add3((fp *) x, (fp *) y, (fp *) z);
  (void) c; assert(!c);
  reduce_once((fp *) x);
}

void fp_add2(fp *x, fp const *y)
{
  fp_add3(x, x, y);
}

void fp_sub3_c(fp *x, fp const *y, fp const *z)
{
  if (uint_sub3((fp *) x, (fp *) y, (fp *) z))
    uint_add3((fp *) x, (fp *) x, &p);
}

void fp_sub2(fp *x, fp const *y)
{
  fp_sub3(x, x, y);
}


/* Montgomery arithmetic */

void fp_enc(fp *x, fp const *y)
{
  fp_mul3(x, (fp *) y, &r_squared_mod_p);
}

void fp_dec(fp *x, fp const *y)
{
  fp_mul3((fp *) x, y, (fp *) &uint_1);
}

// void fp_mul3_c(fp *r, const fp *a, const fp *b)
// {
//   __uint128_t z[2*LIMBS] = { 0 }, accl = 0, acch = 0;
//   int i, j, k;

//   for (i = 0; i <= LIMBS-1; i++) {
//     for (j = 0, k = i; k >= 0; j++, k--) 
//       z[i] = z[i] + (__uint128_t) a->c[j]*b->c[k];
//   }

//   for (i = LIMBS; i <= 2*(LIMBS-1); i++) {
//     for (j = i-(LIMBS-1), k = LIMBS-1; j <= LIMBS-1; j++, k--)
//       z[i] = z[i] + (__uint128_t) a->c[j]*b->c[k];
//   }

//   for (i = 0; i < LIMBS; i++) {
//     acch = 0;
//     for (j = 0; j < i; j++) {
//       accl = accl + ((__uint128_t)r->c[j] * p.c[i-j] & BMASK);
//       acch = acch + ((__uint128_t)r->c[j] * p.c[i-j] >> RADIX);
//     }
//     accl = accl + (z[i] & BMASK);
//     acch = acch + (z[i] >> RADIX);
//     r->c[i] = accl & BMASK;
//     r->c[i] = ((__uint128_t)r->c[i]*inv_min_p_mod_r) & BMASK;
//     accl = accl + ((__uint128_t)r->c[i]*p.c[0]  & BMASK);
//     acch = acch + ((__uint128_t)r->c[i]*p.c[0] >> RADIX);
//     accl = accl>>RADIX;
//     accl = accl + acch;
//   }

//   for (i = LIMBS; i < 2*LIMBS-1; i++) {
//     acch = 0;
//     for (j = i-LIMBS+1; j < LIMBS; j++) {
//       accl = accl + ((__uint128_t)r->c[j]*p.c[i-j]  & BMASK);
//       acch = acch + ((__uint128_t)r->c[j]*p.c[i-j] >> RADIX);
//     }
//     accl = accl + (z[i]&BMASK);
//     acch = acch + (z[i] >> RADIX);
//     r->c[i-LIMBS] = accl & BMASK;
//     accl >>= RADIX;
//     accl += acch;
//   }
//   accl += z[2*LIMBS-1];
//   r->c[LIMBS-1] = accl;

//   reduce_once(r);
// }

void fp_mul3_c(fp *r, const fp *a, const fp *b)
{
  __uint128_t t = 0, acc = 0;
  uint64_t z[2*LIMBS] = { 0 }, mask = 0xFFFFFFFFFFFFFFFFULL;
  int i, j, k;

  for (i = 0; i <= LIMBS-1; i++) {
    for (j = 0, k = i; k >= 0; j++, k--) 
      t += (__uint128_t) a->c[j]*b->c[k];
    z[i] = t & mask;
    t >>= 64;
    t <<=  7;
  }

  for (i = LIMBS; i <= 2*(LIMBS-1); i++) {
    for (j = i-(LIMBS-1), k = LIMBS-1; j <= LIMBS-1; j++, k--)
      t += (__uint128_t) a->c[j]*b->c[k];
    z[i] = t & mask;
    t >>= 64;
    t <<=  7;
  }

  z[2*LIMBS-1] = t & mask;

  for (i = 0; i < LIMBS; i++) {
    for (j = 0; j < i; j++) {
      acc = acc + ((__uint128_t)r->c[j] * p.c[i-j]);
    }
    acc += z[i];
    r->c[i] = (uint64_t) acc;
    r->c[i] = ((__uint128_t)r->c[i]*inv_min_p_mod_r) & BMASK;
    acc = acc + ((__uint128_t)r->c[i]*p.c[0]);
    acc = acc >> RADIX;
  }

  for (i = LIMBS; i < 2*LIMBS-1; i++) {
    for (j = i-LIMBS+1; j < LIMBS; j++) {
      acc = acc + ((__uint128_t)r->c[j] * p.c[i-j]);
    }
    acc += z[i];
    r->c[i-LIMBS] = acc & BMASK;
    acc = acc >> RADIX;
  }
  acc += z[2*LIMBS-1];
  r->c[LIMBS-1] = acc;

  reduce_once(r);
}


void fp_mul2(fp *x, fp const *y)
{
  fp_mul3(x, x, y);
}

void fp_sq2_c(fp *x, fp const *y)
{
  fp_mul3(x, y, y);
}

void fp_sq1(fp *x)
{
  fp_sq2(x, x);
}

/* (obviously) not constant time in the exponent */
static void fp_pow(fp *x, u64 const *e)
{
    fp y = *x;
    *x = fp_1;
    for (size_t k = 0; k < 8; ++k) {
        uint64_t t = e->c[k];
        for (size_t i = 0; i < 64; ++i, t >>= 1) {
            if (t & 1)
                fp_mul2(x, &y);
            fp_sq1(&y);
        }
    }
}

void fp_inv(fp *x)
{
  fp_pow(x, &p_minus_2);
}

bool fp_issquare(fp *x)
{
  fp_pow(x, &p_minus_1_halves);
  return !memcmp(x, &fp_1, sizeof(fp));
}

void fp_random(fp *x)
{
  int i;

  for (i = 0; i < LIMBS; i++) x->c[i] = 0;

  while (true) {
    randombytes(x->c, sizeof(fp));
    for (i = 0; i < LIMBS-1; i++) x->c[i] = x->c[i] & BMASK;
    x->c[LIMBS-1] = x->c[LIMBS-1] & (BMASK>>2);

    for (i = LIMBS-1; i >= 0; i--) {
      if (x->c[i] < p.c[i]) {
        return;
      }
      else if (x->c[i] > p.c[i])
        break;
    }
  }
}
