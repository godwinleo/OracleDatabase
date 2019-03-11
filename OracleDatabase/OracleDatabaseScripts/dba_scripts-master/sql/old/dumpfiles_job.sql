define job=&1
col file_name for a90
select  job_id, file_name
,CREATED ,ZIPPED ,DELETED ,ZIPSIZE ,DMPSIZE ,BMODE
from dbadmin.exp_log_file
where job_id=&job
/
