
CC     =${RISCV}/bin/riscv64-unknown-elf-gcc
OBJDUMP=${RISCV}/bin/riscv64-unknown-elf-objdump
SIM    =${RISCV}/bin/spike
ISA    =rv64gc
PK     =${RISCV}/riscv64-unknown-elf/bin/pk

SRCS  = fp/sw/*.S main.c share.c rdtsc.c fpx.c random.c curve.c sidh.c sike.c fips202.c

RISCV_GCC_OPTS ?= -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O3 -ffast-math -fno-common -fno-builtin-printf

CCFLAGS += -march=${ISA} -lm -lgcc

OUTPUT  = ${WORK_DIR}/sikep434.elf
DISASM  = ${WORK_DIR}/sikep434.disasm

ifeq ($(TYPE), RV64_TYPE2)
	SRCS += fp/ise2/*.S
endif

ifeq ($(TYPE), RV64_TYPE3)
	SRCS += fp/ise2/*.S fp/ise3/*.S
endif

ifeq ($(MODE), debug)
	CCFLAGS += -DDEBUG
endif

KAT_SRCS =  ./KAT/PQCtestKAT_kem434.c \
            ./KAT/rng/rng.c \
            ./KAT/aes/aes.c \
            ./KAT/aes/aes_c.c \
            fp/sw/*.S share.c rdtsc.c fpx.c curve.c sidh.c sike.c fips202.c

KAT_OUTPUT = ${WORK_DIR}/sikep434_kat.elf
KAT_DISASM = ${WORK_DIR}/sikep434_kat.disasm

ifeq ($(TYPE), RV64_TYPE2)
	KAT_SRCS += fp/ise2/*.S
endif

ifeq ($(TYPE), RV64_TYPE3)
	KAT_SRCS += fp/ise2/*.S fp/ise3/*.S
endif

all: clean ${OUTPUT} ${DISASM}
	@${SIM} --isa=${ISA} ${PK} ${OUTPUT}

${OUTPUT} : ${SRCS}
	@mkdir -p ${WORK_DIR}
	@${CC} ${RISCV_GCC_OPTS} ${CCFLAGS} -D${TYPE} -o $@ $^

${DISASM} : ${OUTPUT}
	@${OBJDUMP} -d -t $< > $@

kat: clean ${KAT_OUTPUT} ${KAT_DISASM}
	@${SIM} --isa=${ISA} ${PK} ${KAT_OUTPUT}

${KAT_OUTPUT} : ${KAT_SRCS}
	@mkdir -p ${WORK_DIR}
	@${CC} ${RISCV_GCC_OPTS} ${CCFLAGS} -D${TYPE} -o $@ $^

${KAT_DISASM} : ${KAT_OUTPUT}
	@${OBJDUMP} -d -t $< > $@

clean:
	@rm -rf ${WORK_DIR}

