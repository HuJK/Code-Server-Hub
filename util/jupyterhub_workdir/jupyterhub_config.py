import os
c.JupyterHub.port = 18517
c.JupyterHub.ssl_key = '/etc/code-server-hub/cert/ssl.key'
c.JupyterHub.ssl_cert = '/etc/code-server-hub/cert/ssl.pem'
c.Spawner.default_url = '/lab'
c.Spawner.environment = {
    "JUPYTER_CONFIG_DIR": lambda spawner: f"/etc/code-server-hub/util/jupyterhub_workdir/jupyter_conf/{spawner.user.name}",
}
c.FileCheckpoints.checkpoint_dir = lambda spawner: f"/tmp/.jupyter/checkpoint/{spawner.user.name}"
c.PAMAuthenticator.open_sessions = True
c.Authenticator.allow_all = True
