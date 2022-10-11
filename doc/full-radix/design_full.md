## Notation 

- The 511-bit modulus of CSIDH-512 in the full-radix (radix-$2^{64}$) representation: 
```
P511F = {     
  0x1B81B90533C6C87B, 0xC2721BF457ACA835, 0x516730CC1F0B4F25,
  0xA7AAC6C567F35507, 0x5AFBFCC69322C9CD, 0xB42D083AEDC88C42,
  0xFC8AB0D15E3E4C4A, 0x65B48E8F740F89BF }
```

## Options

| Mnemonic            | Type                         | Meaning                                                          |
| :------------------ | :--------------------------- | :----------------------------------------------------------------|
| `RV64_FULL_TYPE1`   | pure-software, full-radix    | RISC-V base ISA                                                  |
| `RV64_FULL_TYPE2`   | ISE-assisted,  full-radix    | RISC-V base ISA + general-purpose ISE                            |
| `RV64_FULL_TYPE3`   | ISE-assisted,  full-radix    | RISC-V base ISA + general-purpose ISE + special-purpose ISE     |

## Details 

- `RV64_FULL_TYPE1`: base ISA. 

- `RV64_FULL_TYPE2`: base ISA + general-purpose ISE shown below. 

```
  maddlu   rd, rs1, rs2, rs3 {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    z       <- GPR[rs3]
    m       <- (1 << 64) - 1
    r       <- ( (x * y + z)         & m) 
    GPR[rd] <- r
  }

  maddhu   rd, rs1, rs2, rs3 {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    z       <- GPR[rs3]
    m       <- (1 << 64) - 1
    r       <- (((x * y  + z) >> 64) & m) 
    GPR[rd] <- r
  }

  cadd     rd, rs1, rs2, rs3 {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    z       <- GPR[rs3]
    r       <- ((x + y) >> 64) + z
    GPR[rd] <- r
  }  

```

- `RV64_FULL_TYPE3`: base ISA + general-purpose ISE shown above + special-purpose ISE shown below. 

```
  csidh.sub.p512       rd, rs1,      imm {
    x       <- GPR[rs1]
    r       <- x - P511F[imm] 
    GPR[rd] <- r
  }

  csidh.and.p512.add   rd, rs1, rs2, imm {
    x       <- GPR[rs1]
    y       <- GPR[rs2]
    r       <- (x & P511F[imm]) + y
    GPR[rd] <- r
  }
```
