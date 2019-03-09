define owner=&1
define retention=&2
set trims off
set pages 0

select 'QUERY='||t.owner||'.'||t.table_name||':"WHERE TRUNC('||c.column_name||') >=ADD_MONTHS(trunc(sysdate,''MONTH''),-&retention)"'
from dba_tables t,
dba_tab_columns c
where t.owner='&OWNER'
and c.column_name in ('BOOK_DATE','FECHA_TRAN')
and t.owner=c.owner 
and t.table_name=c.table_name 
/
