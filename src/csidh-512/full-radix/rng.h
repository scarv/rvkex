#ifndef RNG_H
#define RNG_H
#include <stdint.h>
#include <stdlib.h>
#include <stdint.h>

#if defined( DRIVER_RANDOM )
void randombytes(void *x, size_t l);
#else
void rand_bytes_init();
void randombytes(void *x, size_t l);
#endif

#endif
