define user=&1
set pages 1000
set verify off
set lines 700
set feedback off
set trims on
col os_username for a20
col action_name for a7
col username for a20
col userhost for a25
col terminal for a30
col obj_name for a20
col new_name for a20
col comment_text for a20
col sql_bind for a20
col sql_text for a20
col extended_timestamp for a20
col pass_fail for a40
select action_name,os_username,username,userhost,terminal,timestamp,logoff_time
,decode(returncode,'0','Ok','1005','Null','1017','wrong username or password','28000','locked account','28001','expired account',returncode) pass_fail
from dba_audit_session
where username like upper('&user')
and action_name!='LOGOFF'
--and timestamp > sysdate - nvl(to_char('&days'),0)
and timestamp between sysdate-2 and sysdate
order by timestamp,username;


/*
select action_name,os_username,username,userhost,terminal,timestamp,logoff_time,
decode(returncode,'0','Ok','1005','Null','1017','wrong username or password','28000','locked account','28001','expired account',returncode) pass_fail
from dba_audit_session
where upper(os_username) like '%&os_username%'
and username like '%&username%'
and returncode like '%&returncode%'
and timestamp > sysdate - nvl(to_char('&days'),0)
order by timestamp
/
*/