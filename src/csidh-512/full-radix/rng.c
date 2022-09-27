
#include "rng.h"

#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

#if defined( DRIVER_RANDOM )
void randombytes(void *x, size_t l)
{
    static int fd = -1;
    ssize_t n;
    if (fd < 0 && 0 > (fd = open("/dev/urandom", O_RDONLY)))
        exit(1);
    for (size_t i = 0; i < l; i += n)
        if (0 >= (n = read(fd, (char *) x + i, l - i)))
            exit(2);
}
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
