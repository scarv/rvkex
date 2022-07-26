## Notation 

- `EXTS`: sign-extended

## Options

| Mnemonic            | Type                         | Meaning                                                          |
| :------------------ | :--------------------------- | :----------------------------------------------------------------|
| `RV64_RDCD_TYPE1`   | pure-software, reduced-radix | RISC-V base ISA                                                  |
| `RV64_RDCD_TYPE2`   | ISE-assisted,  reduced-radix | RISC-V base ISA + general-use ISE                                |
| `RV64_RDCD_TYPE3`   | ISE-assisted,  reduced-radix | RISC-V base ISA + general-use ISE + specific-use ISE             |
| `RV64_FULL_TYPE1`   | pure-software, full-radix    | RISC-V base ISA                                                  |
| `RV64_FULL_TYPE2`   | ISE-assisted,  full-radix    | RISC-V base ISA + general-use ISE                                |
| `RV64_FULL_TYPE3`   | ISE-assisted,  full-radix    | RISC-V base ISA + general-use ISE + specific-use ISE             |

## Details 

- `RV64_RDCD_TYPE1` and `RV64_FULL_TYPE1`: base ISA. 

- `RV64_RDCD_TYPE2`: RISC-V base ISA + general-use ISE shown below. 

```
  sraadd   rd, rs1, rs2, imm {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    r       <- x + EXTS(y >> imm)
    GPR[rd] <- r
  }

  macc51lo rd, rs1, rs2, rs3 {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    z       <- GPR[rs3]
    m       <- (1 << 51) - 1
    r       <- ( (x * y)        & m) + z 
    GPR[rd] <- r
  }

  macc51hi rd, rs1, rs2, rs3 {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    z       <- GPR[rs3]
    m       <- (1 << 64) - 1
    r       <- (((x * y) >> 51) & m) + z 
    GPR[rd] <- r
  }

  macc56lo rd, rs1, rs2, rs3 {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    z       <- GPR[rs3]
    m       <- (1 << 56) - 1
    r       <- ( (x * y)        & m) + z 
    GPR[rd] <- r
  }

  macc56hi rd, rs1, rs2, rs3 {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    z       <- GPR[rs3]
    m       <- (1 << 64) - 1
    r       <- (((x * y) >> 56) & m) + z 
    GPR[rd] <- r
  }
```

- `RV64_RDCD_TYPE3`: base ISA + general-use ISE shown above + specific-use ISE shown below. 
```
  sike.add.p434x2.sub56 rd, rs1, rs2, imm {
    x       <- GPR[rs1]
    y       <- GPR[rs2]

    if      ( imm == 0 ) { 
      r <- x + 0xFFFFFFFFFFFFFE - y
    }
    else if ( imm == 1 | imm == 2 ) {
      r <- x + 0xFFFFFFFFFFFFFF - y
    }
    else if ( imm == 3) {
      r <- x + 0xC5FFFFFFFFFFFF - y  
    }
    else if ( imm == 4) {
      r <- x + 0xB15D47FB82ECF5 - y
    }
    else if ( imm == 5) {
      r <- x + 0x40ACF78CB8F062 - y
    }
    else if ( imm == 6) {
      r <- x + 0x88D9F8BFAD038A - y
    }
    else if ( imm == 7) {
      r <- x + 0x0004683E4E2EE6 - y
    }

    GPR[rd] <- r    
  }

  sike.add.p434x4.sub56 rd, rs1, rs2, imm {
    x       <- GPR[rs1]
    y       <- GPR[rs2]

    if      ( imm == 0 ) { 
      r <- x + 0xFFFFFFFFFFFFFC - y
    }
    else if ( imm == 1 || imm == 2 ) {
      r <- x + 0xFFFFFFFFFFFFFF - y
    }
    else if ( imm == 3) {
      r <- x + 0x8BFFFFFFFFFFFF - y  
    }
    else if ( imm == 4) {
      r <- x + 0x62BA8FF705D9EB - y
    }
    else if ( imm == 5) {
      r <- x + 0x8159EF1971E0C5 - y
    }
    else if ( imm == 6) {
      r <- x + 0x11B3F17F5A0714 - y
    }
    else if ( imm == 7) {
      r <- x + 0x0008D07C9C5DCD - y
    }

    GPR[rd] <- r    
  }

  sike.sub.p434x2.add56 rd, rs1, rs2, imm {
    x       <- GPR[rs1]
    y       <- GPR[rs2]

    if      ( imm == 0 ) { 
      r <- x - 0xFFFFFFFFFFFFFE + y
    }
    else if ( imm == 1 || imm == 2 ) {
      r <- x - 0xFFFFFFFFFFFFFF + y
    }
    else if ( imm == 3) {
      r <- x - 0xC5FFFFFFFFFFFF + y  
    }
    else if ( imm == 4) {
      r <- x - 0xB15D47FB82ECF5 + y
    }
    else if ( imm == 5) {
      r <- x - 0x40ACF78CB8F062 + y
    }
    else if ( imm == 6) {
      r <- x - 0x88D9F8BFAD038A + y
    }
    else if ( imm == 7) {
      r <- x - 0x0004683E4E2EE6 + y
    }

    GPR[rd] <- r    
  } 

  sike.and.p434x2.add56 rd, rs1, rs2, imm {
    x       <- GPR[rs1]
    y       <- GPR[rs2]

    if      ( imm == 0 ) { 
      r <- ( x & 0xFFFFFFFFFFFFFE ) + y
    }
    else if ( imm == 1 || imm == 2 ) {
      r <- ( x & 0xFFFFFFFFFFFFFF ) + y
    }
    else if ( imm == 3) {
      r <- ( x & 0xC5FFFFFFFFFFFF ) + y  
    }
    else if ( imm == 4) {
      r <- ( x & 0xB15D47FB82ECF5 ) + y
    }
    else if ( imm == 5) {
      r <- ( x & 0x40ACF78CB8F062 ) + y
    }
    else if ( imm == 6) {
      r <- ( x & 0x88D9F8BFAD038A ) + y
    }
    else if ( imm == 7) {
      r <- ( x & 0x0004683E4E2EE6 ) + y
    }

    GPR[rd] <- r  
  }

  sike.and.p434.add56   rd, rs1, rs2, imm {
    x       <- GPR[rs1]
    y       <- GPR[rs2]

    if      ( imm == 0 || imm == 1 || imm == 2) { 
      r <- ( x & 0xFFFFFFFFFFFFFF ) + y;
    }
    else if ( imm == 3) {
      r <- ( x & 0xE2FFFFFFFFFFFF ) + y; 
    }
    else if ( imm == 4) {
      r <- ( x & 0x58AEA3FDC1767A ) + y;
    }
    else if ( imm == 5) {
      r <- ( x & 0x20567BC65C7831 ) + y;
    }
    else if ( imm == 6) {
      r <- ( x & 0x446CFC5FD681C5 ) + y;
    }
    else if ( imm == 7) {
      r <- ( x & 0x0002341F271773 ) + y;
    }

    GPR[rd] <- r  
  }
```

- `RV64_FULL_TYPE2`: base ISA + general-use ISE shown below. 

```
  macclo   rd, rs1, rs2, rs3 {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    z       <- GPR[rs3]
    m       <- (1 << 64) - 1
    r       <- ( (x * y)        & m) + z 
    GPR[rd] <- r
  }

  macchi   rd, rs1, rs2, rs3 {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    z       <- GPR[rs3]
    m       <- (1 << 64) - 1
    r       <- (((x * y) >> 64) & m) + z 
    GPR[rd] <- r
  }
```

- `RV64_FULL_TYPE3`: base ISA + general-use ISE shown above + specific-use ISE shown below. 
```
  sike.and.p434x2.add64 rd, rs1, rs2, imm {
    x       <- GPR[rs1]
    y       <- GPR[rs2]

    if      ( imm == 0 ) { 
      r <- ( x & 0xFFFFFFFFFFFFFFFE ) + y
    }
    else if ( imm == 1 || imm == 2 ) {
      r <- ( x & 0xFFFFFFFFFFFFFFFF ) + y
    }
    else if ( imm == 3) {
      r <- ( x & 0xFB82ECF5C5FFFFFF ) + y  
    }
    else if ( imm == 4) {
      r <- ( x & 0xF78CB8F062B15D47 ) + y
    }
    else if ( imm == 5) {
      r <- ( x & 0xD9F8BFAD038A40AC ) + y
    }
    else if ( imm == 6) {
      r <- ( x & 0x0004683E4E2EE688 ) + y
    }

    GPR[rd] <- r
  }

  sike.and.p434.add64   rd, rs1, rs2, imm {
    x       <- GPR[rs1]
    y       <- GPR[rs2]

    if      ( imm == 0 || imm == 1 || imm == 2 ) {
      r <- ( x & 0xFFFFFFFFFFFFFFFF ) + y;
    }
    else if ( imm == 3) {
      r <- ( x & 0xFDC1767AE2FFFFFF ) + y;
    }
    else if ( imm == 4) {
      r <- ( x & 0x7BC65C783158AEA3 ) + y;
    }
    else if ( imm == 5) {
      r <- ( x & 0x6CFC5FD681C52056 ) + y;
    }
    else if ( imm == 6) {
      r <- ( x & 0x0002341F27177344 ) + y;
    }

    GPR[rd] <- r
  }
```

## Discussion

- Design integer `multiply-add` instructions for `reduced-radix`:
  - integer `multiply-add` should take the offset into account. 
  - therefore, the functionality is similar to AVX-512IFMA but should keep the multiplier to be full 64-bit to solve **the saturating issue** (see details in Sect 3.1 in [1]).
  - therefore, the instruction generating higher half should return more bits.

- RISC-V floating-point `multiply-add` instructions are the exception (using R4-type format) in terms of Requirement 2 (i.e., at most 2 source register addresses and 1 destination register address). See details about the floating-point multiply-add instructions `F[N]MADD/F[N]MSUB` on page 69 of [2]. We therefore also design our integer `multiply-add` in a similar manner (i.e., R4-type).

- Since it claimed that SIKE is "happy hybrids" [3], it would be interesting to see: whether SIKE is indeed "happy hybrids" **from an ISE point of view**?

## Ideas for more custom instructions 

- squaring 

## References 

[1] H. Cheng, G. Fotiadis, J. Großschädl, and P. Y. A. Ryan. *Highly Vectorized SIKE for AVX-512*, in TCHES'2022. 

[2] https://github.com/riscv/riscv-isa-manual/releases/download/Ratified-IMAFDQC/riscv-spec-20191213.pdf.

[3] C. Costello. *The Case for SIKE: A Decade of the Supersingular Isogeny Problem*, https://eprint.iacr.org/2021/543.pdf.
