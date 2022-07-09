#include "share.h"
#include "config.h"
#include "rdtsc.h"
#include "fp.h"
#include "fpx.h"
#include "curve.h"
#include "sidh.h"


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

  printf("- fp mul 1w v0:");

  LOAD_CACHE(mp_mul_1w_v0(z56, a56, b56), 100);
  MEASURE_CYCLES(mp_mul_1w_v0(z56, a56, b56), 1000);
  printf("       #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0xC71D855A44CD3BEDA4E7F8313B9FA5AA82B26B0832720F67607CDDDF294479243E4750B62016E\
          2E11C11C38D16E94C9DF9DC36640DBB99F02F53956C58E4B033518922956212467673BEAFBE6B3F\
          DCB995F43CE7746D72FCB829CA107D9B093FDA5F573986C89F82FC94E4629;
  mpi56_carry_prop_((int64_t *)z56);
  mpi_conv_56to64_(z64, z56, NLMB56*2, NLMB56*2);
  mpi64_print("  r  = 0x", z64, 7*2);
  memset(z56, 0, sizeof(uint64_t)*NLMB56*2);
#endif 

  printf("- fp mul 1w v1:");

  LOAD_CACHE(mp_mul_1w_v1(z56, a56, b56), 100);
  MEASURE_CYCLES(mp_mul_1w_v1(z56, a56, b56), 1000);
  printf("       #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0xC71D855A44CD3BEDA4E7F8313B9FA5AA82B26B0832720F67607CDDDF294479243E4750B62016E\
          2E11C11C38D16E94C9DF9DC36640DBB99F02F53956C58E4B033518922956212467673BEAFBE6B3F\
          DCB995F43CE7746D72FCB829CA107D9B093FDA5F573986C89F82FC94E4629;
  mpi56_carry_prop_((int64_t *)z56);
  mpi_conv_56to64_(z64, z56, NLMB56*2, NLMB56*2);
  mpi64_print("  r  = 0x", z64, 7*2);
  memset(z56, 0, sizeof(uint64_t)*NLMB56*2);
#endif 

  printf("- fp mul 1w v2:");

  LOAD_CACHE(mp_mul_1w_v2(z56, a56, b56), 100);
  MEASURE_CYCLES(mp_mul_1w_v2(z56, a56, b56), 1000);
  printf("       #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0xC71D855A44CD3BEDA4E7F8313B9FA5AA82B26B0832720F67607CDDDF294479243E4750B62016E\
          2E11C11C38D16E94C9DF9DC36640DBB99F02F53956C58E4B033518922956212467673BEAFBE6B3F\
          DCB995F43CE7746D72FCB829CA107D9B093FDA5F573986C89F82FC94E4629;
  mpi56_carry_prop_((int64_t *)z56);
  mpi_conv_56to64_(z64, z56, NLMB56*2, NLMB56*2);
  mpi64_print("  r  = 0x", z64, 7*2);
  memset(z56, 0, sizeof(uint64_t)*NLMB56*2);
#endif 

  printf("- fp mul 1w v0 ise:");

  LOAD_CACHE(mp_mul_1w_v0_ise(z56, a56, b56), 100);
  MEASURE_CYCLES(mp_mul_1w_v0_ise(z56, a56, b56), 1000);
  printf("   #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0xC71D855A44CD3BEDA4E7F8313B9FA5AA82B26B0832720F67607CDDDF294479243E4750B62016E\
          2E11C11C38D16E94C9DF9DC36640DBB99F02F53956C58E4B033518922956212467673BEAFBE6B3F\
          DCB995F43CE7746D72FCB829CA107D9B093FDA5F573986C89F82FC94E4629;
  mpi56_carry_prop_((int64_t *)z56);
  mpi_conv_56to64_(z64, z56, NLMB56*2, NLMB56*2);
  mpi64_print("  r  = 0x", z64, 7*2);
  memset(z56, 0, sizeof(uint64_t)*NLMB56*2);
#endif 

  printf("- fp mul 1w v1 ise:");

  LOAD_CACHE(mp_mul_1w_v1_ise(z56, a56, b56), 100);
  MEASURE_CYCLES(mp_mul_1w_v1_ise(z56, a56, b56), 1000);
  printf("   #inst = %lld\n", diff_cycles);

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

  mp_mul_1w_v0_ise(z56, a56, b56);

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

  puts("");

  // ---------------------------------------------------------------------------

  printf("- fp add 1w v0:");

  LOAD_CACHE(fpadd_1w_v0(r56, a56, b56), 100);
  MEASURE_CYCLES(fpadd_1w_v0(r56, a56, b56), 1000);
  printf("       #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x2AB183CA02CCDB0D653A98744D2A993425A66281DB60E8F4C2660C4CF13568ACF13568ACF1356\
          8ACF13568ACF13568ACF13568ACF1358
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 7);
  memset(r56, 0, sizeof(uint64_t)*NLMB56);
  // r := 0x3456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF\
          0123456789ABCDEF0123456789ABCDEF
  fpadd_1w_v0(r56, a56, r56);
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 7);
  memset(r56, 0, sizeof(uint64_t)*NLMB56);  
#endif 

  printf("- fp add 1w v0 ise:");

  LOAD_CACHE(fpadd_1w_v0_ise(r56, a56, b56), 100);
  MEASURE_CYCLES(fpadd_1w_v0_ise(r56, a56, b56), 1000);
  printf("   #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x2AB183CA02CCDB0D653A98744D2A993425A66281DB60E8F4C2660C4CF13568ACF13568ACF1356\
          8ACF13568ACF13568ACF13568ACF1358
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 7);
  memset(r56, 0, sizeof(uint64_t)*NLMB56);
  // r := 0x3456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF\
          0123456789ABCDEF0123456789ABCDEF
  fpadd_1w_v0_ise(r56, a56, r56);
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 7);
  memset(r56, 0, sizeof(uint64_t)*NLMB56);  
#endif 

  puts("");

  // ---------------------------------------------------------------------------

  printf("- mp sub p2 1w v0:");

  LOAD_CACHE(mp_sub_p2_1w_v0(r56, a56, b56), 100);
  MEASURE_CYCLES(mp_sub_p2_1w_v0(r56, a56, b56), 1000);
  printf("    #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x3DFB6D6B76F10517037258C12C9346F043068EB39E5CF72FA646E4E8888877777777888888887\
          77777778888888877777777888888886
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 7);
  memset(r56, 0, sizeof(uint64_t)*NLMB56); 
#endif

  printf("- mp sub p2 1w v1:");

  LOAD_CACHE(mp_sub_p2_1w_v1(r56, a56, b56), 100);
  MEASURE_CYCLES(mp_sub_p2_1w_v1(r56, a56, b56), 1000);
  printf("    #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x3DFB6D6B76F10517037258C12C9346F043068EB39E5CF72FA646E4E8888877777777888888887\
          77777778888888877777777888888886
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 7);
  memset(r56, 0, sizeof(uint64_t)*NLMB56); 
#endif

  printf("- mp sub p2 1w v0 ise:");

  LOAD_CACHE(mp_sub_p2_1w_v0_ise(r56, a56, b56), 100);
  MEASURE_CYCLES(mp_sub_p2_1w_v0_ise(r56, a56, b56), 1000);
  printf("#inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x3DFB6D6B76F10517037258C12C9346F043068EB39E5CF72FA646E4E8888877777777888888887\
          77777778888888877777777888888886
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 7);
  memset(r56, 0, sizeof(uint64_t)*NLMB56); 
#endif

  printf("- mp sub p4 1w v0:");

  LOAD_CACHE(mp_sub_p4_1w_v0(r56, a56, b56), 100);
  MEASURE_CYCLES(mp_sub_p4_1w_v0(r56, a56, b56), 1000);
  printf("    #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x847F524E655992B68F6D28F9D09E16690E9594DEB43176E7D5164148888877777777888888887\
          77777778888888877777777888888884
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 7);
  memset(r56, 0, sizeof(uint64_t)*NLMB56); 
#endif

  printf("- mp sub p4 1w v0 ise:");

  LOAD_CACHE(mp_sub_p4_1w_v0_ise(r56, a56, b56), 100);
  MEASURE_CYCLES(mp_sub_p4_1w_v0_ise(r56, a56, b56), 1000);
  printf("#inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x847F524E655992B68F6D28F9D09E16690E9594DEB43176E7D5164148888877777777888888887\
          77777778888888877777777888888884
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 7);
  memset(r56, 0, sizeof(uint64_t)*NLMB56); 
#endif

  printf("- fp sub 1w v0:");

  LOAD_CACHE(fpsub_1w_v0(r56, a56, b56), 100);
  MEASURE_CYCLES(fpsub_1w_v0(r56, a56, b56), 1000);
  printf("       #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x3DFB6D6B76F10517037258C12C9346F043068EB39E5CF72FA646E4E8888877777777888888887\
          77777778888888877777777888888886
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 7);
  memset(r56, 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("- fp sub 1w v0 ise:");

  LOAD_CACHE(fpsub_1w_v0_ise(r56, a56, b56), 100);
  MEASURE_CYCLES(fpsub_1w_v0_ise(r56, a56, b56), 1000);
  printf("   #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x3DFB6D6B76F10517037258C12C9346F043068EB39E5CF72FA646E4E8888877777777888888887\
          77777778888888877777777888888886
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 7);
  memset(r56, 0, sizeof(uint64_t)*NLMB56); 
#endif 

  puts("");

  // ---------------------------------------------------------------------------

  printf("- fp crt 1w v0:");

  memcpy(r56, a56, sizeof(uint64_t)*NLMB56);

  LOAD_CACHE(fpcorrection_1w_v0(r56), 100);
  MEASURE_CYCLES(fpcorrection_1w_v0(r56), 1000);
  printf("       #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x1114862945AAA9426E59107E6AD98855CE8EF58531F4B0361CEECA6ABCDEF0123456789ABCDEF\
          0123456789ABCDEF0123456789ABCDF0
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 7);
  memset(r56, 0, sizeof(uint64_t)*NLMB56); 
#endif

  printf("- fp crt 1w v0 ise:");

  memcpy(r56, a56, sizeof(uint64_t)*NLMB56);

  LOAD_CACHE(fpcorrection_1w_v0_ise(r56), 100);
  MEASURE_CYCLES(fpcorrection_1w_v0_ise(r56), 1000);
  printf("   #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x1114862945AAA9426E59107E6AD98855CE8EF58531F4B0361CEECA6ABCDEF0123456789ABCDEF\
          0123456789ABCDEF0123456789ABCDF0
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 7);
  memset(r56, 0, sizeof(uint64_t)*NLMB56); 
#endif

  puts("");

  // ---------------------------------------------------------------------------

  printf("- fp neg 1w v0:");

  LOAD_CACHE(fpneg_1w_v0(r56), 100);
  MEASURE_CYCLES(fpneg_1w_v0(r56), 1000);
  printf("       #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x122D6C4831899D8D57A4579DE72BDF6697388D9058F58FA5FA78E3C543210FEDCBA9876543210\
          FEDCBA9876543210FEDCBA987654320F
  memcpy(r56, a56, sizeof(uint64_t)*NLMB56);
  fpneg_1w_v0(r56);
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 7);
  memset(r56, 0, sizeof(uint64_t)*NLMB56); 
#endif

  printf("- fp neg 1w v0 ise:");

  memcpy(r56, a56, sizeof(uint64_t)*NLMB56);

  LOAD_CACHE(fpneg_1w_v0_ise(r56), 100);
  MEASURE_CYCLES(fpneg_1w_v0_ise(r56), 1000);
  printf("   #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x122D6C4831899D8D57A4579DE72BDF6697388D9058F58FA5FA78E3C543210FEDCBA9876543210\
          FEDCBA9876543210FEDCBA987654320F
  memcpy(r56, a56, sizeof(uint64_t)*NLMB56);
  fpneg_1w_v0_ise(r56);
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 7);
  memset(r56, 0, sizeof(uint64_t)*NLMB56); 
#endif

  puts("");

  // ---------------------------------------------------------------------------

  printf("- fp div2 1w v0:");

  LOAD_CACHE(fpdiv2_1w_v0(r56, a56), 100);
  MEASURE_CYCLES(fpdiv2_1w_v0(r56, a56), 1000);
  printf("      #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x2BCC35861A099B70FD29F05B87722BE74D0EFDD823E497F725DF13655E6F78091A2B3C4D5E6F7\
          8091A2B3C4D5E6F78091A2B3C4D5E6F7
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 7);
  memset(r56, 0, sizeof(uint64_t)*NLMB56); 
#endif

  printf("- fp div2 1w v0 ise:");

  LOAD_CACHE(fpdiv2_1w_v0_ise(r56, a56), 100);
  MEASURE_CYCLES(fpdiv2_1w_v0_ise(r56, a56), 1000);
  printf("  #inst = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x2BCC35861A099B70FD29F05B87722BE74D0EFDD823E497F725DF13655E6F78091A2B3C4D5E6F7\
          8091A2B3C4D5E6F78091A2B3C4D5E6F7
  mpi56_carry_prop(r56);
  mpi_conv_56to64(r64, r56);
  mpi64_print("  r  = 0x", r64, 7);
  memset(r56, 0, sizeof(uint64_t)*NLMB56); 
#endif

  puts("**************************************************************************\n");
}

void test_fpx()
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
  uint64_t r56[NLMB56], r64[NLMB56];
  f2elm_t  r, a; 

  mpi_conv_64to56(a[0], a64);
  mpi_conv_64to56(a[1], b64);

  puts("\n**************************************************************************");
  puts("SCALAR FP2 ARITH 1w:\n");

  printf("- fp2 mul 1w v0:");

  LOAD_CACHE(fp2mul_mont_v0(r, a, a), 10);
  MEASURE_CYCLES(fp2mul_mont_v0(r, a, a), 100);
  printf("      #inst = %lld\n", diff_cycles);

#if DEBUG
  // r0 = 0x3306B70C7878F4FC445701989C949D34730CD77D27EB6133F6DB088FED9FA1E7A18F5515\
          74C4BD908049D3BCE94A63695F8ADFBECDA8E
  // r1 = 0x5A0F43788B83346DF59A47F91A579A1AC44B40DCDF58B9536321EEBADA5AD7FE18EE1085\
          892811915E8D7E0606F000D11B5B971AC1DF
  mpi56_carry_prop(r[0]);
  mpi_conv_56to64(r64, r[0]);
  mpi64_print("  r0 = 0x", r64, 7);
  memset(r[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(r[1]);
  mpi_conv_56to64(r64, r[1]);
  mpi64_print("  r1 = 0x", r64, 7);
  memset(r[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("- fp2 mul 1w v1:");

  LOAD_CACHE(fp2mul_mont_v1(r, a, a), 10);
  MEASURE_CYCLES(fp2mul_mont_v1(r, a, a), 100);
  printf("      #inst = %lld\n", diff_cycles);

#if DEBUG
  // r0 = 0x3306B70C7878F4FC445701989C949D34730CD77D27EB6133F6DB088FED9FA1E7A18F5515\
          74C4BD908049D3BCE94A63695F8ADFBECDA8E
  // r1 = 0x5A0F43788B83346DF59A47F91A579A1AC44B40DCDF58B9536321EEBADA5AD7FE18EE1085\
          892811915E8D7E0606F000D11B5B971AC1DF
  mpi56_carry_prop(r[0]);
  mpi_conv_56to64(r64, r[0]);
  mpi64_print("  r0 = 0x", r64, 7);
  memset(r[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(r[1]);
  mpi_conv_56to64(r64, r[1]);
  mpi64_print("  r1 = 0x", r64, 7);
  memset(r[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  puts("");

  // ---------------------------------------------------------------------------

  printf("- fp2 sqr 1w v0:");

  LOAD_CACHE(fp2sqr_mont_v0(r, a), 10);
  MEASURE_CYCLES(fp2sqr_mont_v0(r, a), 100);
  printf("      #inst = %lld\n", diff_cycles);

#if DEBUG
  // r0 = 0xFC4C49B0144AE2C7E59997C4A8F35780D4554679D012157DF735A5FED9FA1E7A18F55157\
          4C4BD908049D3BCE94A63695F8ADFBECDA8F
  // r1 = 0x5A0F43788B83346DF59A47F91A579A1AC44B40DCDF58B9536321EEBADA5AD7FE18EE1085\
          892811915E8D7E0606F000D11B5B971AC1DF
  mpi56_carry_prop(r[0]);
  mpi_conv_56to64(r64, r[0]);
  mpi64_print("  r0 = 0x", r64, 7);
  memset(r[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(r[1]);
  mpi_conv_56to64(r64, r[1]);
  mpi64_print("  r1 = 0x", r64, 7);
  memset(r[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("- fp2 sqr 1w v1:");

  LOAD_CACHE(fp2sqr_mont_v1(r, a), 10);
  MEASURE_CYCLES(fp2sqr_mont_v1(r, a), 100);
  printf("      #inst = %lld\n", diff_cycles);

#if DEBUG
  // r0 = 0xFC4C49B0144AE2C7E59997C4A8F35780D4554679D012157DF735A5FED9FA1E7A18F55157\
          4C4BD908049D3BCE94A63695F8ADFBECDA8F
  // r1 = 0x5A0F43788B83346DF59A47F91A579A1AC44B40DCDF58B9536321EEBADA5AD7FE18EE1085\
          892811915E8D7E0606F000D11B5B971AC1DF
  mpi56_carry_prop(r[0]);
  mpi_conv_56to64(r64, r[0]);
  mpi64_print("  r0 = 0x", r64, 7);
  memset(r[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(r[1]);
  mpi_conv_56to64(r64, r[1]);
  mpi64_print("  r1 = 0x", r64, 7);
  memset(r[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  puts("");

// ---------------------------------------------------------------------------

  printf("- fp2 add 1w v0:");

  LOAD_CACHE(fp2add_v0(r, a, a), 10);
  MEASURE_CYCLES(fp2add_v0(r, a, a), 100);
  printf("      #inst = %lld\n", diff_cycles);

#if DEBUG
  // r0 = 0x22290C528B555284DCB220FCD5B310AB9D1DEB0A63E9606C39DD94D579BDE02468ACF13579BDE\
          02468ACF13579BDE02468ACF13579BE0;
  // r1 = 0x3339FB417A446395EDC30FEBC4A221BCAE2ED9F952D8717D4AEE83C468ACF13579BDE02468ACF\
          13579BDE02468ACF13579BDE02468AD0;
  mpi56_carry_prop(r[0]);
  mpi_conv_56to64(r64, r[0]);
  mpi64_print("  r0 = 0x", r64, 7);
  memset(r[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(r[1]);
  mpi_conv_56to64(r64, r[1]);
  mpi64_print("  r1 = 0x", r64, 7);
  memset(r[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  puts("");

  // ---------------------------------------------------------------------------

  printf("- fp2 sub 1w v0:");

  LOAD_CACHE(fp2sub_v0(r, a, a), 10);
  MEASURE_CYCLES(fp2sub_v0(r, a, a), 100);
  printf("      #inst = %lld\n", diff_cycles);

#if DEBUG
  // r0 = 0;
  // r1 = 0;
  mpi56_carry_prop(r[0]);
  mpi_conv_56to64(r64, r[0]);
  mpi64_print("  r0 = 0x", r64, 7);
  memset(r[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(r[1]);
  mpi_conv_56to64(r64, r[1]);
  mpi64_print("  r1 = 0x", r64, 7);
  memset(r[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  puts("");

puts("**************************************************************************\n");
}

void test_curve()
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  int i;

  point_proj P, Q, PQ;
  f2elm_t A24plus, C24, A24minus;
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

  puts("\n**************************************************************************");
  puts("SCALAR MONTGOMERY CURVE ARITH 1w:\n");

  printf("- xDBL v0:");

  LOAD_CACHE(xDBL_v0(&P, &Q, A24plus, C24), 10);
  MEASURE_CYCLES(xDBL_v0(&P, &Q, A24plus, C24), 100);
  printf("            #inst = %lld\n", diff_cycles);

#if DEBUG
  // XQ0 = 0x1DF58B543C8AD438BF85AFB581109D9A9A5F01854AC9BC0324C1D8623B473C0CF70800C3714AF\
           A9DF28B8AE9546CB4FD62C8E1B5FF22E;
  // XQ1 = 0xE56C71A84A54EAF641A72686AB83725977AACC4D24EFACC0598AFEAE9F3EBB17730A35B41A7F0\
           50761A79882454EA580CE67658F4B61;
  // ZQ0 = 0x60C56C36E22FCE059EC41DEC606922EFAFA1C13BA531244E4404398994B97EB0EE4A05AA7B387\
           6811DB6F03946DC86BCD8A3E972DAAC;
  // ZQ1 = 0x33ABAE3BFC4173F7FAC7FAE7D499E8EC26BEE972CD79FB924748EC81AAA227BD067C16ED727DC\
           B9AF66D3AB670F1F012487D48C602BA;
  mpi56_carry_prop(Q.X[0]);
  mpi_conv_56to64(r64, Q.X[0]);
  mpi64_print("  XQ0 = 0x", r64, 7);
  memset(&Q.X[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.X[1]);
  mpi_conv_56to64(r64, Q.X[1]);
  mpi64_print("  XQ1 = 0x", r64, 7);
  memset(&Q.X[1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.Z[0]);
  mpi_conv_56to64(r64, Q.Z[0]);
  mpi64_print("  ZQ0 = 0x", r64, 7);
  memset(&Q.Z[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.Z[1]);
  mpi_conv_56to64(r64, Q.Z[1]);
  mpi64_print("  ZQ1 = 0x", r64, 7);
  memset(&Q.Z[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("- xDBL v1:");

  LOAD_CACHE(xDBL_v1(&P, &Q, A24plus, C24), 10);
  MEASURE_CYCLES(xDBL_v1(&P, &Q, A24plus, C24), 100);
  printf("            #inst = %lld\n", diff_cycles);

#if DEBUG
  // XQ0 = 0x1DF58B543C8AD438BF85AFB581109D9A9A5F01854AC9BC0324C1D8623B473C0CF70800C3714AF\
           A9DF28B8AE9546CB4FD62C8E1B5FF22E;
  // XQ1 = 0xE56C71A84A54EAF641A72686AB83725977AACC4D24EFACC0598AFEAE9F3EBB17730A35B41A7F0\
           50761A79882454EA580CE67658F4B61;
  // ZQ0 = 0x60C56C36E22FCE059EC41DEC606922EFAFA1C13BA531244E4404398994B97EB0EE4A05AA7B387\
           6811DB6F03946DC86BCD8A3E972DAAC;
  // ZQ1 = 0x33ABAE3BFC4173F7FAC7FAE7D499E8EC26BEE972CD79FB924748EC81AAA227BD067C16ED727DC\
           B9AF66D3AB670F1F012487D48C602BA;
  mpi56_carry_prop(Q.X[0]);
  mpi_conv_56to64(r64, Q.X[0]);
  mpi64_print("  XQ0 = 0x", r64, 7);
  memset(&Q.X[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.X[1]);
  mpi_conv_56to64(r64, Q.X[1]);
  mpi64_print("  XQ1 = 0x", r64, 7);
  memset(&Q.X[1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.Z[0]);
  mpi_conv_56to64(r64, Q.Z[0]);
  mpi64_print("  ZQ0 = 0x", r64, 7);
  memset(&Q.Z[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.Z[1]);
  mpi_conv_56to64(r64, Q.Z[1]);
  mpi64_print("  ZQ1 = 0x", r64, 7);
  memset(&Q.Z[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("- xDBL v2:");

  LOAD_CACHE(xDBL_v2(&P, &Q, A24plus, C24), 10);
  MEASURE_CYCLES(xDBL_v2(&P, &Q, A24plus, C24), 100);
  printf("            #inst = %lld\n", diff_cycles);

#if DEBUG
  // XQ0 = 0x1DF58B543C8AD438BF85AFB581109D9A9A5F01854AC9BC0324C1D8623B473C0CF70800C3714AF\
           A9DF28B8AE9546CB4FD62C8E1B5FF22E;
  // XQ1 = 0xE56C71A84A54EAF641A72686AB83725977AACC4D24EFACC0598AFEAE9F3EBB17730A35B41A7F0\
           50761A79882454EA580CE67658F4B61;
  // ZQ0 = 0x60C56C36E22FCE059EC41DEC606922EFAFA1C13BA531244E4404398994B97EB0EE4A05AA7B387\
           6811DB6F03946DC86BCD8A3E972DAAC;
  // ZQ1 = 0x33ABAE3BFC4173F7FAC7FAE7D499E8EC26BEE972CD79FB924748EC81AAA227BD067C16ED727DC\
           B9AF66D3AB670F1F012487D48C602BA;
  mpi56_carry_prop(Q.X[0]);
  mpi_conv_56to64(r64, Q.X[0]);
  mpi64_print("  XQ0 = 0x", r64, 7);
  memset(&Q.X[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.X[1]);
  mpi_conv_56to64(r64, Q.X[1]);
  mpi64_print("  XQ1 = 0x", r64, 7);
  memset(&Q.X[1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.Z[0]);
  mpi_conv_56to64(r64, Q.Z[0]);
  mpi64_print("  ZQ0 = 0x", r64, 7);
  memset(&Q.Z[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.Z[1]);
  mpi_conv_56to64(r64, Q.Z[1]);
  mpi64_print("  ZQ1 = 0x", r64, 7);
  memset(&Q.Z[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  puts("");

  // ---------------------------------------------------------------------------   

  printf("- xTPL v0:");

  LOAD_CACHE(xTPL_v0(&P, &Q, A24minus, A24plus), 10);
  MEASURE_CYCLES(xTPL_v0(&P, &Q, A24minus, A24plus), 100);
  printf("            #inst = %lld\n", diff_cycles);

#if DEBUG
  // XQ0 = 0x416C62092E5919D21AE4E1D0B30C117ACD21EF38B18F934708A2215C8EE7A30D59BBC6E\
           5BDE7E27BB848662298AEF4BB91CBDD9D14F22
  // XQ1 = 0x1E13BD3B4E9ED537CA5A87BC1E9D0AA4EF91A7526650FCF42896CECDE9F33EED82D5377\
           0052E3FD871F4C2642E57C6B3C3288DD8B2700
  // ZQ0 = 0x4558B5DFCACE8F27EA2A6044B8D1F8B0E8F92EF670A19B75C67DCA0C0C7C73E2E10CEDF\
           30EC979117FEF1CDFEB18EF337E8AC0F305F7E
  // ZQ1 = 0x6DFEE68F111FA3F5348A2B28A4E7EBF2EB6E1D1484ABD53BC3EF459FB2384247482BBB1\
           78D414B892CCECCA18A4E0EDB837647FB82CA
  mpi56_carry_prop(Q.X[0]);
  mpi_conv_56to64(r64, Q.X[0]);
  mpi64_print("  XQ0 = 0x", r64, 7);
  memset(&Q.X[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.X[1]);
  mpi_conv_56to64(r64, Q.X[1]);
  mpi64_print("  XQ1 = 0x", r64, 7);
  memset(&Q.X[1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.Z[0]);
  mpi_conv_56to64(r64, Q.Z[0]);
  mpi64_print("  ZQ0 = 0x", r64, 7);
  memset(&Q.Z[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.Z[1]);
  mpi_conv_56to64(r64, Q.Z[1]);
  mpi64_print("  ZQ1 = 0x", r64, 7);
  memset(&Q.Z[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("- xTPL v1:");

  LOAD_CACHE(xTPL_v1(&P, &Q, A24minus, A24plus), 10);
  MEASURE_CYCLES(xTPL_v1(&P, &Q, A24minus, A24plus), 100);
  printf("            #inst = %lld\n", diff_cycles);

#if DEBUG
  // XQ0 = 0x416C62092E5919D21AE4E1D0B30C117ACD21EF38B18F934708A2215C8EE7A30D59BBC6E\
           5BDE7E27BB848662298AEF4BB91CBDD9D14F22
  // XQ1 = 0x1E13BD3B4E9ED537CA5A87BC1E9D0AA4EF91A7526650FCF42896CECDE9F33EED82D5377\
           0052E3FD871F4C2642E57C6B3C3288DD8B2700
  // ZQ0 = 0x4558B5DFCACE8F27EA2A6044B8D1F8B0E8F92EF670A19B75C67DCA0C0C7C73E2E10CEDF\
           30EC979117FEF1CDFEB18EF337E8AC0F305F7E
  // ZQ1 = 0x6DFEE68F111FA3F5348A2B28A4E7EBF2EB6E1D1484ABD53BC3EF459FB2384247482BBB1\
           78D414B892CCECCA18A4E0EDB837647FB82CA
  mpi56_carry_prop(Q.X[0]);
  mpi_conv_56to64(r64, Q.X[0]);
  mpi64_print("  XQ0 = 0x", r64, 7);
  memset(&Q.X[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.X[1]);
  mpi_conv_56to64(r64, Q.X[1]);
  mpi64_print("  XQ1 = 0x", r64, 7);
  memset(&Q.X[1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.Z[0]);
  mpi_conv_56to64(r64, Q.Z[0]);
  mpi64_print("  ZQ0 = 0x", r64, 7);
  memset(&Q.Z[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.Z[1]);
  mpi_conv_56to64(r64, Q.Z[1]);
  mpi64_print("  ZQ1 = 0x", r64, 7);
  memset(&Q.Z[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

  printf("- xTPL v2:");

  LOAD_CACHE(xTPL_v2(&P, &Q, A24minus, A24plus), 10);
  MEASURE_CYCLES(xTPL_v2(&P, &Q, A24minus, A24plus), 100);
  printf("            #inst = %lld\n", diff_cycles);

#if DEBUG
  // XQ0 = 0x416C62092E5919D21AE4E1D0B30C117ACD21EF38B18F934708A2215C8EE7A30D59BBC6E\
           5BDE7E27BB848662298AEF4BB91CBDD9D14F22
  // XQ1 = 0x1E13BD3B4E9ED537CA5A87BC1E9D0AA4EF91A7526650FCF42896CECDE9F33EED82D5377\
           0052E3FD871F4C2642E57C6B3C3288DD8B2700
  // ZQ0 = 0x4558B5DFCACE8F27EA2A6044B8D1F8B0E8F92EF670A19B75C67DCA0C0C7C73E2E10CEDF\
           30EC979117FEF1CDFEB18EF337E8AC0F305F7E
  // ZQ1 = 0x6DFEE68F111FA3F5348A2B28A4E7EBF2EB6E1D1484ABD53BC3EF459FB2384247482BBB1\
           78D414B892CCECCA18A4E0EDB837647FB82CA
  mpi56_carry_prop(Q.X[0]);
  mpi_conv_56to64(r64, Q.X[0]);
  mpi64_print("  XQ0 = 0x", r64, 7);
  memset(&Q.X[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.X[1]);
  mpi_conv_56to64(r64, Q.X[1]);
  mpi64_print("  XQ1 = 0x", r64, 7);
  memset(&Q.X[1], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.Z[0]);
  mpi_conv_56to64(r64, Q.Z[0]);
  mpi64_print("  ZQ0 = 0x", r64, 7);
  memset(&Q.Z[0], 0, sizeof(uint64_t)*NLMB56);
  mpi56_carry_prop(Q.Z[1]);
  mpi_conv_56to64(r64, Q.Z[1]);
  mpi64_print("  ZQ1 = 0x", r64, 7);
  memset(&Q.Z[1], 0, sizeof(uint64_t)*NLMB56);
#endif 

puts("**************************************************************************\n");

}

int main()
{
  // test_fp();
  // test_fpx();
  test_curve();

  return 0;
}
