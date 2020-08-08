# Code-Server-Hub
It's similar to jupyterhub, but it's for [code-server](https://github.com/cdr/code-server).

You can login with your **linux account** and password,because it's authenticate with Linux PAM module. 
Then it will automatically spawn a code-server instance in a tmux session at background.

If you want add user, type ```sudo adduser``` in command line. Make sure you are a sudoer.

## How this work
This is a nginx reverse proxy config which will try to authenticate user:password with linux pam module ,and try to execute command to spawn a code-server workspace by that user, and then proxy_pass to it.

## Install Script (for Ubuntu 18.04 and 20.04)
Run this in terminal

### Script usage
```
wget https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install.sh
sudo bash install.sh [nodocker|docker] [minimal|standard] [portainer|noportainer] [ssl|nossl]
```
### Examples
#### Normal version

Install Code-Server-Hub only(300MB + dependences)

```
wget https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install.sh
sudo bash install.sh
```
Demo:
[https://cshub.whojk.com/200-panel.html](https://cshub.whojk.com/200-panel.html) 


user|passwd
------|---------
root|DockerATheroku!

### Docker version + normal versoin

Install Code-Server-Hub and Code-Server-Hub-Docker

minimal version (1.5GB + dependences)
```
wget https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install.sh
sudo bash install.sh docker minimal
```

standard version (4GB + dependences)
```
wget https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install.sh
sudo bash install.sh docker standard
```

Then goto url : https://\[your_server_ip\]


dependences=
```
nginx-extras ca-certificates socat tmux libncurses-dev htop nodejs npm wget sudo curl vim openssl git python3 python3-pip python3-dev p7zip-full cockpit cockpit-pcp docker-ce  docker-ce-cli containerd.io
certbot-dns-cloudflare  jupyterlab jupyterhub
configurable-http-proxy
portainer
```
Roughly 3GB for clean ubuntu. If you already installed some package mentioned above, it will be smaller.

## Video introduction

Normal [YouTube](https://www.youtube.com/watch?v=d66OmV22UFI)

