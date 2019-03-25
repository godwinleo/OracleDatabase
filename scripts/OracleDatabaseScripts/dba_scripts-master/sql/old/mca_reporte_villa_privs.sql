set colsep |
set feed off
set pages 0
set echo off
select GRANTEE, OWNER, TABLE_NAME, GRANTOR, PRIVILEGE 
from dba_tab_privs
where grantee  in (select distinct GRANTED_ROLE from dba_role_privs where  grantee in ('EMER_YU28246','EMER_AC59832','EMER_GL40458','EMER_ND72367','EMER_ND49727') )
--and privilege not in ('SELECT','DEBUG')
order by grantee
/