// void gfp_mul_2x1w_ise(vec2 *r, const vec2 *a, const vec2 *b, const vec2 *m);
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
#define B0  v8 
#define B1  v9 
#define B2  v10 
#define B3  v11
#define B4  v12 

// operand "a"
#define A0  v24
#define A1  v25 
#define A2  v26
#define A3  v27
#define A4  v28

// carry 
#define CL  v2 

// constants and masks
#define C19 t3                          // 19
#define C51 t4                          // 51
#define M51 v1                          // 2^51 - 1 || 2^51 - 1


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
  addi     a2,  a2, 16
  vle64.v  B1, (a2)
  addi     a2,  a2, 16
  vle64.v  B2, (a2)
  addi     a2,  a2, 16
  vle64.v  B3, (a2)
  addi     a2,  a2, 16
  vle64.v  B4, (a2)
.endm

.macro STORE_RESULT_R_LMUL1 
  vse64.v  B0, (a0) 
  addi     a0,  a0, 16 
  vse64.v  B1, (a0)
  addi     a0,  a0, 16 
  vse64.v  B2, (a0) 
  addi     a0,  a0, 16 
  vse64.v  B3, (a0)
  addi     a0,  a0, 16 
  vse64.v  B4, (a0) 
.endm

// interleaved multiplication and reduction (based on operand-scanning)

.macro MULTIPLY_A0_LMUL1
  VMUL51LO     R0, A0, B0               // R0  =   A0B0
  VMUL51HI     R1, A0, B0
  VMAC51LO     R1, A0, B1               // R1  =   A0B1 
  VMUL51HI     R2, A0, B1
  VMAC51LO     R2, A0, B2               // R2  =   A0B2  
  VMUL51HI     R3, A0, B2
  VMAC51LO     R3, A0, B3               // R3  =   A0B3 
  VMUL51HI     R4, A0, B3
  VMAC51LO     R4, A0, B4               // R4  =   A0B4
  VMUL51HI     R5, A0, B4  
.endm

.macro MULTIPLY_A1_LMUL1
  vmul.vx      B4, B4, C19              // B4  = 19  B4
  VMAC51LO     R1, A1, B0               // R1 +=   A1B0
  VMAC51HI     R2, A1, B0
  VMAC51LO     R2, A1, B1               // R2 +=   A1B1
  VMAC51HI     R3, A1, B1
  VMAC51LO     R3, A1, B2               // R3 +=   A1B2
  VMAC51HI     R4, A1, B2
  VMAC51LO     R4, A1, B3               // R4 +=   A1B3
  VMAC51HI     R5, A1, B3    
  VMAC51LO     R0, A1, B4               // R0 += 19A1B4
  VMAC51HI     R1, A1, B4
.endm 

.macro MULTIPLY_A2_LMUL1
  vmul.vx      B3, B3, C19              // B3  = 19  B3
  VMAC51LO     R2, A2, B0               // R2 +=   A2B0
  VMAC51HI     R3, A2, B0
  VMAC51LO     R3, A2, B1               // R3 +=   A2B1
  VMAC51HI     R4, A2, B1
  VMAC51LO     R4, A2, B2               // R4 +=   A2B2
  VMAC51HI     R5, A2, B2
  VMAC51LO     R0, A2, B3               // R0 += 19A2B3
  VMAC51HI     R1, A2, B3
  VMAC51LO     R1, A2, B4               // R1 += 19A2B4
  VMAC51HI     R2, A2, B4  
.endm

.macro MULTIPLY_A3_LMUL1
  vmul.vx      B2, B2, C19              // B2  = 19  B2
  VMAC51LO     R3, A3, B0               // R3 +=   A3B0
  VMAC51HI     R4, A3, B0
  VMAC51LO     R4, A3, B1               // R4 +=   A3B1
  VMAC51HI     R5, A3, B1
  VMAC51LO     R0, A3, B2               // R0 += 19A3B2
  VMAC51HI     R1, A3, B2
  VMAC51LO     R1, A3, B3               // R1 += 19A3B3
  VMAC51HI     R2, A3, B3
  VMAC51LO     R2, A3, B4               // R2 += 19A3B4
  VMAC51HI     R3, A3, B4  
.endm

.macro MULTIPLY_A4_LMUL1
  vmul.vx      B1, B1, C19              // B1  = 19  B1
  VMAC51LO     R4, A4, B0               // R4 +=   A4B0
  VMAC51HI     R5, A4, B0
  VMAC51LO     R0, A4, B1               // R0 +=   A4B1
  VMAC51HI     R1, A4, B1
  VMAC51LO     R1, A4, B2               // R1 += 19A4B2
  VMAC51HI     R2, A4, B2
  VMAC51LO     R2, A4, B3               // R2 += 19A4B3
  VMAC51HI     R3, A4, B3
  VMAC51LO     R3, A4, B4               // R3 += 19A4B4
  VMAC51HI     R4, A4, B4  
.endm

// carry propagation 

.macro CARRY_PROPAGATION
  vle64.v      M51, (a3)
  vmacc.vx     R0, C19, R5              // R0 = R0 + 19R5
  vsrl51add.vv R1, R0, R1               // R1 = R1 + R0 >> 51
  vand.vv      B0, R0, M51              // B0 = R0 & M51 
  vsrl51add.vv R2, R1, R2               // R2 = R2 + R1 >> 51
  vand.vv      B1, R1, M51              // B1 = R1 & M51  
  vsrl51add.vv R3, R2, R3               // R3 = R3 + R2 >> 51
  vand.vv      B2, R2, M51              // B2 = R2 & M51
  vsrl51add.vv R4, R3, R4               // R4 = R4 + R3 >> 51 
  vand.vv      B3, R3, M51              // B3 = R3 & M51
  vsrl.vx      CL, R4, C51              // CL = R4 >> 51
  vand.vv      B4, R4, M51              // B4 = R4 & M51  
  vmacc.vx     B0, C19, CL              // B0 = B0 + 19CL
.endm   


// (2x1)-way field multiplication using ISE

.section .text

// v0: conventional operand-scanning 

.global gfp_mul_2x1w_v0_ise

gfp_mul_2x1w_v0_ise:
  li      C19, 19                       // C19 = 19
  li      C51, 51                       // C51 = 51
  li      t1,  -1                       // VL  = VLMAX
  vsetvli t0, t1, e64, m1               // SEW = 64, LMUL = 1
  // 
  LOAD_OPERAND_A_LMUL1                  // load operand "a" to A0-A4
  LOAD_OPERAND_B_LMUL1                  // load operand "b" to B0-B4
  MULTIPLY_A0_LMUL1                     //
  MULTIPLY_A1_LMUL1                     //
  MULTIPLY_A2_LMUL1                     //
  MULTIPLY_A3_LMUL1                     //
  MULTIPLY_A4_LMUL1                     //
  CARRY_PROPAGATION                     //
  STORE_RESULT_R_LMUL1                  // store result "r" to memory 
  // 
  ret 
  

// v1: uses register group to load/store (LMUL = 5)

.global gfp_mul_2x1w_v1_ise

gfp_mul_2x1w_v1_ise:
  li      C19, 19                       // C19 = 19
  li      C51, 51                       // C51 = 51
  li      t1,  10                       // VL = AVL = 2 lanes * 5 registers = 10
  vsetvli t0, t1, e64, m8               // SEW = 64, LMUL = 5 
  // 
  vle64.v A0, (a1)                      // load operand "a" to A0-A4
  vle64.v B0, (a2)                      // load operand "b" to B0-B4
  vsetvli t0, t1, e64, m1               // LMUL = 1
  MULTIPLY_A0_LMUL1                     //
  MULTIPLY_A1_LMUL1                     //
  MULTIPLY_A2_LMUL1                     //
  MULTIPLY_A3_LMUL1                     //
  MULTIPLY_A4_LMUL1                     //
  CARRY_PROPAGATION                     //
  vsetvli t0, t1, e64, m8               // LMUL = 5
  vse64.v B0, (a0)                      // store result "r" to memory 
  //
  ret 
