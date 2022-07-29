#include "share.h"
#include "rdtsc.h"
#include "fp.h"
#include "fpx.h"
#include "curve.h"
#include "sidh.h"
#include "sike.h"
#include "random.h"

// macros for measuring CPU cycles

#define LOAD_CACHE(X, ITER) for (i = 0; i < (ITER); i++) (X)

#define MEASURE_CYCLES(X, ITER)                    \
  start_cycles = rdtsc();                          \
  for (i = 0; i < (ITER); i++) (X);                \
  end_cycles = rdtsc();                            \
  diff_cycles = (end_cycles-start_cycles)/(ITER)


void mpi_conv_56to64_(uint64_t *r, const uint64_t *a, int rlen, int alen)
{
  int i, j, bits_in_word, bits_to_shift;
  uint64_t word;

  i = j = 0;
  bits_in_word = bits_to_shift = 0;
  word = 0;
  while ((i < rlen) && (j < alen)) {
    word |= (a[j] << bits_in_word);
    bits_to_shift = (64 - bits_in_word);
    bits_in_word += 56;
    if (bits_in_word >= 64) {
      r[i++] = word;
      word = ((bits_to_shift > 0) ? (a[j] >> bits_to_shift) : 0);
      bits_in_word = ((bits_to_shift > 0) ? (56 - bits_to_shift) : 0);
    }
    j++;
  }
  if (i < rlen) r[i++] = word;
  for (; i < rlen; i++) r[i] = 0;
}

void mpi56_carry_prop_(int64_t *a)
{
  for (int i = 0; i < 2*NLMB56-1; i ++) {
    a[i+1] += a[i] >> 56;
    a[i]   &= MASK56;
  }
} 

void test_fp()
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  int i;

  // a := 0x0080456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;
  uint64_t a64[10] = { 0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL,
                       0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL, 
                       0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL, 
                       0x0123456789ABCDEFULL, 0x0080456789ABCDEFULL, };
  // b := 0x00805DEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF01234567;
  uint64_t b64[10] = { 0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL,
                       0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL, 
                       0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL, 
                       0x89ABCDEF01234567ULL, 0x00805DEF01234567ULL, };
  uint64_t a56[NLMB56], b56[NLMB56], z56[NLMB56*2], z64[NLMB56*2], r56[NLMB56], r64[NLMB56];

  mpi_conv_64to56(a56, a64);
  mpi_conv_64to56(b56, b64);

  printf("\n**************************************************************************\n");
  printf("FP ARITH:\n");

  printf("- mp mul v0 ise:");

  LOAD_CACHE(mp_mul_v0_ise(z56, a56, b56), 100);
  MEASURE_CYCLES(mp_mul_v0_ise(z56, a56, b56), 1000);
  printf("      #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop_((int64_t *)z56);
  mpi_conv_56to64_(z64, z56, NLMB56*2, NLMB56*2);
  mpi64_print("  r  = 0x", z64, 10*2);
  memset(z56, 0, sizeof(uint64_t)*NLMB56*2);
#endif 

  // ---------------------------------------------------------------------------

  printf("- rdc mont v0 ise:");

  mp_mul_v0_ise(z56, a56, b56);

  LOAD_CACHE(rdc_mont_v0_ise(r56, z56), 100);
  MEASURE_CYCLES(rdc_mont_v0_ise(r56, z56), 1000);
  printf("    #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 10);
  memset(z56, 0, sizeof(uint64_t)*NLMB56*2);
  memset(r56, 0, sizeof(uint64_t)*NLMB56);
#endif 

  // ---------------------------------------------------------------------------

  a64[7] = 0x0040456789ABCDEFULL;
  b64[7] = 0x00405DEF01234567ULL;

  mpi_conv_64to56(a56, a64);
  mpi_conv_64to56(b56, b64);

  // ---------------------------------------------------------------------------

  printf("- fp add v0 ise:");

  LOAD_CACHE(fpadd_v0_ise(r56, a56, b56), 100);
  MEASURE_CYCLES(fpadd_v0_ise(r56, a56, b56), 1000);
  printf("      #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 10);
  fpadd_v0_ise(r56, a56, r56);
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 10);
  memset(r56, 0, sizeof(uint64_t)*NLMB56);  
#endif 

  // ---------------------------------------------------------------------------

  printf("- mp sub p2 v0 ise:");

  LOAD_CACHE(mp_sub_p2_v0_ise(r56, a56, b56), 100);
  MEASURE_CYCLES(mp_sub_p2_v0_ise(r56, a56, b56), 1000);
  printf("   #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 10);
  memset(r56, 0, sizeof(uint64_t)*NLMB56); 
#endif

  printf("- mp sub p4 v0 ise:");

  LOAD_CACHE(mp_sub_p4_v0_ise(r56, a56, b56), 100);
  MEASURE_CYCLES(mp_sub_p4_v0_ise(r56, a56, b56), 1000);
  printf("   #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 10);
  memset(r56, 0, sizeof(uint64_t)*NLMB56); 
#endif

  printf("- fp sub v0 ise:");

  LOAD_CACHE(fpsub_v0_ise(r56, a56, b56), 100);
  MEASURE_CYCLES(fpsub_v0_ise(r56, a56, b56), 1000);
  printf("      #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 10);
  memset(r56, 0, sizeof(uint64_t)*NLMB56); 
#endif 

  // ---------------------------------------------------------------------------

  printf("- fp crt v0 ise:");

  memcpy(r56, a56, sizeof(uint64_t)*NLMB56);

  LOAD_CACHE(fpcorrection_v0_ise(r56), 100);
  MEASURE_CYCLES(fpcorrection_v0_ise(r56), 1000);
  printf("      #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 10);
  memset(r56, 0, sizeof(uint64_t)*NLMB56); 
#endif

  // ---------------------------------------------------------------------------

  printf("- fp neg v0 ise:");

  memcpy(r56, a56, sizeof(uint64_t)*NLMB56);

  LOAD_CACHE(fpneg_v0_ise(r56), 100);
  MEASURE_CYCLES(fpneg_v0_ise(r56), 1000);
  printf("      #cycle = %lld\n", diff_cycles);

#if DEBUG
  memcpy(r56, a56, sizeof(uint64_t)*NLMB56);
  fpneg_v0_ise(r56);
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 10);
  memset(r56, 0, sizeof(uint64_t)*NLMB56); 
#endif

  // ---------------------------------------------------------------------------

  printf("- fp div2 v0 ise:");

  LOAD_CACHE(fpdiv2_v0_ise(r56, a56), 100);
  MEASURE_CYCLES(fpdiv2_v0_ise(r56, a56), 1000);
  printf("     #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 10);
  memset(r56, 0, sizeof(uint64_t)*NLMB56); 
#endif


  printf("**************************************************************************\n");
}

void test_fpx()
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  int i;

  // a := 0x0080456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;
  uint64_t a64[10] = { 0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL,
                       0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL, 
                       0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL, 
                       0x0123456789ABCDEFULL, 0x0080456789ABCDEFULL, };
  // b := 0x00805DEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF01234567;
  uint64_t b64[10] = { 0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL,
                       0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL, 
                       0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL, 
                       0x89ABCDEF01234567ULL, 0x00805DEF01234567ULL, };
  uint64_t r56[NLMB56], r64[NLMB56];
  f2elm_t  r, a; 

  mpi_conv_64to56(a[0], a64);
  mpi_conv_64to56(a[1], b64);

  printf("\n**************************************************************************\n");
  printf("FP2 ARITH:\n");

  printf("- fp2 mul v0:");

  LOAD_CACHE(fp2mul_mont_v0(r, a, a), 10);
  MEASURE_CYCLES(fp2mul_mont_v0(r, a, a), 100);
  printf("         #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(r[0]);
  mpi_conv_56to64(r64, r[0]);
  mpi64_print("  r0 = 0x", r64, 10);
  memset(r[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(r[1]);
  mpi_conv_56to64(r64, r[1]);
  mpi64_print("  r1 = 0x", r64, 10);
  memset(r[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("- fp2 mul v1:");

  LOAD_CACHE(fp2mul_mont_v1(r, a, a), 10);
  MEASURE_CYCLES(fp2mul_mont_v1(r, a, a), 100);
  printf("         #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(r[0]);
  mpi_conv_56to64(r64, r[0]);
  mpi64_print("  r0 = 0x", r64, 10);
  memset(r[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(r[1]);
  mpi_conv_56to64(r64, r[1]);
  mpi64_print("  r1 = 0x", r64, 10);
  memset(r[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("");

  // ---------------------------------------------------------------------------

  printf("- fp2 sqr v0:");

  LOAD_CACHE(fp2sqr_mont_v0(r, a), 10);
  MEASURE_CYCLES(fp2sqr_mont_v0(r, a), 100);
  printf("         #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(r[0]);
  mpi_conv_56to64(r64, r[0]);
  mpi64_print("  r0 = 0x", r64, 10);
  memset(r[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(r[1]);
  mpi_conv_56to64(r64, r[1]);
  mpi64_print("  r1 = 0x", r64, 10);
  memset(r[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("- fp2 sqr v1:");

  LOAD_CACHE(fp2sqr_mont_v1(r, a), 10);
  MEASURE_CYCLES(fp2sqr_mont_v1(r, a), 100);
  printf("         #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(r[0]);
  mpi_conv_56to64(r64, r[0]);
  mpi64_print("  r0 = 0x", r64, 10);
  memset(r[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(r[1]);
  mpi_conv_56to64(r64, r[1]);
  mpi64_print("  r1 = 0x", r64, 10);
  memset(r[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("");

// ---------------------------------------------------------------------------

  printf("- fp2 add:");

  LOAD_CACHE(fp2add(r, a, a), 10);
  MEASURE_CYCLES(fp2add(r, a, a), 100);
  printf("            #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(r[0]);
  mpi_conv_56to64(r64, r[0]);
  mpi64_print("  r0 = 0x", r64, 10);
  memset(r[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(r[1]);
  mpi_conv_56to64(r64, r[1]);
  mpi64_print("  r1 = 0x", r64, 10);
  memset(r[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("");

  // ---------------------------------------------------------------------------

  printf("- fp2 sub:");

  LOAD_CACHE(fp2sub(r, a, a), 10);
  MEASURE_CYCLES(fp2sub(r, a, a), 100);
  printf("            #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(r[0]);
  mpi_conv_56to64(r64, r[0]);
  mpi64_print("  r0 = 0x", r64, 10);
  memset(r[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(r[1]);
  mpi_conv_56to64(r64, r[1]);
  mpi64_print("  r1 = 0x", r64, 10);
  memset(r[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("");

printf("**************************************************************************\n");
}

void test_curve()
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  int i;

  point_proj P, Q, PQ;
  f2elm_t A24plus, C24, A24minus, coeff[3], A24, XPQ, ZPQ;
  const felm_t mont_Rx4 = {
    0x0000000001D0B1, 0x00000000000000, 0x00000000000000, 0x0D000000000000, 
    0x2604AEE67E5999, 0xE3DCE440377525, 0x2737CCF17AFC17, 0x00017F9B77DD48, };
  uint64_t r64[NLMB56];

  // initialization
  memcpy(&P.X[0], &A_gen[       0], sizeof(uint64_t)*NLMB56); // XPA0
  memcpy(&P.X[1], &A_gen[  NLMB56], sizeof(uint64_t)*NLMB56); // XPA1
  memcpy(&P.Z[0], &A_gen[2*NLMB56], sizeof(uint64_t)*NLMB56); // XQA0
  memcpy(&P.Z[1], &A_gen[3*NLMB56], sizeof(uint64_t)*NLMB56); // XQA1
  memset(&Q.X[0], 0, sizeof(uint64_t)*NLMB56);                //    0
  memset(&Q.X[1], 0, sizeof(uint64_t)*NLMB56);                //    0
  memset(&Q.Z[0], 0, sizeof(uint64_t)*NLMB56);                //    0
  memset(&Q.Z[1], 0, sizeof(uint64_t)*NLMB56);                //    0
  memcpy(&A24plus[0], mont_R, sizeof(uint64_t)*NLMB56);       //    1
  memset(&A24plus[1],      0, sizeof(uint64_t)*NLMB56);       //    0
  memcpy(&A24minus[0], mont_Rx4, sizeof(uint64_t)*NLMB56);    //    4
  memset(&A24minus[1],        0, sizeof(uint64_t)*NLMB56);    //    0
  memcpy(&C24[0], mont_Rx4, sizeof(uint64_t)*NLMB56);         //    4
  memset(&C24[1],        0, sizeof(uint64_t)*NLMB56);         //    0

  printf("\n**************************************************************************\n");
  printf("MONTGOMERY CURVE ARITH:\n");

  printf("- xDBL v0:");

  LOAD_CACHE(xDBL_v0(&P, &Q, A24plus, C24), 10);
  MEASURE_CYCLES(xDBL_v0(&P, &Q, A24plus, C24), 100);
  printf("            #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(Q.X[0]);
  mpi_conv_56to64(r64, Q.X[0]);
  mpi64_print("  XQ0 = 0x", r64, 10);
  memset(&Q.X[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.X[1]);
  mpi_conv_56to64(r64, Q.X[1]);
  mpi64_print("  XQ1 = 0x", r64, 10);
  memset(&Q.X[1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.Z[0]);
  mpi_conv_56to64(r64, Q.Z[0]);
  mpi64_print("  ZQ0 = 0x", r64, 10);
  memset(&Q.Z[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.Z[1]);
  mpi_conv_56to64(r64, Q.Z[1]);
  mpi64_print("  ZQ1 = 0x", r64, 10);
  memset(&Q.Z[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("- xDBL v1:");

  LOAD_CACHE(xDBL_v1(&P, &Q, A24plus, C24), 10);
  MEASURE_CYCLES(xDBL_v1(&P, &Q, A24plus, C24), 100);
  printf("            #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(Q.X[0]);
  mpi_conv_56to64(r64, Q.X[0]);
  mpi64_print("  XQ0 = 0x", r64, 10);
  memset(&Q.X[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.X[1]);
  mpi_conv_56to64(r64, Q.X[1]);
  mpi64_print("  XQ1 = 0x", r64, 10);
  memset(&Q.X[1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.Z[0]);
  mpi_conv_56to64(r64, Q.Z[0]);
  mpi64_print("  ZQ0 = 0x", r64, 10);
  memset(&Q.Z[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.Z[1]);
  mpi_conv_56to64(r64, Q.Z[1]);
  mpi64_print("  ZQ1 = 0x", r64, 10);
  memset(&Q.Z[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("");

  // ---------------------------------------------------------------------------   

  printf("- xTPL v0:");

  LOAD_CACHE(xTPL_v0(&P, &Q, A24minus, A24plus), 10);
  MEASURE_CYCLES(xTPL_v0(&P, &Q, A24minus, A24plus), 100);
  printf("            #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(Q.X[0]);
  mpi_conv_56to64(r64, Q.X[0]);
  mpi64_print("  XQ0 = 0x", r64, 10);
  memset(&Q.X[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.X[1]);
  mpi_conv_56to64(r64, Q.X[1]);
  mpi64_print("  XQ1 = 0x", r64, 10);
  memset(&Q.X[1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.Z[0]);
  mpi_conv_56to64(r64, Q.Z[0]);
  mpi64_print("  ZQ0 = 0x", r64, 10);
  memset(&Q.Z[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.Z[1]);
  mpi_conv_56to64(r64, Q.Z[1]);
  mpi64_print("  ZQ1 = 0x", r64, 10);
  memset(&Q.Z[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("- xTPL v1:");

  LOAD_CACHE(xTPL_v1(&P, &Q, A24minus, A24plus), 10);
  MEASURE_CYCLES(xTPL_v1(&P, &Q, A24minus, A24plus), 100);
  printf("            #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(Q.X[0]);
  mpi_conv_56to64(r64, Q.X[0]);
  mpi64_print("  XQ0 = 0x", r64, 10);
  memset(&Q.X[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.X[1]);
  mpi_conv_56to64(r64, Q.X[1]);
  mpi64_print("  XQ1 = 0x", r64, 10);
  memset(&Q.X[1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.Z[0]);
  mpi_conv_56to64(r64, Q.Z[0]);
  mpi64_print("  ZQ0 = 0x", r64, 10);
  memset(&Q.Z[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.Z[1]);
  mpi_conv_56to64(r64, Q.Z[1]);
  mpi64_print("  ZQ1 = 0x", r64, 10);
  memset(&Q.Z[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("");

  // ---------------------------------------------------------------------------   

  printf("- get_4_isog v0:");

  LOAD_CACHE(get_4_isog_v0(&P, A24plus, C24, coeff), 10);
  MEASURE_CYCLES(get_4_isog_v0(&P, A24plus, C24, coeff), 100);
  printf("      #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(A24plus[0]);
  mpi_conv_56to64(r64, A24plus[0]);
  mpi64_print(" A240 = 0x", r64, 10);
  memset(&A24plus[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(A24plus[1]);
  mpi_conv_56to64(r64, A24plus[1]);
  mpi64_print(" A241 = 0x", r64, 10);
  memset(&A24plus[1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(C24[0]);
  mpi_conv_56to64(r64, C24[0]);
  mpi64_print(" C240 = 0x", r64, 10);
  memset(&C24[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(C24[1]);
  mpi_conv_56to64(r64, C24[1]);
  mpi64_print(" C241 = 0x", r64, 10);
  memset(&C24[1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[0][0]);
  mpi_conv_56to64(r64, coeff[0][0]);
  mpi64_print("  K00 = 0x", r64, 10);
  memset(&coeff[0][0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[0][1]);
  mpi_conv_56to64(r64, coeff[0][1]);
  mpi64_print("  K01 = 0x", r64, 10);
  memset(&coeff[0][1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[1][0]);
  mpi_conv_56to64(r64, coeff[1][0]);
  mpi64_print("  K10 = 0x", r64, 10);
  memset(&coeff[1][0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[1][1]);
  mpi_conv_56to64(r64, coeff[1][1]);
  mpi64_print("  K11 = 0x", r64, 10);
  memset(&coeff[1][1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[2][0]);
  mpi_conv_56to64(r64, coeff[2][0]);
  mpi64_print("  K20 = 0x", r64, 10);
  memset(&coeff[2][0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[2][1]);
  mpi_conv_56to64(r64, coeff[2][1]);
  mpi64_print("  K21 = 0x", r64, 10);
  memset(&coeff[2][1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("- get_4_isog v1:");

  LOAD_CACHE(get_4_isog_v1(&P, A24plus, C24, coeff), 10);
  MEASURE_CYCLES(get_4_isog_v1(&P, A24plus, C24, coeff), 100);
  printf("      #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(A24plus[0]);
  mpi_conv_56to64(r64, A24plus[0]);
  mpi64_print(" A240 = 0x", r64, 10);
  memset(&A24plus[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(A24plus[1]);
  mpi_conv_56to64(r64, A24plus[1]);
  mpi64_print(" A241 = 0x", r64, 10);
  memset(&A24plus[1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(C24[0]);
  mpi_conv_56to64(r64, C24[0]);
  mpi64_print(" C240 = 0x", r64, 10);
  memset(&C24[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(C24[1]);
  mpi_conv_56to64(r64, C24[1]);
  mpi64_print(" C241 = 0x", r64, 10);
  memset(&C24[1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[0][0]);
  mpi_conv_56to64(r64, coeff[0][0]);
  mpi64_print("  K00 = 0x", r64, 10);
  memset(&coeff[0][0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[0][1]);
  mpi_conv_56to64(r64, coeff[0][1]);
  mpi64_print("  K01 = 0x", r64, 10);
  memset(&coeff[0][1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[1][0]);
  mpi_conv_56to64(r64, coeff[1][0]);
  mpi64_print("  K10 = 0x", r64, 10);
  memset(&coeff[1][0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[1][1]);
  mpi_conv_56to64(r64, coeff[1][1]);
  mpi64_print("  K11 = 0x", r64, 10);
  memset(&coeff[1][1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[2][0]);
  mpi_conv_56to64(r64, coeff[2][0]);
  mpi64_print("  K20 = 0x", r64, 10);
  memset(&coeff[2][0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[2][1]);
  mpi_conv_56to64(r64, coeff[2][1]);
  mpi64_print("  K21 = 0x", r64, 10);
  memset(&coeff[2][1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("");

  // ---------------------------------------------------------------------------   

  printf("- eval_4_isog v0:");

  LOAD_CACHE(eval_4_isog_v0(&P, coeff), 10);
  MEASURE_CYCLES(eval_4_isog_v0(&P, coeff), 100);
  printf("     #cycle = %lld\n", diff_cycles);

#if DEBUG
  // initialization
  memcpy(&P.X[0], &A_gen[       0], sizeof(uint64_t)*NLMB56); // XPA0
  memcpy(&P.X[1], &A_gen[  NLMB56], sizeof(uint64_t)*NLMB56); // XPA1
  memcpy(&P.Z[0], &A_gen[2*NLMB56], sizeof(uint64_t)*NLMB56); // XQA0
  memcpy(&P.Z[1], &A_gen[3*NLMB56], sizeof(uint64_t)*NLMB56); // XQA1
  // computation
  get_4_isog_v0(&P, A24plus, C24, coeff);
  eval_4_isog_v0(&P, coeff);
  // output
  mpi56_carry_prop(P.X[0]);
  mpi_conv_56to64(r64, P.X[0]);
  mpi64_print("  XP0 = 0x", r64, 10);
  mpi56_carry_prop(P.X[1]);
  mpi_conv_56to64(r64, P.X[1]);
  mpi64_print("  XP1 = 0x", r64, 10);
  mpi56_carry_prop(P.Z[0]);
  mpi_conv_56to64(r64, P.Z[0]);
  mpi64_print("  ZP0 = 0x", r64, 10);
  mpi56_carry_prop(P.Z[1]);
  mpi_conv_56to64(r64, P.Z[1]);
  mpi64_print("  ZP1 = 0x", r64, 10);
#endif

  printf("- eval_4_isog v1:");

  LOAD_CACHE(eval_4_isog_v1(&P, coeff), 10);
  MEASURE_CYCLES(eval_4_isog_v1(&P, coeff), 100);
  printf("     #cycle = %lld\n", diff_cycles);

#if DEBUG
  // initialization
  memcpy(&P.X[0], &A_gen[       0], sizeof(uint64_t)*NLMB56); // XPA0
  memcpy(&P.X[1], &A_gen[  NLMB56], sizeof(uint64_t)*NLMB56); // XPA1
  memcpy(&P.Z[0], &A_gen[2*NLMB56], sizeof(uint64_t)*NLMB56); // XQA0
  memcpy(&P.Z[1], &A_gen[3*NLMB56], sizeof(uint64_t)*NLMB56); // XQA1
  // computation
  get_4_isog_v1(&P, A24plus, C24, coeff);
  eval_4_isog_v1(&P, coeff);
  // output
  mpi56_carry_prop(P.X[0]);
  mpi_conv_56to64(r64, P.X[0]);
  mpi64_print("  XP0 = 0x", r64, 10);
  mpi56_carry_prop(P.X[1]);
  mpi_conv_56to64(r64, P.X[1]);
  mpi64_print("  XP1 = 0x", r64, 10);
  mpi56_carry_prop(P.Z[0]);
  mpi_conv_56to64(r64, P.Z[0]);
  mpi64_print("  ZP0 = 0x", r64, 10);
  mpi56_carry_prop(P.Z[1]);
  mpi_conv_56to64(r64, P.Z[1]);
  mpi64_print("  ZP1 = 0x", r64, 10);
#endif

  printf("");

  // ---------------------------------------------------------------------------   

  // initialization
  memcpy(&P.X[0], &A_gen[       0], sizeof(uint64_t)*NLMB56); // XPA0
  memcpy(&P.X[1], &A_gen[  NLMB56], sizeof(uint64_t)*NLMB56); // XPA1
  memcpy(&P.Z[0], &A_gen[2*NLMB56], sizeof(uint64_t)*NLMB56); // XQA0
  memcpy(&P.Z[1], &A_gen[3*NLMB56], sizeof(uint64_t)*NLMB56); // XQA1

  printf("- get_3_isog v0:");

  LOAD_CACHE(get_3_isog_v0(&P, A24minus, A24plus, coeff), 10);
  MEASURE_CYCLES(get_3_isog_v0(&P, A24minus, A24plus, coeff), 100);
  printf("      #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(A24minus[0]);
  mpi_conv_56to64(r64, A24minus[0]);
  mpi64_print("  A-0 = 0x", r64, 10);
  memset(&A24minus[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(A24minus[1]);
  mpi_conv_56to64(r64, A24minus[1]);
  mpi64_print("  A-1 = 0x", r64, 10);
  memset(&A24minus[1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(A24minus[0]);
  mpi_conv_56to64(r64, A24plus[0]);
  mpi64_print("  A+0 = 0x", r64, 10);
  memset(&A24plus[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(A24plus[1]);
  mpi_conv_56to64(r64, A24plus[1]);
  mpi64_print("  A+1 = 0x", r64, 10);
  memset(&A24plus[1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[0][0]);
  mpi_conv_56to64(r64, coeff[0][0]);
  mpi64_print("  K00 = 0x", r64, 10);
  memset(&coeff[0][0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[0][1]);
  mpi_conv_56to64(r64, coeff[0][1]);
  mpi64_print("  K01 = 0x", r64, 10);
  memset(&coeff[0][1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[1][0]);
  mpi_conv_56to64(r64, coeff[1][0]);
  mpi64_print("  K10 = 0x", r64, 10);
  memset(&coeff[1][0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[1][1]);
  mpi_conv_56to64(r64, coeff[1][1]);
  mpi64_print("  K11 = 0x", r64, 10);
  memset(&coeff[1][1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("- get_3_isog v1:");

  LOAD_CACHE(get_3_isog_v1(&P, A24minus, A24plus, coeff), 10);
  MEASURE_CYCLES(get_3_isog_v1(&P, A24minus, A24plus, coeff), 100);
  printf("      #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(A24minus[0]);
  mpi_conv_56to64(r64, A24minus[0]);
  mpi64_print("  A-0 = 0x", r64, 10);
  memset(&A24minus[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(A24minus[1]);
  mpi_conv_56to64(r64, A24minus[1]);
  mpi64_print("  A-1 = 0x", r64, 10);
  memset(&A24minus[1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(A24minus[0]);
  mpi_conv_56to64(r64, A24plus[0]);
  mpi64_print("  A+0 = 0x", r64, 10);
  memset(&A24plus[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(A24plus[1]);
  mpi_conv_56to64(r64, A24plus[1]);
  mpi64_print("  A+1 = 0x", r64, 10);
  memset(&A24plus[1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[0][0]);
  mpi_conv_56to64(r64, coeff[0][0]);
  mpi64_print("  K00 = 0x", r64, 10);
  memset(&coeff[0][0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[0][1]);
  mpi_conv_56to64(r64, coeff[0][1]);
  mpi64_print("  K01 = 0x", r64, 10);
  memset(&coeff[0][1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[1][0]);
  mpi_conv_56to64(r64, coeff[1][0]);
  mpi64_print("  K10 = 0x", r64, 10);
  memset(&coeff[1][0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[1][1]);
  mpi_conv_56to64(r64, coeff[1][1]);
  mpi64_print("  K11 = 0x", r64, 10);
  memset(&coeff[1][1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("- get_3_isog v2:");

  LOAD_CACHE(get_3_isog_v2(&P, A24minus, A24plus, coeff), 10);
  MEASURE_CYCLES(get_3_isog_v2(&P, A24minus, A24plus, coeff), 100);
  printf("      #cycle = %lld\n", diff_cycles);

#if DEBUG
  mpi56_carry_prop(A24minus[0]);
  mpi_conv_56to64(r64, A24minus[0]);
  mpi64_print("  A-0 = 0x", r64, 10);
  memset(&A24minus[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(A24minus[1]);
  mpi_conv_56to64(r64, A24minus[1]);
  mpi64_print("  A-1 = 0x", r64, 10);
  memset(&A24minus[1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(A24minus[0]);
  mpi_conv_56to64(r64, A24plus[0]);
  mpi64_print("  A+0 = 0x", r64, 10);
  memset(&A24plus[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(A24plus[1]);
  mpi_conv_56to64(r64, A24plus[1]);
  mpi64_print("  A+1 = 0x", r64, 10);
  memset(&A24plus[1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[0][0]);
  mpi_conv_56to64(r64, coeff[0][0]);
  mpi64_print("  K00 = 0x", r64, 10);
  memset(&coeff[0][0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[0][1]);
  mpi_conv_56to64(r64, coeff[0][1]);
  mpi64_print("  K01 = 0x", r64, 10);
  memset(&coeff[0][1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[1][0]);
  mpi_conv_56to64(r64, coeff[1][0]);
  mpi64_print("  K10 = 0x", r64, 10);
  memset(&coeff[1][0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(coeff[1][1]);
  mpi_conv_56to64(r64, coeff[1][1]);
  mpi64_print("  K11 = 0x", r64, 10);
  memset(&coeff[1][1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("");

  // ---------------------------------------------------------------------------   

  printf("- eval_3_isog v0:");

  LOAD_CACHE(eval_3_isog_v0(&P, coeff), 10);
  MEASURE_CYCLES(eval_3_isog_v0(&P, coeff), 100);
  printf("     #cycle = %lld\n", diff_cycles);

#if DEBUG
  // initialization
  memcpy(&P.X[0], &A_gen[       0], sizeof(uint64_t)*NLMB56); // XPA0
  memcpy(&P.X[1], &A_gen[  NLMB56], sizeof(uint64_t)*NLMB56); // XPA1
  memcpy(&P.Z[0], &A_gen[2*NLMB56], sizeof(uint64_t)*NLMB56); // XQA0
  memcpy(&P.Z[1], &A_gen[3*NLMB56], sizeof(uint64_t)*NLMB56); // XQA1
  // computation
  get_3_isog_v0(&P, A24minus, A24plus, coeff);
  eval_3_isog_v0(&P, coeff);
  // output
  mpi56_carry_prop(P.X[0]);
  mpi_conv_56to64(r64, P.X[0]);
  mpi64_print("  XP0 = 0x", r64, 10);
  mpi56_carry_prop(P.X[1]);
  mpi_conv_56to64(r64, P.X[1]);
  mpi64_print("  XP1 = 0x", r64, 10);
  mpi56_carry_prop(P.Z[0]);
  mpi_conv_56to64(r64, P.Z[0]);
  mpi64_print("  ZP0 = 0x", r64, 10);
  mpi56_carry_prop(P.Z[1]);
  mpi_conv_56to64(r64, P.Z[1]);
  mpi64_print("  ZP1 = 0x", r64, 10);
#endif

  printf("- eval_3_isog v1:");

  LOAD_CACHE(eval_3_isog_v1(&P, coeff), 10);
  MEASURE_CYCLES(eval_3_isog_v1(&P, coeff), 100);
  printf("     #cycle = %lld\n", diff_cycles);

#if DEBUG
  // initialization
  memcpy(&P.X[0], &A_gen[       0], sizeof(uint64_t)*NLMB56); // XPA0
  memcpy(&P.X[1], &A_gen[  NLMB56], sizeof(uint64_t)*NLMB56); // XPA1
  memcpy(&P.Z[0], &A_gen[2*NLMB56], sizeof(uint64_t)*NLMB56); // XQA0
  memcpy(&P.Z[1], &A_gen[3*NLMB56], sizeof(uint64_t)*NLMB56); // XQA1
  // computation
  get_3_isog_v1(&P, A24minus, A24plus, coeff);
  eval_3_isog_v1(&P, coeff);
  // output
  mpi56_carry_prop(P.X[0]);
  mpi_conv_56to64(r64, P.X[0]);
  mpi64_print("  XP0 = 0x", r64, 10);
  mpi56_carry_prop(P.X[1]);
  mpi_conv_56to64(r64, P.X[1]);
  mpi64_print("  XP1 = 0x", r64, 10);
  mpi56_carry_prop(P.Z[0]);
  mpi_conv_56to64(r64, P.Z[0]);
  mpi64_print("  ZP0 = 0x", r64, 10);
  mpi56_carry_prop(P.Z[1]);
  mpi_conv_56to64(r64, P.Z[1]);
  mpi64_print("  ZP1 = 0x", r64, 10);
#endif

  printf("");

  // ---------------------------------------------------------------------------   

  printf("- xDBLADD v0:");

  LOAD_CACHE(xDBLADD_v0(&P, &Q, XPQ, ZPQ, A24), 10);
  MEASURE_CYCLES(xDBLADD_v0(&P, &Q, XPQ, ZPQ, A24), 100);
  printf("         #cycle = %lld\n", diff_cycles);

#if DEBUG
  // initialization
  memcpy(&P.X[0], &A_gen[       0], sizeof(uint64_t)*NLMB56); // XPA0
  memcpy(&P.X[1], &A_gen[  NLMB56], sizeof(uint64_t)*NLMB56); // XPA1
  memcpy(&P.Z[0], &A_gen[2*NLMB56], sizeof(uint64_t)*NLMB56); // XQA0
  memcpy(&P.Z[1], &A_gen[3*NLMB56], sizeof(uint64_t)*NLMB56); // XQA1
  memcpy(&Q.X[0], &A_gen[4*NLMB56], sizeof(uint64_t)*NLMB56); // XRA0
  memcpy(&Q.X[1], &A_gen[5*NLMB56], sizeof(uint64_t)*NLMB56); // XRA1
  memcpy(&Q.Z[0], &B_gen[4*NLMB56], sizeof(uint64_t)*NLMB56); // XRB0
  memcpy(&Q.Z[1], &B_gen[5*NLMB56], sizeof(uint64_t)*NLMB56); // XRB1
  memcpy(&XPQ[0], &A_gen[       0], sizeof(uint64_t)*NLMB56); // XPA0
  memcpy(&XPQ[1], &A_gen[  NLMB56], sizeof(uint64_t)*NLMB56); // XPA1
  memcpy(&ZPQ[0], &A_gen[2*NLMB56], sizeof(uint64_t)*NLMB56); // XQA0
  memcpy(&ZPQ[1], &A_gen[3*NLMB56], sizeof(uint64_t)*NLMB56); // XQA1
  memcpy(&A24[0], mont_R, sizeof(uint64_t)*NLMB56);           //    1
  memset(&A24[1],      0, sizeof(uint64_t)*NLMB56);           //    0
  // computation
  xDBLADD_v0(&P, &Q, XPQ, ZPQ, A24);
  // output
  mpi56_carry_prop(P.X[0]);
  mpi_conv_56to64(r64, P.X[0]);
  mpi64_print("  XP0 = 0x", r64, 10);
  mpi56_carry_prop(P.X[1]);
  mpi_conv_56to64(r64, P.X[1]);
  mpi64_print("  XP1 = 0x", r64, 10);
  mpi56_carry_prop(P.Z[0]);
  mpi_conv_56to64(r64, P.Z[0]);
  mpi64_print("  ZP0 = 0x", r64, 10);
  mpi56_carry_prop(P.Z[1]);
  mpi_conv_56to64(r64, P.Z[1]);
  mpi64_print("  ZP1 = 0x", r64, 10);
  mpi56_carry_prop(Q.X[0]);
  mpi_conv_56to64(r64, Q.X[0]);
  mpi64_print("  XQ0 = 0x", r64, 10);
  mpi56_carry_prop(Q.X[1]);
  mpi_conv_56to64(r64, Q.X[1]);
  mpi64_print("  XQ1 = 0x", r64, 10);
  mpi56_carry_prop(Q.Z[0]);
  mpi_conv_56to64(r64, Q.Z[0]);
  mpi64_print("  ZQ0 = 0x", r64, 10);
  mpi56_carry_prop(Q.Z[1]);
  mpi_conv_56to64(r64, Q.Z[1]);
  mpi64_print("  ZQ1 = 0x", r64, 10);
#endif

  printf("- xDBLADD v1:");

  LOAD_CACHE(xDBLADD_v1(&P, &Q, XPQ, ZPQ, A24), 10);
  MEASURE_CYCLES(xDBLADD_v1(&P, &Q, XPQ, ZPQ, A24), 100);
  printf("         #cycle = %lld\n", diff_cycles);

#if DEBUG
  // initialization
  memcpy(&P.X[0], &A_gen[       0], sizeof(uint64_t)*NLMB56); // XPA0
  memcpy(&P.X[1], &A_gen[  NLMB56], sizeof(uint64_t)*NLMB56); // XPA1
  memcpy(&P.Z[0], &A_gen[2*NLMB56], sizeof(uint64_t)*NLMB56); // XQA0
  memcpy(&P.Z[1], &A_gen[3*NLMB56], sizeof(uint64_t)*NLMB56); // XQA1
  memcpy(&Q.X[0], &A_gen[4*NLMB56], sizeof(uint64_t)*NLMB56); // XRA0
  memcpy(&Q.X[1], &A_gen[5*NLMB56], sizeof(uint64_t)*NLMB56); // XRA1
  memcpy(&Q.Z[0], &B_gen[4*NLMB56], sizeof(uint64_t)*NLMB56); // XRB0
  memcpy(&Q.Z[1], &B_gen[5*NLMB56], sizeof(uint64_t)*NLMB56); // XRB1
  memcpy(&XPQ[0], &A_gen[       0], sizeof(uint64_t)*NLMB56); // XPA0
  memcpy(&XPQ[1], &A_gen[  NLMB56], sizeof(uint64_t)*NLMB56); // XPA1
  memcpy(&ZPQ[0], &A_gen[2*NLMB56], sizeof(uint64_t)*NLMB56); // XQA0
  memcpy(&ZPQ[1], &A_gen[3*NLMB56], sizeof(uint64_t)*NLMB56); // XQA1
  memcpy(&A24[0], mont_R, sizeof(uint64_t)*NLMB56);           //    1
  memset(&A24[1],      0, sizeof(uint64_t)*NLMB56);           //    0
  // computation
  xDBLADD_v1(&P, &Q, XPQ, ZPQ, A24);
  // output
  mpi56_carry_prop(P.X[0]);
  mpi_conv_56to64(r64, P.X[0]);
  mpi64_print("  XP0 = 0x", r64, 10);
  mpi56_carry_prop(P.X[1]);
  mpi_conv_56to64(r64, P.X[1]);
  mpi64_print("  XP1 = 0x", r64, 10);
  mpi56_carry_prop(P.Z[0]);
  mpi_conv_56to64(r64, P.Z[0]);
  mpi64_print("  ZP0 = 0x", r64, 10);
  mpi56_carry_prop(P.Z[1]);
  mpi_conv_56to64(r64, P.Z[1]);
  mpi64_print("  ZP1 = 0x", r64, 10);
  mpi56_carry_prop(Q.X[0]);
  mpi_conv_56to64(r64, Q.X[0]);
  mpi64_print("  XQ0 = 0x", r64, 10);
  mpi56_carry_prop(Q.X[1]);
  mpi_conv_56to64(r64, Q.X[1]);
  mpi64_print("  XQ1 = 0x", r64, 10);
  mpi56_carry_prop(Q.Z[0]);
  mpi_conv_56to64(r64, Q.Z[0]);
  mpi64_print("  ZQ0 = 0x", r64, 10);
  mpi56_carry_prop(Q.Z[1]);
  mpi_conv_56to64(r64, Q.Z[1]);
  mpi64_print("  ZQ1 = 0x", r64, 10);
#endif

printf("**************************************************************************\n");
}

void test_sidh()
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  int i;

  unsigned char skA[SECRETKEY_A_BYTES], pkA[CRYPTO_PUBLICKEYBYTES];
  unsigned char skB[SECRETKEY_B_BYTES], pkB[CRYPTO_PUBLICKEYBYTES];
  unsigned char ssA[FP2_ENCODED_BYTES], ssB[FP2_ENCODED_BYTES];

  printf("\n**************************************************************************\n");
  printf("SIDH KEY EXCHANGE:\n");

  randombytes(skA, SECRETKEY_A_BYTES);
  randombytes(skB, SECRETKEY_B_BYTES);

  printf("- Alice key gen:");

  LOAD_CACHE(EphemeralKeyGeneration_A(skA, pkA), 1);
  MEASURE_CYCLES(EphemeralKeyGeneration_A(skA, pkA), 1);
  printf("      #cycle = %lld\n", diff_cycles);

  printf("- Bob   key gen:");

  LOAD_CACHE(EphemeralKeyGeneration_B(skB, pkB), 1);
  MEASURE_CYCLES(EphemeralKeyGeneration_B(skB, pkB), 1);
  printf("      #cycle = %lld\n", diff_cycles);

  printf("- Alice shared sec:");

  LOAD_CACHE(EphemeralSecretAgreement_A(skA, pkB, ssA), 1);
  MEASURE_CYCLES(EphemeralSecretAgreement_A(skA, pkB, ssA), 1);
  printf("   #cycle = %lld\n", diff_cycles);

  printf("- Bob   shared sec:");

  LOAD_CACHE(EphemeralSecretAgreement_B(skB, pkA, ssB), 1);
  MEASURE_CYCLES(EphemeralSecretAgreement_B(skB, pkA, ssB), 1);
  printf("   #cycle = %lld\n", diff_cycles);

#if DEBUG 
  printf("\nSKA: ");
  for (i = 0; i < SECRETKEY_A_BYTES; i++) printf("%02X", skA[i]);
  printf("\nSKB: ");
  for (i = 0; i < SECRETKEY_B_BYTES; i++) printf("%02X", skB[i]);
  printf("\nPKA: ");
  for (i = 0; i < CRYPTO_PUBLICKEYBYTES; i++) printf("%02X", pkA[i]);
  printf("\nPKB: ");
  for (i = 0; i < CRYPTO_PUBLICKEYBYTES; i++) printf("%02X", pkB[i]);
  printf("\nSSA: ");
  for (i = 0; i < FP2_ENCODED_BYTES; i++) printf("%02X", ssA[i]);
  printf("\nSSB: ");
  for (i = 0; i < FP2_ENCODED_BYTES; i++) printf("%02X", ssB[i]);
  printf("\n");
#endif

  printf("**************************************************************************\n");
}

void test_sike()
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  int i, wrong = 0;

  unsigned char sk[CRYPTO_SECRETKEYBYTES] = { 0 };
  unsigned char pk[CRYPTO_PUBLICKEYBYTES] = { 0 };
  unsigned char ct[CRYPTO_CIPHERTEXTBYTES] = { 0 };
  unsigned char ss[CRYPTO_BYTES] = { 0 };
  unsigned char ss_[CRYPTO_BYTES] = { 0 };

  printf("\n**************************************************************************\n");
  printf("SIKE KEY ENCAPSULATION:\n");

  crypto_kem_keypair(pk, sk);
  crypto_kem_enc(ct, ss, pk);
  crypto_kem_dec(ss_, ct, sk);

  wrong = memcmp(ss, ss_, CRYPTO_BYTES);

  printf("- Shared secrets:");

  if (wrong == 0) printf("    \x1b[32m EQUAL!\x1b[0m\n");
  else            printf("    \x1b[31m NOT EQUAL!\x1b[0m\n");

  printf("- Keygen:");

  LOAD_CACHE(crypto_kem_keypair(pk, sk), 1);
  MEASURE_CYCLES(crypto_kem_keypair(pk, sk), 1);
  printf("             #cycle = %lld\n", diff_cycles);

  printf("- Encaps:");

  LOAD_CACHE(crypto_kem_enc(ct, ss, pk), 1);
  MEASURE_CYCLES(crypto_kem_enc(ct, ss, pk), 1);
  printf("             #cycle = %lld\n", diff_cycles);

  printf("- Decaps:");

  LOAD_CACHE(crypto_kem_dec(ss_, ct, sk), 1);
  MEASURE_CYCLES(crypto_kem_dec(ss_, ct, sk), 1);
  printf("             #cycle = %lld\n", diff_cycles);

#if DEBUG 
  printf("\nSSA: ");
  for (i = 0; i < CRYPTO_BYTES; i++) printf("%02X", ss[i]);
  printf("\nSSB: ");
  for (i = 0; i < CRYPTO_BYTES; i++) printf("%02X", ss_[i]);
  printf("\n");
#endif 

  printf("**************************************************************************\n");
}

int main() 
{
  test_fp();
  test_fpx();
  test_curve();
  test_sidh();
  test_sike();

  return 0;
}

