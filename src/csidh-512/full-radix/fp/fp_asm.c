#include <stddef.h>
#include <string.h>
#include <assert.h>

#include "../params.h"
#include "../fp.h"


void fp_mul3_asm(fp *r, const fp *a, const fp *b)
{
  uint64_t t[LIMBS*2];

  uint_mul3_ps_sw(t, a, b);
  fp_rdc_mont_sw(r, t);
  reduce_once(r);
}