# How to use Code-Server-Hub

This project is for our lab to allow users have their own envirement

# Usage

The main difference between RealOS and Container is everyone can use ```sudo``` command in their own container, each container are independent, and can be reset at anytime to avoid Real OS environment corruption .

##### Shell in real OS

![RealOS panel shell sudo](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20221705.png?raw=true)

##### Shell in the container
![Container panel shell sudo](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20221714.png?raw=true)


#### Login

Whenever this dialog prompt, just login with your linux account

![Login](https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/util/sites/Screenshot%202021-01-23%20210930.png)

#### File shareing

By default, ```/data``` and ```/home/{username}``` this two folder will share between RealOS and Container

![index](https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/util/sites/Screenshot%202021-01-23%20210843.png)

## Real OS Panel

* In this panel, all programs are running in the real OS, means all users are share one envirement.
* If you are not a sudoer, you don't have root privilege.
* If you login the server via SSH, your envirement are the same envirement as you login at this panel

![real os panel](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20211028.png?raw=true)

#### Start Server
It will start a vscode instance by your account at background

![real os panel Start](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20211245.png?raw=true)

#### VS code
Connrct to your code-server

![real os panel VS](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20220836.png?raw=true)

#### Jupyter
Connect to a jupyterlab session

![real os panel Jupyter](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20221004.png?raw=true)

#### Cockpit
Connect to cockpit

#### Account
Connect to account page in the cockpit

## Container panel

Whenever you run any program in this panel, all programs will running in a docker container.

Everyone has sudo permission in their own container.

#### Start Container
Just start your container.

If not exist, it will create one

![Container panel](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20213516.png?raw=true)

#### Factort reset

Delete your contaainer. It it will be created at next time you start the container

```/data``` and ```/home/{username}``` folders are mounted externally, so they will not be deleted

![Container panel FS](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20213839.png?raw=true)

#### VS code

![Container panel VS](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20221123.png?raw=true)

#### Jupyter

![Container panel Jupyter](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20221258.png?raw=true)
