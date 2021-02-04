[EN](https://github.com/HuJK/Code-Server-Hub/blob/master/README.md) | [中文](https://github.com/HuJK/Code-Server-Hub/blob/master/README_zh.md)

# Code-Server-Hub
這個專案最初是想要類似jupyter hub一樣，直接在網頁登入jupyterlab，而不用每個人ssh進去開server
不過我開的是code-server，僅此而已

後來覺得好用，我又是學校lab的網管，我就幫lab的伺服器寫了一個一鍵安裝腳本，沒想到挺方便的，功能越加越多了

# 這個專案是什麼?
[https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/README_zh.md](https://github.com/HuJK/Code-Server-Hub/blob/master/util/sites/README_zh.md)

## 如何運作的
這是一個nginx設定檔，會拿你的登入資訊和limux pam模組去認證，認證通過以後以你的身分跑一個code-server(普通版)或是docker container，裡面有code-server(docker版)

# 安裝教學

## 腳本安裝

其實這已經不是單純的安裝腳本了，這是我們實驗室訓練server的一鍵配置腳本了

### 交互安裝
```
wget https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install.sh
chmod 755 install.sh 
sudo install.sh
```

### 這個是給我們lab server用的安裝腳本，全部啟用
```
wget https://raw.githubusercontent.com/HuJK/Code-Server-Hub/master/install.sh
chmod 755 install.sh 
sudo ./install.sh -hp=yes -hps=yes -pq=yes -st=yes -jph=yes -pip3=yes -c=yes -rd=yes -d=yes -de=yes -dn=yes -dp=yes
```

### 參數說明:

|  參數   | 說明  | 佔用端口
|  ----  | ----  | --- |
|     | 安裝本專案 |8443|
| hp  | 替換掉nginx預設首頁 |80|
| hps | 幫首頁啟用https             |443|
| pq  | 安裝pwquality，強迫server底下所有人只能用強密碼。預設要求:大小寫+數字符號各1，長度>=8，不能包含username，啟用字典檢查 ||
| st  | 安裝servstat後端。這是朋友寫的一個探針，用來方便lab同學查詢顯卡使用狀況，是誰在用              |9989|
| jph | 安裝jupyterhub，ML server必備|18517,8001|
| pip3| 安裝python3-pip。已安裝會跳過 ||
| c   | 安裝cockpit                  |9090|
| rd  | 安裝rootless-docker          |2087|
| d   | 安裝docker版code-server-hub  ||
| de  | 安裝docker engine，已安裝跳過 ||
| dn  | 安裝nvidia-docker，已安裝跳過 ||
| dp  | 安裝portainer，已安裝跳過     |9000|


## 如果你們是想要在自己VPS安裝使用，我推薦的安裝參數
#### 最小安裝
```
sudo ./install.sh -hp=no -hps=no -pq=no -st=no -jph=no -pip3=no -c=no -rd=no -d=no -de=no -dn=no -dp=no
```

Demo:
[https://cshub.hujk.org/200-panel.html](https://cshub.hujk.org/200-panel.html) 

user|passwd
----|---------------
root|DockerAtHeroku

#### 一個人用的server，安裝普通版
```
sudo ./install.sh -hp=no -hps=no -pq=no -st=no -jph=yes -pip3=yes -c=yes -rd=no -d=no -de=no -dn=no -dp=no
```

#### 多個人用的server，安裝普通版+docker版+pwquality
```
sudo ./install.sh -hp=no -hps=no -pq=yes -st=no -jph=yes -pip3=yes -c=yes -rd=yes -d=yes -de=yes -dn=yes -dp=yes
```

然後用瀏覽器訪問server ip即可

## 手動安裝
依賴:

* nginx with lua and auth-pam module
* wget curl
* openssl
* git
* python3 python3-pip
* p7zip

偵測CPU架構的bash函數
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

下載本專案
```
cd /etc
git clone --depth 1 https://github.com/HuJK/Code-Server-Hub.git code-server-hub
cd /etc/code-server-hub
```

設定權限，允許nginx讀寫必要檔案+使用pam_module認證
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

自簽名證書
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

### 安裝普通版
依賴:
* tmux
* npm

下載最新的 code-server
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

把設定檔軟連結去nginx
```
cd /etc/code-server-hub
ln -s /etc/code-server-hub/code            /etc/nginx/sites-available/code
ln -s ../sites-available/code              /etc/nginx/sites-enabled/code
```

瀏覽器訪問 ```https://[your_ip]:8443```

### 安裝Docker版
依賴:
* docker
* nvidia-docker(可選)


以下鏡像三選一

 * ```docker pull whojk/code-server-hub-docker:minimal```    (CPU用)
 * ```docker pull whojk/code-server-hub-docker:standard```   (CPU用)
 * ```docker pull whojk/code-server-hub-docker:basicML```    (GPU專用)
 
 自己build請參考[https://github.com/HuJK/Code-Server-Hub/tree/master/Dockerfile](https://github.com/HuJK/Code-Server-Hub/tree/master/Dockerfile)


把設定檔軟連結去nginx
```
cd /etc/code-server-hub
ln -s /etc/code-server-hub/code-hub-docker /etc/nginx/sites-available/code-hub-docker
ln -s ../sites-available/code-hub-docker   /etc/nginx/sites-enabled/code-hub-docker
```

瀏覽器訪問 ```https://[your_ip]:2087```

