#include "gfparith.h"

// (1x4)-way field multiplicative inversion 

void gfp_inv_1x4w(vec4 *r, vec4 *a)
{
  vec4 t0[3], t1[3], t2[3], t3[3];
  int i;

  gfp_sqr_1x4w(t0, a);
  gfp_sqr_1x4w(t1, t0);
  gfp_sqr_1x4w(t1, t1);
  gfp_mul_1x4w(t1, a, t1);
  gfp_mul_1x4w(t0, t0, t1);
  gfp_sqr_1x4w(t2, t0);
  gfp_mul_1x4w(t1, t1, t2);
  gfp_sqr_1x4w(t2, t1);
  for (i = 0; i < 4; i++) gfp_sqr_1x4w(t2, t2);
  gfp_mul_1x4w(t1, t2, t1);
  gfp_sqr_1x4w(t2, t1);
  for (i = 0; i < 9; i++) gfp_sqr_1x4w(t2, t2);
  gfp_mul_1x4w(t2, t2, t1);
  gfp_sqr_1x4w(t3, t2);
  for (i = 0; i < 19; i++) gfp_sqr_1x4w(t3, t3);   
  gfp_mul_1x4w(t2, t3, t2);
  gfp_sqr_1x4w(t2, t2);
  for (i = 0; i < 9; i++) gfp_sqr_1x4w(t2, t2);
  gfp_mul_1x4w(t1, t2, t1);
  gfp_sqr_1x4w(t2, t1);
  for (i = 0; i < 49; i++) gfp_sqr_1x4w(t2, t2);
  gfp_mul_1x4w(t2, t2, t1);
  gfp_sqr_1x4w(t3, t2);
  for (i = 0; i < 99; i++) gfp_sqr_1x4w(t3, t3);
  gfp_mul_1x4w(t2, t3, t2);
  gfp_sqr_1x4w(t2, t2);
  for (i = 0; i < 49; i++) gfp_sqr_1x4w(t2, t2);
  gfp_mul_1x4w(t1, t2, t1);
  gfp_sqr_1x4w(t1, t1);
  for (i = 0; i < 4; i++) gfp_sqr_1x4w(t1, t1);
  gfp_mul_1x4w(r, t1, t0);
}

// -----------------------------------------------------------------------------

// (1x2)-way field multiplicative inversion 

void gfp_inv_1x2w(vec2 *r, vec2 *a)
{
  vec2 t0[3], t1[3], t2[3], t3[3];
  int i;

  gfp_sqr_1x2w(t0, a);
  gfp_sqr_1x2w(t1, t0);
  gfp_sqr_1x2w(t1, t1);
  gfp_mul_1x2w(t1, a, t1);
  gfp_mul_1x2w(t0, t0, t1);
  gfp_sqr_1x2w(t2, t0);
  gfp_mul_1x2w(t1, t1, t2);
  gfp_sqr_1x2w(t2, t1);
  for (i = 0; i < 4; i++) gfp_sqr_1x2w(t2, t2);
  gfp_mul_1x2w(t1, t2, t1);
  gfp_sqr_1x2w(t2, t1);
  for (i = 0; i < 9; i++) gfp_sqr_1x2w(t2, t2);
  gfp_mul_1x2w(t2, t2, t1);
  gfp_sqr_1x2w(t3, t2);
  for (i = 0; i < 19; i++) gfp_sqr_1x2w(t3, t3);   
  gfp_mul_1x2w(t2, t3, t2);
  gfp_sqr_1x2w(t2, t2);
  for (i = 0; i < 9; i++) gfp_sqr_1x2w(t2, t2);
  gfp_mul_1x2w(t1, t2, t1);
  gfp_sqr_1x2w(t2, t1);
  for (i = 0; i < 49; i++) gfp_sqr_1x2w(t2, t2);
  gfp_mul_1x2w(t2, t2, t1);
  gfp_sqr_1x2w(t3, t2);
  for (i = 0; i < 99; i++) gfp_sqr_1x2w(t3, t3);
  gfp_mul_1x2w(t2, t3, t2);
  gfp_sqr_1x2w(t2, t2);
  for (i = 0; i < 49; i++) gfp_sqr_1x2w(t2, t2);
  gfp_mul_1x2w(t1, t2, t1);
  gfp_sqr_1x2w(t1, t1);
  for (i = 0; i < 4; i++) gfp_sqr_1x2w(t1, t1);
  gfp_mul_1x2w(r, t1, t0);
}
