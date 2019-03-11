define schema=&1
define date=&2
col job_id for 999999
col db_sid for a8
col schema_name for a12
col file_name for a90 truncated
col zip_mb for 999.99
col dmp_mb for 999.99
col servername for a15

select queue.JOB_ID, queue.SERVERNAME, queue.db_sid, queue.schema_name
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
and to_char(queue.book_date,'YYYYMMDD') like '%&date%'
--and queue.db_sid like 'db_sid'
--and created > trunc(sysdate)-60
--and file_name like '%monthly%'
and bmode ='EOM'
order by created
/
