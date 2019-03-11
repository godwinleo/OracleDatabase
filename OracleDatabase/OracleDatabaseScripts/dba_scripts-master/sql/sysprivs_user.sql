define user=&1
set pages 200
set lines 185
set trims on
col username for a25
select *
from dba_sys_privs
where grantee=upper('&user')
;
