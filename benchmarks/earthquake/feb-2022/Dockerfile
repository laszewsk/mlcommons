ARG PYTHON_VERSION=3.9.7
FROM python:${PYTHON_VERSION}-slim-bullseye

# This makes bash the default RUN shell instead of /bin/sh
SHELL ["/bin/bash", "-c"]

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
# SET UP WORKING DIRECTORY
######################################################################

RUN mkdir -p /benchmark

# TODO: WE DO NOT WANT TO COPY, WE PROBABLY WANT TO MOUNT OR USE 
# GITHUB TO GET THE CODE. HOEVER IN SOME CIRCIMSTANCES A COPY IS GOOD. 
# DISCUSSION NEEDED.

COPY . /benchmark/

WORKDIR /benchmark

######################################################################
# UPDATE AND INSTALL ANACONDA
######################################################################

RUN apt-get update && apt-get install -y xz-utils curl && \
    python -m venv --prompt mlcommons-science venv && \
    source venv/bin/activate && \
    python -m pip install -U pip && \
    python -m pip install -rrequirements.txt

RUN curl -O https://repo.anaconda.com/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh && \
    bash ./Miniconda3-py39_4.10.3-Linux-x86_64.sh -b -p ~/miniconda && \
    rm Miniconda3-py39_4.10.3-Linux-x86_64.sh

######################################################################
# POPULATE DATA
######################################################################

# TODO: Wire in data volume to either google drive or to a known
# data anchor.
# Optionally, we could bring the the data with us, as it compresses
# to about 9MBs using lzma2/xz.
VOLUME /data
#RUN ln -s /data /benchmark/data

######################################################################
# UPDATE ENVIRONMENT
######################################################################


ENV PATH /root/miniconda/condabin:$PATH
ENTRYPOINT ["/benchmark/scripts/entrypoint.sh"]
CMD ["/bin/bash"]
