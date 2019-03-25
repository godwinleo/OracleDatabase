col description for a40
select name,category,description
,signature
,task_exec_name
--,sql_text 
from DBA_SQL_PROFILES prof
where created > trunc(sysdate)
/
