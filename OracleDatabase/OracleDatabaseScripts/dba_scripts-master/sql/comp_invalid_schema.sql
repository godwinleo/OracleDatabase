define owner=&1
set echo off
COL SQL FOR A150
set pages 0

select DECODE(OBJECT_TYPE, 'PACKAGE BODY','ALTER PACKAGE '||owner||'.'||object_name||' COMPILE BODY;'
	,'TYPE BODY','ALTER TYPE '||owner||'.'||object_name||' COMPILE BODY;'
	,'ALTER '||decode(owner,'PUBLIC','PUBLIC ','')||OBJECT_TYPE||' '||decode(owner,'PUBLIC','',owner||'.')||'"'||object_name||'"'||' COMPILE;') SQL
from dba_objects 
where status='INVALID' 
and owner like upper('&owner')
order by 1
/

set pages 150
