// void uint_mul3_ps_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^64, product-scanning


// registers 

// accumulator "z"
#define Z0 a1
#define Z1 a2
#define Z2 a3

// operand "b"
#define B0 t0 
#define B1 t1
#define B2 t2
#define B3 t3
#define B4 t4
#define B5 t5
#define B6 t6
#define B7 a6

// operand "a"
#define A0 a7
#define A1 s0
#define A2 s1 
#define A3 s2
#define A4 s3
#define A5 s4
#define A6 s5
#define A7 s6

// temp "t"
#define T0 a4
#define T1 a5


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -56
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
  sd    s4, 32(sp)
  sd    s5, 40(sp)
  sd    s6, 48(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  ld    s3, 24(sp)
  ld    s4, 32(sp)
  ld    s5, 40(sp)
  ld    s6, 48(sp)
  addi  sp, sp, 56 
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
  mul   Z0, A0, B0
  mulhu Z1, A0, B0
  sd    Z0,  0(a0)
.endm

.macro COMPUTE_R1
  mul   T0, A0, B1
  mulhu T1, A0, B1
  add   Z1, Z1, T0
  sltu  T0, Z1, T0
  add   Z2, T1, T0
  mul   T0, A1, B0
  mulhu T1, A1, B0
  _ACCU_AIBJ_0  Z1, Z2, Z0
  sd    Z1,  8(a0)
.endm

.macro COMPUTE_R2
  mul   T0, A0, B2
  mulhu T1, A0, B2
  _ACCU_AIBJ_0  Z2, Z0, Z1
  mul   T0, A1, B1
  mulhu T1, A1, B1
  _ACCU_AIBJ_1  Z2, Z0, Z1 
  mul   T0, A2, B0
  mulhu T1, A2, B0
  _ACCU_AIBJ_1  Z2, Z0, Z1
  sd    Z2, 16(a0) 
.endm

.macro COMPUTE_R3
  mul   T0, A0, B3
  mulhu T1, A0, B3
  _ACCU_AIBJ_0  Z0, Z1, Z2
  mul   T0, A1, B2
  mulhu T1, A1, B2
  _ACCU_AIBJ_1  Z0, Z1, Z2 
  mul   T0, A2, B1
  mulhu T1, A2, B1
  _ACCU_AIBJ_1  Z0, Z1, Z2
  mul   T0, A3, B0
  mulhu T1, A3, B0
  _ACCU_AIBJ_1  Z0, Z1, Z2
  sd    Z0, 24(a0) 
.endm

.macro COMPUTE_R4
  mul   T0, A0, B4
  mulhu T1, A0, B4
  _ACCU_AIBJ_0  Z1, Z2, Z0
  mul   T0, A1, B3
  mulhu T1, A1, B3
  _ACCU_AIBJ_1  Z1, Z2, Z0 
  mul   T0, A2, B2
  mulhu T1, A2, B2
  _ACCU_AIBJ_1  Z1, Z2, Z0
  mul   T0, A3, B1
  mulhu T1, A3, B1
  _ACCU_AIBJ_1  Z1, Z2, Z0
  mul   T0, A4, B0
  mulhu T1, A4, B0
  _ACCU_AIBJ_1  Z1, Z2, Z0
  sd    Z1, 32(a0)   
.endm

.macro COMPUTE_R5
  mul   T0, A0, B5
  mulhu T1, A0, B5
  _ACCU_AIBJ_0  Z2, Z0, Z1
  mul   T0, A1, B4
  mulhu T1, A1, B4
  _ACCU_AIBJ_1  Z2, Z0, Z1 
  mul   T0, A2, B3
  mulhu T1, A2, B3
  _ACCU_AIBJ_1  Z2, Z0, Z1
  mul   T0, A3, B2
  mulhu T1, A3, B2
  _ACCU_AIBJ_1  Z2, Z0, Z1
  mul   T0, A4, B1
  mulhu T1, A4, B1
  _ACCU_AIBJ_1  Z2, Z0, Z1
  mul   T0, A5, B0
  mulhu T1, A5, B0
  _ACCU_AIBJ_1  Z2, Z0, Z1
  sd    Z2, 40(a0)   
.endm

.macro COMPUTE_R6
  mul   T0, A0, B6
  mulhu T1, A0, B6
  _ACCU_AIBJ_0  Z0, Z1, Z2
  mul   T0, A1, B5
  mulhu T1, A1, B5
  _ACCU_AIBJ_1  Z0, Z1, Z2 
  mul   T0, A2, B4
  mulhu T1, A2, B4
  _ACCU_AIBJ_1  Z0, Z1, Z2
  mul   T0, A3, B3
  mulhu T1, A3, B3
  _ACCU_AIBJ_1  Z0, Z1, Z2
  mul   T0, A4, B2
  mulhu T1, A4, B2
  _ACCU_AIBJ_1  Z0, Z1, Z2
  mul   T0, A5, B1
  mulhu T1, A5, B1
  _ACCU_AIBJ_1  Z0, Z1, Z2
  mul   T0, A6, B0
  mulhu T1, A6, B0
  _ACCU_AIBJ_1  Z0, Z1, Z2
  sd    Z0, 48(a0)   
.endm

.macro COMPUTE_R7
  mul   T0, A0, B7
  mulhu T1, A0, B7
  _ACCU_AIBJ_0  Z1, Z2, Z0
  mul   T0, A1, B6
  mulhu T1, A1, B6
  _ACCU_AIBJ_1  Z1, Z2, Z0
  mul   T0, A2, B5
  mulhu T1, A2, B5
  _ACCU_AIBJ_1  Z1, Z2, Z0
  mul   T0, A3, B4
  mulhu T1, A3, B4
  _ACCU_AIBJ_1  Z1, Z2, Z0
  mul   T0, A4, B3
  mulhu T1, A4, B3
  _ACCU_AIBJ_1  Z1, Z2, Z0
  mul   T0, A5, B2
  mulhu T1, A5, B2
  _ACCU_AIBJ_1  Z1, Z2, Z0
  mul   T0, A6, B1
  mulhu T1, A6, B1
  _ACCU_AIBJ_1  Z1, Z2, Z0
  mul   T0, A7, B0
  mulhu T1, A7, B0
  _ACCU_AIBJ_1  Z1, Z2, Z0
  sd    Z1, 56(a0)   
.endm

.macro COMPUTE_R8
  mul   T0, A1, B7
  mulhu T1, A1, B7
  _ACCU_AIBJ_0  Z2, Z0, Z1
  mul   T0, A2, B6
  mulhu T1, A2, B6
  _ACCU_AIBJ_1  Z2, Z0, Z1
  mul   T0, A3, B5
  mulhu T1, A3, B5
  _ACCU_AIBJ_1  Z2, Z0, Z1
  mul   T0, A4, B4
  mulhu T1, A4, B4
  _ACCU_AIBJ_1  Z2, Z0, Z1
  mul   T0, A5, B3
  mulhu T1, A5, B3
  _ACCU_AIBJ_1  Z2, Z0, Z1
  mul   T0, A6, B2
  mulhu T1, A6, B2
  _ACCU_AIBJ_1  Z2, Z0, Z1
  mul   T0, A7, B1
  mulhu T1, A7, B1
  _ACCU_AIBJ_1  Z2, Z0, Z1
  sd    Z2, 64(a0)
.endm

.macro COMPUTE_R9
  mul   T0, A2, B7
  mulhu T1, A2, B7
  _ACCU_AIBJ_0  Z0, Z1, Z2
  mul   T0, A3, B6
  mulhu T1, A3, B6
  _ACCU_AIBJ_1  Z0, Z1, Z2
  mul   T0, A4, B5
  mulhu T1, A4, B5
  _ACCU_AIBJ_1  Z0, Z1, Z2
  mul   T0, A5, B4
  mulhu T1, A5, B4
  _ACCU_AIBJ_1  Z0, Z1, Z2
  mul   T0, A6, B3
  mulhu T1, A6, B3
  _ACCU_AIBJ_1  Z0, Z1, Z2
  mul   T0, A7, B2
  mulhu T1, A7, B2
  _ACCU_AIBJ_1  Z0, Z1, Z2
  sd    Z0, 72(a0)
.endm

.macro COMPUTE_R10
  mul   T0, A3, B7
  mulhu T1, A3, B7
  _ACCU_AIBJ_0  Z1, Z2, Z0
  mul   T0, A4, B6
  mulhu T1, A4, B6
  _ACCU_AIBJ_1  Z1, Z2, Z0
  mul   T0, A5, B5
  mulhu T1, A5, B5
  _ACCU_AIBJ_1  Z1, Z2, Z0
  mul   T0, A6, B4
  mulhu T1, A6, B4
  _ACCU_AIBJ_1  Z1, Z2, Z0
  mul   T0, A7, B3
  mulhu T1, A7, B3
  _ACCU_AIBJ_1  Z1, Z2, Z0
  sd    Z1, 80(a0)
.endm

.macro COMPUTE_R11
  mul   T0, A4, B7
  mulhu T1, A4, B7
  _ACCU_AIBJ_0  Z2, Z0, Z1
  mul   T0, A5, B6
  mulhu T1, A5, B6
  _ACCU_AIBJ_1  Z2, Z0, Z1
  mul   T0, A6, B5
  mulhu T1, A6, B5
  _ACCU_AIBJ_1  Z2, Z0, Z1
  mul   T0, A7, B4
  mulhu T1, A7, B4
  _ACCU_AIBJ_1  Z2, Z0, Z1
  sd    Z2, 88(a0)
.endm

.macro COMPUTE_R12
  mul   T0, A5, B7
  mulhu T1, A5, B7
  _ACCU_AIBJ_0  Z0, Z1, Z2
  mul   T0, A6, B6
  mulhu T1, A6, B6
  _ACCU_AIBJ_1  Z0, Z1, Z2
  mul   T0, A7, B5
  mulhu T1, A7, B5
  _ACCU_AIBJ_1  Z0, Z1, Z2
  sd    Z0, 96(a0)
.endm

.macro COMPUTE_R13
  mul   T0, A6, B7
  mulhu T1, A6, B7
  _ACCU_AIBJ_0  Z1, Z2, Z0
  mul   T0, A7, B6
  mulhu T1, A7, B6
  _ACCU_AIBJ_1  Z1, Z2, Z0
  sd    Z1,104(a0)
.endm

.macro COMPUTE_R14
  mul   T0, A7, B7
  mulhu T1, A7, B7
  add   Z2, Z2, T0
  sltu  T0, Z2, T0
  add   T1, T1, T0
  add   Z0, Z0, T1
  sd    Z2,112(a0)
.endm

.macro COMPUTE_R15
  sd    Z0,120(a0) 
.endm


.section .text

.global uint_mul3_ps_sw

uint_mul3_ps_sw:
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
