#!/bin/bash


HOMEPGE="NO"
HOMEPGE_SSL="NO"
LIBPWQUALITY="ASK"
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
apt-get install -y nginx-extras ca-certificates socat
apt-get install -y tmux libncurses-dev htop wget sudo curl vim openssl git
apt-get install -y python3 python3-pip python3-dev p7zip-full libffi-dev nodejs
set +e # folling command only have one will success
#cockpit for user management
apt-get install -y npm

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
ln -s /etc/code-server-hub/code            /etc/nginx/sites-available/code
ln -s ../sites-available/code              /etc/nginx/sites-enabled/code
set -e

echo "###add nginx to shadow to make pam_module work###"
usermod -aG shadow www-data
echo "###set permission###"
mkdir -p /etc/code-server-hub/.cshub
mkdir -p /etc/code-server-hub/envs
chmod -R 755 /etc/code-server-hub/.cshub
chmod -R 775 /etc/code-server-hub/util
chmod -R 773 /etc/code-server-hub/sock
chmod -R 770 /etc/code-server-hub/envs
chmod -R 700 /etc/code-server-hub/cert
chgrp shadow /etc/code-server-hub/envs
chgrp shadow /etc/code-server-hub/util/anime_pic

cd /etc/code-server-hub

echo "###doenload latest code-server###"
curl -s https://api.github.com/repos/cdr/code-server/releases/latest \
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
fi

# Cockpit
if [[ ! $COCKPIT =~ [yYnN].* ]]; then
    read -p "Do you want to install cockpit at 9090 now(yes/no)? " COCKPIT
fi
if [[ $COCKPIT =~ [yY].* ]]; then
    set +e # folling command only have one will success
    apt-get install -y -t xenial-backports cockpit cockpit-pcp #for ubuntu 16.04
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
                    curl -fsSL "https://download.docker.com/linux/$ID/gpg" | sudo apt-key add -;
                    sudo add-apt-repository "deb [arch=${cpu_arch}] https://download.docker.com/linux/$ID $(lsb_release -cs) stable";
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
                    docker run -d -p 9000:9000 \
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
        docker pull whojk/code-server-hub-docker:basicML
        { # try
            docker run --rm --gpus all nvidia/cuda:10.2-base nvidia-smi &&
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
                        distribution=$(. /etc/os-release;echo $ID$VERSION_ID);
                        curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -;
                        curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list;
                        sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit nvidia-container-runtime;
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
            docker pull whojk/code-server-hub-docker:standard
            sed -i.bak "/^image_name_cpu = .*/cimage_name_cpu = 'whojk/code-server-hub-docker:standard'" /etc/code-server-hub/util/create_docker.py
        else
            docker pull whojk/code-server-hub-docker:minimal
        fi
    fi

    #install code-hub-docker
    cd /etc/code-server-hub
    ln -s /etc/code-server-hub/code-hub-docker /etc/nginx/sites-available/code-hub-docker
    ln -s ../sites-available/code-hub-docker   /etc/nginx/sites-enabled/code-hub-docker
    if [[ $HOMEPGE =~ [yY].* ]] && [[ $DOCKER =~ [yY].* ]]; then
        set +e
        rm /var/www/html/index.nginx-debian.html
            ln -s /etc/code-server-hub/util/sites/index_page.html /var/www/html/index.nginx-debian.html
        set -e
    fi
fi





echo "###restart nginx and cockpit###"
systemctl enable nginx
systemctl enable cockpit.socket
service nginx stop
service nginx start
service cockpit stop
service cockpit start
if [ "${PASSWORD}" != "" ]; then
    echo "Your username:password for portainer is admin:${PASSWORD} Login at https://$(wget -qO- https://ifconfig.me/):9000"
    echo "Generated password are store at ~/.ssh/portainer_pwd.txt"
fi
exit 0
