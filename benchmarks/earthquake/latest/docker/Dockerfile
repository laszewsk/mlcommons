ARG UBUNTU_VERSION=20.04
ARG PYTHON_MAJ_VERSION=3.10
ARG PYTHON_PATCH_VERSION=4



ARG PYTHON_VERSION=${PYTHON_MAJ_VERSION}.${PYTHON_PATCH_VERSION}

FROM ubuntu:${UBUNTU_VERSION} as BUILDER
ARG PYTHON_VERSION
ARG UBUNTU_VERSION

# Prevent apt from prompting for user input.
ENV DEBIAN_FRONTEND="noninteractive"
ENV TZ="Etc/UTC"


RUN apt-get update && \
    apt-get install -y \
    make \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev

RUN curl -O https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar xzf Python-${PYTHON_VERSION}.tgz && \
    rm Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --prefix=/opt/python/${PYTHON_VERSION}/ --enable-optimizations --with-lto --with-computed-gotos --with-system-ffi && \
    make -j "$(nproc)" && \
    make altinstall


FROM nvidia/cuda:11.6.0-cudnn8-runtime-ubuntu${UBUNTU_VERSION}
#FROM nvidia/cuda:11.6.0-base-ubuntu${UBUNTU_VERSION}
ARG PYTHON_VERSION
ARG PYTHON_MAJ_VERSION

RUN mkdir -p /opt/python/${PYTHON_VERSION}
COPY --from=BUILDER /opt/python/${PYTHON_VERSION} /opt/python/${PYTHON_VERSION}
RUN /opt/python/3.10.4/bin/python3.10 -m pip install --upgrade pip setuptools wheel && \
    ln -s /opt/python/${PYTHON_VERSION}/bin/python${PYTHON_MAJ_VERSION}  /opt/python/${PYTHON_VERSION}/bin/python3 && \
    ln -s /opt/python/${PYTHON_VERSION}/bin/python${PYTHON_MAJ_VERSION}  /opt/python/${PYTHON_VERSION}/bin/python && \
    ln -s /opt/python/${PYTHON_VERSION}/bin/pydoc${PYTHON_MAJ_VERSION}   /opt/python/${PYTHON_VERSION}/bin/pydoc && \
    ln -s /opt/python/${PYTHON_VERSION}/bin/idle${PYTHON_MAJ_VERSION}    /opt/python/${PYTHON_VERSION}/bin/idle && \
    ln -s /opt/python/${PYTHON_VERSION}/bin/python${PYTHON_MAJ_VERSION}-config /opt/python/${PYTHON_VERSION}/bin/python-config
ENV PATH=/opt/python/${PYTHON_VERSION}/bin:${PATH}

RUN apt-get update && apt-get install -y xz-utils git

ADD https://github.com/laszewsk/mlcommons/archive/refs/heads/main.tar.gz /
ADD https://github.com/laszewsk/mlcommons-data-earthquake/raw/main/data.tar.xz /
RUN mkdir -p /mlcommons && \
    mkdir -p /workspace && \
    mkdir -p /workspace/may2022 && \
    tar zxvf main.tar.gz -C /mlcommons --strip-components=1 && \
    tar Jxvf data.tar.xz -C /workspace && \
    rm main.tar.gz data.tar.xz && \
    cp -a /mlcommons/benchmarks/earthquake/may2022/FFFFWNPFEARTHQ_newTFTv29-gregor-parameters-fig.ipynb /workspace/may2022/FFFFWNPFEARTHQ_newTFTv29-gregor-parameters-fig.ipynb


SHELL ["/bin/bash", "-c"]
RUN mkdir -p /workspace && \
    python -m venv /workspace/ENV3 --upgrade-deps && \
    source /workspace/ENV3/bin/activate && \
    python -m pip install -r  /mlcommons/benchmarks/earthquake/may2022/requirements.txt

ENTRYPOINT //bin/bash