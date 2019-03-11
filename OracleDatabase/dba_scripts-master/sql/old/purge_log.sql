col log_id for 99999999
col job_id for 999
col log_date for a17 truncated
col process for a20
col tab for a30
col message for a85 word_wrapped
col sev for 99
define own=&1
define tab=&2
select book_date,LOG_DATE,SEVERITY sev,PROCESS,
OWNNAME||'.'||TABNAME tab,MESSAGE
--, to_Date(add_months(trunc(sysdate),-DATA_ONLINE)) ret
from dbadmin.dbs_purge_log
where job_id = (select max(job_id) 
		from dbadmin.dbs_purge_log
		where ownname like upper ('&own') 
		and tabname like upper('&tab'))
and severity > 2
and tabname like upper('&tab')
order by log_id
/
