define prog=&1

col comments for a35 word_wrapped
col program for a25
col program_type for a10
col program_action for a50 word_wrapped

select owner||'.'||program_name program,enabled,program_type,program_action,NUMBER_OF_ARGUMENTS,priority,weight,max_runs,comments
from dba_scheduler_programs
where program_name like upper ('&prog')
/
