define schema=&1
col DB_SID for a9
col SCHEMA_NAME for a12
col SERVERNAME for a13
col ENABLE for 99
col CRON_ID for 999
col APP_ID for 99999
col CFG_ID for 99
col BKP_MODE for a4
col MAX_DELAY for 999
col RETENTION for 999
col EOM for 999
col NICE for 999
col RETRY for 999
col JOBSIZE for 999,999,999
col RET_EOM for 999
col KLEOM for 999
col KLSTD for 999
col CLRORDER for 999
col schema_id for 9999
select DB_SID ,SERVERNAME 
,SCHEMA_NAME 
--,ENABLE
 ,CRON_ID ,APP_ID ,CFG_ID ,BKP_MODE
 ,MAX_DELAY ,RETENTION ,EOM ,NICE ,RETRY
 --,JOBSIZE 
,RET_EOM ,KLEOM ,KLSTD -- ,CLRORDER
 ,PS_MON_ID ,HIST_DATA ,HIST_ONLY ,TAB_DATA ,TAB_PROF_ID
 ,schema_id
from exp_schema
where schema_name like upper('&schema')
and enable > 0
--and servername like '%d'
order by servername, db_sid
/

