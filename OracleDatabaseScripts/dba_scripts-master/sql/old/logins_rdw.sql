set verify off
set feedback off
set trims on
col db_name for a8
col os_username for a20
col action_name for a7
col username for a20
col userhost for a30
col terminal for a30
col obj_name for a20
col new_name for a20
col comment_text for a20
col sql_bind for a20
col sql_text for a20
col extended_timestamp for a20
col pass_fail for a10
set colsep |

select SYS_CONTEXT ('USERENV', 'DB_NAME') db_name,username,os_username,userhost, terminal,PROXY_SESSIONID
--,timestamp
, max(timestamp) LAST_LOGIN
--,decode(returncode,'0','Ok','1005','Null','1017','wrong username or password','28000','locked account','28001','expired account',returncode) pass_fail
from dba_audit_session
where action_name='LOGON'
and USERHOST not in ('latap-uat3909.nam.nsroot.net','latap-cob3909.nam.nsroot.net','latap-prd4909.nam.nsroot.net'
						,'latfctdb001u.nam.nsroot.net','latfctdb001p.nam.nsroot.net'
						,'lacurylxap086','lacurylxap084','lacurylxap085','lacurylxdb104','lacurylxdb105','lacurylxdb106'
						,'latfctai001u.nam.nsroot.net','latfctai001c.nam.nsroot.net','latfctai001p.nam.nsroot.net')
and username not in ('DBADMIN','DBSNMP','AIADMIN','DBA_CENTRAL','IFS_INFOSEC','GERS_READ','PATMON','VASCAN')
and username not like ('EMER_%')
and username not like ('DBA_%')
and username not like ('OFS_%')
and OS_USERNAME not in ('QuestService')
and timestamp >= to_date('2015-DEC-01','YYYY-MON-DD')
group by username,os_username,userhost, terminal,PROXY_SESSIONID
order by username,userhost,OS_USERNAME,max(timestamp);


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