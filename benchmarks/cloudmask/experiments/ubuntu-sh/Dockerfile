FROM  nvcr.io/nvidia/tensorflow:23.04-tf2-py3

RUN apt install -y time
RUN pip install -y pip -U
RUN pip install -y cloudmesh-common cloudmesh-gpu
RUN pip install -y scikit-learn
RUN pip install -y git+https://github.com/mlperf/logging.git@1.0.0

# docker run --gpus all -it --rm --shm-size=1g --ulimit memlock=-1 -v \
# `pwd`:/project -v /scratch2:/scratch2 nvcr.io/nvidia/tensorflow:23.04-tf2-py3

