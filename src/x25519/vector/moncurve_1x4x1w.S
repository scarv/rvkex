// void mon_cswap_point_1x4x1w(vec4 *x3z3x2z2, int swap, vec4 m);
// radix-25.5


// meaningful names for registers and constants

// result "r" 
#define R0 v8
#define R1 v9
#define R2 v10
#define R3 v11
#define R4 v12
#define R5 v13
#define R6 v14
#define R7 v15
#define R8 v26
#define R9 v27

// operand "a"
#define A0 v0
#define A1 v1
#define A2 v2
#define A3 v3
#define A4 v4
#define A5 v5
#define A6 v6
#define A7 v7
#define A8 v24
#define A9 v25

// temp "t"
#define T0 v16
#define T1 v17
#define T2 v18
#define T3 v19
#define T4 v20
#define T5 v21
#define T6 v22
#define T7 v23
#define T8 v28
#define T9 v29

// mask 
#define M_ v30                          // "M_" means the mask for any limb


// (1x4x1)-way cswap

.section .text

// v2: uses register group (LMUL = 8, 2)

.global mon_cswap_point_1x4x1w_v2

mon_cswap_point_1x4x1w_v2:
  li          t1, -1                        
  andi        t2, a1, 1
  sub         t2, x0, t2
  //
  vsetvli     t0, t1, e32, m8
  vle32.v     A0, (a0)
  vsetvli     t0, t1, e32, m1
  vle32.v     M_, (a2)
  vrgather.vv R0, A0, M_
  vrgather.vv R1, A1, M_
  vrgather.vv R2, A2, M_
  vrgather.vv R3, A3, M_
  vrgather.vv R4, A4, M_
  vrgather.vv R5, A5, M_
  vrgather.vv R6, A6, M_
  vrgather.vv R7, A7, M_
  vsetvli     t0, t1, e32, m8
  vxor.vv     R0, R0, A0 
  vmv.v.x     T0, t2
  vand.vv     R0, R0, T0
  vxor.vv     R0, R0, A0
  vse32.v     R0, (a0)
  addi        a0, a0, 128
  vsetvli     t0, t1, e32, m2
  vle32.v     A8, (a0)
  vsetvli     t0, t1, e32, m1
  vrgather.vv R8, A8, M_
  vrgather.vv R9, A9, M_
  vsetvli     t0, t1, e32, m2
  vxor.vv     R8, R8, A8 
  vmv.v.x     T8, t2
  vand.vv     R8, R8, T8
  vxor.vv     R8, R8, A8
  vse32.v     R8, (a0)
  //
  ret 