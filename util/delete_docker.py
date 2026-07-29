import os
import sys
import itertools
import subprocess

import engine_util

engine_cmd = engine_util.engine_cmd()

username  = sys.argv[1]
sock_path = sys.argv[2]
envs_path = sys.argv[3]
# this script is a sudo entrypoint for www-data: validate argv before use
username, sock_path, envs_path = engine_util.validate_untrusted_args(username, sock_path, envs_path)
sock_fold = os.path.dirname(sock_path)

try:
    os.remove(sock_path)
except:
    pass
outs, errs = subprocess.Popen(engine_cmd + ["stop" , "docker-"+username]).communicate()
print(outs, errs)
outs, errs = subprocess.Popen(engine_cmd + ["rm" , "docker-"+username]).communicate()
print(outs, errs)

