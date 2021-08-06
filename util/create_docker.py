import os
import sys
import itertools
import subprocess
from pathlib import Path

image_name_cpu = "whojk/code-server-hub-docker:minimal"
image_name_gpu = "whojk/code-server-hub-docker:basicML"

username  = sys.argv[1]
useruid = subprocess.Popen(["id", "-u", username], stdout=subprocess.PIPE).communicate()[0].decode("utf8")[:-1]
usergid = subprocess.Popen(["id", "-g", username], stdout=subprocess.PIPE).communicate()[0].decode("utf8")[:-1]
homedir =  subprocess.Popen(["bash", "-c", "echo ~" + username], stdout=subprocess.PIPE).communicate()[0].decode("utf8")[:-1]
sock_path = sys.argv[2]
envs_path = sys.argv[3]
sock_fold = os.path.dirname(sock_path)

os.makedirs(os.path.dirname(sock_path),mode=0o333,exist_ok=True)
os.makedirs(os.path.dirname(envs_path),mode=0o333,exist_ok=True)

mem_bytes = os.sysconf('SC_PAGE_SIZE') * os.sysconf('SC_PHYS_PAGES')
shm_size = str(max(64,int( mem_bytes/(1024.**2)/2)))+"m"



def getDataParam(username):
    user_available_folder = ["{p}:{p}".format(p=p) for p in ["/data/local",homedir]] + ["{p}:{p}:ro".format(p=p) for p in ["/data","/etc/localtime" , str(Path("/etc/localtime").resolve())]] + [envs_path+":/etc/code-server-hub/ENVSFILE:ro"]
    return list(itertools.chain(*map(list,(zip(["-v"]*len(user_available_folder),[fpath for fpath in user_available_folder])))))

def getGPUParam(username):
    return "all"

with open(envs_path,"w") as envsF:
    envsF.write("SOCKPATH=" + sock_path + "\n")
    envsF.write("USERNAME=" + username + "\n")
    envsF.write("USERUID=" + useruid + "\n")
    envsF.write("USERGID=" + usergid + "\n")
    envsF.write("HOMEDIR=" + homedir + "\n")
    envsF.write("PASSWORD=" + input())
    envsF.flush()

try:
    os.remove(sock_path)
except:
    pass


has_gpu = []
image_name = image_name_cpu

outs, errs = subprocess.Popen(["docker run --rm --gpus all nvidia/cuda:11.2.0-base-ubuntu20.04 nvidia-smi"], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
if len(outs) > 0:
    has_gpu = ["--gpus", getGPUParam(username)]
    image_name = image_name_gpu
print(has_gpu)


stopc = ['docker', "stop" , "docker-"+username] 
subprocess.call(stopc)

runc = ["docker", "run" ,"-it" ,"-d" , "--cap-add=SYS_PTRACE", "--security-opt", "seccomp=unconfined","--shm-size=" + shm_size , "--name" , "docker-"+username , "--hostname" , "docker-"+username ] + has_gpu + [ "-v" , sock_fold+":"+sock_fold] + getDataParam(username) +[image_name]
subprocess.call(runc)

startc = ['docker', "start" ,"docker-"+username ]
subprocess.call(startc)

