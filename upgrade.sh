#!/bin/bash


cd /etc/code-server-hub
git pull -q
eval $(cat util/create_docker.py | grep "image_name_cpu = " | head -n 1 | sed 's/ //g')
eval $(cat util/create_docker.py | grep "image_name_gpu = " | head -n 1 | sed 's/ //g')

echo $image_name_cpu
echo $image_name_gpu

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

if hash docker 2>/dev/null; then
    echo "Docker installed, update docker image"
    if [[ "$(docker images -q $image_name_cpu 2> /dev/null)" == "" ]]; then
        docker pull $image_name_cpu
    fi
    if [[ "$(docker images -q $image_name_gpu 2> /dev/null)" == "" ]]; then
        docker pull $image_name_gpu
    fi
fi