#!/bin/bash
set -x
set -e
export DEBIAN_FRONTEND=noninteractive
echo "Install additional tools"

apt-get -y update

apt-get -y install fish htop aria2 lsof tree ncdu golang default-jdk atop duplicity emacs gawk gnupg2 lftp libsqlite3-dev libssl-dev libtool mc mtr netcat parallel screen silversearcher-ag sl sqlite3 tig vifm wyrd zlib1g-dev zlib1g-dev openssh-server autossh socat libopenblas-dev liblapack-dev gfortran cmake convmv
apt-get -y autoremove ; apt-get autoclean

pip3       install --upgrade tornado tqdm sympy galgebra pandas plotly nose pillow pyparsing scikit-image scikit-learn scipy matplotlib              

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf ;  ~/.fzf/install
echo "thefuck --alias | source" >> /etc/fish/config.fish 

rm -rf /var/lib/apt/lists/* ; localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 ; locale-gen en_US.UTF-8
