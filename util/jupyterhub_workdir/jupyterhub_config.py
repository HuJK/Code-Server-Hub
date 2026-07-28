import os
VENV_PATH = '/etc/code-server-hub/util/jupyterhub_workdir/venv'
c.JupyterHub.port = 18517
# Use the node/configurable-http-proxy installed in the venv by nodeenv,
# so the hub never falls back to a system-wide nodejs
c.ConfigurableHTTPProxy.command = [
    VENV_PATH + '/bin/node',
    VENV_PATH + '/lib/node_modules/configurable-http-proxy/bin/configurable-http-proxy',
]
c.JupyterHub.ssl_key = '/etc/code-server-hub/cert/ssl.key'
c.JupyterHub.ssl_cert = '/etc/code-server-hub/cert/ssl.pem'
c.Spawner.default_url = '/lab'
c.Spawner.environment = {
    "JUPYTER_CONFIG_DIR": lambda spawner: f"/etc/code-server-hub/util/jupyterhub_workdir/jupyter_conf/{spawner.user.name}",
}
c.FileContentsManager.checkpoints_kwargs = {'root_dir': '/tmp/jupyter_checkpoints'}
c.PAMAuthenticator.open_sessions = True
c.Authenticator.allow_all = True
