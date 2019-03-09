define griddisk=&1
define cell=&2
set lines 185
set pages 200
col name for a50
select name
from v$asm_disk
where name like '%_CD_&griddisk_&cell%'
;
