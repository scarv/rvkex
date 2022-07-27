#ifndef _SHARE_H
#define _SHARE_H

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "params.h"

#define NLMB56 9                        // the limb number when using radix-2^56
#define MASK56 0xFFFFFFFFFFFFFFULL      // 2^56 - 1

// Note: though there are 9 limbs in radix-2^56, we use 10 limbs in Montgomery
// reduction (because of the lazy reduction, using 9-limb would exceed R*P 
// 503+504=1007 bits), so R = 2^560. However, in other operations, we only work
// on 9 limbs, and the bits exceeding 504 are stored in the 9th limb. 

// 2^560 mod p
static const uint64_t mont_R[NLMB56] = {
  0xF99AF572183426, 0x00000000000003, 0x00000000000000, 0x00000000000000, 
  0xA2DB3678000000, 0xCD132CB643A36E, 0x523AC2871F16FB, 0x8FCC927783CAD7, 
  0x00B4970E70F478, };

// 2^1120 mod p
static const uint64_t mont_R2[NLMB56] = {
  0xE65A31525831E2, 0x011FFC1E5D1839, 0xB95289A0CF641D, 0x9B88257189FED2,
  0x3C0911B5C8F17A, 0xB0484593C54320, 0xBD40BA05AD2A58, 0x640EEE6E77C524,
  0x28A39B38693BD4, };

// auxiliary functions
void mpi64_print(const char *c, const uint64_t *a, int len);
void mpi56_carry_prop(uint64_t *a);
void mpi_conv_64to56(uint64_t *r, const uint64_t *a);
void mpi_conv_56to64(uint64_t *r, const uint64_t *a);

#endif
