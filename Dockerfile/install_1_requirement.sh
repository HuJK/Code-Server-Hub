#!/bin/bash
set -x
set -e
export DEBIAN_FRONTEND=noninteractive
echo "Install & update"
apt-get -y update
apt-get -y install software-properties-common
add-apt-repository universe
apt-get -y update
apt-get -y dist-upgrade
apt-get -y install apt-utils runit locales openssh-server autossh cron vim git sudo rsync nginx-full socat apache2-utils wget curl git ca-certificates python3 python3-pip python3-dev python-setuptools p7zip-full p7zip-rar git-core 

pip3       install --upgrade torch torchaudio tensorflow-gpu tensorboard tensorboardX scipy numpy virtualenv virtualenvwrapper matplotlib torchvision jupyter jupyterlab jupyterhub jupyter_http_over_ws setuptools

wget -qO- https://deb.nodesource.com/setup_12.x | bash
apt-get -y install nodejs
npm install -g configurable-http-proxy
jupyter labextension install jupyterlab_tensorboard
pip3 install jupyter_tensorboard
jupyter serverextension enable jupyter_tensorboard --sys-prefix
apt-get -y autoremove ; apt-get autoclean


git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf ;  ~/.fzf/install
sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --unattended"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
mkdir ~/.virtualenvs
rm -rf /var/lib/apt/lists/* ; localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 ; locale-gen en_US.UTF-8

echo "eval \"\$(thefuck --alias)\"" >> ~/.bashrc
echo "eval \"\$(thefuck --alias)\"" >> ~/.zshrc
echo "thefuck --alias | source" >> /etc/fish/config.fish 

set -x
mkdir -p /etc/code-server-hub/.cshub
cd /etc/code-server-hub
echo "###doenload latest code-server###"
curl -s https://api.github.com/repos/cdr/code-server/releases/latest \
| grep "browser_download_url.*linux-x86_64.tar.gz" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -i - -O code-server.tar.gz
echo "###unzip code-server.tar.gz###"

tar xzvf code-server.tar.gz -C .cshub
mv .cshub/*/* .cshub/
rm -rf /root/.cache
rm -rf /root/.npm/_cacache

set +e

exit 0