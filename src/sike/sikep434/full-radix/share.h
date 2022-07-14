#ifndef _SHARE_H
#define _SHARE_H

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define NLMB64 8                        // the limb number when using radix-2^64

// auxiliary functions
void randombytes(void *x, int n);
void mpi64_print(const char *c, const uint64_t *a, int len);

#endif
