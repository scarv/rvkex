// void uint_mul3_ka_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^57, Karatsuba
// no carry propagation since it will be done in Montgomery reduction


#include "ise2.h"

// prologue + epilogue 

.macro PROLOGUE
  addi  sp,  sp, -136
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
  addi  sp,  sp, 136 
  ret 
.endm

// load operand

.macro LOAD_OPERAND addr, A0, A1, A2, A3, A4, A5, A6, A7, A8 
  ld    \A0,  0(\addr)
  ld    \A1,  8(\addr)
  ld    \A2, 16(\addr)
  ld    \A3, 24(\addr)
  ld    \A4, 32(\addr)
  ld    \A5, 40(\addr)
  ld    \A6, 48(\addr)
  ld    \A7, 56(\addr)
  ld    \A8, 64(\addr)
.endm

// 4 * 4 limbs multiplication based on product-scanning
// R0-R7 = A0-A3 * B0-B3

// L != 0, H != 0
.macro _ACCU_AIBJ_1 
  add   Z0, Z0, T0 
  sltu  T0, Z0, T0
  add   Z1, Z1, T1
  add   Z1, Z1, T0
.endm

.macro _PROPA_CARRY 
  srli  Z0, Z0, 57
  slli  T0, Z1,  7
  xor   Z0, Z0, T0
  srli  Z1, Z1, 57
.endm

.macro MUL_4X4_PS R0, R1, R2, R3, R4, R5, R6, R7, A0, A1, A2, A3, B0, B1, B2, B3
  // compute R0 R1
  madd57lu \R0, \A0, \B0,  x0
  madd57hu \R1, \A0, \B0,  x0
  // compute R1 R2
  madd57lu \R1, \A0, \B1, \R1
  madd57hu \R2, \A0, \B1,  x0
  madd57lu \R1, \A1, \B0, \R1
  madd57hu \R2, \A1, \B0, \R2
  // compute R2 R3
  madd57lu \R2, \A0, \B2, \R2
  madd57hu \R3, \A0, \B2,  x0
  madd57lu \R2, \A1, \B1, \R2
  madd57hu \R3, \A1, \B1, \R3
  madd57lu \R2, \A2, \B0, \R2
  madd57hu \R3, \A2, \B0, \R3
  // compute R3 R4
  madd57lu \R3, \A0, \B3, \R3
  madd57hu \R4, \A0, \B3,  x0
  madd57lu \R3, \A1, \B2, \R3
  madd57hu \R4, \A1, \B2, \R4
  madd57lu \R3, \A2, \B1, \R3
  madd57hu \R4, \A2, \B1, \R4
  madd57lu \R3, \A3, \B0, \R3
  madd57hu \R4, \A3, \B0, \R4
  // compute R4 R5
  madd57lu \R4, \A1, \B3, \R4
  madd57hu \R5, \A1, \B3,  x0
  madd57lu \R4, \A2, \B2, \R4
  madd57hu \R5, \A2, \B2, \R5
  madd57lu \R4, \A3, \B1, \R4
  madd57hu \R5, \A3, \B1, \R5
  // compute R5 R6
  madd57lu \R5, \A2, \B3, \R5
  madd57hu \R6, \A2, \B3,  x0
  madd57lu \R5, \A3, \B2, \R5
  madd57hu \R6, \A3, \B2, \R6
  // compute R6 R7
  madd57lu \R6, \A3, \B3, \R6
  madd57hu \R7, \A3, \B3,  x0
.endm

.macro MUL_5X5_PS R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, A0, A1, A2, A3, A4, B0, B1, B2, B3, B4
  // compute R0 R1
  madd57lu \R0, \A0, \B0,  x0
  madd57hu \R1, \A0, \B0,  x0
  // compute R1 R2
  madd57lu \R1, \A0, \B1, \R1
  madd57hu \R2, \A0, \B1,  x0
  madd57lu \R1, \A1, \B0, \R1
  madd57hu \R2, \A1, \B0, \R2
  // compute R2 R3
  madd57lu \R2, \A0, \B2, \R2
  madd57hu \R3, \A0, \B2,  x0
  madd57lu \R2, \A1, \B1, \R2
  madd57hu \R3, \A1, \B1, \R3
  madd57lu \R2, \A2, \B0, \R2
  madd57hu \R3, \A2, \B0, \R3
  // compute R3 R4
  madd57lu \R3, \A0, \B3, \R3
  madd57hu \R4, \A0, \B3,  x0
  madd57lu \R3, \A1, \B2, \R3
  madd57hu \R4, \A1, \B2, \R4
  madd57lu \R3, \A2, \B1, \R3
  madd57hu \R4, \A2, \B1, \R4
  madd57lu \R3, \A3, \B0, \R3
  madd57hu \R4, \A3, \B0, \R4
  // compute R4 R5
  madd57lu \R4, \A0, \B4, \R4
  madd57hu \R5, \A0, \B4,  x0
  madd57lu \R4, \A1, \B3, \R4
  madd57hu \R5, \A1, \B3, \R5
  madd57lu \R4, \A2, \B2, \R4
  madd57hu \R5, \A2, \B2, \R5
  madd57lu \R4, \A3, \B1, \R4
  madd57hu \R5, \A3, \B1, \R5
  madd57lu \R4, \A4, \B0, \R4
  madd57hu \R5, \A4, \B0, \R5 
  // compute R5 R6
  madd57lu \R5, \A1, \B4, \R5
  madd57hu \R6, \A1, \B4,  x0
  madd57lu \R5, \A2, \B3, \R5
  madd57hu \R6, \A2, \B3, \R6
  madd57lu \R5, \A3, \B2, \R5
  madd57hu \R6, \A3, \B2, \R6
  madd57lu \R5, \A4, \B1, \R5
  madd57hu \R6, \A4, \B1, \R6
  // compute R6 R7
  madd57lu \R6, \A2, \B4, \R6
  madd57hu \R7, \A2, \B4,  x0
  madd57lu \R6, \A3, \B3, \R6
  madd57hu \R7, \A3, \B3, \R7
  madd57lu \R6, \A4, \B2, \R6
  madd57hu \R7, \A4, \B2, \R7
  // compute R7 R8
  madd57lu \R7, \A3, \B4, \R7
  madd57hu \R8, \A3, \B4,  x0
  madd57lu \R7, \A4, \B3, \R7
  madd57hu \R8, \A4, \B3, \R8
  // compute R8 R9
  madd57lu \R8, \A4, \B4, \R8
  madd57hu \R9, \A4, \B4,  x0
.endm


.section .text 

.global uint_mul3_ka_ise 

uint_mul3_ka_ise:
  PROLOGUE

  // t0-t4  <- AH + AL
  LOAD_OPERAND a1, s0, s1, s2, s3, t4, s5, s6, s7, s8
  add   t0, s0, s5
  add   t1, s1, s6
  add   t2, s2, s7
  add   t3, s3, s8
  // s9-s11, t5-t6 <- BH + BL
  LOAD_OPERAND a2, s0, s1, s2, s3, t6, s5, s6, s7, s8
  add   s9,  s0, s5
  add   s10, s1, s6
  add   s11, s2, s7
  add   t5,  s3, s8
  // s0-s9 <- (AH+AL) * (BH+BL)
  MUL_5X5_PS s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, t0, t1, t2, t3, t4, s9, s10, s11, t5, t6 

  // t0-t4 <- AL
  ld    t0,   0(a1)
  ld    t1,   8(a1)
  ld    t2,  16(a1)
  ld    t3,  24(a1)
  ld    t4,  32(a1)
  // push a1
  sd    a1,  96(sp)
  // t5-t6, s10-s11, a1 <- BL 
  ld    t5,   0(a2)
  ld    t6,   8(a2)
  ld    s10, 16(a2)
  ld    s11, 24(a2)
  ld    a1,  32(a2)
  // a3-a7, t0, t5, t1, t6, t3 <- AL * BL 
  MUL_5X5_PS a3, a4, a5, a6, a7, t0, t5, t1, t6, t3, t0, t1, t2, t3, t4, t5, t6, s10, s11, a1
  // (AH+AL) * (BH+BL) - AL * BL
  sub   s0, s0, a3
  sub   s1, s1, a4
  sub   s2, s2, a5 
  sub   s3, s3, a6 
  sub   s4, s4, a7
  // store R0-R4
  sd    a3,   0(a0)
  sd    a4,   8(a0)
  sd    a5,  16(a0)
  sd    a6,  24(a0)
  sd    a7,  32(a0)
  // pop a1
  ld    a1,  96(sp)
  // continue (AH+AL) * (BH+BL) - AL * BL
  sub   s5, s5, t0
  sub   s6, s6, t5
  sub   s7, s7, t1
  sub   s8, s8, t6 
  sub   s9, s9, t3 
  // [(AH+AL) * (BH+BL) - AL * BL] + (AL * BL)'
  add   s0, s0, t0
  add   s1, s1, t5
  add   s2, s2, t1
  add   s3, s3, t6
  add   s4, s4, t3

  // t0-t3  <- AH
  ld    a3,  40(a1)
  ld    a4,  48(a1)
  ld    a5,  56(a1)
  ld    a6,  64(a1)
  // t4-t6, s10 <- BH
  ld    t4,  40(a2)
  ld    t5,  48(a2)
  ld    t6,  56(a2)
  ld    s10, 64(a2)
  // a1-a2, s11, t0-t4 <- AH * BH
  MUL_4X4_PS a1, a2, s11, t0, t1, t2, t3, t4, a3, a4, a5, a6, t4, t5, t6, s10

  // [(AH+AL) * (BH+BL) - AL * BL - AH * BH] + (AL * BL)'
  sub   s0, s0, a1
  sub   s1, s1, a2
  sub   s2, s2, s11
  sub   s3, s3, t0
  sub   s4, s4, t1
  // [(AH+AL) * (BH+BL) - AL * BL - AH * BH]'
  sub   s5, s5, t2
  sub   s6, s6, t3
  sub   s7, s7, t4
  // store R5-R9
  sd    s0,  40(a0)
  sd    s1,  48(a0)
  sd    s2,  56(a0)
  sd    s3,  64(a0)
  sd    s4,  72(a0)
  // [(AH+AL) * (BH+BL) - AL * BL - AH * BH]' + (AH * BH)
  add   s5, s5, a1
  add   s6, s6, a2
  add   s7, s7, s11 
  add   s8, s8, t0
  add   s9, s9, t1
  // store R10-R14
  sd    s5,  80(a0)
  sd    s6,  88(a0)
  sd    s7,  96(a0)
  sd    s8, 104(a0)
  sd    s9, 112(a0)
  // store R15-R17
  sd    t2, 120(a0)
  sd    t3, 128(a0)
  sd    t4, 136(a0)

  EPILOGUE
