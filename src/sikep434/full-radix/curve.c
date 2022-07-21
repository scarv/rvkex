#include "curve.h"


void copy_point(point_proj_t Q, const point_proj_t P)
{
  fp2copy(Q->X, P->X);
  fp2copy(Q->Z, P->Z);
}

void xDBL(const point_proj_t P, point_proj_t Q, const f2elm_t A24plus, const f2elm_t C24)
{
  f2elm_t t0, t1;
                                        //  range | computation 
  mp2_sub_p2(t0, P->X, P->Z);           // 2p->4p | t0 = X1-Z1 
  mp2_add(t1, P->X, P->Z);              // 2p->4p | t1 = X1+Z1
  fp2sqr_mont(t0, t0);                  // 4p->2p | t0 = (X1-Z1)^2
  fp2sqr_mont(t1, t1);                  // 4p->2p | t1 = (X1+Z1)^2
  fp2mul_mont(Q->Z, C24, t0);           // 2p->2p | Z2 = C24*(X1-Z1)^2
  fp2mul_mont(Q->X, t1, Q->Z);          // 2p->2p | X2 = C24*(X1-Z1)^2*(X1+Z1)^2
  mp2_sub_p2(t1, t1, t0);               // 2p->4p | t1 = (X1+Z1)^2-(X1-Z1)^2  
  fp2mul_mont(t0, A24plus, t1);         // 4p->2p | t0 = A24plus*[(X1+Z1)^2-(X1-Z1)^2]
  mp2_add(Q->Z, Q->Z, t0);              // 2p->4p | Z2 = A24plus*[(X1+Z1)^2-(X1-Z1)^2] + C24*(X1-Z1)^2
  fp2mul_mont(Q->Z, Q->Z, t1);          // 4p->2p | Z2 = [A24plus*[(X1+Z1)^2-(X1-Z1)^2] + C24*(X1-Z1)^2]*[(X1+Z1)^2-(X1-Z1)^2] 
}

void xDBLe(const point_proj_t P, point_proj_t Q, const f2elm_t A24plus, const f2elm_t C24, const int e)
{
  int i;

  copy_point(Q, P);
  for (i = 0; i < e; i++) xDBL(Q, Q, A24plus, C24);
}

void xTPL(const point_proj_t P, point_proj_t Q, const f2elm_t A24minus, const f2elm_t A24plus)
{
  f2elm_t t0, t1, t2, t3, t4, t5, t6;
                                        //  range | computation 
  mp2_sub_p2(t0, P->X, P->Z);           // 2p->4p | t0 = X-Z
  fp2sqr_mont(t2, t0);                  // 4p->2p | t2 = (X-Z)^2
  mp2_add(t1, P->X, P->Z);              // 2p->4p | t1 = X+Z 
  fp2sqr_mont(t3, t1);                  // 4p->2p | t3 = (X+Z)^2
  mp2_add(t4, P->X, P->X);              // 2p->4p | t4 = 2*X
  mp2_add(t0, P->Z, P->Z);              // 2p->4p | t0 = 2*Z
  fp2sqr_mont(t1, t4);                  // 4p->2p | t1 = 4*X^2
  mp2_sub_p2(t1, t1, t3);               // 2p->4p | t1 = 4*X^2 - (X+Z)^2
  mp2_sub_p2(t1, t1, t2);               // 4p->6p | t1 = 4*X^2 - (X+Z)^2 - (X-Z)^2
  fp2mul_mont(t5, A24plus, t3);         // 2p->2p | t5 = A24plus*(X+Z)^2
  fp2mul_mont(t3, t3, t5);              // 2p->2p | t3 = A24plus*(X+Z)^4
  fp2mul_mont(t6, A24minus, t2);        // 2p->2p | t6 = A24minus*(X-Z)^2
  fp2mul_mont(t2, t2, t6);              // 2p->2p | t2 = A24minus*(X-Z)^4
  mp2_sub_p2(t3, t2, t3);               // 2p->4p | t3 = A24minus*(X-Z)^4 - A24plus*(X+Z)^4
  mp2_sub_p2(t2, t5, t6);               // 2p->4p | t2 = A24plus*(X+Z)^2 - A24minus*(X-Z)^2
  fp2mul_mont(t1, t1, t2);              // 6p->2p | t1 = [4*X^2 - (X+Z)^2 - (X-Z)^2]*[A24plus*(X+Z)^2 - A24minus*(X-Z)^2]
  fp2add(t2, t3, t1);                   // 4p->2p | t2 = [4*X^2 - (X+Z)^2 - (X-Z)^2]*[A24plus*(X+Z)^2 - A24minus*(X-Z)^2] + A24minus*(X-Z)^4 - A24plus*(X+Z)^4
  fp2sqr_mont(t2, t2);                  // 2p->2p | t2 = t2^2
  fp2mul_mont(Q->X, t4, t2);            // 4p->2p | X3 = 2*X*t2
  fp2sub(t1, t3, t1);                   // 4p->2p | t1 = A24minus*(X-Z)^4 - A24plus*(X+Z)^4 - [4*X^2 - (X+Z)^2 - (X-Z)^2]*[A24plus*(X+Z)^2 - A24minus*(X-Z)^2]
  fp2sqr_mont(t1, t1);                  // 2p->2p | t1 = t1^2
  fp2mul_mont(Q->Z, t0, t1);            // 4p->2p | Z3 = 2*Z*t1
}

void xTPLe(const point_proj_t P, point_proj_t Q, const f2elm_t A24minus, const f2elm_t A24plus, const int e)
{
  int i;

  copy_point(Q, P);
  for (i = 0; i < e; i++) xTPL(Q, Q, A24minus, A24plus);
}

void get_4_isog(const point_proj_t P, f2elm_t A24plus, f2elm_t C24, f2elm_t *coeff)
{
                                            //  range | computation 
  mp2_sub_p2(coeff[1], P->X, P->Z);         // 2p->4p | coeff[1] = X4-Z4
  mp2_add(coeff[2], P->X, P->Z);            // 2p->4p | coeff[2] = X4+Z4
  fp2sqr_mont(coeff[0], P->Z);              // 2p->2p | coeff[0] = Z4^2
  mp2_add(coeff[0], coeff[0], coeff[0]);    // 2p->4p | coeff[0] = 2*Z4^2
  fp2sqr_mont(C24, coeff[0]);               // 4p->2p | C24 = 4*Z4^4 
  mp2_add(coeff[0], coeff[0], coeff[0]);    // 4p->8p | coeff[0] = 4*Z4^2
  fp2sqr_mont(A24plus, P->X);               // 2p->2p | A24plus = X4^2
  mp2_add(A24plus, A24plus, A24plus);       // 2p->4p | A24plus = 2*X4^2
  fp2sqr_mont(A24plus, A24plus);            // 4p->2p | A24plus = 4*X4^4 
}

void eval_4_isog(point_proj_t P, f2elm_t *coeff)
{
  f2elm_t t0, t1;
                                        //  range | computation 
  mp2_add(t0, P->X, P->Z);              // 2p->4p | t0 = X+Z
  mp2_sub_p2(t1, P->X, P->Z);           // 2p->4p | t1 = X-Z
  fp2mul_mont(P->X, t0, coeff[1]);      // 4p->2p | X  = (X+Z)*coeff[1]
  fp2mul_mont(P->Z, t1, coeff[2]);      // 4p->2p | Z  = (X-Z)*coeff[2]
  fp2mul_mont(t0, t0, t1);              // 4p->2p | t0 = (X+Z)*(X-Z)
  fp2mul_mont(t0, coeff[0], t0);        // 8p->2p | t0 = coeff[0]*(X+Z)*(X-Z)
  mp2_add(t1, P->X, P->Z);              // 2p->4p | t1 = (X-Z)*coeff[2] + (X+Z)*coeff[1]
  mp2_sub_p2(P->Z, P->X, P->Z);         // 2p->4p | Z  = (X-Z)*coeff[2] - (X+Z)*coeff[1]
  fp2sqr_mont(t1, t1);                  // 4p->2p | t1 = [(X-Z)*coeff[2] + (X+Z)*coeff[1]]^2
  fp2sqr_mont(P->Z, P->Z);              // 4p->2p | Z = [(X-Z)*coeff[2] - (X+Z)*coeff[1]]^2
  mp2_add(P->X, t1, t0);                // 2p->4p | X = coeff[0]*(X+Z)*(X-Z) + [(X-Z)*coeff[2] + (X+Z)*coeff[1]]^2
  mp2_sub_p2(t0, P->Z, t0);             // 2p->4p | t0 = [(X-Z)*coeff[2] - (X+Z)*coeff[1]]^2 - coeff[0]*(X+Z)*(X-Z)
  fp2mul_mont(P->X, P->X, t1);          // 4p->2p | Xfinal
  fp2mul_mont(P->Z, P->Z, t0);          // 4p->2p | Zfinal
}

void get_3_isog(const point_proj_t P, f2elm_t A24minus, f2elm_t A24plus, f2elm_t* coeff)
{
  f2elm_t t0, t1, t2, t3, t4;
                                        //  range | computation 
  mp2_sub_p2(coeff[0], P->X, P->Z);     // 2p->4p | coeff0 = X-Z
  fp2sqr_mont(t0, coeff[0]);            // 4p->2p | t0 = (X-Z)^2
  mp2_add(coeff[1], P->X, P->Z);        // 2p->4p | coeff1 = X+Z
  fp2sqr_mont(t1, coeff[1]);            // 4p->2p | t1 = (X+Z)^2
  mp2_add(t3, P->X, P->X);              // 2p->4p | t3 = 2*X
  fp2sqr_mont(t3, t3);                  // 4p->2p | t3 = 4*X^2 
  fp2sub(t2, t3, t0);                   // 2p->2p | t2 = 4*X^2 - (X-Z)^2 
  fp2sub(t3, t3, t1);                   // 2p->2p | t3 = 4*X^2 - (X+Z)^2
  mp2_add(t4, t0, t3);                  // 2p->4p | t4 = 4*X^2 - (X+Z)^2 + (X-Z)^2 
  mp2_add(t4, t4, t4);                  // 4p->8p | t4 = 2(4*X^2 - (X+Z)^2 + (X-Z)^2) 
  mp2_add(t4, t1, t4);                  // 8p->10p| t4 = 8*X^2 - (X+Z)^2 + 2*(X-Z)^2
  fp2mul_mont(A24minus, t2, t4);        //10p->2p | A24minus = [4*X^2 - (X-Z)^2]*[8*X^2 - (X+Z)^2 + 2*(X-Z)^2]
  mp2_add(t4, t1, t2);                  // 2p->4p | t4 = 4*X^2 + (X+Z)^2 - (X-Z)^2
  mp2_add(t4, t4, t4);                  // 4p->8p | t4 = 2(4*X^2 + (X+Z)^2 - (X-Z)^2) 
  mp2_add(t4, t0, t4);                  // 8p->10p| t4 = 8*X^2 + 2*(X+Z)^2 - (X-Z)^2
  fp2mul_mont(A24plus, t3, t4);         //10p->2p | A24plus = [4*X^2 - (X+Z)^2]*[8*X^2 + 2*(X+Z)^2 - (X-Z)^2]  
}

void eval_3_isog(point_proj_t Q, const f2elm_t *coeff)
{
  f2elm_t t0, t1, t2;
                                        //  range | computation
  mp2_add(t0, Q->X, Q->Z);              // 2p->4p | t0 = X+Z
  mp2_sub_p2(t1, Q->X, Q->Z);           // 2p->4p | t1 = X-Z
  fp2mul_mont(t0, coeff[0], t0);        // 4p->2p | t0 = coeff0*(X+Z)
  fp2mul_mont(t1, coeff[1], t1);        // 4p->2p | t1 = coeff1*(X-Z)
  mp2_add(t2, t0, t1);                  // 2p->4p | t2 = coeff0*(X+Z) + coeff1*(X-Z)
  mp2_sub_p2(t0, t1, t0);               // 2p->4p | t0 = coeff1*(X-Z) - coeff0*(X+Z)
  fp2sqr_mont(t2, t2);                  // 4p->2p | t2 = [coeff0*(X+Z) + coeff1*(X-Z)]^2
  fp2sqr_mont(t0, t0);                  // 4p->2p | t0 = [coeff1*(X-Z) - coeff0*(X+Z)]^2
  fp2mul_mont(Q->X, Q->X, t2);          // 2p->2p | X3final = X*[coeff0*(X+Z) + coeff1*(X-Z)]^2        
  fp2mul_mont(Q->Z, Q->Z, t0);          // 2p->2p | Z3final = Z*[coeff1*(X-Z) - coeff0*(X+Z)]^2   
}

void inv_3_way(f2elm_t r1, f2elm_t r2, f2elm_t r3)
{
  f2elm_t t0, t1, t2, t3;

  fp2mul_mont(t0, r1, r2);              // t0 = r1*r2
  fp2mul_mont(t1, r3, t0);              // t1 = r1*r2*r3
  fp2inv_mont(t1);                      // t1 = 1/(r1*r2*r3)
  fp2mul_mont(t2, r3, t1);              // t2 = 1/(r1*r2) 
  fp2mul_mont(t3, t2, r2);              // t3 = 1/r1
  fp2mul_mont(r2, t2, r1);              // r2 = 1/r2
  fp2mul_mont(r3, t0, t1);              // r3 = 1/r3
  fp2copy(r1, t3);                      // z1 = 1/z1
}

void get_A(const f2elm_t xP, const f2elm_t xQ, const f2elm_t xR, f2elm_t A)
{
  f2elm_t t0, t1, one = { 0 };

  fpcopy(one[0], mont_R);               // one = 1
  fp2add(t1, xP, xQ);                   // t1 = xP+xQ
  fp2mul_mont(t0, xP, xQ);              // t0 = xP*xQ
  fp2mul_mont(A, xR, t1);               // A = xR*t1
  fp2add(A, t0, A);                     // A = A+t0
  fp2mul_mont(t0, t0, xR);              // t0 = t0*xR
  fp2sub(A, A, one);                    // A = A-1
  fp2add(t0, t0, t0);                   // t0 = t0+t0
  fp2add(t1, t1, xR);                   // t1 = t1+xR
  fp2add(t0, t0, t0);                   // t0 = t0+t0
  fp2sqr_mont(A, A);                    // A = A^2
  fp2inv_mont(t0);                      // t0 = 1/t0
  fp2mul_mont(A, A, t0);                // A = A*t0
  fp2sub(A, A, t1);                     // Afinal = A-t1
}

void j_inv(const f2elm_t A, const f2elm_t C, f2elm_t jinv)
{
  f2elm_t t0, t1;

  fp2sqr_mont(jinv, A);                 // jinv = A^2        
  fp2sqr_mont(t1, C);                   // t1 = C^2
  fp2add(t0, t1, t1);                   // t0 = t1+t1
  fp2sub(t0, jinv, t0);                 // t0 = jinv-t0
  fp2sub(t0, t0, t1);                   // t0 = t0-t1
  fp2sub(jinv, t0, t1);                 // jinv = t0-t1
  fp2sqr_mont(t1, t1);                  // t1 = t1^2
  fp2mul_mont(jinv, jinv, t1);          // jinv = jinv*t1
  fp2add(t0, t0, t0);                   // t0 = t0+t0
  fp2add(t0, t0, t0);                   // t0 = t0+t0
  fp2sqr_mont(t1, t0);                  // t1 = t0^2
  fp2mul_mont(t0, t0, t1);              // t0 = t0*t1
  fp2add(t0, t0, t0);                   // t0 = t0+t0
  fp2add(t0, t0, t0);                   // t0 = t0+t0
  fp2inv_mont(jinv);                    // jinv = 1/jinv 
  fp2mul_mont(jinv, jinv, t0);          // jinv = t0*jinv
}

void xDBLADD(point_proj_t P, point_proj_t Q, const f2elm_t XPQ, const f2elm_t ZPQ, const f2elm_t A24)
{
  f2elm_t t0, t1, t2;
                                        //  range | computation
  mp2_add(t0, P->X, P->Z);              // 2p->4p | t0 = XP+ZP   
  mp2_sub_p2(t1, P->X, P->Z);           // 2p->4p | t1 = XP-ZP
  fp2sqr_mont(P->X, t0);                // 4p->2p | XP = (XP+ZP)^2
  mp2_sub_p2(t2, Q->X, Q->Z);           // 2p->4p | t2 = XQ-ZQ
  mp2_add(Q->X, Q->X, Q->Z);            // 2p->4p | XQ = XQ+ZQ
  fp2mul_mont(t0, t0, t2);              // 4p->2p | t0 = (XP+ZP)*(XQ-ZQ)
  fp2sqr_mont(P->Z, t1);                // 4p->2p | ZP = (XP-ZP)^2  
  fp2mul_mont(t1, t1, Q->X);            // 4p->2p | t1 = (XP-ZP)*(XQ+ZQ)
  mp2_sub_p2(t2, P->X, P->Z);           // 2p->4p | t2 = (XP+ZP)^2-(XP-ZP)^2
  fp2mul_mont(P->X, P->X, P->Z);        // 2p->2p | XP = (XP+ZP)^2*(XP-ZP)^2
  fp2mul_mont(Q->X, A24, t2);           // 4p->2p | XQ = A24*[(XP+ZP)^2-(XP-ZP)^2]
  mp2_sub_p2(Q->Z, t0, t1);             // 2p->4p | ZQ = (XP+ZP)*(XQ-ZQ)-(XP-ZP)*(XQ+ZQ)
  mp2_add(P->Z, Q->X, P->Z);            // 2p->4p | ZP = A24*[(XP+ZP)^2-(XP-ZP)^2]+(XP-ZP)^2
  mp2_add(Q->X, t0, t1);                // 2p->4p | XQ = (XP+ZP)*(XQ-ZQ)+(XP-ZP)*(XQ+ZQ)  
  fp2mul_mont(P->Z, P->Z, t2);          // 4p->2p | ZP = [A24*[(XP+ZP)^2-(XP-ZP)^2]+(XP-ZP)^2]*[(XP+ZP)^2-(XP-ZP)^2]
  fp2sqr_mont(Q->Z, Q->Z);              // 4p->2p | ZQ = [(XP+ZP)*(XQ-ZQ)-(XP-ZP)*(XQ+ZQ)]^2
  fp2sqr_mont(Q->X, Q->X);              // 4p->2p | XQ = [(XP+ZP)*(XQ-ZQ)+(XP-ZP)*(XQ+ZQ)]^2
  fp2mul_mont(Q->Z, Q->Z, XPQ);         // 2p->2p | ZQ = xPQ*[(XP+ZP)*(XQ-ZQ)-(XP-ZP)*(XQ+ZQ)]^2
  fp2mul_mont(Q->X, Q->X, ZPQ);         // 2p->2p | XQ = ZPQ*[(XP+ZP)*(XQ-ZQ)+(XP-ZP)*(XQ+ZQ)]^2 
}

static void swap_points(point_proj_t P, point_proj_t Q, const uint64_t option)
{
  uint64_t temp;
  int i;

  for (i = 0; i < NLMB64; i++) {
    temp = option & (P->X[0][i] ^ Q->X[0][i]);
    P->X[0][i] = temp ^ P->X[0][i]; 
    Q->X[0][i] = temp ^ Q->X[0][i];  
    temp = option & (P->X[1][i] ^ Q->X[1][i]);
    P->X[1][i] = temp ^ P->X[1][i]; 
    Q->X[1][i] = temp ^ Q->X[1][i];
    temp = option & (P->Z[0][i] ^ Q->Z[0][i]);
    P->Z[0][i] = temp ^ P->Z[0][i]; 
    Q->Z[0][i] = temp ^ Q->Z[0][i];
    temp = option & (P->Z[1][i] ^ Q->Z[1][i]);
    P->Z[1][i] = temp ^ P->Z[1][i]; 
    Q->Z[1][i] = temp ^ Q->Z[1][i]; 
  }
}

void LADDER3PT(const f2elm_t xP, const f2elm_t xQ, const f2elm_t xPQ, const uint64_t* m, const unsigned int AliceOrBob, point_proj_t R, const f2elm_t A)
{
  point_proj_t R0 = { 0 }, R2 = { 0 };
  f2elm_t A24 = { 0 };
  uint64_t mask, i, nbits, bit, swap, prevbit = 0;

  if (AliceOrBob == ALICE) nbits = OALICE_BITS;
  else                     nbits = OBOB_BITS - 1;

  // initializing constant
  fpcopy(A24[0], mont_R);               // A24 = 1
  mp2_add(A24, A24, A24);               // A24 = 2
  mp2_add(A24, A, A24);                 // A24 = A + 2
  fp2div2(A24, A24);                    // A24 = (A+2)/2
  fp2div2(A24, A24);                    // A24 = (A+2)/4  

  // initializing points
  fp2copy(R0->X, xQ);                   // R0 = (xQ,  1)
  fpcopy(R0->Z[0], mont_R);
  fp2copy(R2->X, xPQ);                  // R2 = (xPQ, 1)
  fpcopy(R2->Z[0], mont_R);
  fp2copy(R->X, xP);                    // R  = (xP,  1)
  fpcopy(R->Z[0], mont_R);
  fpzero(R->Z[1]);

  // main loop
  for (i = 0; i < nbits; i++) {
    bit = (m[i>>6]>>(i&63)) & 1;
    swap = bit ^ prevbit;
    prevbit = bit;
    mask = 0 - swap;

    swap_points(R, R2, mask);
    xDBLADD(R0, R2, R->X, R->Z, A24);
  }
  swap = 0 ^ prevbit;
  mask = 0 - swap;
  swap_points(R, R2, mask);
}
