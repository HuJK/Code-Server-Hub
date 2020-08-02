function get_cpu_architecture()
{
    local cpuarch=$(uname -m)
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

echo "###doenload files###"
cd /etc

#install Code server
set +e
git clone --depth 1 https://github.com/HuJK/Code-Server-Hub.git -b heroku code-server-hub
cd /etc/code-server-hub
ln -s /etc/code-server-hub/code            /etc/nginx/sites-available/code
ln -s ../sites-available/code              /etc/nginx/sites-enabled/code
set -e

echo "###add nginx to shadow to make pam_module work###"
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

cd /etc/code-server-hub

echo "###doenload latest code-server###"
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

echo "###generate self signed cert###"
echo "###You should buy or get a valid ssl certs           ###"
echo "###Now I generate a self singed certs in cert folder ###"
echo "###But you should replace it with valid a ssl certs  ###"
echo '###Remember update your cert for cockpit too!        ###'
echo '### cat ssl.pem ssl.key > /etc/cockpit/ws-certs.d/0-self-signed.cert###'
cd /etc/code-server-hub/cert
openssl genrsa -out ssl.key 2048
openssl req -new -x509 -key ssl.key -out ssl.pem -days 3650 -subj /CN=localhost

set +e
mv /var/www/html/index.nginx-debian.html   /var/www/html/index.nginx-debian.html.bak
set -e


ln -s /etc/code-server-hub/index_page_nodocker.html /var/www/html/index.nginx-debian.html
