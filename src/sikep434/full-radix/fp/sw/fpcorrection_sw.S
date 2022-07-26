// void fpcorrection_v0_sw(uint64_t *r);
// radix-2^64


// registers

// operand and result "r"
#define R0 a7
#define R1 a1
#define R2 a2
#define R3 a3
#define R4 a4
#define R5 a5
#define R6 a6

// modulus "p"
#define P0 t2
#define P1 t3
#define P2 t3
#define P3 t3
#define P4 t4
#define P5 t5
#define P6 t6

// temp "t"
#define T0 t0
#define T1 t1


// prologue + epilogue 

.macro PROLOGUE
.endm

.macro EPILOGUE
  ret 
.endm

// load operand + store result

.macro LOAD_P
  la    t0, P434
  ld    P0,  0(t0)
  ld    P3,  8(t0)
  ld    P4, 16(t0)
  ld    P5, 24(t0)
  ld    P6, 32(t0)
.endm

.macro LOAD_R 
  ld    R0,  0(a0)
  ld    R1,  8(a0)
  ld    R2, 16(a0)
  ld    R3, 24(a0)
  ld    R4, 32(a0)
  ld    R5, 40(a0)
  ld    R6, 48(a0)
.endm

.macro STORE_R 
  sd    R0,  0(a0)
  sd    R1,  8(a0)
  sd    R2, 16(a0)
  sd    R3, 24(a0)
  sd    R4, 32(a0)
  sd    R5, 40(a0)
  sd    R6, 48(a0)
.endm

// arithmetic computation

.macro _RI_SUB_PI R, P
  sltu  T1, \R, T0 
  sub   \R, \R, T0
  sltu  T0, \R, \P
  sub   \R, \R, \P 
  or    T0, T0, T1
.endm

.macro R_SUB_P 
  sltu  T0, R0, P0
  sub   R0, R0, P0
  _RI_SUB_PI    R1, P1
  _RI_SUB_PI    R2, P2
  _RI_SUB_PI    R3, P3
  _RI_SUB_PI    R4, P4
  _RI_SUB_PI    R5, P5
  _RI_SUB_PI    R6, P6
.endm

.macro MASK_P
  sub   T0, x0, T0
  and   P0, P0, T0
//and   P1, P1, T0
//and   P2, P2, T0
  and   P3, P3, T0
  and   P4, P4, T0
  and   P5, P5, T0
  and   P6, P6, T0
.endm

.macro _RI_ADD_PJ R, P
  add   \R, \R, T0 
  sltu  T0, \R, T0 
  add   \R, \R, \P
  sltu  T1, \R, \P
  or    T0, T0, T1
.endm

.macro ADD_MASK 
  add  R0, R0, P0
  sltu T0, R0, P0
  _RI_ADD_PJ   R1, P1 
  _RI_ADD_PJ   R2, P2
  _RI_ADD_PJ   R3, P3
  _RI_ADD_PJ   R4, P4
  _RI_ADD_PJ   R5, P5
  add  R6, R6, T0 
  add  R6, R6, P6
.endm


// field correction

.section .text

.global fpcorrection_v0_sw

fpcorrection_v0_sw:
  PROLOGUE
  LOAD_P
  LOAD_R
  R_SUB_P
  MASK_P
  ADD_MASK
  STORE_R
  EPILOGUE


.section .data 
.balign 8

P434:
.dword  0xFFFFFFFFFFFFFFFF              // P0
// .dword  0xFFFFFFFFFFFFFFFF           // P1
// .dword  0xFFFFFFFFFFFFFFFF           // P2
.dword  0xFDC1767AE2FFFFFF              // P3
.dword  0x7BC65C783158AEA3              // P4
.dword  0x6CFC5FD681C52056              // P5
.dword  0x0002341F27177344              // P6
