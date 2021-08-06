# code-server-hub-docker

These dockerfiles are for Code Server docker version.

I use some feature from BuildKit, so prepare buildx first

```bash
# make your computer able to rum arm64 binary
docker run --rm --privileged docker/binfmt:820fdd95a9972a5308930a2bdfb8573dd4447ad3
# enable expremental feature
export DOCKER_CLI_EXPERIMENTAL=enabled
export DOCKER_BUILDKIT=1
docker buildx create --name mybuilder --driver docker-container
docker buildx use mybuilder
```

### CPU version (amd64/arm64)
minimal version (1.5GB)
```bash
docker buildx build --platform linux/arm64,linux/amd64 -t whojk/code-server-hub-docker:minimal -f ./Dockerfile_1_minimal . --push
```

standerd version (4GB)
```bash
docker buildx build --platform linux/arm64,linux/amd64 -t whojk/code-server-hub-docker:standard -f ./Dockerfile_2_standard . --push
```

### GPU version (amd64)
standerd version with essential machine learning packages (11GB)
```bash
docker buildx build --platform linux/arm64,linux/amd64 -t whojk/code-server-hub-docker:basicML -f ./Dockerfile_3_basicML . --push
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
