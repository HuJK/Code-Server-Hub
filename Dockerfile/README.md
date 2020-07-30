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
When you start container, the script will check whether you can run nvidia-docker by following code:
https://github.com/HuJK/Code-Server-Hub/blob/f60d025752bafa863cc98c36eb2158bdc3b4701f/util/create_docker.py#L7-L8
https://github.com/HuJK/Code-Server-Hub/blob/f60d025752bafa863cc98c36eb2158bdc3b4701f/util/create_docker.py#L51-L54

and run corresponding image.