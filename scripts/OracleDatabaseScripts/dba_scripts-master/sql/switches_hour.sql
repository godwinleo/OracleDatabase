alter session set nls_date_format='YYYY-MON-DD HH24:MI:SS';
set lines 180
set pages 200
set trims on
select trunc(first_time,'HH'),count(1)
from v$log_history
group by trunc(first_time,'HH')
order by 1
/
