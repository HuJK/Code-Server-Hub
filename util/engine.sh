#!/bin/bash
# Run the container engine (docker or rootful podman) recorded in config.json.
# Non-root callers (www-data from openresty) reach rootful podman through the
# sudoers entry installed by install.sh.

CONFIG_FILE="/etc/code-server-hub/config.json"
ENGINE="docker"
if [[ -f "$CONFIG_FILE" ]]; then
    ENGINE_CFG=$(jq -r '.engine // empty' "$CONFIG_FILE" 2>/dev/null)
    if [[ -n "$ENGINE_CFG" && "$ENGINE_CFG" != "null" ]]; then
        ENGINE="$ENGINE_CFG"
    fi
fi

if [[ "$ENGINE" == "podman" && "$(id -u)" -ne 0 ]]; then
    exec sudo -n /usr/bin/podman "$@"
fi
exec "$ENGINE" "$@"
