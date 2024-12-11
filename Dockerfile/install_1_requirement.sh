#!/bin/bash
set -x
set -e
ln -fs /usr/share/zoneinfo/Asia/Taipei /etc/localtime
export DEBIAN_FRONTEND=noninteractive
echo "Install requirement tools"
. /etc/os-release

apt-get -y update
apt-get -y install software-properties-common
add-apt-repository universe
apt-get -y update
apt-get -y dist-upgrade

apt-get -y install apt-utils runit locales cron vim git sudo rsync nginx-full apache2-utils wget curl git ca-certificates python3 python3-pip python3-dev python3-setuptools virtualenv python3-virtualenvwrapper python3-numpy p7zip-full p7zip-rar git-core zsh tmux thefuck libssl-dev libffi-dev build-essential bc



export PIP_BREAK_SYSTEM_PACKAGES=1
case $VERSION_ID in
20.04)
    pip3 install --upgrade  jupyter jupyterlab jupyter_http_over_ws
    ;;
22.04)
    apt-get -y install jupyter python3-jupyterlab-server python3-notebook python3-jupyter-sphinx python3-jupyter-server-mathjax jupyter-nbextension-jupyter-js-widgets python3-alembic python3-async-generator python3-certipy python3-dateutil python3-entrypoints python3-jinja2 python3-jupyter-telemetry python3-oauthlib python3-packaging python3-pamela python3-prometheus-client python3-requests python3-sqlalchemy python3-tornado python3-traitlets python3:any python3-bcrypt python3-notebook libjs-bootstrap libjs-jquery libjs-prototype libjs-requirejs fonts-font-awesome
    pip3  install jupyterlab
    ;;
24.04)
    pip3 install --upgrade  jupyter jupyterlab jupyter_http_over_ws
    ;;
*)
    echo "Unsupported version, update the script"
    exit 255
    ;;
esac
unset PIP_BREAK_SYSTEM_PACKAGES

gcc -shared -std=c99 -Wall -O2 -fPIC -D_POSIX_SOURCE -D_GNU_SOURCE  -Wl,--no-as-needed -ldl -o /lib/runit-docker.so /tmp/runit-docker.c

apt-get -y autoremove ; apt-get autoclean


sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --unattended"
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
mkdir ~/.virtualenvs
rm -rf /var/lib/apt/lists/* ; localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 ; locale-gen en_US.UTF-8

function get_cpu_architecture()
{
    local cpuarch=$(uname -m)
    case $cpuarch in
         x86_64)
              echo "amd64";
              ;;
         aarch64)
              echo "arm64";
              ;;
         *)
              echo "Not supported cpu architecture: ${cpuarch}"  >&2
              exit 1
              ;;
    esac
}
cpu_arch=$(get_cpu_architecture)

echo "###doenload miniconda###"
if [ "$cpu_arch" = "amd64" ]; then
    echo "These packages are x86_64 only."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
fi
if [ "$cpu_arch" = "arm64" ]; then
    echo "These packages are arm only."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O /tmp/miniconda.sh
fi

mkdir -p /opt
chmod 755 /tmp/miniconda.sh
bash /tmp/miniconda.sh -b -p /opt/miniconda

mkdir -p /root/.config/fish/
eval "$(/opt/miniconda/bin/conda shell.bash hook)"
conda activate base
if dpkg --compare-versions "$VERSION_ID" "<=" "20.04"; then
    conda install -y python=3.8
elif dpkg --compare-versions "$VERSION_ID" "<=" "22.04"; then
    conda install -y python=3.10
fi
conda install ipykernel
ipython kernel install --user --name=base
conda install -c conda-forge nodejs=20.6.1
npm install -g ijavascript
ijsinstall --spec-path=full

echo "###doenload latest code-server###"
mkdir -p /etc/code-server-hub/.cshub
cd /etc/code-server-hub
curl -L -s https://api.github.com/repos/cdr/code-server/releases/latest \
| grep "browser_download_url.*linux-${cpu_arch}.tar.gz" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -i - -O code-server.tar.gz

echo "###unzip code-server.tar.gz###"
tar xzvf code-server.tar.gz -C .cshub
mv .cshub/*/* .cshub/
rm -rf /root/.cache
rm -rf /root/.npm/_cacache

ls /etc/code-server-hub/.cshub
chmod -R 775 /opt/miniconda
chmod -R 775 /etc/code-server-hub/.cshub
rm -r /root/.cache || true

echo "###disable lastlog###"
cd /var/log
for file in lastlog faillog; do
  unlink $file
  ln -s /dev/null $file
done

exit 0
