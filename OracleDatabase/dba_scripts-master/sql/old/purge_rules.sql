col log_id for 99999999
col job_id for 999
def app=&1
col min_month for 99 
col status for a8
col rule_id for 999
select *
from dbadmin.dbs_purge_rules rule, dbadmin.dbs_purge_step step
where
rule.rule_id=step.rule_id
and rule.application like upper('&app')
order by rule.rule_id,step_id 
/
