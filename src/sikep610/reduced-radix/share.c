#include "share.h"


void mpi64_print(const char *c, const uint64_t *a, int len)
{
  int i;

  printf("%s", c);
  for (i = len-1; i > 0; i--) printf("%016llX", a[i]);
  printf("%016llX\n", a[0]);
}

void mpi56_carry_prop(uint64_t *a)
{
  a[1] += a[0] >> 56; a[0] &= MASK56;
  a[2] += a[1] >> 56; a[1] &= MASK56;
  a[3] += a[2] >> 56; a[2] &= MASK56;
  a[4] += a[3] >> 56; a[3] &= MASK56;
  a[5] += a[4] >> 56; a[4] &= MASK56;
  a[6] += a[5] >> 56; a[5] &= MASK56;
  a[7] += a[6] >> 56; a[6] &= MASK56;
  a[8] += a[7] >> 56; a[7] &= MASK56;
  a[9] += a[8] >> 56; a[8] &= MASK56;
  a[10]+= a[9] >> 56; a[9] &= MASK56;
} 

void mpi_conv_64to56(uint64_t *r, const uint64_t *a)
{
  r[0] = ( a[0]                      ) & MASK56;
  r[1] = ((a[0] >> 56) | (a[1] <<  8)) & MASK56;
  r[2] = ((a[1] >> 48) | (a[2] << 16)) & MASK56;
  r[3] = ((a[2] >> 40) | (a[3] << 24)) & MASK56;
  r[4] = ((a[3] >> 32) | (a[4] << 32)) & MASK56;
  r[5] = ((a[4] >> 24) | (a[5] << 40)) & MASK56;
  r[6] = ((a[5] >> 16) | (a[6] << 48)) & MASK56;
  r[7] = ( a[6] >>  8                ) & MASK56;
  r[8] = ( a[7]                      ) & MASK56;
  r[9] = ((a[7] >> 56) | (a[8] <<  8)) & MASK56;
  r[10]= ((a[8] >> 48) | (a[9] << 16)) & MASK56;
}

void mpi_conv_56to64(uint64_t *r, const uint64_t *a)
{
  r[0] =  a[0]        | (a[1] << 56);
  r[1] = (a[1] >>  8) | (a[2] << 48);
  r[2] = (a[2] >> 16) | (a[3] << 40);
  r[3] = (a[3] >> 24) | (a[4] << 32);
  r[4] = (a[4] >> 32) | (a[5] << 24);
  r[5] = (a[5] >> 40) | (a[6] << 16);
  r[6] = (a[6] >> 48) | (a[7] <<  8);
  r[7] =  a[8]        | (a[9] << 56);
  r[8] = (a[9] >>  8) | (a[10]<< 48);
  r[9] = (a[10]>> 16)               ;
}
