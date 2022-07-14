
ifndef REPO_HOME
  $(error "execute 'source ./bin/conf.sh' to configure environment")
endif

ifndef RISCV
  $(error "execute 'source ./bin/conf.sh' to configure environment")
endif

# ------------------------------------------------------------------------------

work_dir ?= ${REPO_HOME}/work

x25519_f:
	${MAKE} -C ${REPO_HOME}/src/x25519/full-radix       		 work_dir=${work_dir}/x25519_f

x25519_r:
	${MAKE} -C ${REPO_HOME}/src/x25519/reduced-radix    		 work_dir=${work_dir}/x25519_r

sikep434_f:
	${MAKE} -C ${REPO_HOME}/src/sike/sikep434/full-radix     work_dir=${work_dir}/sikep434_f

sikep434_r:
	${MAKE} -C ${REPO_HOME}/src/sike/sikep434/reduced-radix  work_dir=${work_dir}/sikep434_r

sikep434_r_kat:
	${MAKE} kat -C ${REPO_HOME}/src/sike/sikep434/reduced-radix  work_dir=${work_dir}/sikep434_r_kat