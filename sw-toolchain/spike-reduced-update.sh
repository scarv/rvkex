#!/bin/bash

source ${REPO_HOME}/sw-toolchain/share.sh

# ------------------------------------------------------------------------------

cd ${SPIKE_REDUCED_REPO}
git diff --cached > ${SPIKE_REDUCED_PATCH}
cd ${REPO_HOME}
