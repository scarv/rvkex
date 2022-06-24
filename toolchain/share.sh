#!/bin/bash

export TOOL_REPO=${REPO_HOME}/work/toolchain

export GCC_REPO="${TOOL_REPO}/riscv-gnu-toolchain"
export PK_PATCH="${REPO_HOME}/toolchain/gcc.patch"
export GCC_COMMIT="28271f03bb538d926ad2889dc8ad1b0cb1b3b45c"

export PK_REPO="${TOOL_REPO}/riscv-pk"
export PK_BUILD="${PK_REPO}/build"
export PK_PATCH="${REPO_HOME}/toolchain/pk.patch"
export PK_COMMIT="b7ee9734776123c34a8c0d37fa981169521614ad"

export SPIKE_REPO="${TOOL_REPO}/riscv-isa-sim"
export SPIKE_BUILD="${SPIKE_REPO}/build"
export SPIKE_PATCH="${REPO_HOME}/toolchain/spike.patch"
export SPIKE_COMMIT="c6ec6f3582eb2ae106dff95e569b7da927910629"

export BRANCH="rvkex"
