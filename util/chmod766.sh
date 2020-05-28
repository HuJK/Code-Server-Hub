#!/bin/bash
set -x
n=0
until [ $n -ge 120 ]; do
  chmod 766 $1 && break
  n=$((n + 1))
  sleep 1
done
