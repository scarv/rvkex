// void uint_mul3_ka_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^64, Karatsuba


#include "ise2.h"


// registers

// temporary value `t`
#define T0 a6
#define T1 a7


// prologue + epilogue

.macro PROLOGUE
  addi  sp,  sp, -112
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
  addi  sp,  sp, 112 
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

// 4 * 4 limbs multiplication based on product-scanning
// R0-R7 = A0-A3 * B0-B3

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

.macro MUL_4X4_PS R0, R1, R2, R3, R4, R5, R6, R7, A0, A1, A2, A3, B0, B1, B2, B3
  // compute R0
  maddlu \R0, \A0, \B0, x0
  maddhu \R1, \A0, \B0, x0
  // compute R1
  _ACCU_AIBJ_0  \R1, \R2, \R3,  T0, \A0, \B1
  _ACCU_AIBJ_1   T0, \R2, \R3, \R1, \A1, \B0
  // compute R2 
  _ACCU_AIBJ_1  \R2, \R3, \R4,  T0, \A0, \B2
  _ACCU_AIBJ_2   T0, \R3, \R4,  T1, \A1, \B1 
  _ACCU_AIBJ_2   T1, \R3, \R4, \R2, \A2, \B0
  // compute R3 
  _ACCU_AIBJ_1  \R3, \R4, \R5,  T0, \A0, \B3 
  _ACCU_AIBJ_2   T0, \R4, \R5, \R3, \A1, \B2 
  _ACCU_AIBJ_2  \R3, \R4, \R5,  T0, \A2, \B1 
  _ACCU_AIBJ_2   T0, \R4, \R5, \R3, \A3, \B0 
  // compute R4
  _ACCU_AIBJ_1  \R4, \R5, \R6,  T0, \A1, \B3
  _ACCU_AIBJ_2   T0, \R5, \R6,  T1, \A2, \B2
  _ACCU_AIBJ_2   T1, \R5, \R6, \R4, \A3, \B1
  // compute R5
  _ACCU_AIBJ_1  \R5, \R6, \R7,  T0, \A2, \B3
  _ACCU_AIBJ_2   T0, \R6, \R7, \R5, \A3, \B2
  // compute R6
  mv      T0, \R6
  maddlu \R6, \A3, \B3,  T0
  sltu    T0, \R6,  T0
  maddhu  T0, \A3, \B3,  T0
  // compute R7 
  add    \R7, \R7,  T0
.endm


.section .text 

.global uint_mul3_ka_ise 

uint_mul3_ka_ise:
  PROLOGUE

  // t0-t3 <- AH + AL, t4 <- mask
  LOAD_OPERAND a1, s0, s1, s2, s3, s4, s5, s6, s7
  add   t0, s0, s4
  sltu  s0, t0, s0
  add   t1, s0, s5
  sltu  s0, t1, s5
  add   t1, t1, s1
  sltu  s1, t1, s1
  or    s0, s0, s1
  add   t2, s0, s6
  sltu  s0, t2, s6
  add   t2, t2, s2
  sltu  s1, t2, s2
  or    s0, s0, s1
  add   t3, s0, s7
  sltu  s0, t3, s7
  add   t3, t3, s3
  sltu  s1, t3, s3
  or    t4, s0, s1
  // s8-s11 <- BH + BL, t5 <- mask
  LOAD_OPERAND a2, s0, s1, s2, s3, s4, s5, s6, s7
  add   s8,  s0,  s4
  sltu  s0,  s8,  s0
  add   s9,  s0,  s5
  sltu  s0,  s9,  s5
  add   s9,  s9,  s1
  sltu  s1,  s9,  s1
  or    s0,  s0,  s1
  add   s10, s0,  s6
  sltu  s0,  s10, s6
  add   s10, s10, s2
  sltu  s1,  s10, s2
  or    s0,  s0,  s1
  add   s11, s0,  s7
  sltu  s0,  s11, s7
  add   s11, s11, s3
  sltu  s1,  s11, s3
  or    t5,  s0,  s1
  // s0-s7 <- (AH+AL) * (BH+BL)
  MUL_4X4_PS s0, s1, s2, s3, s4, s5, s6, s7, t0, t1, t2, t3, s8, s9, s10, s11
  // t0-t3 <- masked (AH+AL)
  sub   t5, x0, t5 
  and   t0, t0, t5
  and   t1, t1, t5
  and   t2, t2, t5
  and   t3, t3, t5
  // s8-s11 <- masked (BH+BL)
  sub   t4,  x0,  t4
  and   s8,  s8,  t4
  and   s9,  s9,  t4
  and   s10, s10, t4
  and   s11, s11, t4
  // t0-t3 <- masked (AH+AL) + masked (BH+BL)
  add   t0, t0, s8
  sltu  s8, t0, s8
  add   t1, t1, s8
  sltu  s8, t1, s8
  add   t1, t1, s9
  sltu  s9, t1, s9
  or    s8, s8, s9
  add   t2, t2, s8
  sltu  s8, t2, s8
  add   t2, t2, s10
  sltu  s9, t2, s10
  or    s8, s8, s9
  add   t3, t3, s8
  add   t3, t3, s11
  // s0-s7 <- (AH+AL) * (BH+BL) + (masked (AH+AL)+masked (BH+BL))
  add   s4, s4, t0 
  sltu  t0, s4, t0
  add   s5, s5, t0 
  sltu  t0, s5, t0 
  add   s5, s5, t1 
  sltu  t1, s5, t1 
  or    t0, t0, t1 
  add   s6, s6, t0 
  sltu  t0, s6, t0 
  add   s6, s6, t2 
  sltu  t1, s6, t2 
  or    t0, t0, t1
  add   s7, s7, t0 
  add   s7, s7, t3 

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
  // a3-a5, t4-t6, t0, s8 <- AL * BL
  MUL_4X4_PS a3, a4, a5, t4, t5, t6, t0, s8, t0, t1, t2, t3, s8, s9, s10, s11
  // (AH+AL) * (BH+BL) - AL * BL
  sltu  s10, s0,  a3
  sub   s0,  s0,  a3
  sltu  s9,  s1,  s10
  sub   s1,  s1,  s10
  sltu  s10, s1,  a4
  sub   s1,  s1,  a4
  or    s10, s10, s9
  sltu  s9,  s2,  s10
  sub   s2,  s2,  s10
  sltu  s10, s2,  a5
  sub   s2,  s2,  a5
  or    s10, s10, s9
  sltu  s9,  s3,  s10
  sub   s3,  s3,  s10
  sltu  s10, s3,  t4
  sub   s3,  s3,  t4
  or    s10, s10, s9
  sltu  s9,  s4,  s10
  sub   s4,  s4,  s10
  sltu  s10, s4,  t5
  sub   s4,  s4,  t5
  or    s10, s10, s9
  sltu  s9,  s5,  s10
  sub   s5,  s5,  s10
  sltu  s10, s5,  t6
  sub   s5,  s5,  t6
  or    s10, s10, s9
  sltu  s9,  s6,  s10
  sub   s6,  s6,  s10
  sltu  s10, s6,  t0
  sub   s6,  s6,  t0
  or    s10, s10, s9
  sub   s7,  s7,  s10
  sub   s7,  s7,  s8
  // store R0-R3 
  sd    a3,   0(a0)
  sd    a4,   8(a0)
  sd    a5,  16(a0)
  sd    t4,  24(a0)
  // t5-t6, t0, s8 keeps (AL * BL)'

  // t1-t4  <- AH
  ld    t1,  32(a1)
  ld    t2,  40(a1)
  ld    t3,  48(a1)
  ld    t4,  56(a1)
  // s9-s11, a1 <- BH
  ld    s9,  32(a2)
  ld    s10, 40(a2)
  ld    s11, 48(a2)
  ld    a1,  56(a2)
  // a2-a5, s4, s5, t1, s9 <- AH * BH
  sd    s4,  96(sp)
  sd    s5, 104(sp) 
  MUL_4X4_PS a2, a3, a4, a5, s4, s5, t1, s9, t1, t2, t3, t4, s9, s10, s11, a1
  ld    a6,  96(sp)
  ld    a7, 104(sp) 
  // (AH+AL) * (BH+BL) - AL * BL - AH * BH
  sltu  t3, s0, a2 
  sub   s0, s0, a2
  sltu  t4, s1, t3
  sub   s1, s1, t3
  sltu  t3, s1, a3
  sub   s1, s1, a3
  or    t3, t3, t4
  sltu  t4, s2, t3
  sub   s2, s2, t3
  sltu  t3, s2, a4
  sub   s2, s2, a4
  or    t3, t3, t4
  sltu  t4, s3, t3
  sub   s3, s3, t3
  sltu  t3, s3, a5
  sub   s3, s3, a5
  or    t3, t3, t4
  sltu  t4, a6, t3
  sub   a6, a6, t3
  sltu  t3, a6, s4
  sub   a6, a6, s4
  or    t3, t3, t4
  sltu  t4, a7, t3
  sub   a7, a7, t3
  sltu  t3, a7, s5
  sub   a7, a7, s5
  or    t3, t3, t4
  sltu  t4, s6, t3
  sub   s6, s6, t3
  sltu  t3, s6, t1
  sub   s6, s6, t1
  or    t3, t3, t4
  sub   s7, s7, t3
  sub   s7, s7, s9

  // [(AH+AL) * (BH+BL) - AL * BL - AH * BH] + (AL * BL)'
  add   s0, s0, t5 
  sltu  t5, s0, t5 
  add   s1, s1, t5 
  sltu  t5, s1, t5 
  add   s1, s1, t6 
  sltu  t6, s1, t6 
  or    t5, t5, t6 
  add   s2, s2, t5 
  sltu  t5, s2, t5 
  add   s2, s2, t0 
  sltu  t6, s2, t0 
  or    t5, t5, t6 
  add   s3, s3, t5 
  sltu  t5, s3, t5 
  add   s3, s3, s8 
  sltu  t6, s3, s8 
  or    t5, t5, t6
  // store R4-R7
  sd    s0, 32(a0)
  sd    s1, 40(a0)
  sd    s2, 48(a0)
  sd    s3, 56(a0)
  // [(AH+AL) * (BH+BL) - AL * BL - AH * BH]' + (AH * BH)
  add   a6, a6, t5
  sltu  t5, a6, t5
  add   a6, a6, a2
  sltu  t6, a6, a2
  or    t5, t5, t6
  add   a7, a7, t5
  sltu  t5, a7, t5
  add   a7, a7, a3
  sltu  t6, a7, a3
  or    t5, t5, t6
  add   s6, s6, t5
  sltu  t5, s6, t5
  add   s6, s6, a4
  sltu  t6, s6, a4
  or    t5, t5, t6
  add   s7, s7, t5
  sltu  t5, s7, t5
  add   s7, s7, a5
  sltu  t6, s7, a5
  or    t5, t5, t6
  // store R8-R11
  sd    a6, 64(a0)
  sd    a7, 72(a0)
  sd    s6, 80(a0)
  sd    s7, 88(a0)
  // compute R12-R15
  add   s4, s4, t5 
  sltu  t5, s4, t5 
  add   s5, s5, t5
  sltu  t5, s5, t5
  add   t1, t1, t5
  sltu  t5, t1, t5
  add   s9, s9, t5
  // store R12-R15
  sd    s4, 96(a0)
  sd    s5,104(a0)
  sd    t1,112(a0)
  sd    s9,120(a0)

  EPILOGUE
