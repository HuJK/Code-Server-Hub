#!/bin/bash
set -e
#echo "###update phase###"
apt-get update
#apt-get upgrade -y
echo "###install dependanse phase###"
echo "Install dependances"
apt-get install -y nginx-extras ca-certificates socat rsync fish build-essential shellcheck apt-utils gdb
apt-get install -y tmux libncurses-dev htop nodejs npm wget sudo curl vim openssl git
apt-get install -y python3 python3-pip python3-dev p7zip-full 
pip3 install jupyterlab speedtest-cli pylint
exit 0
