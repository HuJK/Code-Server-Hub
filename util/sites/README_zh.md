# How to use Code-Server-Hub

[EN](https://github.com/HuJK/Code-Server-Hub/blob/master/README.md) | [中文](https://github.com/HuJK/Code-Server-Hub/blob/master/README_zh.md)

這個專案是給lab的server寫的，為了讓每個人有自己的環境，可以安裝套件，不會搞砸整個server

# Usage

主系統和容器的差異是，每個人都可以在容器裡面使用```sudo```指令，而且隨時可以重置環境，不怕搞砸

主系統上面就沒有root權限了

##### Shell in real OS

![RealOS panel shell sudo](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20221705.png?raw=true)

##### Shell in the container
![Container panel shell sudo](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20221714.png?raw=true)


#### Login

用你的linux帳密登入就可以了

![Login](https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/util/sites/Screenshot%202021-01-23%20210930.png)

#### File shareing

預設情況下會把 ```/data``` and ```/home/{username}``` 這2個資料夾掛載進去容器裡面，來共享檔案

![index](https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/util/sites/Screenshot%202021-01-23%20210843.png)

## Real OS Panel

* 這個panel裡面的操作都在主系統之下，所有人都在同一個環境
* 所以如果你不是sudoer，你就沒有root權限
* 如果你用SSH登入，你shell的環境就是這個環境

![real os panel](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20211028.png?raw=true)

#### Start Server
這個鈕會在背景用你的身分開一個code-server

![real os panel Start](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20211245.png?raw=true)
[]
#### VS code
打開code-server

![real os panel VS](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20220836.png?raw=true)

#### Jupyter
打開jupyter lab(相信許多ML的人主要用這個)
![real os panel Jupyter](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20221004.png?raw=true)

#### Cockpit
打開Cockpit

#### Account
打開Cockpit的帳號頁面

## Container panel

這個panel裡面的操作都在容器裡面，不會影響主系統

每個人在容器裡都有```sudo```權限

#### Start Container
啟動容器。若不存在就創建

![Container panel](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20213516.png?raw=true)

#### Factort reset

刪除容器，下次啟動創建

```/data``` and ```/home/{username}```這2個資料夾不影響，因為這2個資料夾是外部掛載的，不會跟著刪掉

![Container panel FS](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20213839.png?raw=true)

#### VS code

![Container panel VS](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20221123.png?raw=true)

#### Jupyter

![Container panel Jupyter](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20221258.png?raw=true)
