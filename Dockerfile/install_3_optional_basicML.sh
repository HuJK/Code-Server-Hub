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
12.8)
    pip3 install --upgrade cupy-cuda12x
    ;;
*)
    echo "Unsupported version, update the script"
    exit 255
    ;;
esac


if [ "$CPU_ARCH" = "amd64" ]; then
    echo "These packages are x86_64 only."
    pip3 install onnxruntime-gpu ninja

    case $CUDA_VERSION in
    11.2)
        pip3 install torch==1.12.0+cu102 torchaudio==0.12.0+cu102 torchvision==0.13.0+cu102 -f https://download.pytorch.org/whl/torch_stable.html
        pip3 install --upgrade aqlm
        ;;
    11.8)
        pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
        pip3 install nvidia-tensorrt bitsandbytes
        pip3 install --upgrade aqlm[gpu,cpu]
        ;;
    12.6)
        pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
        pip3 install nvidia-tensorrt bitsandbytes
        pip3 install --upgrade aqlm[gpu,cpu]
        uv pip install vllm --torch-backend=cu126 --system
        pip3 install flash-attn --no-build-isolation
        ;;
    12.8)
        pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128
        pip3 install nvidia-tensorrt bitsandbytes
        pip3 install --upgrade aqlm[gpu,cpu]
        pip3 install vllm
        uv pip install vllm --torch-backend=cu128 --system
        pip3 install flash-attn --no-build-isolation
        ;;
    *)
        echo "Unsupported version, update the script"
        exit 255
        ;;
    esac
fi

if [ "$CPU_ARCH" = "arm64" ]; then
    echo "These packages are arm only."
    pip3 install ninja

    case $CUDA_VERSION in
    11.2)
        pip3 install torch==1.12.0 torchaudio==0.12.0 torchvision==0.13.0 -f https://download.pytorch.org/whl/torch_stable.html
        ;;
    11.8)
        pip3 install torch torchaudio torchvision --index-url https://download.pytorch.org/whl/cu118
        ;;
    12.6)
        pip3 install torch torchaudio torchvision --index-url https://download.pytorch.org/whl/cu126
        ;;
    12.8)
        pip3 install torch torchaudio torchvision --index-url https://download.pytorch.org/whl/cu128
        ;;
    *)
        echo "Unsupported version, update the script"
        exit 255
        ;;
    esac
    pip3 install onnxruntime
    pip3 install --upgrade aqlm
fi

pip3 install --upgrade keras mxnet opencv-python librosa tensorflow tensorboard tensorboardX imbalanced-learn streamlit seaborn yellowbrick nltk gradio chromadb accelerate peft PyPDF2
pip3 install --upgrade torchdiffeq torchsde transformers safetensors tomesd pytorch-lightning einops inflection kornia langchain tqdm scikit-learn openai
pip3 install --upgrade sentencepiece tiktoken einops optimum wandb

curl -fsSL https://ollama.com/install.sh | sh

#pip3 install jupyterlab-tensorboard-pro
#jupyter serverextension enable jupyter_tensorboard --sys-prefix

chmod -R 775 /opt/miniconda
rm -r /root/.cache || true

