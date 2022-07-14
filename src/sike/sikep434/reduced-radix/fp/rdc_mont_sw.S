// void rdc_mont_v0_sw(uint64_t *r, const uint64_t *a);
// radix-2^56, product-scanning


// registers

// accumulator "z"
#define ZL t0
#define ZH t1

// result "r"
#define R_ t2

// modulus "p+1"
#define P3 t3
#define P4 t4
#define P5 t5
#define P6 t6
#define P7 a7

// operand "a"
#define A0 s0
#define A1 s1
#define A2 s2 
#define A3 s3
#define A4 s4
#define A5 s5
#define A6 a2
#define A7 a3

// temp "t"
#define TL a4
#define TH a5

// constants and masks
#define M0 a6


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -48
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
  sd    s4, 32(sp)
  sd    s5, 40(sp)
  li    M0, 0xFFFFFFFFFFFFFFULL
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

// load operand

.macro LOAD_A
  ld    A0,  0(a1)
  ld    A1,  8(a1)
  ld    A2, 16(a1)
  ld    A3, 24(a1)
  ld    A4, 32(a1)
  ld    A5, 40(a1)
  ld    A6, 48(a1)
  ld    A7, 56(a1)
.endm 

.macro LOAD_P
  la    a4, P434P1
  ld    P3,  0(a4)
  ld    P4,  8(a4)
  ld    P5, 16(a4)
  ld    P6, 24(a4)
  ld    P7, 32(a4)
.endm

// pre carry propagation

.macro PRE_PROPAGATION
  srai  TL, A0, 56
  add   A1, A1, TL
  and   A0, A0, M0
  srai  TL, A1, 56
  add   A2, A2, TL
  and   A1, A1, M0
  srai  TL, A2, 56
  add   A3, A3, TL
  and   A2, A2, M0
.endm

// first loop of Montgomery reduction (based on product-scanning)

.macro _PROPAGATE_CARRY
  srli  ZL, ZL, 56
  slli  TL, ZH,  8
  xor   ZL, ZL, TL
  srai  ZH, ZH, 56
.endm 

.macro _ACCUMULATE_AIPJ
  add   ZL, ZL, TL
  sltu  TL, ZL, TL
  add   ZH, ZH, TH
  add   ZH, ZH, TL
.endm

// NOTE: "A" can < 0. When "A" >= 0, then TH = 0; if there is a carry-out, 
// TL = 1, the carry bit is 0+1 = 1; if there is not a carry-out, TL = 0, 
// the carry bit is 0+0 = 0. When "A" < 0, then TH = -1; if there is a borrow-
// out, TL = 0, the carry bit is 0-1 = -1; if there is not a borrow-out, TL = 1, 
// the carry bit is 1-1 = 0. 
.macro _ACCUMULATE_A A
  add   ZL, ZL, \A
  srai  TH, \A, 63
  sltu  TL, ZL, \A
  add   TL, TL, TH
  add   ZH, ZH, TL
.endm

.macro COMPUTE_A3
  mul   ZL, A0, P3
  mulhu ZH, A0, P3
  _ACCUMULATE_A A3
  and   A3, ZL, M0
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_A4
  _ACCUMULATE_A A4
  mul   TL, A0, P4
  mulhu TH, A0, P4
  _ACCUMULATE_AIPJ
  mul   TL, A1, P3
  mulhu TH, A1, P3
  _ACCUMULATE_AIPJ
  and   A4, ZL, M0
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_A5
  _ACCUMULATE_A A5
  mul   TL, A0, P5
  mulhu TH, A0, P5
  _ACCUMULATE_AIPJ
  mul   TL, A1, P4
  mulhu TH, A1, P4
  _ACCUMULATE_AIPJ
  mul   TL, A2, P3
  mulhu TH, A2, P3
  _ACCUMULATE_AIPJ
  and   A5, ZL, M0
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_A6
  _ACCUMULATE_A A6
  mul   TL, A0, P6
  mulhu TH, A0, P6
  _ACCUMULATE_AIPJ
  mul   TL, A1, P5
  mulhu TH, A1, P5
  _ACCUMULATE_AIPJ
  mul   TL, A2, P4
  mulhu TH, A2, P4
  _ACCUMULATE_AIPJ
  mul   TL, A3, P3
  mulhu TH, A3, P3
  _ACCUMULATE_AIPJ
  and   A6, ZL, M0
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_A7
  _ACCUMULATE_A A7
  mul   TL, A0, P7
  mulhu TH, A0, P7
  _ACCUMULATE_AIPJ
  mul   TL, A1, P6
  mulhu TH, A1, P6
  _ACCUMULATE_AIPJ
  mul   TL, A2, P5
  mulhu TH, A2, P5
  _ACCUMULATE_AIPJ
  mul   TL, A3, P4
  mulhu TH, A3, P4
  _ACCUMULATE_AIPJ
  mul   TL, A4, P3
  mulhu TH, A4, P3
  _ACCUMULATE_AIPJ
  and   A7, ZL, M0
  _PROPAGATE_CARRY
.endm

// second loop of Montgomery reduction (based on product-scanning) 

.macro COMPUTE_R0
  ld    R_, 64(a1)
  _ACCUMULATE_A R_
  mul   TL, A1, P7
  mulhu TH, A1, P7
  _ACCUMULATE_AIPJ
  mul   TL, A2, P6
  mulhu TH, A2, P6
  _ACCUMULATE_AIPJ
  mul   TL, A3, P5
  mulhu TH, A3, P5
  _ACCUMULATE_AIPJ
  mul   TL, A4, P4
  mulhu TH, A4, P4
  _ACCUMULATE_AIPJ
  mul   TL, A5, P3
  mulhu TH, A5, P3
  _ACCUMULATE_AIPJ
  and   R_, ZL, M0
  sd    R_,  0(a0)
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_R1
  ld    R_, 72(a1)
  _ACCUMULATE_A R_
  mul   TL, A2, P7
  mulhu TH, A2, P7
  _ACCUMULATE_AIPJ
  mul   TL, A3, P6
  mulhu TH, A3, P6
  _ACCUMULATE_AIPJ
  mul   TL, A4, P5
  mulhu TH, A4, P5
  _ACCUMULATE_AIPJ
  mul   TL, A5, P4
  mulhu TH, A5, P4
  _ACCUMULATE_AIPJ
  mul   TL, A6, P3
  mulhu TH, A6, P3
  _ACCUMULATE_AIPJ
  and   R_, ZL, M0
  sd    R_,  8(a0)
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_R2
  ld    R_, 80(a1)
  _ACCUMULATE_A R_
  mul   TL, A3, P7
  mulhu TH, A3, P7
  _ACCUMULATE_AIPJ
  mul   TL, A4, P6
  mulhu TH, A4, P6
  _ACCUMULATE_AIPJ
  mul   TL, A5, P5
  mulhu TH, A5, P5
  _ACCUMULATE_AIPJ
  mul   TL, A6, P4
  mulhu TH, A6, P4
  _ACCUMULATE_AIPJ
  mul   TL, A7, P3
  mulhu TH, A7, P3
  _ACCUMULATE_AIPJ
  and   R_, ZL, M0
  sd    R_, 16(a0)
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_R3
  ld    R_, 88(a1)
  _ACCUMULATE_A R_
  mul   TL, A4, P7
  mulhu TH, A4, P7
  _ACCUMULATE_AIPJ
  mul   TL, A5, P6
  mulhu TH, A5, P6
  _ACCUMULATE_AIPJ
  mul   TL, A6, P5
  mulhu TH, A6, P5
  _ACCUMULATE_AIPJ
  mul   TL, A7, P4
  mulhu TH, A7, P4
  _ACCUMULATE_AIPJ
  and   R_, ZL, M0
  sd    R_, 24(a0)
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_R4
  ld    R_, 96(a1)
  _ACCUMULATE_A R_
  mul   TL, A5, P7
  mulhu TH, A5, P7
  _ACCUMULATE_AIPJ
  mul   TL, A6, P6
  mulhu TH, A6, P6
  _ACCUMULATE_AIPJ
  mul   TL, A7, P5
  mulhu TH, A7, P5
  _ACCUMULATE_AIPJ
  and   R_, ZL, M0
  sd    R_, 32(a0)
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_R5
  ld    R_,104(a1)
  _ACCUMULATE_A R_
  mul   TL, A6, P7
  mulhu TH, A6, P7
  _ACCUMULATE_AIPJ
  mul   TL, A7, P6
  mulhu TH, A7, P6
  _ACCUMULATE_AIPJ
  and   R_, ZL, M0
  sd    R_, 40(a0)
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_R6
  ld    R_,112(a1)
  _ACCUMULATE_A R_
  mul   TL, A7, P7
  mulhu TH, A7, P7
  _ACCUMULATE_AIPJ
  and   R_, ZL, M0
  sd    R_, 48(a0)
  srli  ZL, ZL, 56
  slli  TL, ZH,  8
  xor   ZL, ZL, TL
.endm

.macro COMPUTE_R7
  ld    R_,120(a1)
  add   R_, ZL, R_
  sd    R_, 56(a0)
.endm


// Montgomery reduction 

.section .text

// v0: conventional product-scanning

.global rdc_mont_v0_sw

rdc_mont_v0_sw:
  PROLOGUE
  LOAD_A
  LOAD_P
  PRE_PROPAGATION
  COMPUTE_A3
  COMPUTE_A4
  COMPUTE_A5
  COMPUTE_A6
  COMPUTE_A7
  COMPUTE_R0
  COMPUTE_R1
  COMPUTE_R2
  COMPUTE_R3
  COMPUTE_R4
  COMPUTE_R5
  COMPUTE_R6
  COMPUTE_R7
  EPILOGUE


.section .data 

.balign 8 

P434P1:
.dword 0xE3000000000000                 // P3
.dword 0x58AEA3FDC1767A                 // P4
.dword 0x20567BC65C7831                 // P5
.dword 0x446CFC5FD681C5                 // P6
.dword 0x0002341F271773                 // P7

