define schema=&1
define tab=&2
col owner_name for a25
col table_name for a35
col job_id for 99999999
col elapsed_min for 999,999.99
select 
job_id,
owner_name, table_name
, min(to_char(systime,'YYYY-MON-DD HH24:MI:SS')) start_time
, max(to_char(systime,'YYYY-MON-DD HH24:MI:SS')) end_time
,(max(systime) - min(systime))*24*60 elapsed_min
, avg ((max(systime) - min(systime))*24*60) over ( partition by owner_name, table_name ) AVG_min
from DBADMIN.APP_MANUAL_STATS_LOG
--where trunc(systime)=trunc(sysdate)
where owner_name like upper ('&schema')
and table_name like upper ('&tab')
/*and job_id= (select max(job_id) from DBADMIN.APP_MANUAL_STATS_LOG
				where owner_name like upper ('&schema')
				and table_name like upper ('&tab'))
*/
and trunc(systime) > trunc(sysdate-15)
group by job_id,owner_name, table_name 
having job_id > (max(job_id))
order by job_id
/

