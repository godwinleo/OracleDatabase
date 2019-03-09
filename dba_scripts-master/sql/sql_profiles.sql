define owner=&1
select prof.task_id,task.task_name,prof.name
from dba_advisor_tasks task
,DBA_SQL_PROFILES prof
where prof.task_id=task.task_id
and owner=upper('&owner')
/
