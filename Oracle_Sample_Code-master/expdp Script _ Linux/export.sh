#!/usr/bin/sh
#Author: Osama Mustafa
#Date  : 27-NOV-12
#Rev.  : 1.0
#Name  : export
#Remark: generate expdp script
#load Backup oraenv.sh
/u01/Backup/scripts/oraenv.sh

expdp $DB_CRED directory=$DP_DIR dumpfile=$ORACLE_SID-$DATE_STRING.dmp logfile=Backup_LOG_DIR:$ORACLE_SID-$DATE_STRING.log schemas=$SCHEMAS_STRING compression=ALL job_name=export_$DATE_STRING parallel=1 cluster=N

