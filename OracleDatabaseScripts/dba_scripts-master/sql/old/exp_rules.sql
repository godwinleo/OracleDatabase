col RULE_ID   for 99
col NAME      for a15
col PROC      for a35
col TYPE      for a5
col P1        for a5
col P2        for a45
col STATUS    for a10
col INTERVAL  for 9999
col REPEAT    for 999
col DETAIL    for a25 word_wrapped

select 
RULE_ID
,NAME
,PROC
,TYPE
,P1
,P2
,STATUS
,INTERVAL
,REPEAT
,to_char(LAST_DATE,'YYYY-MON-DD HH24:MI') last_date
,DETAIL
from exp_rule_setup
order by rule_id;