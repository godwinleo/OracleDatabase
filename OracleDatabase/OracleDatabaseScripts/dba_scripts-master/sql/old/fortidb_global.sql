col run_id for 9999
col policy_name for a60
col servername for a20
col db_sid for a10

select run_id,run_date,servername,db_sid,policy_name, count(1) failures
from dbadmin.fortidb_scan_failures_locals
where run_id = (select max(run_id) from dbadmin.fortidb_scan_failures_locals)
and col_no=1
group by run_id,run_date,servername,db_sid,policy_name 
order by servername,db_sid,policy_name
/


/*
check
select policy_name,servername,db_sid
,count( 1) failures
, count(policy_name) over ( partition by policy_name,db_sid,servername)  failures2
--, sum(1) over ( partition by policy_name,db_sid,servername)  failures
--, grouping( policy_name)  failures
from dbadmin.fortidb_scan_failures_locals
where run_id = (select max(run_id) from dbadmin.fortidb_scan_failures_locals)
and col_no=1
--group by run_id,run_date,rollup(policy_name,db_sid,servername)
group by rollup( policy_name,servername,db_sid)
--order by servername,db_sid,policy_name
/

*/
