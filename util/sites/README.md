# How to use Code-Server-Hub

This project is for our lab to allow users have their own envirement

#### Login

Whenever this dialog prompt, just login with your linux account

#### File shareing

By default, ```/data``` and ```/home/{username}``` this two folder will share between RealOS and Container

## Real OS Panel

* In this panel, all programs are running in the real OS, means all users are share one envirement.
* If you are not a sudoer, you don't have root privilege.
* If you login the server via SSH, your envirement are the same envirement as you login at this panel

#### Start Server
It will start a vscode instance by your account at background

#### VS code
Connrct to your code-server

#### Jupyter
Connect to a jupyterlab session

#### Cockpit
Connect to cockpit

#### Account
Connect to account page in the cockpit

## Container panel

Whenever you run any program in this panel, all programs will running in a docker container.


#### Start Container
Just start your container.
If not exist, it will create one

#### Factort reset
Delete your contaainer. It it will be created at next time you start the container
```/data``` and ```/home/{username}``` folders are mounted externally, will not be deleted

#### VS code

#### Jupyter
