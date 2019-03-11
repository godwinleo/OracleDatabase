set lines 185
set pages 50
col diskgroup for a20
col name for a20
col path for a30
col free_mb for 999,999,999.99
col total_mb for 999,999,999.99
col new_aloc_mb for 999,999,999.99
col add_mb for 999,999,999.99

select dg.name diskgroup
,op.*
from v$asm_diskgroup dg
, v$asm_operation op
where dg.group_number (+) =op.group_number
--and dg.name like upper('dg')
;
