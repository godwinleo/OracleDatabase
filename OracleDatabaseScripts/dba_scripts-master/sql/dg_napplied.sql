col name for a20
select dest_id, recid,lower(name) name, THREAD#,sequence#,completion_time
from v$archived_log al
where dest_id <> 1 
and applied='NO'
--group by dest_id, lower(name), applied
/
