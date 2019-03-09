define tbs=&1
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
,owner,object_name
,seg_end.DB_BLOCK_CHANGES_TOTAL-seg_begin.DB_BLOCK_CHANGES_TOTAL blocks
,begin_interval_time,end_interval_time
from 
dba_hist_tablespace_stat tbs , DBA_HIST_SEG_STAT_OBJ obj
, DBA_HIST_SEG_STAT seg_begin, dba_hist_snapshot snap
,DBA_HIST_SEG_STAT seg_end
where 
  tbs.ts#=obj.ts#
  --and tbs.snap_id=snap.snap_id
  and seg_begin.obj#=obj.obj#
  and seg_begin.dataobj#=obj.dataobj#
  and seg_end.obj#=obj.obj#
  and seg_end.dataobj#=obj.dataobj#
  and tbs.ts#=seg_begin.ts#
  and seg_begin.snap_id=snap.snap_id
  and begin_interval_time > (sysdate-(1/24*8))
  and tbs.tsname like upper('&tbs')
order by blocks
/
