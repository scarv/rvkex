#ifndef _SHARE_H
#define _SHARE_H

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "params.h"

#define NLMB56 14                       // the limb number when using radix-2^56
#define MASK56 0xFFFFFFFFFFFFFFULL      // 2^56 - 1

// 2^784 mod p
static const uint64_t mont_R[NLMB56] = {
  0x00000249AD67C3, 0x00000000000000, 0x00000000000000, 0x00000000000000, 
  0x00000000000000, 0x00000000000000, 0x595FF000000000, 0xE41DEF121B96A2,
  0x629C693BCBC0E3, 0xCDCAADF484FCE6, 0x690C605167C482, 0x05E62AE263352E,
  0x368CEF62181576, 0x000000006FDDEA,
 };

// 2^1568 mod p
static const uint64_t mont_R2[NLMB56] = {
  0xAD40589641FD5E, 0x452A233046449D, 0x8EDB010161A696, 0x5E36941472E3FD,
  0x0BFE2082A2E706, 0xCCA8904F8751F4, 0x838A47FC814932, 0xEE343042C83862,
  0x2C0ABDD4843B53, 0x3AECFBCE3DB507, 0x879C376E912F99, 0xEBD5F9945EDAF8,
  0xFB1B7C52065227, 0x00000000188458, 
 };

// auxiliary functions
void mpi64_print(const char *c, const uint64_t *a, int len);
void mpi56_carry_prop(uint64_t *a);
void mpi_conv_64to56(uint64_t *r, const uint64_t *a);
void mpi_conv_56to64(uint64_t *r, const uint64_t *a);

#endif
