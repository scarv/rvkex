
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <assert.h>

#include "fp.h"
#include "csidh.h"
#include "rdtsc.h"

// macros for measuring CPU cycles

#define LOAD_CACHE(X, ITER) for (i = 0; i < (ITER); i++) (X)

#define MEASURE_CYCLES(X, ITER)                    \
  start_cycles = rdtsc();                          \
  for (i = 0; i < (ITER); i++) (X);                \
  end_cycles = rdtsc();                            \
  diff_cycles = (end_cycles-start_cycles)/(ITER)

void uint_print(u64 const *x)
{
    for (size_t i = 8*8-1; i < 8*8; --i)
        printf("%02hhx", i[(unsigned char *) x->c]);
}

void priv_print(private_key const *k)
{
    char cc = '0';
    for (size_t i = 0; i < sizeof(k->e)/sizeof(*k->e); ++i) {
        char nc = k->e[i] > 0 ? '6' : k->e[i] < 0 ? '4' : '7';
        if (nc != cc) cc = nc, printf("\x1b[3%cm", cc);
        printf(MAX_EXPONENT < 16 ? "%x" : "%02x", abs(k->e[i]));
    }
    printf("\x1b[0m");
}

static void mpi64_print(const char *c, const uint64_t *a, int len)
{
  int i;

  printf("%s", c);
  for (i = len-1; i > 0; i--) printf("%016llX", a[i]);
  printf("%016llX\n", a[0]);
}

void test_fp()
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  int i;

  u64 a64, b64, r64;
  fp  a, b, r;
  uint64_t t[2*LIMBS];

  for (i = 0; i < 8; i++) { 
    a64.c[i] = 0x0123456789ABCDEFULL;
    b64.c[i] = 0x89ABCDEF01234567ULL;
  }
  b64.c[7] = 0x59ABCDEF01234567ULL;

  mpi_conv_64to57(a.c, a64.c, LIMBS, 8);
  mpi_conv_64to57(b.c, b64.c, LIMBS, 8);

  printf("\n**************************************************************************\n");
  printf("FP ARITH:\n");

  printf("- fp add:");
  LOAD_CACHE(fp_add3(&r, &a, &b), 100);
  MEASURE_CYCLES(fp_add3(&r, &a, &b), 1000);
  printf("            #cycle = %lld\n", diff_cycles);

  printf("- fp sub:");
  LOAD_CACHE(fp_sub3(&r, &a, &b), 100);
  MEASURE_CYCLES(fp_sub3(&r, &a, &b), 1000);
  printf("            #cycle = %lld\n", diff_cycles);

  printf("- fp mul:");
  LOAD_CACHE(fp_mul3(&r, &a, &b), 100);
  MEASURE_CYCLES(fp_mul3(&r, &a, &b), 1000);
  printf("            #cycle = %lld\n", diff_cycles);

  // mpi_conv_57to64(r64.c, r.c, 8, 9);
  // mpi64_print("r = ", r64.c, 8);

  printf("- fp sqr:");
  LOAD_CACHE(fp_sq2(&r, &a), 100);
  MEASURE_CYCLES(fp_sq2(&r, &a), 1000);
  printf("            #cycle = %lld\n", diff_cycles);

#if (RV64_TYPE1) | (RV64_TYPE2) | (RV64_TYPE3)
  printf("- uint mul ps:");
  LOAD_CACHE(uint_mul3_asm(t, &a, &b), 100);
  MEASURE_CYCLES(uint_mul3_asm(t, &a, &b), 1000);
  printf("       #cycle = %lld\n", diff_cycles);

  printf("- uint sqr ps:");
  LOAD_CACHE(uint_sqr2_asm(t, &a), 1000);
  MEASURE_CYCLES(uint_sqr2_asm(t, &a), 10000);
  printf("       #cycle = %lld\n", diff_cycles);

  printf("- fp rdc mont:");
  LOAD_CACHE(fp_rdc_mont_asm(&r, t), 1000);
  MEASURE_CYCLES(fp_rdc_mont_asm(&r, t), 10000);
  printf("       #cycle = %lld\n", diff_cycles);
#endif

  printf("- reduce once:");
  LOAD_CACHE(reduce_once(&r), 1000);
  MEASURE_CYCLES(reduce_once(&r), 10000);
  printf("       #cycle = %lld\n", diff_cycles);

  printf("**************************************************************************\n");

}

void test_csidh()
{
    uint64_t start_cycles, end_cycles, diff_cycles;
    int i;

    bool ret; (void) ret;
    clock_t t0, t1;

    private_key priv_alice, priv_bob;
    public_key_u64 pub_alice, pub_bob;
    public_key_u64 shared_alice, shared_bob;

    printf("\n");

    MEASURE_CYCLES(csidh_private(&priv_alice), 1);
    printf("Alice's private key   (%lld cc):\n  ", diff_cycles);
    priv_print(&priv_alice);
    printf("\n\n");

    MEASURE_CYCLES(csidh_private(&priv_bob), 1);
    printf("Bob's private key     (%lld cc):\n  ", diff_cycles);
    priv_print(&priv_bob);
    printf("\n\n");


    MEASURE_CYCLES(ret = csidh(&pub_alice, (public_key_u64 *)&base, &priv_alice), 1);
    assert(ret);
    printf("Alice's public key    (%lld cc):\n  ", diff_cycles);
    uint_print(&pub_alice.A);
    printf("\n\n");


    MEASURE_CYCLES(ret = csidh(&pub_bob, (public_key_u64 *)&base, &priv_bob), 1);
    assert(ret);
    printf("Bob's public key      (%lld cc):\n  ", diff_cycles);
    uint_print(&pub_bob.A);
    printf("\n\n");


    MEASURE_CYCLES(ret = csidh(&shared_alice, &pub_bob, &priv_alice), 1);
    assert(ret);
    printf("Alice's shared secret (%lld cc):\n  ", diff_cycles);
    uint_print(&shared_alice.A);
    printf("\n\n");


    MEASURE_CYCLES(ret = csidh(&shared_bob, &pub_alice, &priv_bob), 1);
    assert(ret);
    printf("Bob's shared secret   (%lld cc):\n  ", diff_cycles);
    uint_print(&shared_bob.A);
    printf("\n\n");


    printf("    ");
    if (memcmp(&shared_alice, &shared_bob, sizeof(public_key_u64)))
        printf("\x1b[31mNOT EQUAL!\x1b[0m\n");
    else
        printf("\x1b[32mequal.\x1b[0m\n");
    printf("\n");


    printf("\n");
}

int main()
{
  test_fp();
  test_csidh();
}
