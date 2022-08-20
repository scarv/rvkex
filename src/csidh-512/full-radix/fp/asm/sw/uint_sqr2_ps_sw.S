// void uint_sqr2_ps_sw(uint64_t *r, const uint64_t *a);
// radix-2^64, product-scanning


// registers 

// accumulator `z`
#define Z0 a1
#define Z1 a2
#define Z2 a3

// partial product `y`
#define Y0 a7
#define Y1 s0
#define Y2 s1

// operand `b`
#define A0 t0 
#define A1 t1
#define A2 t2
#define A3 t3
#define A4 t4
#define A5 t5
#define A6 t6
#define A7 a6

// temporary value `t`
#define T0 a4
#define T1 a5


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -16
  sd    s0,  0(sp)
  sd    s1,  8(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  addi  sp, sp, 16 
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

// integer squaring (based on product-scanning)

// NOTE that max T1:T0 = 0xFE01 means max T1 = 0xFE, so there is no carry-out in 
// `T1 + carry-in`.

// L != 0, M = 0, H = 0
.macro _ACCU_AIBJ_0 L, M, H 
  add   \L, \L, T0 
  sltu  T0, \L, T0
  add   \M, T1, T0
.endm 

// L != 0, M != 0, H = 0
.macro _ACCU_AIBJ_1 L, M, H
  add   \L, \L, T0
  sltu  T0, \L, T0
  add   T1, T1, T0
  add   \M, \M, T1
  sltu  \H, \M, T1
.endm

// L != 0, M != 0, H != 0
.macro _ACCU_AIBJ_2 L, M, H
  add   \L, \L, T0
  sltu  T0, \L, T0
  add   T1, T1, T0
  add   \M, \M, T1
  sltu  T1, \M, T1
  add   \H, \H, T1
.endm

// `z` = `z` + `y` + `y` (Y2 = 0)
// L != 0, M = 0, H = 0
.macro _ACCU_PRDT_0 L, M, H 
  add   \L, \L, Y0
  sltu  T0, \L, Y0
  add   \L, \L, Y0 
  sltu  T1, \L, Y0 
  add   \M, T0, T1 
  add   \M, \M, Y1 
  sltu  T0, \M, Y1 
  add   \M, \M, Y1 
  sltu  T1, \M, Y1
  add   \H, T0, T1 
.endm

// `z` = `z` + `y` + `y` (Y2 = 0)
// L != 0, M != 0, H = 0
.macro _ACCU_PRDT_1 L, M, H 
  add   \L, \L, Y0
  sltu  T0, \L, Y0
  add   \L, \L, Y0 
  sltu  T1, \L, Y0 
  add   T0, T0, T1 
  add   \M, \M, T0 
  sltu  \H, \M, T0 
  add   \M, \M, Y1 
  sltu  T0, \M, Y1 
  add   \M, \M, Y1 
  sltu  T1, \M, Y1
  add   T0, T0, T1 
  add   \H, \H, T0
.endm

// `z` = `z` + `y` + `y` (Y2 != 0)
// L != 0, M != 0, H = 0
.macro _ACCU_PRDT_2 L, M, H 
  add   \L, \L, Y0
  sltu  T0, \L, Y0
  add   \L, \L, Y0 
  sltu  T1, \L, Y0 
  add   T0, T0, T1 
  add   \M, \M, T0 
  sltu  \H, \M, T0 
  add   \M, \M, Y1 
  sltu  T0, \M, Y1 
  add   \M, \M, Y1 
  sltu  T1, \M, Y1
  add   T0, T0, T1 
  add   \H, \H, T0
  add   \H, \H, Y2
  add   \H, \H, Y2
.endm

.macro COMPUTE_R0
  mul   Z0, A0, A0
  mulhu Z1, A0, A0
  sd    Z0,  0(a0)
.endm

.macro COMPUTE_R1
  mul   Y0, A0, A1
  mulhu Y1, A0, A1
  _ACCU_PRDT_0  Z1, Z2, Z0
  sd    Z1,  8(a0)
.endm

.macro COMPUTE_R2
  mul   Y0, A0, A2
  mulhu Y1, A0, A2
  _ACCU_PRDT_1  Z2, Z0, Z1
  mul   T0, A1, A1
  mulhu T1, A1, A1
  _ACCU_AIBJ_2  Z2, Z0, Z1 
  sd    Z2, 16(a0) 
.endm

.macro COMPUTE_R3
  mul   Y0, A0, A3
  mulhu Y1, A0, A3
  mul   T0, A1, A2
  mulhu T1, A1, A2
  _ACCU_AIBJ_1  Y0, Y1, Y2
  _ACCU_PRDT_2  Z0, Z1, Z2
  sd    Z0, 24(a0) 
.endm

.macro COMPUTE_R4
  mul   Y0, A0, A4
  mulhu Y1, A0, A4
  mul   T0, A1, A3
  mulhu T1, A1, A3
  _ACCU_AIBJ_1  Y0, Y1, Y2
  _ACCU_PRDT_2  Z1, Z2, Z0
  mul   T0, A2, A2
  mulhu T1, A2, A2
  _ACCU_AIBJ_2  Z1, Z2, Z0
  sd    Z1, 32(a0)   
.endm

.macro COMPUTE_R5
  mul   Y0, A0, A5
  mulhu Y1, A0, A5
  mul   T0, A1, A4
  mulhu T1, A1, A4
  _ACCU_AIBJ_1  Y0, Y1, Y2
  mul   T0, A2, A3
  mulhu T1, A2, A3
  _ACCU_AIBJ_2  Y0, Y1, Y2
  _ACCU_PRDT_2  Z2, Z0, Z1
  sd    Z2, 40(a0)   
.endm

.macro COMPUTE_R6
  mul   Y0, A0, A6
  mulhu Y1, A0, A6
  mul   T0, A1, A5
  mulhu T1, A1, A5
  _ACCU_AIBJ_1  Y0, Y1, Y2
  mul   T0, A2, A4
  mulhu T1, A2, A4
  _ACCU_AIBJ_2  Y0, Y1, Y2
  _ACCU_PRDT_2  Z0, Z1, Z2
  mul   T0, A3, A3
  mulhu T1, A3, A3
  _ACCU_AIBJ_2  Z0, Z1, Z2
  sd    Z0, 48(a0)   
.endm

.macro COMPUTE_R7
  mul   Y0, A0, A7
  mulhu Y1, A0, A7
  mul   T0, A1, A6
  mulhu T1, A1, A6
  _ACCU_AIBJ_1  Y0, Y1, Y2
  mul   T0, A2, A5
  mulhu T1, A2, A5
  _ACCU_AIBJ_2  Y0, Y1, Y2
  mul   T0, A3, A4
  mulhu T1, A3, A4
  _ACCU_AIBJ_2  Y0, Y1, Y2
  _ACCU_PRDT_2  Z1, Z2, Z0
  sd    Z1, 56(a0)   
.endm

.macro COMPUTE_R8
  mul   Y0, A1, A7
  mulhu Y1, A1, A7
  mul   T0, A2, A6
  mulhu T1, A2, A6
  _ACCU_AIBJ_1  Y0, Y1, Y2
  mul   T0, A3, A5
  mulhu T1, A3, A5
  _ACCU_AIBJ_2  Y0, Y1, Y2
  _ACCU_PRDT_2  Z2, Z0, Z1
  mul   T0, A4, A4
  mulhu T1, A4, A4
  _ACCU_AIBJ_2  Z2, Z0, Z1
  sd    Z2, 64(a0)
.endm

.macro COMPUTE_R9
  mul   Y0, A2, A7
  mulhu Y1, A2, A7
  mul   T0, A3, A6
  mulhu T1, A3, A6
  _ACCU_AIBJ_1  Y0, Y1, Y2
  mul   T0, A4, A5
  mulhu T1, A4, A5
  _ACCU_AIBJ_2  Y0, Y1, Y2
  _ACCU_PRDT_2  Z0, Z1, Z2
  sd    Z0, 72(a0)
.endm

.macro COMPUTE_R10
  mul   Y0, A3, A7
  mulhu Y1, A3, A7
  mul   T0, A4, A6
  mulhu T1, A4, A6
  _ACCU_AIBJ_1  Y0, Y1, Y2
  _ACCU_PRDT_2  Z1, Z2, Z0
  mul   T0, A5, A5
  mulhu T1, A5, A5
  _ACCU_AIBJ_2  Z1, Z2, Z0
  sd    Z1, 80(a0)
.endm

.macro COMPUTE_R11
  mul   Y0, A4, A7
  mulhu Y1, A4, A7
  mul   T0, A5, A6
  mulhu T1, A5, A6
  _ACCU_AIBJ_1  Y0, Y1, Y2
  _ACCU_PRDT_2  Z2, Z0, Z1
  sd    Z2, 88(a0)
.endm

.macro COMPUTE_R12
  mul   Y0, A5, A7
  mulhu Y1, A5, A7
  _ACCU_PRDT_1  Z0, Z1, Z2
  mul   T0, A6, A6
  mulhu T1, A6, A6
  _ACCU_AIBJ_2  Z0, Z1, Z2
  sd    Z0, 96(a0)
.endm

.macro COMPUTE_R13
  mul   Y0, A6, A7
  mulhu Y1, A6, A7
  _ACCU_PRDT_1  Z1, Z2, Z0
  sd    Z1,104(a0)
.endm

.macro COMPUTE_R14
  mul   T0, A7, A7
  mulhu T1, A7, A7
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

.global uint_sqr2_ps_sw

uint_sqr2_ps_sw:
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
  COMPUTE_R8
  COMPUTE_R9
  COMPUTE_R10
  COMPUTE_R11
  COMPUTE_R12
  COMPUTE_R13
  COMPUTE_R14
  COMPUTE_R15
  EPILOGUE
