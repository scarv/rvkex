// void mp_mul_1w_v1(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-56, 1-level Karatsuba
// no carry propagation since it will be done in Montgomery reduction


#include "ise.h"


// meaningful names for registers

// accumulator "z"
#define ZL a3
#define ZH a4


// prologue + epilogue 

.macro PROLOGUE
  addi  sp,  sp, -104
  sd    s0,   0(sp)
  sd    s1,   8(sp)
  sd    s2,  16(sp)
  sd    s3,  24(sp)
  sd    s4,  32(sp)
  sd    s5,  40(sp)
  sd    s6,  48(sp)
  sd    s7,  56(sp)
  sd    s8,  64(sp)
  sd    s9,  72(sp)
  sd    s10, 80(sp)
  sd    s11, 88(sp)
.endm

.macro EPILOGUE
  ld    s0,   0(sp)
  ld    s1,   8(sp)
  ld    s2,  16(sp)
  ld    s3,  24(sp)
  ld    s4,  32(sp)
  ld    s5,  40(sp)
  ld    s6,  48(sp)
  ld    s7,  56(sp)
  ld    s8,  64(sp)
  ld    s9,  72(sp)
  ld    s10, 80(sp)
  ld    s11, 88(sp)
  addi  sp,  sp, 104 
  ret 
.endm

// load operand

.macro LOAD_OPERAND addr, A0, A1, A2, A3, A4, A5, A6, A7 
  ld    \A0,  0(\addr)
  ld    \A1,  8(\addr)
  ld    \A2, 16(\addr)
  ld    \A3, 24(\addr)
  ld    \A4, 32(\addr)
  ld    \A5, 40(\addr)
  ld    \A6, 48(\addr)
  ld    \A7, 56(\addr)
.endm 

// 4 limbs * 4 limbs multiplication based on product-scanning
// R0-R7 = A0-A3 * B0-B3

.macro MUL_4X4_PS R0, R1, R2, R3, R4, R5, R6, R7, A0, A1, A2, A3, B0, B1, B2, B3
  // compute R0 R1
  macc56lo \R0, \A0, \B0,  x0
  macc56hi \R1, \A0, \B0,  x0
  // compute R1 R2
  macc56lo \R1, \A0, \B1, \R1
  macc56hi \R2, \A0, \B1,  x0
  macc56lo \R1, \A1, \B0, \R1
  macc56hi \R2, \A1, \B0, \R2
  // compute R2 R3
  macc56lo \R2, \A0, \B2, \R2
  macc56hi \R3, \A0, \B2,  x0
  macc56lo \R2, \A1, \B1, \R2
  macc56hi \R3, \A1, \B1, \R3
  macc56lo \R2, \A2, \B0, \R2
  macc56hi \R3, \A2, \B0, \R3
  // compute R3 R4
  macc56lo \R3, \A0, \B3, \R3
  macc56hi \R4, \A0, \B3,  x0
  macc56lo \R3, \A1, \B2, \R3
  macc56hi \R4, \A1, \B2, \R4
  macc56lo \R3, \A2, \B1, \R3
  macc56hi \R4, \A2, \B1, \R4
  macc56lo \R3, \A3, \B0, \R3
  macc56hi \R4, \A3, \B0, \R4
  // compute R4 R5
  macc56lo \R4, \A1, \B3, \R4
  macc56hi \R5, \A1, \B3,  x0
  macc56lo \R4, \A2, \B2, \R4
  macc56hi \R5, \A2, \B2, \R5
  macc56lo \R4, \A3, \B1, \R4
  macc56hi \R5, \A3, \B1, \R5
  // compute R5 R6
  macc56lo \R5, \A2, \B3, \R5
  macc56hi \R6, \A2, \B3,  x0
  macc56lo \R5, \A3, \B2, \R5
  macc56hi \R6, \A3, \B2, \R6
  // compute R6 R7
  macc56lo \R6, \A3, \B3, \R6
  macc56hi \R7, \A3, \B3,  x0
.endm


// 1-way integer multiplication 

.section .text 

// v1: 1-level Karatsuba 

.global mp_mul_1w_v1_ise 

mp_mul_1w_v1_ise:
  PROLOGUE

  // t0-t3  <- AH + AL
  LOAD_OPERAND a1, s0, s1, s2, s3, s4, s5, s6, s7
  add   t0, s0, s4
  add   t1, s1, s5
  add   t2, s2, s6 
  add   t3, s3, s7
  // s8-s11 <- BH + BL
  LOAD_OPERAND a2, s0, s1, s2, s3, s4, s5, s6, s7
  add   s8,  s0, s4
  add   s9,  s1, s5
  add   s10, s2, s6
  add   s11, s3, s7
  // s0-s7 <- (AH+AL) * (BH+BL)
  MUL_4X4_PS s0, s1, s2, s3, s4, s5, s6, s7, t0, t1, t2, t3, s8, s9, s10, s11 

  // t0-t3  <- AL
  ld    t0,   0(a1)
  ld    t1,   8(a1)
  ld    t2,  16(a1)
  ld    t3,  24(a1)
  // s8-s11 <- BL
  ld    s8,   0(a2)
  ld    s9,   8(a2)
  ld    s10, 16(a2)
  ld    s11, 24(a2)
  // push a2
  sd    a2,  96(sp)
  // a2, t4-t6, t0-t3 <- AL * BL
  MUL_4X4_PS a2, t4, t5, t6, t0, t1, t2, t3, t0, t1, t2, t3, s8, s9, s10, s11
  // (AH+AL) * (BH+BL) - AL * BL
  sub   s0, s0, a2  
  sub   s1, s1, t4
  sub   s2, s2, t5
  sub   s3, s3, t6
  sub   s4, s4, t0
  sub   s5, s5, t1
  sub   s6, s6, t2
  sub   s7, s7, t3
  // store R0-R3
  sd    a2,   0(a0)
  sd    t4,   8(a0)
  sd    t5,  16(a0)
  sd    t6,  24(a0)
  // pop a2 
  ld    a2,  96(sp)
  // [(AH+AL) * (BH+BL) - AL * BL] + (AL * BL)'
  add   s0, s0, t0
  add   s1, s1, t1
  add   s2, s2, t2
  add   s3, s3, t3

  // t0-t3  <- AH
  ld    t0,  32(a1)
  ld    t1,  40(a1)
  ld    t2,  48(a1)
  ld    t3,  56(a1)
  // s8-s11 <- BH
  ld    s8,  32(a2)
  ld    s9,  40(a2)
  ld    s10, 48(a2)
  ld    s11, 56(a2)
  // a2, t4-t6, t0-t3 <- AH * BH
  MUL_4X4_PS a2, t4, t5, t6, t0, t1, t2, t3, t0, t1, t2, t3, s8, s9, s10, s11
  // [(AH+AL) * (BH+BL) - AL * BL - AH * BH] + (AL * BL)'
  sub   s0, s0, a2  
  sub   s1, s1, t4
  sub   s2, s2, t5
  sub   s3, s3, t6
  // [(AH+AL) * (BH+BL) - AL * BL - AH * BH]'
  sub   s4, s4, t0
  sub   s5, s5, t1
  sub   s6, s6, t2
  sub   s7, s7, t3
  // store R4-R7
  sd    s0,  32(a0)
  sd    s1,  40(a0)
  sd    s2,  48(a0)
  sd    s3,  56(a0)
  // [(AH+AL) * (BH+BL) - AL * BL - AH * BH]' + (AH * BH)
  add   s4, s4, a2
  add   s5, s5, t4
  add   s6, s6, t5 
  add   s7, s7, t6
  // store R8-R11
  sd    s4,  64(a0)
  sd    s5,  72(a0)
  sd    s6,  80(a0)
  sd    s7,  88(a0)
  // store R12-R15
  sd    t0,  96(a0)
  sd    t1, 104(a0)
  sd    t2, 112(a0)
  sd    t3, 120(a0)

  EPILOGUE