META_UUID=0
DATA_DIR=data
RUN_WORKDIR=.
MYUSER=$(shell whoami)
RUN_BASE=${RUN_WORKDIR}/${MYUSER}/workspace-${META_UUID}

info:
	@echo "MYUSER:     " ${MYUSER}
	@echo "RUN_WORKDIR:" $(abspath ${RUN_WORKDIR})
	@echo "RUN_BASE:   " $(abspath ${RUN_BASE})

setup:
	mkdir -p ${RUN_BASE}
	cd ${RUN_BASE};  curl -LO https://github.com/laszewsk/mlcommons-data-earthquake/raw/main/data.tar.xz
	cd ${RUN_BASE}; tar -xf data.tar.xz
	cp config-wish.yaml ${RUN_WORKDIR}/config.yaml
	cp ../../FFFFWNPFEARTHQ_newTFTv29-gregor-2.ipynb .
