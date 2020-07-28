#!/bin/bash
set -x
set -e
export DEBIAN_FRONTEND=noninteractive
echo "Install kaldi"

#mkdir /usr/share/srilm
#mv srilm-1.7.3.tar.gz /usr/share/srilm/
#cd /usr/share/srilm
#tar xvf srilm-1.7.3.tar.gz
#
#sed -i 's/^# SRILM = .*/SRILM = \/usr\/share\/srilm/' Makefile
#sed -i 's/^MACHINE_TYPE := .*/MACHINE_TYPE = i686-m64/' Makefile
#make MACHINE_TYPE=i686-m64 World

#dependency for kaldi and espnet
apt-get -y update
apt-get -y --allow-change-held-packages install g++ gcc make automake autoconf bzip2 unzip sox libtool subversion zlib1g-dev gfortran patch ffmpeg build-essential
apt-get -y --allow-change-held-packages install cmake curl g++ graphviz libatlas3-base libtool pkg-config subversion zlib1g-dev tcl tcl-dev tcsh libsndfile1-dev flac libnccl2 libnccl-dev
rm -rf /var/lib/apt/lists/* ; localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 ; locale-gen en_US.UTF-8

git clone --depth 1 https://github.com/kaldi-asr/kaldi.git /usr/share/kaldi-asr 
cd /usr/share/kaldi-asr/tools
curl 'http://www.speech.sri.com/projects/srilm/srilm_download.php' \
  -H 'Connection: keep-alive' \
  -H 'Cache-Control: max-age=0' \
  -H 'Upgrade-Insecure-Requests: 1' \
  -H 'Origin: http://www.speech.sri.com' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.106 Safari/537.36' \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
  -H 'Referer: http://www.speech.sri.com/projects/srilm/download.html' \
  -H 'Accept-Language: zh-TW,zh;q=0.9,en-US;q=0.8,en;q=0.7,zh-CN;q=0.6' \
  --data-raw 'WWW_file=srilm-1.7.3.tar.gz&WWW_name=rgfs&WWW_org=vfrswrf&WWW_address=sfvsrv&WWW_email=sv&WWW_url=&WWW_list=no' \
  --compressed \
  --insecure \
  -o srilm.tgz

bash install_pfile_utils.sh
bash install_portaudio.sh
bash install_speex.sh
bash install_srilm.sh
bash /usr/share/kaldi-asr/tools/extras/install_mkl.sh
rm srilm.tgz
make -j $(nproc)
cd /usr/share/kaldi-asr/src
./configure --shared --use-cuda
make depend -j $(nproc)
make -j $(nproc)

exit 0
