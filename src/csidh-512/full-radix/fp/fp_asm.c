#include <stddef.h>
#include <string.h>
#include <assert.h>

#include "../params.h"
#include "../fp.h"

void fp_mul3_asm(fp *r, const fp *a, const fp *b)
{
  uint64_t t[LIMBS*2];

  uint_mul3_asm(t, a, b);
  fp_rdc_mont_asm(r, t);
  reduce_once_asm(r);
}

void fp_sqr2_asm(fp *r, const fp *a)
{
  uint64_t t[LIMBS*2];

  uint_sqr2_asm(t, a);
  fp_rdc_mont_asm(r, t);
  reduce_once_asm(r);
}
