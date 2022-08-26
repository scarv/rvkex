// void uint_mul3_ps_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^57, product-scanning


#include "ise2.h"


// registers

// accumulator `z`
#define Z0 a1
#define Z1 a2

// operand `b` 
#define B0 t0 
#define B1 t1
#define B2 t2
#define B3 t3
#define B4 t4
#define B5 t5
#define B6 t6
#define B7 a7
#define B8 a3

// operand `a`
#define A0 s0 
#define A1 s1
#define A2 s2 
#define A3 s3
#define A4 s4
#define A5 s5
#define A6 a4
#define A7 a5
#define A8 a6


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -48
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
  sd    s4, 32(sp)
  sd    s5, 40(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  ld    s3, 24(sp)
  ld    s4, 32(sp)
  ld    s5, 40(sp)
  addi  sp, sp, 48
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
  ld    A8, 64(a1)
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
  ld    B8, 64(a2)
.endm 

// integer multiplication (based on product-scanning)

.macro COMPUTE_R0
  madd57lu Z0, A0, B0, x0
  madd57hu Z1, A0, B0, x0
  sd       Z0,  0(a0)
.endm

.macro COMPUTE_R1
  madd57lu Z1, A0, B1, Z1
  madd57hu Z0, A0, B1, x0
  madd57lu Z1, A1, B0, Z1
  madd57hu Z0, A1, B0, Z0
  sd       Z1,  8(a0)
.endm

.macro COMPUTE_R2
  madd57lu Z0, A0, B2, Z0
  madd57hu Z1, A0, B2, x0
  madd57lu Z0, A1, B1, Z0
  madd57hu Z1, A1, B1, Z1
  madd57lu Z0, A2, B0, Z0
  madd57hu Z1, A2, B0, Z1
  sd       Z0, 16(a0)
.endm

.macro COMPUTE_R3
  madd57lu Z1, A0, B3, Z1
  madd57hu Z0, A0, B3, x0
  madd57lu Z1, A1, B2, Z1
  madd57hu Z0, A1, B2, Z0
  madd57lu Z1, A2, B1, Z1
  madd57hu Z0, A2, B1, Z0
  madd57lu Z1, A3, B0, Z1
  madd57hu Z0, A3, B0, Z0
  sd       Z1, 24(a0)
.endm

.macro COMPUTE_R4
  madd57lu Z0, A0, B4, Z0
  madd57hu Z1, A0, B4, x0
  madd57lu Z0, A1, B3, Z0
  madd57hu Z1, A1, B3, Z1
  madd57lu Z0, A2, B2, Z0
  madd57hu Z1, A2, B2, Z1
  madd57lu Z0, A3, B1, Z0
  madd57hu Z1, A3, B1, Z1
  madd57lu Z0, A4, B0, Z0
  madd57hu Z1, A4, B0, Z1
  sd       Z0, 32(a0)
.endm

.macro COMPUTE_R5
  madd57lu Z1, A0, B5, Z1
  madd57hu Z0, A0, B5, x0
  madd57lu Z1, A1, B4, Z1
  madd57hu Z0, A1, B4, Z0
  madd57lu Z1, A2, B3, Z1
  madd57hu Z0, A2, B3, Z0
  madd57lu Z1, A3, B2, Z1
  madd57hu Z0, A3, B2, Z0
  madd57lu Z1, A4, B1, Z1
  madd57hu Z0, A4, B1, Z0
  madd57lu Z1, A5, B0, Z1
  madd57hu Z0, A5, B0, Z0
  sd       Z1, 40(a0)
.endm

.macro COMPUTE_R6
  madd57lu Z0, A0, B6, Z0
  madd57hu Z1, A0, B6, x0
  madd57lu Z0, A1, B5, Z0
  madd57hu Z1, A1, B5, Z1
  madd57lu Z0, A2, B4, Z0
  madd57hu Z1, A2, B4, Z1
  madd57lu Z0, A3, B3, Z0
  madd57hu Z1, A3, B3, Z1
  madd57lu Z0, A4, B2, Z0
  madd57hu Z1, A4, B2, Z1
  madd57lu Z0, A5, B1, Z0
  madd57hu Z1, A5, B1, Z1
  madd57lu Z0, A6, B0, Z0
  madd57hu Z1, A6, B0, Z1
  sd       Z0, 48(a0)
.endm

.macro COMPUTE_R7
  madd57lu Z1, A0, B7, Z1
  madd57hu Z0, A0, B7, x0
  madd57lu Z1, A1, B6, Z1
  madd57hu Z0, A1, B6, Z0
  madd57lu Z1, A2, B5, Z1
  madd57hu Z0, A2, B5, Z0
  madd57lu Z1, A3, B4, Z1
  madd57hu Z0, A3, B4, Z0
  madd57lu Z1, A4, B3, Z1
  madd57hu Z0, A4, B3, Z0
  madd57lu Z1, A5, B2, Z1
  madd57hu Z0, A5, B2, Z0
  madd57lu Z1, A6, B1, Z1
  madd57hu Z0, A6, B1, Z0
  madd57lu Z1, A7, B0, Z1
  madd57hu Z0, A7, B0, Z0
  sd       Z1, 56(a0)
.endm

.macro COMPUTE_R8
  madd57lu Z0, A0, B8, Z0
  madd57hu Z1, A0, B8, x0
  madd57lu Z0, A1, B7, Z0
  madd57hu Z1, A1, B7, Z1
  madd57lu Z0, A2, B6, Z0
  madd57hu Z1, A2, B6, Z1
  madd57lu Z0, A3, B5, Z0
  madd57hu Z1, A3, B5, Z1
  madd57lu Z0, A4, B4, Z0
  madd57hu Z1, A4, B4, Z1
  madd57lu Z0, A5, B3, Z0
  madd57hu Z1, A5, B3, Z1
  madd57lu Z0, A6, B2, Z0
  madd57hu Z1, A6, B2, Z1
  madd57lu Z0, A7, B1, Z0
  madd57hu Z1, A7, B1, Z1
  madd57lu Z0, A8, B0, Z0
  madd57hu Z1, A8, B0, Z1
  sd       Z0, 64(a0)
.endm

.macro COMPUTE_R9
  madd57lu Z1, A1, B8, Z1
  madd57hu Z0, A1, B8, x0
  madd57lu Z1, A2, B7, Z1
  madd57hu Z0, A2, B7, Z0
  madd57lu Z1, A3, B6, Z1
  madd57hu Z0, A3, B6, Z0
  madd57lu Z1, A4, B5, Z1
  madd57hu Z0, A4, B5, Z0
  madd57lu Z1, A5, B4, Z1
  madd57hu Z0, A5, B4, Z0
  madd57lu Z1, A6, B3, Z1
  madd57hu Z0, A6, B3, Z0
  madd57lu Z1, A7, B2, Z1
  madd57hu Z0, A7, B2, Z0
  madd57lu Z1, A8, B1, Z1
  madd57hu Z0, A8, B1, Z0
  sd       Z1, 72(a0)
.endm

.macro COMPUTE_R10
  madd57lu Z0, A2, B8, Z0
  madd57hu Z1, A2, B8, x0
  madd57lu Z0, A3, B7, Z0
  madd57hu Z1, A3, B7, Z1
  madd57lu Z0, A4, B6, Z0
  madd57hu Z1, A4, B6, Z1
  madd57lu Z0, A5, B5, Z0
  madd57hu Z1, A5, B5, Z1
  madd57lu Z0, A6, B4, Z0
  madd57hu Z1, A6, B4, Z1
  madd57lu Z0, A7, B3, Z0
  madd57hu Z1, A7, B3, Z1
  madd57lu Z0, A8, B2, Z0
  madd57hu Z1, A8, B2, Z1
  sd       Z0, 80(a0)
.endm

.macro COMPUTE_R11
  madd57lu Z1, A3, B8, Z1
  madd57hu Z0, A3, B8, x0
  madd57lu Z1, A4, B7, Z1
  madd57hu Z0, A4, B7, Z0
  madd57lu Z1, A5, B6, Z1
  madd57hu Z0, A5, B6, Z0
  madd57lu Z1, A6, B5, Z1
  madd57hu Z0, A6, B5, Z0
  madd57lu Z1, A7, B4, Z1
  madd57hu Z0, A7, B4, Z0
  madd57lu Z1, A8, B3, Z1
  madd57hu Z0, A8, B3, Z0
  sd       Z1, 88(a0)
.endm

.macro COMPUTE_R12
  madd57lu Z0, A4, B8, Z0
  madd57hu Z1, A4, B8, x0
  madd57lu Z0, A5, B7, Z0
  madd57hu Z1, A5, B7, Z1
  madd57lu Z0, A6, B6, Z0
  madd57hu Z1, A6, B6, Z1
  madd57lu Z0, A7, B5, Z0
  madd57hu Z1, A7, B5, Z1
  madd57lu Z0, A8, B4, Z0
  madd57hu Z1, A8, B4, Z1
  sd       Z0, 96(a0)
.endm

.macro COMPUTE_R13
  madd57lu Z1, A5, B8, Z1
  madd57hu Z0, A5, B8, x0
  madd57lu Z1, A6, B7, Z1
  madd57hu Z0, A6, B7, Z0
  madd57lu Z1, A7, B6, Z1
  madd57hu Z0, A7, B6, Z0
  madd57lu Z1, A8, B5, Z1
  madd57hu Z0, A8, B5, Z0
  sd       Z1,104(a0)
.endm

.macro COMPUTE_R14
  madd57lu Z0, A6, B8, Z0
  madd57hu Z1, A6, B8, x0
  madd57lu Z0, A7, B7, Z0
  madd57hu Z1, A7, B7, Z1
  madd57lu Z0, A8, B6, Z0
  madd57hu Z1, A8, B6, Z1
  sd       Z0,112(a0)
.endm

.macro COMPUTE_R15
  madd57lu Z1, A7, B8, Z1
  madd57hu Z0, A7, B8, x0
  madd57lu Z1, A8, B7, Z1
  madd57hu Z0, A8, B7, Z0
  sd       Z1,120(a0)
.endm

.macro COMPUTE_R16
  madd57lu Z0, A8, B8, Z0
  madd57hu Z1, A8, B8, x0
  sd       Z0,128(a0)
.endm

.macro COMPUTE_R17
  sd       Z1,136(a0)
.endm


.section .text

.global uint_mul3_ps_ise

uint_mul3_ps_ise:
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
  EPILOGUE
