
#include "rng.h"

// #include <stdlib.h>
// #include <unistd.h>
// #include <fcntl.h>

// void randombytes(void *x, size_t l)
// {
//     static int fd = -1;
//     ssize_t n;
//     if (fd < 0 && 0 > (fd = open("/dev/urandom", O_RDONLY)))
//         exit(1);
//     for (size_t i = 0; i < l; i += n)
//         if (0 >= (n = read(fd, (char *) x + i, l - i)))
//             exit(2);
// }

#if defined( DRIVER_RANDOM )
FILE* rand_bytes_prg = NULL;

void rand_bytes_init() {
  if( NULL == ( rand_bytes_prg = fopen( "/dev/urandom", "rb" ) ) ) {
    abort();
  }
}

void rand_bytes_fini() {
  fclose( rand_bytes_prg );
}

void rand_bytes(           uint8_t* x, int n ) {
  if( n != fread( x, sizeof( uint8_t ), n, rand_bytes_prg ) ) {
    abort();
  }
}
#else
void rand_bytes_init() {
  srand( 0 );
}

void rand_bytes_fini() {

}

void rand_bytes(           uint8_t* x, int n ) {
  for( int i = 0; i < n; i++ ) {
    x[ i ] = rand() & 0xFF;
  }
}
#endif

#if defined( DRIVER_RANDOM )
void randombytes(void *x, size_t l)
{
  rand_bytes(x, l);
}
<<<<<<< HEAD
#else
void rand_bytes_init() {
  srand( 0 );
}

void randombytes(void * x, size_t l ) {
  char * t;
  t = (char *) x;
  for( int i = 0; i < l; i++ ) {
    t[i] = rand() & 0xFF;
  }
}

#endif
=======
>>>>>>> 003070752b495ed49c0345f9bb8860ffbdc96529
