// void gfp_premix_4x1w(vec4 *r, vec4 *s, const vec4 *a, const vec4 *b, const vec4 *c， const vec4 *m);
// radix-25.5 
// lane     :    3    ||    2    ||    1    ||    0    
// INPUT  a =    d    ||    c    ||    b    ||    a
//        b =    h    ||    g    ||    f    ||    e
//        c =    l    ||    k    ||    j    ||    i
// OUTPUT r =    d    ||    c    ||    f    ||    a
//        s =    l    ||    k    ||    e    ||    i


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

// temp operand "t"
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

// masks 
#define M_ v30                          // "M_" means the mask for any limb
#define _M v31                         


// permuting

.macro R_EQU_PERM_T_LMUL1 
  vle32.v     M_, (a5)
  vrgather.vv R0, T0, M_
  vrgather.vv R1, T1, M_
  vrgather.vv R2, T2, M_
  vrgather.vv R3, T3, M_
  vrgather.vv R4, T4, M_
  vrgather.vv R5, T5, M_
  vrgather.vv R6, T6, M_
  vrgather.vv R7, T7, M_
  vrgather.vv R8, T8, M_
  vrgather.vv R9, T9, M_               
.endm


// v2: uses register group to load/store (LUML = 8, 2) and arithmetic computation (LMUL = 8, 2)

.global gfp_premix_4x1w_v2

gfp_premix_4x1w_v2:
  li          t1, -1                    // VL  = VLMAX
  //
  li          t0, 0x22222222            // t0   = 0b0010, ..., 0b0010
  vmv.s.x     v0, t0                    // v0.m = 0 || 0 || 1 || 0, ..., 0 || 0 || 1 || 0 
  vsetvli     t0, t1, e32, m8           // LMUL = 8
  vle32.v     R0, (a2)                  // load 8 LS-limbs of "a" to R0-R7
  vle32.v     T0, (a3)                  // load 8 LS-limbs of "b" to T0-T7
  vmerge.vvm  R0, R0, T0, v0            // blend "a" and "b" -> "r" = d || c || f || a
  vse32.v     R0, (a0)                  // store 8 LS-limbs of "r" to memory
  addi        a2, a2, 128               //
  addi        a3, a3, 128               // 
  addi        a0, a0, 128               //
  vsetvli     t0, t1, e32, m2           // LMUL = 2
  vle32.v     R8, (a2)                  // load 2 MS-limbs of "a" to R8-R9
  vle32.v     T8, (a3)                  // load 2 MS-limbs of "b" to T8-T9
  vmerge.vvm  R8, R8, T8, v0            // blend "a" and "b" -> "r" = d || c || f || a
  vse32.v     R8, (a0)                  // store 2 MS-limbs of "r" to memory
  //
  vsetvli     t0, t1, e32, m1           // LMUL = 1
  R_EQU_PERM_T_LMUL1                    // "b"  = g || h || e || f
  //
  vsetvli     t0, t1, e32, m8           // LMUL = 8
  vle32.v     T0, (a4)                  // load 8 LS-limbs of "c" to T0-T7
  vmerge.vvm  R0, T0, R0, v0            // blend "c" and "b" -> "s" = l || k || e || i
  vse32.v     R0, (a1)                  // store 8 LS-limbs of "s" to memory
  addi        a4, a4, 128               //
  addi        a1, a1, 128               // 
  vsetvli     t0, t1, e32, m2           // LMUL = 2
  vle32.v     T8, (a4)                  // load 2 MS-limbs of "c" to T8-T9
  vmerge.vvm  R8, T8, R8, v0            // blend "c" and "b" -> "s" = l || k || e || i
  vse32.v     R8, (a1)                  // store 2 MS-limbs of "s" to memory
  //
  ret
