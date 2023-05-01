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
export NODE_OPTIONS=--openssl-legacy-provider

cpu_arch=$(get_cpu_architecture)
apt update 
ln -s cuda /usr/local/nvidia
apt-get install ffmpeg libsm6 libxext6  -y

case $CUDA_VERSION in
11.2)
    pip3 install --upgrade cupy-cuda11x
    ;;
11.8)
    pip3 install --upgrade cupy-cuda11x
    ;;
*)
    echo "Unsupported version, update the script"
    exit 255
    ;;
esac

if [ "$cpu_arch" = "amd64" ]; then
    echo "These packages are x86_64 only."
    pip3 install onnxruntime-gpu
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
    case $CUDA_VERSION in
    11.2)
        pip3 install torch==1.12.1+cu102 torchaudio==0.12.1+cu102 torchvision==0.13.1+cu102 -f https://download.pytorch.org/whl/torch_stable.html
        ;;
    11.8)
        pip3 install torch==2.0.0+cu118 torchaudio==2.0.1+cu118 torchvision==0.15.1+cu118 -f https://download.pytorch.org/whl/torch_stable.html
        pip3 install nvidia-tensorrt
        ;;
    *)
        echo "Unsupported version, update the script"
        exit 255
        ;;
    esac
fi

if [ "$cpu_arch" = "arm64" ]; then
    echo "These packages are arm only."
    pip3 install onnxruntime
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O /tmp/miniconda.sh
    case $CUDA_VERSION in
    11.2)
        pip3 install torch==1.12.1 torchaudio==0.12.1 torchvision==0.13.1 -f https://download.pytorch.org/whl/torch_stable.html
        ;;
    11.8)
        pip3 install torch torchaudio torchvision -f https://download.pytorch.org/whl/torch_stable.html
        ;;
    *)
        echo "Unsupported version, update the script"
        exit 255
        ;;
    esac
fi

pip3 install --upgrade keras mxnet opencv-python librosa tensorflow tensorboard tensorboardX imbalanced-learn streamlit fastapi uvicorn seaborn yellowbrick nltk

chmod 755 /tmp/miniconda.sh
bash /tmp/miniconda.sh -b -p $HOME/.miniconda

echo "eval \"\$(/root/.miniconda/bin/conda shell.bash hook)\"" >> /root/.bashrc
echo "eval \"\$(/root/.miniconda/bin/conda shell.zsh hook)\"" >> /root/.zshrc
echo "eval \"(/root/.miniconda/bin/conda shell.fish hook)\"" >> /root/.config/fish/config.fish

pip3 install jupyter-tensorboard
jupyter serverextension enable jupyter_tensorboard --sys-prefix

