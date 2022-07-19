
CC     =${RISCV}/bin/riscv64-unknown-elf-gcc
OBJDUMP=${RISCV}/bin/riscv64-unknown-elf-objdump
SIM    =${RISCV}/bin/spike
ISA    =rv64gc
PK     =${RISCV}/riscv64-unknown-elf/bin/pk

SRCS  = gfparith/*.S main.c share.c rdtsc.c gfparith.c moncurve.c

RISCV_GCC_OPTS ?= -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O3 -ffast-math -fno-common -fno-builtin-printf

CCFLAGS += -march=${ISA} -lm -lgcc

OUTPUT  = ${work_dir}/x25519_f.elf
DISASM  = ${work_dir}/x25519_f.disasm

all: clean ${OUTPUT} ${DISASM}
	@${SIM} --isa=${ISA} ${PK} ${OUTPUT}

${OUTPUT} : ${SRCS}
	@mkdir -p ${work_dir}
	@${CC} ${RISCV_GCC_OPTS} ${CCFLAGS} -DVLEN${VLEN} -o $@ $^

${DISASM} : ${OUTPUT}
	@${OBJDUMP} -d -t $< > $@

clean:
	@rm -rf ${work_dir}

