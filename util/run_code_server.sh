#!/bin/bash
set -e

SERVER_FILES_LOCATION="$1"
SERVER_SERVICE_NAME="$2"
SERVER_SOCK_PATH="$3"

if [ -z "$SERVER_FILES_LOCATION" ] || [ -z "$SERVER_SERVICE_NAME" ] || [ -z "$SERVER_SOCK_PATH" ]; then
  echo "Usage: run_code_server.sh <server_files_location> <server_service_name> <server_sock_path>" >&2
  exit 2
fi

CSHUB_HOME="$HOME/.$SERVER_SERVICE_NAME"
CSHUB_COPY="$HOME/.$SERVER_SERVICE_NAME""_cp"

if [ ! -d "$CSHUB_HOME" ]; then
  rm -rf "$CSHUB_COPY"
  cp -pr "$SERVER_FILES_LOCATION/.$SERVER_SERVICE_NAME" "$CSHUB_COPY"
  mv "$CSHUB_COPY" "$CSHUB_HOME"
fi

rm -f "$SERVER_SOCK_PATH"
"$SERVER_FILES_LOCATION/util/chmod766.sh" "$SERVER_SOCK_PATH" &

exec "$CSHUB_HOME/bin/code-server" --socket "$SERVER_SOCK_PATH" --auth password
