#!/bin/bash

source ${REPO_HOME}/sw-toolchain/share.sh

# ------------------------------------------------------------------------------

if [ ! -d ${SPIKE_REDUCED_REPO} ] ; then
  git clone https://github.com/riscv/riscv-isa-sim.git ${SPIKE_REDUCED_REPO}
fi

cd ${SPIKE_REDUCED_REPO}
git fetch origin ${SPIKE_COMMIT}:${BRANCH}
git checkout ${BRANCH}
cd ${REPO_HOME}
