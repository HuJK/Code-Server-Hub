#!/bin/bash
pip3 install jupyterlab jupyterhub
apt-get install -y npm
npm install -g configurable-http-proxy


cd /etc
mkdir -p jupyterhub
cd jupyterhub
jupyterhub --generate-config
sed -i "s/#c.Spawner.default_url = ''/c.Spawner.default_url = '\/lab'/g" jupyterhub_config.py
sed -i "s/#c.JupyterHub.ssl_cert = ''/c.JupyterHub.ssl_cert = '\/etc\/code-server-hub\/cert\/ssl.pem'/g" jupyterhub_config.py
sed -i "s/#c.JupyterHub.ssl_key = ''/c.JupyterHub.ssl_key = '\/etc\/code-server-hub\/cert\/ssl.key'/g" jupyterhub_config.py

echo "[Unit]
Description=Jupyterhub
After=syslog.target network.target

[Service]
User=root
WorkingDirectory=/etc/jupyterhub
Environment="PATH=/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin"
ExecStart=/usr/local/bin/jupyterhub -f /etc/jupyterhub/jupyterhub_config.py

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/jupyterhub.service
systemctl enable --now jupyterhub
