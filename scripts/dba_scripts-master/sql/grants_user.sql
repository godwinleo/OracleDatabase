define user=&1
set lines 185
set pages 200
col table_name for a25
col owner for a15
col table_owner for a15
col privileges for a10
select * 
from dba_sys_privs sp
where grantee like upper('&user')
order by grantee, privilege
;
