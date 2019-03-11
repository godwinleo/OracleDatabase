SET VERIFY OFF TERMOUT OFF LINES 300 DEFINE "&" FEEDBACK OFF PAGES 300


COLUMN OWNER FORMAT A30

COLUMN lmt new_value lmt NOPRINT
COLUMN sel new_value sel NOPRINT
COLUMN val new_value val NOPRINT
COLUMN cls_where new_value cls_where NOPRINT
select instr('&1.','=') lmt from dual;
select lower(substr( '&1.' , 1, &lmt. )) sel,  upper(substr( '&1.', &lmt.+1, 100)) val from dual;
select
 case '&sel.'
     when 'o='  then 'where o.owner like ''&val.''' 
     when 'on=' then 'where UPPER(o.owner||''.''||o.object_name) like ''&val.''' 
     when 't='  then 'where object_type like ''&val.''' 
     when 'n='  then 'where UPPER(object_name) like ''&val.''' 
     when 'i='  then 'where object_id like ''&val.''' 
     else 'where UPPER(object_name) like ''&val.''' 
  end cls_where
from dual
/


SET VERIFY OFF TERMOUT ON LINES 300 DEFINE "&" FEEDBACK OFF

REM prompt DEBUG &cls_where.

COLUMN DETALHES format A120
COL OBJECT_NAME FORMAT A35 trunc

select 
   o.owner
  ,o.object_type
  ,o.object_name
  ,o.status
  ,CASE o.object_type
     WHEN 'DIRECTORY' THEN
       ( 
        SELECT 'path: ' || s.directory_path
        FROM dba_directories s 
        WHERE (o.owner=s.owner and o.object_name=s.directory_name)
       )
     WHEN 'SYNONYM' THEN
       ( 
        SELECT s.owner||'.'||s.synonym_name || ' --> ' || s.table_owner|| '.' || s.table_name || decode( db_link, null, null, '@' || db_link )
        FROM dba_synonyms s 
        WHERE (o.owner=s.owner and o.object_name=s.synonym_name)
       )
     WHEN 'TABLE' THEN
       ( 
        SELECT 
          CASE WHEN IOT_TYPE IS NULL THEN 'HEAP' ELSE 'IOT: ' || IOT_TYPE || ' (name:' || IOT_NAME || ')' END || ', TEMPORARY: ' || TEMPORARY || 
          ', CREATION: ' || to_char( o.created, 'dd/mm/yyyy' ) || ', LAST_DDL: ' || to_char( o.last_ddl_time, 'dd/mm/yyyy hh24:mi' )
        FROM dba_tables s 
        WHERE (o.owner=s.owner and o.object_name=s.table_name)
       )
     WHEN 'MATERIALIZED VIEW' THEN
       ( 
          SELECT 'RefrGrp: ' || S.RNAME ||', Intrvl: ' || S.INTERVAL || ', LastRefresh: ' || to_char( t.last_refresh, 'dd/mm/yy HH24:MI' ) || ', Creation: ' || to_char( o.created, 'dd/mm/yy' ) || ', LastDDL: ' || to_char( o.last_ddl_time, 'dd/mm/yy' )
          FROM      DBA_MVIEW_REFRESH_TIMES t 
          LEFT JOIN DBA_REFRESH_CHILDREN s on (t.owner=s.owner and t.name=s.name)
          WHERE (o.owner=t.owner and o.object_name=t.name)
          order by t.last_refresh desc fetch first 1 rows only
       )
     ELSE 
       'CREATION: ' || to_char( o.created, 'dd/mm/yyyy' ) || ', LAST_DDL: ' || to_char( o.last_ddl_time, 'dd/mm/yyyy' )
   END detalhes
from dba_objects o
&cls_where.
order by o.created
/

SET VERIFY ON TERMOUT ON LINES 300 DEFINE "&" FEEDBACK 6 PAGES 66
