#include "curve.h"


void pointcopy(point_proj_t Q, const point_proj_t P)
{
  fp2copy(Q->X, P->X);
  fp2copy(Q->Z, P->Z);
}

void xDBL_v0(const point_proj_t P, point_proj_t Q, const f2elm_t A24plus, const f2elm_t C24)
{
  f2elm_t t0, t1;
                                        //  range | limb-length | computation 
  mp2_sub_p2(t0, P->X, P->Z);           // 2p->4p |  56    ->56 | t0 = X1-Z1 
  mp2_add_v0(t1, P->X, P->Z);           // 2p->4p |  56    ->56 | t1 = X1+Z1
  fp2sqr_mont_v0(t0, t0);               // 4p->2p |  56->56->56 | t0 = (X1-Z1)^2
  fp2sqr_mont_v0(t1, t1);               // 4p->2p |  56->56->56 | t1 = (X1+Z1)^2
  fp2mul_mont_v0(Q->Z, C24, t0);        // 2p->2p |  56->56->56 | Z2 = C24*(X1-Z1)^2
  fp2mul_mont_v0(Q->X, t1, Q->Z);       // 2p->2p |  56->56->56 | X2 = C24*(X1-Z1)^2*(X1+Z1)^2
  mp2_sub_p2(t1, t1, t0);               // 2p->4p |  56    ->56 | t1 = (X1+Z1)^2-(X1-Z1)^2  
  fp2mul_mont_v0(t0, A24plus, t1);      // 3p->2p |  56->56->56 | t0 = A24plus*[(X1+Z1)^2-(X1-Z1)^2]
  mp2_add_v0(Q->Z, Q->Z, t0);           // 2p->4p |  56    ->56 | Z2 = A24plus*[(X1+Z1)^2-(X1-Z1)^2] + C24*(X1-Z1)^2
  fp2mul_mont_v0(Q->Z, Q->Z, t1);       // 4p->2p |  56->56->56 | Z2 = [A24plus*[(X1+Z1)^2-(X1-Z1)^2] + C24*(X1-Z1)^2]*[(X1+Z1)^2-(X1-Z1)^2] 
}

void xDBL_v1(const point_proj_t P, point_proj_t Q, const f2elm_t A24plus, const f2elm_t C24)
{
  f2elm_t t0, t1;
                                        //  range | limb-length | computation 
  mp2_sub_p2(t0, P->X, P->Z);           // 2p->4p |  56    ->56 | t0 = X1-Z1 
  mp2_add_v1(t1, P->X, P->Z);           // 2p->4p |  56    ->57 | t1 = X1+Z1
  fp2sqr_mont_v1(t0, t0);               // 4p->2p |  56->57->56 | t0 = (X1-Z1)^2
  fp2sqr_mont_v1(t1, t1);               // 4p->2p |  57->58->56 | t1 = (X1+Z1)^2
  fp2mul_mont_v1(Q->Z, C24, t0);        // 2p->2p |  56->57->56 | Z2 = C24*(X1-Z1)^2
  fp2mul_mont_v1(Q->X, t1, Q->Z);       // 2p->2p |  56->57->56 | X2 = C24*(X1-Z1)^2*(X1+Z1)^2
  mp2_sub_p2(t1, t1, t0);               // 2p->4p |  56    ->56 | t1 = (X1+Z1)^2-(X1-Z1)^2  
  fp2mul_mont_v1(t0, A24plus, t1);      // 4p->2p |  56    ->56 | t0 = A24plus*[(X1+Z1)^2-(X1-Z1)^2]
  mp2_add_v1(Q->Z, Q->Z, t0);           // 2p->4p |  56    ->57 | Z2 = A24plus*[(X1+Z1)^2-(X1-Z1)^2] + C24*(X1-Z1)^2
  fp2mul_mont_v1(Q->Z, Q->Z, t1);       // 4p->2p |  56.5  ->56 | Z2 = [A24plus*[(X1+Z1)^2-(X1-Z1)^2] + C24*(X1-Z1)^2]*[(X1+Z1)^2-(X1-Z1)^2] 
}
