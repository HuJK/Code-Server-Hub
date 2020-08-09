#!/bin/bash
set -x
set -e
export DEBIAN_FRONTEND=noninteractive
echo "Install requirement tools"
apt-get -y update
apt-get -y install software-properties-common
add-apt-repository universe
apt-get -y update
apt-get -y dist-upgrade
apt-get -y install apt-utils runit locales cron vim git sudo rsync nginx-full apache2-utils wget curl git ca-certificates python3 python3-pip python3-dev python-setuptools p7zip-full p7zip-rar git-core zsh tmux thefuck libssl-dev libffi-dev build-essential

python3 -m pip install --upgrade pip
pip3       install --upgrade  jupyter jupyterlab jupyterhub jupyter_http_over_ws setuptools virtualenv virtualenvwrapper numpy

wget -qO- https://deb.nodesource.com/setup_12.x | bash
apt-get -y install nodejs
npm install -g configurable-http-proxy
apt-get -y autoremove ; apt-get autoclean


sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --unattended"
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth 1 git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
mkdir ~/.virtualenvs
rm -rf /var/lib/apt/lists/* ; localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 ; locale-gen en_US.UTF-8

exit 0