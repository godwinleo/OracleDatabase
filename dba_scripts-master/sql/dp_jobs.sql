col OWNER_NAME for a30 truncated
col JOB_NAME for a50 word_wrapped
col OPERATION for a10 truncated
col JOB_MODE for a10 truncated
col STATE for a20 truncated
col DEGREE for 99
col ATTACHED_SESSIONS for 99
col DATAPUMP_SESSIONS for 99
select *
from dba_datapump_jobs
order by datapump_sessions
/
