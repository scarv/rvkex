// void gfp_mul51_2x1w_ise(vec2 *r, const vec2 *a, const vec *b, const vec2 *m);
// radix-51 + ISE (vmacc51lo + vmacc51hi)


#include "../ise.h"


// meaningful names for registers and constants

// result "r"
#define R0  v16
#define R1  v17 
#define R2  v18 
#define R3  v19 
#define R4  v20
#define R5  v21

// operand "b"
#define B0  v24
#define B1  v25
#define B2  v26
#define B3  v27

// operand "a"
#define A0  v8
#define A1  v9 
#define A2  v10
#define A3  v11
#define A4  v12

// carry 
#define CL  v6 

// constants and masks
#define C19 t2                          // 19
#define C51 t3                          // 51  
#define M51 v5                          // 2^51 - 1 || 2^51 - 1


// load operands "a" "b" + store result "r" 

.macro LOAD_OPERAND_A_LMUL1
  vle64.v  A0, (a1)
  addi     a1,  a1, 16
  vle64.v  A1, (a1)
  addi     a1,  a1, 16
  vle64.v  A2, (a1)
  addi     a1,  a1, 16
  vle64.v  A3, (a1)
  addi     a1,  a1, 16
  vle64.v  A4, (a1)
.endm

.macro LOAD_OPERAND_B_LMUL1 
  vle64.v  B0, (a2)
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

// multiplication 

.macro MULTIPLY_B0_LMUL1
  VMUL51LO     R0, A0, B0               // R0  =   A0B0
  VMUL51HI     R1, A0, B0
  VMAC51LO     R1, A1, B0               // R1  =   A1B0 
  VMUL51HI     R2, A1, B0
  VMAC51LO     R2, A2, B0               // R2  =   A2B0  
  VMUL51HI     R3, A2, B0
  VMAC51LO     R3, A3, B0               // R3  =   A3B0 
  VMUL51HI     R4, A3, B0
  VMAC51LO     R4, A4, B0               // R4  =   A4B0
  VMUL51HI     R5, A4, B0
.endm 

.macro CARRY_PROPAGATION
  vle64.v      M51, (a3)
  vmacc.vx     R0, C19, R5              // R0 = R0 + 19R5
  vsrl51add.vv R1, R0, R1               // R1 = R1 + R0 >> 51
  vand.vv      R0, R0, M51              // A0 = R0 & M51 
.endm


// (2x1)-way field mul51 using ISE

.section .text

// v0: conventional one

.global gfp_mul51_2x1w_v0_ise

gfp_mul51_2x1w_v0_ise:
  li      C19, 19                       // C19 = 19
  li      C51, 51                       // C51 = 51
  li      t1,  -1                       // VL  = VLMAX
  vsetvli t0, t1, e64, m1               // SEW = 64, LMUL = 1
  // 
  LOAD_OPERAND_A_LMUL1                  // load operand "a" to A0-A4
  LOAD_OPERAND_B_LMUL1                  // load operand "b" to B0
  MULTIPLY_B0_LMUL1                     //
  CARRY_PROPAGATION                     //
  STORE_RESULT_R_LMUL1                  // store result "r" to memory
  //
  ret


// v1: uses register group to load/store (LMUL = 5)

.global gfp_mul51_2x1w_v1_ise

gfp_mul51_2x1w_v1_ise:
  li      C19, 19                       // C19 = 19
  li      C51, 51                       // C51 = 51
  li      t1,  10                       // AVL = 2 lanes * 5 registers = 10
  vsetvli t0, t1, e64, m8               // SEW = 64, LMUL = 5
  // 
  vle64.v A0, (a1)                      // load operand "a" to A0-A4
  vsetvli t0, t1, e64, m1               // LMUL = 1
  LOAD_OPERAND_B_LMUL1                  // load operand "b" to B0
  MULTIPLY_B0_LMUL1                     //
  CARRY_PROPAGATION                     //
  vsetvli t0, t1, e64, m8               // LMUL = 5
  vse64.v R0, (a0)                      // store result "r" to memory 
  //
  ret
