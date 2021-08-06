#!/bin/bash
set -x
set -e
export DEBIAN_FRONTEND=noninteractive

ln -s cuda /usr/local/nvidia
ln -s libcudart.so.10.2 /usr/local/cuda/lib64/libcudart.so.10.1
pip3       install --upgrade tensorflow  keras mxnet torch 
pip3       install --upgrade tensorboard tensorboardX opencv-python torchaudio  torchvision librosa
pip install git+https://github.com/cliffwoolley/jupyter_tensorboard.git
pip install git+https://github.com/chaoleili/jupyterlab_tensorboard.git
jupyter serverextension enable jupyter_tensorboard --sys-prefix

