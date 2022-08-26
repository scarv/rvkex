// void reduce_once_ad_ise3(uint64_t *a)
// radix-2^57


#include "../ise2/ise2.h" 
#include "ise3.h"


// registers 

// result and operand `r`
#define R0 t2
#define R1 t3
#define R2 t4
#define R3 t5
#define R4 t6
#define R5 a2
#define R6 a3
#define R7 a4
#define R8 a5

// temporary value `t`
#define T_ t0

// mask `m`
#define M_ t1


// prologue + epilogue 

.macro PROLOGUE
  li    M_, 0x1FFFFFFFFFFFFFFULL
.endm

.macro EPILOGUE
  ret 
.endm

// load operand + store result

.macro LOAD_R 
  ld    R0,  0(a0)
  ld    R1,  8(a0)
  ld    R2, 16(a0)
  ld    R3, 24(a0)
  ld    R4, 32(a0)
  ld    R5, 40(a0)
  ld    R6, 48(a0)
  ld    R7, 56(a0)
  ld    R8, 64(a0)
.endm

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

.macro R_SUB_P
  csidh.sub.p512.57 R0, R0, 0
  csidh.sub.p512.57 R1, R1, 1
  csidh.sub.p512.57 R2, R2, 2
  csidh.sub.p512.57 R3, R3, 3
  csidh.sub.p512.57 R4, R4, 4
  csidh.sub.p512.57 R5, R5, 5
  csidh.sub.p512.57 R6, R6, 6
  csidh.sub.p512.57 R7, R7, 7
  csidh.sub.p512.57 R8, R8, 8
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

.global reduce_once_ad_ise3

reduce_once_ad_ise3:
  PROLOGUE
  LOAD_R
  R_SUB_P
  GET_SIGN
  ADD_MASK
  CARRY_PROPAGATION
  STORE_R
  EPILOGUE
