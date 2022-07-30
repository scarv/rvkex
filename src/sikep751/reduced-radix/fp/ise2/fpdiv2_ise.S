// void fpdiv2_v0_ise(uint64_t *r, const uint64_t *a);
// radix-2^56


#include "ise2.h"


// registers

// result "r"
#define R0  t0
#define R1  t1
#define R2  t2
#define R3  a3
#define R4  a4
#define R5  a5
#define R6  a6
#define R7  a7
#define R8  s0
#define R9  s1
#define R10 s2
#define R11 s3
#define R12 s4
#define R13 a2

// operand "a"
#define A_  t3

// modulus "p"
#define P_  t4

// temp "t"
#define T_  t5

// constants and masks
#define M0  t6


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -40
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
  sd    s4, 32(sp)
  la    a2, P751
  li    M0, 0xFFFFFFFFFFFFFFULL
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

.macro STORE_R 
  sd    R0,   0(a0)
  sd    R1,   8(a0)
  sd    R2,  16(a0)
  sd    R3,  24(a0)
  sd    R4,  32(a0)
  sd    R5,  40(a0)
  sd    R6,  48(a0)
  sd    R7,  56(a0)
  sd    R8,  64(a0)
  sd    R9,  72(a0)
  sd    R10, 80(a0)
  sd    R11, 88(a0)
  sd    R12, 96(a0)
  sd    R13,104(a0)
.endm

// arithmetic computation

.macro GET_MASK 
  ld    A_,  0(a1)
  andi  T_, A_,  1
  sub   T_, x0, T_
.endm

.macro _COMPUTE_R R, imm
  ld    A_, 8*\imm(a1)
  ld    P_, 8*\imm-40(a2)
  and   P_, P_, T_
  add   \R, A_, P_
.endm

.macro ADD_MASKEDP 
  ld    P_,  0(a2)
  and   P_, P_, T_
  add   R0, A_, P_
  ld    A_,  8(a1)
  add   R1, A_, P_
  ld    A_, 16(a1)
  add   R2, A_, P_
  ld    A_, 24(a1)
  add   R3, A_, P_
  ld    A_, 32(a1)
  add   R4, A_, P_
  ld    A_, 40(a1)
  add   R5, A_, P_
  _COMPUTE_R R6, 6
  _COMPUTE_R R7, 7
  _COMPUTE_R R8, 8
  _COMPUTE_R R9, 9
  _COMPUTE_R R10, 10
  _COMPUTE_R R11, 11
  _COMPUTE_R R12, 12
  _COMPUTE_R R13, 13
.endm

.macro _PROPAGATE_CARRY A, B 
  sraiadd \B, \B, \A, 56
  and     \A, \A, M0
.endm

.macro CARRY_PROPAGATION 
  _PROPAGATE_CARRY R0,  R1
  _PROPAGATE_CARRY R1,  R2
  _PROPAGATE_CARRY R2,  R3
  _PROPAGATE_CARRY R3,  R4
  _PROPAGATE_CARRY R4,  R5
  _PROPAGATE_CARRY R5,  R6
  _PROPAGATE_CARRY R6,  R7
  _PROPAGATE_CARRY R7,  R8
  _PROPAGATE_CARRY R8,  R9
  _PROPAGATE_CARRY R9,  R10
  _PROPAGATE_CARRY R10, R11
  _PROPAGATE_CARRY R11, R12
  _PROPAGATE_CARRY R12, R13
.endm

.macro _RIGHT_SHIFT A, B
  andi   T_, \B,  1
  slli   T_, T_, 55
  srai   \A, \A,  1
  xor    \A, \A, T_
.endm

.macro RIGHT_SHITF 
  _RIGHT_SHIFT R0,  R1
  _RIGHT_SHIFT R1,  R2
  _RIGHT_SHIFT R2,  R3
  _RIGHT_SHIFT R3,  R4
  _RIGHT_SHIFT R4,  R5
  _RIGHT_SHIFT R5,  R6
  _RIGHT_SHIFT R6,  R7
  _RIGHT_SHIFT R7,  R8
  _RIGHT_SHIFT R8,  R9
  _RIGHT_SHIFT R9,  R10
  _RIGHT_SHIFT R10, R11
  _RIGHT_SHIFT R11, R12
  _RIGHT_SHIFT R12, R13
  srai   R13, R13, 1
.endm


// field division by 2 using ISE

.section .text

// v0: conventional one

.global fpdiv2_v0_ise

fpdiv2_v0_ise:
  PROLOGUE
  GET_MASK
  ADD_MASKEDP
  CARRY_PROPAGATION
  RIGHT_SHITF
  STORE_R
  EPILOGUE


.section .data 
.balign 8

P751:
.dword 0xFFFFFFFFFFFFFF                 // P0
// .dword 0xFFFFFFFFFFFFFF              // P1 
// .dword 0xFFFFFFFFFFFFFF              // P2 
// .dword 0xFFFFFFFFFFFFFF              // P3
// .dword 0xFFFFFFFFFFFFFF              // P4
// .dword 0xFFFFFFFFFFFFFF              // P5
.dword 0xA8EEAFFFFFFFFF                 // P6
.dword 0xE3EC968549F878                 // P7
.dword 0x959B1A13F7CC76                 // P8
.dword 0x9867D6EBE876DA                 // P9
.dword 0x045CB25748084E                 // P10
.dword 0x97BADC668562B5                 // P11
.dword 0x41F71C0E12909F                 // P12
.dword 0x000000006FE5D5                 // P13