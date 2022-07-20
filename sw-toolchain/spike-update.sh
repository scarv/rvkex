#!/bin/bash

source ${REPO_HOME}/sw-toolchain/share.sh

# ------------------------------------------------------------------------------

cd ${SPIKE_REPO}
git diff --cached > ${SPIKE_PATCH}
cd ${REPO_HOME}
