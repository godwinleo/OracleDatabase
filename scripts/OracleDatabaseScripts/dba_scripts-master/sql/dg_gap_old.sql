col name for a20
select dest_id, lower(name) name, applied, count (*),to_char(max(completion_time),'YYYY-MON-DD HH24:MI:SS') last_completed,max(sequence#),min(sequence#)
from v$archived_log al
where dest_id <> 1 
group by dest_id, lower(name), applied
order by dest_id
/
