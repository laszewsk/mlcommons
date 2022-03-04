USER_NAME=`whoami`
GROUP_NAME='dsc:'
USER_ID=`id -u`
#GROUP_ID=`id -g`
GROUP_ID=`getent group | fgrep ${GROUP_NAME} | cut -d":" -f 3`


nvidia: nv-tf-21-05-image

all: containers


containers: nv-tf-21-05-image tf-latest-image nv-tf-20-09-image   

nv-tf-20-09-image: 
	cd nv-tf-20-09; \
	time docker build --label=nv-tf-20-09 --tag=latest \
		--build-arg USER_ID=${USER_ID} \
		--build-arg GROUP_ID=${GROUP_ID} \
		--build-arg USER_NAME=${USER_NAME} \
		.

nv-tf-21-05-image: 
	cd nv-tf-21-05; \
	time docker build --label=nv-tf-21-05 --tag=latest \
		--build-arg USER_ID=${USER_ID} \
		--build-arg GROUP_ID=${GROUP_ID} \
		--build-arg USER_NAME=${USER_NAME} \
		.

tf-latest-image: 
	cd tf-latest; \
	time docker build --label=tf-latest --tag=latest \
		--build-arg USER_ID=${USER_ID} \
		--build-arg GROUP_ID=${GROUP_ID} \
		--build-arg USER_NAME=${USER_NAME} \
		.
