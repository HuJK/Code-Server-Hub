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
aria2c  -x 16 -j 16  "https://ollama.com/download/ollama-linux-$cpu_arch" -d / -o /usr/bin/ollama
chmod 755 /usr/bin/ollama
eval "$(/opt/miniconda/bin/conda shell.bash hook)"
conda activate base

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
    pip3 install --upgrade triton aqlm[gpu,cpu]
    case $CUDA_VERSION in
    11.2)
        pip3 install torch==1.12.0+cu102 torchaudio==0.12.0+cu102 torchvision==0.13.0+cu102 -f https://download.pytorch.org/whl/torch_stable.html
        ;;
    11.8)
        pip3 install torch==2.0.1+cu118 torchaudio==2.0.2+cu118 torchvision==0.15.2+cu118 -f https://download.pytorch.org/whl/torch_stable.html
        pip3 install nvidia-tensorrt bitsandbytes
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
    pip3 install --upgrade aqlm
    case $CUDA_VERSION in
    11.2)
        pip3 install torch==1.12.0 torchaudio==0.12.0 torchvision==0.13.0 -f https://download.pytorch.org/whl/torch_stable.html
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

pip3 install --upgrade keras mxnet opencv-python librosa tensorflow tensorboard tensorboardX imbalanced-learn streamlit seaborn yellowbrick nltk gradio chromadb accelerate
pip3 install --upgrade torchdiffeq torchsde transformers safetensors tomesd pytorch-lightning einops inflection kornia langchain
pip3 install --upgrade sentencepiece tiktoken einops optimum wandb

#pip3 install jupyterlab-tensorboard-pro
#jupyter serverextension enable jupyter_tensorboard --sys-prefix

chmod -R 775 /opt/miniconda
rm -r /root/.cache || true

