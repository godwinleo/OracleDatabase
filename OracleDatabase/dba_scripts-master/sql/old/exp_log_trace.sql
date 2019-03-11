set pages 200
 col JOB_ID for 99999999
 col LOG_DATE for a20
 col PROCESS for a20
 col ERR_MSG for a110 word_wrapped
 col ERR_CODE for a9
select JOB_ID
 , to_char(LOG_DATE,'YYYY-MON-DD HH24:MI:SS') log_date
 , PROCESS
 , ERR_MSG
 , ERR_CODE
from exp_log_trace
where job_id=0
and log_date > sysdate-1/10
order by log_id
/
