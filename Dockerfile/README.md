# code-server-hub-docker

These dockerfiles are for Code Server docker version.

### CPU version (amd64/arm64)
minimal version (1.5GB)
```bash
docker build -t whojk/code-server-hub-docker:minimal -f ./Dockerfile_1_minimal .
```

standerd version (4GB)
```bash
docker build -t whojk/code-server-hub-docker:standerd -f ./Dockerfile_2_standard .
```

### GPU version (amd64)
standerd version with essential machine learning packages (11GB)
```bash
docker build -t whojk/code-server-hub-docker:basicML -f ./Dockerfile_3_basicML .
```

You can build it by your self.


## Usage
When you start container, [this script](https://github.com/HuJK/Code-Server-Hub/blob/master/util/create_docker.py) will check whether you can run nvidia-docker by following code:

```python
image_name_cpu = "whojk/code-server-hub-docker:minimal"
image_name_gpu = "whojk/code-server-hub-docker:basicML"
```
```python3
has_gpu = []
image_name = image_name_cpu
outs, errs = subprocess.Popen(["docker run --rm --gpus all nvidia/cuda:10.2-base nvidia-smi"], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
if len(outs) > 0:
    has_gpu = ["--gpus", getGPUParam(username)]
    image_name = image_name_gpu
```
and run corresponding image.
