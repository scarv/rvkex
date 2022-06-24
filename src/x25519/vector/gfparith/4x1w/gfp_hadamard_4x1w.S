// void gfp_hadamard_4x1w(vec4 *r, const vec4 *a, const vec4 *m);
// radix-25.5 
// lane   :    3    ||    2    ||    1    ||    0    
// input  =    z    ||    y    ||    x    ||    w         
// output =   z+y   ||  z+2p-y ||   x+w   ||  x+2p-w 


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

// mask 
#define M_ v30                          // "M_" means the mask for any limb

// modulus "2p"
#define P0 t4                           // the LS   limb 0x7FFFFDA
#define P1 t5                           // the odd  limb 0x3FFFFFE
#define P2 t6                           // the even limb 0x7FFFFFE


// load operand "a" + store result "r" 

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

.macro T_EQU_2P_SUB_A_LMUL1
  vrsub.vx    T0, A0, P0
  vrsub.vx    T1, A1, P1
  vrsub.vx    T2, A2, P2
  vrsub.vx    T3, A3, P1
  vrsub.vx    T4, A4, P2
  vrsub.vx    T5, A5, P1
  vrsub.vx    T6, A6, P2
  vrsub.vx    T7, A7, P1
  vrsub.vx    T8, A8, P2
  vrsub.vx    T9, A9, P1
.endm

.macro R_EQU_PERM_A_LMUL1 
  vle32.v     M_, (a2)                  // M_ = 2 3 0 1 
  vrgather.vv R0, A0, M_
  vrgather.vv R1, A1, M_
  vrgather.vv R2, A2, M_
  vrgather.vv R3, A3, M_
  vrgather.vv R4, A4, M_
  vrgather.vv R5, A5, M_
  vrgather.vv R6, A6, M_
  vrgather.vv R7, A7, M_
  vrgather.vv R8, A8, M_
  vrgather.vv R9, A9, M_                
.endm

.macro T_EQU_BLD_A_T_LMUL1
  li          t0, 0xA                   // 0xA  =  0b1010
  vmv.s.x     v0, t0                    // v0.m =  1 || 0 || 1 || 0
  vmerge.vvm  T0, T0, A0, v0            // NOTE: though A0^(0) has been changed,
  vmerge.vvm  T1, T1, A1, v0            //       it doesn't affect anything. 
  vmerge.vvm  T2, T2, A2, v0
  vmerge.vvm  T3, T3, A3, v0
  vmerge.vvm  T4, T4, A4, v0
  vmerge.vvm  T5, T5, A5, v0
  vmerge.vvm  T6, T6, A6, v0
  vmerge.vvm  T7, T7, A7, v0
  vmerge.vvm  T8, T8, A8, v0
  vmerge.vvm  T9, T9, A9, v0
.endm

.macro R_EQU_T_ADD_R_LMUL1
  vadd.vv     R0, R0, T0
  vadd.vv     R1, R1, T1
  vadd.vv     R2, R2, T2
  vadd.vv     R3, R3, T3
  vadd.vv     R4, R4, T4
  vadd.vv     R5, R5, T5
  vadd.vv     R6, R6, T6
  vadd.vv     R7, R7, T7
  vadd.vv     R8, R8, T8
  vadd.vv     R9, R9, T9
.endm


// (4x1)-way field hadamard 

.section .text

// v0: conventional one

.global gfp_hadamard_4x1w_v0

gfp_hadamard_4x1w_v0:
  li      P0, 0x7FFFFDA                 // P0  = 0x7FFFFDA
  li      P1, 0x3FFFFFE                 // P1  = 0x3FFFFFE
  li      P2, 0x7FFFFFE                 // P2  = 0x7FFFFFE
  li      t1, -1                        // VL  = VLMAX
  vsetvli t0, t1, e32, m1               // SEW = 32, LMUL = 1
  // 
  LOAD_OPERAND_A_LMUL1                  // "a" =    z ||      y ||    x ||      w
  T_EQU_2P_SUB_A_LMUL1                  // "t" = 2p-z ||   2p-y || 2p-x ||   2p-w
  R_EQU_PERM_A_LMUL1                    // "r" =    y ||      z ||    w ||      x
  T_EQU_BLD_A_T_LMUL1                   // "t" =    z ||   2p-y ||    x ||   2p-w
  R_EQU_T_ADD_R_LMUL1                   // "r" =  z+y || z+2p-y ||  x+w || x+2p-w 
  STORE_RESULT_R_LMUL1                  // store result "r" R0-R9 to memory
  //
  ret  


// v1: uses register group to load/store (LMUL = 8, 2)

.macro LOAD_OPERAND_A_LMUL82 
  vsetvli t0, t1, e32, m8               // LMUL = 8
  vle32.v A0, (a1)                      // load 8 LS-limbs of "a" to A0-A7
  vsetvli t0, t1, e32, m2               // LMUL = 2
  addi    a1, a1, 128                   // 
  vle32.v A8, (a1)                      // load 2 MS-limbs of "a" to A8-A9
.endm

.macro STORE_RESULT_R_LMUL82
  vsetvli t0, t1, e32, m8               // LMUL = 8
  vse32.v R0, (a0)                      // store 8 LS-limbs of "r" to memory
  vsetvli t0, t1, e32, m2               // LMUL = 2
  addi    a0, a0, 128                   // 
  vse32.v R8, (a0)                      // store 2 MS-limbs of "r" to memory
.endm


.global gfp_hadamard_4x1w_v1

gfp_hadamard_4x1w_v1:
  li      P0, 0x7FFFFDA                 // P0  = 0x7FFFFDA
  li      P1, 0x3FFFFFE                 // P1  = 0x3FFFFFE
  li      P2, 0x7FFFFFE                 // P2  = 0x7FFFFFE
  li      t1, -1                        // VL  = VLMAX
  // 
  LOAD_OPERAND_A_LMUL82                 // "a" =    z ||      y ||    x ||      w
  vsetvli t0, t1, e32, m1               // SEW = 32, LMUL = 1
  T_EQU_2P_SUB_A_LMUL1                  // "t" = 2p-z ||   2p-y || 2p-x ||   2p-w
  R_EQU_PERM_A_LMUL1                    // "r" =    y ||      z ||    w ||      x
  T_EQU_BLD_A_T_LMUL1                   // "t" =    z ||   2p-y ||    x ||   2p-w
  R_EQU_T_ADD_R_LMUL1                   // "r" =  z+y || z+2p-y ||  x+w || x+2p-w 
  STORE_RESULT_R_LMUL82                 // store result "r" R0-R9 to memory
  //
  ret  


// v2: uses register group to load/store (LUML = 8, 2) and arithmetic computation (LMUL = 8, 2)

// blend "a" and "t", then compute "r += t" and meanwhile store "r" to memory 
// (save 4 `vsetvli` instructions)
// NOTE: though A0^(0) has been changed, it doesn't affect the correctness. 

.macro STORE_R_EQU_R_ADD_BLD_A_T_LMUL82
  li          t0, 0xAAAAAAAA            // t0   = 0b1010, ..., 0b1010
  vmv.s.x     v0, t0                    // v0.m = 1 || 0 || 1 || 0, ..., 1 || 0 || 1 || 0 
  vsetvli     t0, t1, e32, m8           // LMUL = 8
  vmerge.vvm  T0, T0, A0, v0            // blend A0-A7 and T0-T7
  vadd.vv     R0, R0, T0                // R0-R7 += T0-T7
  vse32.v     R0, (a0)                  // store 8 LS-limbs of "r" to memory
  addi        a0, a0, 128               //  
  vsetvli     t0, t1, e32, m2           // LMUL = 2
  vmerge.vvm  T8, T8, A8, v0            // blend A8-A9 and T8-T9
  vadd.vv     R8, R8, T8                // R8-R9 += T8-T9
  vse32.v     R8, (a0)                  // store 2 MS-limbs of "r" to memory
.endm


.global gfp_hadamard_4x1w_v2

gfp_hadamard_4x1w_v2:
  li      P0, 0x7FFFFDA                 // P0  = 0x7FFFFDA
  li      P1, 0x3FFFFFE                 // P1  = 0x3FFFFFE
  li      P2, 0x7FFFFFE                 // P2  = 0x7FFFFFE
  li      t1, -1                        // VL  = VLMAX
  // 
  LOAD_OPERAND_A_LMUL82                 // "a" =    z ||      y ||    x ||      w
  vsetvli t0, t1, e32, m1               // SEW = 32, LMUL = 1
  T_EQU_2P_SUB_A_LMUL1                  // "t" = 2p-z ||   2p-y || 2p-x ||   2p-w
  R_EQU_PERM_A_LMUL1                    // "r" =    y ||      z ||    w ||      x
  STORE_R_EQU_R_ADD_BLD_A_T_LMUL82      // "r" =  z+y || z+2p-y ||  x+w || x+2p-w 
                                        // store result "r" R0-R9 to memory
  //
  ret 

