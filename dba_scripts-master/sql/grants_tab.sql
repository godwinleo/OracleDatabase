define owner=&1
define table=&2
set lines 185
set pages 200
col table_name for a30
col owner for a15
col table_owner for a15
col privileges for a10
select tp.owner,tp.table_name
,tp.privilege,tp.grantee
from dba_tab_privs tp
where table_name like upper('&table')
and owner like upper('&owner')
order by owner,table_name,grantee,privilege
/
