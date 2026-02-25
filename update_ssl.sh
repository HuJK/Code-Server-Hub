#!/usr/bin/env bash
set -euo pipefail

# --- Config ---
: "${KEY_URL:?Please set KEY_URL env var (e.g. https://...)}"

PRIV_URL="${KEY_URL%/}/privkey.pem"
FULL_URL="${KEY_URL%/}/fullchain.pem"

KEY_PATH="/etc/code-server-hub/cert/ssl.key"
CRT_PATH="/etc/code-server-hub/cert/ssl.pem"

OPENRESTY_BIN="/etc/code-server-hub/util/openresty/build/bin/openresty"
OPENRESTY_SERVICE="cshub-openresty"
NGINX_BIN="nginx"
NGINX_SERVICE="nginx"

WGET_OPTS=(--no-check-certificate -t 3 -q)

# --- Secure temp files ---
umask 077
TMP_KEY="$(mktemp /tmp/privkey.XXXXXX)"
TMP_CRT="$(mktemp /tmp/fullchain.XXXXXX)"
trap 'rm -f "$TMP_KEY" "$TMP_CRT"' EXIT

log() { printf '[%s] %s\n' "$(date +'%Y-%m-%dT%H:%M:%S%z')" "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

fetch() {
  local url="$1" out="$2" kind="$3"
  if ! wget "${WGET_OPTS[@]}" -O "$out" "$url"; then
    log "ERROR: Failed to download $url"
    return 1
  fi
  if [[ ! -s "$out" ]] || ! grep -q -e '-----BEGIN ' -- "$out"; then
    log "ERROR: Invalid content from $url"
    return 1
  fi
  if have openssl; then
    if [[ "$kind" == "key" ]]; then
      openssl pkey -in "$out" -noout >/dev/null 2>&1 || {
        log "ERROR: Downloaded key does not parse"; return 1; }
    else
      openssl x509 -in "$out" -noout >/dev/null 2>&1 || {
        log "ERROR: Downloaded cert does not parse"; return 1; }
    fi
  fi
}

install_if_changed() {
  local src="$1" dst="$2"
  if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
    return 1  # unchanged
  fi
  local mode=600 owner=0 group=0
  if [[ -e "$dst" ]]; then
    mode="$(stat -c '%a' "$dst")"
    owner="$(stat -c '%u' "$dst")"
    group="$(stat -c '%g' "$dst")"
  fi
  local tmp="${dst}.new.$$"
  cp -f -- "$src" "$tmp"
  chmod "$mode" "$tmp" || true
  chown "$owner:$group" "$tmp" || true
  mv -f -- "$tmp" "$dst"
  log "Updated $(basename "$dst")"
  return 0
}

changed=false

log "Fetching new certificates..."
fetch "$PRIV_URL" "$TMP_KEY" "key"
fetch "$FULL_URL" "$TMP_CRT" "crt"

if install_if_changed "$TMP_KEY" "$KEY_PATH"; then changed=true; fi
if install_if_changed "$TMP_CRT" "$CRT_PATH"; then changed=true; fi

if [[ "$changed" == false ]]; then
  log "No changes detected in certs. Nothing to restart."
  exit 0
fi

restart_service_safely() {
  local bin="$1" args="$2" svc="$3"
  if "$bin" $args; then
    log "Config test passed for $svc; restarting..."
    systemctl restart "$svc"
    log "Restarted $svc"
  else
    log "ERROR: Config test FAILED for $svc; NOT restarting."
  fi
}

[[ -x "$OPENRESTY_BIN" ]] && restart_service_safely "$OPENRESTY_BIN" "-t" "$OPENRESTY_SERVICE" || true
have "$NGINX_BIN" && restart_service_safely "$NGINX_BIN" "-t" "$NGINX_SERVICE" || true

log "Done."
