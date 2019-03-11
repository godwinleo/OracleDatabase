col FIRST_LOG     for a20
col LAST_LOG      for a20
col RULE_ID       for 99
col SENT          for 99
col DB_SID        for a15
col SERVERNAME    for a15
col SCHEMA_NAME   for a10
col BOOK_DATE     for a20
col SUBMITTED     for a20
col STARTED       for a20
col STATUS        for a15
 
select 
to_char( FIRST_LOG,'YYYY-MON-DD HH24:MI') FIRST_LOG
,to_char( LAST_LOG,'YYYY-MON-DD HH24:MI') LAST_LOG
,RULE_ID
,SENT
,DB_SID
,SERVERNAME
,SCHEMA_NAME
,to_char( BOOK_DATE  ,'YYYY-MON-DD HH24:MI') BOOK_DATE
,to_char( SUBMITTED  ,'YYYY-MON-DD HH24:MI') SUBMITTED
,to_char( STARTED    ,'YYYY-MON-DD HH24:MI') STARTED
,STATUS
from exp_alert_history
where FIRST_LOG > trunc(sysdate-10)
order by FIRST_LOG desc;