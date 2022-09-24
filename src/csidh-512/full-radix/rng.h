#ifndef RNG_H
#define RNG_H

#include <stdlib.h>
#include <stdint.h>

void rand_bytes(uint8_t* x, int n);
void randombytes(void *x, size_t l);

#endif
