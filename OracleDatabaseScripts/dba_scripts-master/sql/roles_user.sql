define user=&1
set lines 185
set pages 200
select * 
from dba_role_privs rp
where grantee like upper('&user')
order by grantee, granted_role
;
