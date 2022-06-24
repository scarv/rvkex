
ifndef REPO_HOME
  $(error "execute 'source ./bin/conf.sh' to configure environment")
endif

ifndef RISCV
  $(error "execute 'source ./bin/conf.sh' to configure environment")
endif

# ------------------------------------------------------------------------------

work_dir ?= ${REPO_HOME}/work

vector_x25519:	
	${MAKE} -C ${REPO_HOME}/src/x25519/vector all       work_dir=${work_dir}/vector_x25519

scalar_x25519: 
	${MAKE} -C ${REPO_HOME}/src/x25519/scalar all       work_dir=${work_dir}/scalar_x25519

vector_sike:	
	${MAKE} -C ${REPO_HOME}/src/sike/vector all         work_dir=${work_dir}/vector_sike

scalar_sike: 
	${MAKE} -C ${REPO_HOME}/src/sike/scalar all         work_dir=${work_dir}/scalar_sike