#ifndef CSIDH_H
#define CSIDH_H

#include <stdbool.h>

#include "params.h"

typedef struct private_key {
  int8_t e[NUM_PRIMES];
} private_key;

typedef struct public_key {
  fp A; /* Montgomery coefficient: represents y^2 = x^3 + Ax^2 + x */
} public_key;

typedef struct public_key_u64 {
  u64 A; /* Montgomery coefficient: represents y^2 = x^3 + Ax^2 + x */
} public_key_u64;

extern const public_key base;

void csidh_private(private_key *priv);
bool csidh(public_key_u64 *out, public_key_u64 const *in, private_key const *priv);

#endif
