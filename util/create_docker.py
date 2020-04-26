import os
import sys
import itertools
import subprocess

image_name = "whojk/code-server-hub-docker"

username  = sys.argv[1]
sock_path = sys.argv[2]
envs_path = sys.argv[3]
sock_fold = os.path.dirname(sock_path)


def getDataFolder(username):
    return ["data","/mnt"]
    
def getDataParam(username):
    user_available_folder = getDataFolder(username)
    return list(itertools.chain(*map(list,(zip(["-v"]*len(user_available_folder),["{origpath}:/root/{index}-{fname}".format(origpath=fpath,index=str(i),fname=list(filter(None,fpath.split("/")))[-1]) for i,fpath in enumerate(user_available_folder)])))))

def getGPUParam(username):
    return "all"

with open(envs_path,"w") as envsF:
    envsF.write("SOCKPATH=" + sock_path + "\n")
    envsF.write("USERNAME=" + username + "\n")
    envsF.write("PASSWORD=" + input())

try:
    os.remove(sock_path)
except:
    pass

subprocess.call(["docker", "run" ,"-it" ,"-d" , "--cap-add=SYS_PTRACE", "--security-opt seccomp=unconfined", "--name" , "docker-"+username ,"--env-file" ,envs_path ,"--gpus", getGPUParam(username), "-v" , sock_fold+":"+sock_fold] + getDataParam(username) +[image_name])

subprocess.call(['docker', "start" ,"docker-"+username ])
