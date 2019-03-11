define cons=&1
set lines 185
set pages 200
col table_name for a25
col owner for a15
col r_owner for a15
col constraint_name for a30
col column_name for a25
col status for a15
select fk.owner,fk.constraint_name,fk.table_name,fk.r_owner,ref.table_name,fk.r_constraint_name,fk.status,fk.invalid
from dba_constraints fk
, dba_constraints ref
--, dba_cons_columns cc
where
fk.constraint_name=upper('&cons')
and fk.constraint_type='R'
and fk.r_constraint_name=ref.constraint_name
and fk.r_owner=ref.owner
;
