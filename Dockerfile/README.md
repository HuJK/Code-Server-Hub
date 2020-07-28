# code-server-hub-docker

These dockerfiles are for Code Server docker version.

There are two main version for CPU only machine, you can build it with following command(amd64 and arm64):

minimal version (1.5GB)
```bash
docker build -t whojk/code-server-hub-docker:minimal -f ./Dockerfile_1_minimal .
```

standerd version (10GB)
```bash
docker build -t whojk/code-server-hub-docker:standerd -f ./Dockerfile_2_standard .
```

If you have nvidia/cuda support machine, you can build it with (amd64 only):

standerd version with essential machine learning packages (11GB)
```bash
docker build -t whojk/code-server-hub-docker:basicML -f ./Dockerfile_3_basicML .
```
