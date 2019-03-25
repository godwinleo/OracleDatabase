col comments for a40 word_wrapped
col schedule for a30
col REPEAT_INTERVAL for a60 word_wrapped
col end_date for a20
select owner||'.'||schedule_name schedule
,SCHEDULE_TYPE
,REPEAT_INTERVAL
,END_DATE
,comments
from dba_scheduler_schedules
/
