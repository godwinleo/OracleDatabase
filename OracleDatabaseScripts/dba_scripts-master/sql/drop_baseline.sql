/*
--define plan=&1
select 'dbms_spm.DROP_SQL_PLAN_BASELINE ('''||sql_handle||''','''||plan_name||''');'  sql_drop
from  DBA_SQL_PLAN_BASELINES
--where plan_name like ('&plan')
where origin ='AUTO-CAPTURE'
/
*/
declare
rc number;

begin

	for v_pb in ( select sql_handle,plan_name from dba_sql_plan_baselines where origin ='AUTO-CAPTURE')
	loop
		begin
		rc := dbms_spm.DROP_SQL_PLAN_BASELINE ( v_pb.sql_handle , v_pb.plan_name);
		if rc = 0 then
			dbms_output.put_line ('Plan '||v_pb.plan_name||' for baseline '||v_pb.sql_handle||' drop successfully.');
		else
			dbms_output.put_line ('Failed to drop plan '||v_pb.plan_name||' for baseline '||v_pb.sql_handle||' .');

		end if;
	end loop;
end loop;
end;
/

