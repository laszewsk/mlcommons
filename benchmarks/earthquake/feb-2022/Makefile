IMAGE=nv-tf-21-05
TAG=latest
RAID=$(realpath /raid)
NOTEBOOKDIR=$(realpath ./notebooks)
LAB_HOME=.
PORT=8888
OPTIONS=--gpus all --shm-size=1g --ulimit memlock=-1 --memory="64g"
DGX=dgx

# --memory-swap="16g" 

# -shm-size=1g --ulimit memlock=-1 --ulimit stack=67108864

USER_NAME=`whoami`
GROUP_NAME='dsc:'
USER_ID=`id -u`
#GROUP_ID=`id -g`
GROUP_ID=`getent group | fgrep ${GROUP_NAME} | cut -d":" -f 3`

VERSION=v0.36.0
MONITOR=8080


help:
	@echo 
	@echo "help"
	@echo 
	@echo "    help  - print the help message "
	@echo 
	@echo "    reset - deletes all containers and images (use with care)"
	@echo 
	@echo "    image - create the docker image"
	@echo "    lab   - start the notebook"
	@echo 
	@echo "    shell - opens the container interactively and runs bash"
	@echo 


data:
	@echo "GROUP_NAME:" ${GROUP_NAME}
	@echo "GROUP_ID:  " ${GROUP_ID}
	@echo "VERSION:   " ${VERSION}
	@echo "MONITOR:   " ${MONITOR}

	@echo "USER_NAME: " ${USER_NAME}
	@echo "USER_ID:   " ${USER_ID}
	@echo "GROUP_IS:  " ${GROUP_IS}


trust:
	jupyter trust */*.ipynb

tunnel:
	ssh -L ${PORT}:localhost:${PORT} ${DGX}

lab:
	docker run  ${OPTIONS} -it --rm -p ${PORT}:8888 \
		-w /workspace/notebooks \
		-v ${RAID}:/raid \
		-v ${NOTEBOOKDIR}:/workspace/notebooks \
		${IMAGE}:${TAG}

image:
	cd ${LAB_HOME}/docker/${IMAGE}; \
	time docker build --label=${IMAGE} --tag=${IMAGE}:${TAG} \
		--build-arg USER_ID=${USER_ID} \
		--build-arg GROUP_ID=${GROUP_ID} \
		--build-arg USER_NAME=${USER_NAME} \
		.
	@echo
	@echo "==============================================================================="
	@echo
	@echo "Created Image:\e[1m ${IMAGE}:${TAG} \e[0m"
	@echo
	@docker image ls
	@echo
	@echo "==============================================================================="
	@echo

shell:
	docker run -it \
	    --entrypoint=/bin/bash \
	    --rm -p ${PORT}:8888 \
            -w /workspace/notebooks \
            -v ${RAID}:/raid \
            -v ${NOTEBOOKDIR}:/workspace/notebooks \
            ${IMAGE}:${TAG}

clean:
	@docker rmi ${IMAGE} --force
	@docker image -f dangling=true -q | xargs -r docker rmi --force
	@docker ps
	@docker image list
	# @docker kill $(docker ps -q)

reset:
	# @docker rmi ${IMAGE} --force
	@docker system prune -a --volumes
	@echo "------------------------------------------------------------"
	docker ps
	@echo "------------------------------------------------------------"
	docker images list

info:
	docker run --rm --gpus all nvcr.io/nvidia/tensorflow:${IMAGE} nvidia-smi
	#sudo docker run --rm --gpus all ${IMAGE} nvidia-smi


containers:
	cd docker; make containers


# OUTDATED

ext:
	jupyter labextension install --no-build @jupyterlab/toc
	jupyter labextension install --no-build @jupyter-widgets/jupyterlab-manager
	jupyter lab build
	pip install aquirdturtle_collapsible_headings
	jupyter labextension enable @jupyterlab/toc
	jupyter labextension enable @jupyter-widgets/jupyterlab-manager
	jupyter labextension enable aquirdturtle_collapsible_headings

list:
	jupyter labextension list
	jupyter-lab --version

install:
	jupyter nbextension enable --py widgetsnbextension

start:
	jupyter-lab  --port=8888 --ip=0.0.0.0 --allow-root --no-browser .

kill:
	docker kill $(docker ps -q)


monitor:
	docker run \
		--volume=/:/rootfs:ro\
		--volume=/var/run:/var/run:ro\
		--volume=/sys:/sys:ro\
		--volume=/var/lib/docker/:/var/lib/docker:ro\
		--volume=/dev/disk/:/dev/disk:ro\
		--publish=${MONITOR}:8080\
		--detach=true\
		--name=cadvisor\
		--privileged\
		--device=/dev/kmsg\
		gcr.io/cadvisor/cadvisor:${VERSION}
	sleep 1
	gopen https://localhost:${MONITOR}


update: 
	make reset
	make image


gwe:
	flatpak run com.leinardi.gwe

old:
	docker run  --gpus all -it --rm -p ${PORT}:8888 -w /workspace -v ${RAID}:/raid -v ${NOTEBOOKDIR}:/workspace/notebooks nvcr.io/nvidia/tensorflow:21.05-tf2-py3

read:
	sudo chgrp -R ${USER} /raid/experiments 
	sudo chown -R ${USER} /raid/experiments

