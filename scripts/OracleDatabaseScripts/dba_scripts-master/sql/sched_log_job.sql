col job for a20
col status for a10
col log_date for a35
col ADDITIONAL_INFO for a100 word_wrapped
define name=&1
select owner||'.'||job_name job
,log_date
,status, ADDITIONAL_INFO
from DBA_SCHEDULER_JOB_LOG
where job_name like nvl('&name','%')
and log_date > sysdate-7 
order by log_date
/
