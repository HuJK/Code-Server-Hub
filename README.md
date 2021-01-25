# Code-Server-Hub
It's similar to jupyterhub, but it's for [code-server](https://github.com/cdr/code-server).

You can login with your **linux account** and password,because it's authenticate with Linux PAM module. 
Then it will automatically spawn a code-server instance in a tmux session at background.

If you want add user, type ```sudo adduser``` in command line. Make sure you are a sudoer.

# What is this?
[https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/README.md](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/README.md)

## How this work
This is a nginx reverse proxy config which will try to authenticate user:password with linux pam module ,and try to execute command to spawn a code-server workspace by that user, and then proxy_pass to it.

# Install guide

## Quick install (for Ubuntu 18.04 and 20.04 and Debian 10)

### interactive install
```
wget https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install.sh
chmod 755 install.sh 
sudo install.sh
```


#### minimal
```
wget https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install.sh
chmod 755 install.sh 
sudo ./install.sh -hp=no -hps=no -jph=no -pip3=no -c=no -rd=no -d=no -de=no -dn=no -dp=no
```

Demo:
[https://cshub.hujk.org/200-panel.html](https://cshub.hujk.org/200-panel.html) 

user|passwd
----|---------------
root|DockerAtHeroku

#### normal
```
wget https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install.sh
chmod 755 install.sh 
sudo ./install.sh -hp=no -hps=no -jph=yes -pip3=yes -c=yes -rd=yes -d=no -de=no -dn=no -dp=no
```

#### normal+docker (~5.2 GB)

```
wget https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install.sh
chmod 755 install.sh 
sudo ./install.sh -hp=no -hps=no -jph=yes -pip3=yes -c=yes -rd=yes -d=yes -de=yes -dn=yes -dp=yes
```

#### For our lab (~5.2 GB)
```
wget https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install.sh
chmod 755 install.sh 
sudo ./install.sh -hp=yes -hps=yes -jph=yes -pip3=yes -c=yes -rd=yes -d=yes -de=yes -dn=yes -dp=yes
```

Then goto url : https://\[your_server_ip\]

## Manual install

dependences:

* nginx with lua and auth-pam module
* tmux
* npm
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
Link config file to nginx
```
ln -s /etc/code-server-hub/code            /etc/nginx/sites-available/code
ln -s ../sites-available/code              /etc/nginx/sites-enabled/code
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

## Video introduction

Normal [YouTube](https://www.youtube.com/watch?v=d66OmV22UFI)

