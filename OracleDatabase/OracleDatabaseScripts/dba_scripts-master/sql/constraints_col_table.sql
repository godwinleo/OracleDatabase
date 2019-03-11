define table=&1
set lines 185
set pages 200
col table_name for a25
col owner for a15
col index_name for a25
col constraint_name for a30
col column_name for a25
select cc.owner,cc.table_name,con.constraint_name,cc.column_name,cc.position,con.constraint_type,con.status,index_name,invalid
from dba_cons_columns cc
, dba_constraints con
where
cc.constraint_name=con.constraint_name
and cc.table_name=con.table_name
and con.TABLE_NAME='&1'
order by con.constraint_type,con.constraint_name,cc.position
;
