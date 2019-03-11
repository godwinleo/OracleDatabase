col startup_time for a30
col begin_interval_time for a30
col end_interval_time for a30
col flush_elapsed for a20
col snap_timezone for a20

select snap_id
-- ,startup_time
,begin_interval_time,end_interval_time,flush_elapsed,snap_level,error_count,snap_flag,snap_timezone
 from dba_hist_snapshot
 where begin_interval_time > trunc(sysdate-nvl('&1',0))
order by snap_id
/

