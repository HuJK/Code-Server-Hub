#!/bin/bash
set -x
set -e

git clone --depth 1 https://github.com/pykaldi/pykaldi.git /usr/share/pykaldi
cd  /usr/share/pykaldi/tools
bash check_dependencies.sh python3
bash install_protobuf.sh python3
bash install_clif.sh  python3
bash install_kaldi.sh pyhonn3

cd  /usr/share/pykaldi
python3 setup.py install

#delete self
rm /tmp/install3.sh

set +e



exit 0
