#!/bin/bash

source ${REPO_HOME}/sw-toolchain/share.sh

# ------------------------------------------------------------------------------

cd ${SPIKE_REPO}
if [ -s ${SPIKE_PATCH} ] ; then
  git apply ${SPIKE_PATCH}
  git add --all
fi
cd ${REPO_HOME}
