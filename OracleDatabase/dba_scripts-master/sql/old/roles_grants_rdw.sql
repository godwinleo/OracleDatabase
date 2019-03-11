
col db_name for a10
select grants.* 
from 
(
	select SYS_CONTEXT ('USERENV', 'DB_NAME') db_name, grantee, 'ROLE ' grant_type, granted_role  granted
	from dba_role_privs rp
	union all
	select SYS_CONTEXT ('USERENV', 'DB_NAME') db_name, grantee, 'DIRECT GRANT ' grant_type, privilege granted
	from dba_sys_privs sp
) grants, 
(
select username
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
group by username
) users
 where grants.grantee=users.username
order by grantee, grant_type, granted
;


/*
select SYS_CONTEXT ('USERENV', 'DB_NAME') db_name, grantee, 'ROLE ' grant_type, granted_role  granted
from dba_role_privs rp
where grantee like upper('&user')
union all
 select SYS_CONTEXT ('USERENV', 'DB_NAME') db_name, grantee, 'DIRECT GRANT ' grant_type, privilege granted
 from dba_sys_privs sp
 where grantee like upper('user')
order by grantee, grant_type, granted
;
*/