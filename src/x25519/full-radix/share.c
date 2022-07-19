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
