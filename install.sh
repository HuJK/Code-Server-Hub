#!/bin/bash
set -e
#echo "###update phase###"
apt-get update
#apt-get upgrade -y
echo "###install dependanse phase###"
echo "Install dependances"
apt-get install -y nginx-extras ca-certificates
apt-get install -y tmux libncurses-dev htop nodejs npm wget sudo curl vim openssl git
apt-get install -y python3 python3-pip python3-dev p7zip-full 
pip3 install certbot-dns-cloudflare
set +e # folling command only have one will success
#cockpit for user management
apt-get install -y -t bionic-backports cockpit cockpit-pcp #for ubuntu 18.04
apt-get install -y cockpit cockpit-pcp                     #for ubuntu 20.04
set -e

echo "###doenload files###"
cd /etc

#install Code server
set +e
git clone --depth 1 https://github.com/HuJK/Code-Server-Hub.git code-server-hub
cd /etc/code-server-hub
ln -s /etc/code-server-hub/code            /etc/nginx/sites-available/code
ln -s ../sites-available/code              /etc/nginx/sites-enabled/
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
chmod -R 600 /etc/code-server-hub/cert
chgrp shadow /etc/code-server-hub/envs
chgrp shadow /etc/code-server-hub/util/anime_pic

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


mv /var/www/html/index.nginx-debian.html   /var/www/html/index.nginx-debian.html.bak


if [ "$1" == "docker" ]; then
    #ask for install docker
    if hash docker 2>/dev/null; then
        echo "Docker installed, skip docker auto install"
    else
        echo "=========================================================================="
        while true; do
            read -p "Docker not detected. Dou you want to install docker now? (Yes/No/Abort)" yn
            case $yn in
                [Yy]* ) 
                    apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common;
                    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -;
                    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable";
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
    #ask for install nvidia-docker
    if hash nvidia-smi 2>/dev/null; then
        { # try
            docker run --rm --gpus all nvidia/cuda:10.2-base nvidia-smi &&
            echo "Nvidia docker installed, skip  nvidia-docker autoinstall"
        } || { # catch
            # save log for exception 
            echo "=========================================================================="
            while true; do
                read -p "Nvidia-docker not detected. Dou you want to install nvidia-docker now? (Yes/No/Abort)" yn
                case $yn in
                    [Yy]* ) 
                        # Nvidia-Docker
                        distribution=$(. /etc/os-release;echo $ID$VERSION_ID);
                        curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -;
                        curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list;
                        sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit;
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
    fi
    #Portainer
    while true; do
        echo "=========================================================================="
        read -p "Do you want install portainer(a web based docker gui) now? (Yes/No)" yn
        case $yn in
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
                while true; do
                    read -p "Please visit https://$(wget -qO- https://ifconfig.me/):9000 to set your portainer password now. Finished?(Yes/No)" ynn
                    case $ynn in
                        [Yy]* ) 
                            break;;
                        [Nn]* ) 
                            echo "Please set password now, or your computer may take serious security risks";;
                        * ) echo "Please answer yes or no.";;
                    esac
                done
                break;;
            [Nn]* ) 
                echo "Skipped";
                break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
    #install code-hub-docker
    cd /etc/code-server-hub
    ln -s /etc/code-server-hub/index_page.html /var/www/html/index.nginx-debian.html
    ln -s /etc/code-server-hub/code-hub-docker /etc/nginx/sites-available/code-hub-docker
    ln -s ../sites-available/code-hub-docker   /etc/nginx/sites-enabled/
    docker pull whojk/code-server-hub-docker
else
    ln -s /etc/code-server-hub/index_page_nodocker.html /var/www/html/index.nginx-debian.html
fi


#ask for enable ssl at nginx
if ! grep -q -e  "^[^#]*listen 443 ssl" /etc/nginx/sites-available/default; then
    while true; do
        echo "=========================================================================="
        read -p "Do you want enable ssl encryption on your nginx config /etc/nginx/sites-available/default ? (Yes/No/Abort)" yn
        case $yn in
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

sudo sh -c "$(wget -O- https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install2.sh)"

echo "###restart nginx and cockpit###"
systemctl enable nginx
systemctl enable cockpit.socket
service nginx stop
service nginx start
service cockpit stop
service cockpit start

exit 0
