#include "share.h"


void rand_bytes(void *x, int n) 
{
  FILE* rand_bytes_prg = NULL;

  if( NULL == (rand_bytes_prg = fopen( "/dev/urandom", "rb"))) abort();
  if( n != fread(x, sizeof(uint8_t), n, rand_bytes_prg)) abort();
  fclose(rand_bytes_prg);
}

// -----------------------------------------------------------------------------
// (4x1)-way implementation

void mpi32_print(const char *c, const uint32_t *a, int len)
{
  int i;

  printf("%s", c);
  for (i = len-1; i > 0; i--) printf("%08X", a[i]);
  printf("%08X\n", a[0]);
}

void mpi25_from_vec_4x1w(uint32_t *r, const vec4 *a, const int nlimb, const int ch) 
{
  int i;

  for(i = 0; i < nlimb; i++) {
    r[i] = ((uint32_t *)&a[i])[ch];
  }
}

void mpi25_from_vec_1x4w(uint32_t *r, const vec4 *a)
{
  r[0] = a[0][0]; r[3] = a[0][1]; r[6] = a[0][2]; r[9] = a[0][3];
  r[1] = a[1][0]; r[4] = a[1][1]; r[7] = a[1][2]; 
  r[2] = a[2][0]; r[5] = a[2][1]; r[8] = a[2][2]; 
}

void mpi25_to_vec_1x4w(vec4 *r, const uint32_t *a)
{
  r[0][0] = a[0]; r[0][1] = a[3]; r[0][2] = a[6]; r[0][3] = a[9];
  r[1][0] = a[1]; r[1][1] = a[4]; r[1][2] = a[7]; r[1][3] =    0;
  r[2][0] = a[2]; r[2][1] = a[5]; r[2][2] = a[8]; r[2][3] =    0;
}

void mpi25_carry_prop(uint32_t *a)
{
  a[1] += a[0] >> 26; a[0] &= MASK26;
  a[2] += a[1] >> 25; a[1] &= MASK25;
  a[3] += a[2] >> 26; a[2] &= MASK26;
  a[4] += a[3] >> 25; a[3] &= MASK25;
  a[5] += a[4] >> 26; a[4] &= MASK26;
  a[6] += a[5] >> 25; a[5] &= MASK25;
  a[7] += a[6] >> 26; a[6] &= MASK26;
  a[8] += a[7] >> 25; a[7] &= MASK25;
  a[9] += a[8] >> 26; a[8] &= MASK26;
} 

void mpi_conv_32to25(uint32_t *r, const uint32_t *a)
{
  r[0] = ( a[0]                      ) & MASK26;
  r[1] = ((a[0] >> 26) | (a[1] << 6 )) & MASK25;
  r[2] = ((a[1] >> 19) | (a[2] << 13)) & MASK26;
  r[3] = ((a[2] >> 13) | (a[3] << 19)) & MASK25;
  r[4] = ( a[3] >> 6                 ) & MASK26;
  r[5] = ( a[4]                      ) & MASK25;
  r[6] = ((a[4] >> 25) | (a[5] << 7 )) & MASK26;
  r[7] = ((a[5] >> 19) | (a[6] << 13)) & MASK25;
  r[8] = ((a[6] >> 12) | (a[7] << 20)) & MASK26;
  r[9] = ( a[7] >> 6                 ) & MASK25;
}

void mpi_conv_25to32(uint32_t *r, const uint32_t *a)
{
  r[0] =  a[0]        | (a[1] << 26);
  r[1] = (a[1] >> 6 ) | (a[2] << 19);
  r[2] = (a[2] >> 13) | (a[3] << 13);
  r[3] = (a[3] >> 19) | (a[4] << 6 );
  r[4] =  a[5]        | (a[6] << 25);
  r[5] = (a[6] >> 7 ) | (a[7] << 19);
  r[6] = (a[7] >> 13) | (a[8] << 12);
  r[7] = (a[8] >> 20) | (a[9] << 6 ); 
  r[8] =  a[9] >> 26                ;        
}

// -----------------------------------------------------------------------------
// (2x1)-way implementation

void mpi64_print(const char *c, const uint64_t *a, int len)
{
  int i;

  printf("%s", c);
  for (i = len-1; i > 0; i--) printf("%016llX", a[i]);
  printf("%016llX\n", a[0]);
}

void mpi51_from_vec_2x1w(uint64_t *r, const vec2 *a, const int nlimb, const int ch) 
{
  int i;

  for(i = 0; i < nlimb; i++) {
    r[i] = ((uint64_t *)&a[i])[ch];
  }
}

void mpi51_from_vec_1x2w(uint64_t *r, const vec2 *a)
{
  r[0] = a[0][0]; r[3] = a[0][1]; 
  r[1] = a[1][0]; r[4] = a[1][1]; 
  r[2] = a[2][0]; 
}

void mpi51_to_vec_1x2w(vec2 *r, const uint64_t *a)
{
  r[0][0] = a[0]; r[0][1] = a[3];
  r[1][0] = a[1]; r[1][1] = a[4]; 
  r[2][0] = a[2]; r[2][1] =    0;
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
