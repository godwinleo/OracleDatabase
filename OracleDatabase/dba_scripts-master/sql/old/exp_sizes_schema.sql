define schema=&1
col job_id for 999999
col dmp_gb for 999.99
select elf.JOB_ID
, q.db_sid, q.schema_name, q.book_date, q.bkp_mode
, round(sum(dmpsize/1024/1024/1024),2) dmp_GB
, to_char(max(created),'YYYY-MON-DD HH24:MI:SS') creation_time
from exp_log_file elf, exp_queue q
where q.schema_name like upper ('&schema')
and elf.job_id=q.job_id
group by elf.job_id, q.db_sid, q.SCHEMA_NAME, q.book_date, q.bkp_mode
having max(created) > trunc(sysdate-7)
--order by max(created)
order by q.db_sid, q.schema_name, q.book_date
/
