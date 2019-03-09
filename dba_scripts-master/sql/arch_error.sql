col dest_name for a20 truncated
col destination for a10 truncated
col error for a70 word_wrapped
col "archive_thr/seq" for a15
col "applied_thr/seq" for a15
col gap_status for a20
col db_unique_name for a10 truncated
select 
DESTINATION ,DATABASE_MODE 
,ERROR ,SRL 
--,DB_UNIQUE_NAME
 ,SYNCHRONIZED ,GAP_STATUS
from V$ARCHIVE_DEST_STATUS
where status!='INACTIVE'
--and type!='LOCAL'
/
