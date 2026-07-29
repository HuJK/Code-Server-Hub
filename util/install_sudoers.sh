#!/bin/bash
# www-data (openresty) may only run these predefined entrypoints as root,
# never the container engine directly. Each entrypoint validates its own
# arguments because the caller is untrusted.
set -e

SUDOERS_D_FILE="/etc/sudoers.d/code-server-hub"
TMP_FILE=$(mktemp)
cat > "$TMP_FILE" <<'EOF'
www-data ALL=NOPASSWD: /usr/bin/python3 /etc/code-server-hub/util/create_docker.py *
www-data ALL=NOPASSWD: /usr/bin/python3 /etc/code-server-hub/util/close_docker.py *
www-data ALL=NOPASSWD: /usr/bin/python3 /etc/code-server-hub/util/delete_docker.py *
www-data ALL=NOPASSWD: /etc/code-server-hub/util/close_docker.sh
www-data ALL=NOPASSWD: /etc/code-server-hub/util/container_logs.sh
EOF
if ! visudo -cf "$TMP_FILE" >/dev/null; then
    echo "Error: generated sudoers file is invalid, aborting." >&2
    rm -f "$TMP_FILE"
    exit 1
fi
install -m 0440 -o root -g root "$TMP_FILE" "$SUDOERS_D_FILE"
rm -f "$TMP_FILE"
echo "Installed $SUDOERS_D_FILE"

# remove overly broad entries appended to /etc/sudoers by old versions
LEGACY_LINES=(
    "www-data ALL=NOPASSWD: /etc/code-server-hub/util/close_docker.sh"
    "www-data ALL=NOPASSWD: /usr/bin/podman"
)
for LINE in "${LEGACY_LINES[@]}"; do
    if grep -Fxq "$LINE" /etc/sudoers; then
        sed -i "\|^${LINE}\$|d" /etc/sudoers
        echo "Removed legacy sudoers entry: $LINE"
    fi
done
