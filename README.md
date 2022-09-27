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

- We plan to develop 4 types of implementation for each of pre-quantum [X25519](https://cr.yp.to/ecdh.html)  and post-quantum [CSIDH-512](https://csidh.isogeny.org):
  - [x] full-radix    pure-software  x25519
  - [x] full-radix    ISE-assisted   x25519
  - [x] reduced-radix pure-software  x25519
  - [x] reduced-radix ISE-assisted   x25519
  - [x] full-radix    pure-software  csidh-512
  - [x] full-radix    ISE-assisted   csidh-512
  - [x] reduced-radix pure-software  csidh-512
  - [x] reduced-radix ISE-assisted   csidh-512

  Furthermore, we plan to design general-purpose ISE (for large integer arithmetic) and specific-purpose ISE (for CSIDH-512) then discuss different trade-offs. 

- Since CSIDH is costly, it makes more sense to target more computing-powerful `rv64` instead of `rv32` in this project. 

## Organization 

```
├── bin                       - scripts (e.g., environment configuration)
├── doc                       - documentation (e.g., encoding and design)
├── src                       - source code
│   ├── hw                    - hardware part
│   ├── csidh-512             - csidh-512 implementations
│   │   ├── full-radix            - radix-2^64 (pure-sw + ise-assisted)
│   │   └── reduced-radix         - radix-2^57 (pure-sw + ise-assisted)
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
### Evaluation on Software Simulation

- Build the software toolchain
  ```sh
  make sw-toolchain-build  
  ```

- Build and evaluate the (different) software 
  ```sh
  make sw-run ALG=x25519    RADIX=[full/reduced] TYPE=RV64_TYPE[1/2]
  make sw-run ALG=csidh-512 RADIX=[full/reduced] TYPE=RV64_TYPE[0/1/2/3]
  ```
  - `RV64_TYPE0`: reference       C implementation; 
  - `RV64_TYPE1`: pure-software ASM implementation; 
  - `RV64_TYPE2`: ISE-assisted  ASM implementation using general-purpose ISE; 
  - `RV64_TYPE3`: ISE-assisted  ASM implementation using general-purpose ISE *plus* specific-purpose ISE.

- The optional `cadd` instruction is enabled by default. But you may would like to disable it in the ISE-assisted full-radix implementation, then add `CADD=disable`, e.g.,
  ```sh
  make sw-run ALG=x25519    RADIX=full TYPE=RV64_TYPE2 CADD=disable
  make sw-run ALG=csidh-512 RADIX=full TYPE=RV64_TYPE[2/3] CADD=disable
  ```

- Enable the debug mode (add `MODE=debug`), e.g.,
  ```sh
  make sw-run ALG=x25519 RADIX=reduced TYPE=RV64_TYPE2 MODE=debug 
  ```
  
### Evaluation with Rocket Chip on FPGA hardware

- Fix paths for the Rocket Chip toolchain, e.g., 
  
  ```sh
  export RISCV_ROCKET="/opt/riscv-rocket"
  ```

- Build a
  [toolchain](https://github.com/riscv/riscv-gnu-toolchain)
  for use with
  [Rocket-Chip](https://github.com/chipsalliance/rocket-chip.git)
  into `${RISCV_ROCKET}`:

  ```sh
  make hw-toolchain-build
  ```

- The build system in

  ```sh
  ${REPO_HOME}/src/hw/Makefile
  ```
  
  includes 
  - ISE-enabled Rocket Chip implementation, 
  - Implementing the Rocket Chip SoC on FPGA using Vivado,

- Get an ISE-enabled
  [Rocket-Chip](https://github.com/chipsalliance/rocket-chip.git)
  implementation

  ```sh
  make hw-get-rocketchip
  ```

- Build the Xilinx FPGA bitstream for the Rocket Chip system and run a software on it using Vivado:

  - Fix path for the installed Vivado Design Suite, e.g., 
  
  ```sh
  export VIVADO_TOOL_DIR="/opt/Xilinx/Vivado/2019.1"
  source ./bin/vivado-conf.sh
  ```

  - Generate the verilog files, and then bit-stream for the FPGA implementation, e.g.,

  ```sh
  ALG="x25519" RADIX=[full/reduced] make fpga-hw
  ```
 
  - Download FPGA bit-stream, and then build and execute software on the FPGA implementation, e.g.,

  ```sh
  ALG="x25519" RADIX=[full/reduced] make fpga-prog
  ```

  - Build and execute software on the FPGA implementation, e.g.,

  ```sh
  ALG="x25519" RADIX=[full/reduced] TYPE=RV64_TYPE[1/2] make fpga-run
  ```
