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
apt-get -y install apt-utils runit locales openssh-server autossh cron vim git sudo rsync nginx-full socat apache2-utils
apt-get -y install fish zsh tmux htop thefuck wget curl aria2 lsof tree ncdu \ 
                   golang default-jdk python-pip python-setuptools python3 python3-pip python3-dev build-essential g++ gcc p7zip-full p7zip-rar \ 
                   atop autoconf duplicity emacs gawk git-core gnupg2 lftp libsqlite3-dev libssl-dev libtool \ 
                   mc mtr netcat nikto parallel pgadmin3 postgresql screen searchandrescue siege silversearcher-ag \ 
                   sl sqlite3 tig vifm wyrd zlib1g-dev zlib1g-dev
pip3       install --upgrade tornado flask django torch torchvision jupyterlab jupyterhub jupyter_http_over_ws
wget -qO- https://deb.nodesource.com/setup_12.x | bash
apt-get -y install nodejs
npm install -g configurable-http-proxy

apt-get -y autoremove ; apt-get autoclean
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf ;  ~/.fzf/install
sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --unattended"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
rm -rf /var/lib/apt/lists/* ; localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 ; locale-gen en_US.UTF-8

mkdir /etc/code-server-hub/.cshub
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

echo "eval \"\$(thefuck --alias)\"" >> ~/.bashrc
echo "eval \"\$(thefuck --alias)\"" >> ~/.zshrc
echo "thefuck --alias | source" >> /etc/fish/config.fish 

#delete self
rm /tmp/install.sh

set +e
exit 0
