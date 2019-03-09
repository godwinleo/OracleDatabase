col job for a20
col status for a10
col log_date for a35
col ADDITIONAL_INFO for a105 word_wrapped
define name=&1
select owner||'.'||job_name job
,log_date
,status, error#, ADDITIONAL_INFO
from dba_scheduler_job_run_details
where job_name like nvl('&name','%')
and log_date > sysdate-7 
order by log_date
/
