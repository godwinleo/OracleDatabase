col name for a20

  SELECT THREAD#, applied, count(1), min(SEQUENCE#) ,max(SEQUENCE#)
  , max(SEQUENCE#) - min(SEQUENCE#)
   FROM V$ARCHIVED_LOG local 
   WHERE dest_id != 1 and
    sequence# > 
	   (SELECT max(sequence#)
		FROM V$ARCHIVED_LOG remote
		WHERE dest_id <> 1
		and applied = 'YES'
	)
	group by THREAD#, applied
	/

