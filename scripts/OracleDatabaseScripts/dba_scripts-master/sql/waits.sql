set pages 200
set lines 185
col sessions for 99999 WRAPPED 
col PCT for 999.99
set trims on
set feed off
break on report
compute sum label "Total of active sessions: " of sessions on report
select sw.event, count(sw.event) sessions,round(ratio_to_report(count(sw.event)) over ()*100,2) PCT
from v$session s,v$session_wait sw
where 
s.sid=sw.sid
and s.status='ACTIVE'
group by sw.event
order by sessions desc
;
