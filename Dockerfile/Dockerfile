FROM nvidia/cuda

COPY install.sh /tmp/
RUN  chmod 755 /tmp/install.sh ; /tmp/install.sh
COPY move2docker /move2docker
RUN  rsync -a --no-perms --no-owner --no-group --chmod=755 --keep-dirlinks /move2docker/* / ;/tmp/install2.sh; rm -r /move2docker

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV NVIDIA_DRIVER_CAPABILITIES all
ENV MKL_DEBUG_CPU_TYPE 5

ENTRYPOINT ["/sbin/runit-docker"]

