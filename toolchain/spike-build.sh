#!/bin/bash

source ${REPO_HOME}/toolchain/share.sh

# ------------------------------------------------------------------------------

mkdir --parents ${RISCV}

if [ -d ${SPIKE_BUILD} ] ; then
  rm --force --recursive ${SPIKE_BUILD}
fi

mkdir --parents ${SPIKE_BUILD}

export PATH="${RISCV}/bin:${PATH}"

cd ${SPIKE_BUILD}
${SPIKE_REPO}/configure --prefix="${RISCV}" --target="riscv64-unknown-elf" --with-isa="rv64gcv"
make
make install
cd ${REPO_HOME}
