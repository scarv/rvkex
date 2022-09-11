
CC     =${RISCV}/bin/riscv64-unknown-elf-gcc
OBJDUMP=${RISCV}/bin/riscv64-unknown-elf-objdump
SIM    =${RISCV}/bin/spike
ISA    =rv64gc
PK     =${RISCV}/riscv64-unknown-elf/bin/pk

SRCS  = gfparith/sw/*.S main.c share.c rdtsc.c gfparith.c moncurve.c

RISCV_GCC_OPTS ?= -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O3 -ffast-math -fno-common -fno-builtin-printf

CCFLAGS += -march=${ISA} -lm -lgcc

OUTPUT  = ${WORK_DIR}/x25519.elf
DISASM  = ${WORK_DIR}/x25519.disasm

ifeq ($(TYPE), RV64_TYPE2)
	SRCS += gfparith/ise/*.S
endif

ifeq ($(MODE), debug)
	CCFLAGS += -DDEBUG
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

