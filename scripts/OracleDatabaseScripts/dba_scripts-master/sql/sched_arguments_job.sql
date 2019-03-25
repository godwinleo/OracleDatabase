define job=&1
col job for a30
col ANYDATA_VALUE for a20
col value for a20
col ARGUMENT_TYPE for a10

select
OWNER||'.'||JOB_NAME job
, ARGUMENT_NAME
, ARGUMENT_POSITION
, ARGUMENT_TYPE
, VALUE
, ANYDATA_VALUE
, OUT_ARGUMENT
from
DBA_SCHEDULER_JOB_ARGS
where job_name like upper ('&job')
order by 1, argument_position
/