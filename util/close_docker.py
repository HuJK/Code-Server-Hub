import os
import sys
import itertools
import subprocess

username  = sys.argv[1]
sock_path = sys.argv[2]
envs_path = sys.argv[3]
sock_fold = os.path.dirname(sock_path)

try:
    os.remove(sock_path)
except:
    pass
subprocess.call(['docker', "stop" , "docker-"+username] )
#subprocess.call(['sudo', '/etc/code-server-hub/util/close_docker.sh' , username] )

