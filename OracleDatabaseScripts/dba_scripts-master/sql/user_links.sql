define link=&1
set lines 185
set pages 100
col db_link for a35
col host for a60
col owner for a15
col userid for a15
col password for a35
select 
DB_LINK
,USERNAME
,PASSWORD
,HOST
,CREATED
from user_db_links l
where DB_LINK like upper('&link%');
