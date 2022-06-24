#!/bin/bash

source ${REPO_HOME}/toolchain/share.sh

# ------------------------------------------------------------------------------

cd ${SPIKE_REPO}
if [ -s ${SPIKE_PATCH} ] ; then
  git apply ${SPIKE_PATCH}
  git add --all
fi
cd ${REPO_HOME}
