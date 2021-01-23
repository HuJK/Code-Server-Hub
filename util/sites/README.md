# How to use Code-Server-Hub

This project is for our lab to allow users have their own envirement

#### Login

Whenever this dialog prompt, just login with your linux account

![Login](https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/util/sites/Screenshot%202021-01-23%20210930.png)

#### File shareing

By default, ```/data``` and ```/home/{username}``` this two folder will share between RealOS and Container

![index.html](https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/util/sites/Screenshot%202021-01-23%20210843.png)

## Real OS Panel

* In this panel, all programs are running in the real OS, means all users are share one envirement.
* If you are not a sudoer, you don't have root privilege.
* If you login the server via SSH, your envirement are the same envirement as you login at this panel

![index.html](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20211028.png?raw=true)

#### Start Server
It will start a vscode instance by your account at background
![index.html](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20211245.png?raw=true)

#### VS code
Connrct to your code-server
![index.html]()

#### Jupyter
Connect to a jupyterlab session
![index.html]()

#### Cockpit
Connect to cockpit
![index.html]()

#### Account
Connect to account page in the cockpit
![index.html]()

## Container panel

Whenever you run any program in this panel, all programs will running in a docker container.

#### Start Container
Just start your container.
If not exist, it will create one
![index.html]()

#### Factort reset
Delete your contaainer. It it will be created at next time you start the container
```/data``` and ```/home/{username}``` folders are mounted externally, will not be deleted
![index.html]()

#### VS code
![index.html]()

#### Jupyter
![index.html]()

# Usage
The main difference between RealOS and Container is everyone can use ```sudo``` command in their own container, each container are independent, and can reset at anytime to avoid system environment corrupt .
![index.html]()
![index.html]()
