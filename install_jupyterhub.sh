#!/bin/bash
. /etc/os-release
mkdir -p /etc/code-server-hub/util/jupyterhub_workdir

if dpkg --compare-versions "$VERSION_ID" "<=" "23.04"; then 
    pip3 install --upgrade pip
    pip3 install jupyterlab jupyterhub
    pip3 install markupsafe==2.0.1
    npm install -g configurable-http-proxy
    echo "[Unit]
Description=Jupyterhub
After=syslog.target network.target

[Service]
User=root
WorkingDirectory=/etc/code-server-hub/util/jupyterhub_workdir
Environment="PATH=/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin"
ExecStart=/usr/local/bin/jupyterhub -f jupyterhub_config.py

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/jupyterhub.service
else
    apt-get install -y pipenv
    cd /etc/code-server-hub/util/jupyterhub_workdir
    pipenv --python 3
    pipenv install jupyterhub
    npm install -g configurable-http-proxy
    echo "[Unit]
Description=Jupyterhub
After=syslog.target network.target

[Service]
User=root
WorkingDirectory=/etc/code-server-hub/util/jupyterhub_workdir
Environment="PATH=/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin"
ExecStart=/usr/bin/pipenv run jupyterhub -f jupyterhub_config.py

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/jupyterhub.service
fi

cd /etc/code-server-hub/util/jupyterhub_workdir
# jupyterhub --generate-config
# sed -i "s/#c.Spawner.default_url = ''/c.Spawner.default_url = '\/lab'/g" jupyterhub_config.py
# sed -i "s/#c.JupyterHub.ssl_cert = ''/c.JupyterHub.ssl_cert = '\/etc\/code-server-hub\/cert\/ssl.pem'/g" jupyterhub_config.py
# sed -i "s/#c.JupyterHub.ssl_key = ''/c.JupyterHub.ssl_key = '\/etc\/code-server-hub\/cert\/ssl.key'/g" jupyterhub_config.py
# sed -i "s/# c.Spawner.default_url = ''/c.Spawner.default_url = '\/lab'/g" jupyterhub_config.py
# sed -i "s/# c.JupyterHub.ssl_cert = ''/c.JupyterHub.ssl_cert = '\/etc\/code-server-hub\/cert\/ssl.pem'/g" jupyterhub_config.py
# sed -i "s/# c.JupyterHub.ssl_key = ''/c.JupyterHub.ssl_key = '\/etc\/code-server-hub\/cert\/ssl.key'/g" jupyterhub_config.py
# sed -i "s/# c.JupyterHub.port = ''/c.JupyterHub.port = 18517'/g" jupyterhub_config.py

echo "import os
c.JupyterHub.port = 18517
c.JupyterHub.ssl_key = '/etc/code-server-hub/cert/ssl.key'
c.JupyterHub.ssl_cert = '/etc/code-server-hub/cert/ssl.pem'
c.Spawner.default_url = '/lab'
c.FileCheckpoints.checkpoint_dir = os.path.expanduser('~/.ipynb_checkpoints')
c.PAMAuthenticator.open_sessions = True
" > jupyterhub_config.py


systemctl enable --now jupyterhub
systemctl start jupyterhub
