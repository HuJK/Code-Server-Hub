#!/bin/bash
# Restricted sudo entrypoint for www-data (openresty): show the logs of one
# code-server-hub container. Arguments are validated because the caller is
# untrusted.

USER_NAME="$1"
SINCE="$2"

if [[ ! "$USER_NAME" =~ ^[a-zA-Z][0-9a-zA-Z]*$ ]]; then
    echo "Error: USER_NAME must start with a letter and contain only alphanumeric characters." >&2
    exit 1
fi

if [[ -n "$SINCE" ]]; then
    if [[ ! "$SINCE" =~ ^[0-9TZ:.-]+$ ]]; then
        echo "Error: SINCE must be a timestamp like 2021-01-23T22:08:36Z" >&2
        exit 1
    fi
    exec /etc/code-server-hub/util/engine.sh logs "docker-$USER_NAME" --since "$SINCE"
fi
exec /etc/code-server-hub/util/engine.sh logs "docker-$USER_NAME"
