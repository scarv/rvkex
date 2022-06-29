// void fpcorrection_1w_v0(uint64_t *r);
// radix-56


// meaningful names for registers

// operand and result "r"
#define R0 s0
#define R1 s1
#define R2 s2
#define R3 s3
#define R4 t4
#define R5 t5
#define R6 t6
#define R7 a7

// modulus "p"
#define P0 t1
#define P1 a1
#define P2 a2
#define P3 a3
#define P4 a4
#define P5 a5
#define P6 a6
#define P7 t2

// temp "t"
#define T_ t0

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
  la    t0, P434
  ld    P0,  0(t0)
  ld    P1,  8(t0)
  ld    P2, 16(t0)
  ld    P3, 24(t0)
  ld    P4, 32(t0)
  ld    P5, 40(t0)
  ld    P6, 48(t0)
  ld    P7, 56(t0)
.endm

.macro LOAD_R 
  ld    R0,  0(a0)
  ld    R1,  8(a0)
  ld    R2, 16(a0)
  ld    R3, 24(a0)
  ld    R4, 32(a0)
  ld    R5, 40(a0)
  ld    R6, 48(a0)
  ld    R7, 56(a0)
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

.macro SUBTRACTION
  sub   R0, R0, P0
  sub   R1, R1, P1
  sub   R2, R2, P2
  sub   R3, R3, P3
  sub   R4, R4, P4
  sub   R5, R5, P5
  sub   R6, R6, P6
  sub   R7, R7, P7
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
  add   R0, R0, P0
  add   R1, R1, P1
  add   R2, R2, P2
  add   R3, R3, P3
  add   R4, R4, P4
  add   R5, R5, P5
  add   R6, R6, P6
  add   R7, R7, P7
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
  srai  T_, T_, 63
.endm

.macro _PROPAGATE_CARRY A, B 
  srai  T_, \A, 56
  add   \B, \B, T_
  and   \A, \A, M0
.endm

.macro CARRY_PROPAGATION 
  _PROPAGATE_CARRY R0, R1
  _PROPAGATE_CARRY R1, R2
  _PROPAGATE_CARRY R2, R3
  _PROPAGATE_CARRY R3, R4
  _PROPAGATE_CARRY R4, R5
  _PROPAGATE_CARRY R7, R6
  _PROPAGATE_CARRY R6, R7
.endm


// 1-way field correction

.section .text

// v0: conventional one

.global fpcorrection_1w_v0

fpcorrection_1w_v0:
  PROLOGUE
  LOAD_P
  LOAD_R
  SUBTRACTION
  GET_SIGN
  MASK_P
  ADD_MASK
  CARRY_PROPAGATION
  STORE_R
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
