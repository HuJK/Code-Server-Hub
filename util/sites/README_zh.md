# Code-Server-Hub

[EN](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/README.md) | [中文](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/README_zh.md)

這個專案是給lab的server寫的，為了讓每個人有自己的環境，可以安裝套件，不會搞砸整個server

# 用途

主系統和容器的差異是，每個人都可以在容器裡面使用```sudo```指令，而且隨時可以重置環境，不怕搞砸

#### 容器裡做的事
大部分的事情都可以在容器裡完成，每人都有```sudo```權限，可以自行安裝需要的套件

#### 主系統做的事
* 改密碼
    * 在容器裡面改密碼是無效的...每次啟動容器，密碼都會從主系統傳遞到容器裡面(hash過)
    * 主系統那邊改完密碼，容器裡的密碼會跟著變
* port forwarding
    * 因為容器裡面listen port外面連不上。
    * 如需在容器裡面架服務外面連，請先在容器裡面用 ```ip addr```查詢容器的ip
    * 架好以後再用該指令把主系統的port forawding去容器裡面(172.22.17.3換成你的ip)
    * ```socat TCP-LISTEN:10080,fork TCP:172.22.17.3:80```
* 跑docker
    * 因為docker裡面不能跑docker(很麻煩)，所以每台server我都安裝了 [rootless docker](https://github.com/HuJK/rootless_docker)。
    * 如果有需求跑現成docker，直接在主系統用docker指令即可

### 差異

##### 主系統的Shell

![RealOS panel shell sudo](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20221705.png?raw=true)

##### 容器裡的Shell
![Container panel shell sudo](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20221714.png?raw=true)


#### 登入

用你的linux帳密登入就可以了

![Login](https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/util/sites/Screenshot%202021-01-23%20210930.png)

#### 檔案共享

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
打開jupyter lab
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
打開容器裡的code-server

![Container panel VS](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20221123.png?raw=true)

#### Jupyter
打開容器裡的jupyter lab (相信許多ML的人主要用這個)

![Container panel Jupyter](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/Screenshot%202021-01-23%20221258.png?raw=true)

# 安全性警告
* 請在主系統把 ```/home``` and ```/data``` 用 ```nosuid,nodev``` 參數來掛載. 
    * 因為使用者在container裡面有root權限，可以```setuid```一個執行檔，然後在主系統執行，藉此獲取主系統的root權限. 
    * 只有 ```/home/{username}``` 和 ```/data``` 是在容器內和主系統之間共享，所以在主系統必須把這2個資料夾掛載成```nosuid,nodev```，可以防止沒權限的user取得主系統的root權限.
