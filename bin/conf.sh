#!/bin/sh

echo "-------------------------[Setting Up Project]--------------------------"

# ------------------------------------------------------------------------------

if [ -z ${RISCV} ]; then
    echo "[ERROR] No 'RISCV' environment variable defined"
fi

export REPO_HOME=`pwd`
export CORE=rocket-rvkex

# ------------------------------------------------------------------------------

echo "REPO_HOME         = $REPO_HOME"
echo "RISCV             = $RISCV"
echo "CORE              = $CORE"

# ------------------------------------------------------------------------------

echo "------------------------------[Finished]-------------------------------"
