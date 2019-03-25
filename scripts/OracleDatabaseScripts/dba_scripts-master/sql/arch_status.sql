col dest_name for a20 truncated
col destination for a10 truncated
col error for a10 truncated
col "archive_thr/seq" for a15
col "applied_thr/seq" for a15
col gap_status for a10
col db_unique_name for a10 truncated
select 
--DEST_ID, DEST_NAME ,STATUS ,TYPE ,
DESTINATION ,DATABASE_MODE ,RECOVERY_MODE ,PROTECTION_MODE
,STANDBY_LOGFILE_COUNT stdby_logs
--,STANDBY_LOGFILE_ACTIVE 
,ARCHIVED_THREAD#||':'||ARCHIVED_SEQ# "archive_thr/seq", APPLIED_THREAD#||':'||APPLIED_SEQ# "applied_thr/seq"
,ERROR ,SRL 
--,DB_UNIQUE_NAME
,SYNCHRONIZATION_STATUS ,SYNCHRONIZED ,GAP_STATUS
from V$ARCHIVE_DEST_STATUS
where status!='INACTIVE'
--and type!='LOCAL';
