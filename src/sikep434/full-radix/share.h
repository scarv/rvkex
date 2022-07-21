#ifndef _SHARE_H
#define _SHARE_H

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "params.h"

#define NLMB64 7                        // the limb number when using radix-2^64

// 2^448 mod p
static const uint64_t mont_R[NLMB64] = {
  0x000000000000742C, 0x0000000000000000, 0x0000000000000000, 0xB90FF404FC000000, 
  0xD801A4FB559FACD4, 0xE93254545F77410C, 0x0000ECEEA7BD2EDA, };

// 2^896 mod p
static const uint64_t mont_R2[NLMB64] = {
  0x28E55B65DCD69B30, 0xACEC7367768798C2, 0xAB27973F8311688D, 0x175CC6AF8D6C7C0B,
  0xABCD92BF2DDE347E, 0x69E16A61C7686D9A, 0x000025A89BCDD12A, };

// auxiliary functions
void mpi64_print(const char *c, const uint64_t *a, int len);

#endif
