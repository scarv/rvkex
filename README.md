# RVKEX: ECC/isogeny-based key exchange on 64-bit RISC-V 

## Overview

- We consider the RISC-V baseline ISA as being `rv64gc` meaning that the following standard extensions
  - M      (multiplication)
  - A      (atomic)
  - F      (single-precision floating-point)
  - D      (double-precision floating-point)
  - C      (compressed)

  are available by default.

## Implementations 

- We plan to develop 4 types of implementation for each of pre-quantum X25519 [1] and post-quantum SIKEp434 [2]:
  - [x] full-radix    pure-software  x25519
  - [x] full-radix    ISE-assisted   x25519
  - [x] reduced-radix pure-software  x25519
  - [x] reduced-radix ISE-assisted   x25519
  - [x] full-radix    pure-software  sikep434
  - [x] full-radix    ISE-assisted   sikep434
  - [x] reduced-radix pure-software  sikep434
  - [x] reduced-radix ISE-assisted   sikep434

- Based on our experimental results, we plan to develop 2 types of implementation for other parameter sets of SIKE:
  - [ ] full-radix    pure-software  sikep503
  - [x] reduced-radix ISE-assisted   sikep503
  - [ ] full-radix    pure-software  sikep610
  - [x] reduced-radix ISE-assisted   sikep610
  - [ ] full-radix    pure-software  sikep751
  - [ ] reduced-radix ISE-assisted   sikep751

  Furthermore, we plan to design general-use ISE (for big number arithmetic) and specific-use ISE (for SIKE) then discuss different trade-offs. 

- Since SIKE is relatively costly (compared to other PQC KEMs), it makes more sense to target more computing-powerful `rv64` instead of `rv32` in this project. Some details and arguments about the performance of SIKE can be found on page 36 of [3]. 

## Organization 

```
├── bin                       - scripts (e.g., environment configuration)
├── doc                       - documentation (e.g., encoding and design)
├── src                       - source code
│   ├── hw                    - hardware part
│   ├── sikep434              - sikep434 implementation
│   │   ├── full-radix            - radix-2^64 (pure-sw + ise-assisted)
│   │   └── reduced-radix         - radix-2^56 (pure-sw + ise-assisted)
│   ├── sikep503              - sikep503 implementation
│   │   ├── full-radix            - radix-2^64 (pure-sw)
│   │   └── reduced-radix         - radix-2^56 (ise-assisted)
│   ├── sikep610              - sikep610 implementation
│   │   ├── full-radix            - radix-2^64 (pure-sw)
│   │   └── reduced-radix         - radix-2^56 (ise-assisted)
│   ├── sikep751              - sikep751 implementation
│   │   ├── full-radix            - radix-2^64 (pure-sw)
│   │   └── reduced-radix         - radix-2^56 (ise-assisted)
│   └── x25519                - x25519 implementations
│       ├── full-radix            - radix-2^64 (pure-sw + ise-assisted)
│       └── reduced-radix         - radix-2^51 (pure-sw + ise-assisted)
├── hw-toolchain              - scripts to install RISC-V hardware toolchains 
├── sw-toolchain              - scripts to install RISC-V software toolchains 
└── work                      - working directory for build
```

## Usage 

- Fix paths for the RISCV toolchains, e.g., 

  ```sh
  export RISCV="/opt/riscv"
  ```
- Clone the repository and setup environment

  ```sh
  git clone https://github.com/scarv/rvkex.git
  cd ./rvkex
  git submodule update --init --recursive
  source bin/conf.sh
  ```

- Build the software toolchain
  ```sh
  make sw-toolchain-build  
  ```

- Build and evaluate the (different) software 
  ```sh
  make sw-run ALG=[x25519/sikep434] RADIX=[full/reduced] TYPE=RV64_TYPE[1/2/3]
  ```
  - `RV64_TYPE1`: pure-software implementation; 
  - `RV64_TYPE2`: ISE-assisted implementation using general-use ISE; 
  - `RV64_TYPE3`: ISE-assisted implementation using general-use ISE *plus* specific-use ISE.

- Build and run the KAT test for SIKE 
  ```sh 
  make sw-kat ALG=sikep434 RADIX=[full/reduced] TYPE=RV64_TYPE[1/2/3]
  ```

- Enable the debug mode (add `MODE=debug`), e.g.,
  ```sh
  make sw-run ALG=x25519 RADIX=reduced TYPE=RV64_TYPE2 MODE=debug 
  ```

## References and links

[1] D. J. Bernstein. *Curve25519: new Diffie-Hellman speed records*, in PKC'2006.

[2] https://sike.org/files/SIDH-spec.pdf

[3] https://nvlpubs.nist.gov/nistpubs/ir/2022/NIST.IR.8413.pdf
