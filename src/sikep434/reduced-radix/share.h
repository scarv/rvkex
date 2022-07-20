#ifndef _SHARE_H
#define _SHARE_H

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "params.h"

#define NLMB56 8                        // the limb number when using radix-2^56
#define MASK56 0xFFFFFFFFFFFFFFULL      // 2^56 - 1

// 2^448 mod p
static const uint64_t mont_R[NLMB56] = {
  0x0000000000742C, 0x00000000000000, 0x00000000000000, 0xFC000000000000, 
  0x9FACD4B90FF404, 0x410CD801A4FB55, 0xDAE93254545F77, 0x0000ECEEA7BD2E, };

// 2^896 mod p
static const uint64_t mont_R2[NLMB56] = {
  0xE55B65DCD69B30, 0x7367768798C228, 0x3F8311688DACEC, 0x8D6C7C0BAB2797,
  0xDE347E175CC6AF, 0x6D9AABCD92BF2D, 0x2A69E16A61C768, 0x000025A89BCDD1, };

// auxiliary functions
void mpi64_print(const char *c, const uint64_t *a, int len);
void mpi56_carry_prop(uint64_t *a);
void mpi_conv_64to56(uint64_t *r, const uint64_t *a);
void mpi_conv_56to64(uint64_t *r, const uint64_t *a);

#endif
