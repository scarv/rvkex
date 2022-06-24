#ifndef _SHARE_H
#define _SHARE_H

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define CONSTA 486662                   // the constant of Curve25519

void rand_bytes(void *x, int n);        // random bytes generation

// -----------------------------------------------------------------------------
// (4x1)-way implementation

#define NLMB25 10                       // the limber number when using radix-25.5
#define MASK26 0x3FFFFFFUL              // 2^26 - 1
#define MASK25 0x1FFFFFFUL              // 2^25 - 1

typedef uint32_t vec4[4];               // 128-bit 4-lane vector for 4x1w 

// auxiliary functions
void mpi32_print(const char *c, const uint32_t *a, int len);
void mpi25_from_vec_4x1w(uint32_t *r, const vec4 *a, const int nlimb, const int ch); 
void mpi25_from_vec_1x4w(uint32_t *r, const vec4 *a);
void mpi25_to_vec_1x4w(vec4 *r, const uint32_t *a);
void mpi25_carry_prop(uint32_t *a);
void mpi_conv_32to25(uint32_t *r, const uint32_t *a);
void mpi_conv_25to32(uint32_t *r, const uint32_t *a);

// -----------------------------------------------------------------------------
// (2x1)-way implementation

#define NLMB51 5                        // the limb number when using radix-51
#define MASK51 0x7FFFFFFFFFFFFULL       // 2^51 - 1
#define LSLP51 0x7FFFFFFFFFFEDULL       // least significant limb of modulus p 

typedef uint64_t vec2[2];               // 128-bit 2-lane vector for 2x1w

// auxiliary functions
void mpi64_print(const char *c, const uint64_t *a, int len);
void mpi51_from_vec_2x1w(uint64_t *r, const vec2 *a, const int nlimb, const int ch);
void mpi51_from_vec_1x2w(uint64_t *r, const vec2 *a);
void mpi51_to_vec_1x2w(vec2 *r, const uint64_t *a);
void mpi51_carry_prop(uint64_t *a);
void mpi_conv_64to51(uint64_t *r, const uint64_t *a);
void mpi_conv_51to64(uint64_t *r, const uint64_t *a);

// -----------------------------------------------------------------------------

#endif
