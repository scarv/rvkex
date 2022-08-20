// void reduce_once_ad_ise(uint64_t *a)
// radix-2^64
// NOTE that due to the lack of carry flag on RISC-V, the `cswap-based` 
// `reduce_once` is more efficient than `addition-based` version.


#include "ise3.h"


// registers 

// result `r`
#define R0 t2
#define R1 t3
#define R2 t4
#define R3 t5
#define R4 t6
#define R5 a1
#define R6 a2
#define R7 a3

// operand `a`
#define A_ a4

// temporary value `t`
#define T0 t0
#define T1 t1


// prologue + epilogue 

.macro PROLOGUE
.endm

.macro EPILOGUE
  ret 
.endm

// arithmetic computation

.macro _A_SUB_P_0 
  ld             A_, 0(a0)
  csidh.sub.p512 R0, A_, 0
  sltu           T0, A_, R0
.endm

.macro _A_SUB_P_I R, imm
  ld             A_, 8*\imm(a0)
  sltu           T1, A_, T0 
  sub            A_, A_, T0
  csidh.sub.p512 \R, A_, \imm
  sltu           T0, A_, \R
  or             T0, T0, T1
.endm

.macro A_SUB_P
  _A_SUB_P_0
  _A_SUB_P_I R1, 1
  _A_SUB_P_I R2, 2
  _A_SUB_P_I R3, 3
  _A_SUB_P_I R4, 4
  _A_SUB_P_I R5, 5
  _A_SUB_P_I R6, 6
  _A_SUB_P_I R7, 7
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

.global reduce_once_ad_ise

reduce_once_ad_ise:
  PROLOGUE
  A_SUB_P
  ADD_MASK
  EPILOGUE
