
## Options

| Mnemonic            | Type             | Meaning                                                          |
| :------------------ | :--------------- | :----------------------------------------------------------------|
| `X25519_RVS_TYPE1`  | pure-software    | select RISC-V base ISA:          option 1, per description below |
| `X25519_RVS_TYPE2`  | specific-use ISE | select RISC-V base ISA plus ISE: option 2, per description below |
| `X25519_RVS_TYPE3`  | general-use  ISE | select RISC-V base ISA plus ISE: option 3, per description below |


## Details

- `X25519_RVS_TYPE1`: base ISA.

- `X25519_RVS_TYPE2`: base ISA plus ISE.

```
  macc51lo rd, rs1, rs2, rs3 {
    rd = ((rs1 * rs2) & (((uint64_t)1 << 51) - 1)) + rs3;
  }
  macc51hi rd, rs1, rs2, rs3 {
    rd = (((uint128_t)rs1 * rs2) >> 51) + rs3;
  }
  rsladd   rd, rs1, rs2, imm {
    rd = rs1 + (rs2 >> imm);
  }
```

## Discussion 
- We don't consider using `full-radix` representation for RISC-V since there is no carry flag, the combo of `add` and `sltu` makes the cheap thing extremely expensive.
- The weakness of current `multiply-add` instructions of other platforms:
  - AVX-512: `vpmadd52luq` and `vpmadd52huq`, i.e., AVX-512IFMA instrutions, limit the multiplier to be **52-bit** instead of **64-bit**. This requires, every time when performing the multiply-add instruction, the multiplicand and the multiplier must not exceed 52-bit (saturating issue), which is **unfriendly for Karatsuba multiplication and delayed carry propagation**. 
  - ARM: `UMLAL` $ r1 || r0 \leftarrow r1 || r0 + r2 \times r3$, `UMAAL` $ r1 || r0 \leftarrow r1 + r0 + r2 \times r3$, `VMLAL.U32` $<d1, d0> \leftarrow <d1 + d2[1] \times d3[0], d0 + d2[0]\times d3[0]>$ are **unfriendly for accmulating the higher half** of the product (i.e., they **need more registers** to serve as the accumulators when using reduced-radix representation, and they are unfriendly for simple multiplication like `mul51`). More details of ARM instructions like `UMLAL`, `UMLAL2` need to be checked. 
  - Our custom instructions: **solved above-mentioned weakness**.
- RISC-V floating-point `multiply-add` instructions are the exception (using R4-type format) in terms of Requirement 2 (i.e., at most 2 source register addresses and 1 destination register address). See details about the floating-point multiply-add instructions `F[N]MADD/F[N]MSUB` on page 69 of [1]. We therefore also design our integer `multiply-add` in a similar manner (i.e., R4-type). 
- Using our ISE can greatly accelerate the carry propagation, especially for `mul51` in x25519 and for `integer multiplication` in SIKE! Because in terms of SIKE, when using our `multiply-add` instructions, it's possible to work together with the delayed carry propagation in integer multiplication, and later perform the propagation in Montgomery reduction. 
- **One more custom instruction** (if needed) can be the one to accelerate the field subtraction (i.e. implementing `2p` in hardware).  

## Something interesting
- It would be interesting to see: when we apply our scalar and vector ISEs to the software, then 1) is scalar implementation possible to outperform the vector implementation? 2) if not, will our ISE narrow the gap?
- Since SIKE team claimed that SIKE is "happy hybrids" [3], it would also be interesting to see: if SIKE is indeed "happy hybrids" **from an ISE point of view**?
- I'm also wondering whether the **hybrid implementation** of Montgomery ladder is more efficient (vectorized batch multiplication/squaring + scalar serial addition/subtraction/mul51/inversion, see something algorithmically similar in Algorithm 1 of [2])? Because there are two ALUs, i.e., scalar ALU and vector ALU, and all the data are supposed to be stored in RAM (unless we have vector scratchpad to store data), the hybrid way seems to be a very efficient option? Not only can we use two ALUs simultaneously but also save the overhead caused by blending, alignment, and permutation.

## References 
[1] https://github.com/riscv/riscv-isa-manual/releases/download/Ratified-IMAFDQC/riscv-spec-20191213.pdf
[2] T. Chou. *Sandy2x: New Curve25519 Speed Records*, in SAC'2015.
[3] C. Costello. *The Case for SIKE: A Decade of the Supersingular Isogeny Problem*, https://eprint.iacr.org/2021/543.pdf