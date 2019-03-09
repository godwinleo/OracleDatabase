col sess for a10
col username for a15 truncated
col ELAPSED_TIME for a30
col "%_COMP" for 99.99
col ELAPSED_TIME for a19 truncated
col REMAINING_TIME for a19 truncated
col message for a60

SELECT SID||','||SERIAL# sess,
       username,
       substr(message,1,instr(message,':',-1)-1) message
       , trunc(SOFAR/TOTALWORK*100,2) "%_COMP"
       , sofar, totalwork
       ,NUMTODSINTERVAL(ELAPSED_SECONDS,'second') ELAPSED_TIME,NUMTODSINTERVAL(TIME_REMAINING,'second') REMAINING_TIME
	, sql_id
FROM V$SESSION_LONGOPS slo
WHERE totalwork>sofar
order by elapsed_seconds
/
