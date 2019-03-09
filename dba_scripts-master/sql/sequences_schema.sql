define own=&1
define name=&2
select *
from dba_sequences
where sequence_owner like upper('%&own%')
and sequence_name like upper('%&name%')
/
