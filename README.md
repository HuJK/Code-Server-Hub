# Code-Server-Hub
It's similar to jupyterhub, but it's for [code-server](https://github.com/cdr/code-server).

You can login with your **linux account** and password,because it's authenticate with Linux PAM module. 
Then it will automatically spawn a code-server instance in a tmux session at background.

If you want add user, type ```sudo adduser``` in command line. Make sure you are a sudoer.

## How this work
This is a nginx reverse proxy config which will try to authenticate user:password with linux pam module ,and try to execute command to spawn a code-server workspace by that user, and then proxy_pass to it.

## Quick install (for Ubuntu 18.04 and 20.04 and Debian 10)

minimal install
```
wget https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install.sh
chmod 755 install.sh 
sudo install.sh -jph=no -jphp3=no -c=no -d=no
```

Demo:
[https://cshub.hujk.org/200-panel.html](https://cshub.hujk.org/200-panel.html) 

user|passwd
----|---------------
root|DockerAtHeroku

### full experiement

```
wget https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install.sh
chmod 755 install.sh 
sudo install.sh -jph=yes -jphp3=yes -c=yes -d=yes -dn=yes -dp=yes
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

