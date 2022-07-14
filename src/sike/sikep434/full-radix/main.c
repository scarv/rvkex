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


void test_fp()
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  int i;

  // a := 0x0003456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;
  uint64_t a[NLMB64] = {  0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL,
                          0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL, 
                          0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL, 
                          0x0003456789ABCDEFULL };
  // b := 0x0003CDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF01234567;
  uint64_t b[NLMB64] = {  0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL,
                          0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL, 
                          0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL, 
                          0x0003CDEF01234567ULL };
  uint64_t z[NLMB64*2], r[NLMB64];

  puts("\n**************************************************************************");
  puts("SCALAR FP ARITH:\n");

  printf("- mp mul v0 sw:");

  LOAD_CACHE(mp_mul_v0_sw(z, a, b), 100);
  MEASURE_CYCLES(mp_mul_v0_sw(z, a, b), 1000);
  printf("       #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0xC71D855A44CD3BEDA4E7F8313B9FA5AA82B26B0832720F67607CDDDF294479243E4750B62016E\
          2E11C11C38D16E94C9DF9DC36640DBB99F02F53956C58E4B033518922956212467673BEAFBE6B3F\
          DCB995F43CE7746D72FCB829CA107D9B093FDA5F573986C89F82FC94E4629;
  mpi64_print("  r  = 0x", z, NLMB64*2);
  memset(z, 0, sizeof(uint64_t)*NLMB64*2);
#endif

  printf("- mp mul v1 sw:");

  LOAD_CACHE(mp_mul_v1_sw(z, a, b), 100);
  MEASURE_CYCLES(mp_mul_v1_sw(z, a, b), 1000);
  printf("       #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0xC71D855A44CD3BEDA4E7F8313B9FA5AA82B26B0832720F67607CDDDF294479243E4750B62016E\
          2E11C11C38D16E94C9DF9DC36640DBB99F02F53956C58E4B033518922956212467673BEAFBE6B3F\
          DCB995F43CE7746D72FCB829CA107D9B093FDA5F573986C89F82FC94E4629;
  mpi64_print("  r  = 0x", z, NLMB64*2);
  memset(z, 0, sizeof(uint64_t)*NLMB64*2);
#endif

  // ---------------------------------------------------------------------------

  printf("- rdc mont v0 sw:");

  mp_mul_v0_sw(z, a, b);

  LOAD_CACHE(rdc_mont_v0_sw(r, z), 100);
  MEASURE_CYCLES(rdc_mont_v0_sw(r, z), 1000);
  printf("     #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x147173547FF63D0B52AB864DF1D570AF09061B91AC6FE5B8A6CCE68DD6D2D6BFF0C770842C494\
          08C8AF46BF03037800688DADCB8D60EF;
  mpi64_print("  r  = 0x", r, NLMB64);
  memset(z, 0, sizeof(uint64_t)*NLMB64*2);
  memset(r, 0, sizeof(uint64_t)*NLMB64);
#endif 

  puts("**************************************************************************\n");
}

int main()
{
  test_fp();

  return 0;
}