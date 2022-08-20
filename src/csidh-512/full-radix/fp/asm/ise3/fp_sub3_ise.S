// void fp_sub3_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
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

.macro _A_SUB_B_I R, imm
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2)
  sltu  T1, A_, T0 
  sub   \R, A_, T0
  sltu  T0, \R, B_
  sub   \R, \R, B_ 
  or    T0, T0, T1
.endm

.macro _A_SUB_B_0 
  ld    A_,  0(a1)
  ld    B_,  0(a2)
  sltu  T0, A_, B_
  sub   R0, A_, B_
.endm

.macro A_SUB_B
  _A_SUB_B_0
  _A_SUB_B_I R1, 1
  _A_SUB_B_I R2, 2
  _A_SUB_B_I R3, 3
  _A_SUB_B_I R4, 4
  _A_SUB_B_I R5, 5
  _A_SUB_B_I R6, 6
  _A_SUB_B_I R7, 7
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
  csidh.and.p512.add A_, T0, R0, 0
  sltu               T1, A_, R0
  sd                 A_, 0(a0)
  _ADD_MASK          R1, 1
  _ADD_MASK          R2, 2
  _ADD_MASK          R3, 3
  _ADD_MASK          R4, 4
  _ADD_MASK          R5, 5
  _ADD_MASK          R6, 6
  _ADD_MASK          R7, 7
.endm


.section .text

.global fp_sub3_ise

fp_sub3_ise:
  PROLOGUE
  A_SUB_B
  ADD_MASK
  EPILOGUE
