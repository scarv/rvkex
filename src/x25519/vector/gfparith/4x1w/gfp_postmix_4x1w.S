// void gfp_postmix_4x1w(vec4 *r, const vec4 *a, const vec4 *b, const vec4 *m);
// radix-25.5 
// NOTE: scalar implementation might be faster!
// lane       :    3    ||    2    ||    1    ||    0    
// input  "a" =    d    ||    c    ||    b    ||    a
//        "b" =    h    ||    g    ||    f    ||    e
// output "r" =    d    ||    c    ||   f-e   ||  2b+a


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
#define R8 v2
#define R9 v3

// operand "a"
#define A0 v24
#define A1 v25
#define A2 v26
#define A3 v27
#define A4 v28
#define A5 v29
#define A6 v30
#define A7 v31
#define A8 v6
#define A9 v7

// temp operand "t"
#define T0 v16
#define T1 v17
#define T2 v18
#define T3 v19
#define T4 v20
#define T5 v21
#define T6 v22
#define T7 v23
#define T8 v4
#define T9 v5

// mask and carry
#define M_ v1                           // "M_" means the mask for any limb
#define C_ v1                           // "C_" means carry bits for any limb

// modulus "2p"
#define P0 t4                           // the LS   limb 0x7FFFFDA
#define P1 t5                           // the odd  limb 0x3FFFFFE
#define P2 t6                           // the even limb 0x7FFFFFE

// constants and masks
#define C19 t4                          // 19  
#define M26 t5                          // 2^26 - 1
#define M25 t6                          // 2^25 - 1


// load operands "a" "b" + store result "r" 

.macro LOAD_OPERAND_A_LMUL1 
  vle32.v  A0, (a1) 
  addi     a1,  a1, 16 
  vle32.v  A1, (a1)
  addi     a1,  a1, 16 
  vle32.v  A2, (a1) 
  addi     a1,  a1, 16 
  vle32.v  A3, (a1)
  addi     a1,  a1, 16 
  vle32.v  A4, (a1) 
  addi     a1,  a1, 16 
  vle32.v  A5, (a1)
  addi     a1,  a1, 16 
  vle32.v  A6, (a1) 
  addi     a1,  a1, 16 
  vle32.v  A7, (a1)
  addi     a1,  a1, 16 
  vle32.v  A8, (a1) 
  addi     a1,  a1, 16 
  vle32.v  A9, (a1)
.endm

.macro LOAD_OPERAND_B_LMUL1 
  vle32.v  A0, (a2) 
  addi     a2,  a2, 16 
  vle32.v  A1, (a2)
  addi     a2,  a2, 16 
  vle32.v  A2, (a2) 
  addi     a2,  a2, 16 
  vle32.v  A3, (a2)
  addi     a2,  a2, 16 
  vle32.v  A4, (a2) 
  addi     a2,  a2, 16 
  vle32.v  A5, (a2)
  addi     a2,  a2, 16 
  vle32.v  A6, (a2) 
  addi     a2,  a2, 16 
  vle32.v  A7, (a2)
  addi     a2,  a2, 16 
  vle32.v  A8, (a2) 
  addi     a2,  a2, 16 
  vle32.v  A9, (a2)
.endm

.macro STORE_RESULT_R_LMUL1 
  vse32.v  R0, (a0) 
  addi     a0,  a0, 16 
  vse32.v  R1, (a0)
  addi     a0,  a0, 16 
  vse32.v  R2, (a0) 
  addi     a0,  a0, 16 
  vse32.v  R3, (a0)
  addi     a0,  a0, 16 
  vse32.v  R4, (a0) 
  addi     a0,  a0, 16 
  vse32.v  R5, (a0)
  addi     a0,  a0, 16 
  vse32.v  R6, (a0) 
  addi     a0,  a0, 16 
  vse32.v  R7, (a0)
  addi     a0,  a0, 16 
  vse32.v  R8, (a0) 
  addi     a0,  a0, 16 
  vse32.v  R9, (a0) 
.endm

// arithmetic computation + permuting and blending

.macro T_EQU_2A_LMUL1 
  vadd.vv     T0, A0, A0
  vadd.vv     T1, A1, A1
  vadd.vv     T2, A2, A2
  vadd.vv     T3, A3, A3
  vadd.vv     T4, A4, A4
  vadd.vv     T5, A5, A5
  vadd.vv     T6, A6, A6
  vadd.vv     T7, A7, A7
  vadd.vv     T8, A8, A8
  vadd.vv     T9, A9, A9
.endm

.macro R_EQU_PERM_T_LMUL1 
  vle32.v     M_, (a3)                  // M_ = 2 3 0 1 
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

.macro T_EQU_R_ADD_A_LMUL1
  vadd.vv     T0, R0, A0
  vadd.vv     T1, R1, A1
  vadd.vv     T2, R2, A2
  vadd.vv     T3, R3, A3
  vadd.vv     T4, R4, A4
  vadd.vv     T5, R5, A5
  vadd.vv     T6, R6, A6
  vadd.vv     T7, R7, A7
  vadd.vv     T8, R8, A8
  vadd.vv     T9, R9, A9
.endm

.macro R_EQU_BLD_A_T_LMUL1
  li          t0, 0x1                   // 0x1  =  0b0001
  vmv.s.x     v0, t0                    // v0.m =  0 || 0 || 0 || 1
  vmerge.vvm  R0, A0, T0, v0
  vmerge.vvm  R1, A1, T1, v0
  vmerge.vvm  R2, A2, T2, v0
  vmerge.vvm  R3, A3, T3, v0
  vmerge.vvm  R4, A4, T4, v0
  vmerge.vvm  R5, A5, T5, v0
  vmerge.vvm  R6, A6, T6, v0
  vmerge.vvm  R7, A7, T7, v0
  vmerge.vvm  R8, A8, T8, v0
  vmerge.vvm  R9, A9, T9, v0
.endm

.macro T_EQU_PERM_A_LMUL1 
  vrgather.vv T0, A0, M_
  vrgather.vv T1, A1, M_
  vrgather.vv T2, A2, M_
  vrgather.vv T3, A3, M_
  vrgather.vv T4, A4, M_
  vrgather.vv T5, A5, M_
  vrgather.vv T6, A6, M_
  vrgather.vv T7, A7, M_
  vrgather.vv T8, A8, M_
  vrgather.vv T9, A9, M_
.endm

.macro T_EQU_2P_SUB_T_LMUL1
  vrsub.vx    T0, T0, P0
  vrsub.vx    T1, T1, P1 
  vrsub.vx    T2, T2, P2
  vrsub.vx    T3, T3, P1
  vrsub.vx    T4, T4, P2
  vrsub.vx    T5, T5, P1 
  vrsub.vx    T6, T6, P2
  vrsub.vx    T7, T7, P1
  vrsub.vx    T8, T8, P2
  vrsub.vx    T9, T9, P1
.endm

.macro T_EQU_T_ADD_A_LMUL1
  vadd.vv     T0, T0, A0
  vadd.vv     T1, T1, A1
  vadd.vv     T2, T2, A2
  vadd.vv     T3, T3, A3
  vadd.vv     T4, T4, A4
  vadd.vv     T5, T5, A5
  vadd.vv     T6, T6, A6
  vadd.vv     T7, T7, A7
  vadd.vv     T8, T8, A8
  vadd.vv     T9, T9, A9
.endm

.macro R_EQU_BLD_R_T_LMUL1
  li          t0, 0x2                   // 0x2  =  0b0010
  vmv.s.x     v0, t0                    // v0.m =  0 || 0 || 1 || 0
  vmerge.vvm  R0, R0, T0, v0
  vmerge.vvm  R1, R1, T1, v0
  vmerge.vvm  R2, R2, T2, v0
  vmerge.vvm  R3, R3, T3, v0
  vmerge.vvm  R4, R4, T4, v0
  vmerge.vvm  R5, R5, T5, v0
  vmerge.vvm  R6, R6, T6, v0
  vmerge.vvm  R7, R7, T7, v0
  vmerge.vvm  R8, R8, T8, v0
  vmerge.vvm  R9, R9, T9, v0
.endm

// final reduction and carry propagation

.macro FINAL_REDUCTION_LMUL1
  vsrl.vi     C_, R0, 26                // C_ = R0 >> 26
  vand.vx     R0, R0, M26               // R0 = R0 & M26
  vadd.vv     R1, R1, C_                // R1 = R1 + R0>>26
  vsrl.vi     C_, R1, 25                // C_ = R1 >> 25
  vand.vx     R1, R1, M25               // R1 = R1 & M25
  vadd.vv     R2, R2, C_                // R2 = R2 + R1>>25
  vsrl.vi     C_, R2, 26                // C_ = R2 >> 26
  vand.vx     R2, R2, M26               // R2 = R2 & M26
  vadd.vv     R3, R3, C_                // R3 = R3 + R0>>26
  vsrl.vi     C_, R3, 25                // C_ = R3 >> 25
  vand.vx     R3, R3, M25               // R3 = R3 & M25
  vadd.vv     R4, R4, C_                // R4 = R4 + R1>>25
  vsrl.vi     C_, R4, 26                // C_ = R4 >> 26
  vand.vx     R4, R4, M26               // R4 = R4 & M26
  vadd.vv     R5, R5, C_                // R5 = R5 + R0>>26
  vsrl.vi     C_, R5, 25                // C_ = R5 >> 25
  vand.vx     R5, R5, M25               // R5 = R5 & M25
  vadd.vv     R6, R6, C_                // R6 = R6 + R1>>25
  vsrl.vi     C_, R6, 26                // C_ = R6 >> 26
  vand.vx     R6, R6, M26               // R6 = R6 & M26
  vadd.vv     R7, R7, C_                // R7 = R7 + R0>>26
  vsrl.vi     C_, R7, 25                // C_ = R7 >> 25
  vand.vx     R7, R7, M25               // R7 = R7 & M25
  vadd.vv     R8, R8, C_                // R8 = R8 + R1>>25
  vsrl.vi     C_, R8, 26                // C_ = R8 >> 26
  vand.vx     R8, R8, M26               // R8 = R8 & M26
  vadd.vv     R9, R9, C_                // R9 = R9 + R0>>26
  vsrl.vi     C_, R9, 25                // C_ = R9 >> 25
  vand.vx     R9, R9, M25               // R9 = R9 & M25
  vmul.vx     C_, C_, C19               // C_ = 19 * (R9>>25)
  vadd.vv     R0, R0, C_                // R0 = R0 + 19(R9>>25)
.endm


// (4x1)-way postmix

.section .text

// v0: conventional one

.global gfp_postmix_4x1w_v0

gfp_postmix_4x1w_v0:
  li      P0,  0x7FFFFDA                // P0  = 0x7FFFFDA
  li      P1,  0x3FFFFFE                // P1  = 0x3FFFFFE
  li      P2,  0x7FFFFFE                // P2  = 0x7FFFFFE
  li      t1, -1                        // VL  = VLMAX
  vsetvli t0, t1, e32, m1               // SEW = 32, LMUL = 1
  //
  LOAD_OPERAND_A_LMUL1                  // "a" =      d ||      c ||      b ||      a
  T_EQU_2A_LMUL1                        // "t" =     2d ||     2c ||     2b ||     2a
  R_EQU_PERM_T_LMUL1                    // "r" =     2c ||     2d ||     2a ||     2b
  T_EQU_R_ADD_A_LMUL1                   // "t" =   2c+d ||   2d+c ||   2a+b ||   2b+a
  R_EQU_BLD_A_T_LMUL1                   // "r" =      d ||      c ||      b ||   2b+a
  LOAD_OPERAND_B_LMUL1                  // "a" =      h ||      g ||      f ||      e
  T_EQU_PERM_A_LMUL1                    // "t" =      g ||      h ||      e ||      f
  T_EQU_2P_SUB_T_LMUL1                  // "t" =   2p-g ||   2p-h ||   2p-e ||   2p-f
  T_EQU_T_ADD_A_LMUL1                   // "t" = h+2p-g || g+2p-h || f+2p-e || e+2p-f
  R_EQU_BLD_R_T_LMUL1                   // "r" =      d ||      c || f+2p-e ||   2b+a 
  //
  li      C19, 19                       // C19 = 19
  li      M26, 0x3FFFFFF                // M26 = 2^26 - 1
  li      M25, 0x1FFFFFF                // M25 = 2^25 - 1
  FINAL_REDUCTION_LMUL1                 // "r" =      d ||      c ||    f-e ||   2b+a 
  STORE_RESULT_R_LMUL1                  // store result "r" R0-R9 to memory
  //
  ret


// v2: uses register group to load/store (LUML = 8, 2) and arithmetic computation (LMUL = 8, 2)

.global gfp_postmix_4x1w_v2

gfp_postmix_4x1w_v2:
  li      P0,  0x7FFFFDA                // P0  = 0x7FFFFDA
  li      P1,  0x3FFFFFE                // P1  = 0x3FFFFFE
  li      P2,  0x7FFFFFE                // P2  = 0x7FFFFFE
  li      t1, -1                        // VL   = VLMAX
  // 
  vsetvli     t0, t1, e32, m8           // LMUL = 8
  vle32.v     A0, (a1)                  // "a"  =     d ||      c ||      b ||      a
  addi        a1, a1, 128               // 
  vadd.vv     T0, A0, A0                // "t"  =    2d ||     2c ||     2b ||     2a
  vsetvli     t0, t1, e32, m2           // LMUL = 2
  vle32.v     A8, (a1)                  // "a"  =     d ||      c ||      b ||      a
  vadd.vv     T8, A8, A8                // "t"  =    2d ||     2c ||     2b ||     2a
  vsetvli     t0, t1, e32, m1           // LMUL = 1
  R_EQU_PERM_T_LMUL1                    // "r"  =    2c ||     2d ||     2a ||     2b
  li          t0, 0x11111111            // 0x1  = 0b0001
  vmv.s.x     v0, t0                    // v0.m =     0 ||      0 ||      0 ||      1
  vsetvli     t0, t1, e32, m8           // LMUL = 8
  vadd.vv     T0, R0, A0                // "t"  =  2c+d ||   2d+c ||   2a+b ||   2b+a
  vmerge.vvm  R0, A0, T0, v0            // "r"  =     d ||      c ||      b ||   2b+a
  vle32.v     A0, (a2)                  // "a" =      h ||      g ||      f ||      e
  addi        a2, a2, 128               // 
  vsetvli     t0, t1, e32, m2           // LMUL = 2
  vadd.vv     T8, R8, A8                // "t"  =  2c+d ||   2d+c ||   2a+b ||   2b+a
  vmerge.vvm  R8, A8, T8, v0            // "r"  =     d ||      c ||      b ||   2b+a
  vle32.v     A8, (a2)                  // "a" =      h ||      g ||      f ||      e
  vsetvli     t0, t1, e32, m1           // LMUL = 1
  T_EQU_PERM_A_LMUL1                    // "t" =      g ||      h ||      e ||      f
  T_EQU_2P_SUB_T_LMUL1                  // "t" =   2p-g ||   2p-h ||   2p-e ||   2p-f
  li          t0, 0x22222222            // 0x2  =  0b0010
  vmv.s.x     v0, t0                    // v0.m =  0 || 0 || 1 || 0  
  vsetvli     t0, t1, e32, m8           // LMUL = 8
  vadd.vv     T0, T0, A0                // "t" = h+2p-g || g+2p-h || f+2p-e || e+2p-f
  vmerge.vvm  R0, R0, T0, v0            // "r" =      d ||      c || f+2p-e ||   2b+a 
  vsetvli     t0, t1, e32, m2           // LMUL = 2
  vadd.vv     T8, T8, A8                // "t" = h+2p-g || g+2p-h || f+2p-e || e+2p-f
  vmerge.vvm  R8, R8, T8, v0            // "r" =      d ||      c || f+2p-e ||   2b+a
  vsetvli     t0, t1, e32, m1           // LMUL = 1 
  //
  li      C19, 19                       // C19 = 19
  li      M26, 0x3FFFFFF                // M26 = 2^26 - 1
  li      M25, 0x1FFFFFF                // M25 = 2^25 - 1
  FINAL_REDUCTION_LMUL1                 // "r" =      d ||      c ||    f-e ||   2b+a 
  vsetvli t0, t1, e32, m8               // LMUL = 8
  vse32.v R0, (a0)                      // store 8 LS-limbs of "r" to memory
  vsetvli t0, t1, e32, m2               // LMUL = 2
  addi    a0, a0, 128                   // 
  vse32.v R8, (a0)                      // store 2 MS-limbs of "r" to memory
  //
  ret

  