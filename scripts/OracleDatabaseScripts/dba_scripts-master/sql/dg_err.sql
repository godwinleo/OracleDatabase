set pages 200
col facility for a25
col severity for a13
col message for a99
col dest_id for 999
col err for 99999
select 
 FACILITY ,SEVERITY ,DEST_ID ,ERROR_CODE err ,CALLOUT ,to_char(TIMESTAMP,'YYYY-MON-DD HH24:MI:SS') timestamp ,MESSAGE
from v$dataguard_status
where timestamp > sysdate-(1/24*12)
and Severity not in ('Control','Informational')
order by message_num
/
