#!/bin/bash

source ${REPO_HOME}/sw-toolchain/share.sh

# ------------------------------------------------------------------------------

if [ ! -d ${SPIKE_REPO} ] ; then
  git clone https://github.com/riscv/riscv-isa-sim.git ${SPIKE_REPO}
fi

cd ${SPIKE_REPO}
git fetch origin ${SPIKE_COMMIT}:${BRANCH}
git checkout ${BRANCH}
cd ${REPO_HOME}
