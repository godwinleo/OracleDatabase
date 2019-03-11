define role=&1
set lines 185
set pages 200
select * 
from dba_role_privs rp
where granted_role=upper('&role')
;
