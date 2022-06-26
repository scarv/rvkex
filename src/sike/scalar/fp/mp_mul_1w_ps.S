// void mp_mul_1w_v0(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-51, product-scanning
// no carry propagation since it will be done in Montgomery reduction


// meaningful names for registers

// accumulator "z"
#define ZL a1
#define ZH a2

// result "r"
#define R_ a3 

// operand "b" 
#define B0 t0 
#define B1 t1
#define B2 t2
#define B3 t3
#define B4 t4
#define B5 t5
#define B6 t6
#define B7 a7

// operand "a"
#define A0 s0 
#define A1 s1
#define A2 s2 
#define A3 s3
#define A4 s4
#define A5 s5
#define A6 s6
#define A7 s7 

// temp "t"
#define TL a4
#define TH a5

// constants and masks
#define M0 a6


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
  li    M0, 0xFFFFFFFFFFFFFFULL
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

.macro LOAD_B
  ld    B0,  0(a2)
  ld    B1,  8(a2)
  ld    B2, 16(a2)
  ld    B3, 24(a2)
  ld    B4, 32(a2)
  ld    B5, 40(a2)
  ld    B6, 48(a2)
  ld    B7, 56(a2)
.endm 

// integer multiplication (based on product-scanning)

.macro _PROPAGATE_CARRY
  srli  ZL, ZL, 56
  slli  R_, ZH,  8
  xor   ZL, ZL, R_
  srli  ZH, ZH, 56
.endm 

.macro _ACCUMULATE_AIBJ
  add   ZL, ZL, TL
  sltu  TL, ZL, TL
  add   ZH, ZH, TH
  add   ZH, ZH, TL
.endm

.macro COMPUTE_R0
  mul   ZL, A0, B0
  mulhu ZH, A0, B0
  and   R_, ZL, M0
  sd    R_,  0(a0)
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_R1
  mul   TL, A0, B1
  mulhu TH, A0, B1
  _ACCUMULATE_AIBJ
  mul   TL, A1, B0
  mulhu TH, A1, B0
  _ACCUMULATE_AIBJ
  and   R_, ZL, M0
  sd    R_,  8(a0)
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_R2
  mul   TL, A0, B2
  mulhu TH, A0, B2
  _ACCUMULATE_AIBJ
  mul   TL, A1, B1
  mulhu TH, A1, B1
  _ACCUMULATE_AIBJ
  mul   TL, A2, B0
  mulhu TH, A2, B0
  _ACCUMULATE_AIBJ
  and   R_, ZL, M0
  sd    R_, 16(a0)
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_R3
  mul   TL, A0, B3
  mulhu TH, A0, B3
  _ACCUMULATE_AIBJ
  mul   TL, A1, B2
  mulhu TH, A1, B2
  _ACCUMULATE_AIBJ
  mul   TL, A2, B1
  mulhu TH, A2, B1
  _ACCUMULATE_AIBJ
  mul   TL, A3, B0
  mulhu TH, A3, B0
  _ACCUMULATE_AIBJ
  and   R_, ZL, M0
  sd    R_, 24(a0)
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_R4
  mul   TL, A0, B4
  mulhu TH, A0, B4
  _ACCUMULATE_AIBJ
  mul   TL, A1, B3
  mulhu TH, A1, B3
  _ACCUMULATE_AIBJ
  mul   TL, A2, B2
  mulhu TH, A2, B2
  _ACCUMULATE_AIBJ
  mul   TL, A3, B1
  mulhu TH, A3, B1
  _ACCUMULATE_AIBJ
  mul   TL, A4, B0
  mulhu TH, A4, B0
  _ACCUMULATE_AIBJ
  and   R_, ZL, M0
  sd    R_, 32(a0)
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_R5
  mul   TL, A0, B5
  mulhu TH, A0, B5
  _ACCUMULATE_AIBJ
  mul   TL, A1, B4
  mulhu TH, A1, B4
  _ACCUMULATE_AIBJ
  mul   TL, A2, B3
  mulhu TH, A2, B3
  _ACCUMULATE_AIBJ
  mul   TL, A3, B2
  mulhu TH, A3, B2
  _ACCUMULATE_AIBJ
  mul   TL, A4, B1
  mulhu TH, A4, B1
  _ACCUMULATE_AIBJ
  mul   TL, A5, B0
  mulhu TH, A5, B0
  _ACCUMULATE_AIBJ
  and   R_, ZL, M0
  sd    R_, 40(a0)
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_R6
  mul   TL, A0, B6
  mulhu TH, A0, B6
  _ACCUMULATE_AIBJ
  mul   TL, A1, B5
  mulhu TH, A1, B5
  _ACCUMULATE_AIBJ
  mul   TL, A2, B4
  mulhu TH, A2, B4
  _ACCUMULATE_AIBJ
  mul   TL, A3, B3
  mulhu TH, A3, B3
  _ACCUMULATE_AIBJ
  mul   TL, A4, B2
  mulhu TH, A4, B2
  _ACCUMULATE_AIBJ
  mul   TL, A5, B1
  mulhu TH, A5, B1
  _ACCUMULATE_AIBJ
  mul   TL, A6, B0
  mulhu TH, A6, B0
  _ACCUMULATE_AIBJ
  and   R_, ZL, M0
  sd    R_, 48(a0)
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_R7
  mul   TL, A0, B7
  mulhu TH, A0, B7
  _ACCUMULATE_AIBJ
  mul   TL, A1, B6
  mulhu TH, A1, B6
  _ACCUMULATE_AIBJ
  mul   TL, A2, B5
  mulhu TH, A2, B5
  _ACCUMULATE_AIBJ
  mul   TL, A3, B4
  mulhu TH, A3, B4
  _ACCUMULATE_AIBJ
  mul   TL, A4, B3
  mulhu TH, A4, B3
  _ACCUMULATE_AIBJ
  mul   TL, A5, B2
  mulhu TH, A5, B2
  _ACCUMULATE_AIBJ
  mul   TL, A6, B1
  mulhu TH, A6, B1
  _ACCUMULATE_AIBJ
  mul   TL, A7, B0
  mulhu TH, A7, B0
  _ACCUMULATE_AIBJ
  and   R_, ZL, M0
  sd    R_, 56(a0)
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_R8
  mul   TL, A1, B7
  mulhu TH, A1, B7
  _ACCUMULATE_AIBJ
  mul   TL, A2, B6
  mulhu TH, A2, B6
  _ACCUMULATE_AIBJ
  mul   TL, A3, B5
  mulhu TH, A3, B5
  _ACCUMULATE_AIBJ
  mul   TL, A4, B4
  mulhu TH, A4, B4
  _ACCUMULATE_AIBJ
  mul   TL, A5, B3
  mulhu TH, A5, B3
  _ACCUMULATE_AIBJ
  mul   TL, A6, B2
  mulhu TH, A6, B2
  _ACCUMULATE_AIBJ
  mul   TL, A7, B1
  mulhu TH, A7, B1
  _ACCUMULATE_AIBJ
  and   R_, ZL, M0
  sd    R_, 64(a0)
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_R9
  mul   TL, A2, B7
  mulhu TH, A2, B7
  _ACCUMULATE_AIBJ
  mul   TL, A3, B6
  mulhu TH, A3, B6
  _ACCUMULATE_AIBJ
  mul   TL, A4, B5
  mulhu TH, A4, B5
  _ACCUMULATE_AIBJ
  mul   TL, A5, B4
  mulhu TH, A5, B4
  _ACCUMULATE_AIBJ
  mul   TL, A6, B3
  mulhu TH, A6, B3
  _ACCUMULATE_AIBJ
  mul   TL, A7, B2
  mulhu TH, A7, B2
  _ACCUMULATE_AIBJ
  and   R_, ZL, M0
  sd    R_, 72(a0)
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_R10
  mul   TL, A3, B7
  mulhu TH, A3, B7
  _ACCUMULATE_AIBJ
  mul   TL, A4, B6
  mulhu TH, A4, B6
  _ACCUMULATE_AIBJ
  mul   TL, A5, B5
  mulhu TH, A5, B5
  _ACCUMULATE_AIBJ
  mul   TL, A6, B4
  mulhu TH, A6, B4
  _ACCUMULATE_AIBJ
  mul   TL, A7, B3
  mulhu TH, A7, B3
  _ACCUMULATE_AIBJ
  and   R_, ZL, M0
  sd    R_, 80(a0)
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_R11
  mul   TL, A4, B7
  mulhu TH, A4, B7
  _ACCUMULATE_AIBJ
  mul   TL, A5, B6
  mulhu TH, A5, B6
  _ACCUMULATE_AIBJ
  mul   TL, A6, B5
  mulhu TH, A6, B5
  _ACCUMULATE_AIBJ
  mul   TL, A7, B4
  mulhu TH, A7, B4
  _ACCUMULATE_AIBJ
  and   R_, ZL, M0
  sd    R_, 88(a0)
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_R12
  mul   TL, A5, B7
  mulhu TH, A5, B7
  _ACCUMULATE_AIBJ
  mul   TL, A6, B6
  mulhu TH, A6, B6
  _ACCUMULATE_AIBJ
  mul   TL, A7, B5
  mulhu TH, A7, B5
  _ACCUMULATE_AIBJ
  and   R_, ZL, M0
  sd    R_, 96(a0)
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_R13
  mul   TL, A6, B7
  mulhu TH, A6, B7
  _ACCUMULATE_AIBJ
  mul   TL, A7, B6
  mulhu TH, A7, B6
  _ACCUMULATE_AIBJ
  and   R_, ZL, M0
  sd    R_,104(a0)
  _PROPAGATE_CARRY
.endm

.macro COMPUTE_R14
  mul   TL, A7, B7
  mulhu TH, A7, B7
  _ACCUMULATE_AIBJ
  and   R_, ZL, M0
  sd    R_,112(a0)
.endm

.macro COMPUTE_R15
  srli  ZL, ZL, 56
  slli  R_, ZH,  8
  xor   R_, ZL, R_
  sd    R_,120(a0)
.endm


// 1-way integer multiplication 

.section .text

// v0: conventional product-scanning

.global mp_mul_1w_v0

mp_mul_1w_v0:
  PROLOGUE
  LOAD_A
  LOAD_B
  COMPUTE_R0
  COMPUTE_R1
  COMPUTE_R2
  COMPUTE_R3
  COMPUTE_R4
  COMPUTE_R5
  COMPUTE_R6
  COMPUTE_R7
  COMPUTE_R8
  COMPUTE_R9
  COMPUTE_R10
  COMPUTE_R11
  COMPUTE_R12
  COMPUTE_R13
  COMPUTE_R14
  COMPUTE_R15
  EPILOGUE
