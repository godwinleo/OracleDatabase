col inst for 99
col host for a15
col thread# for 99
col instance_number for 99
col database_status for a10
col status for a10
col version for a10
select
 INSTANCE_NUMBER inst
 ,INSTANCE_NAME
 ,substr(HOST_NAME,1,instr(HOST_NAME,'.',1)-1) host
 ,VERSION
 ,STARTUP_TIME
 ,STATUS
 ,PARALLEL
 ,THREAD#
 ,ARCHIVER
 ,LOG_SWITCH_WAIT
 ,LOGINS
 ,SHUTDOWN_PENDING
 ,DATABASE_STATUS
 ,INSTANCE_ROLE
 ,ACTIVE_STATE
 ,BLOCKED
from v$instance;
