#!/bin/bash

source ${REPO_HOME}/toolchain/share.sh

# ------------------------------------------------------------------------------

mkdir --parents ${RISCV}

if [ -d ${PK_BUILD} ] ; then
  rm --force --recursive ${PK_BUILD}
fi

mkdir --parents ${PK_BUILD}

export PATH="${RISCV}/bin:${PATH}"

cd ${PK_BUILD}
${PK_REPO}/configure --prefix="${RISCV}" --host="riscv64-unknown-elf" --with-arch="rv64gc" --with-abi="lp64"
make clean
make
make install
cd ${REPO_HOME}