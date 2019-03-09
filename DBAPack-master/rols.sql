col sid format 99999
col username format a30 
col segment_name format a30
col logon format a20
WITH FILTERED_LOCKS AS
(
  SELECT * 
  FROM GV$LOCK 
  WHERE type = 'TX' and lmode = 6 
),
 DBA_SEG AS 
(
  SELECT segment_name, ROUND(bytes/(1024*1024),2) size_mb 
  FROM dba_segments 
  WHERE segment_type = 'TYPE2 UNDO'
)  
SELECT 
   dba_seg.segment_name
  ,dba_seg.size_mb
  ,DECODE(TRUNC(SYSDATE - LOGON_TIME), 0, NULL, TRUNC(SYSDATE - LOGON_TIME) || ' Days' || ' + ') || 
    TO_CHAR(TO_DATE(TRUNC(MOD(SYSDATE-LOGON_TIME,1) * 86400), 'SSSSS'), 'HH24:MI:SS') LOGON 
  ,v.inst_id
  ,v.SID
  ,v.SERIAL#
  ,p.SPID
  --,v.process
  ,v.USERNAME
  ,v.STATUS
  --,v.OSUSER
  --,v.MACHINE
  --,v.PROGRAM
  --,v.module
  --,v.action 
FROM gv$session v
JOIN filtered_locks l ON ( v.inst_id = l.inst_id and v.sid = l.sid)
LEFT JOIN gv$process p ON ( v.inst_id = p.inst_id and v.sid = p.pid )
LEFT JOIN dba_rollback_segs rr ON (TRUNC(l.id1/65536) = rr.segment_id )
LEFT JOIN dba_seg ON (rr.segment_name = dba_seg.segment_name)
ORDER BY dba_seg.size_mb DESC;
