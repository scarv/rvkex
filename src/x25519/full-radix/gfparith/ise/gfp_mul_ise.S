// void gfp_mul_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^64


#include "ise.h"


// registers 

// result `r`
#define R0 a6
#define R1 a7
#define R2 a1 
#define R3 a2
#define R4 s0
#define R5 s1
#define R6 s2
#define R7 s3

// operand `b` 
#define B0 t0 
#define B1 t1
#define B2 t2 
#define B3 t3

// operand `a`
#define A0 t4 
#define A1 t5 
#define A2 t6 
#define A3 a3
#define A4 t0

// temporary value `t`
#define T0 a4
#define T1 a5

// constant `m` 
#define M0 t1


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -32
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp) 
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  ld    s3, 24(sp)
  addi  sp, sp, 32 
  ret 
.endm

// load operand + store result 

.macro LOAD_A
  ld    A0,  0(a1)
  ld    A1,  8(a1)
  ld    A2, 16(a1)
  ld    A3, 24(a1)
.endm 

.macro LOAD_B
  ld    B0,  0(a2)
  ld    B1,  8(a2)
  ld    B2, 16(a2)
  ld    B3, 24(a2)
.endm 

.macro STORE_R
  sd    R0,  0(a0)
  sd    R1,  8(a0)
  sd    R2, 16(a0)
  sd    R3, 24(a0)
.endm

// integer multiplication (based on product-scanning)

// L != 0, M = 0, H = 0
// L M H -> T M H
.macro _ACCU_AIBJ_0 L, M, H, T, A, B 
  maddlu \T, \A, \B, \L
  sltu   \L, \T, \L
  maddhu \M, \A, \B, \L                 // no carry-out
.endm

// L != 0, M != 0, H = 0
// L M H -> T M H
.macro _ACCU_AIBJ_1 L, M, H, T, A, B 
  maddlu \T, \A, \B, \L
  sltu   \L, \T, \L
  maddhu \L, \A, \B, \L                 // no carry-out
  add    \M, \M, \L
  sltu   \H, \M, \L
.endm

// L != 0, M != 0, H != 0
// L M H -> T M H 
.macro _ACCU_AIBJ_2 L, M, H, T, A, B 
  maddlu \T, \A, \B, \L
  sltu   \L, \T, \L
  maddhu \L, \A, \B, \L                 // no carry-out
  add    \M, \M, \L
  sltu   \L, \M, \L
  add    \H, \H, \L
.endm

.macro COMPUTE_R0
  mul    R0, A0, B0
  mulhu  R1, A0, B0                     // accu: R0 R1    -> R0 R1    
.endm

.macro COMPUTE_R1 
  _ACCU_AIBJ_0   R1, R2, R3, T0, A0, B1 // accu: R1 R2    -> T0 R2
  _ACCU_AIBJ_1   T0, R2, R3, R1, A1, B0 // accu: T0 R2 R3 -> R1 R2 R3  
.endm

.macro COMPUTE_R2 
  _ACCU_AIBJ_1   R2, R3, R4, T0, A0, B2 // accu: R2 R3 R4 -> T0 R3 R4
  _ACCU_AIBJ_2   T0, R3, R4, T1, A1, B1 // accu: T0 R3 R4 -> T1 R3 R4
  _ACCU_AIBJ_2   T1, R3, R4, R2, A2, B0 // accu: T1 R3 R4 -> R2 R3 R4
.endm

.macro COMPUTE_R3
  _ACCU_AIBJ_1   R3, R4, R5, T0, A0, B3 // accu: R3 R4 R5 -> T0 R4 R5
  _ACCU_AIBJ_2   T0, R4, R5, R3, A1, B2 // accu: T0 R4 R5 -> R3 R4 R5
  _ACCU_AIBJ_2   R3, R4, R5, T0, A2, B1 // accu: R3 R4 R5 -> T0 R4 R5
  _ACCU_AIBJ_2   T0, R4, R5, R3, A3, B0 // accu: T0 R4 R5 -> R3 R4 R5
.endm

.macro COMPUTE_R4 
  _ACCU_AIBJ_1   R4, R5, T1, T0, A1, B3 // accu: R4 R5 R6 -> T0 R5 T1
  _ACCU_AIBJ_2   T0, R5, T1, R6, A2, B2 // accu: T0 R5 R6 -> R6 R5 T1
  _ACCU_AIBJ_2   R6, R5, T1, R4, A3, B1 // accu: R6 R5 R6 -> R4 R5 T1
.endm

.macro COMPUTE_R5 
  _ACCU_AIBJ_1   R5, T1, R7, T0, A2, B3 // accu: R5 T1 R7 -> T0 T1 R7
  _ACCU_AIBJ_2   T0, T1, R7, R5, A3, B2 // accu: T0 T1 R7 -> R5 T1 R7
.endm

.macro COMPUTE_R6 
  maddlu R6, A3, B3, T1
  sltu   T1, R6, T1 
  maddhu R7, A3, B3, R7                 // accu: T1 R7    -> R6 R7   
.endm

.macro COMPUTE_R7 
  add    R7, R7, T1
.endm

// reduction A0-A4 = R0-R3 + 38*(R4-R7)

.macro REDUCTION
  li     M0, 38 

  maddlu A0, R4, M0, R0
  sltu   T0, A0, R0
  maddhu A1, R4, M0, T0                 // no carry-out

  maddlu T0, R5, M0, A1 
  sltu   T1, T0, A1 
  maddhu A2, R5, M0, T1                 // no carry-out
  add    A1, T0, R1 
  sltu   T0, A1, T0 
  add    A2, A2, T0

  maddlu T0, R6, M0, A2 
  sltu   T1, T0, A2 
  maddhu A3, R6, M0, T1                 // no carry-out
  add    A2, T0, R2 
  sltu   T0, A2, T0 
  add    A3, A3, T0  
 
  maddlu T0, R7, M0, A3 
  sltu   T1, T0, A3 
  maddhu A4, R7, M0, T1                 // no carry-out
  add    A3, T0, R3 
  sltu   T0, A3, T0 
  add    A4, A4, T0 
.endm

// final reduction 

.macro FINAL_REDC
  slli   R3, A3, 1
  srli   R3, R3, 1 
  srli   A3, A3, 63
  slli   A4, A4, 1
  or     A3, A3, A4 
  li     M0, 19
  maddlu R0, A3, M0, A0
  sltu   R1, R0, A0 
  add    R1, R1, A1 
  sltu   R2, R1, A1 
  add    R2, R2, A2 
  sltu   T0, R2, A2 
  add    R3, R3, T0 
.endm


// field multiplication

.section .text

.global gfp_mul_ise

gfp_mul_ise:
  PROLOGUE
  LOAD_A
  LOAD_B
  COMPUTE_R0
  COMPUTE_R1
  COMPUTE_R2
  COMPUTE_R3
  COMPUTE_R4
  COMPUTE_R5
  COMPUTE_R6
  COMPUTE_R7
  REDUCTION
  FINAL_REDC
  STORE_R
  EPILOGUE
