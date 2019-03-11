define user=&1
set lines 185
set pages 200
col table_name for a30
col owner for a20
col privilege for a15
select * 
from dba_tab_privs tp
where grantee like upper('&user')
;
