define schema=&1
col DB_SID for a7
col TGT_SCHEMA for a12
col profile_name for a5
col IMP_MODE for a6
col ENABLE for 999
col status for a10

select 
 prof.PROFILE_ID
,prof.PROFILE_NAME
,prof.SCHEMA_ID
,prof.TRUNCATE_ID
,prof.REMAP_DB_ID
,prof.TGT_SCHEMA
,prof.SCRAMBLE_ID
,prof.PASSWORD
,prof.IMP_MODE
,prof.RUN
,prof.CFG_ID
,prof.STATUS
,prof.TAB_PROF_ID
,prof.JUST_PROF_TAB
,prof.GLOBAL_RETENTION
from DBADMIN.IMP_PROFILE prof
, dbadmin.imp_Schema sch
where prof.TGT_SCHEMA like upper('&schema')
and prof.schema_id=sch.schema_id
and sch.status='ENABLED'
order by prof.schema_id, prof.profile_id
/

