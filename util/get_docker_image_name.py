#!/usr/bin/python3
import os
import sys
import itertools
import subprocess
import json
import pathlib
from pathlib import Path

os.chdir(pathlib.Path(__file__).parent.resolve())

image_name_base = "whojk/code-server-hub-docker:"
image_name_tags = json.loads(open("../Dockerfile/versions.json").read())

all_versions_str = {}
all_versions = []
for version_str in image_name_tags.keys():
    version = tuple(version_str.split("."))
    all_versions_str[version] = version_str
    all_versions += [version]

all_versions = sorted(all_versions,reverse=True)
#print(all_versions)
#print(all_versions_str)

outs_c, errs = subprocess.Popen(["docker run --rm --gpus all nvidia/cuda:11.2.2-base-ubuntu20.04 nvidia-smi"], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
if len(outs_c) > 0:
    outs , errs = subprocess.Popen(["nvidia-smi"], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
    if len(outs) > 0:
        outs = outs.decode("utf8")
        for outline in outs.split("\n"):
            if "CUDA Version" in outline:
                cuda_version = outline.split("CUDA Version:")[1]
                cuda_version = cuda_version.split("|")[0].strip()
                cuda_version = tuple(cuda_version.split("."))
                #print(cuda_version)
                for version in all_versions:
                    if cuda_version >= version:
                        print(image_name_base + image_name_tags[all_versions_str[version]])
                        exit(0)
                break
print(image_name_base + image_name_tags["0"])
exit(1)