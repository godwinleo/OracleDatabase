select
--DEST_ID,
remote.DESTINATION 
, DEST_NAME ,STATUS ,TYPE
,DATABASE_MODE ,RECOVERY_MODE ,PROTECTION_MODE
--,STANDBY_LOGFILE_COUNT stdby_logs
--,STANDBY_LOGFILE_ACTIVE
,remote.ARCHIVED_THREAD#
,remote.ARCHIVED_SEQ# --,remote.APPLIED_SEQ#
,local.applied - remote.ARCHIVED_SEQ# APPLIED_GAP
--,local.applied - remote.APPLIED_SEQ# APPLIED_GAP
,local.applied - arch.shipped SHIPPED_GAP
--, APPLIED_THREAD#||':'||APPLIED_SEQ# "applied_thr/seq"
from V$ARCHIVE_DEST_STATUS remote
, ( select DEST_ID, DESTINATION, ARCHIVED_THREAD#, ARCHIVED_SEQ# applied
		from V$ARCHIVE_DEST_STATUS 
		where type='LOCAL' and status!='INACTIVE'
		) local
, ( select dest_id, max(sequence#) shipped from v$archived_log
	group by dest_id
	) arch
where 
 status!='INACTIVE'
-- and type!='LOCAL' 
 and remote.ARCHIVED_THREAD#=local.ARCHIVED_THREAD#
 and remote.dest_id=arch.dest_id
/
