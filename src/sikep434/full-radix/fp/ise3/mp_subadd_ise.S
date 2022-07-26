// void mp_subadd_v1_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^64


#include "ise3.h"


// registers

// result "r"
#define R0  t0
#define R1  t1
#define R2  t2
#define R3  t3
#define R4  t4
#define R5  t5
#define R6  t6
#define R7  a7
#define R8  s0
#define R9  s1
#define R10 s2
#define R11 s3
#define R12 s4
#define R13 s5

// operand "a"
#define A_ a3

// operand "b"
#define B_ a4

// temp "t"
#define T0 a5
#define T1 a6


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

.macro STORE_R1ST 
  sd    R0,    0(a0)
  sd    R1,    8(a0)
  sd    R2,   16(a0)
  sd    R3,   24(a0)
  sd    R4,   32(a0)
  sd    R5,   40(a0)
  sd    R6,   48(a0)
.endm 

.macro STORE_R2ND
  sd    R0,   56(a0) 
  sd    R1,   64(a0)
  sd    R2,   72(a0)
  sd    R3,   80(a0)
  sd    R4,   88(a0)
  sd    R5,   96(a0)
  sd    R6,  104(a0)
.endm

// arithmetic computation

.macro _AI_SUB_BI R, imm
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2)
  sltu  T1, A_, T0 
  sub   \R, A_, T0
  sltu  T0, \R, B_
  sub   \R, \R, B_ 
  or    T0, T0, T1
.endm

.macro _A0_SUB_B0 
  ld    A_,  0(a1)
  ld    B_,  0(a2)
  sltu  T0, A_, B_
  sub   R0, A_, B_
.endm

.macro A_SUB_B
  _A0_SUB_B0
  _AI_SUB_BI R1,   1
  _AI_SUB_BI R2,   2
  _AI_SUB_BI R3,   3
  _AI_SUB_BI R4,   4
  _AI_SUB_BI R5,   5
  _AI_SUB_BI R6,   6
  _AI_SUB_BI R7,   7
  _AI_SUB_BI R8,   8
  _AI_SUB_BI R9,   9
  _AI_SUB_BI R10, 10
  _AI_SUB_BI R11, 11
  _AI_SUB_BI R12, 12
  _AI_SUB_BI R13, 13
.endm

.macro _ADD_MASK R, A, imm
  sike.and.p434.add64 \R, T0, \A, \imm
  sltu \A, \R, \A 
  add  \R, \R, T1
  sltu T1, \R, T1
  or   T1, T1, \A
.endm

.macro ADD_MASK 
  sub  T0, x0, T0
  sike.and.p434.add64 R0, T0, R7,  0
  sltu T1, R0, R7
  _ADD_MASK R1, R8,  1
  _ADD_MASK R2, R9,  2
  _ADD_MASK R3, R10, 3
  _ADD_MASK R4, R11, 4
  _ADD_MASK R5, R12, 5
  sike.and.p434.add64 R6, T0, R13, 6
  add  R6, R6, T1
.endm


// integer subadd

.section .text

// v1: using specific-use ISE

.global mp_subadd_v1_ise

mp_subadd_v1_ise:
  PROLOGUE
  A_SUB_B
  STORE_R1ST
  ADD_MASK
  STORE_R2ND
  EPILOGUE
