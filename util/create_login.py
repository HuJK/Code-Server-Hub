#!/usr/bin/python3
import os.path
sockpath = input()
if not os.path.isfile(sockpath[:-4] + "login"):
    with open(sockpath[:-4] + "login","w") as loginpath:
        loginpath.write("1")
