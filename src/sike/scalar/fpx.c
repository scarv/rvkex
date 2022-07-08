#include "fpx.h"

// v0: there are carry propagations in two integer additions. 
void fp2mul_mont_v0(f2elm_t r, const f2elm_t a, const f2elm_t b)
{
  felm_t t1, t2;
  dfelm_t tt1, tt2, tt3;

  mp_add_v0(t1, a[0], a[1]);            // t1  = a0 + a1
  mp_add_v0(t2, b[0], b[1]);            // t2  = b0 + b1
  mp_mul(tt1, a[0], b[0]);              // tt1 = a0 * b0
  mp_mul(tt2, a[1], b[1]);              // tt2 = a1 * b1
  mp_mul(tt3, t1, t2);                  // tt3 = (a0+a1) * (b0+b1)
  mp_dblsub(tt3, tt1, tt2);             // tt3 = (a0+a1)(b0+b1) - a0b0 - a1b1 = a0b1+a1b0
  mp_subadd(tt1, tt1, tt2);             // tt1 = a0b0 - a1b1
  rdc_mont(r[1], tt3);                  // r1  = a0b1+a1b0 mod 2p
  rdc_mont(r[0], tt1);                  // r0  = a0b0-a1b1 mod 2p
}

// v1: there are NOT carry propagations in two integer additions. 
void fp2mul_mont_v1(f2elm_t r, const f2elm_t a, const f2elm_t b)
{
  felm_t t1, t2;
  dfelm_t tt1, tt2, tt3;

  mp_add_v1(t1, a[0], a[1]);            // t1  = a0 + a1
  mp_add_v1(t2, b[0], b[1]);            // t2  = b0 + b1
  mp_mul(tt1, a[0], b[0]);              // tt1 = a0 * b0
  mp_mul(tt2, a[1], b[1]);              // tt2 = a1 * b1
  mp_mul(tt3, t1, t2);                  // tt3 = (a0+a1) * (b0+b1)
  mp_dblsub(tt3, tt1, tt2);             // tt3 = (a0+a1)(b0+b1) - a0b0 - a1b1 = a0b1+a1b0
  mp_subadd(tt1, tt1, tt2);             // tt1 = a0b0 - a1b1
  rdc_mont(r[1], tt3);                  // r1  = a0b1+a1b0 mod 2p
  rdc_mont(r[0], tt1);                  // r0  = a0b0-a1b1 mod 2p
}

// The Mongomery multiplication can be optimized with merging the two functions 
// into one to save some store/load instructions.
void fpmul_mont_v0(felm_t r, const felm_t a, const felm_t b)
{
  dfelm_t temp = { 0 };

  mp_mul(temp, a, b);
  rdc_mont(r, temp);
}

// v0: there are carry propagations in first three additions/subtraction.
void fp2sqr_mont_v0(f2elm_t r, const f2elm_t a)
{
  felm_t t1, t2, t3;
  
  mp_add_v0(t1, a[0], a[1]);            // t1 = a0 + a1
  mp_sub_p4_v0(t2, a[0], a[1]);         // t2 = a0 - a1
  mp_add_v0(t3, a[0], a[0]);            // t3 = 2 * a0
  fpmul_mont_v0(r[0], t1, t2);          // r0 = (a0+a1) * (a0-a1) mod 2p
  fpmul_mont_v0(r[1], t3, a[1]);        // r1 = 2a0 * a1 mod 2p
}

// v1: there are NOT carry propagations in first three additions/subtraction.
void fp2sqr_mont_v1(f2elm_t r, const f2elm_t a)
{
  felm_t t1, t2, t3;

  mp_add_v1(t1, a[0], a[1]);            // t1 = a0 + a1
  mp_sub_p4_v1(t2, a[0], a[1]);         // t2 = a0 - a1
  mp_add_v1(t3, a[0], a[0]);            // t3 = 2 * a0
  fpmul_mont_v0(r[0], t1, t2);          // r0 = (a0+a1) * (a0-a1) mod 2p
  fpmul_mont_v0(r[1], t3, a[1]);        // r1 = 2a0 * a1 mod 2p
}

void fp2add_v0(f2elm_t r, const f2elm_t a, const f2elm_t b)
{
  fpadd(r[0], a[0], b[0]);
  fpadd(r[1], a[1], b[1]);
}

void fp2sub_v0(f2elm_t r, const f2elm_t a, const f2elm_t b)
{
  fpsub(r[0], a[0], b[0]);
  fpsub(r[1], a[1], b[1]);
}