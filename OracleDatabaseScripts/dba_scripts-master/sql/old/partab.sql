col log_id for 99999999
col job_id for 999
def owner=&1
def tab=&2
col tab for a40
col parmask for a10
col historical for a30
col exceptions for a25
col temporal for a25
col key_format for a8
col min_month for 99 
col status for a8
col rule_id for 999
col interval for a30
select 
OWNNAME||'.'|| TABNAME tab
--,PARMASK
,KEY_FORMAT
,STATUS
,RULE_ID
,COMPRESSED
,MIN_MONTH
--,TEMPORAL
--,EXCEPTIONS
,HISTORICAL
--,MERGE_VIEW
,interval
from dbadmin.dbs_tab_part
where tabname like upper('&tab')
and ownname like upper('&owner')
order by ownname,rule_id,tabname desc
/
