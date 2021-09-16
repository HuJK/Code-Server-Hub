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
pip3       install --upgrade keras mxnet opencv-python librosa
pip3 install torch==1.9.0+cu111 torchvision==0.10.0+cu111 torchaudio==0.9.0 -f https://download.pytorch.org/whl/torch_stable.html

if [ "$cpu_arch" = "amd64" ]; then
    echo "These packages are x86_64 only."
    pip3   install --upgrade tensorflow tensorboard tensorboardX cupy-cuda112
fi

if [ "$cpu_arch" = "arm64" ]; then
    echo "These packages are arm only."

fi

pip install git+https://github.com/cliffwoolley/jupyter_tensorboard.git
pip install git+https://github.com/chaoleili/jupyterlab_tensorboard.git
jupyter serverextension enable jupyter_tensorboard --sys-prefix

