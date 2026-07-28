#!/usr/bin/python3
# Resolve which container engine (docker or rootful podman) this host uses.
# The engine is recorded in config.json by install.sh; default is docker.
import os
import json

CONFIG_PATHS = [
    "/etc/code-server-hub/config.json",
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "config.json"),
]

def get_config():
    for path in CONFIG_PATHS:
        if os.path.isfile(path):
            with open(path) as f:
                return json.load(f)
    return {}

def get_engine():
    engine = get_config().get("engine", "docker")
    if engine not in ("docker", "podman"):
        raise ValueError("config.json: unsupported engine: " + engine)
    return engine

def engine_cmd():
    engine = get_engine()
    if engine == "podman" and os.geteuid() != 0:
        # rootful podman: non-root callers (www-data from openresty) go through
        # the sudoers entry installed by install.sh
        return ["sudo", "-n", "/usr/bin/podman"]
    return [engine]

def normalize_gpu_value(value):
    # gpuuser.json value: "all", or a list of GPU indices / UUIDs
    if isinstance(value, list):
        return value
    if isinstance(value, str):
        v = value.strip().strip('"').strip("'")
        if v == "all":
            return "all"
        # backward compat with the old docker --gpus syntax, e.g. "\"device=0,1\""
        if v.startswith("device="):
            v = v[len("device="):]
        return [g for g in v.split(",") if g != ""]
    raise ValueError("gpuuser.json: unsupported value: " + repr(value))

def gpu_args(value):
    gpus = normalize_gpu_value(value)
    if get_engine() == "podman":
        if gpus == "all":
            return ["--device", "nvidia.com/gpu=all"]
        args = []
        for g in gpus:
            args += ["--device", "nvidia.com/gpu={}".format(g)]
        return args
    if gpus == "all":
        return ["--gpus", "all"]
    if len(gpus) == 0:
        return []
    return ["--gpus", '"device={}"'.format(",".join(str(g) for g in gpus))]
