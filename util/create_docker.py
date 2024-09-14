import os
import subprocess
import re
import sys
import itertools
import subprocess
import pathlib
import json
from pathlib import Path

os.chdir(pathlib.Path(__file__).parent.resolve())

username  = sys.argv[1]
useruid = subprocess.Popen(["id", "-u", username], stdout=subprocess.PIPE).communicate()[0].decode("utf8")[:-1]
usergid = subprocess.Popen(["id", "-g", username], stdout=subprocess.PIPE).communicate()[0].decode("utf8")[:-1]
homedir =  subprocess.Popen(["bash", "-c", "echo ~" + username], stdout=subprocess.PIPE).communicate()[0].decode("utf8")[:-1]
sock_path = sys.argv[2]
envs_path = sys.argv[3]
password = sys.argv[4] if len(sys.argv) >=5 else input()
sock_fold = os.path.dirname(sock_path)
gpuuser = {"*":"all"}
if os.path.isfile("/etc/code-server-hub/util/gpuuser.json"):
    gpuuser = json.loads(open("/etc/code-server-hub/util/gpuuser.json").read())

os.makedirs(os.path.dirname(sock_path),mode=0o333,exist_ok=True)
os.makedirs(os.path.dirname(envs_path),mode=0o333,exist_ok=True)

mem_bytes = os.sysconf('SC_PAGE_SIZE') * os.sysconf('SC_PHYS_PAGES')
shm_size = str(max(64,int( mem_bytes/(1024.**2)/2)))+"m"

def get_docker_version():
    try:
        result = subprocess.run(['docker', '--version'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if result.returncode == 0:
            version_output = result.stdout.strip()
            version_match = re.search(r'Docker version (\d+\.\d+\.\d+)', version_output)
            if version_match:
                version_str = version_match.group(1).split(".")
                version_int = [int(v) for v in version_str]
                return tuple(version_int)
            else:
                raise Exception("Error: Could not parse Docker version")
        else:
            raise Exception(f"Error: {result.stderr.strip()}")
    except FileNotFoundError:
        raise Exception("Error: Docker is not installed or not found in PATH")

docker_version = get_docker_version()

def getMountParam(username):
    rw_folders = [(p,p) for p in ["/data/local",homedir]]
    ro_folders = [(p,p) for p in ["/data"]]
    rro_folders = [(p,p) for p in ["/etc/localtime" , str(Path("/etc/localtime").resolve())]] + [(envs_path,"/etc/code-server-hub/ENVSFILE")]
    mount_options =  ["type=bind,source={s},target={d}".format(s=s,d=d) for s,d in rw_folders]
    mount_options += ["type=bind,readonly,source={s},target={d}".format(s=s,d=d) for s,d in rro_folders]
    if docker_version >= (25,0,0):
        mount_options += ["type=bind,readonly,bind-recursive=writable,source={s},target={d}".format(s=s,d=d) for s,d in ro_folders]
    else:
        mount_options += ["type=bind,readonly,source={s},target={d}".format(s=s,d=d) for s,d in ro_folders]
    param_ret = []
    for mount_opt in mount_options:
        param_ret += ["--mount" , mount_opt]
    return param_ret

def getGPUParam(username):
    if username in gpuuser:
        return gpuuser[username]
    return gpuuser["*"]

with open(envs_path,"w") as envsF:
    envsF.write("SOCKPATH=" + sock_path + "\n")
    envsF.write("USERNAME=" + username + "\n")
    envsF.write("USERUID=" + useruid + "\n")
    envsF.write("USERGID=" + usergid + "\n")
    envsF.write("HOMEDIR=" + homedir + "\n")
    envsF.write("PASSWORD=" +  password + "\n")
    envsF.flush()

try:
    os.remove(sock_path)
except:
    pass


has_gpu = []


get_docker_image_name = subprocess.Popen(["python3 get_docker_image_name.py"], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
image_name, errs = get_docker_image_name.communicate()
image_name = image_name.replace(b"\n",b"").decode("utf8")

if get_docker_image_name.returncode == 0:
    has_gpu = ["--gpus", getGPUParam(username)]

#print(has_gpu)

def run_command(command):
    print("$ " + " ".join(command), flush=True)
    subprocess.call(command, stderr=sys.stdout.buffer)
    print("", flush=True)

stopc = ['docker', "stop" , "docker-"+username] 
run_command(stopc)

stopc2 = ['sudo', '/etc/code-server-hub/util/close_docker.sh' , username]
run_command(stopc2)

runc = ["docker", "run" ,"-it" ,"-d" , "--cap-add=SYS_PTRACE", "--security-opt", "seccomp=unconfined","--shm-size=" + shm_size , "--name" , "docker-"+username , "--hostname" , "docker-"+username ] + has_gpu + [ "-v" , sock_fold+":"+sock_fold] + getMountParam(username) +[image_name]
run_command(runc)

startc = ['docker', "start" ,"docker-"+username ]
run_command(startc)
