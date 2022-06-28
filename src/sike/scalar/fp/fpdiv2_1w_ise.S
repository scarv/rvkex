// void fpdiv2_1w_v0_ise(uint64_t *r, const uint64_t *a);
// radix-56


#include "ise.h"


// meaningful names for registers

// result "r"
#define R0 t0
#define R1 t1
#define R2 t2
#define R3 a3
#define R4 a4
#define R5 a5
#define R6 a6
#define R7 a7

// operand "a"
#define A_ t3

// modulus "p"
#define P_ t4

// temp "t"
#define T_ t5

// constants and masks
#define M0 t6


// prologue + epilogue 

.macro PROLOGUE
  la    a2, P434
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

.macro GET_MASK 
  ld    A_,  0(a1)
  andi  T_, A_,  1
  sub   T_, x0, T_
.endm

.macro _COMPUTE_R R, imm
  ld    A_, 8*\imm(a1)
  ld    P_, 8*\imm(a2)
  and   P_, P_, T_
  add   \R, A_, P_
.endm

.macro ADD_MASKEDP 
  ld    P_,  0(a2)
  and   P_, P_, T_
  add   R0, A_, P_
  _COMPUTE_R R1, 1
  _COMPUTE_R R2, 2
  _COMPUTE_R R3, 3
  _COMPUTE_R R4, 4
  _COMPUTE_R R5, 5
  _COMPUTE_R R6, 6
  _COMPUTE_R R7, 7
.endm

.macro _PROPAGATE_CARRY A, B 
  sraadd \B, \B, \A, 56
  and    \A, \A, M0
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

.macro _RIGHT_SHIFT A, B
  andi   T_, \B,  1
  slli   T_, T_, 55
  srai   \A, \A,  1
  xor    \A, \A, T_
.endm

.macro RIGHT_SHITF 
  _RIGHT_SHIFT R0, R1
  _RIGHT_SHIFT R1, R2
  _RIGHT_SHIFT R2, R3
  _RIGHT_SHIFT R3, R4
  _RIGHT_SHIFT R4, R5
  _RIGHT_SHIFT R5, R6
  _RIGHT_SHIFT R6, R7
  srai   R7, R7,  1
.endm


// 1-way field division by 2

.section .text

// v0: conventional one

.global fpdiv2_1w_v0_ise

fpdiv2_1w_v0_ise:
  PROLOGUE
  GET_MASK
  ADD_MASKEDP
  CARRY_PROPAGATION
  RIGHT_SHITF
  STORE_R
  EPILOGUE


.section .data 
.balign 8

P434:
.dword 0xFFFFFFFFFFFFFF 
.dword 0xFFFFFFFFFFFFFF
.dword 0xFFFFFFFFFFFFFF
.dword 0xE2FFFFFFFFFFFF
.dword 0x58AEA3FDC1767A
.dword 0x20567BC65C7831
.dword 0x446CFC5FD681C5
.dword 0x0002341F271773
