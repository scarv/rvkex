// void mp_sub_p2_v1_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// void mp_dblsub_v0_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^56

// registers

// result "r"
#define R0 t0
#define R1 t1
#define R2 t2
#define R3 t3
#define R4 t4
#define R5 t5
#define R6 t6
#define R7 s0
#define R8 a7

// operand "a"
#define A_ a4

// operand "b"
#define B_ a5

// modulus "2p" or "4p"
#define P_ a6


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -8
  sd    s0,  0(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  addi  sp, sp,  8
  ret 
.endm

// store result 

.macro STORE_R 
  sd    R0,  0(a0)
  sd    R1,  8(a0)
  sd    R2, 16(a0)
  sd    R3, 24(a0)
  sd    R4, 32(a0)
  sd    R5, 40(a0)
  sd    R6, 48(a0)
  sd    R7, 56(a0)
  sd    R8, 64(a0)
.endm

// arithmetic computation

.macro _COMPUTE_R_ R, imm 
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2)
  add   \R, A_, a7
  sub   \R, \R, B_
.endm 

.macro _COMPUTE_RT R, imm 
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2)
  ld    P_, 8*\imm-32(a3)
  add   \R, A_, a7
  add   \R, \R, P_
  sub   \R, \R, B_
.endm 

// v1: no carry propagation

.global mp_sub_p2_v1_sw

mp_sub_p2_v1_sw:
  PROLOGUE
  la a3, P503X2T
  li a7, 0x1FFFFFFFFFFFFFEULL
  _COMPUTE_R_ R0, 0
  _COMPUTE_R_ R1, 1
  _COMPUTE_R_ R2, 2
  _COMPUTE_R_ R3, 3
  _COMPUTE_RT R4, 4
  _COMPUTE_RT R5, 5
  _COMPUTE_RT R6, 6
  _COMPUTE_RT R7, 7
  li a7, 0xFFFFFFFFFFFFFEULL 
  _COMPUTE_RT R8, 8
  STORE_R
  EPILOGUE

// integer double subtraction

.global mp_dblsub_v0_sw

mp_dblsub_v0_sw:
  .set imm, 0
  .rept 18
  ld   t0, imm(a0)
  ld   t1, imm(a1)
  ld   t2, imm(a2)
  sub  t0, t0, t1
  sub  t0, t0, t2 
  sd   t0, imm(a0)
  .set imm, imm + 8
  .endr 
  ret


.section .data 
.balign 8

// T = 2*(P503 - (2^502-1))
P503X2T:
.dword 0x23CF4158000000                 // T4
.dword 0xFB5E2610B7B444                 // T5
.dword 0xA03737ED90F6FC                 // T6
.dword 0xC08B8D7BB4EF49                 // T7
.dword 0x00CDEA83023C3C                 // T8
