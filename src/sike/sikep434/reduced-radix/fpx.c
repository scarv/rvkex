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

// The Mongomery squaring can be optimized with (1) merging the two functions 
// into one to save some store/load instructions and (2) a dedicated integer 
// squaring function.
void fpsqr_mont_v0(felm_t r, const felm_t a)
{
  dfelm_t temp = { 0 };

  mp_mul(temp, a, a);
  rdc_mont(r, temp);
}

// v0: there are carry propagations in first two additions.
void fp2sqr_mont_v0(f2elm_t r, const f2elm_t a)
{
  felm_t t1, t2, t3;
  
  mp_add_v0(t1, a[0], a[1]);            // t1 = a0 + a1
  mp_add_v0(t3, a[0], a[0]);            // t3 = 2 * a0
  mp_sub_p4(t2, a[0], a[1]);            // t2 = a0 - a1 + 4p
  fpmul_mont_v0(r[0], t1, t2);          // r0 = (a0+a1) * (a0-a1) mod 2p
  fpmul_mont_v0(r[1], t3, a[1]);        // r1 = 2a0 * a1 mod 2p
}

// v1: there are NOT carry propagations in first two additions.
void fp2sqr_mont_v1(f2elm_t r, const f2elm_t a)
{
  felm_t t1, t2, t3;

  mp_add_v1(t1, a[0], a[1]);            // t1 = a0 + a1
  mp_add_v1(t3, a[0], a[0]);            // t3 = 2 * a0
  mp_sub_p4(t2, a[0], a[1]);            // t2 = a0 - a1 + 4p
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

void fp2neg_v0(f2elm_t r)
{
  fpneg(r[0]);
  fpneg(r[1]);  
}

void fp2div2_v0(f2elm_t r, const f2elm_t a)
{
  fpdiv2(r[0], a[0]);
  fpdiv2(r[1], a[1]);
}

void fp2correction_v0(f2elm_t r)
{
  fpcorrection(r[0]);
  fpcorrection(r[1]);
}

// v0: there are carry propagations in integer additions. 
void mp2_add_v0(f2elm_t r, const f2elm_t a, const f2elm_t b)
{
  mp_add_v0(r[0], a[0], b[0]);
  mp_add_v0(r[1], a[1], b[1]);
}

// v1: there are NOT carry propagations in integer additions. 
void mp2_add_v1(f2elm_t r, const f2elm_t a, const f2elm_t b)
{
  mp_add_v1(r[0], a[0], b[0]);
  mp_add_v1(r[1], a[1], b[1]);
}

void mp2_sub_p2_v0(f2elm_t r, const f2elm_t a, const f2elm_t b)
{
  mp_sub_p2_v0(r[0], a[0], b[0]);
  mp_sub_p2_v0(r[1], a[1], b[1]);
}

void mp2_sub_p2_v1(f2elm_t r, const f2elm_t a, const f2elm_t b)
{
  mp_sub_p2_v1(r[0], a[0], b[0]);
  mp_sub_p2_v1(r[1], a[1], b[1]);
}

void to_mont(felm_t r, const felm_t a)
{
  fpmul_mont(r, a, mont_R2);
}

void from_mont(felm_t r, const felm_t a)
{
  felm_t one = { 1 };

  fpmul_mont(r, a, one);
  fpcorrection(r);
}

void to_fp2mont(f2elm_t r, const f2elm_t a)
{
  to_mont(r[0], a[0]);
  to_mont(r[1], a[1]);
}

void from_fp2mont(f2elm_t r, const f2elm_t a)
{
  from_mont(r[0], a[0]);
  from_mont(r[1], a[1]);
}

void fpcopy(felm_t r, const felm_t a)
{
  int i;

  for (i = 0; i < NLMB56; i++) r[i] = a[i];
}

void fp2copy(f2elm_t r, const f2elm_t a)
{
  fpcopy(r[0], a[0]);
  fpcopy(r[1], a[1]);
}  

void fpzero(felm_t r)
{
  int i;

  for (i = 0; i < NLMB56; i++) r[i] = 0;
}

void fp2zero(f2elm_t r)
{
  fpzero(r[0]);
  fpzero(r[1]);
}

void fpinv_chain_mont(felm_t r)
{
  felm_t t[31], tt;
  int i, j;

  // Precomputed table
  fpsqr_mont(tt, r);
  fpmul_mont(t[0], r, tt);    
  for (i = 0; i <= 29; i++) fpmul_mont(t[i+1], t[i], tt);
  fpcopy(tt, r);
  for (i = 0; i < 7; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[5], tt);
  for (i = 0; i < 10; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[14], tt);
  for (i = 0; i < 6; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[3], tt);
  for (i = 0; i < 6; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[23], tt);
  for (i = 0; i < 6; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[13], tt);
  for (i = 0; i < 6; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[24], tt);
  for (i = 0; i < 6; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[7], tt);  
  for (i = 0; i < 8; i++) fpsqr_mont(tt, tt); 
  fpmul_mont(tt, t[12], tt);
  for (i = 0; i < 8; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[30], tt);
  for (i = 0; i < 6; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[1], tt);
  for (i = 0; i < 6; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[30], tt);    
  for (i = 0; i < 7; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[21], tt);  
  for (i = 0; i < 9; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[2], tt);
  for (i = 0; i < 9; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[19], tt);
  for (i = 0; i < 9; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[1], tt);
  for (i = 0; i < 7; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[24], tt);
  for (i = 0; i < 6; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[26], tt);
  for (i = 0; i < 6; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[16], tt);    
  for (i = 0; i < 7; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[10], tt);
  for (i = 0; i < 7; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[6], tt);
  for (i = 0; i < 7; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[0], tt);
  for (i = 0; i < 9; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[20], tt);
  for (i = 0; i < 8; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[9], tt);
  for (i = 0; i < 6; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[25], tt);
  for (i = 0; i < 9; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[30], tt);
  for (i = 0; i < 6; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[26], tt);
  for (i = 0; i < 6; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, r, tt);
  for (i = 0; i < 7; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[28], tt);
  for (i = 0; i < 6; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[6], tt);
  for (i = 0; i < 6; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[10], tt);
  for (i = 0; i < 9; i++) fpsqr_mont(tt, tt);
  fpmul_mont(tt, t[22], tt);
  for (j = 0; j < 35; j++) {
    for (i = 0; i < 6; i++) fpsqr_mont(tt, tt);
    fpmul_mont(tt, t[30], tt);
  }
  fpcopy(r, tt); 
}

void fpinv_mont(felm_t r)
{
  felm_t tt;

  fpcopy(tt, r);
  fpinv_chain_mont(tt);
  fpsqr_mont(tt, tt);
  fpsqr_mont(tt, tt);
  fpmul_mont(r, r, tt);
}

void fp2inv_mont(f2elm_t r)
{
  f2elm_t t1;

  fpsqr_mont(t1[0], r[0]);  
  fpsqr_mont(t1[1], r[1]);
  fpadd(t1[0], t1[0], t1[1]);
  fpinv_mont(t1[0]);
  fpneg(r[1]);
  fpmul_mont(r[0], r[0], t1[0]);
  fpmul_mont(r[1], r[1], t1[0]);        
}

void decode_to_digits(const unsigned char* x, uint64_t* dec, int nbytes, int ndigits)
{
  dec[ndigits - 1] = 0;
  memcpy((unsigned char*)dec, x, nbytes);
}

static void encode_to_bytes(const uint64_t* x, unsigned char* enc, int nbytes)
{ 
  memcpy(enc, (const unsigned char*)x, nbytes);
}

void fp2_encode(const f2elm_t x, unsigned char *enc)
{
  f2elm_t t;
  uint64_t t64[NLMB56];

  from_fp2mont(t, x);                   // t is x in number domain
  mpi_conv_56to64(t64, t[0]);           // convert t[0] to radix-2^64
  encode_to_bytes(t64, enc, FP2_ENCODED_BYTES/2);
  mpi_conv_56to64(t64, t[1]);           // convert t[1] to radix-2^64
  encode_to_bytes(t64, enc+FP2_ENCODED_BYTES/2, FP2_ENCODED_BYTES/2); 
}

void fp2_decode(const unsigned char *x, f2elm_t dec)
{
  uint64_t r56[NLMB56];

  decode_to_digits(x, r56, FP2_ENCODED_BYTES/2, NWORDS_FIELD);
  mpi_conv_64to56(dec[0], r56);
  decode_to_digits(x+FP2_ENCODED_BYTES/2, r56, FP2_ENCODED_BYTES/2, NWORDS_FIELD);
  mpi_conv_64to56(dec[1], r56);
  to_fp2mont(dec, dec);
}

int8_t ct_compare(const uint8_t *a, const uint8_t *b, unsigned int len) 
{
  uint8_t r = 0;

  for (unsigned int i = 0; i < len; i++)
    r |= a[i] ^ b[i];

  return (-(int8_t)r) >> (8*sizeof(uint8_t)-1);
}

void ct_cmov(uint8_t *r, const uint8_t *a, unsigned int len, int8_t selector) 
{
  for (unsigned int i = 0; i < len; i++)
    r[i] ^= selector & (a[i] ^ r[i]);
}

