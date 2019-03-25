 col CFG_ID for 99
 col JOB_PREFIX for a5
 col DIRECTORY for a12
 col FILESIZE for 999,999,999,999
 col PARALLEL for 99
 col EXCLUDE for a10
 col INCLUDE for a10
 col QUERY for a10
 col CONTENT for a15
 col TABLES for a10
 col FULL for a4
 --col FLASHBACK for a30
 col VERSION for a10
 col OTHER for a25 word_wrapped
 col DETAIL for a10
 col estimate for a8

select *
from exp_dp_cfg
order by cfg_id
/

