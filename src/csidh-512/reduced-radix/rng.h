#ifndef RNG_H
#define RNG_H

#include <stdlib.h>
#include <stdint.h>

<<<<<<< HEAD
#if defined( DRIVER_RANDOM )
void randombytes(void *x, size_t l);
#else
void rand_bytes_init();
=======
void rand_bytes(uint8_t* x, int n);
>>>>>>> 003070752b495ed49c0345f9bb8860ffbdc96529
void randombytes(void *x, size_t l);

#endif
#endif
