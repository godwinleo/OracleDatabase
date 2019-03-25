define owner=&1
define tab=&2
col log_id for 99999999
col job_id for 999
col process for a20
col ownname for a20
col tabname for a20
col message for a50
col severity for a10
select *
from dbadmin.dbs_tab_part_log
where job_id = ( select job_id
		from dbadmin.dbs_tab_part_log
		where log_id = (select max(log_id) 
				from dbadmin.dbs_tab_part_log)
		and ownname like upper('&owner')
		and tabname like upper('&tab')
	)
and ownname like upper('&owner')
and tabname like upper('&tab')
order by log_id --desc
/
