col log_id for 99999999
col job_id for 999
def owner=&1
def tab=&2
col tab for a40
select ownname||'.'||tabname tab
,created
,status
,detail
from dbadmin.dbs_tab_exceptions
where ownname like upper('&owner')
and tabname like upper('&tab')
order by tabname desc
/
