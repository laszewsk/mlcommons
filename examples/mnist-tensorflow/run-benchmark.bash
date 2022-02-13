#!/bin/bash

####
#### CAUTION
####
####

# This script is still in draft format.


### Note you must first do the following before this script can be used:
# 0. Install NVidia's GPU Driver (if on linux)
# 1. Install NVidia's CUDA Toolkit 11.0 - https://developer.nvidia.com/cuda-11.0-download-archive
# 2. Download NVidia's cuDNN - https://developer.nvidia.com/rdp/cudnn-archive#a-collapse804-110
#    a. If using Linux, see the linux procedure at the top of this to configure things.
#    b. If using windows, install winget https://github.com/microsoft/winget-cli by using Add-AppxPackage -Path https://github.com/microsoft/winget-cli/releases/download/v1.2.10271/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle


# Be sure to match the CUDA version with CUDNN

CUDA_VERSION=11.5.2_496.13 # Get from https://developer.nvidia.com/cuda-11-5-2-download-archive
CUDNN_VERSION=8.3.1.22 # Get from https://developer.nvidia.com/rdp/cudnn-archive


# Installs CUDA and cuDNN on linus
cudnn_linux() {
    local cudnn_archive = $1
    shift

    local CUDNN_BASE=/opt/nvidia/cudnn
    local CUDA_BASE=/usr/local/cuda

    sudo mkdir -p ${CUDNN_BASE}
    sudo tar -xzvf ${cudnn_archive}.tgz -C ${CUDNN_BASE} --strip-components=1
    sudo cp ${CUDNN_BASE}/include/cudnn.h ${CUDA_BASE}/include
    sudo cp ${CUDNN_BASE}/lib64/libcudnn* ${CUDA_BASE}/lib64
    sudo chmod a+r ${CUDNN_BASE}/include/cudnn.h ${CUDNN_BASE}/lib64/libcudnn*
    sudo cat > /etc/ld.so.conf.d/99990-cudnn.conf <<EOF 
${CUDNN_BASE}/lib64
EOF
    # Note this will issue a warning about several libraries not being symlinks.  This
    # is okay as we're using the packaged distribution from NVidia.
    sudo ldconfig
}

# Installs the required libraries to get the system working on windows
cudnn_mk_windows() {
    local cudnn_archive = $1
    shift
    winget install "Nvidia.CUDA"
    # You'll need to install cuDNN using your NVidia account's credentials
    # no additional modification is needed to use this on windows.
    mkdir -p /c/tools/cudnn
    unzip -d /c/tools/cudnn "$cudnn_archive"
    #setx PATH="C:\\tools\\cuda\\bin;C:\\tools\\cuda\\lib;C:\\tools\\cuda\\include;%PATH%"
}

mk_from_source_win() {
    winget install "Visual Studio Build Tools 2022"
    "C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe" modify --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 Microsoft.VisualStudio.ComponentGroup.VC.Tools.142.x86.x64	
    (cd /tmp/Python-${PYTHON_VERSION} && ./PCbuild/build.bat)
    mkdir -p /c/tools/python/${PYTHON_VERSION}
    (cd /tmp/Python-${PYTHON_VERSION}/PCbuild/amd64 && cp -a . /c/tools/python/${PYTHON_VERSION}/)
}

# Creates a new version of python building from source
mk_from_source() {
    PYTHON_VERSION="${1}"
    shift

    ## Derived versions
    small_version=$(echo ${PYTHON_VERSION} | cut -f 1-2 -d '.')
    arch_version=$(echo ${PYTHON_VERISON} | cut -f 1 -d '.')
    source /etc/os-release
    (cd /tmp && curl -O https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz)
    (cd /tmp && tar xzf Python-${PYTHON_VERSION}.tgz)
    # Setup build dependencies for python
    if [ "x$OS" == "xWindows_NT" ]; then
        cu_mk_windows
    else
        if [ "x$ID" == "xdebian" ]; then
            sudo apt-get install -y make \
                                    build-essential \
                                    libssl-dev \
                                    zlib1g-dev \
                                    libbz2-dev \
                                    libreadline-dev \
                                    libsqlite3-dev \
                                    wget \
                                    curl \
                                    llvm \
                                    libncurses5-dev \
                                    ibncursesw5-dev \
                                    xz-utils \
                                    tk-dev
        elif [ "x$ID_LIKE" == "xopensuse suse" ]; then
            sudo zypper install -t pattern devel_basis
        elif [ "x$NAME" == "xubuntu" ]; then
            sudo apt-get install -y make\
                                    build-essential \
                                    libssl-dev \
                                    zlib1g-dev \
                                    libbz2-dev \
                                    libreadline-dev \
                                    libsqlite3-dev \
                                    wget \
                                    curl \
                                    llvm \
                                    libncurses5-dev \
                                    libncursesw5-dev \
                                    xz-utils \
                                    tk-dev
        fi

        (cd /tmp/Python-${PYTHON_VERSION} && \
            ./configure --prefix=/opt/python/${PYTHON_VERSION}/ --enable-optimizations --with-lto --with-computed-gotos --with-system-ffi && \
            make -j "$(nproc)" && \
            sudo make altinstall)
        rm /tmp/Python-${PYTHON_VERSION}.tgz
        /opt/python/${PYTHON_VERSION}/bin/python3.10 -m pip install --upgrade pip setuptools wheel

        sudo ln -s /opt/python/${PYTHON_VERSION}/bin/python${small_version}          /opt/python/${PYTHON_VERSION}/bin/python${arch_version}
        sudo ln -s /opt/python/${PYTHON_VERSION}/bin/python${small_version}          /opt/python/${PYTHON_VERSION}/bin/python
        sudo ln -s /opt/python/${PYTHON_VERSION}/bin/pip${small_version}             /opt/python/${PYTHON_VERSION}/bin/pip${arch_version}
        sudo ln -s /opt/python/${PYTHON_VERSION}/bin/pip${small_version}             /opt/python/${PYTHON_VERSION}/bin/pip
        sudo ln -s /opt/python/${PYTHON_VERSION}/bin/pydoc${small_version}           /opt/python/${PYTHON_VERSION}/bin/pydoc
        sudo ln -s /opt/python/${PYTHON_VERSION}/bin/idle${small_version}            /opt/python/${PYTHON_VERSION}/bin/idle
        sudo ln -s /opt/python/${PYTHON_VERSION}/bin/python${small_version}-config   /opt/python/${PYTHON_VERSION}/bin/python-config
    
    fi
}

# Runs the benchmark, uses an already installed python version
run() {
    local PYTHON_BIN
    printf "Using python version %s.\n" "${PYTHON_VERSION}"

    if [ "x${PYTHON_VERSION}" == "xpath" ]; then
        PYTHON_BIN=$(which python)
    elif [ "x$OS" == "Windows_NT" ]; then
        PYTHON_BIN=/c/tools/python/${PYTHON_VERSION}/bin/python${small_version}
    else
        PYTHON_BIN=/opt/python/${PYTHON_VERSION}/bin/python
    fi

    if [ x"$OS" == "Windows_NT" ]; then
        ACTIVATE_PATH=mnist-${PYTHON_VERSION}/Scripts/activate
    else
        ACTIVATE_PATH=mnist-${PYTHON_VERSION}/bin/activate
    fi

    $PYTHON_BIN -m venv mnist-${PYTHON_VERSION}
    source ${ACTIVATE_PATH}

    python -m pip install -U pip setuptools wheel
    python -m pip install -r requirements.txt
    time python mnist.py
}

usage() {
    printf "\`$0' is a Driver script for running MNIST Benchmark\n\n"
    printf "Usage: $0 [OPTION]...\n\n"
    printf "Options:\n"
    printf "  -u        Specifies the version of python to use. Supply \"path\" to use python already on path\n"
    printf "  -s        Specifies that the version set by -u should be compiled from source\n"
    printf "  -c        [Experemental] Installs cuDNN libraries on the target system.\n"
    printf "  -h        Displays this help message\n\n"
    printf "Report bugs to <https://github.com/laszewsk/mlcommons/issues>.\n\n"

}

# CLI Command loop
while getopts "u:c:sh" argument ; do
    case "${argument}" in
        u) PYTHON_VERSION="${OPTARG}"
        ;;
        s) printf "Compiling from source\n"
           if [ "x$OS" == "xWindows_NT" ] ; then
            mk_from_source_win $PYTHON_VERSION
           else
            printf "Command requires admin rights, type your root password to continue\n"
            sudo printf "Starting build\n"
            mk_from_source $PYTHON_VERSION
           fi
        ;;
        c) read -n 1 -p "CAUTION this step is experemental, do you want to continue? [y/n] " proceed
           if [ "x$Proceed" == "y" ] && [ "x$OS" == "xWindows_NT" ] ; then
            cudnn_mk_windows ${OPTARG}
           else
            cudnn_linux ${OPTARG}
           fi
        ;;
        h) usage
           exit 0
        ;;
        *) usage
           exit 1
        ;;
    esac
done

if [ -z "${PYTHON_VERSION}" ]; then
    PYTHON_VERSION="path"
fi

run
