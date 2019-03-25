col METRICS_NAME for a40
col WARNING for a20
col CRITICAL for a20
col OBJECT_TYPE for a15
col OBJECT_NAME for a15

select METRICS_NAME
,warning_operator||' '||WARNING_VALUE warning, critical_operator||' '||CRITICAL_VALUE critical, OBSERVATION_PERIOD time, CONSECUTIVE_OCCURRENCES repeat
,status
,INSTANCE_NAME
,OBJECT_TYPE, OBJECT_NAME
from dba_thresholds 
order by OBJECT_TYPE, metrics_name, OBJECT_NAME;