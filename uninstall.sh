#!/bin/bash
set +e
cd /
rm -r /etc/code-server-hub || true
rm -r /etc/servstat || true
rm -r /etc/systemd/system/cshub-openresty.service || true
rm -r /etc/systemd/system/jupyterhub.service || true
rm -r /etc/systemd/system/serverstat.service || true
