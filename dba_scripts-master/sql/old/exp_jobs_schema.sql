define schema=&1
col job_id for 999999
col dmp_gb for 999.99
col status for a8
select q.JOB_ID
, q.db_sid, q.schema_name, q.book_date, q.bkp_mode
, q.status
, round(sum(dmpsize/1024/1024/1024),2) dmp_GB
, to_char(max(created),'YYYY-MON-DD HH24:MI:SS') creation_time
,to_char(q.started,'YYYY-MON-DD HH24:MI:SS' ), to_char(q.finished,'YYYY-MON-DD HH24:MI:SS')
, round((q.finished-q.started)*60*24,2) min_elapsed
from exp_log_file elf, exp_queue q
where q.schema_name like upper ('&schema')
and elf.job_id (+)=q.job_id
--and bkp_mode ='EOM'
group by q.job_id, q.db_sid, q.SCHEMA_NAME, q.book_date, q.status, q.bkp_mode, q.started, q.finished
having max(book_date) > trunc(sysdate-7)
--having max(book_date) between to_Date('2012-10-21','YYYY-MM-DD') and to_Date('2013-10-21','YYYY-MM-DD')
--order by max(created)
order by book_date
/
