col username for a20
col server for a15
col db_name for a15
col db_unique_name for a15
col hoy for a25
col schema for a20
col sid for a10
select 
to_char(sysdate,'YYYY-MON-DD HH24:MI:SS') hoy
, SYS_CONTEXT ('USERENV', 'SERVER_HOST') server
, SYS_CONTEXT ('USERENV', 'DB_NAME') db_name
, SYS_CONTEXT ('USERENV', 'DB_UNIQUE_NAME') db_unique_name
,SYS_CONTEXT ('USERENV', 'SID') sid
,SYS_CONTEXT ('USERENV', 'SESSION_USER') username
,SYS_CONTEXT ('USERENV', 'CURRENT_SCHEMA') schema
from dual;
