
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

void uint_print(fp const *x)
{
    for (size_t i = 8*LIMBS-1; i < 8*LIMBS; --i)
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

void mpi64_print(const char *c, const uint64_t *a, int len)
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

  fp a, b, r;
  uint64_t t[2*LIMBS];

  for (i = 0; i < LIMBS; i++) { 
    a.c[i] = 0x0123456789ABCDEFULL;
    b.c[i] = 0x89ABCDEF01234567ULL;
  }

  printf("\n**************************************************************************\n");
  printf("FP ARITH:\n");

  printf("- uint mul ps sw:");
  MEASURE_CYCLES(uint_mul3_ps_sw(t, &a, &b), 1);
  printf("       #cycle = %lld\n", diff_cycles);
  
  mpi64_print("  t  = 0x", t, LIMBS*2);

  printf("FP ARITH:\n");

  printf("- uint mul ps sw:");
  MEASURE_CYCLES(fp_rdc_mont_sw(&r, t), 1);
  printf("       #cycle = %lld\n", diff_cycles);
  
  printf("  r = 0x");
  uint_print(&r);
  printf("\n");

  printf("**************************************************************************\n");
}

void test_csidh()
{
    bool ret; (void) ret;

    private_key priv_alice, priv_bob;
    public_key pub_alice, pub_bob;
    public_key shared_alice, shared_bob;

    uint64_t start_cycles, end_cycles, diff_cycles;
    int i;

    printf("\n");

    MEASURE_CYCLES(csidh_private(&priv_alice), 1);
    printf("Alice's private key   (%lld cc):\n  ", diff_cycles);
    priv_print(&priv_alice);
    printf("\n\n");

    MEASURE_CYCLES(csidh_private(&priv_bob), 1);
    printf("Bob's private key     (%lld cc):\n  ", diff_cycles);
    priv_print(&priv_bob);
    printf("\n\n");


    MEASURE_CYCLES(ret = csidh(&pub_alice, &base, &priv_alice), 1);
    assert(ret);
    printf("Alice's public key    (%lld cc):\n  ", diff_cycles);
    uint_print(&pub_alice.A);
    printf("\n\n");


    MEASURE_CYCLES(ret = csidh(&pub_bob, &base, &priv_bob), 1);
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
    if (memcmp(&shared_alice, &shared_bob, sizeof(public_key)))
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