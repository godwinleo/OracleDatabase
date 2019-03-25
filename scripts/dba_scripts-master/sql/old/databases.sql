col DB_SID for a10
col SERVERNAME for a13
col ENVIRONMENT for a10
col TNS_ALIAS for a15
col TNS_PORT for 99999
col ORACLE_HOME for a40
col VERSION for a10
col STATUS for a10
col DESCRIPTION for a55 truncated
select 
DB_SID ,SERVERNAME ,ENVIRONMENT ,TNS_ALIAS ,TNS_PORT ,ORACLE_HOME ,VERSION ,STATUS ,DESCRIPTION
from dbadmin.databases
where status='ACTIVE'
order by environment,servername,db_sid;
