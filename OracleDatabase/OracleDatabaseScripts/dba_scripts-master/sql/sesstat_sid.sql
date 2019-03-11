define sid=&1
col username for a25
col program for a30
col value for a30
select to_char(sysdate,'hh24:mi')
, username, program , s.sid, s.serial#, name.name, stat.value
from v$session s, v$statname name, v$sesstat stat
where name.STATISTIC# =stat.STATISTIC#
and stat.sid=s.sid
and stat.sid=&sid
order by value
/
