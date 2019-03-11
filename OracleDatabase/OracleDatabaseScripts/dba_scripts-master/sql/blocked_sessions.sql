col name for a60 
col object for a30
SELECT s1.SID blocked_sid, s1.username, s1.blocking_session blocking_sid, s2.username
       --,s1.p1 "FILE#"
	   , df.name
	   , s1.p2 "BLOCK#", s1.p3 "class#"
	   --, s1.row_wait_obj# OBJECT_ID
	   , obj.owner||'.'||obj.object_name object
  FROM v$session s1
  , v$session s2
  , v$datafile df
  , dba_objects obj
 -- , dba_extents ex
 WHERE s1.event = 'read by other session'
	and s1.blocking_session=s2.sid (+)
	and s1.p1=df.file# 
	and s1.row_wait_obj# = obj.OBJECT_ID (+) 
--	and s1.p1=ex.file_id (+) 
--	and s1.p2 between ex.block_id and ex.block_id + ex.blocks -1
   AND s1.STATE='WAITING'
;