#include "sike.h"

int crypto_kem_keypair(unsigned char *pk, unsigned char *sk)
{
  // generate lower portion of secret key sk <- s||SK
  randombytes(sk, MSG_BYTES);
  random_mod_order_B(sk + MSG_BYTES);

  // generate public key pk
  EphemeralKeyGeneration_B(sk + MSG_BYTES, pk);

  // append public key pk to secret key sk
  memcpy(&sk[MSG_BYTES + SECRETKEY_B_BYTES], pk, CRYPTO_PUBLICKEYBYTES);

  return 0;
}

int crypto_kem_enc(unsigned char *ct, unsigned char *ss, const unsigned char *pk)
{
  unsigned char ephemeralsk[SECRETKEY_A_BYTES];
  unsigned char jinvariant[FP2_ENCODED_BYTES];
  unsigned char h[MSG_BYTES];
  unsigned char temp[CRYPTO_CIPHERTEXTBYTES+MSG_BYTES];

  // generate ephemeralsk <- G(m||pk) mod oA 
  randombytes(temp, MSG_BYTES);
  memcpy(&temp[MSG_BYTES], pk, CRYPTO_PUBLICKEYBYTES);
  shake256(ephemeralsk, SECRETKEY_A_BYTES, temp, CRYPTO_PUBLICKEYBYTES+MSG_BYTES);
  ephemeralsk[SECRETKEY_A_BYTES - 1] &= MASK_ALICE;

  // encrypt
  EphemeralKeyGeneration_A(ephemeralsk, ct);
  EphemeralSecretAgreement_A(ephemeralsk, pk, jinvariant);

  shake256(h, MSG_BYTES, jinvariant, FP2_ENCODED_BYTES);
  for (int i = 0; i < MSG_BYTES; i++) {
      ct[i + CRYPTO_PUBLICKEYBYTES] = temp[i] ^ h[i];
  }

  // generate shared secret ss <- H(m||ct)
  memcpy(&temp[MSG_BYTES], ct, CRYPTO_CIPHERTEXTBYTES);
  shake256(ss, CRYPTO_BYTES, temp, CRYPTO_CIPHERTEXTBYTES+MSG_BYTES);

  return 0;
}

int crypto_kem_dec(unsigned char *ss, const unsigned char *ct, const unsigned char *sk)
{
  unsigned char ephemeralsk_[SECRETKEY_A_BYTES];
  unsigned char jinvariant_[FP2_ENCODED_BYTES];
  unsigned char h_[MSG_BYTES];
  unsigned char c0_[CRYPTO_PUBLICKEYBYTES];
  unsigned char temp[CRYPTO_CIPHERTEXTBYTES+MSG_BYTES];

  // decrypt
  EphemeralSecretAgreement_B(sk + MSG_BYTES, ct, jinvariant_);
  shake256(h_, MSG_BYTES, jinvariant_, FP2_ENCODED_BYTES);
  for (int i = 0; i < MSG_BYTES; i++) {
      temp[i] = ct[i + CRYPTO_PUBLICKEYBYTES] ^ h_[i];
  }

  // generate ephemeralsk_ <- G(m||pk) mod oA
  memcpy(&temp[MSG_BYTES], &sk[MSG_BYTES + SECRETKEY_B_BYTES], CRYPTO_PUBLICKEYBYTES);
  shake256(ephemeralsk_, SECRETKEY_A_BYTES, temp, CRYPTO_PUBLICKEYBYTES+MSG_BYTES);
  ephemeralsk_[SECRETKEY_A_BYTES - 1] &= MASK_ALICE;
    
  // generate shared secret ss <- H(m||ct), or output ss <- H(s||ct) in case of ct verification failure
  EphemeralKeyGeneration_A(ephemeralsk_, c0_);
  // if selector = 0 then do ss = H(m||ct), else if selector = -1 load s to do ss = H(s||ct)
  int8_t selector = ct_compare(c0_, ct, CRYPTO_PUBLICKEYBYTES);
  ct_cmov(temp, sk, MSG_BYTES, selector);
  memcpy(&temp[MSG_BYTES], ct, CRYPTO_CIPHERTEXTBYTES);
  shake256(ss, CRYPTO_BYTES, temp, CRYPTO_CIPHERTEXTBYTES+MSG_BYTES);

  return 0;
}
