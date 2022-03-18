FROM nvcr.io/nvidia/tensorflow:22.02-tf1-py3

######################################################################
MAINTAINER Gregor von Laszewski <laszewski@gmail.com>#
####################################################################

######################################################################
# UPDATE
######################################################################
RUN apt update
RUN apt install -y build-essential
RUN apt install -y git

######################################################################
# Install Python 3.10.3
######################################################################

RUN python -m pip install --upgrade pip
RUN wget https://www.python.org/ftp/python/3.10.2/Python-3.10.2.tar.xz
RUN tar -Jxf Python-3.10.2.tar.xz

WORKDIR Python-3.10.2
RUN ./configure --enable-optimizations
RUN make altinstall -j8
RUN update-alternatives --install /usr/bin/python python /usr/local/bin/python3.10 1
RUN update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip3.10 1

RUN pip install pip -U

######################################################################
# Install pandoc
######################################################################

RUN apt install -y pandoc

# 3.10.2 needs to be installed ;-)

######################################################################
# CLOUDMESH
######################################################################
RUN which python
RUN python --version
RUN pip uninstall setuptools -y
RUN pip install setuptools
RUN pip install docopt
RUN pip install cloudmesh-cmd5
RUN pip install cloudmesh-gpu
RUN pip install cloudmesh-sbatch

######################################################################
# GRAPHVIZ
######################################################################
RUN apt-get install -y --no-install-recommends graphviz libgraphviz-dev


######################################################################
# PYTHON MODULES
######################################################################

RUN pip install matplotlib
RUN pip install numpy
RUN pip install pandas
RUN pip install scipy
RUN pip install scikit-learn
RUN pip install tqdm


######################################################################
# NODE.JS
######################################################################
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt install -y nodejs

## RUN apt install -y npm


######################################################################
# UPDATE TENSORFLOW >= 2.5.0
######################################################################

# RUN pip install tensorflow -U


######################################################################
# UPDATE JUPYTERLAB
######################################################################

## RUN pip uninstall -y jupyterlab
## RUN pip install jupyterlab

RUN pip install jupyterlab -U



######################################################################
# JUPYTERLAB EXTENSIONS
######################################################################

#RUN pip install tensorboard -U
#RUN pip install jupytext -U

RUN pip install nbdime
RUN pip install aquirdturtle_collapsible_headings

RUN pip install nbconvert -U
RUN pip install jupyter_bokeh
RUN pip install jupyterlab-python-file
RUN pip install ipydagred3
RUN pip install jupyterlab-git
RUN pip install jupytext -U
RUN pip install black isort jupyterlab_code_formatter 
RUN pip install ipywidgets -U
RUN pip install jupyterlab_widgets -U
RUN pip install bqplot
RUN pip install jupyterlab-topbar
RUN pip install jupyterlab_execute_time
RUN pip install ipython-autotime
RUN pip install papermill

##RUN pip install qgrid


##RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null
##RUN echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list
##RUN apt-get update && apt-get install yarn

#RUN jupyter serverextension enable jupyterlab

#RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager
#RUN jupyter labextension install @jupyterlab/toc

## RUN jupyter labextension install jupyterlab_tensorboard

RUN jupyter labextension update --all

######################################################################
# IMAGE INFO FOR JUPYTERLAB
######################################################################
RUN cms banner "Image Info"

RUN python --version
RUN pip list
RUN jupyter labextension list
RUN jupyter-lab --version

RUN cms banner "Jupyter tools"


#RUN node --version

######################################################################
# IPYNBNAME
######################################################################


RUN mkdir -p /opt
RUN cd /opt ; git clone https://github.com/cloudmesh/ipynbname.git 
RUN cd /opt/ipynbname
RUN cd /opt/ipynbname; pip install .

######################################################################
# CREATE USER
######################################################################

ARG USER_ID
ARG GROUP_ID
ARG USER_NAME

RUN addgroup --system --gid $GROUP_ID $USER_NAME
RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID $USER_NAME
USER $USER_NAME

######################################################################
# WORKSPACE AND ENTRYPOINT
######################################################################

WORKDIR /workspace

ENTRYPOINT ["jupyter-lab", "--port=8888", "--ip=0.0.0.0",  "--allow-root", "--no-browser", "."]






