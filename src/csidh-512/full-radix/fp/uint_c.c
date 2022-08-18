
#include <string.h>
#include <stddef.h>
#include <assert.h>

#include "../params.h"
#include "../fp.h"
#include "../rng.h"

/* assumes little-endian throughout. */

fp const uint_0 = {{0}};
fp const uint_1 = {{1}};

bool uint_eq(fp const *x, fp const *y)
{
    uint64_t r = 0;
    for (size_t k = 0; k < LIMBS; ++k)
        r |= x->c[k] ^ y->c[k];
    return !r;
}

void uint_set(fp *x, uint64_t y)
{
    x->c[0] = y;
    for (size_t i = 1; i < LIMBS; ++i)
        x->c[i] = 0;
}

size_t uint_len(fp const *x)
{
    for (size_t i = LIMBS - 1, j; i < LIMBS; --i) {
        uint64_t v = x->c[i];
        if (!v) continue;
        for (j = 0; v; ++j, v >>= 1);
        return 64*i+j;
    }
    return 0;
}

bool uint_bit(fp const *x,  uint64_t k)
{
    return 1 & (x->c[k / 64] >> k % 64);
}


bool uint_add3(fp *x, fp const *y, fp const *z)
{
    bool c = 0;
    for (size_t i = 0; i < LIMBS; ++i) {
        uint64_t t;
        c = __builtin_add_overflow(y->c[i], c, &t);
        c |= __builtin_add_overflow(t, z->c[i], &x->c[i]);
    }
    return c;
}

bool uint_sub3(fp *x, fp const *y, fp const *z)
{
    bool b = 0;
    for (size_t i = 0; i < LIMBS; ++i) {
        uint64_t t;
        b = __builtin_sub_overflow(y->c[i], b, &t);
        b |= __builtin_sub_overflow(t, z->c[i], &x->c[i]);
    }
    return b;
}


void uint_mul3_64(fp *x, fp const *y, uint64_t z)
{
    uint64_t c = 0;
    for (size_t i = 0; i < LIMBS; ++i) {
        __uint128_t t = y->c[i] * (__uint128_t) z + c;
        c = t >> 64;
        x->c[i] = t;
    }
}


void uint_random(fp *x, fp const *m)
{
    if (!m) {
        randombytes(x, sizeof(*x));
        return;
    }

    assert(memcmp(m, &uint_0, sizeof(*m)));

    const size_t bits = uint_len(m);
    const uint64_t mask = ((uint64_t) 1 << bits % 64) - 1;

    while (true) {

        *x = uint_0;
        randombytes(x, (bits+7)/8);

        if (bits < 64*LIMBS)
            x->c[bits/64] &= mask;

        for (size_t i = LIMBS-1; i < LIMBS; --i) {
            if (x->c[i] < m->c[i])
                return;
            else if (x->c[i] > m->c[i])
                break;
        }
    }
}

