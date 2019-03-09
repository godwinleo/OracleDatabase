col sample_time for a25
col sess for a9
set head on
set feed on
set pages 0
set colsep |
select *
from (
	select  ash.snap_id
	,to_char(min(snap.BEGIN_INTERVAL_TIME),'YYYY-MON-DD HH24:MI') start_time, to_char(max(snap.END_INTERVAL_TIME),'YYYY-MON-DD HH24:MI') end_time
		--,QC_SESSION_ID qsid ,ash.session_id||','||ash.session_serial# sess
		, ash.user_id, u.username
		--, ash.sql_id ,ash.sql_plan_hash_value plan_hash
		--, round(max(pga_allocated)/1024/1024,2) pga_mb, round(max(temp_space_allocated)/1024/1024,2) temp_mb
		, sum(TM_DELTA_CPU_TIME)/60/100/100 cpu_time_mins, sum(TM_DELTA_DB_TIME)/60/100/100 db_time_mins
	from DBA_HIST_ACTIVE_SESS_HISTORY ash, dba_users u, dba_hist_snapshot snap
	where  ash.snap_id=snap.snap_id
		and ash.user_id=u.user_id
		and snap.begin_interval_time > trunc(sysdate-nvl('&1',0))
		and SESSION_STATE = 'ON CPU'
		--and snap_id.sample_time > trunc(sysdate-2)
	--group by session_id, session_serial#, QC_SESSION_ID, ash.user_id, u.username, ash.sql_id, ash.sql_plan_hash_value
	group by ash.snap_id, ash.user_id, u.username
	--having max(ash.temp_space_allocated/1024/1024) > 100
	order by snap_id, db_time_mins desc
)
where rownum < 15
/
