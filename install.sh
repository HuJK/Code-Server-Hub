#!/bin/bash


HOMEPGE="NO"
HOMEPGE_SSL="NO"
LIBPWQUALITY="ASK"
SERVERSTAT="ASK"
JUPYTERHUB="ASK"
JUPYTERHUB_PIP3="ASK"
COCKPIT="ASK"
ROOTLESS_DOCKER="ASK"
DOCKER="ASK"
DOCKER_INSTALL="ASK"
DOCKER_NVIDIA="ASK"
DOCKER_PORTAINER="ASK"
DOCKER_IMAGE="standard"

for i in "$@"
do
case $i in
    -hp=*|--homepage=*)
    HOMEPGE="${i#*=}"
    shift # past argument=value
    ;;
    -hps=*|--homepage-ssl=*)
    HOMEPGE_SSL="${i#*=}"
    shift # past argument=value
    ;;
    -pq=*|--pwquality=*)
    LIBPWQUALITY="${i#*=}"
    shift # past argument=value
    ;;
    -st=*|--server-stat=*)
    SERVERSTAT="${i#*=}"
    shift # past argument=value
    ;;
    -jph=*|--jupyterhub=*)
    JUPYTERHUB="${i#*=}"
    shift # past argument=value
    ;;
    -pip3=*|--jupyterhub-pip3=*)
    JUPYTERHUB_PIP3="${i#*=}"
    shift # past argument=value
    ;;
    -c=*|--cockpit=*)
    COCKPIT="${i#*=}"
    shift # past argument=value
    ;;
    -rd=*|--rootless-docker=*)
    ROOTLESS_DOCKER="${i#*=}"
    shift # past argument=value
    ;;
    -d=*|--docker=*)
    DOCKER="${i#*=}"
    shift # past argument=value
    ;;
    -de=*|--docker-engine-install=*)
    DOCKER_INSTALL="${i#*=}"
    shift # past argument=value
    ;;
    -dn=*|--docker-nvidia=*)
    DOCKER_NVIDIA="${i#*=}"
    shift # past argument=value
    ;;
    -dp=*|--docker-portainer=*)
    DOCKER_PORTAINER="${i#*=}"
    shift # past argument=value
    ;;
    -di=*|--docker-image=*)
    DOCKER_IMAGE="${i#*=}"
    shift # past argument=value
    ;;
    *)
    ;;
esac
done

echo "Install homepage             = ${HOMEPGE}"
echo "Enable SSL for homepage      = ${HOMEPGE_SSL}"
echo "Install libpam-pwquality     = ${LIBPWQUALITY}"
echo "Install serverstat_backend   = ${SERVERSTAT}"
echo "Install jupyterhub           = ${JUPYTERHUB}"
echo "Install pip3 for jupyterhub  = ${JUPYTERHUB_PIP3}"
echo "Install cockpit              = ${COCKPIT}"
echo "Install docker version       = ${DOCKER}"
echo "Install rootless docker      = ${ROOTLESS_DOCKER}"
echo "Install docker               = ${DOCKER_INSTALL}"
echo "Install nvidia-docker        = ${DOCKER_NVIDIA}"
echo "Install portainer            = ${DOCKER_PORTAINER}"
echo "Docker image for code-server = ${DOCKER_IMAGE}"

sleep 5

set -e
#echo "###update phase###"
apt-get update
#apt-get upgrade -y
echo "###install dependanse phase###"
echo "Install dependances"
apt-get install -y nginx ca-certificates socat jq coreutils
apt-get install -y tmux libncurses-dev htop wget sudo curl vim openssl git libpcre3-dev libssl-dev perl make build-essential curl libpam0g-dev jq
apt-get install -y python3 python3-pip python3-dev p7zip-full libffi-dev nodejs
set +e # folling command only have one will success
#cockpit for user management
if ! command -v npm &> /dev/null
then
    echo "npm could not be found, installing npm"
    apt-get install -y npm
fi


set -e

function get_cpu_architecture()
{
    local cpuarch;
    cpuarch=$(uname -m)
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

if [ -f /etc/os-release ]; then
    . /etc/os-release
fi


echo "###doenload files###"
cd /etc

#install Code server
set +e
git clone --depth 1 https://github.com/HuJK/Code-Server-Hub.git code-server-hub
cd /etc/code-server-hub
set -e

echo "###add nginx to shadow to make pam_module work###"
usermod -aG shadow www-data
echo "###set permission###"
mkdir -p /etc/code-server-hub/.cshub
mkdir -p /etc/code-server-hub/envs
mkdir -p /var/log/code-server-hub/
chmod -R 755 /etc/code-server-hub/.cshub
chmod -R 775 /etc/code-server-hub/util
chmod -R 773 /etc/code-server-hub/sock
chmod -R 770 /etc/code-server-hub/envs
chmod -R 700 /etc/code-server-hub/cert
chown www-data /var/log/code-server-hub
chgrp shadow /etc/code-server-hub/envs
chgrp shadow /etc/code-server-hub/util/anime_pic
ln -s /etc/code-server-hub/code            /etc/code-server-hub/util/openresty/conf/sites-enabled/code.conf

SUDOERS_FILE="/etc/sudoers"
LINE="www-data ALL=NOPASSWD: /etc/code-server-hub/util/close_docker.sh"

install() {
    # Check if the line already exists in sudoers
    if sudo grep -Fxq "$LINE" "$SUDOERS_FILE"; then
        echo "Entry already exists in sudoers."
    else
        # Add the line to sudoers
        echo "$LINE" | sudo tee -a "$SUDOERS_FILE" > /dev/null
        echo "Entry added to sudoers."
    fi
}
install

cd /etc/code-server-hub

echo "###doenload latest code-server###"
curl -L -s https://api.github.com/repos/cdr/code-server/releases/latest \
| grep "browser_download_url.*linux-${cpu_arch}.tar.gz" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -i - -O code-server.tar.gz
echo "###unzip code-server.tar.gz###"

rm -r /etc/code-server-hub/.cshub/* || true
tar xzvf code-server.tar.gz -C .cshub
mv .cshub/*/* .cshub/
rm code-server.tar.gz

echo "###generate self signed cert###"
echo "###You should buy or get a valid ssl certs           ###"
echo "###Now I generate a self singed certs in cert folder ###"
echo "###But you should replace it with valid a ssl certs  ###"
echo '###Remember update your cert for cockpit too!        ###'
echo '### cat ssl.pem ssl.key > /etc/cockpit/ws-certs.d/0-self-signed.cert###'
cd /etc/code-server-hub/cert
openssl genrsa -out ssl.key 2048
openssl req -new -x509 -key ssl.key -out ssl.pem -days 3650 -subj /CN=localhost

if [[ ! $HOMEPGE =~ [yYnN].* ]]; then
    read -p "Do you want to install homepage(yes/no)? " HOMEPGE
fi
if [[ $HOMEPGE =~ [yY].* ]]; then
    set +e
    mv /var/www/html/index.nginx-debian.html   /var/www/html/index.nginx-debian.html.bak
    ln -s /etc/code-server-hub/util/sites/index_page_nodocker.html /var/www/html/index.nginx-debian.html
    set -e
fi


echo "###Compiel and install openresty###"
wget https://openresty.org/download/openresty-1.21.4.1.tar.gz
tar -xvf openresty-1.21.4.1.tar.gz
git clone https://github.com/sto/ngx_http_auth_pam_module
cd openresty-1.21.4.1/
./configure -j2 --add-module=../ngx_http_auth_pam_module --with-pcre-jit \
    --prefix=/etc/code-server-hub/util/openresty/build \
    --conf-path=/etc/code-server-hub/util/openresty/conf/nginx.conf

make
make install

ln -s /etc/code-server-hub/util/openresty/conf/cshub-openresty.service  /etc/systemd/system/cshub-openresty.service

#ask for enable ssl at nginx
if ! grep -q -e  "^[^#]*listen 443 ssl" /etc/nginx/sites-available/default; then
    while true; do
        echo "=========================================================================="
        if [[ ! $HOMEPGE_SSL =~ [yYnN].* ]]; then
            read -p "Do you want enable ssl encryption on your nginx config /etc/nginx/sites-available/default ? (Yes/No/Abort)" HOMEPGE_SSL
        fi
        
        case $HOMEPGE_SSL in
            [Yy]* ) 
                sed -i.bak "/^[^#]*listen 80.*/a\  listen 443 ssl;\n  listen [::]:443 ssl;\n  ssl_certificate '/etc/code-server-hub/cert/ssl.pem';\n  ssl_certificate_key '/etc/code-server-hub/cert/ssl.key';" /etc/nginx/sites-available/default;
                break;;
            [Nn]* ) 
                echo "Skipped";
                break;;
            [Aa]* ) 
                echo "Aborted";
                exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
fi

# libpam-pwquality
if [[ ! $LIBPWQUALITY =~ [yYnN].* ]]; then
    read -p "Do you want to force users to use strong passwords with libpam-pwquality(yes/no)? " LIBPWQUALITY
fi
if [[ $LIBPWQUALITY =~ [yY].* ]]; then
    apt-get install -y libpam-pwquality
    cp /etc/code-server-hub/util/pwquality.conf /etc/security/pwquality.conf
    mkdir -p /usr/share/dict
    wget https://raw.githubusercontent.com/danielmiessler/SecLists/refs/heads/master/Passwords/Common-Credentials/xato-net-10-million-passwords.txt -O /usr/share/dict/10-million-password-list-top-1000000.txt
    create-cracklib-dict /usr/share/dict/10-million-password-list-top-1000000.txt
fi

# Cockpit
if [[ ! $COCKPIT =~ [yYnN].* ]]; then
    read -p "Do you want to install cockpit at 9090 now(yes/no)? " COCKPIT
fi
if [[ $COCKPIT =~ [yY].* ]]; then
    set +e # folling command only have one will success
    apt-get install -y -t bionic-backports cockpit cockpit-pcp #for ubuntu 18.04
    apt-get install -y cockpit cockpit-pcp                     #for ubuntu 20.04
    set -e
fi

#Jupyterhub
if [[ ! $JUPYTERHUB =~ [yYnN].* ]]; then
    read -p "Do you want to install jupyterhub at port 8000(yes/no)? " JUPYTERHUB
fi
if [[ $JUPYTERHUB =~ [yY].* ]]; then
    { # try
        pip3 -V
    } || { # catch
        # save log for exception 
        echo "=========================================================================="
        while true; do
            if [[ ! $JUPYTERHUB_PIP3 =~ [yYnN].* ]]; then
                read -p "pip3 has problem, trying to fix now?? (Yes/No/Abort)" JUPYTERHUB_PIP3
            fi
            
            case $JUPYTERHUB_PIP3 in
                [Yy]* ) 
                    apt purge -y python3-pip
                    wget https://bootstrap.pypa.io/get-pip.py
                    python3 get-pip.py
                    break;;
                [Aa]* ) 
                    echo "Aborted";
                    exit;;
                [Nn]* ) 
                    echo "Skipped";
                    break;;
                * ) echo "Please answer yes or no or abort.";;
            esac
        done
    }
    set +e
    pip3 install certbot-dns-cloudflare
    wget -O- https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install_jupyterhub.sh | bash
    set -e
fi

# serverstat
if [[ ! $SERVERSTAT =~ [yYnN].* ]]; then
    read -p "Do you want to serverstat-backend(yes/no)? " SERVERSTAT
fi
if [[ $SERVERSTAT =~ [yY].* ]]; then
    cd /etc
    git clone https://github.com/HuJK/servstat.git servstat
    cd servstat/backend
    bash install.sh
fi

#Rootless docker
if [[ ! $DOCKER =~ [yYnN].* ]]; then
    read -p "Do you want to install Rootless docker for all users(yes/no)? " ROOTLESS_DOCKER
fi
if [[ $ROOTLESS_DOCKER =~ [yY].* ]]; then
    cd /etc
    sudo git clone --depth 1 https://github.com/HuJK/rootless_docker.git
    cd rootless_docker
    sudo bash ./install-rootless-docker.sh
fi

#Jupyterhub
if [[ ! $DOCKER =~ [yYnN].* ]]; then
    read -p "Do you want to install docker version of code-server-hub at port 2087(yes/no)? " DOCKER
fi
if [[ $DOCKER =~ [yY].* ]]; then
    #ask for install docker
    mkdir -p /data/local
    chmod 777 /data/local
    export FSTAB_SECURE='/data/local /data/local                                                none nosuid,nodev,bind 0 0'
    grep -qxF "${FSTAB_SECURE}" /etc/fstab || echo "${FSTAB_SECURE}" >> /etc/fstab
    if hash docker 2>/dev/null; then
        echo "Docker installed, skip docker auto install"
    else
        echo "=========================================================================="
        while true; do
            if [[ ! $DOCKER_INSTALL =~ [yYnN].* ]]; then
                read -p "Docker not detected. Dou you want to install docker now? (Yes/No/Abort)" DOCKER_INSTALL
            fi
            case $DOCKER_INSTALL in
                [Yy]* ) 
                    apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common;
                    curl https://get.docker.com | bash
                    apt-get update;
                    apt-get install -y docker-ce docker-ce-cli containerd.io;
                    break;;
                [Nn]* ) 
                    echo "Skipped";
                    break;;
                [Aa]* ) 
                    echo "Aborted";
                    exit;;
                * ) echo "Please answer yes or no or abort.";;
            esac
        done
    fi
    usermod -aG docker www-data


    #Portainer
    has_portainer=$(docker container ls -a | grep portainer) || true
    PASSWORD=""
    if [ -z "$has_portainer" ]; then
        echo "=========================================================================="
        
        while true; do
        if [[ ! $DOCKER_PORTAINER =~ [yYnN].* ]]; then
            read -p "Do you want install portainer(a web based docker gui) at port 9000 now? (Yes/No)" DOCKER_PORTAINER
        fi
            case $DOCKER_PORTAINER in
                [Yy]* ) 
                    docker run -d -p 9000:9443 \
                        --name portainer --restart always \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        -v portainer_data:/data \
                        -v /etc/letsencrypt:/etc/letsencrypt \
                        -v /etc/code-server-hub/cert/:/etc/code-server-hub/cert/ \
                        portainer/portainer \
                        --ssl \
                        --sslcert /etc/code-server-hub/cert/ssl.pem \
                        --sslkey  /etc/code-server-hub/cert/ssl.key;
                    echo "=========================================================================="
                    PASSWORD=`date +%s|md5sum|base64|head -c 12`
                    echo "Your username:password for portainer is admin:${PASSWORD} Login at https://$(wget -qO- https://ifconfig.me/):9000"
                    echo "Generated password are store at ~/.ssh/portainer_pwd.txt"
                    mkdir -p ~/.ssh
                    chmod 600 ~/.ssh
                    echo "admin:${PASSWORD}" > ~/.ssh/portainer_pwd.txt
                    n=1
                    until [ $n -ge 16 ]; do
                        echo "Trying to set password ${PASSWORD} for cockpit, attemp ${n}"
                        curl 'https://127.0.0.1:9000/api/users/admin/init' --data-binary '{"Username":"admin","Password":"'"${PASSWORD}"'"}' --insecure && break
                        n=$((n + 1))
                        sleep 1
                    done
                    break;;
                [Nn]* ) 
                    echo "Skipped";
                    break;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi

    #ask for install nvidia-docker
    if hash nvidia-smi 2>/dev/null; then
        docker pull $(python3 /etc/code-server-hub/util/get_docker_image_name.py)
        { # try
            docker run --rm --gpus all nvidia/cuda:11.2.2-base-ubuntu20.04 nvidia-smi &&
            echo "Nvidia docker installed, skip nvidia-docker autoinstall"
        } || { # catch
            # save log for exception 
            echo "=========================================================================="
            while true; do

                if [[ ! $DOCKER_NVIDIA =~ [yYnN].* ]]; then
                    read -p "Nvidia-docker not detected. Dou you want to install nvidia-docker now? (Yes/No/Abort)" DOCKER_NVIDIA
                fi
                case $DOCKER_NVIDIA in
                    [Yy]* ) 
                        # Nvidia-Docker
                        curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
                          && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
                            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
                            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
                        sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit nvidia-container-runtime;
                        echo 'ACTION=="add", DEVPATH=="/bus/pci/drivers/nvidia", RUN+="/usr/bin/nvidia-ctk system 	create-dev-char-symlinks --create-all"' > /lib/udev/rules.d/71-nvidia-dev-char.rules
                        ln -s /etc/code-server-hub/util/initgpu.service  /etc/systemd/system/initgpu.service
                        systemctl enable --now initgpu
                        daemon_json="/etc/docker/daemon.json"
                        config_line='"exec-opts": ["native.cgroupdriver=cgroupfs"]'
                        # Check if daemon.json exists
                        if [ -f "$daemon_json" ]; then
                            # Add the config line to daemon.json using temporary file
                            tmp_file=$(mktemp)
                            jq ". += { $config_line }" "$daemon_json" > "$tmp_file" && mv "$tmp_file" "$daemon_json"
                            echo "Added config to $daemon_json"
                        else
                            # Create daemon.json with the config line
                            echo "{ $config_line }" | sudo tee "$daemon_json" >/dev/null
                            echo "Created $daemon_json"
                        fi
                        systemctl restart docker;
                        break;;
                    [Aa]* ) 
                        echo "Aborted";
                        exit;;
                    [Nn]* ) 
                        echo "Skipped";
                        break;;
                    * ) echo "Please answer yes or no or abort.";;
                esac
            done
        }
    else
        echo "Nvidia driver not found, skip nvidia-docker autoinstall"
        if [[ $DOCKER_IMAGE == "standard" ]]; then
            tmp=$(mktemp)
            jq '."0" = "standard"' /etc/code-server-hub/Dockerfile/versions.json > "$tmp" && mv "$tmp" /etc/code-server-hub/Dockerfile/versions.json
            chmod 755 /etc/code-server-hub/Dockerfile/versions.json
            docker pull $(python3 /etc/code-server-hub/util/get_docker_image_name.py)
        else
            docker pull whojk/code-server-hub-docker:minimal
        fi
    fi

    #install code-hub-docker
    cd /etc/code-server-hub
    ln -s /etc/code-server-hub/code-hub-docker            /etc/code-server-hub/util/openresty/conf/sites-enabled/code-hub-docker.conf
    if [[ $HOMEPGE =~ [yY].* ]] && [[ $DOCKER =~ [yY].* ]]; then
        set +e
        rm /var/www/html/index.nginx-debian.html
            ln -s /etc/code-server-hub/util/sites/index_page.html /var/www/html/index.nginx-debian.html
        set -e
    fi
fi





echo "###restart nginx and cockpit###"
systemctl enable --now nginx
systemctl enable --now cockpit.socket
systemctl enable --now cshub-openresty

if [ "${PASSWORD}" != "" ]; then
    echo "Your username:password for portainer is admin:${PASSWORD} Login at https://$(wget -qO- https://ifconfig.me/):9000"
    echo "Generated password are store at ~/.ssh/portainer_pwd.txt"
fi
exit 0

