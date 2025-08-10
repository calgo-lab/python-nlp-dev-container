# setup_jupyter.py

from jupyter_server.auth import passwd
import os

password_hash = passwd(os.environ.get("JUPYTER_PASS", "dev"))

config = f"""c = get_config()
c.ServerApp.ip = "0.0.0.0"
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.allow_origin = "*"
c.ServerApp.terminals_enabled = True
c.ServerApp.password = "{password_hash}"
"""

config_dir = "/etc/jupyter"
os.makedirs(config_dir, exist_ok=True)

with open(os.path.join(config_dir, "jupyter_lab_config.py"), "w") as f:
    f.write(config)
