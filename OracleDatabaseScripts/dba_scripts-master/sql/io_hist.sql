set pages 100
col begin_interval_time for a15 truncated
col end_interval_time for a15 truncated
col stat_name for a27

select SYS_CONTEXT ('USERENV', 'DB_UNIQUE_NAME') db_unique_name
,trunc(min(begin_interval_time)) min_date
,trunc(max(begin_interval_time)) max_date
--,max(stat1.value)
--,stat2.stat_name
--,max(stat2.value)
,max (stat1.value + stat2.value) max_io
,avg (stat1.value + stat2.value) avg_io
from DBA_HIST_SYSSTAT stat1, DBA_HIST_SYSSTAT stat2, dba_hist_snapshot snap
where 
  stat1.snap_id=snap.snap_id
  and stat2.snap_id=snap.snap_id
  and trunc(begin_interval_time) > to_date('2014-APR-30','YYYY-MON-DD')
  and trunc(begin_interval_time) < to_date('2014-JUN-01','YYYY-MON-DD')
  and stat1.stat_name = 'physical read IO requests'
  and stat2.stat_name = 'physical write IO requests'
group by stat1.stat_name, stat2.stat_name
--order by snap.snap_id
/
