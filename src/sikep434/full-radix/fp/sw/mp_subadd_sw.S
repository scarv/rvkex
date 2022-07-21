// void mp_subadd_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^64


// registers 

// result "r"
#define R0  t0
#define R1  t1
#define R2  t2
#define R3  t3
#define R4  t4
#define R5  t5
#define R6  t6
#define R7  a7
#define R8  s0
#define R9  s1
#define R10 s2
#define R11 s3
#define R12 s4
#define R13 s5

// modulus "p"
#define P0 t0
#define P1 t1
#define P2 t2
#define P3 t3
#define P4 t4
#define P5 t5
#define P6 t6

// operand "a"
#define A_ a3

// operand "b"
#define B_ a4

// temp "t"
#define T0 a5
#define T1 a6


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -48
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
  sd    s4, 32(sp)
  sd    s5, 40(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  ld    s3, 24(sp)
  ld    s4, 32(sp)
  ld    s5, 40(sp)
  addi  sp, sp, 48
  ret 
.endm

// load modulus + store result 

.macro LOAD_P
  la    a2,    P434
  ld    P0,    0(a2)
  ld    P1,    8(a2)
  ld    P2,   16(a2)
  ld    P3,   24(a2)
  ld    P4,   32(a2)
  ld    P5,   40(a2)
  ld    P6,   48(a2)
.endm

.macro STORE_R1ST 
  sd    R0,    0(a0)
  sd    R1,    8(a0)
  sd    R2,   16(a0)
  sd    R3,   24(a0)
  sd    R4,   32(a0)
  sd    R5,   40(a0)
  sd    R6,   48(a0)
.endm 

.macro STORE_R2ND
  sd    R7,   56(a0) 
  sd    R8,   64(a0)
  sd    R9,   72(a0)
  sd    R10,  80(a0)
  sd    R11,  88(a0)
  sd    R12,  96(a0)
  sd    R13, 104(a0)
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
  _AI_SUB_BI R8,   8
  _AI_SUB_BI R9,   9
  _AI_SUB_BI R10, 10
  _AI_SUB_BI R11, 11
  _AI_SUB_BI R12, 12
  _AI_SUB_BI R13, 13
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
.endm

.macro _RI_ADD_PJ R, P
  add   \R, \R, T0 
  sltu  T0, \R, T0 
  add   \R, \R, \P
  sltu  T1, \R, \P
  or    T0, T0, T1
.endm

.macro ADD_MASK 
  add  R7, R7, P0
  sltu T0, R7, P0
  _RI_ADD_PJ   R8,  P1 
  _RI_ADD_PJ   R9,  P2
  _RI_ADD_PJ   R10, P3
  _RI_ADD_PJ   R11, P4
  _RI_ADD_PJ   R12, P5
  add  R13, R13, T0 
  add  R13, R13, P6
.endm

// integer subadd

.section .text

.global mp_subadd_v0_sw

mp_subadd_v0_sw:
  PROLOGUE
  A_SUB_B
  STORE_R1ST
  LOAD_P
  MASK_P
  ADD_MASK
  STORE_R2ND
  EPILOGUE


.section .data 
.balign 8

P434:
.dword  0xFFFFFFFFFFFFFFFF              // P0
.dword  0xFFFFFFFFFFFFFFFF              // P1
.dword  0xFFFFFFFFFFFFFFFF              // P2
.dword  0xFDC1767AE2FFFFFF              // P3
.dword  0x7BC65C783158AEA3              // P4
.dword  0x6CFC5FD681C52056              // P5
.dword  0x0002341F27177344              // P6
