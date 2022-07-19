// void gfp_mul_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^64


// registers 

// result "r"
#define R0 a6
#define R1 a7
#define R2 a1 
#define R3 a2
#define R4 s0
#define R5 s1
#define R6 s2
#define R7 s3

// operand "b" 
#define B0 t0 
#define B1 t1
#define B2 t2 
#define B3 t3

// operand "a"
#define A0 t4 
#define A1 t5 
#define A2 t6 
#define A3 a3
#define A4 t0

// temp "t"
#define T0 a4
#define T1 a5

// constants 
#define M0 t1


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -32
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp) 
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

.macro LOAD_A
  ld    A0,  0(a1)
  ld    A1,  8(a1)
  ld    A2, 16(a1)
  ld    A3, 24(a1)
.endm 

.macro LOAD_B
  ld    B0,  0(a2)
  ld    B1,  8(a2)
  ld    B2, 16(a2)
  ld    B3, 24(a2)
.endm 

.macro STORE_R
  sd    R0,  0(a0)
  sd    R1,  8(a0)
  sd    R2, 16(a0)
  sd    R3, 24(a0)
.endm

// integer multiplication (based on product-scanning)

// NOTE that max T1:T0 = 0xFE01 means max T1 = 0xFE, so there is no overflow in 
// `T1 + carry-bit`.  
.macro _ACCU_AIBJ_0 L, M, H
  add   \L, \L, T0
  sltu  T0, \L, T0
  add   T1, T1, T0
  add   \M, \M, T1
  sltu  \H, \M, T1
.endm

.macro _ACCU_AIBJ_1 L, M, H
  add   \L, \L, T0
  sltu  T0, \L, T0
  add   T1, T1, T0
  add   \M, \M, T1
  sltu  T1, \M, T1
  add   \H, \H, T1
.endm

.macro COMPUTE_R0
  mul   R0, A0, B0
  mulhu R1, A0, B0
.endm

.macro COMPUTE_R1 
  mul   T0, A0, B1
  mulhu T1, A0, B1
  add   R1, R1, T0 
  sltu  T0, R1, T0 
  add   R2, T1, T0 
  mul   T0, A1, B0 
  mulhu T1, A1, B0
  _ACCU_AIBJ_0  R1, R2, R3
.endm

.macro COMPUTE_R2
  mul   T0, A0, B2 
  mulhu T1, A0, B2
  _ACCU_AIBJ_0  R2, R3, R4
  mul   T0, A1, B1
  mulhu T1, A1, B1
  _ACCU_AIBJ_1  R2, R3, R4 
  mul   T0, A2, B0
  mulhu T1, A2, B0
  _ACCU_AIBJ_1  R2, R3, R4
.endm 

.macro COMPUTE_R3
  mul   T0, A0, B3
  mulhu T1, A0, B3
  _ACCU_AIBJ_0  R3, R4, R5
  mul   T0, A1, B2
  mulhu T1, A1, B2
  _ACCU_AIBJ_1  R3, R4, R5 
  mul   T0, A2, B1
  mulhu T1, A2, B1
  _ACCU_AIBJ_1  R3, R4, R5
  mul   T0, A3, B0
  mulhu T1, A3, B0
  _ACCU_AIBJ_1  R3, R4, R5
.endm

.macro COMPUTE_R4
  mul   T0, A1, B3
  mulhu T1, A1, B3
  _ACCU_AIBJ_0  R4, R5, R6
  mul   T0, A2, B2
  mulhu T1, A2, B2
  _ACCU_AIBJ_1  R4, R5, R6 
  mul   T0, A3, B1
  mulhu T1, A3, B1
  _ACCU_AIBJ_1  R4, R5, R6 
.endm

.macro COMPUTE_R5
  mul   T0, A2, B3
  mulhu T1, A2, B3
  _ACCU_AIBJ_0  R5, R6, R7
  mul   T0, A3, B2
  mulhu T1, A3, B2
  _ACCU_AIBJ_1  R5, R6, R7
.endm

.macro COMPUTE_R6
  mul   T0, A3, B3
  mulhu T1, A3, B3
  add   R6, R6, T0
  sltu  T0, R6, T0
  add   T1, T1, T0
.endm

.macro COMPUTE_R7
  add   R7, R7, T1
.endm

// reduction A0-A4 = R0-R3 + 38*(R4-R7)

.macro REDUCTION 
  li    M0, 38
  mul   T0, R4, M0
  mulhu T1, R4, M0
  add   A0, R0, T0
  sltu  T0, A0, T0
  add   A1, T1, T0

  mul   T0, R5, M0
  mulhu T1, R5, M0
  add   A1, A1, T0 
  sltu  T0, A1, T0 
  add   A2, T1, T0
  add   A1, A1, R1 
  sltu  T0, A1, R1 
  add   A2, A2, T0
  sltu  A3, A2, T0

  mul   T0, R6, M0 
  mulhu T1, R6, M0 
  add   A2, A2, T0 
  sltu  T0, A2, T0
  add   T1, T0, T1 
  add   A3, A3, T1
  sltu  A4, A3, T1
  add   A2, A2, R2 
  sltu  T0, A2, R2 
  add   A3, A3, T0 
  sltu  T0, A3, T0 
  add   A4, A4, T0

  mul   T0, R7, M0 
  mulhu T1, R7, M0 
  add   A3, A3, T0 
  sltu  T0, A3, T0 
  add   T1, T1, T0 
  add   A4, A4, T1 
  add   A3, A3, R3 
  sltu  T0, A3, R3 
  add   A4, A4, T0 
.endm

// final reduction 

.macro FINAL_REDC
  slli  R3, A3, 1
  srli  R3, R3, 1 
  srli  A3, A3, 63
  slli  A4, A4, 1
  or    A3, A3, A4 
  li    M0, 19
  mul   T0, A3, M0
  add   R0, A0, T0 
  sltu  R1, R0, T0 
  add   R1, R1, A1 
  sltu  R2, R1, A1 
  add   R2, R2, A2 
  sltu  T0, R2, A2 
  add   R3, R3, T0 
.endm


// field multiplication

.section .text

.global gfp_mul_sw

gfp_mul_sw:
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
  REDUCTION
  FINAL_REDC
  STORE_R
  EPILOGUE
