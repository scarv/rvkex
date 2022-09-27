#ifndef RNG_H
#define RNG_H

#include <stdlib.h>

#if defined( DRIVER_RANDOM )
void randombytes(void *x, size_t l);
#else
void rand_bytes_init();
void randombytes(void *x, size_t l);

#endif
#endif
