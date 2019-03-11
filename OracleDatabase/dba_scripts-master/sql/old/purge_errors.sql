col log_id for 99999999
col job_id for 999
col process for a20
col ownname for a20
col tabname for a20
col message for a80
col severity for a10
define tab=&1
select LOG_ID,LOG_DATE,SEVERITY,PROCESS,OWNNAME,TABNAME,MESSAGE
from dbadmin.dbs_purge_log
where ownname=(select ownname from dbadmin.dbs_purge_log where log_id=
	(select max(log_id) from dbadmin.dbs_purge_log))
and log_date >= trunc( sysdate-(nvl('&date',0)))
and tabname like upper('&tab')
and severity='ERROR'
order by log_id
/
