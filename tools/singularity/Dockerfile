# Heavily inspired by https://github.com/kaczmarj/singularity-in-docker,
# This dockerfile is based against debian and uses the newer apptainer repository
# for its runtime.

FROM golang:latest as builder

WORKDIR $GOPATH/src/github.com/apptainer
RUN apt-get update && apt-get install -y \
   build-essential \
    libssl-dev \
    uuid-dev \
    libgpgme11-dev \
    squashfs-tools \
    libseccomp-dev \
    wget \
    pkg-config \
    git

ARG SINGULARITY_VERSION="v3.8.5"
RUN git clone --depth 1 --branch ${SINGULARITY_VERSION} https://github.com/apptainer/singularity.git \
    && cd singularity \
    && ./mconfig -p /usr/local/singularity \
    && cd builddir \
    && make \
    && make install

RUN echo 'kernel.unprivileged_userns_clone=1' > /etc/sysctl.d/00-local-userns.conf

FROM debian:stable-slim
COPY --from=builder /usr/local/singularity /usr/local/singularity
ENV PATH="/usr/local/singularity/bin:$PATH" \
    SINGULARITY_TMPDIR="/tmp-singularity"
RUN apt-get update && apt-get install ca-certificates libseccomp2 squashfs-tools tzdata \
    && rm -rf /tmp/* && \
    useradd appuser

USER appuser

RUN mkdir -p /work && \
    mkdir -p $SINGULARITY_TMPDIR

WORKDIR /work
ENTRYPOINT ["/usr/local/singularity/bin/singularity"]