#!/bin/bash -xe

BASE="/project/ds6011-sp22-002/python/base"

echo $BASE

# Work OpenSSL
# Fetch source code
echo "Prepping OpenSSL"
mkdir -p ${BASE}/src
(cd ${BASE}/src && curl -OL https://www.openssl.org/source/openssl-1.1.1m.tar.gz)
tar -zxvf ${BASE}/src/openssl-1.1.1m.tar.gz -C ${BASE}/src/
echo "Building OpenSSL"
(cd ${BASE}/src/openssl-1.1.1m/ && \
    ./config --prefix=${BASE}/ssl --openssldir=${BASE}/ssl shared zlib && \
    make && \
    make install && \
    make clean)


function build_python() {
  local PYTHON_VERSION=$1
  local PREFIX=$2
  local BASE=$3

  PYTHON_MAJ=${PYTHON_VERSION%.*}
  PYTHON_MIN=${PYTHON_VERSION/${PYTHON_MAJ}./}

  PREFIX="${BASE}/versions/${PYTHON_VERSION}"

  echo "Building Python <${PYTHON_VERSION}>"
  echo "Installing to <${PREFIX}>"
  echo "Using Shared Lib Folder <${BASE}>"

  mkdir -p ${BASE}/src
  (cd ${BASE}/src && curl -OL https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz)
  tar Jxvf ${BASE}/src/Python-${PYTHON_VERSION}.tar.xz -C ${BASE}/src/
  cd ${BASE}/src/Python-${PYTHON_VERSION}
  export CPPFLAGS=" -I${BASE}/ssl/include "
  export LDFLAGS=" -L${BASE}/ssl/lib "
  export LD_LIBRARY_PATH=${BASE}/ssl/lib:$LD_LIBRARY_PATH
  ./configure --prefix=${PREFIX} --enable-optimizations --with-lto --with-computed-gotos --with-system-ffi

  make -j "$(nproc)"
  make test
  make altinstall
  make clean
  (cd ${PREFIX}/bin && ln -s python${PYTHON_MAJ} python)
}

build_python 3.10.2 ${PREFIX} ${BASE}
build_python 3.9.7 ${PREFIX} ${BASE}
build_python 3.8.5 ${PREFIX} ${BASE}