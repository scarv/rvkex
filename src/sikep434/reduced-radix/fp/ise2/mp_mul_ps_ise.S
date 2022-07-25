// void mp_mul_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^56, product-scanning
// no carry propagation since it will be done in Montgomery reduction


#include "ise2.h"


// registers

// accumulator "z"
#define ZL a1
#define ZH a2

// operand "b" 
#define B0 t0 
#define B1 t1
#define B2 t2
#define B3 t3
#define B4 t4
#define B5 t5
#define B6 t6
#define B7 a3

// operand "a"
#define A0 s0 
#define A1 s1
#define A2 s2 
#define A3 s3
#define A4 a4
#define A5 a5
#define A6 a6
#define A7 a7 


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

// load operand

.macro LOAD_A
  ld    A0,  0(a1)
  ld    A1,  8(a1)
  ld    A2, 16(a1)
  ld    A3, 24(a1)
  ld    A4, 32(a1)
  ld    A5, 40(a1)
  ld    A6, 48(a1)
  ld    A7, 56(a1)
.endm 

.macro LOAD_B
  ld    B0,  0(a2)
  ld    B1,  8(a2)
  ld    B2, 16(a2)
  ld    B3, 24(a2)
  ld    B4, 32(a2)
  ld    B5, 40(a2)
  ld    B6, 48(a2)
  ld    B7, 56(a2)
.endm 

// integer multiplication (based on product-scanning)

.macro COMPUTE_R0
  macc56lo ZL, A0, B0, x0
  macc56hi ZH, A0, B0, x0
  sd       ZL,  0(a0)
.endm

.macro COMPUTE_R1
  macc56lo ZH, A0, B1, ZH
  macc56hi ZL, A0, B1, x0
  macc56lo ZH, A1, B0, ZH
  macc56hi ZL, A1, B0, ZL
  sd       ZH,  8(a0)
.endm

.macro COMPUTE_R2
  macc56lo ZL, A0, B2, ZL
  macc56hi ZH, A0, B2, x0
  macc56lo ZL, A1, B1, ZL
  macc56hi ZH, A1, B1, ZH
  macc56lo ZL, A2, B0, ZL
  macc56hi ZH, A2, B0, ZH
  sd       ZL, 16(a0)
.endm

.macro COMPUTE_R3
  macc56lo ZH, A0, B3, ZH
  macc56hi ZL, A0, B3, x0
  macc56lo ZH, A1, B2, ZH
  macc56hi ZL, A1, B2, ZL
  macc56lo ZH, A2, B1, ZH
  macc56hi ZL, A2, B1, ZL
  macc56lo ZH, A3, B0, ZH
  macc56hi ZL, A3, B0, ZL
  sd       ZH, 24(a0)
.endm

.macro COMPUTE_R4
  macc56lo ZL, A0, B4, ZL
  macc56hi ZH, A0, B4, x0
  macc56lo ZL, A1, B3, ZL
  macc56hi ZH, A1, B3, ZH
  macc56lo ZL, A2, B2, ZL
  macc56hi ZH, A2, B2, ZH
  macc56lo ZL, A3, B1, ZL
  macc56hi ZH, A3, B1, ZH
  macc56lo ZL, A4, B0, ZL
  macc56hi ZH, A4, B0, ZH
  sd       ZL, 32(a0)
.endm

.macro COMPUTE_R5
  macc56lo ZH, A0, B5, ZH
  macc56hi ZL, A0, B5, x0
  macc56lo ZH, A1, B4, ZH
  macc56hi ZL, A1, B4, ZL
  macc56lo ZH, A2, B3, ZH
  macc56hi ZL, A2, B3, ZL
  macc56lo ZH, A3, B2, ZH
  macc56hi ZL, A3, B2, ZL
  macc56lo ZH, A4, B1, ZH
  macc56hi ZL, A4, B1, ZL
  macc56lo ZH, A5, B0, ZH
  macc56hi ZL, A5, B0, ZL
  sd       ZH, 40(a0)
.endm

.macro COMPUTE_R6
  macc56lo ZL, A0, B6, ZL
  macc56hi ZH, A0, B6, x0
  macc56lo ZL, A1, B5, ZL
  macc56hi ZH, A1, B5, ZH
  macc56lo ZL, A2, B4, ZL
  macc56hi ZH, A2, B4, ZH
  macc56lo ZL, A3, B3, ZL
  macc56hi ZH, A3, B3, ZH
  macc56lo ZL, A4, B2, ZL
  macc56hi ZH, A4, B2, ZH
  macc56lo ZL, A5, B1, ZL
  macc56hi ZH, A5, B1, ZH
  macc56lo ZL, A6, B0, ZL
  macc56hi ZH, A6, B0, ZH
  sd       ZL, 48(a0)
.endm

.macro COMPUTE_R7
  macc56lo ZH, A0, B7, ZH
  macc56hi ZL, A0, B7, x0
  macc56lo ZH, A1, B6, ZH
  macc56hi ZL, A1, B6, ZL
  macc56lo ZH, A2, B5, ZH
  macc56hi ZL, A2, B5, ZL
  macc56lo ZH, A3, B4, ZH
  macc56hi ZL, A3, B4, ZL
  macc56lo ZH, A4, B3, ZH
  macc56hi ZL, A4, B3, ZL
  macc56lo ZH, A5, B2, ZH
  macc56hi ZL, A5, B2, ZL
  macc56lo ZH, A6, B1, ZH
  macc56hi ZL, A6, B1, ZL
  macc56lo ZH, A7, B0, ZH
  macc56hi ZL, A7, B0, ZL
  sd       ZH, 56(a0)
.endm

.macro COMPUTE_R8
  macc56lo ZL, A1, B7, ZL
  macc56hi ZH, A1, B7, x0
  macc56lo ZL, A2, B6, ZL
  macc56hi ZH, A2, B6, ZH
  macc56lo ZL, A3, B5, ZL
  macc56hi ZH, A3, B5, ZH
  macc56lo ZL, A4, B4, ZL
  macc56hi ZH, A4, B4, ZH
  macc56lo ZL, A5, B3, ZL
  macc56hi ZH, A5, B3, ZH
  macc56lo ZL, A6, B2, ZL
  macc56hi ZH, A6, B2, ZH
  macc56lo ZL, A7, B1, ZL
  macc56hi ZH, A7, B1, ZH
  sd       ZL, 64(a0)
.endm

.macro COMPUTE_R9
  macc56lo ZH, A2, B7, ZH
  macc56hi ZL, A2, B7, x0
  macc56lo ZH, A3, B6, ZH
  macc56hi ZL, A3, B6, ZL
  macc56lo ZH, A4, B5, ZH
  macc56hi ZL, A4, B5, ZL
  macc56lo ZH, A5, B4, ZH
  macc56hi ZL, A5, B4, ZL
  macc56lo ZH, A6, B3, ZH
  macc56hi ZL, A6, B3, ZL
  macc56lo ZH, A7, B2, ZH
  macc56hi ZL, A7, B2, ZL
  sd       ZH, 72(a0)
.endm

.macro COMPUTE_R10
  macc56lo ZL, A3, B7, ZL
  macc56hi ZH, A3, B7, x0
  macc56lo ZL, A4, B6, ZL
  macc56hi ZH, A4, B6, ZH
  macc56lo ZL, A5, B5, ZL
  macc56hi ZH, A5, B5, ZH
  macc56lo ZL, A6, B4, ZL
  macc56hi ZH, A6, B4, ZH
  macc56lo ZL, A7, B3, ZL
  macc56hi ZH, A7, B3, ZH
  sd       ZL, 80(a0)
.endm

.macro COMPUTE_R11
  macc56lo ZH, A4, B7, ZH
  macc56hi ZL, A4, B7, x0
  macc56lo ZH, A5, B6, ZH
  macc56hi ZL, A5, B6, ZL
  macc56lo ZH, A6, B5, ZH
  macc56hi ZL, A6, B5, ZL
  macc56lo ZH, A7, B4, ZH
  macc56hi ZL, A7, B4, ZL
  sd       ZH, 88(a0)
.endm

.macro COMPUTE_R12
  macc56lo ZL, A5, B7, ZL
  macc56hi ZH, A5, B7, x0
  macc56lo ZL, A6, B6, ZL
  macc56hi ZH, A6, B6, ZH
  macc56lo ZL, A7, B5, ZL
  macc56hi ZH, A7, B5, ZH
  sd       ZL, 96(a0)
.endm

.macro COMPUTE_R13
  macc56lo ZH, A6, B7, ZH
  macc56hi ZL, A6, B7, x0
  macc56lo ZH, A7, B6, ZH
  macc56hi ZL, A7, B6, ZL
  sd       ZH,104(a0)
.endm

.macro COMPUTE_R14
  macc56lo ZL, A7, B7, ZL
  macc56hi ZH, A7, B7, x0
  sd       ZL,112(a0)
.endm

.macro COMPUTE_R15
  sd       ZH,120(a0)
.endm


// integer multiplication using ISE

.section .text

// v0: conventional product-scanning

.global mp_mul_v0_ise

mp_mul_v0_ise:
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
  COMPUTE_R8
  COMPUTE_R9
  COMPUTE_R10
  COMPUTE_R11
  COMPUTE_R12
  COMPUTE_R13
  COMPUTE_R14
  COMPUTE_R15
  EPILOGUE
