// void mp_subadd_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^56
// no reduction, no propagation


// registers

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

// modulus "p"
#define P0 a3
#define P1 a4
#define P2 a5
#define P3 a6
#define P4 a7
#define P5 t3 
#define P6 t4
#define P7 t5

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
  ld    P7,   56(a2)
.endm

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
  srai  T_, R0, 56
  add   T_, T_, R1
  srai  T_, T_, 56
  add   T_, T_, R2
  srai  T_, T_, 56
  add   T_, T_, R3
  srai  T_, T_, 56
  add   T_, T_, R4
  srai  T_, T_, 56
  add   T_, T_, R5
  srai  T_, T_, 56
  add   T_, T_, R6
  srai  T_, T_, 56
  add   T_, T_, R7
  srai  T_, T_, 56
  add   T_, T_, R8
  srai  T_, T_, 56
  add   T_, T_, R9
  srai  T_, T_, 56
  add   T_, T_, R10
  srai  T_, T_, 56
  add   T_, T_, R11
  srai  T_, T_, 56
  add   T_, T_, R12
  srai  T_, T_, 56
  add   T_, T_, R13
  srai  T_, T_, 56
  add   T_, T_, R14
  srai  T_, T_, 56
  add   T_, T_, R15
  srai  T_, T_, 63
.endm

.macro MASK_P
  and   P0, P0, T_
  and   P1, P1, T_
  and   P2, P2, T_
  and   P3, P3, T_
  and   P4, P4, T_
  and   P5, P5, T_
  and   P6, P6, T_
  and   P7, P7, T_
.endm

.macro ADD_MASK 
  add   R8,  R8,  P0
  add   R9,  R9,  P1
  add   R10, R10, P2
  add   R11, R11, P3
  add   R12, R12, P4
  add   R13, R13, P5
  add   R14, R14, P6
  add   R15, R15, P7
.endm

// integer subadd

.section .text

// v0: conventional one

.global mp_subadd_v0_sw

mp_subadd_v0_sw:
  PROLOGUE
  SUBTRACTION
  GET_SIGN
  STORE_R1ST
  LOAD_P
  MASK_P
  ADD_MASK
  STORE_R2ND
  EPILOGUE


.section .data 
.balign 8

P434:
.dword 0xFFFFFFFFFFFFFF                 // P0 
.dword 0xFFFFFFFFFFFFFF                 // P1
.dword 0xFFFFFFFFFFFFFF                 // P2
.dword 0xE2FFFFFFFFFFFF                 // P3
.dword 0x58AEA3FDC1767A                 // P4
.dword 0x20567BC65C7831                 // P5
.dword 0x446CFC5FD681C5                 // P6
.dword 0x0002341F271773                 // P7