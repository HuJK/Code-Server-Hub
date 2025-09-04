#!/bin/bash
set -x
set -e
export DEBIAN_FRONTEND=noninteractive
. /etc/os-release

function get_cpu_architecture() {
    local cpuarch=$(uname -m)
    case $cpuarch in
         x86_64)  echo "amd64" ;;
         aarch64) echo "arm64" ;;
         *) 
              echo "Not supported CPU architecture: ${cpuarch}" >&2
              exit 1
              ;;
    esac
}
CPU_ARCH=$(get_cpu_architecture)

apt update 
ln -s cuda /usr/local/nvidia
apt-get install ffmpeg libsm6 libxext6 libhdf5-dev pipx -y

eval "$(/opt/miniconda/bin/conda shell.bash hook)"
conda activate base
pipx install uv

case $CUDA_VERSION in
11.2)
    pip3 install --upgrade cupy-cuda11x
    ;;
11.8)
    pip3 install --upgrade cupy-cuda11x
    ;;
12.6)
    pip3 install --upgrade cupy-cuda12x
    ;;
*)
    echo "Unsupported version, update the script"
    exit 255
    ;;
esac


if [ "$CPU_ARCH" = "amd64" ]; then
    echo "These packages are x86_64 only."
    pip3 install onnxruntime-gpu

    case $CUDA_VERSION in
    11.2)
        pip3 install torch==1.12.0+cu102 torchaudio==0.12.0+cu102 torchvision==0.13.0+cu102 -f https://download.pytorch.org/whl/torch_stable.html
        pip3 install --upgrade aqlm
        ;;
    11.8)
        pip3 install torch==2.2.2+cu118 torchaudio==2.2.2+cu118 torchvision==0.17.2+cu118 -f https://download.pytorch.org/whl/torch_stable.html
        pip3 install nvidia-tensorrt bitsandbytes
        pip3 install --upgrade aqlm[gpu,cpu] # aqlm GPU requires python >= 3.9, not available at ubuntu 20.04
        ;;
    12.6)
        pip3 install torch==2.3.1+cu121 torchaudio==2.3.1+cu121 torchvision==0.18.1+cu121 -f https://download.pytorch.org/whl/torch_stable.html
        pip3 install nvidia-tensorrt bitsandbytes
        pip3 install --upgrade aqlm[gpu,cpu] # aqlm GPU requires python >= 3.9, not available at ubuntu 20.04
        ;;
    *)
        echo "Unsupported version, update the script"
        exit 255
        ;;
    esac
fi

if [ "$CPU_ARCH" = "arm64" ]; then
    echo "These packages are arm only."
    case $CUDA_VERSION in
    11.2)
        pip3 install torch==1.12.0 torchaudio==0.12.0 torchvision==0.13.0 -f https://download.pytorch.org/whl/torch_stable.html
        ;;
    11.8)
        pip3 install torch torchaudio torchvision -f https://download.pytorch.org/whl/torch_stable.html
        ;;
    12.6)
        pip3 install torch torchaudio torchvision -f https://download.pytorch.org/whl/torch_stable.html
        ;;
    *)
        echo "Unsupported version, update the script"
        exit 255
        ;;
    esac
    pip3 install onnxruntime
    pip3 install --upgrade aqlm
fi

pip3 install --upgrade keras mxnet opencv-python librosa tensorflow tensorboard tensorboardX imbalanced-learn streamlit seaborn yellowbrick nltk gradio chromadb accelerate
pip3 install --upgrade torchdiffeq torchsde transformers safetensors tomesd pytorch-lightning einops inflection kornia langchain
pip3 install --upgrade sentencepiece tiktoken einops optimum wandb

curl -fsSL https://ollama.com/install.sh | sh

#pip3 install jupyterlab-tensorboard-pro
#jupyter serverextension enable jupyter_tensorboard --sys-prefix

chmod -R 775 /opt/miniconda
rm -r /root/.cache || true

