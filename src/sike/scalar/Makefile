
CC     =${RISCV}/bin/riscv64-unknown-elf-gcc
OBJDUMP=${RISCV}/bin/riscv64-unknown-elf-objdump
SIM    =${RISCV}/bin/spike
ISA    =rv64gcv
PK     =${RISCV}/riscv64-unknown-elf/bin/pk

VLEN  ?=128
SRCS  = fp/*.S main.c share.c rdtsc.c fpx.c curve.c sidh.c

RISCV_GCC_OPTS ?= -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O3 -ffast-math -fno-common -fno-builtin-printf

CCFLAGS += -march=${ISA} -lm -lgcc

OUTPUT  = ${work_dir}/sim_scalar.elf
DISASM  = ${work_dir}/sim_scalar.disasm

all: clean ${OUTPUT} ${DISASM}
	@${SIM} --isa=${ISA} --varch=vlen:${VLEN},elen:64 ${PK} ${OUTPUT}

${OUTPUT} : ${SRCS}
	@mkdir -p ${work_dir}
	@${CC} ${RISCV_GCC_OPTS} ${CCFLAGS} -DVLEN${VLEN} -o $@ $^

${DISASM} : ${OUTPUT}
	@${OBJDUMP} -d -t $< > $@

clean:
	@rm -rf ${work_dir}

