#include "sidh.h"


static void init_basis(uint64_t *gen, f2elm_t XP, f2elm_t XQ, f2elm_t XR)
{
  fpcopy(XP[0], gen           );
  fpcopy(XP[1], gen +   NLMB64);
  fpcopy(XQ[0], gen + 2*NLMB64);
  fpcopy(XQ[1], gen + 3*NLMB64);
  fpcopy(XR[0], gen + 4*NLMB64);
  fpcopy(XR[1], gen + 5*NLMB64);
}

void random_mod_order_B(unsigned char* random_digits)
{
  randombytes(random_digits, SECRETKEY_B_BYTES);
  random_digits[SECRETKEY_B_BYTES-1] &= MASK_BOB;
}

void EphemeralKeyGeneration_A(const unsigned char* PrivateKeyA, unsigned char* PublicKeyA)
{
  point_proj_t R, phiP = { 0 }, phiQ = { 0 }, phiR = { 0 }, pts[MAX_INT_POINTS_ALICE];
  f2elm_t XPA, XQA, XRA, coeff[3], A24plus = { 0 }, C24 = { 0 }, A = { 0 };
  int i, row, m, index = 0, pts_index[MAX_INT_POINTS_ALICE], npts = 0, ii = 0;
  uint64_t SecretKeyA[NWORDS_ORDER] = { 0 };

  // initialize basis points
  init_basis((uint64_t *)A_gen, XPA, XQA, XRA);
  init_basis((uint64_t *)B_gen, phiP->X, phiQ->X, phiR->X);
  fpcopy(phiP->Z[0], mont_R);
  fpcopy(phiQ->Z[0], mont_R);
  fpcopy(phiR->Z[0], mont_R);

  // initialize constants: A24plus = A+2C, C24 = 4C, where A=6, C=1
  fpcopy(A24plus[0], mont_R);           // A24plus = 1
  mp2_add(A24plus, A24plus, A24plus);   // A24plus = 2
  mp2_add(C24, A24plus, A24plus);       // C24     = 4
  mp2_add(A, A24plus, C24);             // A       = 6
  mp2_add(A24plus, C24, C24);           // A24plus = 8

  // retrieve kernel point
  decode_to_digits(PrivateKeyA, SecretKeyA, SECRETKEY_A_BYTES, NWORDS_ORDER);
  LADDER3PT(XPA, XQA, XRA, SecretKeyA, ALICE, R, A);

  // traverse tree
  index = 0;
  for (row = 1; row < MAX_Alice; row++) {
    while (index < MAX_Alice-row) {
      copy_point(pts[npts], R);
      pts_index[npts++] = index;
      m = strat_Alice[ii++];
      xDBLe(R, R, A24plus, C24, 2*m);
      index += m;
    }
    get_4_isog(R, A24plus, C24, coeff);

    for (i = 0; i < npts; i++) eval_4_isog(pts[i], coeff);
    eval_4_isog(phiP, coeff);
    eval_4_isog(phiQ, coeff);
    eval_4_isog(phiR, coeff);

    copy_point(R, pts[npts-1]);
    index = pts_index[npts-1];
    npts -= 1;
  }

  get_4_isog(R, A24plus, C24, coeff);
  eval_4_isog(phiP, coeff);
  eval_4_isog(phiQ, coeff);
  eval_4_isog(phiR, coeff);

  inv_3_way(phiP->Z, phiQ->Z, phiR->Z);
  fp2mul_mont(phiP->X, phiP->X, phiP->Z);
  fp2mul_mont(phiQ->X, phiQ->X, phiQ->Z);
  fp2mul_mont(phiR->X, phiR->X, phiR->Z);

  fp2_encode(phiP->X, PublicKeyA);
  fp2_encode(phiQ->X, PublicKeyA + FP2_ENCODED_BYTES);
  fp2_encode(phiR->X, PublicKeyA + 2*FP2_ENCODED_BYTES);
}

void EphemeralKeyGeneration_B(const unsigned char* PrivateKeyB, unsigned char* PublicKeyB)
{
  point_proj_t R, phiP = { 0 }, phiQ = { 0 }, phiR = { 0 }, pts[MAX_INT_POINTS_BOB];
  f2elm_t XPB, XQB, XRB, coeff[3], A24plus = { 0 }, A24minus = { 0 }, A = { 0 };
  int i, row, m, index = 0, pts_index[MAX_INT_POINTS_BOB], npts = 0, ii = 0;
  uint64_t SecretKeyB[NWORDS_ORDER] = { 0 };

  // initialize basis points 
  init_basis((uint64_t *)B_gen, XPB, XQB, XRB);
  init_basis((uint64_t *)A_gen, phiP->X, phiQ->X, phiR->X);
  fpcopy(phiP->Z[0], mont_R);
  fpcopy(phiQ->Z[0], mont_R);
  fpcopy(phiR->Z[0], mont_R);

  // initialize constants: A24minus = A-2C, A24plus = A+2C, where A=6, C=1
  fpcopy(A24plus[0], mont_R);           // A24plus  = 1
  mp2_add(A24plus, A24plus, A24plus);   // A24plus  = 2
  mp2_add(A24minus, A24plus, A24plus);  // A24minus = 4
  mp2_add(A, A24plus, A24minus);        // A        = 6
  mp2_add(A24plus, A24minus, A24minus); // A24plus  = 8

  // retrieve kernel point
  decode_to_digits(PrivateKeyB, SecretKeyB, SECRETKEY_B_BYTES, NWORDS_ORDER);
  LADDER3PT(XPB, XQB, XRB, SecretKeyB, BOB, R, A);

  // traverse tree
  index = 0;
  for (row = 1; row < MAX_Bob; row++) {
    while (index < MAX_Bob-row) {
      copy_point(pts[npts], R);
      pts_index[npts++] = index;
      m = strat_Bob[ii++];
      xTPLe(R, R, A24minus, A24plus, m);
      index += m;
    }

    get_3_isog(R, A24minus, A24plus, coeff);

    for (i = 0; i < npts; i++) eval_3_isog(pts[i], coeff);
    eval_3_isog(phiP, coeff);
    eval_3_isog(phiQ, coeff);
    eval_3_isog(phiR, coeff);

    copy_point(R, pts[npts-1]);
    index = pts_index[npts-1];
    npts -= 1;
  }

  get_3_isog(R, A24minus, A24plus, coeff);
  eval_3_isog(phiP, coeff);
  eval_3_isog(phiQ, coeff);
  eval_3_isog(phiR, coeff);

  inv_3_way(phiP->Z, phiQ->Z, phiR->Z);
  fp2mul_mont(phiP->X, phiP->X, phiP->Z);
  fp2mul_mont(phiQ->X, phiQ->X, phiQ->Z);
  fp2mul_mont(phiR->X, phiR->X, phiR->Z);

  fp2_encode(phiP->X, PublicKeyB);
  fp2_encode(phiQ->X, PublicKeyB + FP2_ENCODED_BYTES);
  fp2_encode(phiR->X, PublicKeyB + 2*FP2_ENCODED_BYTES);
}

void EphemeralSecretAgreement_A(const unsigned char* PrivateKeyA, const unsigned char* PublicKeyB, unsigned char* SharedSecretA)
{
  point_proj_t R, pts[MAX_INT_POINTS_ALICE];
  f2elm_t coeff[3], PKB[3], jinv;
  f2elm_t A24plus = { 0 }, C24 = { 0 }, A = { 0 };
  int i, row, m, index = 0, pts_index[MAX_INT_POINTS_ALICE], npts = 0, ii = 0;
  uint64_t SecretKeyA[NWORDS_ORDER] = { 0 };
      
  // initialize images of Bob's basis
  fp2_decode(PublicKeyB, PKB[0]);
  fp2_decode(PublicKeyB + FP2_ENCODED_BYTES, PKB[1]);
  fp2_decode(PublicKeyB + 2*FP2_ENCODED_BYTES, PKB[2]);

  // Initialize constants: A24plus = A+2C, C24 = 4C, where C=1
  get_A(PKB[0], PKB[1], PKB[2], A);
  mp_add(C24[0], mont_R, mont_R);       // C24 = 2C
  mp2_add(A24plus, A, C24);             // A24plus = A+2C
  mp_add(C24[0], C24[0], C24[0]);       // C24 = 4C

  // retrieve kernel point 
  decode_to_digits(PrivateKeyA, SecretKeyA, SECRETKEY_A_BYTES, NWORDS_ORDER);
  LADDER3PT(PKB[0], PKB[1], PKB[2], SecretKeyA, ALICE, R, A); 

  // traverse tree 
  index = 0;
  for (row = 1; row < MAX_Alice; row++) {
    while (index < MAX_Alice-row) {
      copy_point(pts[npts], R);
      pts_index[npts++] = index;
      m = strat_Alice[ii++];
      xDBLe(R, R, A24plus, C24, 2*m);
      index += m;
    }
    get_4_isog(R, A24plus, C24, coeff);

    for (i = 0; i < npts; i++) eval_4_isog(pts[i], coeff);

    copy_point(R, pts[npts-1]);
    index = pts_index[npts-1];
    npts -= 1;
  }

  get_4_isog(R, A24plus, C24, coeff); 
  mp2_add(A24plus, A24plus, A24plus);
  fp2sub(A24plus, A24plus, C24);
  fp2add(A24plus, A24plus, A24plus);
  j_inv(A24plus, C24, jinv);
  fp2_encode(jinv, SharedSecretA);
}

void EphemeralSecretAgreement_B(const unsigned char* PrivateKeyB, const unsigned char* PublicKeyA, unsigned char* SharedSecretB)
{
  point_proj_t R, pts[MAX_INT_POINTS_BOB];
  f2elm_t coeff[3], PKB[3], jinv;
  f2elm_t A24plus = { 0 }, A24minus = { 0 }, A = { 0 };
  int i, row, m, index = 0, pts_index[MAX_INT_POINTS_BOB], npts = 0, ii = 0;
  uint64_t SecretKeyB[NWORDS_ORDER] = { 0 };

  // initialize images of Alice's basis
  fp2_decode(PublicKeyA, PKB[0]);
  fp2_decode(PublicKeyA + FP2_ENCODED_BYTES, PKB[1]);
  fp2_decode(PublicKeyA + 2*FP2_ENCODED_BYTES, PKB[2]);

  // initialize constants: A24plus = A+2C, A24minus = A-2C, where C=1
  get_A(PKB[0], PKB[1], PKB[2], A);
  mp_add(A24minus[0], mont_R, mont_R);  // A24minus = 2C
  mp2_add(A24plus, A, A24minus);        // A24plus  = A+2C
  mp2_sub_p2(A24minus, A, A24minus);    // A24minus = A-2C

  // retrieve kernel point
  decode_to_digits(PrivateKeyB, SecretKeyB, SECRETKEY_B_BYTES, NWORDS_ORDER);
  LADDER3PT(PKB[0], PKB[1], PKB[2], SecretKeyB, BOB, R, A);

  // traverse tree 
  index = 0;
  for (row = 1; row < MAX_Bob; row++) {
    while (index < MAX_Bob-row) {
      copy_point(pts[npts], R);
      pts_index[npts++] = index;
      m = strat_Bob[ii++];
      xTPLe(R, R, A24minus, A24plus, m);
      index += m;
    }
    get_3_isog(R, A24minus, A24plus, coeff);

    for (i = 0; i < npts; i++) eval_3_isog(pts[i], coeff);

    copy_point(R, pts[npts-1]);
    index = pts_index[npts-1];
    npts -= 1;
  }

  get_3_isog(R, A24minus, A24plus, coeff);
  fp2add(A, A24plus, A24minus); 
  fp2add(A, A, A); 
  fp2sub(A24plus, A24plus, A24minus);      
  j_inv(A, A24plus, jinv);
  fp2_encode(jinv, SharedSecretB);
}
