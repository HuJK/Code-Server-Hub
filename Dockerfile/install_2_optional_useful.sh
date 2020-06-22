apt-get -y update

apt-get -y install fish zsh tmux htop thefuck aria2 lsof tree ncdu golang default-jdk \
                   atop duplicity emacs gawk gnupg2 lftp libsqlite3-dev libssl-dev libtool \
                   mc mtr netcat parallel screen silversearcher-ag \
                   sl sqlite3 tig vifm wyrd zlib1g-dev zlib1g-dev
apt-get -y autoremove ; apt-get autoclean

pip3       install --upgrade tornado tqdm opencv-python sympy galgebra librosa mxnet pandas plotly nose pillow pyparsing  ninja

rm -rf /var/lib/apt/lists/* ; localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 ; locale-gen en_US.UTF-8
