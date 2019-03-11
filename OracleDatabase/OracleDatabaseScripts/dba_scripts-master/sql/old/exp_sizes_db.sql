define sid=&1
col job_id for 999999
col dmp_gb for 999.99
select db_sid,servername,book_date
, round(sum(dmpsize/1024/1024/1024),2) dmp_GB
from exp_log_file lf
, exp_queue q
--where file_name like upper ('%&schema%')
where q.job_id=lf.job_id
and db_sid='&sid'
group by db_sid,servername,book_date
order by book_date
/
