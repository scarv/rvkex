#ifndef _SHARE_H
#define _SHARE_H

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "params.h"

#define NLMB56 11                       // the limb number when using radix-2^56
#define MASK56 0xFFFFFFFFFFFFFFULL      // 2^56 - 1

// 2^616 mod p
static const uint64_t mont_R[NLMB56] = {
  0x00000000000067, 0x00000000000000, 0x00000000000000, 0x00000000000000, 
  0x00000000000000, 0x1D51BD32000000, 0xEB9898A7637583, 0xACC20B3B2A128B, 
  0x84FD6341150BDB, 0x41D10BB7DF643F, 0x01FC2A4F3DF09, };

// 2^1232 mod p
static const uint64_t mont_R2[NLMB56] = {
  0x63B627392EE75F, 0x18DE493DE0B859, 0xD1A0C56BC17078, 0xE54ADC7F419940,
  0xC423A6030979ED, 0xF4DC80E47082B8, 0xEA856A6762238F, 0x7ED065819D8A61,
  0xBE6DFE5BD50120, 0x97041DE9FAC830, 0x00E7585A7C3439, };

// auxiliary functions
void mpi64_print(const char *c, const uint64_t *a, int len);
void mpi56_carry_prop(uint64_t *a);
void mpi_conv_64to56(uint64_t *r, const uint64_t *a);
void mpi_conv_56to64(uint64_t *r, const uint64_t *a);

#endif
