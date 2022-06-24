#include "moncurve.h"


void mon_ladder_step_1x4x1w(vec4 *x3z3x2z2, vec4 *z1x1_A)
{
  vec4 x5z5x4z4[NLMB25], z2x2x2z2[NLMB25], z1x1x2A[NLMB25];
  vec4 x5z5z2z4[NLMB25], x7z7x6z6[NLMB25];

  // x3z3x2z2 =            x3+z3 ||            x3-z3 ||            x2+z2 ||                  x2-z2
  gfp_hadamard_4x1w(x3z3x2z2, x3z3x2z2);  
  // z2x2x2z2 =            x2-z2 ||            x2+z2 ||            x2+z2 ||                  x2-z2                   
  gfp_align_4x1w(z2x2x2z2, x3z3x2z2);
  // x3z3x2z2 =   (x3+z3)(x2-z2) ||   (x3-z3)(x2+z2) ||        (x2+z2)^2 ||              (x2-z2)^2                  
  gfp_mul_4x1w(x3z3x2z2, x3z3x2z2, z2x2x2z2);
  // x3z3x2z2 =     2(x2x3-z2z3) ||     2(x2z3-x3z2) ||     2(x2^2+z2^2) ||                  4x2z2                  
  gfp_hadamard_4x1w(x3z3x2z2, x3z3x2z2);
  // x5z5x4z4 =   4(x2x3-z2z3)^2 ||   4(x2z3-x3z2)^2 ||   4(x2^2+z2^2)^2 ||           16 x2^2 z2^2
  gfp_sqr_4x1w(x5z5x4z4, x3z3x2z2);
  // z1x1x2A  =               z1 ||               x1 ||     2(x2^2+z2^2) ||                      A
  // x5z5z2z4 =   4(x2x3-z2z3)^2 ||   4(x2z3-x3z2)^2 ||            4x2z2 ||           16 x2^2 z2^2
  gfp_premix_4x1w(z1x1x2A, x5z5z2z4, z1x1_A, x3z3x2z2, x5z5x4z4);
  // x7z7x6z6 = 4z1(x2x3-z2z3)^2 || 4x1(x2z3-x3z2)^2 || 8x2z2(x2^2+z2^2) ||          16A x2^2 z2^2 
  gfp_mul_4x1w(x7z7x6z6, z1x1x2A, x5z5z2z4);
  // x3z3x2z2 = 4z1(x2x3-z2z3)^2 || 4x1(x2z3-x3z2)^2 ||   4(x2^2-z2^2)^2 || 16x2z2(x2^2+z2^2+Ax2z2)
  gfp_postmix_4x1w(x3z3x2z2, x7z7x6z6, x5z5x4z4);
}

void mon_mul_varbase_1x4x1w(uint32_t *r, const uint32_t *k, const uint32_t *x)
{
  vec4 x3z3x2z2[NLMB25], z1x1_A[NLMB25];
  uint32_t kp[8], x25[NLMB25], z25[NLMB25], r25[NLMB25];
  vec4 x_1x4w[3], z_1x4w[3], r_1x4w[3];
  int i, b, s = 0;

  // prune scalar k
  for (i = 0; i < 8; i++) kp[i] = k[i];
  kp[0] &= 0xFFFFFFF8UL; 
  kp[7] &= 0x7FFFFFFFUL; 
  kp[7] |= 0x40000000UL;

  // convert x-coordinate to radix-2^25.5
  mpi_conv_32to25(x25, x);

  // initialize ladder
  for (i = 0; i < NLMB25; i++) {
    x3z3x2z2[i][3] = x25[i];
    x3z3x2z2[i][2] = x3z3x2z2[i][1] = x3z3x2z2[i][0] = 0;
    z1x1_A[i][3]   = z1x1_A[i][1]   = z1x1_A[i][0]   = 0;
    z1x1_A[i][2]   = x25[i];
  }
  x3z3x2z2[0][2] = x3z3x2z2[0][1] = 1;
  z1x1_A[0][0]   = CONSTA;
  z1x1_A[0][3]   = 1;

  // main ladder loop
  for (i = 254; i >= 0; i--) {
    b = kp[i>>5] >> (i & 31);
    s = s ^ b;
    mon_cswap_point_1x4x1w(x3z3x2z2, s);
    mon_ladder_step_1x4x1w(x3z3x2z2, z1x1_A);
    s = b;
  } 

  mon_cswap_point_1x4x1w(x3z3x2z2, s);

  // projective -> affine
  mpi25_from_vec_4x1w(x25, x3z3x2z2, NLMB25, 1);
  mpi25_from_vec_4x1w(z25, x3z3x2z2, NLMB25, 0);

  mpi25_to_vec_1x4w(x_1x4w, x25);
  mpi25_to_vec_1x4w(z_1x4w, z25);
  gfp_inv_1x4w(z_1x4w, z_1x4w);
  gfp_mul_1x4w(r_1x4w, x_1x4w, z_1x4w);

  // vec4 -> string
  mpi25_from_vec_1x4w(r25, r_1x4w);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r, r25);
}  

// -----------------------------------------------------------------------------

void mon_ladder_step_1x2x1w(vec2 *x3z3, vec2 *x2z2, const vec2 *z1x1)
{
  vec2 tmp0[NLMB51], tmp1[NLMB51];

  // x2z2 =               x2 ||                     x3 
  // x3z3 =               z2 ||                     z3
  gfp_mix0_2x1w(x2z2, x3z3, x2z2, x3z3);
  // tmp0 =            x2+z2 ||                  x3+z3
  gfp_add_2x1w(tmp0, x2z2, x3z3);
  // tmp1 =            x2-z2 ||                  x3-z3 
  gfp_sub_2x1w(tmp1, x2z2, x3z3);
  // tmp1 =            x3-z3 ||                  x2-z2
  gfp_align_2x1w(tmp1, tmp1);
  // x3z3 =   (x2+z2)(x3-z3) ||         (x2-z2)(x3+z3)
  gfp_mul_2x1w(x3z3, tmp0, tmp1);
  // x2z2 =   (x2-z2)(x3+z3) ||         (x2+z2)(x3-z3)
  gfp_align_2x1w(x2z2, x3z3);
  // x3z3 =     2(x2x3-z2z3) ||           2(x3z2-x2z3)
  gfp_addsub_2x1w(x3z3, x2z2, x3z3);
  // x3z3 =   4(x2x3-z2z3)^2 ||         4(x2z3-x3z2)^2
  gfp_sqr_2x1w(x3z3, x3z3);
  // x3z3 = 4z1(x2x3-z2z3)^2 ||       4x1(x2z3-x3z2)^2
  gfp_mul_2x1w(x3z3, x3z3, z1x1);
  // tmp0 =            x2+z2 ||                  x2-z2
  gfp_mix1_2x1w(tmp0, tmp0, tmp1);
  // x2z2 =        (x2+z2)^2 ||              (x2-z2)^2
  gfp_sqr_2x1w(x2z2, tmp0);
  // tmp1 =   (x2+z2)^2 A24+ ||         (x2-z2)^2 A24-
  gfp_mul51_2x1w(tmp1, x2z2, c_A24_2x1w);
  // tmp0 =        (x2+z2)^2 ||         (x2+z2)^2 A24+
  // tmp1 =        (x2-z2)^2 ||         (x2-z2)^2 A24-
  gfp_mix0_2x1w(tmp0, tmp1, x2z2, tmp1);
  // tmp0 =            4x2z2 ||        Ax2z2+x2^2+z2^2
  gfp_sub_2x1w(tmp0, tmp0, tmp1);
  // x2z2 =        (x2+z2)^2 ||                  4x2z2
  // tmp0 =        (x2-z2)^2 ||        x2^2+z2^2+Ax2z2
  gfp_mix0_2x1w(x2z2, tmp0, x2z2, tmp0);
  // x2z2 =    (x2^2-z2^2)^2 || 4x2z2(x2^2+z2^2+Ax2z2)
  gfp_mul_2x1w(x2z2, x2z2, tmp0);
} 

void mon_mul_varbase_1x2x1w(uint64_t *r, const uint64_t *k, const uint64_t *x)
{
  vec2 x3z3[NLMB51], x2z2[NLMB51], z1x1[NLMB51];
  uint64_t kp[4], x51[NLMB51], z51[NLMB51], r51[NLMB51], r64[NLMB51];
  vec2 x_1x2w[3], z_1x2w[3], r_1x2w[3];
  int i, b, s = 0;

  // prune scalar k
  for (i = 0; i < 4; i++) kp[i] = k[i];
  kp[0] &= 0xFFFFFFFFFFFFFFF8ULL; 
  kp[3] &= 0x7FFFFFFFFFFFFFFFULL; 
  kp[3] |= 0x4000000000000000ULL;

  // convert x-coordinate to radix-2^51
  mpi_conv_64to51(x51, x);

  // initialize ladder
  for (i = 0; i < NLMB51; i++) {
    x3z3[i][1] = x51[i];
    x3z3[i][0] = 0;
    x2z2[i][1] = x2z2[i][0] = 0;
    z1x1[i][1] = 0;
    z1x1[i][0] = x51[i];
  }
  x3z3[0][0] = x2z2[0][1] = 1;
  z1x1[0][1] = 1;

  for (i = 254; i >= 0; i--) {
    b = kp[i>>6] >> (i & 63);
    s = s ^ b;
    mon_cswap_point_1x2x1w(x3z3, x2z2, s);
    mon_ladder_step_1x2x1w(x3z3, x2z2, z1x1);
    s = b;
  }

  mon_cswap_point_1x2x1w(x3z3, x2z2, s);

  // projective -> affine
  mpi51_from_vec_2x1w(x51, x2z2, NLMB51, 1);
  mpi51_from_vec_2x1w(z51, x2z2, NLMB51, 0);
  mpi51_to_vec_1x2w(x_1x2w, x51);
  mpi51_to_vec_1x2w(z_1x2w, z51);
  gfp_inv_1x2w(z_1x2w, z_1x2w);
  gfp_mul_1x2w(r_1x2w, x_1x2w, z_1x2w);

  // vec2 -> string
  mpi51_from_vec_1x2w(r51, r_1x2w);
  mpi51_carry_prop(r51);
  mpi_conv_51to64(r, r51);
}
