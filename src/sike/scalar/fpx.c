#include "fpx.h"


void fp2mul_mont(f2elm_t r, const f2elm_t a, const f2elm_t b)
{
  felm_t t1, t2;
  dfelm_t tt1, tt2, tt3;

  // the first two integer addition probably don't need carry propagation
  // but it needs to carefully check the limb range to avoid overflow
  mp_add(t1, a[0], a[1]);               // t1  = a0 + a1
  mp_add(t2, b[0], b[1]);               // t2  = b0 + b1
  
  mp_mul(tt1, a[0], b[0]);              // tt1 = a0 * b0
  mp_mul(tt2, a[1], b[1]);              // tt2 = a1 * b1
  mp_mul(tt3, t1, t2);                  // tt3 = (a0+a1) * (b0+b1)
  mp_dblsub(tt3, tt1, tt2);             // tt3 = (a0+a1)(b0+b1) - a0b0 - a1b1 = a0b1+a1b0
  mp_subadd(tt1, tt1, tt2);             // tt1 = a0b0 - a1b1
  rdc_mont(r[1], tt3);                  // r1  = a0b1+a1b0 mod 2p
  rdc_mont(r[0], tt1);                  // r0  = a0b0-a1b1 mod 2p
}
