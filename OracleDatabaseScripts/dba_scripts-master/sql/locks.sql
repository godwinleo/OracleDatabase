col username for a30
col program for a40 truncated
col sid for 999999
col holding for a15
break on holding
--SELECT DECODE(request,0,'Holder: ','Waiter: ')||sid sess, 
SELECT DECODE(lk.request,0,'Holder: ','Waiter: ') holding
        , lk.sid
	--, s.username, s.program 
        , lk.id1, lk.id2, lk.lmode, lk.request, lk.type
	, ctime
    FROM V$LOCK lk
	--, v$session s
   WHERE (lk.id1, lk.id2, lk.type) IN
             (SELECT id1, id2, type FROM V$LOCK WHERE request>0)
   --and lk.sid=s.sid
   ORDER BY lk.id1, lk.request, lk.ctime
  ;
