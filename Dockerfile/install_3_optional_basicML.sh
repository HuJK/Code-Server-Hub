#!/bin/bash
set -x
set -e
export DEBIAN_FRONTEND=noninteractive

function get_cpu_architecture()
{
    local cpuarch=$(uname -m)
    case $cpuarch in
         x86_64)
              echo "amd64";
              ;;
         aarch64)
              echo "arm64";
              ;;
         *)
              echo "Not supported cpu architecture: ${cpuarch}"  >&2
              exit 1
              ;;
    esac
}
cpu_arch=$(get_cpu_architecture)

ln -s cuda /usr/local/nvidia

pip3       install --upgrade keras mxnet opencv-python librosa tensorboard tensorboardX 
pip3 install torch==1.11.0+cu113 torchvision==0.12.0+cu113 torchaudio==0.11.0+cu113 -f https://download.pytorch.org/whl/torch_stable.html
export NODE_OPTIONS=--openssl-legacy-provider
if [ "$cpu_arch" = "amd64" ]; then
    echo "These packages are x86_64 only."
    pip3   install --upgrade tensorflow cupy-cuda113
fi

if [ "$cpu_arch" = "arm64" ]; then
    echo "These packages are arm only."
fi

pip3 install jupyter-tensorboard
jupyter serverextension enable jupyter_tensorboard --sys-prefix

