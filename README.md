# Code-Server-Hub
It's a webpage similar to jupyterhub, but it's for [code-server](https://github.com/cdr/code-server).

You can login with your **linux account** and password,because it's authenticate with Linux PAM module. 

Then it will automatically spawn a code-server instance in a tmux session at background for you.

If you want add user, type ```sudo adduser``` in command line. Make sure you are a sudoer.

## What is this
This is an nginx reverse proxy config which will try to authenticate user:password with linux pam module ,and try to execute command to spawn a code-server workspace by that user, and then proxy_pass to it.

## Auto Install
Run this in terminal

### Normal version
```
wget https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install.sh
sudo bash install.sh
```
Demo:
[https://nlvm.whojk.com](https://nlvm.whojk.com) 

Because the demo server is hosted in a very cheap VPS(256MB ram, 3GB disk), the debugger may not work properly due to low memory.

user|passwd
------|---------
demo01|demo)!

### Docker version + normal versoin

```
wget https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install.sh
sudo bash install.sh docker
```

And goto url : https://\[your_server_ip\]



## Video introduction

[YouTube](https://www.youtube.com/watch?v=d66OmV22UFI)

## Manual install 

### Preinstall (for Ubuntu. If you use different distro, please install equivalent package ): 

```bash
set -e
echo "###update phase###"
apt-get update
echo "###install dependanse phase###"
apt-get install -y nginx-extras ca-certificates socat
apt-get install -y tmux libncurses-dev htop nodejs npm wget sudo curl vim openssl git
apt-get install -y python3 python3-pip python3-dev p7zip-full 
pip3 install certbot-dns-cloudflare
set +e # folling command only have one will success
#cockpit for user management
apt-get install -y -t bionic-backports cockpit cockpit-pcp #for ubuntu 18.04
apt-get install -y cockpit cockpit-pcp                     #for ubuntu 20.04
set -e
```
If you want to install in CentOS, you'll need package ```nginx-module-auth-pam``` and ```nginx-module-lua``` , but it's only available in a paid repository. 

Otherwise you have to compile nginx and module yourself.

### Install

```bash
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
| grep "browser_download_url.*linux-x86_64.tar.gz" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -i - -O code-server.tar.gz
echo "###unzip code-server.tar.gz###"

rm -r /etc/code-server-hub/.cshub/* || true
tar xzvf code-server.tar.gz -C .cshub
mv .cshub/*/* .cshub/
rm code-server.tar.gz

cd /etc/code-server-hub/cert
openssl genrsa -out ssl.key 2048
openssl req -new -x509 -key ssl.key -out ssl.pem -days 3650 -subj /CN=localhost
```

### Install jupyterhub
```bash
sudo sh -c "$(wget -O- https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install2.sh)"
```

### Postinstall.

#### 1. Setup ssl certificates

1. Buy or get a free domain
2. Get a valid certificate from letsencrypt
3. put your ssl cert and key at following path
```
    ssl_certificate     /etc/code-server-hub/cert/ssl.pem;
    ssl_certificate_key /etc/code-server-hub/cert/ssl.key;
```
4. configure ssl key for cockpit
```
cd /etc/code-server-hub/cert
cat ssl.pem ssl.key > /etc/cockpit/ws-certs.d/0-self-signed.cert
```

#### 2. Change port number(optional)
Edit ```/etc/code-server-hub/code```
```
    listen 8443 ssl;
    listen [::]:8443 ssl;
``` 
from 8443 to other ports that you prefer.

Now, reload services with 
```bash
echo "restart nginx and cockpit"
systemctl enable nginx
systemctl enable cockpit.socket
service nginx stop
service nginx start
service cockpit stop
service cockpit start
exit 0
```
