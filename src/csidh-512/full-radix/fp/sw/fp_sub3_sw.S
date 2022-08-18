// void fp_sub3_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^64


// registers

// result "r"
#define R0 s0
#define R1 s1
#define R2 s2
#define R3 s3
#define R4 s4
#define R5 s5
#define R6 s6
#define R7 s7 

// operand "a"
#define A_ t0

// operand "b"
#define B_ t1

// modulus "p"
#define P0 t4
#define P1 t5
#define P2 t6
#define P3 a3
#define P4 a4
#define P5 a5
#define P6 a6
#define P7 a7

// temp "t"
#define T0 t2
#define T1 t3


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -64
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
  sd    s4, 32(sp)
  sd    s5, 40(sp)
  sd    s6, 48(sp)
  sd    s7, 56(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  ld    s3, 24(sp)
  ld    s4, 32(sp)
  ld    s5, 40(sp)
  ld    s6, 48(sp)
  ld    s7, 56(sp)
  addi  sp, sp, 64
  ret 
.endm

// load modulus + store result

.macro LOAD_P
  la    t0, P511
  ld    P0,  0(t0)
  ld    P1,  8(t0)
  ld    P2, 16(t0)
  ld    P3, 24(t0)
  ld    P4, 32(t0)
  ld    P5, 40(t0)
  ld    P6, 48(t0)
  ld    P7, 56(t0)
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
.endm

// arithmetic computation

.macro _AI_SUB_BI R, imm
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2)
  sltu  T1, A_, T0 
  sub   \R, A_, T0
  sltu  T0, \R, B_
  sub   \R, \R, B_ 
  or    T0, T0, T1
.endm

.macro _A0_SUB_B0 
  ld    A_,  0(a1)
  ld    B_,  0(a2)
  sltu  T0, A_, B_
  sub   R0, A_, B_
.endm

.macro A_SUB_B
  _A0_SUB_B0
  _AI_SUB_BI R1,   1
  _AI_SUB_BI R2,   2
  _AI_SUB_BI R3,   3
  _AI_SUB_BI R4,   4
  _AI_SUB_BI R5,   5
  _AI_SUB_BI R6,   6
  _AI_SUB_BI R7,   7
.endm

.macro MASK_P
  sub   T0, x0, T0
  and   P0, P0, T0
  and   P1, P1, T0
  and   P2, P2, T0
  and   P3, P3, T0
  and   P4, P4, T0
  and   P5, P5, T0
  and   P6, P6, T0
  and   P7, P7, T0
.endm

.macro _RI_ADD_PI R, P
  add   \R, \R, T0 
  sltu  T0, \R, T0 
  add   \R, \R, \P
  sltu  T1, \R, \P
  or    T0, T0, T1
.endm

.macro ADD_MASK 
  add  R0, R0, P0
  sltu T0, R0, P0
  _RI_ADD_PI   R1, P1 
  _RI_ADD_PI   R2, P2
  _RI_ADD_PI   R3, P3
  _RI_ADD_PI   R4, P4
  _RI_ADD_PI   R5, P5
  _RI_ADD_PI   R6, P6
  add  R7, R7, T0 
  add  R7, R7, P7
.endm


.section .text

.global fp_sub3_sw

fp_sub3_sw:
  PROLOGUE
  LOAD_P
  A_SUB_B
  MASK_P
  ADD_MASK
  STORE_R
  EPILOGUE


.section .data 

.balign 8 

P511: 
.dword 0x1b81b90533c6c87b               // P0 
.dword 0xc2721bf457aca835               // P1
.dword 0x516730cc1f0b4f25               // P2
.dword 0xa7aac6c567f35507               // P3
.dword 0x5afbfcc69322c9cd               // P4 
.dword 0xb42d083aedc88c42               // P5
.dword 0xfc8ab0d15e3e4c4a               // P6
.dword 0x65b48e8f740f89bf               // P7
