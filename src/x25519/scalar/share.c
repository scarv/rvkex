#include "share.h"


void rand_bytes(void *x, int n) 
{
  FILE* rand_bytes_prg = NULL;

  if( NULL == (rand_bytes_prg = fopen( "/dev/urandom", "rb"))) abort();
  if( n != fread(x, sizeof(uint8_t), n, rand_bytes_prg)) abort();
  fclose(rand_bytes_prg);
}


void mpi64_print(const char *c, const uint64_t *a, int len)
{
  int i;

  printf("%s", c);
  for (i = len-1; i > 0; i--) printf("%016llX", a[i]);
  printf("%016llX\n", a[0]);
}

void mpi51_carry_prop(uint64_t *a)
{
  a[1] += a[0] >> 51; a[0] &= MASK51;
  a[2] += a[1] >> 51; a[1] &= MASK51;
  a[3] += a[2] >> 51; a[2] &= MASK51;
  a[4] += a[3] >> 51; a[3] &= MASK51;
} 

void mpi_conv_64to51(uint64_t *r, const uint64_t *a)
{
  r[0] = ( a[0]                      ) & MASK51;
  r[1] = ((a[0] >> 51) | (a[1] << 13)) & MASK51;
  r[2] = ((a[1] >> 38) | (a[2] << 26)) & MASK51;
  r[3] = ((a[2] >> 25) | (a[3] << 39)) & MASK51;
  r[4] = ( a[3] >> 12                ) & MASK51;
}

void mpi_conv_51to64(uint64_t *r, const uint64_t *a)
{
  r[0] =  a[0]        | (a[1] << 51);
  r[1] = (a[1] >> 13) | (a[2] << 38);
  r[2] = (a[2] >> 26) | (a[3] << 25);
  r[3] = (a[3] >> 39) | (a[4] << 12); 
  r[4] =  a[4] >> 52                ; 
}
