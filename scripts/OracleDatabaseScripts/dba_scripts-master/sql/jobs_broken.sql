set pages 200
set lines 185
set trims on
col job for 999999
col what for a70 word_wrapped
col interval for a40
col schema_user for a15
select job,schema_user,what,last_date,interval,next_date,broken, failures
from dba_jobs
where broken='Y'
order by next_date
;
