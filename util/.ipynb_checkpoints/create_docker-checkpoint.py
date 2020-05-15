import os
import sys
import itertools
import subprocess


image_name = "whojk/code-server-hub-docker"

username  = sys.argv[1]
useruid = subprocess.Popen(["id", "-u", username], stdout=subprocess.PIPE).communicate()[0].decode("utf8")[:-1]
usergid = subprocess.Popen(["id", "-g", username], stdout=subprocess.PIPE).communicate()[0].decode("utf8")[:-1]
homedir =  subprocess.Popen(["bash", "-c", "echo ~" + username], stdout=subprocess.PIPE).communicate()[0].decode("utf8")[:-1]
sock_path = sys.argv[2]
envs_path = sys.argv[3]
sock_fold = os.path.dirname(sock_path)


mem_bytes = os.sysconf('SC_PAGE_SIZE') * os.sysconf('SC_PHYS_PAGES')
shm_size = str(max(64,int( mem_bytes/(1024.**2)/2)))+"m"


def getDataFolder(username):
    return ["/data:/data" , homedir+":"+homedir , envs_path+":"+"/etc/code-server-hub/ENVSFILE"]

def getDataParam(username):
    user_available_folder = getDataFolder(username)
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

try:
    os.remove(sock_path)
except:
    pass

subprocess.call(['docker', "stop" , "docker-"+username] )

subprocess.call(["docker", "run" ,"-it" ,"-d" , "--cap-add=SYS_PTRACE", "--security-opt", "seccomp=unconfined","--shm-size=" + shm_size , "--name" , "docker-"+username ,"--gpus", getGPUParam(username), "-v" , sock_fold+":"+sock_fold] + getDataParam(username) +[image_name])

subprocess.call(['docker', "start" ,"docker-"+username ])

