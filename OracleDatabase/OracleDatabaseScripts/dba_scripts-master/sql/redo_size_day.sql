alter session set nls_date_format='YYYY-MON-DD HH24:MI:SS';
set lines 180
set pages 200
set trims on
col gb for 999,999.99
select day,switches, switches*gb_redo Gb
from (select trunc(first_time) day,count(1) switches
from v$log_history
group by trunc(first_time))
, (select avg(bytes/1024/1024/1024) gb_redo from v$log) log
order by 1
/
