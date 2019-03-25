define prog=&1
col prog for a30
col default_ANYDATA_VALUE for a20
col default_value for a20
col ARGUMENT_TYPE for a10

select
OWNER||'.'||PROGRAM_NAME prog
, ARGUMENT_NAME
, ARGUMENT_POSITION
, ARGUMENT_TYPE
, METADATA_ATTRIBUTE
, DEFAULT_VALUE
, DEFAULT_ANYDATA_VALUE
, OUT_ARGUMENT
from DBA_SCHEDULER_PROGRAM_ARGS
where PROGRAM_NAME like upper ('&prog')
order by 1, argument_position
/