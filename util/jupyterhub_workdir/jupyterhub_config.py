import os
c.JupyterHub.port = 18517
c.JupyterHub.ssl_key = '/etc/code-server-hub/cert/ssl.key'
c.JupyterHub.ssl_cert = '/etc/code-server-hub/cert/ssl.pem'
c.Spawner.default_url = '/lab'
c.Spawner.environment = {
    "JUPYTER_CONFIG_DIR": lambda spawner: f"/etc/code-server-hub/util/jupyterhub_workdir/jupyter_conf/{spawner.user.name}",
}
c.FileContentsManager.checkpoints_kwargs = {'root_dir': '/tmp/jupyter_checkpoints'}
c.PAMAuthenticator.open_sessions = True
c.Authenticator.allow_all = True
