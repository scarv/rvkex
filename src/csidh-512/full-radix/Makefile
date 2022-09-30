
source ${REPO_HOME}/src/sw-toolchain/share.sh

CC     =${RISCV}/bin/riscv64-unknown-elf-gcc
OBJDUMP=${RISCV}/bin/riscv64-unknown-elf-objdump
SIM    =${SPIKE_FULL_INSTALL}/bin/spike
ISA    =rv64gc
PK     =${PK_INSTALL}/riscv64-unknown-elf/bin/pk

SRCS  = fp/fp_c.c fp/uint_c.c mont.c constants.c rng.c csidh.c main.c rdtsc.c

RISCV_GCC_OPTS ?= -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O3 -ffast-math -fno-common -fno-builtin-printf

CCFLAGS += -march=${ISA} -lm -lgcc

OUTPUT  = ${WORK_DIR}/csidh-512.elf
DISASM  = ${WORK_DIR}/csidh-512.disasm

ifeq ($(TYPE), RV64_TYPE1)
	SRCS += fp/asm/sw/*.S fp/fp_asm.c
endif

ifeq ($(TYPE), RV64_TYPE2)
	SRCS += fp/asm/sw/*.S fp/fp_asm.c fp/asm/ise2/*.S
endif

ifeq ($(TYPE), RV64_TYPE3)
	SRCS += fp/asm/sw/*.S fp/fp_asm.c fp/asm/ise2/*.S fp/asm/ise3/*.S
endif

ifeq ($(CADD), disable)
	CCFLAGS += -DDISABLE_CADD
endif

all: clean ${OUTPUT} ${DISASM}
	@${SIM} --isa=${ISA} ${PK} ${OUTPUT}

${OUTPUT} : ${SRCS}
	@mkdir -p ${WORK_DIR}
	@${CC} ${RISCV_GCC_OPTS} ${CCFLAGS} -D${TYPE} -o $@ $^

${DISASM} : ${OUTPUT}
	@${OBJDUMP} -d -t $< > $@

clean:
	@rm -rf ${WORK_DIR}
