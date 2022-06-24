// void gfp_mix0_2x1w(vec2 *r, vec2 *s, const vec2 *a, const vec2 *b);
// radix-51
// lane     :      1    ||    0    
// input  a =      x    ||    w         
//        b =      z    ||    y 
// output r =      x    ||    z 
//        s =      w    ||    y


// meaningful names for registers and constants

// result "r" 
#define R0 v16
#define R1 v17
#define R2 v18
#define R3 v19
#define R4 v20

// result "s" 
#define S0 v16
#define S1 v17
#define S2 v18
#define S3 v19
#define S4 v20

// operand "a"
#define A0 v8 
#define A1 v9
#define A2 v10
#define A3 v11
#define A4 v12

// operand "b"
#define B0 v24 
#define B1 v25 
#define B2 v26 
#define B3 v27
#define B4 v28 

// mask 
#define M_ v30                          // "M_" means the mask for any limb


// load operands "a" "b" + store results "r" "s"

.macro LOAD_OPERAND_A_LMUL1
  vle64.v  A0, (a2)
  addi     a2,  a2, 16
  vle64.v  A1, (a2)
  addi     a2,  a2, 16
  vle64.v  A2, (a2)
  addi     a2,  a2, 16
  vle64.v  A3, (a2)
  addi     a2,  a2, 16
  vle64.v  A4, (a2)
.endm

.macro LOAD_OPERAND_B_LMUL1 
  vle64.v  B0, (a3)
  addi     a3,  a3, 16
  vle64.v  B1, (a3)
  addi     a3,  a3, 16
  vle64.v  B2, (a3)
  addi     a3,  a3, 16
  vle64.v  B3, (a3)
  addi     a3,  a3, 16
  vle64.v  B4, (a3)
.endm

.macro STORE_RESULT_R_LMUL1 
  vse64.v  R0, (a0) 
  addi     a0,  a0, 16 
  vse64.v  R1, (a0)
  addi     a0,  a0, 16 
  vse64.v  R2, (a0) 
  addi     a0,  a0, 16 
  vse64.v  R3, (a0)
  addi     a0,  a0, 16 
  vse64.v  R4, (a0) 
.endm

.macro STORE_RESULT_S_LMUL1 
  vse64.v  S0, (a1) 
  addi     a1,  a1, 16 
  vse64.v  S1, (a1)
  addi     a1,  a1, 16 
  vse64.v  S2, (a1) 
  addi     a1,  a1, 16 
  vse64.v  S3, (a1)
  addi     a1,  a1, 16 
  vse64.v  S4, (a1) 
.endm

// permuting and blending

.macro R_EQU_PERM_B_LMUL1 
  vrgather.vv R0, B0, M_
  vrgather.vv R1, B1, M_
  vrgather.vv R2, B2, M_
  vrgather.vv R3, B3, M_
  vrgather.vv R4, B4, M_
.endm

.macro R_EQU_BLD_A_R_LMUL1
  vmv.s.x     v0, t2                    // v0.m =  0b01
  vmerge.vvm  R0, A0, R0, v0
  vmerge.vvm  R1, A1, R1, v0
  vmerge.vvm  R2, A2, R2, v0
  vmerge.vvm  R3, A3, R3, v0
  vmerge.vvm  R4, A4, R4, v0
.endm

.macro S_EQU_PERM_A_LMUL1 
  vrgather.vv S0, A0, M_
  vrgather.vv S1, A1, M_
  vrgather.vv S2, A2, M_
  vrgather.vv S3, A3, M_
  vrgather.vv S4, A4, M_
.endm

.macro S_EQU_BLD_S_B_LMUL1
  vmerge.vvm  S0, S0, B0, v0
  vmerge.vvm  S1, S1, B1, v0
  vmerge.vvm  S2, S2, B2, v0
  vmerge.vvm  S3, S3, B3, v0
  vmerge.vvm  S4, S4, B4, v0
.endm


// (4x1)-way mix0

.section .text

// v0: conventional one

.global gfp_mix0_2x1w_v0

gfp_mix0_2x1w_v0:
  li      t1, -1
  vsetvli t0, t1, e64, m1               // SEW = 64, LMUL = 1
  vxor.vv M_, M_, M_                    // M_   =  0 || 0
  li      t2, 0x1                       // 0x1  =  0b01
  vmv.s.x M_, t2                        // M_   =  0 || 1
  // 
  LOAD_OPERAND_A_LMUL1                  // load operand "a" to A0-A4
  LOAD_OPERAND_B_LMUL1                  // load operand "b" to B0-B4
  R_EQU_PERM_B_LMUL1                    // "r" =  y || z
  R_EQU_BLD_A_R_LMUL1                   // "r" =  x || z 
  STORE_RESULT_R_LMUL1                  // store result "r" to memory 
  S_EQU_PERM_A_LMUL1                    // "s" =  w || x
  S_EQU_BLD_S_B_LMUL1                   // "s" =  w || y
  STORE_RESULT_S_LMUL1                  // store result "s" to memory
  //
  ret 


// v2: uses register group to load/store and arithmetic computation (LMUL = 5)

.global gfp_mix0_2x1w_v2

gfp_mix0_2x1w_v2:
  li      t1, 10                        // VL = AVL = 2 lanes * 5 registers = 10
  vsetvli t0, t1, e64, m8               // SEW = 64, LMUL = 5
  // 
  vle64.v A0, (a2)                      // load operand "a" to A0-A4
  vle64.v B0, (a3)                      // load operand "b" to B0-B4
  vsetvli t0, t1, e64, m1               // LMUL = 1 
  //
  vxor.vv M_, M_, M_                    // 
  li      t2, 0x1                       // 
  vmv.s.x M_, t2                        // 
  li      t2, 0x155                     // 
  vmv.s.x v0, t2                        // 
  //
  R_EQU_PERM_B_LMUL1                    // "r" =  y || z
  vsetvli t0, t1, e64, m8               // LMUL = 5
  vmerge.vvm  R0, A0, R0, v0            // "r" =  x || z 
  vse64.v R0, (a0)                      // store result "r" to memory 
  vsetvli t0, t1, e64, m1               // LMUL = 1
  S_EQU_PERM_A_LMUL1                    // "s" =  w || x
  vsetvli t0, t1, e64, m8               // LMUL = 5
  vmerge.vvm  S0, S0, B0, v0            // "s" =  w || y
  vse64.v S0, (a1)                      // store result "s" to memory 
  // 
  ret 
