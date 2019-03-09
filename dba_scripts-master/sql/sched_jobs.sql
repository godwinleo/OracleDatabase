col job for a35
col action for a55 word_wrapped
col schedule for a42 truncated word_wrapped
col PROGRAM_NAME for a25
col schedule_type for a15
col next_run_Date for a15 truncated
col state for a10
define name=&1
select owner||'.'||job_name job
--,enabled
,state,nvl(job_action,program_name) action,nvl(REPEAT_INTERVAL,schedule_name) schedule,schedule_type
, next_run_date
from dba_scheduler_jobs
where enabled!='FALSE'
and job_name like nvl('&name','%')
order by schedule_type
/
