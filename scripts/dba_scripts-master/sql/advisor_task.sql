define sqltask=&1
col DESCRIPTION for a60 word_wrapped

select OWNER
,TASK_ID 
,TASK_NAME
,DESCRIPTION
,advisor_name
,created
from DBA_ADVISOR_TASKS
where TASK_NAME like ('&sqltask')
and DESCRIPTION not like '%Auto%'
and owner !='SYS'
order by created
/