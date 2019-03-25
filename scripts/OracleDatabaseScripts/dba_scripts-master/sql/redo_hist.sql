set pages 100
col plan_hash for 9999999999999
col begin_interval_time for a20 truncated
col end_interval_time for a20 truncated
col sql_profile for a25
col execs for 999999999
col gets for 999999999
col reads for 999999999
col cpu_min for 99999999
col elap_min for 99999999

select 
tsname
,sum(DB_BLOCK_CHANGES_TOTAL), sum(DB_BLOCK_CHANGES_DELTA)
--,begin_interval_time,end_interval_time
--,min(begin_interval_time),max(begin_interval_time)
from DBA_HIST_SEG_STAT seg, dba_hist_snapshot snap
,dba_hist_tablespace_stat tbs
where 
  seg.snap_id=snap.snap_id
  and tbs.snap_id=snap.snap_id
  and tbs.ts#=seg.ts#
  and begin_interval_time > (sysdate-(1/24*8))
--group by snap.snap_id,begin_interval_time,end_interval_time,tsname
group by tsname
  --having sum(DB_BLOCK_CHANGES_DELTA) > 0
--order by snap.snap_id, 2
order by sum(db_block_changes_total)
/
