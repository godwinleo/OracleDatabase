define job=&1
 col LOG_ID for 9999999999
 col JOB_ID for 99999999
 col LOG_DATE for a20
 col PROCESS for a20
 col ERR_MSG for a89 word_wrapped
 col ERR_CODE for a9

select LOG_ID
,JOB_ID
,to_char(LOG_DATE,'YYYY-MON-DD HH24:MI:SS') log_date
,PROCESS
,ERR_MSG
,ERR_CODE
from imp_log_trace
where job_id=&job
order by log_id
/
