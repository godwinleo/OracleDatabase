set echo off
set pages 0
set feed off
set lines 200
define address=&1

insert into plan_table 
(select 
'&address' ,
sysdate, --timestamp
'from v$Sql_plan', --remarks
operation,
options,
s.object_node,
s.object_owner,
s.object_Name,
0 object_instance, --object_instance
o.object_type, --object_type
optimizer,
search_Columns,
id,
parent_id,
position,
cost,
cardinality,
bytes,
other_tag,
partition_start,
partition_stop,
partition_id,
other,
distribution,
cpu_Cost,
io_cost,
temp_Space,
access_predicates,
filter_predicates
from v$sql_plan s, dba_objects o
where address = '&address'
and o.object_id (+)=s.object#
)
/

SELECT * FROM table(DBMS_XPLAN.DISPLAY('PLAN_TABLE','&address'));
rollback;
