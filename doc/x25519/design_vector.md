## Note

- `X25519_RVV_TYPE2` is more SIMD-like rather than vector-like, which will be most-possibly removed at the end. We use it for now because it facilitates the design for `X25519_RVV_TYPE3`.

## Options

| Mnemonic            | Type             | Meaning                                                          |
| :------------------ | :--------------- | :----------------------------------------------------------------|
| `X25519_RVV_TYPE1`  | pure-software    | select RISC-V base ISA:          option 1, per description below |
| `X25519_RVV_TYPE2`  | specific-use ISE | select RISC-V base ISA plus ISE: option 2, per description below |
| `X25519_RVV_TYPE3`  | general-use  ISE | select RISC-V base ISA plus ISE: option 3, per description below |


## Details

- `X25519_RVV_TYPE1`: base ISA.

- `X25519_RVV_TYPE2`: base ISA plus ISE.

  ```
  vmacc51lo.vv vd, vs1, vs2 {
    for (int i = 0; i < vl; i++) 
      vd[i] = ((vs1[i] * vs2[i]) & (((uint64_t)1 << 51) - 1)) + vd[i];
  }

  vmacc51hi.vv vd, vs1, vs2 {
    for (int i = 0; i < vl; i++) 
      vd[i] = (((uint128_t)vs1[i] * vs2[i]) >> 51) + vd[i];
  }

  vmul51lo.vv  vd, vs1, vs2 {
    for (int i = 0; i < vl; i++) 
      vd[i] = (vs1[i] * vs2[i]) & (((uint64_t)1 << 51) - 1);
  }

  vmul51hi.vv  vd, vs1, vs2 {
    for (int i = 0; i < vl; i++) 
      vd[i] = ((uint128_t)vs1[i] * vs2[i]) >> 51;
  }

  vsrl51add.vv vd, vs1, vs2 {
    for (int i = 0; i < vl; i++) 
      vd[i] = (vs1[i] >> 51) + vs2[i];
  }

  vpermute.vv  vd, vs1, vs2 {
    for (int i = 0; i < vl; i++) {
      uint64_t rmd = i&(VLEN/ELEN-1);
      vd[i] = vs2[vs1[rmd] + i-rmd];
    }
  }

  vmvidx1.s.x vd, rs1 {
    vd[1] = GPR[rs1];
  }

  ```

- `RVV_TYPE3`: base ISA plus ISE.

  ```
  vmacclo.vvi vd, vs1, vs2, imm {
    for (int i = 0; i < vl; i++) 
      vd[i] = ((vs1[i] * vs2[i]) & (((uint64_t)1 << imm) - 1)) + vd[i];
  }

  vmacchi.vvi vd, vs1, vs2, imm {
    for (int i = 0; i < vl; i++) 
       vd[i] = (((uint128_t)vs1[i] * vs2[i]) >> imm) + vd[i];
  } 

  vmullo.vvi vd, vs1, vs2, imm {
    for (int i = 0; i < vl; i++) 
      vd[i] = (vs1[i] * vs2[i]) & (((uint64_t)1 << imm) - 1);
  }

  vmulhi.vvi vd, vs1, vs2, imm {
    for (int i = 0; i < vl; i++) 
       vd[i] = ((uint128_t)vs1[i] * vs2[i]) >> imm;
  }  

  vsrladd.vvi vd, vs1, vs2, imm {
    for (int i = 0; i < vl; i++) 
      vd[i] = (vs1[i] >> imm) + vs2[i];
  }

  vpermute.vv  vd, vs1, vs2 {
    for (int i = 0; i < vl; i++) {
      uint64_t rmd = i&(VLEN/ELEN-1);
      vd[i] = vs2[vs1[rmd] + i-rmd];
    }
  }

  vmvidx.s.x.i vd, rs1, imm {
    vd[imm] = GPR[rs1];
  }
  ```


## Discussion 
  - Using **a pair of** single-length instructions (compred to **a single** widening instruction like `vwmaccu`) can take advantage of **the full 64-bit lane/multiplier** (i.e. `SEW = 64-bit` **and** `EEW = 64-bit`, whereas `vwmaccu` has `EEW = 64-bit` **but** `SEW = 32-bit`) 
  - Our custum multiply-add instructions are designed to be friendly for **the delayed carry propagation** (no so-called **saturating-issue** for the multiplier; see details about this issue at Sect 3.1 in [1]), in comparison to AVX-512IFMA where the multiplier is fixed to `52-bit` 
  - Blending vectors is easy in current RVV 1.0 via the mask register, however, permuting elements within a register (group) is very costly; therefore, we designed `vpermute.vv` aiming at significantly accelerating the permutation  
  - In `TYPE3`, the input `imm` can make instructions friendly for any radix 
  - It might be useful to use a set of **three** multiply-add custom instructions (i.e., we will use `vmacclo`, `vmaccmd`, `vmacchi`), which might make carry propagation more efficient (but multiplication less efficient).

## References 
[1] H. Cheng, G. Fotiadis, J. Großschädl, and P. Y. A. Ryan, *Highly Vectorized SIKE for AVX-512*, in TCHES'2022. 