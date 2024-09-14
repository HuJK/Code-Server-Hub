#!/bin/bash
cd /etc/code-server-hub
git pull --no-edit
export image_name=$(python3 util/get_docker_image_name.py)

echo $image_name

SUDOERS_FILE="/etc/sudoers"
LINE="www-data ALL=NOPASSWD: /etc/code-server-hub/util/close_docker.sh"

install() {
    # Check if the line already exists in sudoers
    if sudo grep -Fxq "$LINE" "$SUDOERS_FILE"; then
        echo "Entry already exists in sudoers."
    else
        # Add the line to sudoers
        echo "$LINE" | sudo tee -a "$SUDOERS_FILE" > /dev/null
        echo "Entry added to sudoers."
    fi
}
install

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

if hash docker 2>/dev/null; then
    echo "Docker installed, update docker image"
    echo docker pull $image_name
    docker pull $image_name
fi
/etc/code-server-hub/util/openresty/build/bin/openresty -s reload
