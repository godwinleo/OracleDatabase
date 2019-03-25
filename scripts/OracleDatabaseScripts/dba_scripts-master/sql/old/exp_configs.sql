col CFG_ID     for 999
col JOB_PREFIX for a10
col DIRECTORY  for a12
col FILESIZE   for 999999999999
col PARALLEL   for 99
col EXCLUDE    for a10
col INCLUDE    for a5
col QUERY      for a10
col CONTENT    for a20
col TABLES     for a5
col FULL       for a2
col FLASHBACK  for 999
col VERSION    for a7
col OTHER      for a35 word_wrapped
col DETAIL     for a5
col ESTIMATE   for a10
select CFG_ID
,JOB_PREFIX
,DIRECTORY
,FILESIZE
,PARALLEL
,EXCLUDE
,INCLUDE
,QUERY
,CONTENT
,TABLES
,FULL
,FLASHBACK
,VERSION
,OTHER
,DETAIL
,ESTIMATE
from EXP_DP_CFG
order by CFG_ID
/

