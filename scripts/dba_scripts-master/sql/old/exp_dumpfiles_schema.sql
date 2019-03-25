define schema=&1
col job_id for 999999
col db_sid for a8
col schema_name for a12
col file_name for a95 truncated
col zip_mb for 999.99
col dmp_mb for 999.99
select queue.JOB_ID, queue.db_sid, queue.schema_name
,FILE_NAME ,to_char(CREATED,'YYYY-MON-DD HH24:MI') creation_time
--,to_char(ZIPPED,'YYYY-MON-DD HH24:MI') zipped 
,to_char(DELETED,'YYYY-MON-DD HH24:MI') DELETED 
--, round(zipsize/1024/1024/1024,2) zip_MB
, round(dmpsize/1024/1024/1024,2) dmp_MB
,BMODE
from exp_log_file dumps
, exp_queue queue
where dumps.job_id = queue.job_id
and queue.schema_name like upper ('&schema')
--and queue.db_sid like 'db_sid'
and created > trunc(sysdate)-60
order by created
/
