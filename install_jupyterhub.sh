#!/bin/bash
. /etc/os-release
mkdir -p /etc/code-server-hub/util/jupyterhub_workdir

# Install necessary system packages
apt-get update
apt-get install -y python3-pip python3-venv

# For Ubuntu 18.04 and older, install Python 3.8 for modern JupyterHub
if dpkg --compare-versions "$VERSION_ID" "<=" "18.04"; then
    # Add deadsnakes PPA for newer Python versions
    apt-get install -y software-properties-common
    add-apt-repository -y ppa:deadsnakes/ppa
    apt-get update
    apt-get install -y python3.8 python3.8-venv python3.8-dev
    PYTHON_CMD="python3.8"
else
    # Ubuntu 20.04+ already has Python 3.8+
    PYTHON_CMD="python3"
fi

cd /etc/code-server-hub/util/jupyterhub_workdir

# Create virtual environment with appropriate Python
$PYTHON_CMD -m venv /etc/code-server-hub/util/jupyterhub_workdir/venv

# Install packages
VENV_PATH="/etc/code-server-hub/util/jupyterhub_workdir/venv"
$VENV_PATH/bin/pip install --upgrade pip
$VENV_PATH/bin/pip install jupyter jupyterhub jupyterlab nodeenv

# Setup node environment within venv
$VENV_PATH/bin/nodeenv -p --node=lts
$VENV_PATH/bin/npm install -g configurable-http-proxy

# Create systemd service
echo "[Unit]
Description=Jupyterhub
After=syslog.target network.target

[Service]
User=root
WorkingDirectory=/etc/code-server-hub/util/jupyterhub_workdir
Environment=\"PATH=$VENV_PATH/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"
ExecStart=$VENV_PATH/bin/jupyterhub -f jupyterhub_config.py

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/jupyterhub.service

chmod 776 /etc/code-server-hub/util/jupyterhub_workdir/jupyter_conf
# Enable and start the service
systemctl daemon-reload
systemctl enable --now jupyterhub
systemctl start jupyterhub
