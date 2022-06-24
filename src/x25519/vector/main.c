#include "share.h"
#include "config.h"
#include "rdtsc.h"
#include "gfparith.h"
#include "moncurve.h"


// macros for measuring CPU cycles

#define LOAD_CACHE(X, ITER) for (i = 0; i < (ITER); i++) (X)

#define MEASURE_CYCLES(X, ITER)                    \
  start_cycles = rdtsc();                          \
  for (i = 0; i < (ITER); i++) (X);                \
  end_cycles = rdtsc();                            \
  diff_cycles = (end_cycles-start_cycles)/(ITER)


void test_gfp_arith()
{
  vec4 a_4x1w[NLMB25] = { 0 }, b_4x1w[NLMB25] = { 0 }, c_4x1w[NLMB25] = { 0 };
  vec4 r_4x1w[NLMB25] = { 0 }, s_4x1w[NLMB25] = { 0 };
  uint32_t a25[NLMB25], b25[NLMB25], r25[NLMB25], r32[9]; 
  uint64_t start_cycles, end_cycles, diff_cycles;
  int i;

  // prepare and form test vectors

  // a := 0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;
  uint32_t a32[8] = { 0x89ABCDEFUL, 0x01234567UL, 0x89ABCDEFUL, 0x01234567UL, 
                      0x89ABCDEFUL, 0x01234567UL, 0x89ABCDEFUL, 0x01234567UL, };
  // b := 0x09ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF01234567;
  uint32_t b32[8] = { 0x01234567UL, 0x89ABCDEFUL, 0x01234567UL, 0x89ABCDEFUL, 
                      0x01234567UL, 0x89ABCDEFUL, 0x01234567UL, 0x09ABCDEFUL, };

  mpi_conv_32to25(a25, a32);
  mpi_conv_32to25(b25, b32);

  for (i = 0; i < NLMB25; i++) {
    a_4x1w[i][0] = a25[i];
    b_4x1w[i][0] = b25[i];
  }

  puts("\n**************************************************************************");
  puts("VEC GFP ARITH 4x1w:\n");

  // ---------------------------------------------------------------------------

  printf("- gfp mul 4x1w v0:");

  LOAD_CACHE(gfp_mul_4x1w_v0(r_4x1w, a_4x1w, b_4x1w), 100);
  MEASURE_CYCLES(gfp_mul_4x1w_v0(r_4x1w, a_4x1w, b_4x1w), 1000);
  printf("        #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x359FEE6106B5DA2E7C347321EADF6B4942C8F7E2CF08FC64095D7CA3B3328D77;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 0);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r  = 0x", r32, 8);
  memset(r_4x1w, 0, 4*4*NLMB25);
#endif 

  printf("- gfp mul 4x1w v1:");

  LOAD_CACHE(gfp_mul_4x1w_v1(r_4x1w, a_4x1w, b_4x1w), 100);
  MEASURE_CYCLES(gfp_mul_4x1w_v1(r_4x1w, a_4x1w, b_4x1w), 1000);
  printf("        #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x359FEE6106B5DA2E7C347321EADF6B4942C8F7E2CF08FC64095D7CA3B3328D77;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 0);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r  = 0x", r32, 8); 
  memset(r_4x1w, 0, 4*4*NLMB25); 
#endif

  printf("- gfp mul 4x1w v2:");

  LOAD_CACHE(gfp_mul_4x1w_v2(r_4x1w, a_4x1w, b_4x1w), 100);
  MEASURE_CYCLES(gfp_mul_4x1w_v2(r_4x1w, a_4x1w, b_4x1w), 1000);
  printf("        #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x359FEE6106B5DA2E7C347321EADF6B4942C8F7E2CF08FC64095D7CA3B3328D77;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 0);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r  = 0x", r32, 8);  
  memset(r_4x1w, 0, 4*4*NLMB25);
#endif

  puts("");

  // ---------------------------------------------------------------------------

  printf("- gfp sqr 4x1w v0:");

  LOAD_CACHE(gfp_sqr_4x1w_v0(r_4x1w, a_4x1w), 100);
  MEASURE_CYCLES(gfp_sqr_4x1w_v0(r_4x1w, a_4x1w), 1000);
  printf("        #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x72CC9B9B881D163356F62CB64EB19AF43B1FBDD115461FB51F494EEBDBDAA465;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 0);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r  = 0x", r32, 8);
  memset(r_4x1w, 0, 4*4*NLMB25);
#endif

  printf("- gfp sqr 4x1w v1:");

  LOAD_CACHE(gfp_sqr_4x1w_v1(r_4x1w, a_4x1w), 100);
  MEASURE_CYCLES(gfp_sqr_4x1w_v1(r_4x1w, a_4x1w), 1000);
  printf("        #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x72CC9B9B881D163356F62CB64EB19AF43B1FBDD115461FB51F494EEBDBDAA465;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 0);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r  = 0x", r32, 8);
  memset(r_4x1w, 0, 4*4*NLMB25);
#endif

  printf("- gfp sqr 4x1w v2:");

  LOAD_CACHE(gfp_sqr_4x1w_v2(r_4x1w, a_4x1w), 100);
  MEASURE_CYCLES(gfp_sqr_4x1w_v2(r_4x1w, a_4x1w), 1000);
  printf("        #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x72CC9B9B881D163356F62CB64EB19AF43B1FBDD115461FB51F494EEBDBDAA465;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 0);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r  = 0x", r32, 8);
  memset(r_4x1w, 0, 4*4*NLMB25);
#endif

  puts("");

  // ---------------------------------------------------------------------------

  for (i = 0; i < NLMB25; i++) {
    a_4x1w[i][0] = a25[i];
    a_4x1w[i][1] = b25[i];
    a_4x1w[i][2] = b25[i];
    a_4x1w[i][3] = a25[i];
  }
  
  // lane   :    3    ||    2    ||    1    ||    0    
  // input  =    a    ||    b    ||    b    ||    a         
  // output =   a+b   ||  a+2p-b ||   a+b   ||  b+2p-a 

  printf("- gfp hadamard 4x1w v0:");

  LOAD_CACHE(gfp_hadamard_4x1w_v0(r_4x1w, a_4x1w, &m_ladder_1x4x1w[0]), 100);
  MEASURE_CYCLES(gfp_hadamard_4x1w_v0(r_4x1w, a_4x1w, &m_ladder_1x4x1w[0]), 1000);
  printf("   #inst = %lld\n", diff_cycles);

#if DEBUG
  // r0 := 0x10888888777777778888888877777777888888887777777788888888777777752;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 0);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r0 = 0x", r32, 9);
  // r1 := 0xACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF1356;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 1);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r1 = 0x", r32, 9);
  // r2 := 0xF777777888888887777777788888888777777778888888877777777888888862;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 2);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r2 = 0x", r32, 9);
  // r3 := 0xACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF1356;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 3);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r3 = 0x", r32, 9);
  memset(r_4x1w, 0, 4*4*NLMB25);
#endif

  printf("- gfp hadamard 4x1w v1:");

  LOAD_CACHE(gfp_hadamard_4x1w_v1(r_4x1w, a_4x1w, &m_ladder_1x4x1w[0]), 100);
  MEASURE_CYCLES(gfp_hadamard_4x1w_v1(r_4x1w, a_4x1w, &m_ladder_1x4x1w[0]), 1000);
  printf("   #inst = %lld\n", diff_cycles);

#if DEBUG
  // r0 := 0x10888888777777778888888877777777888888887777777788888888777777752;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 0);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r0 = 0x", r32, 9);
  // r1 := 0xACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF1356;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 1);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r1 = 0x", r32, 9);
  // r2 := 0xF777777888888887777777788888888777777778888888877777777888888862;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 2);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r2 = 0x", r32, 9);
  // r3 := 0xACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF1356;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 3);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r3 = 0x", r32, 9);
  memset(r_4x1w, 0, 4*4*NLMB25);
#endif

  printf("- gfp hadamard 4x1w v2:");

  LOAD_CACHE(gfp_hadamard_4x1w_v2(r_4x1w, a_4x1w, &m_ladder_1x4x1w[0]), 100);
  MEASURE_CYCLES(gfp_hadamard_4x1w_v2(r_4x1w, a_4x1w, &m_ladder_1x4x1w[0]), 1000);
  printf("   #inst = %lld\n", diff_cycles);

#if DEBUG
  // r0 := 0x10888888777777778888888877777777888888887777777788888888777777752;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 0);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r0 = 0x", r32, 9);
  // r1 := 0xACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF1356;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 1);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r1 = 0x", r32, 9);
  // r2 := 0xF777777888888887777777788888888777777778888888877777777888888862;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 2);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r2 = 0x", r32, 9);
  // r3 := 0xACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF1356;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 3);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r3 = 0x", r32, 9);
  memset(r_4x1w, 0, 4*4*NLMB25);
#endif

  puts("");

  // ---------------------------------------------------------------------------

  for (i = 0; i < NLMB25; i++) {
    a_4x1w[i][0] = 0x00000000; a_4x1w[i][1] = 0x11111111; 
    a_4x1w[i][2] = 0x22222222; a_4x1w[i][3] = 0x33333333;
  }

  // lane   :    3    ||    2    ||    1    ||    0    
  // input  =    0    ||    0    ||    b    ||    a         
  // output =    a    ||    b    ||    b    ||    a 

  printf("- gfp align 4x1w v2:");

  LOAD_CACHE(gfp_align_4x1w_v2(r_4x1w, a_4x1w, &m_ladder_1x4x1w[1]), 100);
  MEASURE_CYCLES(gfp_align_4x1w_v2(r_4x1w, a_4x1w, &m_ladder_1x4x1w[1]), 1000);
  printf("      #inst = %lld\n", diff_cycles);

#if DEBUG
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 0);
  mpi32_print("  r0 = 0x", r25, NLMB25);
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 1);
  mpi32_print("  r1 = 0x", r25, NLMB25);
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 2);
  mpi32_print("  r2 = 0x", r25, NLMB25);
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 3);
  mpi32_print("  r3 = 0x", r25, NLMB25);
  memset(r_4x1w, 0, 4*4*NLMB25);
#endif

  puts(" ");

  // ---------------------------------------------------------------------------

  for (i = 0; i < NLMB25; i++) {
    a_4x1w[i][0] = 0x00000000; a_4x1w[i][1] = 0x11111111; 
    a_4x1w[i][2] = 0x22222222; a_4x1w[i][3] = 0x33333333;
    b_4x1w[i][0] = 0x44444444; b_4x1w[i][1] = 0x55555555; 
    b_4x1w[i][2] = 0x66666666; b_4x1w[i][3] = 0x77777777;
    c_4x1w[i][0] = 0x88888888; c_4x1w[i][1] = 0x99999999; 
    c_4x1w[i][2] = 0xAAAAAAAA; c_4x1w[i][3] = 0xBBBBBBBB;
  }

  // lane     :    3    ||    2    ||    1    ||    0    
  // input  a =    3    ||    2    ||    1    ||    0 
  //        b =    7    ||    6    ||    5    ||    4
  //        c =    B    ||    A    ||    9    ||    8         
  // output r =    3    ||    2    ||    5    ||    0 
  //        s =    B    ||    A    ||    4    ||    8 

  printf("- gfp premix 4x1w v2:");

  LOAD_CACHE(gfp_premix_4x1w_v2(r_4x1w, s_4x1w, a_4x1w, b_4x1w, c_4x1w, &m_ladder_1x4x1w[0]), 100);
  MEASURE_CYCLES(gfp_premix_4x1w_v2(r_4x1w, s_4x1w, a_4x1w, b_4x1w, c_4x1w, &m_ladder_1x4x1w[0]), 1000);
  printf("     #inst = %lld\n", diff_cycles);

#if DEBUG
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 0);
  mpi32_print("  r0 = 0x", r25, NLMB25);
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 1);
  mpi32_print("  r1 = 0x", r25, NLMB25);
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 2);
  mpi32_print("  r2 = 0x", r25, NLMB25);
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 3);
  mpi32_print("  r3 = 0x", r25, NLMB25);

  mpi25_from_vec_4x1w(r25, s_4x1w, NLMB25, 0);
  mpi32_print("  s0 = 0x", r25, NLMB25);
  mpi25_from_vec_4x1w(r25, s_4x1w, NLMB25, 1);
  mpi32_print("  s1 = 0x", r25, NLMB25);
  mpi25_from_vec_4x1w(r25, s_4x1w, NLMB25, 2);
  mpi32_print("  s2 = 0x", r25, NLMB25);
  mpi25_from_vec_4x1w(r25, s_4x1w, NLMB25, 3);
  mpi32_print("  s3 = 0x", r25, NLMB25);

  memset(r_4x1w, 0, 4*4*NLMB25);
  memset(s_4x1w, 0, 4*4*NLMB25);
#endif

  puts("");

  // ---------------------------------------------------------------------------

  for (i = 0; i < NLMB25; i++) {
    a_4x1w[i][0] = a25[i]; 
    a_4x1w[i][1] = b25[i];
    a_4x1w[i][2] = b25[i];
    a_4x1w[i][3] = a25[i];
    b_4x1w[i][0] = a25[i];
    b_4x1w[i][1] = b25[i];
    b_4x1w[i][2] = 0;
    b_4x1w[i][3] = 0;
  }

  // lane       :    3    ||    2    ||    1    ||    0    
  // input  "a" =    a    ||    b    ||    b    ||    a
  //        "b" =    0    ||    0    ||    b    ||    a
  // output "r" =    a    ||    b    ||   b-a   ||  2b+a

  printf("- gfp postmix 4x1w v0:");

  LOAD_CACHE(gfp_postmix_4x1w_v0(r_4x1w, a_4x1w, b_4x1w, &m_ladder_1x4x1w[0]), 100);
  MEASURE_CYCLES(gfp_postmix_4x1w_v0(r_4x1w, a_4x1w, b_4x1w, &m_ladder_1x4x1w[0]), 1000);
  printf("    #inst = %lld\n", diff_cycles);

#if DEBUG
  // r0 := 0x147AE1458BF258BE147AE1458BF258BE147AE1458BF258BE147AE1458BF258BD;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 0);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r0 = 0x", r32, 8);
  // r1 := 0x0888888777777778888888877777777888888887777777788888888777777778;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 1);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r1 = 0x", r32, 8);
  // r2 := 0x09ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF01234567;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 2);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r2 = 0x", r32, 8);
  // r3 := 0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 3);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r3 = 0x", r32, 8);
  memset(r_4x1w, 0, 4*4*NLMB25);
#endif

  printf("- gfp postmix 4x1w v2:");

  LOAD_CACHE(gfp_postmix_4x1w_v2(r_4x1w, a_4x1w, b_4x1w, &m_ladder_1x4x1w[0]), 100);
  MEASURE_CYCLES(gfp_postmix_4x1w_v2(r_4x1w, a_4x1w, b_4x1w, &m_ladder_1x4x1w[0]), 1000);
  printf("    #inst = %lld\n", diff_cycles);

#if DEBUG
  // r0 := 0x147AE1458BF258BE147AE1458BF258BE147AE1458BF258BE147AE1458BF258BD;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 0);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r0 = 0x", r32, 8);
  // r1 := 0x0888888777777778888888877777777888888887777777788888888777777778;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 1);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r1 = 0x", r32, 8);
  // r2 := 0x09ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF01234567;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 2);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r2 = 0x", r32, 8);
  // r3 := 0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;
  mpi25_from_vec_4x1w(r25, r_4x1w, NLMB25, 3);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r3 = 0x", r32, 8);
  memset(r_4x1w, 0, 4*4*NLMB25);
#endif

  puts("");

  // ---------------------------------------------------------------------------
  puts("VEC GFP ARITH 1x4w:\n");

  vec4 a_1x4w[3]  = { { a25[0], a25[3], a25[6], a25[9] }, 
                      { a25[1], a25[4], a25[7],      0 }, 
                      { a25[2], a25[5], a25[8],      0 } }; 
  vec4 b_1x4w[3]  = { { b25[0], b25[3], b25[6], b25[9] }, 
                      { b25[1], b25[4], b25[7],      0 }, 
                      { b25[2], b25[5], b25[8],      0 } };
  vec4 r_1x4w[3]  = { 0 };

  printf("- gfp mul 1x4w v0:");

  LOAD_CACHE(gfp_mul_1x4w_v0(r_1x4w, a_1x4w, b_1x4w, m_mul_1x4w), 100);
  MEASURE_CYCLES(gfp_mul_1x4w_v0(r_1x4w, a_1x4w, b_1x4w, m_mul_1x4w), 1000);
  printf("        #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x359FEE6106B5DA2E7C347321EADF6B4942C8F7E2CF08FC64095D7CA3B3328D77;
  for (i = 0; i < NLMB25; i++) r25[i] = r_1x4w[i%3][i/3];
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r  = 0x", r32, 8);
  memset(r_1x4w, 0, 4*4*3);
#endif 

  puts("");

  // ---------------------------------------------------------------------------

  printf("- gfp inv 1x4w:");

  LOAD_CACHE(gfp_inv_1x4w(r_1x4w, a_1x4w), 10);
  MEASURE_CYCLES(gfp_inv_1x4w(r_1x4w, a_1x4w), 100);
  printf("           #inst = %lld\n", diff_cycles);

#if DEBUG
  for (i = 0; i < NLMB25; i++) r25[i] = r_1x4w[i%3][i/3];
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  r  = 0x", r32, 8);
  memset(r_1x4w, 0, 4*4*3);
#endif 

  puts("");

  puts("--------------------------------------------------------------------------");
  puts("VEC GFP ARITH 2x1w:\n");

  uint64_t a_2x1w[NLMB51][2] = { 0 };
  uint64_t b_2x1w[NLMB51][2] = { 0 };
  uint64_t r_2x1w[NLMB51][2] = { 0 };
  uint64_t a51[NLMB51], b51[NLMB51], r51[NLMB51], r64[NLMB51];

  // a := 0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;
  uint64_t a64[4] = { 0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL,
                      0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL, };
  // b := 0x09ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF01234567;
  uint64_t b64[4] = { 0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL,
                      0x89ABCDEF01234567ULL, 0x09ABCDEF01234567ULL, };

  mpi_conv_64to51(a51, a64);
  mpi_conv_64to51(b51, b64);

  for (i = 0; i < NLMB51; i++) {
    a_2x1w[i][0] = a51[i];
    b_2x1w[i][0] = b51[i];
  }

  // ---------------------------------------------------------------------------

  printf("- gfp mul 2x1w v0:");

  LOAD_CACHE(gfp_mul_2x1w_v0(r_2x1w, a_2x1w, b_2x1w, m_mul_2x1w), 100);
  MEASURE_CYCLES(gfp_mul_2x1w_v0(r_2x1w, a_2x1w, b_2x1w, m_mul_2x1w), 1000);
  printf("        #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x359FEE6106B5DA2E7C347321EADF6B4942C8F7E2CF08FC64095D7CA3B3328D77;
  mpi51_from_vec_2x1w(r51, r_2x1w, NLMB51, 0);
  mpi51_carry_prop(r51);
  mpi_conv_51to64(r64, r51);
  mpi64_print("  r  = 0x", r64, 4);
  memset(r_2x1w, 0, 2*8*NLMB51);
#endif 

  printf("- gfp mul 2x1w v1:");

  LOAD_CACHE(gfp_mul_2x1w_v1(r_2x1w, a_2x1w, b_2x1w, m_mul_2x1w), 100);
  MEASURE_CYCLES(gfp_mul_2x1w_v1(r_2x1w, a_2x1w, b_2x1w, m_mul_2x1w), 1000);
  printf("        #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x359FEE6106B5DA2E7C347321EADF6B4942C8F7E2CF08FC64095D7CA3B3328D77;
  mpi51_from_vec_2x1w(r51, r_2x1w, NLMB51, 0);
  mpi51_carry_prop(r51);
  mpi_conv_51to64(r64, r51);
  mpi64_print("  r  = 0x", r64, 4);
  memset(r_2x1w, 0, 2*8*NLMB51);
#endif 

  puts("");

  // ---------------------------------------------------------------------------

  printf("- gfp sqr 2x1w v0:");

  LOAD_CACHE(gfp_sqr_2x1w_v0(r_2x1w, a_2x1w, m_mul_2x1w), 100);
  MEASURE_CYCLES(gfp_sqr_2x1w_v0(r_2x1w, a_2x1w, m_mul_2x1w), 1000);
  printf("        #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x72CC9B9B881D163356F62CB64EB19AF43B1FBDD115461FB51F494EEBDBDAA465;
  mpi51_from_vec_2x1w(r51, r_2x1w, NLMB51, 0);
  mpi51_carry_prop(r51);
  mpi_conv_51to64(r64, r51);
  mpi64_print("  r  = 0x", r64, 4);
  memset(r_2x1w, 0, 2*8*NLMB51);
#endif 

  printf("- gfp sqr 2x1w v1:");

  LOAD_CACHE(gfp_sqr_2x1w_v1(r_2x1w, a_2x1w, m_mul_2x1w), 100);
  MEASURE_CYCLES(gfp_sqr_2x1w_v1(r_2x1w, a_2x1w, m_mul_2x1w), 1000);
  printf("        #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x72CC9B9B881D163356F62CB64EB19AF43B1FBDD115461FB51F494EEBDBDAA465;
  mpi51_from_vec_2x1w(r51, r_2x1w, NLMB51, 0);
  mpi51_carry_prop(r51);
  mpi_conv_51to64(r64, r51);
  mpi64_print("  r  = 0x", r64, 4);
  memset(r_2x1w, 0, 2*8*NLMB51);
#endif 

  puts("");

  // ---------------------------------------------------------------------------
  puts("VEC GFP ARITH 1x2w:\n");

  vec2 a_1x2w[3]  = { { a51[0], a51[3] }, { a51[1], a51[4] }, { a51[2], 0 } };
  vec2 b_1x2w[3]  = { { b51[0], b51[3] }, { b51[1], b51[4] }, { b51[2], 0 } };
  vec2 r_1x2w[3]  = { 0 };

  printf("- gfp mul 1x2w v0:");

  LOAD_CACHE(gfp_mul_1x2w_v0(r_1x2w, a_1x2w, b_1x2w, m_mul_1x2w), 100);
  MEASURE_CYCLES(gfp_mul_1x2w_v0(r_1x2w, a_1x2w, b_1x2w, m_mul_1x2w), 1000);
  printf("        #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x359FEE6106B5DA2E7C347321EADF6B4942C8F7E2CF08FC64095D7CA3B3328D77;
  for (i = 0; i < NLMB51; i++) r51[i] = r_1x2w[i%3][i/3];
  mpi51_carry_prop(r51);
  mpi_conv_51to64(r64, r51);
  mpi64_print("  r  = 0x", r64, 4);
  memset(r_1x2w, 0, 2*8*3);
#endif 

  puts("");

  // ---------------------------------------------------------------------------

  printf("- gfp inv 1x2w:");

  LOAD_CACHE(gfp_inv_1x2w(r_1x2w, a_1x2w), 10);
  MEASURE_CYCLES(gfp_inv_1x2w(r_1x2w, a_1x2w), 100);
  printf("           #inst = %lld\n", diff_cycles);

#if DEBUG
  for (i = 0; i < NLMB51; i++) r51[i] = r_1x2w[i%3][i/3];
  mpi51_carry_prop(r51);
  mpi_conv_51to64(r64, r51);
  mpi64_print("  r  = 0x", r64, 4);
  memset(r_1x2w, 0, 2*8*3);
#endif 

  puts("**************************************************************************\n");
}

void test_ise()
{
  puts("\n**************************************************************************");
  puts("VEC GFP ARITH ISE 2x1w:\n");

  uint64_t a_2x1w[NLMB51][2] = { 0 };
  uint64_t b_2x1w[NLMB51][2] = { 0 };
  uint64_t r_2x1w[NLMB51][2] = { 0 };
  uint64_t a51[NLMB51], b51[NLMB51], r51[NLMB51], r64[NLMB51];
  uint64_t start_cycles, end_cycles, diff_cycles;
  int i;

  // a := 0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;
  uint64_t a64[4] = { 0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL,
                      0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL, };
  // b := 0x09ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF01234567;
  uint64_t b64[4] = { 0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL,
                      0x89ABCDEF01234567ULL, 0x09ABCDEF01234567ULL, };

  mpi_conv_64to51(a51, a64);
  mpi_conv_64to51(b51, b64);

  for (i = 0; i < NLMB51; i++) {
    a_2x1w[i][0] = a51[i];
    b_2x1w[i][0] = b51[i];
  }

  printf("- gfp mul 2x1w v0 (ISE):");

  LOAD_CACHE(gfp_mul_2x1w_v0_ise(r_2x1w, a_2x1w, b_2x1w, m_mul_2x1w), 100);
  MEASURE_CYCLES(gfp_mul_2x1w_v0_ise(r_2x1w, a_2x1w, b_2x1w, m_mul_2x1w), 1000);
  printf("    #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x359FEE6106B5DA2E7C347321EADF6B4942C8F7E2CF08FC64095D7CA3B3328D77;
  mpi51_from_vec_2x1w(r51, r_2x1w, NLMB51, 0);
  mpi51_carry_prop(r51);
  mpi_conv_51to64(r64, r51);
  mpi64_print("  r  = 0x", r64, 4);
  memset(r_2x1w, 0, 2*8*NLMB51);
#endif 

  printf("- gfp mul 2x1w v1 (ISE):");

  LOAD_CACHE(gfp_mul_2x1w_v1_ise(r_2x1w, a_2x1w, b_2x1w, m_mul_2x1w), 100);
  MEASURE_CYCLES(gfp_mul_2x1w_v1_ise(r_2x1w, a_2x1w, b_2x1w, m_mul_2x1w), 1000);
  printf("    #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x359FEE6106B5DA2E7C347321EADF6B4942C8F7E2CF08FC64095D7CA3B3328D77;
  mpi51_from_vec_2x1w(r51, r_2x1w, NLMB51, 0);
  mpi51_carry_prop(r51);
  mpi_conv_51to64(r64, r51);
  mpi64_print("  r  = 0x", r64, 4);
  memset(r_2x1w, 0, 2*8*NLMB51);
#endif 

  puts("");

  // ---------------------------------------------------------------------------

  printf("- gfp sqr 2x1w v0 (ISE):");

  LOAD_CACHE(gfp_sqr_2x1w_v0_ise(r_2x1w, a_2x1w, m_mul_2x1w), 100);
  MEASURE_CYCLES(gfp_sqr_2x1w_v0_ise(r_2x1w, a_2x1w, m_mul_2x1w), 1000);
  printf("    #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x72CC9B9B881D163356F62CB64EB19AF43B1FBDD115461FB51F494EEBDBDAA465;
  mpi51_from_vec_2x1w(r51, r_2x1w, NLMB51, 0);
  mpi51_carry_prop(r51);
  mpi_conv_51to64(r64, r51);
  mpi64_print("  r  = 0x", r64, 4);
  memset(r_2x1w, 0, 2*8*NLMB51);
#endif 

  printf("- gfp sqr 2x1w v1 (ISE):");

  LOAD_CACHE(gfp_sqr_2x1w_v1_ise(r_2x1w, a_2x1w, m_mul_2x1w), 100);
  MEASURE_CYCLES(gfp_sqr_2x1w_v1_ise(r_2x1w, a_2x1w, m_mul_2x1w), 1000);
  printf("    #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x72CC9B9B881D163356F62CB64EB19AF43B1FBDD115461FB51F494EEBDBDAA465;
  mpi51_from_vec_2x1w(r51, r_2x1w, NLMB51, 0);
  mpi51_carry_prop(r51);
  mpi_conv_51to64(r64, r51);
  mpi64_print("  r  = 0x", r64, 4);
  memset(r_2x1w, 0, 2*8*NLMB51);
#endif 

  puts("");

  // ---------------------------------------------------------------------------
  puts("VEC GFP ARITH 1x2w:\n");

  vec2 a_1x2w[3]  = { { a51[0], a51[3] }, { a51[1], a51[4] }, { a51[2], 0 } };
  vec2 b_1x2w[3]  = { { b51[0], b51[3] }, { b51[1], b51[4] }, { b51[2], 0 } };
  vec2 r_1x2w[3]  = { 0 };

  printf("- gfp mul 1x2w v0 (ISE):");

  LOAD_CACHE(gfp_mul_1x2w_v0_ise(r_1x2w, a_1x2w, b_1x2w, m_mul_1x2w), 100);
  MEASURE_CYCLES(gfp_mul_1x2w_v0_ise(r_1x2w, a_1x2w, b_1x2w, m_mul_1x2w), 1000);
  printf("        #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x359FEE6106B5DA2E7C347321EADF6B4942C8F7E2CF08FC64095D7CA3B3328D77;
  for (i = 0; i < NLMB51; i++) r51[i] = r_1x2w[i%3][i/3];
  mpi51_carry_prop(r51);
  mpi_conv_51to64(r64, r51);
  mpi64_print("  r  = 0x", r64, 4);
  memset(r_1x2w, 0, 2*8*3);
#endif 

  puts("");

  puts("**************************************************************************\n");
}

void test_curve_arith()
{
  vec4 x3z3x2z2[NLMB25], z1x1_A[NLMB25];
  uint32_t xp32[8] = { 0x01234A14, 0x89ABCDEF, 0x01234567, 0x89ABCDEF, \
    0x01234567, 0x89ABCDEF, 0x01234567, 0x09ABCDEF };
  uint32_t zp32[8] = { 0x89ABD289, 0x01234567, 0x89ABCDEF, 0x01234567, \
    0x89ABCDEF, 0x01234567, 0x89ABCDEF, 0x01234567 };  
  uint32_t xq32[8] = { 0xd807aa98, 0xa3030242, 0x12835b01, 0x45706fbe, \
    0x243185be, 0x4ee4b28c, 0x550c7dc3, 0x55ffb4e2 };
  uint32_t zq32[8] = { 0x72be5d74, 0xf27b896f, 0x80deb1fe, 0x3b1696b1, \
    0x9bdc06a7, 0x25c71235, 0xc19bf174, 0x4f692694 };
  uint32_t xd32[8] = { 0xe49b69c1, 0x9ef14ad2, 0xefbe4786, 0x384f25e3, \
    0x0fc19dc6, 0x8b8cd5b5, 0x240ca1cc, 0x77ac9c65 };
  uint32_t r32[9], r25[NLMB25];
  uint32_t xp25[NLMB25], zp25[NLMB25], xq25[NLMB25], zq25[NLMB25], xd25[NLMB25];
  int i;
  uint64_t start_cycles, end_cycles, diff_cycles;

  mpi_conv_32to25(xp25, xp32);
  mpi_conv_32to25(zp25, zp32);
  mpi_conv_32to25(xq25, xq32);
  mpi_conv_32to25(zq25, zq32);
  mpi_conv_32to25(xd25, xd32);

  for (i = 0; i < NLMB25; i++) {
    x3z3x2z2[i][0] = zp25[i];
    x3z3x2z2[i][1] = xp25[i];
    x3z3x2z2[i][2] = zq25[i];
    x3z3x2z2[i][3] = xq25[i];
    z1x1_A[i][2]   = xd25[i];
    z1x1_A[i][0] = z1x1_A[i][1] = z1x1_A[i][3] = 0;   
  }
  z1x1_A[0][0] = CONSTA;
  z1x1_A[0][3] = 1;


  puts("\n**************************************************************************");
  puts("VEC MONTGOMERY CURVE ARITH 1x4x1w:\n");

  printf("- mon ladder step 1x4x1w:");

  LOAD_CACHE(mon_ladder_step_1x4x1w(x3z3x2z2, z1x1_A), 10);
  MEASURE_CYCLES(mon_ladder_step_1x4x1w(x3z3x2z2, z1x1_A), 100);
  printf(" #inst = %lld\n", diff_cycles);

#if DEBUG
  for (i = 0; i < NLMB25; i++) {
    x3z3x2z2[i][0] = zp25[i];
    x3z3x2z2[i][1] = xp25[i];
    x3z3x2z2[i][2] = zq25[i];
    x3z3x2z2[i][3] = xq25[i];
  }
  mon_ladder_step_1x4x1w(x3z3x2z2, z1x1_A);
  // x3 := 0x4F46FD1FD643F60F58FBC3DCB6691EDBB8BC4C0E8619879A1E7CCD145F86813B
  // z3 := 0x32C0C112720E8B7C9945DA6D5730D5D9CD118B8C76A5A8E7AB247B06822B993C
  // x2 := 0x1C3D46520257873EDF13AB303F812260A1EA100E7CAABD8264C074EEC5FB104E
  // z2 := 0x2F06F5CA09100C04718E216112881F623DD1C322D08E87E9B71F2949E16C9CCD
  mpi25_from_vec_4x1w(r25, x3z3x2z2, NLMB25, 3);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  x3 = 0x", r32, 8);
  mpi25_from_vec_4x1w(r25, x3z3x2z2, NLMB25, 2);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  z3 = 0x", r32, 8);
  mpi25_from_vec_4x1w(r25, x3z3x2z2, NLMB25, 1);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  x2 = 0x", r32, 8);
  mpi25_from_vec_4x1w(r25, x3z3x2z2, NLMB25, 0);
  mpi25_carry_prop(r25);
  mpi_conv_25to32(r32, r25);
  mpi32_print("  z2 = 0x", r32, 8);
#endif  

  puts("");

  // ---------------------------------------------------------------------------

  printf("- mon varbase mul 1x4x1w:");

  uint32_t k32[8] = { 0x6BE346A5, 0x9D7C52F0, 0x4B15163B, 0xDD5E4682, \
    0x0A4C1462, 0x185AFCC1, 0x44226A50, 0xC49A44BA };
  uint32_t x32[8] = { 0x6768DBE6, 0xDB303058, 0xA4C19435, 0x7C5FB124, \
    0xEC246672, 0x3B35B326, 0xA603A910, 0x4C1CABD0 };

  LOAD_CACHE(mon_mul_varbase_1x4x1w(r32, k32, x32), 10);
  MEASURE_CYCLES(mon_mul_varbase_1x4x1w(r32, k32, x32), 50);
  printf(" #inst = %lld\n", diff_cycles);

#if DEBUG
  // R := 0x5285A2775507B454F7711C4903CFEC324F088DF24DEA948E90C6E99D3755DAC3;
  mpi32_print("  R  = 0x", r32, 8);
#endif  

  puts("");

  puts("--------------------------------------------------------------------------");
  puts("VEC MONTGOMERY CURVE ARITH 1x2x1w:\n");

  vec2 x3z3[NLMB51], x2z2[NLMB51], z1x1[NLMB51];
  uint64_t xp64[4] = { 0x89ABCDEF01234A14, 0x89ABCDEF01234567, \
    0x89ABCDEF01234567, 0x09ABCDEF01234567 };
  uint64_t zp64[4] = { 0x0123456789ABD289, 0x0123456789ABCDEF, \
    0x0123456789ABCDEF, 0x0123456789ABCDEF };  
  uint64_t xq64[4] = { 0xa3030242d807aa98, 0x45706fbe12835b01, \
    0x4ee4b28c243185be, 0x55ffb4e2550c7dc3 };
  uint64_t zq64[4] = { 0xf27b896f72be5d74, 0x3b1696b180deb1fe, \
    0x25c712359bdc06a7, 0x4f692694c19bf174 };
  uint64_t xd64[4] = { 0x9ef14ad2e49b69c1, 0x384f25e3efbe4786, \
    0x8b8cd5b50fc19dc6, 0x77ac9c65240ca1cc };
  uint64_t r64[NLMB51], r51[NLMB51];
  uint64_t xp51[NLMB51], zp51[NLMB51], xq51[NLMB51], zq51[NLMB51], xd51[NLMB51];

  mpi_conv_64to51(xp51, xp64);
  mpi_conv_64to51(zp51, zp64);
  mpi_conv_64to51(xq51, xq64);
  mpi_conv_64to51(zq51, zq64);
  mpi_conv_64to51(xd51, xd64);

  for (i = 0; i < NLMB51; i++) {
    x2z2[i][0] = zp51[i];
    x2z2[i][1] = xp51[i];
    x3z3[i][0] = zq51[i];
    x3z3[i][1] = xq51[i];
    z1x1[i][0] = xd51[i];
    z1x1[i][1] = 0;   
  }
  z1x1[0][1] = 1;

  printf("- mon ladder step 1x2x1w:");

  LOAD_CACHE(mon_ladder_step_1x2x1w(x3z3, x2z2, z1x1), 10);
  MEASURE_CYCLES(mon_ladder_step_1x2x1w(x3z3, x2z2, z1x1), 100);
  printf(" #inst = %lld\n", diff_cycles);

#if DEBUG
  for (i = 0; i < NLMB51; i++) {
    x2z2[i][0] = zp51[i];
    x2z2[i][1] = xp51[i];
    x3z3[i][0] = zq51[i];
    x3z3[i][1] = xq51[i];
  }
  mon_ladder_step_1x2x1w(x3z3, x2z2, z1x1);
  // x3 := 0x4F46FD1FD643F60F58FBC3DCB6691EDBB8BC4C0E8619879A1E7CCD145F86813B
  // z3 := 0x32C0C112720E8B7C9945DA6D5730D5D9CD118B8C76A5A8E7AB247B06822B993C
  // x2 := 0x470F51948095E1CFB7C4EACC0FE04898287A84039F2AAF6099301D3BB17EC40A
  // z2 := 0x6BC1BD72824403011C63885844A207D88F7470C8B423A1FA6DC7CA52785B2725
  mpi51_from_vec_2x1w(r51, x3z3, NLMB51, 1);
  mpi51_carry_prop(r51);
  mpi_conv_51to64(r64, r51);
  mpi64_print("  x3 = 0x", r64, 4);
  mpi51_from_vec_2x1w(r51, x3z3, NLMB51, 0);
  mpi51_carry_prop(r51);
  mpi_conv_51to64(r64, r51);
  mpi64_print("  z3 = 0x", r64, 4);
  mpi51_from_vec_2x1w(r51, x2z2, NLMB51, 1);
  mpi51_carry_prop(r51);
  mpi_conv_51to64(r64, r51);
  mpi64_print("  x2 = 0x", r64, 4);
  mpi51_from_vec_2x1w(r51, x2z2, NLMB51, 0);
  mpi51_carry_prop(r51);
  mpi_conv_51to64(r64, r51);
  mpi64_print("  z2 = 0x", r64, 4);
#endif   

  puts("");

  // ---------------------------------------------------------------------------

  printf("- mon varbase mul 1x2x1w:");

  uint64_t k64[4] = { 0x9D7C52F06BE346A5ULL, 0xDD5E46824B15163BULL, \
    0x185AFCC10A4C1462ULL, 0xC49A44BA44226A50ULL };
  uint64_t x64[4] = { 0xDB3030586768DBE6ULL, 0x7C5FB124A4C19435ULL, \
    0x3B35B326EC246672ULL, 0x4C1CABD0A603A910ULL };

  LOAD_CACHE(mon_mul_varbase_1x2x1w(r64, k64, x64), 10);
  MEASURE_CYCLES(mon_mul_varbase_1x2x1w(r64, k64, x64), 50);
  printf(" #inst = %lld\n", diff_cycles);

#if DEBUG
  // R := 0x5285A2775507B454F7711C4903CFEC324F088DF24DEA948E90C6E99D3755DAC3;
  mpi64_print("  R  = 0x", r64, 4);
#endif  

  puts("**************************************************************************\n");
}

void test_ecdh()
{
  puts("\n**************************************************************************");
  puts("ECDH CORRECTNESS TEST:");

  // RFC7748 test vectors
  static uint32_t RFC7748_A[8] = { 
    0x0a6d0777, 0x7da51873, 0x72c1163c, 0x4566b251, 
    0x872f4cdf, 0x2a99c0eb, 0xa5fb77b1, 0x2a2cb91d };
  static uint32_t RFC7748_B[8] = {
    0x7e08ab5d, 0x4b8a4a62, 0x8b7fe179, 0xe60e8083, 
    0x29b13b6f, 0xfdb61826, 0x278b2f1c, 0xebe088ff };

  union tvec { uint32_t t32[8]; uint64_t t64[4]; };
  union tvec sk_a, sk_b, pk_a, pk_b, ss_a, ss_b;
  static union tvec base_pt = { 9 };

  puts("--------------------------------------------------------------------------");
  puts("X25519 1x4x1w: (Alice <---> Bob, RFC7748 test vectors)");

  memcpy(sk_a.t32, RFC7748_A, 32);
  memcpy(sk_b.t32, RFC7748_B, 32);

  puts("\n- Private key:");
  mpi32_print("  Alice: ", sk_a.t32, 8);
  mpi32_print("  Bob  : ", sk_b.t32, 8);

  mon_mul_varbase_1x4x1w(pk_a.t32, sk_a.t32, base_pt.t32);
  mon_mul_varbase_1x4x1w(pk_b.t32, sk_b.t32, base_pt.t32);

  puts("\n- Public key:");
  mpi32_print("  Alice: ", pk_a.t32, 8);
  mpi32_print("  Bob  : ", pk_b.t32, 8);

  mon_mul_varbase_1x4x1w(ss_a.t32, sk_a.t32, pk_b.t32);
  mon_mul_varbase_1x4x1w(ss_b.t32, sk_b.t32, pk_a.t32);

  puts("\n- Shared secret:");
  mpi32_print("  Alice: ", ss_a.t32, 8);
  mpi32_print("  Bob  : ", ss_b.t32, 8);

  puts("");

  // ---------------------------------------------------------------------------
  puts("X25519 1x4x1w: (Carol <---> Dave, random test vectors)");

  rand_bytes(sk_a.t32, 32);
  rand_bytes(sk_b.t32, 32);

  puts("\n- Private key:");
  mpi32_print("  Carol: ", sk_a.t32, 8);
  mpi32_print("  Dave : ", sk_b.t32, 8);

  mon_mul_varbase_1x4x1w(pk_a.t32, sk_a.t32, base_pt.t32);
  mon_mul_varbase_1x4x1w(pk_b.t32, sk_b.t32, base_pt.t32);

  puts("\n- Public key:");
  mpi32_print("  Carol: ", pk_a.t32, 8);
  mpi32_print("  Dave : ", pk_b.t32, 8);

  mon_mul_varbase_1x4x1w(ss_a.t32, sk_a.t32, pk_b.t32);
  mon_mul_varbase_1x4x1w(ss_b.t32, sk_b.t32, pk_a.t32);

  puts("\n- Shared secret:");
  mpi32_print("  Carol: ", ss_a.t32, 8);
  mpi32_print("  Dave : ", ss_b.t32, 8);

  puts("");

  puts("--------------------------------------------------------------------------");
  puts("X25519 1x2x1w: (Alice <---> Bob, RFC7748 test vectors)");

  memcpy(sk_a.t64, RFC7748_A, 32);
  memcpy(sk_b.t64, RFC7748_B, 32);

  puts("\n- Private key:");
  mpi64_print("  Alice: ", sk_a.t64, 4);
  mpi64_print("  Bob  : ", sk_b.t64, 4);

  mon_mul_varbase_1x2x1w(pk_a.t64, sk_a.t64, base_pt.t64);
  mon_mul_varbase_1x2x1w(pk_b.t64, sk_b.t64, base_pt.t64);

  puts("\n- Public key:");
  mpi64_print("  Alice: ", pk_a.t64, 4);
  mpi64_print("  Bob  : ", pk_b.t64, 4);

  mon_mul_varbase_1x2x1w(ss_a.t64, sk_a.t64, pk_b.t64);
  mon_mul_varbase_1x2x1w(ss_b.t64, sk_b.t64, pk_a.t64);

  puts("\n- Shared secret:");
  mpi64_print("  Alice: ", ss_a.t64, 4);
  mpi64_print("  Bob  : ", ss_b.t64, 4);

  puts("");

  // ---------------------------------------------------------------------------
  puts("X25519 1x2x1w: (Carol <---> Dave, random test vectors)");

  rand_bytes(sk_a.t64, 32);
  rand_bytes(sk_b.t64, 32);

  puts("\n- Private key:");
  mpi64_print("  Carol: ", sk_a.t64, 4);
  mpi64_print("  Dave : ", sk_b.t64, 4);

  mon_mul_varbase_1x2x1w(pk_a.t64, sk_a.t64, base_pt.t64);
  mon_mul_varbase_1x2x1w(pk_b.t64, sk_b.t64, base_pt.t64);

  puts("\n- Public key:");
  mpi64_print("  Carol: ", pk_a.t64, 4);
  mpi64_print("  Dave : ", pk_b.t64, 4);

  mon_mul_varbase_1x2x1w(ss_a.t64, sk_a.t64, pk_b.t64);
  mon_mul_varbase_1x2x1w(ss_b.t64, sk_b.t64, pk_a.t64);

  puts("\n- Shared secret:");
  mpi64_print("  Carol: ", ss_a.t64, 4);
  mpi64_print("  Dave : ", ss_b.t64, 4);

  puts("**************************************************************************\n");
}

int main()
{
  // test_gfp_arith();
  // test_ise();
  test_curve_arith();
  test_ecdh();

  return 0;
}
