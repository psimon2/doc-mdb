#!/bin/bash
apt update
apt install -y python3 python3-pip libffi-dev unzip
apt autoremove -y
export ydb_dist=/opt/yottadb/current
export ydb_gbldir=/data/r2.02_x86_64/g/yottadb.gld
export ydb_dir=/data
export ydb_rel=r2.02_x86_64
export ydb_routines="/data/r2.02_x86_64/r(/data/r2.02_x86_64/r) /opt/yottadb/current/plugin/o/_ydbaim.so /opt/yottadb/current/plugin/o/_ydbgui.so /opt/yottadb/current/plugin/o/_ydbmwebserver.so /opt/yottadb/current/plugin/o/_ydbocto.so /opt/yottadb/current/plugin/o/_ydbposix.so /opt/yottadb/current/libyottadbutil.so"
export ydb_icu_version=70.1
export ydb_xc_ydbposix=/usr/local/lib/yottadb/latest/plugin/ydbposix.xc
pip3 install yottadb
$ydb_dist/mupip SET -NULL_SUBSCRIPTS=true -region DEFAULT
$ydb_dist/mupip set -journal=off -region DEFAULT
$ydb_dist/mupip set -access_method=mm -region DEFAULT
$ydb_dist/dse d -f
cp /home/mumps/*.m /data/r2.02_x86_64/r
cp /home/fhir/fhir.zip /tmp
cd /tmp 
unzip fhir.zip
cp /home/python/xpath_v2.py /tmp
python3 /tmp/xpath_v2.py '/tmp/fhir.nor.txt' '/tmp/xpath_patient.txt'
python3 /tmp/xpath_v2.py '/tmp/fhir.eoc.txt' '/tmp/xpath_eoc.txt'
ydb <<< 'do IDXPATH2^CONSUMER("/tmp/xpath_patient.txt","nor")'
ydb <<< 'do STT^CONSUMER("nor","/tmp/xpath_patient.txt")'
ydb <<< 'do IDXPATH2^CONSUMER("/tmp/xpath_eoc.txt","eoc")'
ydb <<< 'do STT^CONSUMER("eoc","/tmp/xpath_eoc.txt")'
mkdir /srv/nornu
cp /home/javascript/index.html /srv/nornu
cp /home/python/calltab.ci /srv
cp /home/python/mumps_srv_v5.py /srv
pip install flask
pip install flask-cors
cd /home/provision
sleep 5
cat provision.sql | /opt/yottadb/current/plugin/bin/octo