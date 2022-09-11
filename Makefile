
ifndef REPO_HOME
  $(error "execute 'source ./bin/conf.sh' to configure environment")
endif

ifndef RISCV
  $(error "execute 'source ./bin/conf.sh' to configure environment")
endif

# ------------------------------------------------------------------------------

export WORK_DIR ?= ${REPO_HOME}/work/${ALG}_${RADIX}

export ALG      ?= x25519
export RADIX    ?= reduced

export TYPE     ?= RV64_TYPE1
export MODE     ?= 
export CADD     ?=
# ------------------------------------------------------------------------------

sw-toolchain-build :
	@make --directory="${REPO_HOME}/sw-toolchain" clone 
	@make --directory="${REPO_HOME}/sw-toolchain" apply 
	@make --directory="${REPO_HOME}/sw-toolchain" build
sw-toolchain-clean :
	@make --directory="${REPO_HOME}/sw-toolchain" clean

sw-run:
	@make --directory="${REPO_HOME}/src/${ALG}/${RADIX}-radix" all

sw-clean:
	@make --directory="${REPO_HOME}/src/${ALG}/${RADIX}-radix" clean

# -----------------------------------------------------------------------------

hw-toolchain-build :
	@make --directory="${REPO_HOME}/hw-toolchain" clone 
	@make --directory="${REPO_HOME}/hw-toolchain" build
hw-toolchain-clean :
	@make --directory="${REPO_HOME}/hw-toolchain" clean

hw-get-rocketchip :
	@make --directory="${REPO_HOME}/src/hw" rocketchip-clone
	@make --directory="${REPO_HOME}/src/hw" rocketchip-apply

fpga-hw : 
	@make --directory="${REPO_HOME}/src/hw" fpga-verilog
	@make --directory="${REPO_HOME}/src/hw" bitstream

fpga-prog:
	@make --directory="${REPO_HOME}/src/hw" program-fpga

fpga-run :
	@make --directory="${REPO_HOME}/src/hw" fpga-swclean fpga-run	
