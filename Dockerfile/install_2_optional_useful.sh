#!/bin/bash
set -x
set -e
rm /etc/localtime
ln -fs /usr/share/zoneinfo/Asia/Taipei /etc/localtime
export DEBIAN_FRONTEND=noninteractive
echo "Install additional tools"
. /etc/os-release

add-apt-repository ppa:longsleep/golang-backports
apt-get -y update
case $VERSION_ID in
20.04)
    apt-get -y install openjdk-17-jdk-headless
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash
    apt-get install -y speedtest
    ;;
22.04)
    apt-get -y install openjdk-19-jdk-headless
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash
    apt-get install -y speedtest
    ;;
24.04)
    apt-get -y install openjdk-21-jdk-headless
    # speedtest-cli not available at ubuntu 24.04
    #curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash
    ;;
*)
    echo "Unsupported version, update the script"
    exit 255
    ;;
esac

function get_cpu_architecture() {
    local cpuarch=$(uname -m)
    case $cpuarch in
         x86_64)  echo "amd64" ;;
         aarch64) echo "arm64" ;;
         *) 
              echo "Not supported CPU architecture: ${cpuarch}" >&2
              exit 1
              ;;
    esac
}
CPU_ARCH=$(get_cpu_architecture)



apt-get -y install fish htop aria2 lsof tree ncdu golang-go atop duplicity emacs gawk gnupg2 lftp libsqlite3-dev libssl-dev libtool mc mtr-tiny iputils-ping netcat-openbsd parallel screen silversearcher-ag sl sqlite3 tig vifm wyrd zlib1g-dev zlib1g-dev openssh-server autossh socat libopenblas-dev liblapack-dev gfortran cmake convmv llvm
apt-get -y autoremove ; apt-get autoclean 

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf ;  ~/.fzf/install

case $VERSION_ID in
20.04)
    echo "thefuck --alias | source" >> /etc/fish/config.fish
    ;;
22.04)
    echo "thefuck --alias | source" >> /etc/fish/config.fish
    ;;
24.04)
    echo "thefuck doesn't support 24.04, skip"
    ;;
*)
    echo "Unsupported version, update the script"
    exit 255
    ;;
esac

eval "$(/opt/miniconda/bin/conda shell.bash hook)"
conda activate base
pip3 install --upgrade tornado tqdm sympy galgebra pandas plotly nose pillow pyparsing scikit-image scikit-learn scipy matplotlib fastapi uvicorn omegaconf requests protobuf pytest pyyaml colorama datasets jinja2 markdown psutil rich

chmod -R 775 /opt/miniconda
rm -rf /var/lib/apt/lists/* ; localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 ; locale-gen en_US.UTF-8
rm -r /root/.cache || true
