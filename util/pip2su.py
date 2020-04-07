#!/usr/bin/python3
import sys
import pexpect
print(sys.argv)
child = pexpect.spawn(sys.argv[1],sys.argv[2:])
password = input()
child.sendline(password)
print(child.read().decode("utf8"))
