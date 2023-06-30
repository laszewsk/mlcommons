FROM nvcr.io/nvidia/tensorflow:22.10-tf2-py3

COPY requirements.txt /tmp/

RUN apt update
RUN apt install -y python3-venv git
RUN pip install pip -U ; python --version
RUN pip install -r /tmp/requirements.txt


RUN pip install humanize
RUN pip install numpy matplotlib pandas scikit-learn jupyter jupyterlab papermill

RUN pip install tensorflow_datasets tensorflow-metadata
RUN pip install tqdm wheel ipywidgets jupyter-autotime ipython-autotime

RUN pip install cloudmesh-common cloudmesh-gpu




