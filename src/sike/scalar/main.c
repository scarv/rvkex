#include "share.h"
#include "config.h"
#include "rdtsc.h"
#include "fp.h"


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

  // a := 0x0003456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;
  uint64_t a64[7] = { 0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL,
                      0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL, 
                      0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL, 
                      0x0003456789ABCDEFULL };
  // b := 0x0003CDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF01234567;
  uint64_t b64[7] = { 0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL,
                      0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL, 
                      0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL, 
                      0x0003CDEF01234567ULL };
  uint64_t a56[NLMB56], b56[NLMB56], z56[NLMB56*2], z64[NLMB56*2], r56[NLMB56], r64[NLMB56];

  mpi_conv_64to56(a56, a64);
  mpi_conv_64to56(b56, b64);

  puts("\n**************************************************************************");
  puts("SCALAR FP ARITH 1w:\n");

  printf("- gfp mul 1w v0:");

  LOAD_CACHE(mp_mul_1w_v0(z56, a56, b56), 100);
  MEASURE_CYCLES(mp_mul_1w_v0(z56, a56, b56), 1000);
  printf("      #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0xC71D855A44CD3BEDA4E7F8313B9FA5AA82B26B0832720F67607CDDDF294479243E4750B62016E\
          2E11C11C38D16E94C9DF9DC36640DBB99F02F53956C58E4B033518922956212467673BEAFBE6B3F\
          DCB995F43CE7746D72FCB829CA107D9B093FDA5F573986C89F82FC94E4629;
  mpi56_carry_prop_((int64_t *)z56);
  mpi_conv_56to64_(z64, z56, NLMB56*2, NLMB56*2);
  mpi64_print("  r  = 0x", z64, 7*2);
  memset(z56, 0, sizeof(uint64_t)*NLMB56*2);
#endif 

  printf("- gfp mul 1w v1:");

  LOAD_CACHE(mp_mul_1w_v1(z56, a56, b56), 100);
  MEASURE_CYCLES(mp_mul_1w_v1(z56, a56, b56), 1000);
  printf("      #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0xC71D855A44CD3BEDA4E7F8313B9FA5AA82B26B0832720F67607CDDDF294479243E4750B62016E\
          2E11C11C38D16E94C9DF9DC36640DBB99F02F53956C58E4B033518922956212467673BEAFBE6B3F\
          DCB995F43CE7746D72FCB829CA107D9B093FDA5F573986C89F82FC94E4629;
  mpi56_carry_prop_((int64_t *)z56);
  mpi_conv_56to64_(z64, z56, NLMB56*2, NLMB56*2);
  mpi64_print("  r  = 0x", z64, 7*2);
  memset(z56, 0, sizeof(uint64_t)*NLMB56*2);
#endif 

  printf("- gfp mul 1w v2:");

  LOAD_CACHE(mp_mul_1w_v2(z56, a56, b56), 100);
  MEASURE_CYCLES(mp_mul_1w_v2(z56, a56, b56), 1000);
  printf("      #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0xC71D855A44CD3BEDA4E7F8313B9FA5AA82B26B0832720F67607CDDDF294479243E4750B62016E\
          2E11C11C38D16E94C9DF9DC36640DBB99F02F53956C58E4B033518922956212467673BEAFBE6B3F\
          DCB995F43CE7746D72FCB829CA107D9B093FDA5F573986C89F82FC94E4629;
  mpi56_carry_prop_((int64_t *)z56);
  mpi_conv_56to64_(z64, z56, NLMB56*2, NLMB56*2);
  mpi64_print("  r  = 0x", z64, 7*2);
  memset(z56, 0, sizeof(uint64_t)*NLMB56*2);
#endif 

  printf("- gfp mul 1w v0 ise:");

  LOAD_CACHE(mp_mul_1w_v0_ise(z56, a56, b56), 100);
  MEASURE_CYCLES(mp_mul_1w_v0_ise(z56, a56, b56), 1000);
  printf("  #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0xC71D855A44CD3BEDA4E7F8313B9FA5AA82B26B0832720F67607CDDDF294479243E4750B62016E\
          2E11C11C38D16E94C9DF9DC36640DBB99F02F53956C58E4B033518922956212467673BEAFBE6B3F\
          DCB995F43CE7746D72FCB829CA107D9B093FDA5F573986C89F82FC94E4629;
  mpi56_carry_prop_((int64_t *)z56);
  mpi_conv_56to64_(z64, z56, NLMB56*2, NLMB56*2);
  mpi64_print("  r  = 0x", z64, 7*2);
  memset(z56, 0, sizeof(uint64_t)*NLMB56*2);
#endif 

  printf("- gfp mul 1w v1 ise:");

  LOAD_CACHE(mp_mul_1w_v1_ise(z56, a56, b56), 100);
  MEASURE_CYCLES(mp_mul_1w_v1_ise(z56, a56, b56), 1000);
  printf("  #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0xC71D855A44CD3BEDA4E7F8313B9FA5AA82B26B0832720F67607CDDDF294479243E4750B62016E\
          2E11C11C38D16E94C9DF9DC36640DBB99F02F53956C58E4B033518922956212467673BEAFBE6B3F\
          DCB995F43CE7746D72FCB829CA107D9B093FDA5F573986C89F82FC94E4629;
  mpi56_carry_prop_((int64_t *)z56);
  mpi_conv_56to64_(z64, z56, NLMB56*2, NLMB56*2);
  mpi64_print("  r  = 0x", z64, 7*2);
  memset(z56, 0, sizeof(uint64_t)*NLMB56*2);
#endif 

  puts("");

  // ---------------------------------------------------------------------------

  printf("- rdc mont 1w v0:");

  mp_mul_1w_v2(z56, a56, b56);

  LOAD_CACHE(rdc_mont_1w_v0(r56, z56), 100);
  MEASURE_CYCLES(rdc_mont_1w_v0(r56, z56), 1000);
  printf("     #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x147173547FF63D0B52AB864DF1D570AF09061B91AC6FE5B8A6CCE68DD6D2D6BFF0C770842C494\
          08C8AF46BF03037800688DADCB8D60EF;
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 7);
  memset(z56, 0, sizeof(uint64_t)*NLMB56*2);
  memset(r56, 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("- rdc mont 1w v0 ise:");

  mp_mul_1w_v2(z56, a56, b56);

  LOAD_CACHE(rdc_mont_1w_v0_ise(r56, z56), 100);
  MEASURE_CYCLES(rdc_mont_1w_v0_ise(r56, z56), 1000);
  printf(" #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x147173547FF63D0B52AB864DF1D570AF09061B91AC6FE5B8A6CCE68DD6D2D6BFF0C770842C494\
          08C8AF46BF03037800688DADCB8D60EF;
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 7);
  memset(z56, 0, sizeof(uint64_t)*NLMB56*2);
  memset(r56, 0, sizeof(uint64_t)*NLMB56);
#endif 

  puts("**************************************************************************\n");
}

int main()
{
  test_fp();

  return 0;
}