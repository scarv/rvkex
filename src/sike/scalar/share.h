#ifndef _SHARE_H
#define _SHARE_H

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define NLMB56 8                        // the limb number when using radix-56
#define MASK56 0xFFFFFFFFFFFFFFULL      // 2^56 - 1

// auxiliary functions
void rand_bytes(void *x, int n);
void mpi64_print(const char *c, const uint64_t *a, int len);
void mpi56_carry_prop(uint64_t *a);
void mpi_conv_64to56(uint64_t *r, const uint64_t *a);
void mpi_conv_56to64(uint64_t *r, const uint64_t *a);

#endif