define dg=&1
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
,dk.path
,dk.name
,dk.header_status
,dk.total_mb
,dk.free_mb
,dk.MOUNT_DATE
,dk.create_DATE
from v$asm_diskgroup dg
, v$asm_disk dk
where dg.group_number =dk.group_number
and dk.name like upper('&dg')
order by dk.name
;
