// void gfp_add_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^64


// registers 

// result `r`
#define R0 a3
#define R1 a4
#define R2 a5 
#define R3 a6
#define R4 t3

// operand `b` 
#define B0 t0 
#define B1 t1
#define B2 t2
#define B3 t3

// operand `a`
#define A0 t4 
#define A1 t5 
#define A2 t6 
#define A3 a7

// temporary value `t`
#define T0 t0
#define T1 t1
#define T2 t4

// constant `m`
#define M0 t2


// prologue + epilogue 

.macro PROLOGUE
.endm

.macro EPILOGUE
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

// integer addition

.macro ADDITION 
  add   R0, A0, T0 
  sltu  T0, R0, A0

  add   R1, A1, T0 
  sltu  T0, R1, T0 
  add   R1, R1, B1 
  sltu  T1, R1, B1 
  or    T0, T0, T1 

  add   R2, A2, T0 
  sltu  T0, R2, T0 
  add   R2, R2, B2 
  sltu  T1, R2, B2 
  or    T0, T0, T1  

  add   R3, A3, T0 
  sltu  T0, R3, T0 
  add   R3, R3, B3 
  sltu  T1, R3, B3 
  or    R4, T0, T1 
.endm

// final reduction 

.macro FINAL_REDC
  srli  T2, R3, 63
  slli  R3, R3, 1 
  srli  R3, R3, 1
  slli  T1, T1, 1
  or    T2, T1, T2 
  li    M0, 19 
  mul   T0, T2, M0 
  add   R0, R0, T0 
  sltu  T0, R0, T0 
  add   R1, R1, T0 
  sltu  T0, R1, T0 
  add   R2, R2, T0 
  sltu  T0, R2, T0
  add   R3, R3, T0 
.endm

// field addition 

.section .text

.global gfp_add_sw

gfp_add_sw:
  PROLOGUE
  LOAD_A
  LOAD_B
  ADDITION
  FINAL_REDC
  STORE_R
  EPILOGUE
