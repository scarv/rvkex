// void mp_subadd_v1_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^56
// no reduction, no propagation


#include "../ise2/ise2.h"
#include "ise3.h"


// result "r"
#define R0  a3
#define R1  a4
#define R2  a5
#define R3  a6
#define R4  a7
#define R5  t3
#define R6  t4
#define R7  t5
#define R8  t1
#define R9  t6
#define R10 s0
#define R11 s1
#define R12 s2
#define R13 s3
#define R14 s4
#define R15 t2

// operand "a"
#define A_ t0

// operand "b"
#define B_ t2

// temp "t"
#define T_ t0


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -40
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
  sd    s4, 32(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  ld    s3, 24(sp)
  ld    s4, 32(sp)
  addi  sp, sp, 40
  ret 
.endm

// store result 

.macro STORE_R1ST 
  sd    R0,    0(a0)
  sd    R1,    8(a0)
  sd    R2,   16(a0)
  sd    R3,   24(a0)
  sd    R4,   32(a0)
  sd    R5,   40(a0)
  sd    R6,   48(a0)
  sd    R7,   56(a0)
.endm 

.macro STORE_R2ND 
  sd    R8,   64(a0)
  sd    R9,   72(a0)
  sd    R10,  80(a0)
  sd    R11,  88(a0)
  sd    R12,  96(a0)
  sd    R13, 104(a0)
  sd    R14, 112(a0)
  sd    R15, 120(a0)
.endm

// arithmetic computation

.macro _SUBTRACT R, imm 
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2)
  sub   \R, A_, B_
.endm

.macro SUBTRACTION
  _SUBTRACT R0,   0 
  _SUBTRACT R1,   1
  _SUBTRACT R2,   2
  _SUBTRACT R3,   3
  _SUBTRACT R4,   4
  _SUBTRACT R5,   5
  _SUBTRACT R6,   6
  _SUBTRACT R7,   7
  _SUBTRACT R8,   8 
  _SUBTRACT R9,   9
  _SUBTRACT R10, 10
  _SUBTRACT R11, 11
  _SUBTRACT R12, 12
  _SUBTRACT R13, 13
  _SUBTRACT R14, 14
  _SUBTRACT R15, 15
.endm

// carry propagation

.macro GET_SIGN 
  sraiadd T_, R1,  R0, 56
  sraiadd T_, R2,  T_, 56
  sraiadd T_, R3,  T_, 56
  sraiadd T_, R4,  T_, 56
  sraiadd T_, R5,  T_, 56
  sraiadd T_, R6,  T_, 56
  sraiadd T_, R7,  T_, 56
  sraiadd T_, R8,  T_, 56
  sraiadd T_, R9,  T_, 56
  sraiadd T_, R10, T_, 56
  sraiadd T_, R11, T_, 56
  sraiadd T_, R12, T_, 56
  sraiadd T_, R13, T_, 56
  sraiadd T_, R14, T_, 56
  sraiadd T_, R15, T_, 56
  srai    T_, T_, 63
.endm

.macro ADD_MASK 
  sike.and.p434.add56 R8,  T_, R8,  0
  sike.and.p434.add56 R9,  T_, R9,  1
  sike.and.p434.add56 R10, T_, R10, 2
  sike.and.p434.add56 R11, T_, R11, 3
  sike.and.p434.add56 R12, T_, R12, 4
  sike.and.p434.add56 R13, T_, R13, 5
  sike.and.p434.add56 R14, T_, R14, 6
  sike.and.p434.add56 R15, T_, R15, 7
.endm


// integer subadd using ISE

.section .text

// v1: using specific-use ISE

.global mp_subadd_v1_ise

mp_subadd_v1_ise:
  PROLOGUE
  SUBTRACTION
  GET_SIGN
  STORE_R1ST
  ADD_MASK
  STORE_R2ND
  EPILOGUE
