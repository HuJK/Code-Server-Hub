#!/bin/bash
set -e
#echo "###update phase###"
apt-get update
#apt-get upgrade -y
echo "###install dependanse phase###"
echo "Install dependances"
apt-get install -y nginx-extras ca-certificates socat rsync fish build-essential shellcheck apt-utils gdb
apt-get install -y tmux libncurses-dev htop wget sudo curl vim openssl git
apt-get install -y python3 python3-pip python3-dev python-setuptools p7zip-full p7zip-rar
apt-get install -y apt-utils runit locales cron vim git sudo rsync nginx-full apache2-utils wget curl git ca-certificates  git-core zsh tmux thefuck libssl-dev libffi-dev build-essential
pip3 install jupyterlab speedtest-cli pylint
exit 0
