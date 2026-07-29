#!/bin/bash
cd /etc/code-server-hub
git pull --no-edit
export image_name=$(python3 util/get_docker_image_name.py)

echo $image_name

# www-data may only run the predefined entrypoints as root, see the script
bash /etc/code-server-hub/util/install_sudoers.sh

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
curl -L -s https://api.github.com/repos/cdr/code-server/releases/latest \
| grep "browser_download_url.*linux-${cpu_arch}.tar.gz" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -i - -O code-server.tar.gz
echo "###unzip code-server.tar.gz###"

rm -r /etc/code-server-hub/.cshub/* || true
tar xzvf code-server.tar.gz -C .cshub
mv .cshub/*/* .cshub/
rm code-server.tar.gz

ENGINE="docker"
if [ -f /etc/code-server-hub/config.json ]; then
    ENGINE_CFG=$(jq -r '.engine // empty' /etc/code-server-hub/config.json 2>/dev/null)
    if [ -n "$ENGINE_CFG" ] && [ "$ENGINE_CFG" != "null" ]; then
        ENGINE="$ENGINE_CFG"
    fi
fi
if hash $ENGINE 2>/dev/null; then
    echo "$ENGINE installed, update container image"
    echo $ENGINE pull $image_name
    $ENGINE pull $image_name
fi
/etc/code-server-hub/util/openresty/build/bin/openresty -s reload
