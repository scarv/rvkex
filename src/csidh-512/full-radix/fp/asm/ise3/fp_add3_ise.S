// void fp_add3_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^64


#include "ise3.h"


// registers

// result `r`
#define R0 t4
#define R1 t5
#define R2 t6
#define R3 a3
#define R4 a4
#define R5 a5
#define R6 a6
#define R7 a7 

// operand `a`
#define A_ t0

// operand `b`
#define B_ t1

// temporary value `t`
#define T0 t2
#define T1 t3


// prologue + epilogue 

.macro PROLOGUE
.endm

.macro EPILOGUE
  ret 
.endm

// arithmetic computation

.macro _A_ADD_B_I R, imm
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2) 
  add   \R, A_, B_
  sltu  T1, \R, A_
  add   \R, \R, T0
  sltu  T0, \R, T0
  or    T0, T0, T1 
.endm

.macro _A_ADD_B_0
  ld    A_,  0(a1)
  ld    B_,  0(a2)
  add   R0, A_, B_
  sltu  T0, R0, A_
.endm

.macro _A_ADD_B_7
  ld    A_, 56(a1)
  ld    B_, 56(a2)
  add   R7, A_, B_
  add   R7, R7, T0 
.endm

.macro A_ADD_B 
  _A_ADD_B_0
  _A_ADD_B_I R1, 1
  _A_ADD_B_I R2, 2
  _A_ADD_B_I R3, 3
  _A_ADD_B_I R4, 4
  _A_ADD_B_I R5, 5
  _A_ADD_B_I R6, 6
  _A_ADD_B_7
.endm

.macro _R_SUB_P_0 
  csidh.sub.p512 B_, R0, 0
  sltu           T0, R0, B_
.endm

.macro _R_SUB_P_I S, R, imm
  sltu           T1, \R, T0 
  sub            \R, \R, T0
  csidh.sub.p512 \S, \R, \imm
  sltu           T0, \R, \S
  or             T0, T0, T1
.endm

// R0-R7 -> B_, R0-R6
.macro R_SUB_P
  _R_SUB_P_0
  _R_SUB_P_I R0, R1, 1
  _R_SUB_P_I R1, R2, 2
  _R_SUB_P_I R2, R3, 3
  _R_SUB_P_I R3, R4, 4
  _R_SUB_P_I R4, R5, 5
  _R_SUB_P_I R5, R6, 6
  _R_SUB_P_I R6, R7, 7
.endm

.macro _ADD_MASK R, imm
  csidh.and.p512.add A_, T0, \R, \imm
  sltu               \R, A_, \R 
  add                A_, A_, T1
  sltu               T1, A_, T1 
  or                 T1, T1, \R
  sd                 A_, 8*\imm(a0)
.endm

.macro ADD_MASK 
  sub                T0, x0, T0
  csidh.and.p512.add A_, T0, B_, 0
  sltu               T1, A_, B_
  sd                 A_, 0(a0)
  _ADD_MASK          R0, 1
  _ADD_MASK          R1, 2
  _ADD_MASK          R2, 3
  _ADD_MASK          R3, 4
  _ADD_MASK          R4, 5
  _ADD_MASK          R5, 6
  _ADD_MASK          R6, 7
.endm


.section .text

.global fp_add3_ise

fp_add3_ise:
  PROLOGUE
  A_ADD_B
  R_SUB_P
  ADD_MASK
  EPILOGUE
