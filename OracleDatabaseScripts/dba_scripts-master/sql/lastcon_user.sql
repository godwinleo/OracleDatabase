define user=&1
col result for a150
select 'base' ||'|'||username||'|'||action_name||'|'||max(timestamp) result
from dba_audit_trail
where action_name='LOGON'
and username =upper('&user')
group by username,action_name;
