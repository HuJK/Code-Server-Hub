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

apt-get -y install apt-utils runit locales cron vim git sudo rsync nginx-full apache2-utils wget curl git ca-certificates python3 python3-pip python3-dev python3-setuptools virtualenv python3-virtualenvwrapper python3-numpy p7zip-full p7zip-rar git-core zsh tmux libssl-dev libffi-dev build-essential bc



export PIP_BREAK_SYSTEM_PACKAGES=1
case $VERSION_ID in
20.04)
    pip3 install --upgrade  jupyter jupyterlab jupyter_http_over_ws thefuck
    ;;
22.04)
    apt-get -y install jupyter python3-jupyterlab-server python3-notebook python3-jupyter-sphinx python3-jupyter-server-mathjax jupyter-nbextension-jupyter-js-widgets python3-alembic python3-async-generator python3-certipy python3-dateutil python3-entrypoints python3-jinja2 python3-jupyter-telemetry python3-oauthlib python3-packaging python3-pamela python3-prometheus-client python3-requests python3-sqlalchemy python3-tornado python3-traitlets python3:any python3-bcrypt python3-notebook libjs-bootstrap libjs-jquery libjs-prototype libjs-requirejs fonts-font-awesome thefuck
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
mkdir -p /root/.config/fish/

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


## Installing miniconda with same version of the system python version
case $VERSION_ID in
    "20.04") CONDA_VER="py38"  ;;
    "22.04") CONDA_VER="py310" ;;
    "24.04") CONDA_VER="py312" ;;
    *)  
        echo "Unsupported OS version: $VERSION_ID. Update the script."
        exit 255
        ;;
esac

case $CPU_ARCH in
    "amd64") CONDA_ARCH="Linux-x86_64"  ;;
    "arm64") CONDA_ARCH="Linux-aarch64" ;;
    *)
        echo "Unsupported CPU architecture: $CPU_ARCH"
        exit 1
        ;;
esac

# Base Miniconda URL
BASE_URL="https://repo.anaconda.com/miniconda/"
# Fetch the Miniconda archive page

set +x
ARCHIVE_PAGE=$(curl -s "$BASE_URL")
# Extract all matching Miniconda versions
LATEST_VERSION=$(echo "$ARCHIVE_PAGE" | grep -oP "Miniconda3-${CONDA_VER}[^>]*-${CONDA_ARCH}\\.sh" | sort -V | tail -n 1)
# Check if a valid version was found
if [[ -z "$LATEST_VERSION" ]]; then
    echo "Error: No matching Miniconda version found for $CONDA_VER on $CONDA_ARCH."
    exit 1
fi
# Construct the Miniconda download URL
MINICONDA_URL="${BASE_URL}${LATEST_VERSION}"

# Download Miniconda installer
echo "Downloading latest Miniconda: $MINICONDA_URL"
echo wget "$MINICONDA_URL" -O /tmp/miniconda.sh
wget "$MINICONDA_URL" -O /tmp/miniconda.sh
set -x

mkdir -p /opt
chmod 755 /tmp/miniconda.sh
bash /tmp/miniconda.sh -b -p /opt/miniconda


set +x
eval "$(/opt/miniconda/bin/conda shell.bash hook)"
conda activate base
set -x

conda install ipykernel
ipython kernel install --user --name=base
conda install -c conda-forge nodejs=20.6.1
npm install -g ijavascript
ijsinstall --spec-path=full

echo "###doenload latest code-server###"
mkdir -p /etc/code-server-hub/.cshub
cd /etc/code-server-hub
curl -L -s https://api.github.com/repos/cdr/code-server/releases/latest \
| grep "browser_download_url.*linux-${CPU_ARCH}.tar.gz" \
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
