#!/bin/bash
set -e
#echo "###update phase###"
apt-get update
#apt-get upgrade -y
set +e
# In my distro(debian 10), It seems nginx and nginx-full are not compatible. I have to remove nginx than I can install nginx-full.
apt-get remove -y nginx
# The install script will detect npm exist or not on the system. If exist, it will not use itself's npm
# But in Ubuntu 19.04, npm from apt are not compatible with it. So I have to remove first, and install back later.
apt-get autoremove -y
set -e
echo "###install dependanse phase###"


#uncommit it if ypu need
# Docker
#apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
#apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Nvidia-Docker
#distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
#curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
#curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
#sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit

systemctl restart docker


apt-get install -y nginx-full
apt-get install -y lua5.2 lua5.2-doc liblua5.2-dev luajit
apt-get install -y libnginx-mod-http-auth-pam libnginx-mod-http-lua
apt-get install -y tmux gdb git python python3 wget libncurses-dev nodejs
apt-get install -y python3-pip nodejs sudo gcc g++ build-essential
apt-get install -y aria2 p7zip-full python3-dev perl wget curl vim htop
pip3 install certbot-dns-cloudflare
set +e # folling command only have one will success
#cockpit for user management
apt-get install -y -t bionic-backports cockpit cockpit-pcp #for ubuntu 18.04
apt-get install -y cockpit cockpit-pcp                     #for ubuntu 19.04
set -e

echo "###doenload files###"
cd /etc
git clone --depth 1 https://github.com/HuJK/Code-Server-Hub-Docker.git code-server-hub


cd /etc/code-server-hub
ln -s /etc/code-server-hub/code-hub-docker /etc/nginx/sites-available/code-hub-docker
ln -s ../sites-available/code-hub-docker /etc/nginx/sites-enabled/
mv /var/www/html/index.nginx-debian.html /var/www/html/index.nginx-debian.html.bak
ln -s /etc/code-server-hub/index_page.html /var/www/html/index.nginx-debian.html

#Code server
wget https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/code
ln -s /etc/code-server-hub/code /etc/nginx/sites-available/code
ln -s ../sites-available/code /etc/nginx/sites-enabled/


set +e
echo "###add nginx to shadow to make pam_module work###"
usermod -aG shadow nginx
usermod -aG shadow www-data
usermod -aG docker nginx
usermod -aG docker www-data
set -e
echo "###set permission###"
mkdir -p /etc/code-server-hub/.cshub
mkdir -p /etc/code-server-hub/envs
chmod -R 755 /etc/code-server-hub/.cshub
chmod -R 755 /etc/code-server-hub/util
chmod -R 773 /etc/code-server-hub/sock
chmod -R 770 /etc/code-server-hub/envs
chgrp shadow /etc/code-server-hub/envs

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



set +e
echo "###generate self signed cert###"
echo "###You should buy or get a valid ssl certs           ###"
echo "###Now I generate a self singed certs in cert folder ###"
echo "###But you should replace it with valid a ssl certs  ###"
echo '###Remember update your cert for cockpit too!        ###'
echo '### cat ssl.pem ssl.key > /etc/cockpit/ws-certs.d/0-self-signed.cert###'
apt-get install -y install openssl
mkdir /etc/code-server-hub/cert
chmod 600 /etc/code-server-hub/cert
cd /etc/code-server-hub/cert
openssl genrsa -out ssl.key 2048
openssl req -new -x509 -key ssl.key -out ssl.pem -days 3650 -subj /CN=localhost

echo "###restart nginx and cockpit###"
systemctl enable nginx
systemctl enable cockpit.socket
service nginx stop
service nginx start
service cockpit stop
service cockpit start

sudo sh -c "$(wget -O- https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install2.sh)"
docker pull whojk/code-server-hub-docker
docker run -d -p 9000:9000 \
       --name portainer --restart always \
       -v /var/run/docker.sock:/var/run/docker.sock \
       -v portainer_data:/data \
       -v /etc/letsencrypt:/etc/letsencrypt \
       -v /etc/code-server-hub/cert/:/etc/code-server-hub/cert/ \
       portainer/portainer \
       --ssl \
       --sslcert /etc/code-server-hub/cert/ssl.pem \
       --sslkey  /etc/code-server-hub/cert/ssl.key

exit 0
