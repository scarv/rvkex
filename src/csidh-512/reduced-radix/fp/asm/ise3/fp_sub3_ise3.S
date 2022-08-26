// void fp_sub3_ise3(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^57


#include "ise3.h"
#include "../ise2/ise2.h"


// registers 

// result and operand `r`
#define R0 t3
#define R1 t4
#define R2 t5
#define R3 t6
#define R4 a3
#define R5 a4
#define R6 a5
#define R7 a6
#define R8 a7

// operand `a`
#define A_ t0

// operand `b`
#define B_ t1

// temporary value `t`
#define T_ t0

// mask `m`
#define M_ t2


// prologue + epilogue 

.macro PROLOGUE
  li    M_, 0x1FFFFFFFFFFFFFFULL
.endm

.macro EPILOGUE
  ret 
.endm

// store result

.macro STORE_R 
  sd    R0,  0(a0)
  sd    R1,  8(a0)
  sd    R2, 16(a0)
  sd    R3, 24(a0)
  sd    R4, 32(a0)
  sd    R5, 40(a0)
  sd    R6, 48(a0)
  sd    R7, 56(a0)
  sd    R8, 64(a0)
.endm

// arithmetic computation

.macro _A_SUB_B_I R, imm
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2) 
  sub   \R, A_, B_
.endm

.macro A_SUB_B 
  _A_SUB_B_I R0, 0
  _A_SUB_B_I R1, 1
  _A_SUB_B_I R2, 2
  _A_SUB_B_I R3, 3
  _A_SUB_B_I R4, 4
  _A_SUB_B_I R5, 5
  _A_SUB_B_I R6, 6
  _A_SUB_B_I R7, 7
  _A_SUB_B_I R8, 8
.endm

.macro ADD_MASK 
  csidh.and.p512.add57 R0, T_, R0, 0
  csidh.and.p512.add57 R1, T_, R1, 1
  csidh.and.p512.add57 R2, T_, R2, 2
  csidh.and.p512.add57 R3, T_, R3, 3
  csidh.and.p512.add57 R4, T_, R4, 4
  csidh.and.p512.add57 R5, T_, R5, 5
  csidh.and.p512.add57 R6, T_, R6, 6
  csidh.and.p512.add57 R7, T_, R7, 7
  csidh.and.p512.add57 R8, T_, R8, 8
.endm

// carry propagation

.macro GET_SIGN 
  sraiadd T_, R1, R0, 57
  sraiadd T_, R2, T_, 57
  sraiadd T_, R3, T_, 57
  sraiadd T_, R4, T_, 57
  sraiadd T_, R5, T_, 57
  sraiadd T_, R6, T_, 57
  sraiadd T_, R7, T_, 57
  sraiadd T_, R8, T_, 57
  srai    T_, T_, 63
.endm

.macro _PROPAGATE_CARRY A, B 
  sraiadd \B, \B, \A, 57
  and     \A, \A, M_
.endm

.macro CARRY_PROPAGATION 
  _PROPAGATE_CARRY R0, R1
  _PROPAGATE_CARRY R1, R2
  _PROPAGATE_CARRY R2, R3
  _PROPAGATE_CARRY R3, R4
  _PROPAGATE_CARRY R4, R5
  _PROPAGATE_CARRY R5, R6
  _PROPAGATE_CARRY R6, R7
  _PROPAGATE_CARRY R7, R8
.endm


.section .text

.global fp_sub3_ise3

fp_sub3_ise3:
  PROLOGUE
  A_SUB_B
  GET_SIGN
  ADD_MASK
  CARRY_PROPAGATION
  STORE_R
  EPILOGUE
