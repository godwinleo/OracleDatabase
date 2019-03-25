define user=&1

col sql_text for a60 truncated
col user_name for a15 
col cursor_type for a35
set lines 300
col sid for 9999 

select oc.SID ,oc.USER_NAME
,oc.ADDRESS 
,oc.SQL_ID 
,oc.HASH_VALUE
,oc.LAST_SQL_ACTIVE_TIME
,oc.SQL_EXEC_ID ,oc.CURSOR_TYPE
,SQL_TEXT
from v$open_cursor oc
,v$session sess
where oc.saddr = sess.saddr
and sess.username like upper('&user')
;