col name for a15
col check_name for a30
col status for a20
col start_time for a30
col end_time for a30
select run_id,start_time,END_TIME,name,check_name,status,error_number 
from v$hm_run
order by start_time
/
