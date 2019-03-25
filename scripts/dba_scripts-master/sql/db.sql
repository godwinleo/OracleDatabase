col name for a10
col current_scn for 999999999999999
col controlfile_change# heading CF_CHANGE# for 999999999999999
col controlfile_sequence# heading CF_SEQ# for 99999999999
col flashback_on for a5
select name
,dbid
,created,open_mode,log_mode,flashback_on
,current_scn,force_logging,database_role
,switchover_status 
,controlfile_change#,controlfile_sequence#,controlfile_type,controlfile_time
from v$database;
