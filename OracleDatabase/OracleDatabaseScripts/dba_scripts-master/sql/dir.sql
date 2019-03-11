define dir=&1
set pages 100
set lines 185
col owner for a20
col directory_path for a50
col directory_name for a30
select owner,directory_name,directory_path
from dba_Directories
where directory_name like upper('&dir')
order by 1
/
