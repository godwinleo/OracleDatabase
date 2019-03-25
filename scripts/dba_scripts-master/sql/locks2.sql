col username for a15
col program for a25 truncated
col sid for 999999
col holding for a10
col event for a30 truncated
set feed on
break on holding
--SELECT DECODE(request,0,'Holder: ','Waiter: ')||sid sess, 
select l.holding
, s.username, s.sid, serial# ,s.program
       , l.id1, l.id2, l.lmode, l.request, l.type, l.ctime
, sw.event
from
v$session s
, v$session_wait sw
, (
SELECT /*+ NO_MERGE */ DECODE(lk.request,0,'Holder: ','Waiter: ') holding
        , lk.sid
	--, s.username, s.program 
        , lk.id1, lk.id2, lk.lmode, lk.request, lk.type
	, ctime
    FROM V$LOCK lk
	--, v$session s
   WHERE (lk.id1, lk.id2, lk.type) IN
             (SELECT id1, id2, type FROM V$LOCK WHERE request>0
		and ctime > 0
	       )
   --and lk.sid=s.sid
) l
where s.sid=l.sid
and s.sid=sw.sid
ORDER BY l.id1, l.request, l.ctime
  ;
