alter session set nls_date_format='YYYY-MON-DD HH24:MI:SS';
set lines 180
set pages 200
set trims on
select trunc(first_time,'HH'),count(1) ,
decode(trunc(first_time,'HH'),03,count(1) over (partition by trunc(first_time,'HH')))
from v$log_history
where first_time > trunc(sysdate)-2
--group by trunc(first_time)
order by 1
/
