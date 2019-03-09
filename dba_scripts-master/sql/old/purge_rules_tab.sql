def owner=&1
def tab=&2
col log_id for 99999999
col job_id for 999
col min_month for 99 
col status for a8
col rule_id for 999
col tab for a40
col action for a10
col historical for a30
col key_format for a10

select ownname||'.'||tabname TAB, KEY_FORMat, tp.STATUS, tp.RULE_ID, tp.COMPRESSED, MIN_MONTH, HISTORICAL
, STEP_ID, DATA_ONLINE, DATA_UNIT, DATA_DUE, KEEP, ACTION, DROP_EMPTY
, decode ( DATA_DUE , 'YES' ,
		decode ( DATA_UNIT, 'MONTH', to_Date(add_months(trunc(sysdate,'MM'),-DATA_ONLINE-1)) 
		   , 'YEAR' , to_Date(add_months(trunc(sysdate,'MM'),-DATA_ONLINE*12)) 
		   ) ,
		   'NO' ,
		   decode ( DATA_UNIT, 'MONTH', to_Date(trunc(add_months(sysdate,-DATA_ONLINE-1),'MM')) 
		   , 'YEAR' , to_Date(trunc(add_months(sysdate,-(DATA_ONLINE*12-12)),'YY'))
		   )
	)ret
from dbadmin.dbs_purge_rules rule, dbadmin.dbs_purge_step step
, dbadmin.dbs_tab_part tp
where
tp.rule_id=rule.rule_id (+)
and rule.rule_id=step.rule_id (+)
and tp.ownname like upper('&owner')
and tp.tabname like upper('&tab')
order by tab,rule.rule_id,tab,step_id 
/
