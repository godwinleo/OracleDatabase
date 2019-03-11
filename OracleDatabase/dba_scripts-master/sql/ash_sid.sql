define sid=&1
define serial=&2
col sample_time for a25
col sess for a10
select *
from (
	select  --SAMPLE_ID
	 to_char(min(ash.sample_time),'YYYY-MON-DD HH24:MI') start_time, to_char(max(ash.sample_time),'YYYY-MON-DD HH24:MI') end_time
		, ash.session_id||','||ash.session_serial# sess, ash.user_id, u.username, ash.sql_id ,ash.sql_plan_hash_value
		, round(max(pga_allocated)/1024/1024,2) pga_mb, round(max(temp_space_allocated)/1024/1024,2) temp_mb
	from v$active_session_history ash, dba_users u
	where  ash.user_id=u.user_id
		--and sample_time > trunc(sysdate-4)
		and ash.session_id = &sid
		and ash.session_serial# = &serial
	group by --SAMPLE_ID,
	session_id, session_serial#,ash.user_id,u.username, ash.sql_id, ash.sql_plan_hash_value
	--having max(ash.temp_space_allocated/1024/1024) > 100
	order by temp_mb desc, pga_mb desc
)
where rownum < 15
/
