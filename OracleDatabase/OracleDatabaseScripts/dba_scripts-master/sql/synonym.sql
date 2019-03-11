define owner=&1
define syn=&2
col db_link for a40
col SYNONYM_NAME for a29
col owner for a25
col table_owner for a25
col table_name for a30
select OWNER       
,SYNONYM_NAME
,TABLE_OWNER 
,TABLE_NAME  
,DB_LINK     
from dba_synonyms
where owner like upper('&owner')
and synonym_name like upper('&syn')
;
