define link=&1
col OWNER     for a20
col DB_LINK   for a40
col USERNAME  for a20
col HOST      for a20
col CREATED   for a20

select
OWNER
,DB_LINK
,USERNAME
,HOST
,CREATED
from dba_db_links
where DB_LINK like upper('&link%');
