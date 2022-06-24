#!/bin/bash

source ${REPO_HOME}/toolchain/share.sh

# ------------------------------------------------------------------------------

cd ${SPIKE_REPO}
git diff --cached > ${SPIKE_PATCH}
cd ${REPO_HOME}
