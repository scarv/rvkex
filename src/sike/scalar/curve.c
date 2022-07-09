#include "curve.h"


void copy_point(point_proj_t Q, const point_proj_t P)
{
  fp2copy(Q->X, P->X);
  fp2copy(Q->Z, P->Z);
}

void xDBL_v0(const point_proj_t P, point_proj_t Q, const f2elm_t A24plus, const f2elm_t C24)
{
  f2elm_t t0, t1;
                                        //  range | limb-length | computation 
  mp2_sub_p2_v0(t0, P->X, P->Z);        // 2p->4p |  56    ->56 | t0 = X1-Z1 
  mp2_add_v0(t1, P->X, P->Z);           // 2p->4p |  56    ->56 | t1 = X1+Z1
  fp2sqr_mont_v0(t0, t0);               // 4p->2p |  56->56->56 | t0 = (X1-Z1)^2
  fp2sqr_mont_v0(t1, t1);               // 4p->2p |  56->56->56 | t1 = (X1+Z1)^2
  fp2mul_mont_v0(Q->Z, C24, t0);        // 2p->2p |  56->56->56 | Z2 = C24*(X1-Z1)^2
  fp2mul_mont_v0(Q->X, t1, Q->Z);       // 2p->2p |  56->56->56 | X2 = C24*(X1-Z1)^2*(X1+Z1)^2
  mp2_sub_p2_v0(t1, t1, t0);            // 2p->4p |  56    ->56 | t1 = (X1+Z1)^2-(X1-Z1)^2  
  fp2mul_mont_v0(t0, A24plus, t1);      // 4p->2p |  56->56->56 | t0 = A24plus*[(X1+Z1)^2-(X1-Z1)^2]
  mp2_add_v0(Q->Z, Q->Z, t0);           // 2p->4p |  56    ->56 | Z2 = A24plus*[(X1+Z1)^2-(X1-Z1)^2] + C24*(X1-Z1)^2
  fp2mul_mont_v0(Q->Z, Q->Z, t1);       // 4p->2p |  56->56->56 | Z2 = [A24plus*[(X1+Z1)^2-(X1-Z1)^2] + C24*(X1-Z1)^2]*[(X1+Z1)^2-(X1-Z1)^2] 
}

void xDBL_v1(const point_proj_t P, point_proj_t Q, const f2elm_t A24plus, const f2elm_t C24)
{
  f2elm_t t0, t1;
                                        //  range | limb-length | computation 
  mp2_sub_p2_v0(t0, P->X, P->Z);        // 2p->4p |  56    ->56 | t0 = X1-Z1 
  mp2_add_v1(t1, P->X, P->Z);           // 2p->4p |  56    ->57 | t1 = X1+Z1
  fp2sqr_mont_v1(t0, t0);               // 4p->2p |  56->57->56 | t0 = (X1-Z1)^2
  fp2sqr_mont_v1(t1, t1);               // 4p->2p |  57->58->56 | t1 = (X1+Z1)^2
  fp2mul_mont_v1(Q->Z, C24, t0);        // 2p->2p |  56->57->56 | Z2 = C24*(X1-Z1)^2
  fp2mul_mont_v1(Q->X, t1, Q->Z);       // 2p->2p |  56->57->56 | X2 = C24*(X1-Z1)^2*(X1+Z1)^2
  mp2_sub_p2_v0(t1, t1, t0);            // 2p->4p |  56    ->56 | t1 = (X1+Z1)^2-(X1-Z1)^2  
  fp2mul_mont_v1(t0, A24plus, t1);      // 4p->2p |  56    ->56 | t0 = A24plus*[(X1+Z1)^2-(X1-Z1)^2]
  mp2_add_v1(Q->Z, Q->Z, t0);           // 2p->4p |  56    ->57 | Z2 = A24plus*[(X1+Z1)^2-(X1-Z1)^2] + C24*(X1-Z1)^2
  fp2mul_mont_v1(Q->Z, Q->Z, t1);       // 4p->2p |  56,57 ->56 | Z2 = [A24plus*[(X1+Z1)^2-(X1-Z1)^2] + C24*(X1-Z1)^2]*[(X1+Z1)^2-(X1-Z1)^2] 
}

// NOTE: This `xDBL_v2` needs to be carefully checked whether it will cause 
// overflow when being used in higher layers, we therefore use `xDBL_v1` by 
// default for now. Additionally, it will be very possible to cause overflow if 
// we have and use `fp2sqr_mont_v2` (using `mp_sub_p4_v1`). The limb-length 
// during the computation will be max 61 bits (now 59 bits), so we don't develop 
// the `mp_sub_p4_v1`. 
void xDBL_v2(const point_proj_t P, point_proj_t Q, const f2elm_t A24plus, const f2elm_t C24)
{
  f2elm_t t0, t1;
                                        //  range | limb-length | computation 
  mp2_sub_p2_v1(t0, P->X, P->Z);        // 2p->4p |  56    ->58 | t0 = X1-Z1 
  mp2_add_v1(t1, P->X, P->Z);           // 2p->4p |  56    ->57 | t1 = X1+Z1
  fp2sqr_mont_v1(t0, t0);               // 4p->2p |  58->59->56 | t0 = (X1-Z1)^2
  fp2sqr_mont_v1(t1, t1);               // 4p->2p |  57->58->56 | t1 = (X1+Z1)^2
  fp2mul_mont_v1(Q->Z, C24, t0);        // 2p->2p |  56->57->56 | Z2 = C24*(X1-Z1)^2
  fp2mul_mont_v1(Q->X, t1, Q->Z);       // 2p->2p |  56->57->56 | X2 = C24*(X1-Z1)^2*(X1+Z1)^2
  mp2_sub_p2_v1(t1, t1, t0);            // 2p->4p |  56    ->58 | t1 = (X1+Z1)^2-(X1-Z1)^2  
  fp2mul_mont_v1(t0, A24plus, t1);      // 4p->2p |  56,58 ->56 | t0 = A24plus*[(X1+Z1)^2-(X1-Z1)^2]
  mp2_add_v1(Q->Z, Q->Z, t0);           // 2p->4p |  56    ->57 | Z2 = A24plus*[(X1+Z1)^2-(X1-Z1)^2] + C24*(X1-Z1)^2
  fp2mul_mont_v1(Q->Z, Q->Z, t1);       // 4p->2p |  56,57 ->56 | Z2 = [A24plus*[(X1+Z1)^2-(X1-Z1)^2] + C24*(X1-Z1)^2]*[(X1+Z1)^2-(X1-Z1)^2] 
}

void xDBLe(const point_proj_t P, point_proj_t Q, const f2elm_t A24plus, const f2elm_t C24, const int e)
{
  int i;

  copy_point(Q, P);
  for (i = 0; i < e; i++) xDBL(Q, Q, A24plus, C24);
}

void xTPL_v0(const point_proj_t P, point_proj_t Q, const f2elm_t A24minus, const f2elm_t A24plus)
{
  f2elm_t t0, t1, t2, t3, t4, t5, t6;
                                        //  range | limb-length | computation 
  mp2_sub_p2_v0(t0, P->X, P->Z);        // 2p->4p |  56    ->56 | t0 = X-Z
  fp2sqr_mont_v0(t2, t0);               // 4p->2p |  56->56->56 | t2 = (X-Z)^2
  mp2_add_v0(t1, P->X, P->Z);           // 2p->4p |  56    ->56 | t1 = X+Z 
  fp2sqr_mont_v0(t3, t1);               // 4p->2p |  56->56->56 | t3 = (X+Z)^2
  mp2_add_v0(t4, P->X, P->X);           // 2p->4p |  56    ->56 | t4 = 2*X
  mp2_add_v0(t0, P->Z, P->Z);           // 2p->4p |  56    ->56 | t0 = 2*Z
  fp2sqr_mont_v0(t1, t4);               // 4p->2p |  56->56->56 | t1 = 4*X^2
  mp2_sub_p2_v0(t1, t1, t3);            // 2p->4p |  56    ->56 | t1 = 4*X^2 - (X+Z)^2
  mp2_sub_p2_v0(t1, t1, t2);            // 4p->6p |  56    ->56 | t1 = 4*X^2 - (X+Z)^2 - (X-Z)^2
  fp2mul_mont_v0(t5, A24plus, t3);      // 2p->2p |  56->56->56 | t5 = A24plus*(X+Z)^2
  fp2mul_mont_v0(t3, t3, t5);           // 2p->2p |  56->56->56 | t3 = A24plus*(X+Z)^4
  fp2mul_mont_v0(t6, A24minus, t2);     // 2p->2p |  56->56->56 | t6 = A24minus*(X-Z)^2
  fp2mul_mont_v0(t2, t2, t6);           // 2p->2p |  56->56->56 | t2 = A24minus*(X-Z)^4
  mp2_sub_p2_v0(t3, t2, t3);            // 2p->4p |  56    ->56 | t3 = A24minus*(X-Z)^4 - A24plus*(X+Z)^4
  mp2_sub_p2_v0(t2, t5, t6);            // 2p->4p |  56    ->56 | t2 = A24plus*(X+Z)^2 - A24minus*(X-Z)^2
  fp2mul_mont_v0(t1, t1, t2);           // 6p->2p |  56->56->56 | t1 = [4*X^2 - (X+Z)^2 - (X-Z)^2]*[A24plus*(X+Z)^2 - A24minus*(X-Z)^2]
  fp2add_v0(t2, t3, t1);                // 4p->2p |  56    ->56 | t2 = [4*X^2 - (X+Z)^2 - (X-Z)^2]*[A24plus*(X+Z)^2 - A24minus*(X-Z)^2] + A24minus*(X-Z)^4 - A24plus*(X+Z)^4
  fp2sqr_mont_v0(t2, t2);               // 2p->2p |  56->56->56 | t2 = t2^2
  fp2mul_mont_v0(Q->X, t4, t2);         // 4p->2p |  56->56->56 | X3 = 2*X*t2
  fp2sub_v0(t1, t3, t1);                // 4p->2p |  56    ->56 | t1 = A24minus*(X-Z)^4 - A24plus*(X+Z)^4 - [4*X^2 - (X+Z)^2 - (X-Z)^2]*[A24plus*(X+Z)^2 - A24minus*(X-Z)^2]
  fp2sqr_mont_v0(t1, t1);               // 2p->2p |  56->56->56 | t1 = t1^2
  fp2mul_mont_v0(Q->Z, t0, t1);         // 4p->2p |  56->56->56 | Z3 = 2*Z*t1
}

void xTPL_v1(const point_proj_t P, point_proj_t Q, const f2elm_t A24minus, const f2elm_t A24plus)
{
  f2elm_t t0, t1, t2, t3, t4, t5, t6;
                                        //  range | limb-length | computation 
  mp2_sub_p2_v0(t0, P->X, P->Z);        // 2p->4p |  56    ->56 | t0 = X-Z
  fp2sqr_mont_v1(t2, t0);               // 4p->2p |  56->57->56 | t2 = (X-Z)^2
  mp2_add_v1(t1, P->X, P->Z);           // 2p->4p |  56    ->57 | t1 = X+Z 
  fp2sqr_mont_v1(t3, t1);               // 4p->2p |  57->58->56 | t3 = (X+Z)^2
  mp2_add_v1(t4, P->X, P->X);           // 2p->4p |  56    ->57 | t4 = 2*X
  mp2_add_v1(t0, P->Z, P->Z);           // 2p->4p |  56    ->57 | t0 = 2*Z
  fp2sqr_mont_v1(t1, t4);               // 4p->2p |  57->58->56 | t1 = 4*X^2
  mp2_sub_p2_v0(t1, t1, t3);            // 2p->4p |  56    ->56 | t1 = 4*X^2 - (X+Z)^2
  mp2_sub_p2_v0(t1, t1, t2);            // 4p->6p |  56    ->56 | t1 = 4*X^2 - (X+Z)^2 - (X-Z)^2
  fp2mul_mont_v1(t5, A24plus, t3);      // 2p->2p |  56->56->56 | t5 = A24plus*(X+Z)^2
  fp2mul_mont_v1(t3, t3, t5);           // 2p->2p |  56->57->56 | t3 = A24plus*(X+Z)^4
  fp2mul_mont_v1(t6, A24minus, t2);     // 2p->2p |  56->57->56 | t6 = A24minus*(X-Z)^2
  fp2mul_mont_v1(t2, t2, t6);           // 2p->2p |  56->57->56 | t2 = A24minus*(X-Z)^4
  mp2_sub_p2_v0(t3, t2, t3);            // 2p->4p |  56    ->56 | t3 = A24minus*(X-Z)^4 - A24plus*(X+Z)^4
  mp2_sub_p2_v0(t2, t5, t6);            // 2p->4p |  56    ->56 | t2 = A24plus*(X+Z)^2 - A24minus*(X-Z)^2
  fp2mul_mont_v1(t1, t1, t2);           // 6p->2p |  56->57->56 | t1 = [4*X^2 - (X+Z)^2 - (X-Z)^2]*[A24plus*(X+Z)^2 - A24minus*(X-Z)^2]
  fp2add_v0(t2, t3, t1);                // 4p->2p |  56    ->56 | t2 = [4*X^2 - (X+Z)^2 - (X-Z)^2]*[A24plus*(X+Z)^2 - A24minus*(X-Z)^2] + A24minus*(X-Z)^4 - A24plus*(X+Z)^4
  fp2sqr_mont_v1(t2, t2);               // 2p->2p |  56->57->56 | t2 = t2^2
  fp2mul_mont_v1(Q->X, t4, t2);         // 4p->2p |  56->57->56 | X3 = 2*X*t2
  fp2sub_v0(t1, t3, t1);                // 4p->2p |  56    ->56 | t1 = A24minus*(X-Z)^4 - A24plus*(X+Z)^4 - [4*X^2 - (X+Z)^2 - (X-Z)^2]*[A24plus*(X+Z)^2 - A24minus*(X-Z)^2]
  fp2sqr_mont_v1(t1, t1);               // 2p->2p |  56->57->56 | t1 = t1^2
  fp2mul_mont_v1(Q->Z, t0, t1);         // 4p->2p |  56->57->56 | Z3 = 2*Z*t1
}

void xTPL_v2(const point_proj_t P, point_proj_t Q, const f2elm_t A24minus, const f2elm_t A24plus)
{
  f2elm_t t0, t1, t2, t3, t4, t5, t6;
                                        //  range | limb-length | computation 
  mp2_sub_p2_v1(t0, P->X, P->Z);        // 2p->4p |  56    ->58 | t0 = X-Z
  fp2sqr_mont_v1(t2, t0);               // 4p->2p |  58->59->56 | t2 = (X-Z)^2
  mp2_add_v1(t1, P->X, P->Z);           // 2p->4p |  56    ->57 | t1 = X+Z 
  fp2sqr_mont_v1(t3, t1);               // 4p->2p |  57->58->56 | t3 = (X+Z)^2
  mp2_add_v1(t4, P->X, P->X);           // 2p->4p |  56    ->57 | t4 = 2*X
  mp2_add_v1(t0, P->Z, P->Z);           // 2p->4p |  56    ->57 | t0 = 2*Z
  fp2sqr_mont_v1(t1, t4);               // 4p->2p |  57->58->56 | t1 = 4*X^2
  mp2_sub_p2_v0(t1, t1, t3);            // 2p->4p |  56    ->56 | t1 = 4*X^2 - (X+Z)^2
  mp2_sub_p2_v0(t1, t1, t2);            // 4p->6p |  56    ->56 | t1 = 4*X^2 - (X+Z)^2 - (X-Z)^2
  fp2mul_mont_v1(t5, A24plus, t3);      // 2p->2p |  56->56->56 | t5 = A24plus*(X+Z)^2
  fp2mul_mont_v1(t3, t3, t5);           // 2p->2p |  56->57->56 | t3 = A24plus*(X+Z)^4
  fp2mul_mont_v1(t6, A24minus, t2);     // 2p->2p |  56->57->56 | t6 = A24minus*(X-Z)^2
  fp2mul_mont_v1(t2, t2, t6);           // 2p->2p |  56->57->56 | t2 = A24minus*(X-Z)^4
  mp2_sub_p2_v1(t3, t2, t3);            // 2p->4p |  56    ->58 | t3 = A24minus*(X-Z)^4 - A24plus*(X+Z)^4
  mp2_sub_p2_v1(t2, t5, t6);            // 2p->4p |  56    ->58 | t2 = A24plus*(X+Z)^2 - A24minus*(X-Z)^2
  fp2mul_mont_v1(t1, t1, t2);           // 6p->2p |  56,58 ->56 | t1 = [4*X^2 - (X+Z)^2 - (X-Z)^2]*[A24plus*(X+Z)^2 - A24minus*(X-Z)^2]
  fp2add_v0(t2, t3, t1);                // 4p->2p |  56,58 ->56 | t2 = [4*X^2 - (X+Z)^2 - (X-Z)^2]*[A24plus*(X+Z)^2 - A24minus*(X-Z)^2] + A24minus*(X-Z)^4 - A24plus*(X+Z)^4
  fp2sqr_mont_v1(t2, t2);               // 2p->2p |  56->57->56 | t2 = t2^2
  fp2mul_mont_v1(Q->X, t4, t2);         // 4p->2p |  56->57->56 | X3 = 2*X*t2
  fp2sub_v0(t1, t3, t1);                // 4p->2p |  56    ->56 | t1 = A24minus*(X-Z)^4 - A24plus*(X+Z)^4 - [4*X^2 - (X+Z)^2 - (X-Z)^2]*[A24plus*(X+Z)^2 - A24minus*(X-Z)^2]
  fp2sqr_mont_v1(t1, t1);               // 2p->2p |  56->57->56 | t1 = t1^2
  fp2mul_mont_v1(Q->Z, t0, t1);         // 4p->2p |  56->57->56 | Z3 = 2*Z*t1
}

void xTPLe(const point_proj_t P, point_proj_t Q, const f2elm_t A24minus, const f2elm_t A24plus, const int e)
{
  int i;

  copy_point(Q, P);
  for (i = 0; i < e; i++) xTPL(Q, Q, A24minus, A24plus);
}
