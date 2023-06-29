# Ubuntu

## Nvidia Docker Documentation

<https://catalog.ngc.nvidia.com/orgs/nvidia/containers/tensorflow>

```
docker --version
```

Docker version 23.0.5, build bc4487a


current version Apr 27, 20203

* 23.04-tf2-py3

```
docker run --gpus all -it --rm nvcr.io/nvidia/tensorflow:23.04-tf2-py
```

python --version
Python 3.8.10

docker run --gpus all -it --rm --shm-size=1g --ulimit memlock=-1 -v \
`pwd`:/project -v /scratch2:/scratch2 nvcr.io/nvidia/tensorflow:23.04-tf2-py3

/project
/scratch

pip install pip -U
pip install cloudmesh-common
pip install git+https://github.com/mlperf/logging.git@1.0.0
pip install scikit-learn

