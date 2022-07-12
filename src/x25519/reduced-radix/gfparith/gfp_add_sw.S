// void gfp_add_sw(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^51, no carry propagation, no reduction


// field addition 

.section .text

.global gfp_add_sw

gfp_add_sw:
  .set imm, 0
  .rept 5
  ld   t1, imm(a1)
  ld   t2, imm(a2)
  add  t0, t1, t2 
  sd   t0, imm(a0)
  .set imm, imm + 8
  .endr 
  ret
  