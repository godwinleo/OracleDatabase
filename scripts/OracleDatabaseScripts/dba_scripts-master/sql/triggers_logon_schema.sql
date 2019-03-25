define owner=&1
col OWNER for a25
col TRIGGER_NAME for a30
col TRIGGER_TYPE for a15
col TRIGGERING_EVENT for a15
col TABLE_OWNER for a15
col BASE_OBJECT_TYPE for a15
col TABLE_NAME for a20
col COLUMN_NAME for a15
col REFERENCING_NAMES for a15
col WHEN_CLAUSE for a15
col STATUS for a15
col DESCRIPTION for a40
col ACTION_TYPE for a15
col TRIGGER_BODY for a15
select OWNER ,TRIGGER_NAME ,TRIGGER_TYPE ,TRIGGERING_EVENT ,TABLE_OWNER 
--,COLUMN_NAME ,REFERENCING_NAMES ,WHEN_CLAUSE 
,STATUS,ACTION_TYPE  
--,DESCRIPTION
--,TRIGGER_BODY
from dba_triggers
where table_owner like upper('&owner')
and trigger_type='AFTER EVENT' 
and triggering_event like 'LOGON '
/
