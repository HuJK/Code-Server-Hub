# code-server-hub-docker

These dockerfiles are for Code Server docker version.
It will automatically pull my image if you use my install script. If you don't want to use mine, you can build it by you self.

I use some feature from BuildKit, so prepare buildx first

```bash
# make your computer able to rum arm64 binary
docker run --rm --privileged docker/binfmt:820fdd95a9972a5308930a2bdfb8573dd4447ad3
# enable expremental feature
export DOCKER_CLI_EXPERIMENTAL=enabled
export DOCKER_BUILDKIT=1
docker buildx create --name mybuilder --driver docker-container
docker buildx use mybuilder

# setup cpu arch function
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
```

### CPU version
minimal version (1.5GB)
```bash
docker buildx build --platform linux/$cpu_arch -t whojk/code-server-hub-docker:minimal -f ./Dockerfile_1_minimal . --output="type=docker"

```

standerd version (4GB)
```bash
docker buildx build --platform linux/$cpu_arch -t whojk/code-server-hub-docker:standard -f ./Dockerfile_2_standard . --output="type=docker"
```

### GPU version
Requirement: nvidia driver 460+

standerd version with essential machine learning packages (11GB)
```bash
docker buildx build --platform linux/$cpu_arch -t whojk/code-server-hub-docker:basicML -f ./Dockerfile_3_basicML . --output="type=docker"
```

You can build it by your self.

#### Build all and upload to registry
```
docker buildx build --platform linux/arm64,linux/amd64 -t whojk/code-server-hub-docker:minimal -f ./Dockerfile_1_minimal . --push
docker buildx build --platform linux/arm64,linux/amd64 -t whojk/code-server-hub-docker:standard -f ./Dockerfile_2_standard . --push
docker buildx build --platform linux/arm64,linux/amd64 -t whojk/code-server-hub-docker:basicML -f ./Dockerfile_3_basicML . --push
```

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
