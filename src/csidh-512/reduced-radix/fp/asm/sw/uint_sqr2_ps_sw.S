// void uint_sqr2_ps_sw(uint64_t *r, const uint64_t *a);
// radix-2^57, product-scanning
// no carry propagation since it will be done in Montgomery reduction


// registers

// accumulator `z`
#define Z0 a1
#define Z1 a2

// partial product `y`
#define Y0 a6
#define Y1 s0

// operand `b` 
#define B0 t0 
#define B1 t1
#define B2 t2
#define B3 t3
#define B4 t4
#define B5 t5
#define B6 t6
#define B7 a7
#define B8 a3

// operand `a`
#define A0 t0 
#define A1 t1
#define A2 t2 
#define A3 t3
#define A4 t4
#define A5 t5
#define A6 t6
#define A7 a7
#define A8 a3

// temporary value `t`
#define T0 a4
#define T1 a5

// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -8
  sd    s0,  0(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  addi  sp, sp, 8
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
  ld    A8, 64(a1)
.endm 

// integer multiplication (based on product-scanning)

// L != 0, H = 0
.macro _ACCU_AIAJ_0 L H 
  add   \L, \L, T0
  sltu  T0, \L, T0 
  add   \H, T1, T0
.endm

// L != 0, H != 0
.macro _ACCU_AIAJ_1 L H  
  add   \L, \L, T0 
  sltu  T0, \L, T0
  add   \H, \H, T1
  add   \H, \H, T0
.endm

// `z` = `z` + `y` + `y`
// Z0 != 0, Z1 = 0
.macro _ACCU_PRDT_0 
  add   Z0, Z0, Y0
  sltu  T0, Z0, Y0
  add   Z0, Z0, Y0
  sltu  T1, Z0, Y0
  add   Z1, Y1, Y1
  add   Z1, Z1, T0
  add   Z1, Z1, T1
.endm

.macro COMPUTE_R0
  mul   Z0, A0, A0
  mulhu Z1, A0, A0
  sd    Z0,  0(a0)
  slli  Z0, Z1,  7
.endm

.macro COMPUTE_R1
  mul   Y0, A0, A1
  mulhu Y1, A0, A1
  _ACCU_PRDT_0
  sd    Z0,  8(a0)
  slli  Z0, Z1,  7
.endm

.macro COMPUTE_R2
  mul   Y0, A0, A2
  mulhu Y1, A0, A2
  _ACCU_PRDT_0
  mul   T0, A1, B1
  mulhu T1, A1, B1
  _ACCU_AIAJ_1  Z0, Z1
  sd    Z0, 16(a0)
  slli  Z0, Z1,  7
.endm

.macro COMPUTE_R3
  mul   Y0, A0, A3
  mulhu Y1, A0, A3
  mul   T0, A1, A2
  mulhu T1, A1, A2
  _ACCU_AIAJ_1  Y0, Y1
  _ACCU_PRDT_0
  sd    Z0, 24(a0)
  slli  Z0, Z1,  7
.endm

.macro COMPUTE_R4
  mul   Y0, A0, A4
  mulhu Y1, A0, A4
  mul   T0, A1, A3
  mulhu T1, A1, A3
  _ACCU_AIAJ_1  Y0, Y1
  _ACCU_PRDT_0
  mul   T0, A2, B2
  mulhu T1, A2, B2
  _ACCU_AIAJ_1 Z0, Z1
  sd    Z0, 32(a0)
  slli  Z0, Z1,  7
.endm

.macro COMPUTE_R5
  mul   Y0, A0, A5
  mulhu Y1, A0, A5
  mul   T0, A1, A4
  mulhu T1, A1, A4
  _ACCU_AIAJ_1  Y0, Y1
  mul   T0, A2, A3
  mulhu T1, A2, A3
  _ACCU_AIAJ_1  Y0, Y1
  _ACCU_PRDT_0
  sd    Z0, 40(a0)
  slli  Z0, Z1,  7
.endm

.macro COMPUTE_R6
  mul   Y0, A0, A6
  mulhu Y1, A0, A6
  mul   T0, A1, A5
  mulhu T1, A1, A5
  _ACCU_AIAJ_1  Y0, Y1
  mul   T0, A2, A4
  mulhu T1, A2, A4
  _ACCU_AIAJ_1  Y0, Y1
  _ACCU_PRDT_0
  mul   T0, A3, A3
  mulhu T1, A3, A3
  _ACCU_AIAJ_1  Z0, Z1
  sd    Z0, 48(a0)
  slli  Z0, Z1,  7
.endm

.macro COMPUTE_R7
  mul   Y0, A0, A7
  mulhu Y1, A0, A7
  mul   T0, A1, A6
  mulhu T1, A1, A6
  _ACCU_AIAJ_1  Y0, Y1
  mul   T0, A2, A5
  mulhu T1, A2, A5
  _ACCU_AIAJ_1  Y0, Y1
  mul   T0, A3, A4
  mulhu T1, A3, A4
  _ACCU_AIAJ_1  Y0, Y1
  _ACCU_PRDT_0
  sd    Z0, 56(a0)
  slli  Z0, Z1,  7
.endm

.macro COMPUTE_R8
  mul   Y0, A0, A8
  mulhu Y1, A0, A8
  mul   T0, A1, A7
  mulhu T1, A1, A7
  _ACCU_AIAJ_1  Y0, Y1
  mul   T0, A2, A6
  mulhu T1, A2, A6
  _ACCU_AIAJ_1  Y0, Y1
  mul   T0, A3, A5
  mulhu T1, A3, A5
  _ACCU_AIAJ_1  Y0, Y1
  _ACCU_PRDT_0
  mul   T0, A4, A4
  mulhu T1, A4, A4
  _ACCU_AIAJ_1  Z0, Z1
  sd    Z0, 64(a0)
  slli  Z0, Z1,  7
.endm

.macro COMPUTE_R9
  mul   Y0, A1, A8
  mulhu Y1, A1, A8
  mul   T0, A2, A7
  mulhu T1, A2, A7
  _ACCU_AIAJ_1  Y0, Y1
  mul   T0, A3, A6
  mulhu T1, A3, A6
  _ACCU_AIAJ_1  Y0, Y1
  mul   T0, A4, A5
  mulhu T1, A4, A5
  _ACCU_AIAJ_1  Y0, Y1
  _ACCU_PRDT_0
  sd    Z0, 72(a0)
  slli  Z0, Z1,  7
.endm

.macro COMPUTE_R10
  mul   Y0, A2, A8
  mulhu Y1, A2, A8
  mul   T0, A3, A7
  mulhu T1, A3, A7
  _ACCU_AIAJ_1  Y0, Y1
  mul   T0, A4, A6
  mulhu T1, A4, A6
  _ACCU_AIAJ_1  Y0, Y1
  _ACCU_PRDT_0
  mul   T0, A5, A5
  mulhu T1, A5, A5
  _ACCU_AIAJ_1  Z0, Z1
  sd    Z0, 80(a0)
  slli  Z0, Z1,  7
.endm

.macro COMPUTE_R11
  mul   Y0, A3, A8
  mulhu Y1, A3, A8
  mul   T0, A4, A7
  mulhu T1, A4, A7
  _ACCU_AIAJ_1  Y0, Y1
  mul   T0, A5, A6
  mulhu T1, A5, A6
  _ACCU_AIAJ_1  Y0, Y1
  _ACCU_PRDT_0
  sd    Z0, 88(a0)
  slli  Z0, Z1,  7
.endm

.macro COMPUTE_R12
  mul   Y0, A4, A8
  mulhu Y1, A4, A8
  mul   T0, A5, A7
  mulhu T1, A5, A7
  _ACCU_AIAJ_1  Y0, Y1
  _ACCU_PRDT_0
  mul   T0, A6, A6
  mulhu T1, A6, A6
  _ACCU_AIAJ_1  Z0, Z1
  sd    Z0, 96(a0)
  slli  Z0, Z1,  7
.endm

.macro COMPUTE_R13
  mul   Y0, A5, A8
  mulhu Y1, A5, A8
  mul   T0, A6, A7
  mulhu T1, A6, A7
  _ACCU_AIAJ_1  Y0, Y1
  _ACCU_PRDT_0
  sd    Z0,104(a0)
  slli  Z0, Z1,  7
.endm

.macro COMPUTE_R14
  mul   Y0, A6, A8
  mulhu Y1, A6, A8
  _ACCU_PRDT_0
  mul   T0, A7, A7
  mulhu T1, A7, A7
  _ACCU_AIAJ_1  Z0, Z1
  sd    Z0,112(a0)
  slli  Z0, Z1,  7
.endm

.macro COMPUTE_R15
  mul   Y0, A7, A8
  mulhu Y1, A7, A8
  _ACCU_PRDT_0
  sd    Z0,120(a0)
  slli  Z0, Z1,  7
.endm

.macro COMPUTE_R16
  mul   T0, A8, B8
  mulhu T1, A8, B8
  _ACCU_AIAJ_0  Z0, Z1
  sd    Z0,128(a0)
  slli  Z0, Z1,  7
.endm

.macro COMPUTE_R17
  sd    Z0,136(a0)
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
  COMPUTE_R16
  COMPUTE_R17
  EPILOGUE
