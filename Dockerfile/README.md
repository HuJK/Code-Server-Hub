# code-server-hub-docker

This dockerfile is for Code Server docker version.

There are two main version, you can build it with following command:

standerd version (13GB)
```bash
cp runit-docker/runit-docker.so.$(uname -m) move2docker/lib/runit-docker.so
docker build -t whojk/code-server-hub-docker .
```

minimal version (1.5GB)
```bash
cp runit-docker/runit-docker.so.$(uname -m) move2docker/lib/runit-docker.so
docker build -t whojk/code-server-hub-docker:minimal -f ./Dockerfile_minimal .
```

minimal version only contain minimal requirement for Code Server docker version, and standerd version contains some common ML framework.