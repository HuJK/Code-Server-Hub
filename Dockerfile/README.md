# code-server-hub-docker

This dockerfile is for Code Server docker version.

There are two main version, you can build it with following command:

standerd version with essential machine learning packages (13GB)
```bash
docker build -t whojk/code-server-hub-docker:minimal -f ./Dockerfile_3_basicML .
```

minimal version (1.5GB)
```bash
docker build -t whojk/code-server-hub-docker:minimal -f ./Dockerfile_1_minimal .
```

