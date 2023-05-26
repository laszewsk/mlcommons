FROM nvcr.io/nvidia/tensorflow:23.04-tf2-py3

RUN apt update
RUN apt upgrade -y
RUN apt install git

RUN pip install pip -U
RUN pip install numpy matplotlib pandas scikit-learn

# RUN pip install humanize  \
# RUN pip install git+https://github.com/mlperf/logging.git@1.0.0

RUN pip install cloudmesh-common
RUN pip install cloudmesh-gpu
RUN pip install jupyter jupyterlab papermill \
        tabulate tensorflow_datasets tqdm wheel \
        ipywidgets jupyter-autotime ipython-autotime



