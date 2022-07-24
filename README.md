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

- We plan to develop 4 types of implementation for each of pre-quantum X25519 [1] and post-quantum SIKE [2]:
  - [x] reduced-radix pure-software  x25519
  - [x] reduced-radix ISE-assisted   x25519
  - [x] full-radix    pure-software  x25519
  - [x] full-radix    ISE-assisted   x25519
  - [x] reduced-radix pure-software  sikep434
  - [x] reduced-radix ISE-assisted   sikep434
  - [x] full-radix    pure-software  sikep434
  - [ ] full-radix    ISE-assisted   sikep434


  Furthermore, we plan to design several different ISEs and then discuss different trade-offs. 

- Since SIKE is relatively costly (compared to other PQC KEMs), it makes more sense to target more computing-powerful `rv64` instead of `rv32` in this project. Some details and arguments about the performance of SIKE can be found on page 36 of [3]. 

## Organization 

```
├── bin                       - scripts (e.g., environment configuration)
├── doc                       - documentation (e.g., encoding and design)
├── src                       - source code
│   ├── sikep434              - sikep434 implementation
│   │   ├── full-radix            - radix-2^64 implementation
│   │   └── reduced-radix         - radix-2^56 implementation
│   └── x25519                - x25519 implementations
│       ├── full-radix            - radix-2^64 implementation
│       └── reduced-radix         - radix-2^51 implementation
├── sw-toolchain              - scripts to install RISC-V sw toolchains 
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
  make sw-run ALG=[x25519/sikep434] RADIX=[full/reduced] TYPE=RV64_TYPE[1/2]
  ```

- Build and run the KAT test for SIKE 
  ```sh 
  make sw-kat ALG=sikep434 RADIX=[full/reduced] TYPE=RV64_TYPE[1/2]
  ```

- Enable the debug mode (add `MODE=debug`), e.g.,
  ```sh
  make sw-run ALG=x25519 RADIX=reduced TYPE=RV64_TYPE2 MODE=debug 
  ```

## TODO 

- further save `ld` instructions (regarding modulus) in field/integer subtraction/addition of sike

## References and links

[1] D. J. Bernstein. *Curve25519: new Diffie-Hellman speed records*, in PKC'2006.

[2] https://sike.org/files/SIDH-spec.pdf

[3] https://nvlpubs.nist.gov/nistpubs/ir/2022/NIST.IR.8413.pdf
