col SPACE_LIMIT for 999,999,999,999,999.99
col SPACE_USED for 999,999,999,999,999.99
col name for a60
select NAME, round(space_used/space_limit*100,2) "%_USED" ,SPACE_LIMIT,SPACE_USED, SPACE_RECLAIMABLE, NUMBER_OF_FILES
from V$RECOVERY_FILE_DEST
/