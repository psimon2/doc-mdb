#!/bin/bash
export ydb_dist=/opt/yottadb/current
export ydb_gbldir=/data/r2.02_x86_64/g/yottadb.gld
export ydb_dir=/data
export ydb_rel=r2.02_x86_64
export ydb_routines="/data/r2.02_x86_64/r(/data/r2.02_x86_64/r) /opt/yottadb/current/plugin/o/_ydbaim.so /opt/yottadb/current/plugin/o/_ydbgui.so /opt/yottadb/current/plugin/o/_ydbmwebserver.so /opt/yottadb/current/plugin/o/_ydbocto.so /opt/yottadb/current/plugin/o/_ydbposix.so /opt/yottadb/current/libyottadbutil.so"
export ydb_icu_version=70.1
export ydb_xc_ydbposix=/usr/local/lib/yottadb/latest/plugin/ydbposix.xc
/opt/yottadb/current/ydb -run %ydbgui --readwrite --port 9081 &
cd /srv
python3 mumps_srv_v5.py