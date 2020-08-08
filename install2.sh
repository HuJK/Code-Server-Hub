#!/bin/bash

{ # try
    pip3 -V
} || { # catch
    # save log for exception 
    echo "=========================================================================="
    while true; do
        read -p "pip3 has problem, trying to fix now?? (Yes/No/Abort)" yn
        case $yn in
            [Yy]* ) 
                # Nvidia-Docker
                apt purge python3-pip
                wget https://bootstrap.pypa.io/get-pip.py
                python3 get-pip.py
                break;;
            [Aa]* ) 
                echo "Aborted";
                exit;;
            [Nn]* ) 
                echo "Skipped";
                break;;
            * ) echo "Please answer yes or no or abort.";;
        esac
    done
}

pip3 install --upgrade pip
pip3 install jupyterlab jupyterhub
npm install -g configurable-http-proxy

mkdir -p /etc/code-server-hub/util/jupyterhub_workdir
cd /etc/code-server-hub/util/jupyterhub_workdir
jupyterhub --generate-config
sed -i "s/#c.Spawner.default_url = ''/c.Spawner.default_url = '\/lab'/g" jupyterhub_config.py
sed -i "s/#c.JupyterHub.ssl_cert = ''/c.JupyterHub.ssl_cert = '\/etc\/code-server-hub\/cert\/ssl.pem'/g" jupyterhub_config.py
sed -i "s/#c.JupyterHub.ssl_key = ''/c.JupyterHub.ssl_key = '\/etc\/code-server-hub\/cert\/ssl.key'/g" jupyterhub_config.py

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
systemctl enable --now jupyterhub
