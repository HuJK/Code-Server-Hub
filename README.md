# Code-Server-Hub
It's a webpage similar to jupyterhub, but it's for [code-server](https://github.com/cdr/code-server).

You can login with your **linux account** and password,because it's authenticate with Linux PAM module. 

Then it will automatically spawn a code-server instance in a tmux session at background for you.

If you want add user, type ```sudo adduser``` in command line. Make sure you are a sudoer.

## How this work
This is a nginx reverse proxy config which will try to authenticate user:password with linux pam module ,and try to execute command to spawn a code-server workspace by that user, and then proxy_pass to it.

## Install Script (for Ubuntu 18.04 and 20.04)
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

minimal version
```
wget https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install.sh
sudo bash install.sh docker
```

standard version
```
wget https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install.sh
sudo bash install.sh docker standard
```

Then goto url : https://\[your_server_ip\]



## Video introduction

Normal [YouTube](https://www.youtube.com/watch?v=d66OmV22UFI)

