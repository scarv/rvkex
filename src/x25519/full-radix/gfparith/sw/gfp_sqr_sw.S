// void gfp_sqr_sw(uint64_t *r, const uint64_t *a);
// radix-2^64


// registers 

// result "r"
#define R0 s0
#define R1 a1
#define R2 a2
#define R3 a3
#define R4 a4
#define R5 a5
#define R6 a6
#define R7 a7

// operand "a"
#define A0 t0 
#define A1 t1
#define A2 t2 
#define A3 t3 
#define A4 s1

// temp "t"
#define T0 t4
#define T1 t5
#define T2 s2
#define T3 t6
#define T4 s1 

// constants 
#define M0 t6


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -24
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  addi  sp, sp, 24
  ret 
.endm

// load operand + store result 

.macro LOAD_A
  ld    A0,  0(a1)
  ld    A1,  8(a1)
  ld    A2, 16(a1)
  ld    A3, 24(a1)
.endm 

.macro STORE_R
  sd    R0,  0(a0)
  sd    R1,  8(a0)
  sd    R2, 16(a0)
  sd    R3, 24(a0)
.endm

// integer squaring (based on product-scanning)

.macro _ACCU_AIAJ  L, M, H
  add   \L, \L, T0
  sltu  T0, \L, T0
  add   T1, T1, T0
  add   \M, \M, T1
  sltu  T1, \M, T1
  add   \H, \H, T1
.endm

.macro COMPUTE_R0
  mul   R0, A0, A0
  mulhu R1, A0, A0
.endm

.macro COMPUTE_R1
  mul   T0, A0, A1
  mulhu T1, A0, A1

  srli  T3, T0, 63 
  slli  T0, T0,  1
  srli  T2, T1, 63
  slli  T1, T1,  1
  or    T1, T1, T3

  add   R1, R1, T0 
  sltu  R2, R1, T0
  add   R2, R2, T1 
  sltu  R3, R2, T1 
  add   R3, R3, T2 
.endm

.macro COMPUTE_R2 
  mul   T0, A0, A2 
  mulhu T1, A0, A2

  srli  T3, T0, 63 
  slli  T0, T0,  1
  srli  T2, T1, 63
  slli  T1, T1,  1
  or    T1, T1, T3

  add   R2, R2, T0 
  sltu  T0, R2, T0

  add   R3, R3, T0 
  sltu  T0, R3, T0 
  add   R3, R3, T1 
  sltu  T1, R3, T1 
  or    R4, T0, T1
  
  add   R4, R4, T2
  mul   T0, A1, A1
  mulhu T1, A1, A1
  _ACCU_AIAJ    R2, R3, R4
.endm

.macro COMPUTE_R3 
  mul   T0, A0, A3 
  mulhu T1, A0, A3
  mul   T2, A1, A2 
  mulhu T3, A1, A2

  add   T0, T0, T2 
  sltu  T2, T0, T2 
  add   T1, T1, T2 
  add   T1, T1, T3 
  sltu  T2, T1, T3

  srli  T3, T0, 63 
  slli  T0, T0,  1
  srli  T4, T1, 63
  slli  T1, T1,  1
  or    T1, T1, T3
  slli  T2, T2,  1
  add   T2, T2, T4

  add   R3, R3, T0
  sltu  T0, R3, T0 
  add   R4, R4, T0
  sltu  T0, R4, T0 
  add   R4, R4, T1 
  sltu  T1, R4, T1 
  or    R5, T0, T1 
  add   R5, R5, T2 
.endm  

.macro COMPUTE_R4 
  mul   T0, A1, A3 
  mulhu T1, A1, A3

  srli  T3, T0, 63 
  slli  T0, T0,  1
  srli  T2, T1, 63
  slli  T1, T1,  1
  or    T1, T1, T3

  add   R4, R4, T0 
  sltu  T0, R4, T0
  add   R5, R5, T0 
  sltu  T0, R5, T0 
  add   R5, R5, T1 
  sltu  T1, R5, T1 
  or    R6, T0, T1 
  add   R6, R6, T2

  mul   T0, A2, A2
  mulhu T1, A2, A2
  _ACCU_AIAJ    R4, R5, R6
.endm

.macro COMPUTE_R5 
  mul   T0, A2, A3 
  mulhu T1, A2, A3

  srli  T3, T0, 63 
  slli  T0, T0,  1
  srli  T2, T1, 63
  slli  T1, T1,  1
  or    T1, T1, T3

  add   R5, R5, T0 
  sltu  T0, R5, T0 
  add   R6, R6, T0 
  sltu  T0, R6, T0 
  add   R6, R6, T1
  sltu  T1, R6, T1 
  or    R7, T1, T0
  add   R7, R7, T2 
.endm

.macro COMPUTE_R6
  mul   T0, A3, A3
  mulhu T1, A3, A3
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

  mul   T0, R6, M0 
  mulhu T1, R6, M0 
  add   A2, A2, T0 
  sltu  T0, A2, T0
  add   A3, T0, T1
  add   A2, A2, R2 
  sltu  T0, A2, R2 
  add   A3, A3, T0 

  mul   T0, R7, M0 
  mulhu T1, R7, M0 
  add   A3, A3, T0 
  sltu  T0, A3, T0 
  add   A4, T0, T1
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


// field squaring

.section .text

.global gfp_sqr_sw

gfp_sqr_sw:
  PROLOGUE
  LOAD_A
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