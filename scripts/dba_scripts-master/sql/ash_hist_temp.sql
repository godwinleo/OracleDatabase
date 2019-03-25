col sample_time for a25
col sess for a9
select *
from (
	select  to_char(min(ash.sample_time),'YYYY-MON-DD HH24:MI') start_time, to_char(max(ash.sample_time),'YYYY-MON-DD HH24:MI') end_time
		,QC_SESSION_ID qsid ,ash.session_id||','||ash.session_serial# sess, ash.user_id, u.username, ash.sql_id ,ash.sql_plan_hash_value plan_hash
		, round(max(pga_allocated)/1024/1024,2) pga_mb, round(max(temp_space_allocated)/1024/1024,2) temp_mb
	from DBA_HIST_ACTIVE_SESS_HISTORY ash, dba_users u, dba_hist_snapshot snap
	where  ash.snap_id=snap.snap_id
		and ash.user_id=u.user_id
		and snap.begin_interval_time > trunc(sysdate-nvl('&1',0))
		--and snap_id.sample_time > trunc(sysdate-2)
	group by session_id, session_serial#, QC_SESSION_ID, ash.user_id, u.username, ash.sql_id, ash.sql_plan_hash_value
	having max(ash.temp_space_allocated/1024/1024) > 100
	order by temp_mb desc, pga_mb desc
)
where rownum < 15
/
