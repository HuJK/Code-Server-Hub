#!/bin/bash
set +e
cd /
rm -r /etc/code-server-hub || true
rm -r /etc/servstat || true
rm -r /etc/systemd/system/cshub-openresty.service || true
rm -r /etc/systemd/system/jupyterhub.service || true
rm -r /etc/systemd/system/serverstat.service || true
rm -r /etc/systemd/system/initgpu.service    || true

SUDOERS_FILE="/etc/sudoers"
LINE="www-data ALL=NOPASSWD: /etc/code-server-hub/util/close_docker.sh"
LINE_PODMAN="www-data ALL=NOPASSWD: /usr/bin/podman"

uninstall() {
    # Check if the line exists in sudoers
    if sudo grep -Fxq "$1" "$SUDOERS_FILE"; then
        # Remove the line from sudoers
        sudo sed -i "\|$1|d" "$SUDOERS_FILE"
        echo "Entry removed from sudoers."
    else
        echo "Entry does not exist in sudoers."
    fi
}
uninstall "$LINE"
uninstall "$LINE_PODMAN"