// void fpadd_v0_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^56


#include "ise2.h"


// registers

// result "r"
#define R0 s0
#define R1 s1
#define R2 s2
#define R3 t2
#define R4 t4
#define R5 t5
#define R6 t6
#define R7 a7
#define R8 s3

// operand "a"
#define A_ t0

// operand "b"
#define B_ t1

// temp "t"
#define T_ t0

// modulus "2p"
#define P0 t1
#define P1 a1
#define P2 a1
#define P3 a1
#define P4 a4
#define P5 a5
#define P6 a6
#define P7 a2
#define P8 a3

// constants and masks
#define M0 t3


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -32
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
  li    M0, 0xFFFFFFFFFFFFFFULL
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  ld    s3, 24(sp)
  addi  sp, sp, 32
  ret 
.endm

// load operand + store result

.macro LOAD_P
  la    t0, P503X2
  ld    P0,  0(t0)
  addi  P1, P0, 1 
  ld    P4,  8(t0)
  ld    P5, 16(t0)
  ld    P6, 24(t0)
  ld    P7, 32(t0)
  ld    P8, 40(t0)
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

.macro _COMPUTE_R R, imm
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2)
  add   \R, A_, B_
.endm 

.macro ADDITION
  _COMPUTE_R R0, 0
  _COMPUTE_R R1, 1
  _COMPUTE_R R2, 2
  _COMPUTE_R R3, 3
  _COMPUTE_R R4, 4
  _COMPUTE_R R5, 5
  _COMPUTE_R R6, 6
  _COMPUTE_R R7, 7
  _COMPUTE_R R8, 8
.endm

.macro SUBTRACTION 
  sub   R0, R0, P0
  sub   R1, R1, P1
  sub   R2, R2, P2
  sub   R3, R3, P3
  sub   R4, R4, P4
  sub   R5, R5, P5
  sub   R6, R6, P6
  sub   R7, R7, P7
  sub   R8, R8, P8 
.endm

.macro MASK_2P
  and   P0, P0, T_
  and   P1, P1, T_
//and   P2, P2, T_
//and   P3, P3, T_
  and   P4, P4, T_
  and   P5, P5, T_
  and   P6, P6, T_
  and   P7, P7, T_
  and   P8, P8, T_
.endm

.macro ADD_MASK 
  add   R0, R0, P0
  add   R1, R1, P1
  add   R2, R2, P2
  add   R3, R3, P3
  add   R4, R4, P4
  add   R5, R5, P5
  add   R6, R6, P6
  add   R7, R7, P7
  add   R8, R8, P8
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
  sraiadd T_, R8, T_, 56
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
  _PROPAGATE_CARRY R7, R8
.endm


// field addition using ISE

.section .text

// v0: conventional one

.global fpadd_v0_ise

fpadd_v0_ise:
  PROLOGUE
  ADDITION
  LOAD_P
  SUBTRACTION
  GET_SIGN
  MASK_2P
  ADD_MASK
  CARRY_PROPAGATION
  STORE_R
  EPILOGUE


.section .data 
.balign 8

P503X2:
.dword 0xFFFFFFFFFFFFFE                 // P0
// .dword 0xFFFFFFFFFFFFFF              // P1 
// .dword 0xFFFFFFFFFFFFFF              // P2 
// .dword 0xFFFFFFFFFFFFFF              // P3
.dword 0x23CF4157FFFFFF                 // P4
.dword 0xFB5E2610B7B444                 // P5
.dword 0xA03737ED90F6FC                 // P6
.dword 0xC08B8D7BB4EF49                 // P7
.dword 0x80CDEA83023C3C                 // P8
