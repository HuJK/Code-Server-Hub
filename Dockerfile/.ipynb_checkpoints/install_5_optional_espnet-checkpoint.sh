#!/bin/bash
set -x
set -e
export DEBIAN_FRONTEND=noninteractive
echo "Install espnet"

pip3 install -U PyYAML Cython

cd /usr/share
git clone  --depth 1 https://github.com/espnet/espnet espnet


export CUDAROOT=/usr/local/cuda
export PATH=$CUDAROOT/bin:$PATH
export LD_LIBRARY_PATH=$CUDAROOT/lib64:$LD_LIBRARY_PATH
export CFLAGS="-I$CUDAROOT/include $CFLAGS"
export CPATH=$CUDAROOT/include:$CPATH
export CUDA_HOME=$CUDAROOT
export CUDA_PATH=$CUDAROOT
echo $CFLAGS

export CUDA_HOME=/usr/local/cuda # change to your path
export CUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME
export LD_LIBRARY_PATH="$CUDA_HOME/extras/CUPTI/lib64:$LD_LIBRARY_PATH"
export LIBRARY_PATH=$CUDA_HOME/lib64:$LIBRARY_PATH

echo $PATH
which python3
ln -s /usr/bin/python3 /usr/local/bin/python
ln -s pip3 /usr/bin/pip
cd /usr/share/espnet/tools
alias pip=pip3
rm -rf venv; mkdir -p venv/bin; touch venv/bin/activate  # Create an empty file
make KALDI=/usr/share/kaldi-asr PYTHON=dummy
cd /usr/share/espnet/tools
sed -i.bak "/^PYTHON_VERSION := .*/cPYTHON_VERSION := 3.6.9" Makefile
sed -i.bak "/^CHAINER_VERSION := .*/cCHAINER_VERSION := 7.4.0" Makefile
sed -i.bak "/^TH_VERSION := .*/cTH_VERSION := 1.5.1" Makefile
make check_install


rm /usr/local/bin/python
rm /usr/bin/pip


pip3 install -U torch

exit 0
