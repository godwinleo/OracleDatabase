define job=&1
col job_id for 999999
col file_name for a95 truncated
col zip_mb for 999.99
col dmp_mb for 999.99
select JOB_ID,FILE_NAME ,to_char(CREATED,'YYYY-MON-DD HH24:MI') created 
--,to_char(ZIPPED,'YYYY-MON-DD HH24:MI') zipped 
,to_char(DELETED,'YYYY-MON-DD HH24:MI') DELETED 
--, round(zipsize/1024/1024/1024,2) zip_MB
, round(dmpsize/1024/1024/1024,2) dmp_MB
,BMODE
from exp_log_file
where job_id=&job
order by file_name
/
