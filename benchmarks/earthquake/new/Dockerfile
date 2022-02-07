ARG PYTHON_VERSION=3.9.7
FROM python:${PYTHON_VERSION}-slim-bullseye

# This makes bash the default RUN shell instead of /bin/sh
SHELL ["/bin/bash", "-c"]

RUN mkdir -p /benchmark

COPY . /benchmark/

WORKDIR /benchmark


RUN apt-get update && apt-get install -y xz-utils curl && \
    python -m venv --prompt mlcommons-science venv && \
    source venv/bin/activate && \
    python -m pip install -U pip && \
    python -m pip install -rrequirements.txt

# TODO: Wire in data volume to either google drive or to a known
# data anchor.
# Optionally, we could bring the the data with us, as it compresses
# to about 9MBs using lzma2/xz.
VOLUME /data
#RUN ln -s /data /benchmark/data

RUN curl -O https://repo.anaconda.com/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh && \
    bash ./Miniconda3-py39_4.10.3-Linux-x86_64.sh -b -p ~/miniconda && \
    rm Miniconda3-py39_4.10.3-Linux-x86_64.sh

ENV PATH /root/miniconda/condabin:$PATH
ENTRYPOINT ["/benchmark/scripts/entrypoint.sh"]
CMD ["/bin/bash"]