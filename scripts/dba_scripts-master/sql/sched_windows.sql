col schedule for a70 word_wrapped
col duration for a15
col window_name for a18
col resource_plan for a25
col next_start_date for a28 truncated
select window_name, resource_plan, enabled, active
,nvl(repeat_interval,schedule_name) schedule,duration
,window_priority
,next_start_date
from dba_scheduler_windows
/
