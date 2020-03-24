FROM tensorflow/tensorflow:latest-gpu-jupyter

COPY install.sh  /tmp
RUN  chmod 755 /tmp/install.sh ; /tmp/install.sh
COPY move2docker /move2docker
RUN  rsync -a --no-perms --no-owner --no-group --chmod=755 --keep-dirlinks /move2docker/* / ; rm -r /move2docker

ENV EDITOR vim
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/lib64:/usr/local/nvidia/lib:/usr/local/nvidia/lib64

ENTRYPOINT ["/sbin/runit-docker"]

