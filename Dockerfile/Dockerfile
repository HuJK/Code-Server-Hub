FROM ubuntu
RUN apt-get update; apt-get install -y wget
RUN echo "root:DockerATheroku!" | chpasswd

ENV EDITOR vim
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive

COPY install.sh /tmp/
RUN  bash /tmp/install.sh
COPY install2.sh /tmp/
RUN  bash /tmp/install2.sh
RUN echo "" > /etc/nginx/sites-available/default
COPY move2docker /tmp/move2docker
RUN  rsync -a --no-perms --no-owner --no-group --chmod=755 --keep-dirlinks /tmp/move2docker/* / ;rm -r /tmp/*
#RUN --mount=type=secret,id=move2docker,dst=/tmp/move2docker rsync -a --no-perms --no-owner --no-group --chmod=755 --keep-dirlinks /tmp/move2docker/* /
#RUN  --mount=type=bind,source=./move2docker,target=/tmp/move2docker rsync -a --no-perms --no-owner --no-group --chmod=755 --keep-dirlinks /tmp/move2docker/* /

ENTRYPOINT ["/bin/bash", "/etc/rc.local"]
