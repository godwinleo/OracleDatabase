col run_id for 9999
col policy_name for a60
col col_no for 999
col col_value for a100

select run_id,run_date,policy_name,col_no,col_value 
from dbadmin.fortidb_scan_failures_local
where run_id = (select max(run_id) from dbadmin.fortidb_scan_failures_local)
order by run_date,policy_name,col_no
/
