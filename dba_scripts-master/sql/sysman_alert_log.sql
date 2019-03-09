define server=&1

col MODULE_NAME       for a15
col ERROR_CODE        for 99999
col LOG_LEVEL         for a6
col ERROR_MSG         for a60 word_wrapped
col FACILITY          for a6
col CLIENT_DATA       for a10
col HOST_URL          for a40
col EMD_URL           for a30
col OCCUR_TIMESTAMP   for a12 truncated

select 
 MODULE_NAME
, OCCUR_DATE
, ERROR_CODE
, LOG_LEVEL
, ERROR_MSG
, FACILITY
--, CLIENT_DATA
--, HOST_URL
, EMD_URL
, APPLICATION_TYPE
, OCCUR_TIMESTAMP
from SYSMAN.MGMT_SYSTEM_ERROR_LOG
where emd_url like lower('&server')
--and OCCUR_TIMESTAMP > trunc(sysdate-1)
/