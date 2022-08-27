// void fp_rdc_mont_4ka_sw(uint64_t *r, const uint64_t *a);
// radix-2^57, product-scanning

// integer multiplication uses Product-Scanning or Karatsuba
#define UINT_MUL_ASM_PS 0
#define UINT_MUL_ASM_KA 1

// registers

// accumulator `z`
#define Z0 t0
#define Z1 t1

// modulus `p`
#define P0 t3
#define P1 t4
#define P2 t5
#define P3 t6
#define P4 a2 
#define P5 a3
#define P6 a7
#define P7 s10
#define P8 s11

// operand `a`
#define A0 s0
#define A1 s1
#define A2 s2
#define A3 s3
#define A4 s4
#define A5 s5
#define A6 s6
#define A7 s7
#define A8 s8
#define A_ t2

// temporary value `t`
#define T0 a4
#define T1 a5

// mask `m`
#define M_ a6

// Montgomery reduction constant `w = -p^-1 mod 2^57`
#define W_ s9


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -96
  sd    s0,   0(sp)
  sd    s1,   8(sp)
  sd    s2,  16(sp)
  sd    s3,  24(sp)
  sd    s4,  32(sp)
  sd    s5,  40(sp)
  sd    s6,  48(sp)
  sd    s7,  56(sp)
  sd    s8,  64(sp)
  sd    s9,  72(sp)
  sd    s10, 80(sp)
  sd    s11, 88(sp)
  li    M_, 0x1FFFFFFFFFFFFFFULL
  li    W_, 0x0C1301F632E294DULL
.endm

.macro EPILOGUE
  ld    s0,   0(sp)
  ld    s1,   8(sp)
  ld    s2,  16(sp)
  ld    s3,  24(sp)
  ld    s4,  32(sp)
  ld    s5,  40(sp)
  ld    s6,  48(sp)
  ld    s7,  56(sp)
  ld    s8,  64(sp)
  ld    s9,  72(sp)
  ld    s10, 80(sp)
  ld    s11, 88(sp)
  addi  sp, sp, 96 
  ret 
.endm

// load operand and modulus

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

.macro LOAD_P
  la    a4, P512
  ld    P0,  0(a4)
  ld    P1,  8(a4)
  ld    P2, 16(a4)
  ld    P3, 24(a4)
  ld    P4, 32(a4)
  ld    P5, 40(a4)
  ld    P6, 48(a4)
  ld    P7, 56(a4)
  ld    P8, 64(a4)
.endm

// first loop of Montgomery reduction (based on product-scanning)

.macro _ALIGN_ACMLTR
  srli  Z0, Z0, 57
  slli  T0, Z1,  7
  xor   Z0, Z0, T0
  srai  Z1, Z1, 57
.endm 

.macro _ACCU_PRODUCT
  add   Z0, Z0, T0
  sltu  T0, Z0, T0
  add   Z1, Z1, T1
  add   Z1, Z1, T0
.endm


.macro _ACCU_OPERAND A
#if   (UINT_MUL_ASM_PS)
  add   Z0, Z0, \A
  sltu  T0, Z0, \A
  add   Z1, Z1, T0
// NOTE: in Karatsuba, "A" can < 0. When "A" >= 0, then T1 = 0; if there is a 
// carry-out, T0 = 1, the carry bit is 0+1 = 1; if there is not a carry-out, 
// T0 = 0, the carry bit is 0+0 = 0. When "A" < 0, then T1 = -1; if there is a 
// borrow-out, T0 = 0, the carry bit is 0-1 = -1; if there is not a borrow-out, 
// T0 = 1, the carry bit is 1-1 = 0. 
#elif (UINT_MUL_ASM_KA)
  add   Z0, Z0, \A
  srai  T1, \A, 63
  sltu  T0, Z0, \A
  add   T0, T0, T1
  add   Z1, Z1, T0
#endif
.endm

.macro COMPUTE_A0
  mv    Z0, A0 
  mul   A0, Z0, W_
  and   A0, A0, M_
  mul   T0, A0, P0
  mulhu T1, A0, P0
  add   Z0, Z0, T0
  sltu  T0, Z0, T0
  add   Z1, T0, T1
  _ALIGN_ACMLTR
.endm

.macro COMPUTE_A1
  _ACCU_OPERAND A1
  mul   T0, A0, P1
  mulhu T1, A0, P1
  _ACCU_PRODUCT
  mul   A1, Z0, W_
  and   A1, A1, M_
  mul   T0, A1, P0
  mulhu T1, A1, P0
  _ACCU_PRODUCT
  _ALIGN_ACMLTR
.endm

.macro COMPUTE_A2
  _ACCU_OPERAND A2
  mul   T0, A0, P2
  mulhu T1, A0, P2
  _ACCU_PRODUCT
  mul   T0, A1, P1
  mulhu T1, A1, P1
  _ACCU_PRODUCT
  mul   A2, Z0, W_
  and   A2, A2, M_
  mul   T0, A2, P0
  mulhu T1, A2, P0
  _ACCU_PRODUCT
  _ALIGN_ACMLTR
.endm

.macro COMPUTE_A3
  _ACCU_OPERAND A3
  mul   T0, A0, P3
  mulhu T1, A0, P3
  _ACCU_PRODUCT
  mul   T0, A1, P2
  mulhu T1, A1, P2
  _ACCU_PRODUCT
  mul   T0, A2, P1
  mulhu T1, A2, P1
  _ACCU_PRODUCT
  mul   A3, Z0, W_
  and   A3, A3, M_
  mul   T0, A3, P0
  mulhu T1, A3, P0
  _ACCU_PRODUCT
  _ALIGN_ACMLTR
.endm

.macro COMPUTE_A4
  _ACCU_OPERAND A4
  mul   T0, A0, P4
  mulhu T1, A0, P4
  _ACCU_PRODUCT
  mul   T0, A1, P3
  mulhu T1, A1, P3
  _ACCU_PRODUCT
  mul   T0, A2, P2
  mulhu T1, A2, P2
  _ACCU_PRODUCT
  mul   T0, A3, P1
  mulhu T1, A3, P1
  _ACCU_PRODUCT
  mul   A4, Z0, W_
  and   A4, A4, M_
  mul   T0, A4, P0
  mulhu T1, A4, P0
  _ACCU_PRODUCT
  _ALIGN_ACMLTR
.endm

.macro COMPUTE_A5
  _ACCU_OPERAND A5
  mul   T0, A0, P5
  mulhu T1, A0, P5
  _ACCU_PRODUCT
  mul   T0, A1, P4
  mulhu T1, A1, P4
  _ACCU_PRODUCT
  mul   T0, A2, P3
  mulhu T1, A2, P3
  _ACCU_PRODUCT
  mul   T0, A3, P2
  mulhu T1, A3, P2
  _ACCU_PRODUCT
  mul   T0, A4, P1
  mulhu T1, A4, P1
  _ACCU_PRODUCT
  mul   A5, Z0, W_
  and   A5, A5, M_
  mul   T0, A5, P0
  mulhu T1, A5, P0
  _ACCU_PRODUCT
  _ALIGN_ACMLTR
.endm

.macro COMPUTE_A6
  _ACCU_OPERAND A6
  mul   T0, A0, P6
  mulhu T1, A0, P6
  _ACCU_PRODUCT
  mul   T0, A1, P5
  mulhu T1, A1, P5
  _ACCU_PRODUCT
  mul   T0, A2, P4
  mulhu T1, A2, P4
  _ACCU_PRODUCT
  mul   T0, A3, P3
  mulhu T1, A3, P3
  _ACCU_PRODUCT
  mul   T0, A4, P2
  mulhu T1, A4, P2
  _ACCU_PRODUCT
  mul   T0, A5, P1
  mulhu T1, A5, P1
  _ACCU_PRODUCT
  mul   A6, Z0, W_
  and   A6, A6, M_
  mul   T0, A6, P0
  mulhu T1, A6, P0
  _ACCU_PRODUCT
  _ALIGN_ACMLTR
.endm

.macro COMPUTE_A7
  _ACCU_OPERAND A7
  mul   T0, A0, P7
  mulhu T1, A0, P7
  _ACCU_PRODUCT
  mul   T0, A1, P6
  mulhu T1, A1, P6
  _ACCU_PRODUCT
  mul   T0, A2, P5
  mulhu T1, A2, P5
  _ACCU_PRODUCT
  mul   T0, A3, P4
  mulhu T1, A3, P4
  _ACCU_PRODUCT
  mul   T0, A4, P3
  mulhu T1, A4, P3
  _ACCU_PRODUCT
  mul   T0, A5, P2
  mulhu T1, A5, P2
  _ACCU_PRODUCT
  mul   T0, A6, P1
  mulhu T1, A6, P1
  _ACCU_PRODUCT
  mul   A7, Z0, W_
  and   A7, A7, M_
  mul   T0, A7, P0
  mulhu T1, A7, P0
  _ACCU_PRODUCT
  _ALIGN_ACMLTR
.endm

.macro COMPUTE_A8
  _ACCU_OPERAND A8
  mul   T0, A0, P8
  mulhu T1, A0, P8
  _ACCU_PRODUCT
  mul   T0, A1, P7
  mulhu T1, A1, P7
  _ACCU_PRODUCT
  mul   T0, A2, P6
  mulhu T1, A2, P6
  _ACCU_PRODUCT
  mul   T0, A3, P5
  mulhu T1, A3, P5
  _ACCU_PRODUCT
  mul   T0, A4, P4
  mulhu T1, A4, P4
  _ACCU_PRODUCT
  mul   T0, A5, P3
  mulhu T1, A5, P3
  _ACCU_PRODUCT
  mul   T0, A6, P2
  mulhu T1, A6, P2
  _ACCU_PRODUCT
  mul   T0, A7, P1
  mulhu T1, A7, P1
  _ACCU_PRODUCT
  mul   A8, Z0, W_
  and   A8, A8, M_
  mul   T0, A8, P0
  mulhu T1, A8, P0
  _ACCU_PRODUCT
  _ALIGN_ACMLTR
.endm

// second loop of Montgomery reduction (based on product-scanning) 

.macro COMPUTE_R0 
  ld    A_, 72(a1)
  _ACCU_OPERAND A_
  mul   T0, A1, P8
  mulhu T1, A1, P8
  _ACCU_PRODUCT
  mul   T0, A2, P7
  mulhu T1, A2, P7
  _ACCU_PRODUCT
  mul   T0, A3, P6
  mulhu T1, A3, P6
  _ACCU_PRODUCT
  mul   T0, A4, P5
  mulhu T1, A4, P5
  _ACCU_PRODUCT
  mul   T0, A5, P4
  mulhu T1, A5, P4
  _ACCU_PRODUCT
  mul   T0, A6, P3
  mulhu T1, A6, P3
  _ACCU_PRODUCT
  mul   T0, A7, P2
  mulhu T1, A7, P2
  _ACCU_PRODUCT
  mul   T0, A8, P1
  mulhu T1, A8, P1
  _ACCU_PRODUCT
  and   A_, Z0, M_
  _ALIGN_ACMLTR
  sd    A_,  0(a0)
.endm

.macro COMPUTE_R1
  ld    A_, 80(a1)
  _ACCU_OPERAND A_
  mul   T0, A2, P8
  mulhu T1, A2, P8
  _ACCU_PRODUCT
  mul   T0, A3, P7
  mulhu T1, A3, P7
  _ACCU_PRODUCT
  mul   T0, A4, P6
  mulhu T1, A4, P6
  _ACCU_PRODUCT
  mul   T0, A5, P5
  mulhu T1, A5, P5
  _ACCU_PRODUCT
  mul   T0, A6, P4
  mulhu T1, A6, P4
  _ACCU_PRODUCT
  mul   T0, A7, P3
  mulhu T1, A7, P3
  _ACCU_PRODUCT
  mul   T0, A8, P2
  mulhu T1, A8, P2
  _ACCU_PRODUCT
  and   A_, Z0, M_
  _ALIGN_ACMLTR
  sd    A_,  8(a0)
.endm

.macro COMPUTE_R2
  ld    A_, 88(a1)
  _ACCU_OPERAND A_
  mul   T0, A3, P8
  mulhu T1, A3, P8
  _ACCU_PRODUCT
  mul   T0, A4, P7
  mulhu T1, A4, P7
  _ACCU_PRODUCT
  mul   T0, A5, P6
  mulhu T1, A5, P6
  _ACCU_PRODUCT
  mul   T0, A6, P5
  mulhu T1, A6, P5
  _ACCU_PRODUCT
  mul   T0, A7, P4
  mulhu T1, A7, P4
  _ACCU_PRODUCT
  mul   T0, A8, P3
  mulhu T1, A8, P3
  _ACCU_PRODUCT
  and   A_, Z0, M_
  _ALIGN_ACMLTR
  sd    A_, 16(a0)
.endm

.macro COMPUTE_R3
  ld    A_, 96(a1)
  _ACCU_OPERAND A_
  mul   T0, A4, P8
  mulhu T1, A4, P8
  _ACCU_PRODUCT
  mul   T0, A5, P7
  mulhu T1, A5, P7
  _ACCU_PRODUCT
  mul   T0, A6, P6
  mulhu T1, A6, P6
  _ACCU_PRODUCT
  mul   T0, A7, P5
  mulhu T1, A7, P5
  _ACCU_PRODUCT
  mul   T0, A8, P4
  mulhu T1, A8, P4
  _ACCU_PRODUCT
  and   A_, Z0, M_
  _ALIGN_ACMLTR
  sd    A_, 24(a0)
.endm

.macro COMPUTE_R4
  ld    A_,104(a1)
  _ACCU_OPERAND A_
  mul   T0, A5, P8
  mulhu T1, A5, P8
  _ACCU_PRODUCT
  mul   T0, A6, P7
  mulhu T1, A6, P7
  _ACCU_PRODUCT
  mul   T0, A7, P6
  mulhu T1, A7, P6
  _ACCU_PRODUCT
  mul   T0, A8, P5
  mulhu T1, A8, P5
  _ACCU_PRODUCT
  and   A_, Z0, M_
  _ALIGN_ACMLTR
  sd    A_, 32(a0)
.endm

.macro COMPUTE_R5
  ld    A_,112(a1)
  _ACCU_OPERAND A_
  mul   T0, A6, P8
  mulhu T1, A6, P8
  _ACCU_PRODUCT
  mul   T0, A7, P7
  mulhu T1, A7, P7
  _ACCU_PRODUCT
  mul   T0, A8, P6
  mulhu T1, A8, P6
  _ACCU_PRODUCT
  and   A_, Z0, M_
  _ALIGN_ACMLTR
  sd    A_, 40(a0)
.endm

.macro COMPUTE_R6
  ld    A_,120(a1)
  _ACCU_OPERAND A_
  mul   T0, A7, P8
  mulhu T1, A7, P8
  _ACCU_PRODUCT
  mul   T0, A8, P7
  mulhu T1, A8, P7
  _ACCU_PRODUCT
  and   A_, Z0, M_
  _ALIGN_ACMLTR
  sd    A_, 48(a0)
.endm

.macro COMPUTE_R7
  ld    A_,128(a1)
  _ACCU_OPERAND A_
  mul   T0, A8, P8
  mulhu T1, A8, P8
  _ACCU_PRODUCT
  and   A_, Z0, M_
  srli  Z0, Z0, 57
  slli  T0, Z1,  7
  xor   Z0, Z0, T0
  sd    A_, 56(a0)
.endm

.macro COMPUTE_R8
  ld    A_,136(a1)
  add   Z0, Z0, A_
  and   A_, Z0, M_
  sd    A_, 64(a0)
.endm


.section .text

.global fp_rdc_mont_4ka_sw

fp_rdc_mont_4ka_sw:
  PROLOGUE
  LOAD_A
  LOAD_P
  COMPUTE_A0
  COMPUTE_A1
  COMPUTE_A2
  COMPUTE_A3
  COMPUTE_A4
  COMPUTE_A5
  COMPUTE_A6
  COMPUTE_A7
  COMPUTE_A8
  COMPUTE_R0
  COMPUTE_R1
  COMPUTE_R2
  COMPUTE_R3
  COMPUTE_R4
  COMPUTE_R5
  COMPUTE_R6
  COMPUTE_R7
  COMPUTE_R8
  EPILOGUE


.section .data 

.balign 8 

P512: 
.dword 0x181B90533C6C87B                // P0
.dword 0x10DFA2BD6541A8D                // P1
.dword 0x03307C2D3C9709C                // P2
.dword 0x0ACFE6AA0EA2CE6                // P3
.dword 0x1322C9CDA7AAC6C                // P4
.dword 0x0446212D7DFE634                // P5
.dword 0x1312AD0B420EBB7                // P6
.dword 0x17FF91561A2BC7C                // P7
.dword 0x065B48E8F740F89                // P8
