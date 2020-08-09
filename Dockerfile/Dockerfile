# syntax = docker/dockerfile:experimental
FROM ubuntu
RUN apt-get update; apt-get install -y wget

ENV EDITOR vim
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive

COPY           install_1_requirement.sh /tmp/
RUN  bash /tmp/install_1_requirement.sh

COPY           install_2_optional_useful.sh /tmp/
RUN  bash /tmp/install_2_optional_useful.sh

COPY install.sh /tmp/
RUN  bash /tmp/install.sh
COPY install2.sh /tmp/
RUN  bash /tmp/install2.sh
RUN echo "" > /etc/nginx/sites-available/default
RUN  --mount=type=bind,source=move2docker,target=/tmp/move2docker  rsync -a --no-perms --no-owner --no-group --chmod=755 --keep-dirlinks /tmp/move2docker/* / ;
RUN echo "root:DockerAtHeroku" | chpasswd

ENTRYPOINT ["/bin/bash", "/etc/rc.local"]
