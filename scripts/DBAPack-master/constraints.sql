define dono=&1.
define tabs=&2.
define tipo='R'

set verify off long 540 lines 320
col constraint_name format a30
col table_name format a30
col column_name format a32
col checks format a45
col fk     format a40
col status format a22
col constraint_type format a1 heading "T"

select /*+ rule */ cc.table_name
      ,cc.constraint_name
      ,c.constraint_type
      ,c.status|| ' '||c.validated status
      ,nvl(cc.position, 1) || '-' || cc.column_name column_name
      ,c.search_condition checks
      ,c.r_owner ||'.'||c.r_constraint_name fk
      ,c.deferrable
      ,c.delete_rule
  from dba_cons_columns cc, dba_constraints c
  where (cc.table_name LIKE UPPER('&tabs.') or c.constraint_type=upper('&tabs.'))
  and cc.owner = upper( '&dono.' )
  --and c.constraint_type = '&tipo.'
  and cc.constraint_name = c.constraint_name
  and cc.owner = c.owner
  ORDER BY cc.table_name, cc.constraint_name, cc.position
/
set verify on
