// void mp_mul_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^56, product-scanning
// no carry propagation since it will be done in Montgomery reduction


#include "ise2.h"


// registers 

// accumulator "z"
#define ZL  a1
#define ZH  a2

// operand "b" 
#define B0  t0 
#define B1  t1
#define B2  t2
#define B3  t3
#define B4  t4
#define B5  t5
#define B6  t6
#define B7  a3
#define B8  s4
#define B9  s6
#define B10 s7

// operand "a"
#define A0  s0 
#define A1  s1
#define A2  s2 
#define A3  s3
#define A4  a4
#define A5  a5
#define A6  a6
#define A7  a7
#define A8  s5
#define A9  s8
#define A10 s9


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -80
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
  sd    s4, 32(sp)
  sd    s5, 40(sp)
  sd    s6, 48(sp)
  sd    s7, 56(sp)
  sd    s8, 64(sp)
  sd    s9, 72(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  ld    s3, 24(sp)
  ld    s4, 32(sp)
  ld    s5, 40(sp)
  ld    s6, 48(sp)
  ld    s7, 56(sp)
  ld    s8, 64(sp)
  ld    s9, 72(sp)
  addi  sp, sp, 80 
  ret 
.endm

// load operand

.macro LOAD_A
  ld    A0,   0(a1)
  ld    A1,   8(a1)
  ld    A2,  16(a1)
  ld    A3,  24(a1)
  ld    A4,  32(a1)
  ld    A5,  40(a1)
  ld    A6,  48(a1)
  ld    A7,  56(a1)
  ld    A8,  64(a1)
  ld    A9,  72(a1)
  ld    A10, 80(a1)
.endm 

.macro LOAD_B
  ld    B0,   0(a2)
  ld    B1,   8(a2)
  ld    B2,  16(a2)
  ld    B3,  24(a2)
  ld    B4,  32(a2)
  ld    B5,  40(a2)
  ld    B6,  48(a2)
  ld    B7,  56(a2)
  ld    B8,  64(a2)
  ld    B9,  72(a2)
  ld    B10, 80(a2)
.endm 

// integer multiplication (based on product-scanning)

.macro COMPUTE_R0
  madd56lu ZL, A0, B0, x0
  madd56hu ZH, A0, B0, x0
  sd       ZL,  0(a0)
.endm

.macro COMPUTE_R1
  madd56lu ZH, A0, B1, ZH
  madd56hu ZL, A0, B1, x0
  madd56lu ZH, A1, B0, ZH
  madd56hu ZL, A1, B0, ZL
  sd       ZH,  8(a0)
.endm

.macro COMPUTE_R2
  madd56lu ZL, A0, B2, ZL
  madd56hu ZH, A0, B2, x0
  madd56lu ZL, A1, B1, ZL
  madd56hu ZH, A1, B1, ZH
  madd56lu ZL, A2, B0, ZL
  madd56hu ZH, A2, B0, ZH
  sd       ZL, 16(a0)
.endm

.macro COMPUTE_R3
  madd56lu ZH, A0, B3, ZH
  madd56hu ZL, A0, B3, x0
  madd56lu ZH, A1, B2, ZH
  madd56hu ZL, A1, B2, ZL
  madd56lu ZH, A2, B1, ZH
  madd56hu ZL, A2, B1, ZL
  madd56lu ZH, A3, B0, ZH
  madd56hu ZL, A3, B0, ZL
  sd       ZH, 24(a0)
.endm

.macro COMPUTE_R4
  madd56lu ZL, A0, B4, ZL
  madd56hu ZH, A0, B4, x0
  madd56lu ZL, A1, B3, ZL
  madd56hu ZH, A1, B3, ZH
  madd56lu ZL, A2, B2, ZL
  madd56hu ZH, A2, B2, ZH
  madd56lu ZL, A3, B1, ZL
  madd56hu ZH, A3, B1, ZH
  madd56lu ZL, A4, B0, ZL
  madd56hu ZH, A4, B0, ZH
  sd       ZL, 32(a0)
.endm

.macro COMPUTE_R5
  madd56lu ZH, A0, B5, ZH
  madd56hu ZL, A0, B5, x0
  madd56lu ZH, A1, B4, ZH
  madd56hu ZL, A1, B4, ZL
  madd56lu ZH, A2, B3, ZH
  madd56hu ZL, A2, B3, ZL
  madd56lu ZH, A3, B2, ZH
  madd56hu ZL, A3, B2, ZL
  madd56lu ZH, A4, B1, ZH
  madd56hu ZL, A4, B1, ZL
  madd56lu ZH, A5, B0, ZH
  madd56hu ZL, A5, B0, ZL
  sd       ZH, 40(a0)
.endm

.macro COMPUTE_R6
  madd56lu ZL, A0, B6, ZL
  madd56hu ZH, A0, B6, x0
  madd56lu ZL, A1, B5, ZL
  madd56hu ZH, A1, B5, ZH
  madd56lu ZL, A2, B4, ZL
  madd56hu ZH, A2, B4, ZH
  madd56lu ZL, A3, B3, ZL
  madd56hu ZH, A3, B3, ZH
  madd56lu ZL, A4, B2, ZL
  madd56hu ZH, A4, B2, ZH
  madd56lu ZL, A5, B1, ZL
  madd56hu ZH, A5, B1, ZH
  madd56lu ZL, A6, B0, ZL
  madd56hu ZH, A6, B0, ZH
  sd       ZL, 48(a0)
.endm

.macro COMPUTE_R7
  madd56lu ZH, A0, B7, ZH
  madd56hu ZL, A0, B7, x0
  madd56lu ZH, A1, B6, ZH
  madd56hu ZL, A1, B6, ZL
  madd56lu ZH, A2, B5, ZH
  madd56hu ZL, A2, B5, ZL
  madd56lu ZH, A3, B4, ZH
  madd56hu ZL, A3, B4, ZL
  madd56lu ZH, A4, B3, ZH
  madd56hu ZL, A4, B3, ZL
  madd56lu ZH, A5, B2, ZH
  madd56hu ZL, A5, B2, ZL
  madd56lu ZH, A6, B1, ZH
  madd56hu ZL, A6, B1, ZL
  madd56lu ZH, A7, B0, ZH
  madd56hu ZL, A7, B0, ZL
  sd       ZH, 56(a0)
.endm

.macro COMPUTE_R8
  madd56lu ZL, A0, B8, ZL
  madd56hu ZH, A0, B8, x0
  madd56lu ZL, A1, B7, ZL
  madd56hu ZH, A1, B7, ZH
  madd56lu ZL, A2, B6, ZL
  madd56hu ZH, A2, B6, ZH
  madd56lu ZL, A3, B5, ZL
  madd56hu ZH, A3, B5, ZH
  madd56lu ZL, A4, B4, ZL
  madd56hu ZH, A4, B4, ZH
  madd56lu ZL, A5, B3, ZL
  madd56hu ZH, A5, B3, ZH
  madd56lu ZL, A6, B2, ZL
  madd56hu ZH, A6, B2, ZH
  madd56lu ZL, A7, B1, ZL
  madd56hu ZH, A7, B1, ZH
  madd56lu ZL, A8, B0, ZL
  madd56hu ZH, A8, B0, ZH
  sd       ZL, 64(a0)
.endm

.macro COMPUTE_R9
  madd56lu ZH, A0, B9, ZH
  madd56hu ZL, A0, B9, x0
  madd56lu ZH, A1, B8, ZH
  madd56hu ZL, A1, B8, ZL
  madd56lu ZH, A2, B7, ZH
  madd56hu ZL, A2, B7, ZL
  madd56lu ZH, A3, B6, ZH
  madd56hu ZL, A3, B6, ZL
  madd56lu ZH, A4, B5, ZH
  madd56hu ZL, A4, B5, ZL
  madd56lu ZH, A5, B4, ZH
  madd56hu ZL, A5, B4, ZL
  madd56lu ZH, A6, B3, ZH
  madd56hu ZL, A6, B3, ZL
  madd56lu ZH, A7, B2, ZH
  madd56hu ZL, A7, B2, ZL
  madd56lu ZH, A8, B1, ZH
  madd56hu ZL, A8, B1, ZL
  madd56lu ZH, A9, B0, ZH
  madd56hu ZL, A9, B0, ZL
  sd       ZH, 72(a0)
.endm

.macro COMPUTE_R10
  madd56lu ZL, A0, B10, ZL
  madd56hu ZH, A0, B10, x0
  madd56lu ZL, A1, B9, ZL
  madd56hu ZH, A1, B9, ZH
  madd56lu ZL, A2, B8, ZL
  madd56hu ZH, A2, B8, ZH
  madd56lu ZL, A3, B7, ZL
  madd56hu ZH, A3, B7, ZH
  madd56lu ZL, A4, B6, ZL
  madd56hu ZH, A4, B6, ZH
  madd56lu ZL, A5, B5, ZL
  madd56hu ZH, A5, B5, ZH
  madd56lu ZL, A6, B4, ZL
  madd56hu ZH, A6, B4, ZH
  madd56lu ZL, A7, B3, ZL
  madd56hu ZH, A7, B3, ZH
  madd56lu ZL, A8, B2, ZL
  madd56hu ZH, A8, B2, ZH
  madd56lu ZL, A9, B1, ZL
  madd56hu ZH, A9, B1, ZH
  madd56lu ZL, A10, B0, ZL
  madd56hu ZH, A10, B0, ZH
  sd       ZL, 80(a0)
.endm

.macro COMPUTE_R11
  madd56lu ZH, A1, B10, ZH
  madd56hu ZL, A1, B10, x0
  madd56lu ZH, A2, B9, ZH
  madd56hu ZL, A2, B9, ZL
  madd56lu ZH, A3, B8, ZH
  madd56hu ZL, A3, B8, ZL
  madd56lu ZH, A4, B7, ZH
  madd56hu ZL, A4, B7, ZL
  madd56lu ZH, A5, B6, ZH
  madd56hu ZL, A5, B6, ZL
  madd56lu ZH, A6, B5, ZH
  madd56hu ZL, A6, B5, ZL
  madd56lu ZH, A7, B4, ZH
  madd56hu ZL, A7, B4, ZL
  madd56lu ZH, A8, B3, ZH
  madd56hu ZL, A8, B3, ZL
  madd56lu ZH, A9, B2, ZH
  madd56hu ZL, A9, B2, ZL
  madd56lu ZH, A10, B1, ZH
  madd56hu ZL, A10, B1, ZL
  sd       ZH, 88(a0)
.endm

.macro COMPUTE_R12
  madd56lu ZL, A2, B10, ZL
  madd56hu ZH, A2, B10, x0
  madd56lu ZL, A3, B9, ZL
  madd56hu ZH, A3, B9, ZH
  madd56lu ZL, A4, B8, ZL
  madd56hu ZH, A4, B8, ZH
  madd56lu ZL, A5, B7, ZL
  madd56hu ZH, A5, B7, ZH
  madd56lu ZL, A6, B6, ZL
  madd56hu ZH, A6, B6, ZH
  madd56lu ZL, A7, B5, ZL
  madd56hu ZH, A7, B5, ZH
  madd56lu ZL, A8, B4, ZL
  madd56hu ZH, A8, B4, ZH
  madd56lu ZL, A9, B3, ZL
  madd56hu ZH, A9, B3, ZH
  madd56lu ZL, A10, B2, ZL
  madd56hu ZH, A10, B2, ZH
  sd       ZL, 96(a0)
.endm

.macro COMPUTE_R13
  madd56lu ZH, A3, B10, ZH
  madd56hu ZL, A3, B10, x0
  madd56lu ZH, A4, B9, ZH
  madd56hu ZL, A4, B9, ZL
  madd56lu ZH, A5, B8, ZH
  madd56hu ZL, A5, B8, ZL
  madd56lu ZH, A6, B7, ZH
  madd56hu ZL, A6, B7, ZL
  madd56lu ZH, A7, B6, ZH
  madd56hu ZL, A7, B6, ZL
  madd56lu ZH, A8, B5, ZH
  madd56hu ZL, A8, B5, ZL
  madd56lu ZH, A9, B4, ZH
  madd56hu ZL, A9, B4, ZL
  madd56lu ZH, A10, B3, ZH
  madd56hu ZL, A10, B3, ZL
  sd       ZH,104(a0)
.endm

.macro COMPUTE_R14
  madd56lu ZL, A4, B10, ZL
  madd56hu ZH, A4, B10, x0
  madd56lu ZL, A5, B9, ZL
  madd56hu ZH, A5, B9, ZH
  madd56lu ZL, A6, B8, ZL
  madd56hu ZH, A6, B8, ZH
  madd56lu ZL, A7, B7, ZL
  madd56hu ZH, A7, B7, ZH
  madd56lu ZL, A8, B6, ZL
  madd56hu ZH, A8, B6, ZH
  madd56lu ZL, A9, B5, ZL
  madd56hu ZH, A9, B5, ZH
  madd56lu ZL, A10, B4, ZL
  madd56hu ZH, A10, B4, ZH
  sd       ZL,112(a0)
.endm

.macro COMPUTE_R15
  madd56lu ZH, A5, B10, ZH
  madd56hu ZL, A5, B10, x0
  madd56lu ZH, A6, B9, ZH
  madd56hu ZL, A6, B9, ZL
  madd56lu ZH, A7, B8, ZH
  madd56hu ZL, A7, B8, ZL
  madd56lu ZH, A8, B7, ZH
  madd56hu ZL, A8, B7, ZL
  madd56lu ZH, A9, B6, ZH
  madd56hu ZL, A9, B6, ZL
  madd56lu ZH, A10, B5, ZH
  madd56hu ZL, A10, B5, ZL
  sd       ZH,120(a0)
.endm

.macro COMPUTE_R16
  madd56lu ZL, A6, B10, ZL
  madd56hu ZH, A6, B10, x0
  madd56lu ZL, A7, B9, ZL
  madd56hu ZH, A7, B9, ZH
  madd56lu ZL, A8, B8, ZL
  madd56hu ZH, A8, B8, ZH
  madd56lu ZL, A9, B7, ZL
  madd56hu ZH, A9, B7, ZH
  madd56lu ZL, A10, B6, ZL
  madd56hu ZH, A10, B6, ZH
  sd       ZL,128(a0)
.endm

.macro COMPUTE_R17
  madd56lu ZH, A7, B10, ZH
  madd56hu ZL, A7, B10, x0
  madd56lu ZH, A8, B9, ZH
  madd56hu ZL, A8, B9, ZL
  madd56lu ZH, A9, B8, ZH
  madd56hu ZL, A9, B8, ZL
  madd56lu ZH, A10, B7, ZH
  madd56hu ZL, A10, B7, ZL
  sd       ZH,136(a0)
.endm

.macro COMPUTE_R18
  madd56lu ZL, A8, B10, ZL
  madd56hu ZH, A8, B10, x0
  madd56lu ZL, A9, B9, ZL
  madd56hu ZH, A9, B9, ZH
  madd56lu ZL, A10, B8, ZL
  madd56hu ZH, A10, B8, ZH
  sd       ZL,144(a0)
.endm

.macro COMPUTE_R19
  madd56lu ZH, A9, B10, ZH
  madd56hu ZL, A9, B10, x0
  madd56lu ZH, A10, B9, ZH
  madd56hu ZL, A10, B9, ZL
  sd       ZH,152(a0)
.endm

.macro COMPUTE_R20
  madd56lu ZL, A10, B10, ZL
  madd56hu ZH, A10, B10, x0
  sd       ZL,160(a0)
.endm

.macro COMPUTE_R21
  sd       ZH,168(a0)
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
  COMPUTE_R16
  COMPUTE_R17
  COMPUTE_R18
  COMPUTE_R19
  COMPUTE_R20
  COMPUTE_R21
  EPILOGUE
