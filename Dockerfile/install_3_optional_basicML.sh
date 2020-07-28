#!/bin/bash
set -x
set -e
export DEBIAN_FRONTEND=noninteractive

ln -s cuda /usr/local/nvidia
ln -s libcudart.so.10.2 /usr/local/cuda/lib64/libcudart.so.10.1
pip3       install --upgrade opencv-python librosa mxnet torch torchaudio tensorflow-gpu tensorboard tensorboardX torchvision 

jupyter labextension install jupyterlab_tensorboard
pip3 install jupyter_tensorboard
jupyter serverextension enable jupyter_tensorboard --sys-prefix

