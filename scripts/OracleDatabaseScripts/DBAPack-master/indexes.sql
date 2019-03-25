/*

GRANT SELECT ON SYS.DBA_IND_EXPRESSIONS TO P_7236 WITH GRANT OPTION;

CREATE OR REPLACE FUNCTION P_7236.GET_IND_EXPR( p_owner VARCHAR2, p_index VARCHAR2, p_pos NUMBER )
RETURN VARCHAR2
IS
  STR VARCHAR2(32767);
BEGIN
  EXECUTE IMMEDIATE
   'SELECT COLUMN_EXPRESSION FROM SYS.DBA_IND_EXPRESSIONS WHERE INDEX_OWNER = :b1 AND INDEX_NAME= :b2 AND COLUMN_POSITION = :b3'
   INTO str USING upper(p_owner), upper(p_index), p_pos;
  RETURN SUBSTR( STR, 1, 4000 );
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE( 'ERR: '|| SQLCODE) ;
    RETURN NULL;
END;
/

*/


set verify off long 212 feed off lines 212 pages 10000
col table_name format a30
col index_name format a50
col column_name format a70 trunc
col uniqueness format a9 heading 'UNICIDADE'
col index_type format a22 heading 'TYPE' trunc
col status format a8 heading 'STATE'
col descend format a3 heading 'ORD' TRUNC

break on table_name  on index_name

select DISTINCT ix.table_name
from dba_indexes ix
where ix.table_owner LIKE upper( '&1.' )
and ix.table_name LIKE upper( '&2.' )
.

select /*+RULE*/ ix.table_name, ic.index_owner||'.'||ix.index_name index_name
      ,ic.column_position||'-'||
        case
          when ix.table_name <> ic.table_name then ic.table_name||'('||ic.column_name||')'
          when ic.column_name like 'SYS_NC%' then P_7236.GET_IND_EXPR( ic.index_owner, ic.index_name, ic.column_position )
          else ic.column_name
          end column_name
      ,ix.index_type || ' ' || ip.locality  || ' ' || ip.partitioning_type index_type
      ,ix.uniqueness
      ,ix.status
      ,ic.descend
from dba_indexes ix, dba_ind_columns ic, dba_part_indexes ip
where ix.table_owner LIKE upper( '&1.' )
and ix.table_name LIKE upper( '&2.' )
and ix.owner            = ic.index_owner
and ix.index_name       = ic.index_name
and ix.owner            = ip.owner(+)
and ix.index_name       = ip.index_name(+)
ORDER BY ix.table_name, ix.index_name, ic.column_position
/
PROMPT
set verify on feed 6
clear break

