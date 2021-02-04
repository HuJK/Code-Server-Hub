[EN](https://github.com/HuJK/Code-Server-Hub/blob/master/README.md) | [中文](https://github.com/HuJK/Code-Server-Hub/blob/master/README_zh.md)

# Code-Server-Hub
I want to make code-server uses like jupyterhub, login at web browser without ssh into server and spawn a code-server instance

And it's so convenient, and I am the MIS personnel of my lab. So I wrote a installation script. But with the time passed, I added more and more function in this script....

# What is this?
[https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/README.md](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/README.md)

## How this work
This is a nginx reverse proxy config which will try to authenticate user:password with linux pam module ,and try to execute command to spawn a code-server workspace by that user, and then proxy_pass to it.

# Installation guide

## Install with script(Ubuntu 18.04/20.04)

Actually this script is only a installation script, it's a one-click configuration script for training servers of our lab. 

Please install nvidia-driver before use this script and make sure ```nvidia-smi``` works properly if you have GPUs.

### interactive install , ask you (yes/no) in the installation process
```
wget https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install.sh
chmod 755 install.sh 
sudo install.sh
```

#### For our lab , enable all functions
```
wget https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install.sh
chmod 755 install.sh 
sudo ./install.sh -hp=yes -hps=yes -pq=yes -st=yes -jph=yes -pip3=yes -c=yes -rd=yes -d=yes -de=yes -dn=yes -dp=yes
```
##### Paramaters description

|  paramater   | description  | port occupied|
|  ----  | ----  | --- |
|     | This project |8443|
| hp  | Replace homepage of nginx |80|
| hps | Enable https for homepage         |443|
| pq  | Install pwquality,force users to use strong passwords with libpam-pwquality<br/>Password requirement:at least one lower-case, upper-case, digit, and non-alphanumeric  <br/>minlen =8，usercheck and dictcheck enabled ||
| st  | Install [servstat backend](https://github.com/HuJK/servstat)<br />a web gui to check who is using the GPUs              |9989|
| jph | Install jupyterhub|18517,8001|
| pip3| Install python3-pip。it will be skipped if already installed. ||
| c   | Install [cockpit](https://github.com/cockpit-project/cockpit)                  |9090|
| rd  | Install [rootless-docker](https://github.com/HuJK/rootless_docker)          |2087|
| d   | Install docker版code-server-hub  ||
| de  | Install docker engine，it will be skipped if already installed. ||
| dn  | Install nvidia-docker，it will be skipped if already installed. ||
| dp  | Install portainer，it will be skipped if already installed.     |9000|

### If you want to install at your own server, this is the paramater I suggest.
#### Minimal installatoin
```
sudo ./install.sh -hp=no -hps=no -pq=no -st=no -jph=no -pip3=no -c=no -rd=no -d=no -de=no -dn=no -dp=no
```

Demo:
[https://cshub.hujk.org/200-panel.html](https://cshub.hujk.org/200-panel.html) 

user|passwd
----|---------------
root|DockerAtHeroku

#### Your own server，Normal version
```
sudo ./install.sh -hp=no -hps=no -pq=no -st=no -jph=yes -pip3=yes -c=yes -rd=no -d=no -de=no -dn=no -dp=no
```

#### Multi user server，normal version + docker version + pwquality
```
sudo ./install.sh -hp=no -hps=no -pq=yes -st=no -jph=yes -pip3=yes -c=yes -rd=yes -d=yes -de=yes -dn=yes -dp=yes
```

than access your ip with port 8443(normal version) and 2087(docker version) with web browser.

## Manual install
dependences:

* nginx with lua and auth-pam module
* wget curl
* openssl
* git
* python3 python3-pip
* p7zip

Predefined functions in bash
```
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
```

Doenload files to /etc/code-server-hub
```
cd /etc
git clone --depth 1 https://github.com/HuJK/Code-Server-Hub.git code-server-hub
cd /etc/code-server-hub
```

Add nginx to shadow to make pam_module work and set permission to allow nginx read/write to following folder
```
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
```

Generate self signed cert
```
echo "###generate self signed cert###"
echo "###You should buy or get a valid ssl certs           ###"
echo "###Now I generate a self singed certs in cert folder ###"
echo "###But you should replace it with valid a ssl certs  ###"
echo '###Remember update your cert for cockpit too!        ###'
echo '### cat ssl.pem ssl.key > /etc/cockpit/ws-certs.d/0-self-signed.cert###'
cd /etc/code-server-hub/cert
openssl genrsa -out ssl.key 2048
openssl req -new -x509 -key ssl.key -out ssl.pem -days 3650 -subj /CN=localhost
```

### normal version
dependences:
* tmux
* npm

Doenload latest code-server
```
cd /etc/code-server-hub
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
```

Link config file to nginx
```
cd /etc/code-server-hub
ln -s /etc/code-server-hub/code            /etc/nginx/sites-available/code
ln -s ../sites-available/code              /etc/nginx/sites-enabled/code
```

Now, you can access ```https://[your_ip]:8443``` to access it.

### Docker version
dependences:
* docker

```
docker pull whojk/code-server-hub-docker:minimal
docker pull whojk/code-server-hub-docker:standard
docker pull whojk/code-server-hub-docker:basicML
```

Link config file to nginx
```
cd /etc/code-server-hub
ln -s /etc/code-server-hub/code-hub-docker /etc/nginx/sites-available/code-hub-docker
ln -s ../sites-available/code-hub-docker   /etc/nginx/sites-enabled/code-hub-docker
```

Now, you can access ```https://[your_ip]:2087``` to access it.

## Video introduction

Normal [YouTube](https://www.youtube.com/watch?v=d66OmV22UFI)

