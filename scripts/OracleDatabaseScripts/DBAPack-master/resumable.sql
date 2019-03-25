col sql_text format a60 head "SQL Text" trunc
col error_message format a40 head "Error"
col ident format a20 head "User (Sess,@Inst)"
col name            format a35
select 
   (select u.username from all_users u where u.user_id = r.user_id)||'('||session_id||',@'||instance_id||')' ident
  ,to_char( to_date(suspend_time, 'mm/dd/yy hh24:mi:ss' ), 'dd/mm hh24:mi' ) "Suspendido"
  ,to_char( to_date(resume_time, 'mm/dd/yy hh24:mi:ss' ), 'dd/mm hh24:mi' ) "Reiniciado"
  ,timeout "TimeOut"
  ,nullif(error_number||' - '|| error_msg, '0 - ' ) error_message 
  ,trim(sql_text) sql_text
from dba_resumable r;

