col ljob_id for 9999
col remote_job_id for 9999
col severity for 9
col runtime for a18 truncated
col module for a10
col message for a130 word_wrapped

select LJOB_ID 
--,REMOTE_JOB_ID 
,RUNTIME ,SEVERITY
,MODULE ,MESSAGE
from dbadmin.fortidb_local_log
where ljob_id = (select max( ljob_id) 
		from dbadmin.fortidb_local_log)
and severity > 0
order by log_id
/
