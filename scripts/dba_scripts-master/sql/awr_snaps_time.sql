select min(snap_id),max(snap_id)
from  DBA_HIST_SNAPSHOT
where begin_interval_time between to_date('&min','YYYY-MON-DD HH24:MI:SS')
and to_date('&max','YYYY-MON-DD HH24:MI:SS')
/
