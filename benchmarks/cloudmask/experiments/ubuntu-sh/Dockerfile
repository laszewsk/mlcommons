FROM  nvcr.io/nvidia/tensorflow:23.04-tf2-py3

RUN apt install -y time
RUN pip install pip -U
RUN pip install  \
    cloudmesh-common  \
    cloudmesh-gpu
RUN pip install scikit-learn
RUN pip install git+https://github.com/mlperf/logging.git@1.0.0

RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1001 ubuntu
USER ubuntu

WORKDIR /home/cloudmask

RUN cms help

WORKDIR /project
# docker run --gpus all -it --rm --shm-size=1g --ulimit memlock=-1 -v \
# `pwd`:/project -v /scratch2:/scratch2 nvcr.io/nvidia/tensorflow:23.04-tf2-py3

