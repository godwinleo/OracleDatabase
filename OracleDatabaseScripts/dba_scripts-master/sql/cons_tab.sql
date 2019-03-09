define owner=&1
define tab=&2

col idx for a35
col tab for a35
col status for a10

select --owner,
constraint_name,constraint_type,r_owner,r_constraint_name,status,index_owner||'.'||index_name idx
,owner||'.'||table_name tab
from dba_constraints
where owner like upper('&owner')
and table_name like upper('&tab')
/
