#!/bin/bash
set -x
adduser demo01 --gecos "Demo 01,,," --disabled-password
echo "demo01:demo)!" | chpasswd

adduser demo02 --gecos "Demo 02,,," --disabled-password
echo "demo02:demo)@" | chpasswd

adduser demo03 --gecos "Demo 03,,," --disabled-password
echo "demo03:demo)#" | chpasswd

echo "root:DockerATheroku" | chpasswd

