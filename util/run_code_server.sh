#!/bin/bash
set -e

SERVER_FILES_LOCATION="$1"
SERVER_SERVICE_NAME="$2"
SERVER_SOCK_PATH="$3"

if [ -z "$SERVER_FILES_LOCATION" ] || [ -z "$SERVER_SERVICE_NAME" ] || [ -z "$SERVER_SOCK_PATH" ]; then
  echo "Usage: run_code_server.sh <server_files_location> <server_service_name> <server_sock_path>" >&2
  exit 2
fi

CODE_SERVER_BIN="$SERVER_FILES_LOCATION/.$SERVER_SERVICE_NAME/bin/code-server"
USER_DATA_DIR="$HOME/.local/share/code-server"
EXTENSIONS_DIR="$USER_DATA_DIR/extensions"

rm -f "$SERVER_SOCK_PATH"
mkdir -p "$USER_DATA_DIR" "$EXTENSIONS_DIR"

exec "$CODE_SERVER_BIN" \
  --socket "$SERVER_SOCK_PATH" \
  --socket-mode 766 \
  --auth password \
  --user-data-dir "$USER_DATA_DIR" \
  --extensions-dir "$EXTENSIONS_DIR"
