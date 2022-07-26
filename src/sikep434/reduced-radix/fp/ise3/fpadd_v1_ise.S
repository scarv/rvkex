// void fpadd_v1_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^56


#include "../ise2/ise2.h"
#include "ise3.h"


// registers

// result "r"
#define R0 t3
#define R1 t4
#define R2 t5
#define R3 t6
#define R4 a4
#define R5 a5
#define R6 a6
#define R7 a7

// operand "a"
#define A_ t0

// operand "b"
#define B_ t1

// temp "t"
#define T_ t0

// constants and masks
#define M0 t2


// prologue + epilogue 

.macro PROLOGUE
  li    M0, 0xFFFFFFFFFFFFFFULL
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
.endm

// arithmetic computation

.macro _COMPUTE_R R, imm
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2)
  sike.sub.p434x2.add56 \R, A_, B_, \imm
.endm

.macro COMPUTE_R 
  _COMPUTE_R R0, 0
  _COMPUTE_R R1, 1
  _COMPUTE_R R2, 2
  _COMPUTE_R R3, 3
  _COMPUTE_R R4, 4
  _COMPUTE_R R5, 5
  _COMPUTE_R R6, 6
  _COMPUTE_R R7, 7
.endm

.macro ADD_MASK
  sike.and.p434x2.add56 R0, T_, R0, 0
  sike.and.p434x2.add56 R1, T_, R1, 1
  sike.and.p434x2.add56 R2, T_, R2, 2
  sike.and.p434x2.add56 R3, T_, R3, 3
  sike.and.p434x2.add56 R4, T_, R4, 4
  sike.and.p434x2.add56 R5, T_, R5, 5
  sike.and.p434x2.add56 R6, T_, R6, 6
  sike.and.p434x2.add56 R7, T_, R7, 7
.endm

// carry propagation 

.macro GET_SIGN 
  sraiadd T_, R1, R0, 56
  sraiadd T_, R2, T_, 56
  sraiadd T_, R3, T_, 56
  sraiadd T_, R4, T_, 56
  sraiadd T_, R5, T_, 56
  sraiadd T_, R6, T_, 56
  sraiadd T_, R7, T_, 56
  srai    T_, T_, 63
.endm

.macro _PROPAGATE_CARRY A, B 
  sraiadd \B, \B, \A, 56
  and     \A, \A, M0
.endm

.macro CARRY_PROPAGATION 
  _PROPAGATE_CARRY R0, R1
  _PROPAGATE_CARRY R1, R2
  _PROPAGATE_CARRY R2, R3
  _PROPAGATE_CARRY R3, R4
  _PROPAGATE_CARRY R4, R5
  _PROPAGATE_CARRY R5, R6
  _PROPAGATE_CARRY R6, R7
.endm


// field addition using ISE

.section .text

// v1: using specific-use ISE

.global fpadd_v1_ise

fpadd_v1_ise:
  PROLOGUE
  COMPUTE_R
  GET_SIGN
  ADD_MASK
  CARRY_PROPAGATION
  STORE_R
  EPILOGUE
