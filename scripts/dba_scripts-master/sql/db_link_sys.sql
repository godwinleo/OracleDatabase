define link=&1
set lines 185
set pages 100
col name for a35
col host for a30
col owner for a15
col userid for a15
col password for a15
col passwordx for a35
select l.name
,u.username owner,l.host,l.userid,l.password,l.passwordx
from sys.link$ l
, dba_users u
where l.owner#=u.user_id
and name like upper('&link%');
