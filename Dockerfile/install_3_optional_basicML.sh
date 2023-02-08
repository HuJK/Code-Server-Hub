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
apt update 
ln -s cuda /usr/local/nvidia
apt-get install ffmpeg libsm6 libxext6  -y
pip3 install --upgrade keras mxnet opencv-python librosa tensorboard tensorboardX imbalanced-learn
pip3 install torch==1.11.0+cu113 torchvision==0.12.0+cu113 torchaudio==0.11.0+cu113 -f https://download.pytorch.org/whl/torch_stable.html
export NODE_OPTIONS=--openssl-legacy-provider
if [ "$cpu_arch" = "amd64" ]; then
    echo "These packages are x86_64 only."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
    pip3   install --upgrade tensorflow cupy-cuda113
fi

if [ "$cpu_arch" = "arm64" ]; then
    echo "These packages are arm only."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-armv7l.sh -O /tmp/miniconda.sh
fi

chmod 755 /tmp/miniconda.sh
bash /tmp/miniconda.sh -b -p $HOME/.miniconda

echo "eval \"\$(/root/.miniconda/bin/conda shell.bash hook)\"" >> /root/.bashrc
echo "eval \"\$(/root/.miniconda/bin/conda shell.zsh hook)\"" >> /root/.zshrc
echo "eval \"(/root/.miniconda/bin/conda shell.fish hook)\"" >> /root/.config/fish/config.fish

pip3 install jupyter-tensorboard
jupyter serverextension enable jupyter_tensorboard --sys-prefix

