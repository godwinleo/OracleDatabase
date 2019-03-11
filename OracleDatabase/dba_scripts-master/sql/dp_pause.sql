accept owner char prompt 'Job Owner : ' 
accept job char prompt 'Job Name : ' 

declare
	v_dp_job number;
	v_job_state VARCHAR2 (30);
	v_status ku$_Status; -- data pump status
	job_not_exist EXCEPTION;
	PRAGMA EXCEPTION_INIT (job_not_exist, -31626);
	v_job_name varchar2(200) := '&job';
	v_job_owner varchar2(200) := upper('&owner');
	v_logs ku$_LogEntry;
    v_row  PLS_INTEGER;
	
begin
	
	dbms_output.put_line(' Starting ... ');
	v_dp_job := DBMS_DATAPUMP.ATTACH (
										job_name => v_job_name ,
										job_owner => v_job_owner
										
									);
								
	dbms_output.put_line(' expdp job attached: '||v_dp_job);
	
	DBMS_DATAPUMP.STOP_JOB(	handle => v_dp_job,
							immediate => 0		-- 0 = wait workers to finish, nonzero immediate
							, keep_master => 1	-- 0 = delete, nonzero = keep
							, delay => 60		-- default 
							);
							
	DBMS_DATAPUMP.DETACH(v_dp_job);
	dbms_output.put_line(' Job Paused : '||v_dp_job);

	
exception
when job_not_exist then
	dbms_output.put_line(' error ! -> '||SQLERRM);
	DBMS_DATAPUMP.GET_STATUS (	handle => null,
								mask =>     8,
								timeout =>  null,
								job_state => v_job_state,
								status => v_status
							);
	v_logs := v_status.error;
	v_row := v_logs.FIRST;
	
	loop
		EXIT WHEN v_row is null;
		dbms_output.put_line('logLineNumber=' || v_logs(v_row).logLineNumber);
		dbms_output.put_line('errorNumber=' || v_logs(v_row).errorNumber);
		dbms_output.put_line('LogText=' || v_logs(v_row).LogText);	
		v_row := v_logs.NEXT(v_row);
	end loop;
when others then
	dbms_output.put_line(' error2 ! -> '||SQLERRM);
	DBMS_DATAPUMP.GET_STATUS (	handle => v_dp_job,
								mask =>     8,
								timeout =>  null,
								job_state => v_job_state,
								status => v_status
							);
	dbms_output.put_line('tesst3');
	v_logs := v_status.error;
	v_row := v_logs.FIRST;
	
	loop
		EXIT WHEN v_row is null;
		dbms_output.put_line('logLineNumber=' || v_logs(v_row).logLineNumber);
		dbms_output.put_line('errorNumber=' || v_logs(v_row).errorNumber);
		dbms_output.put_line('LogText=' || v_logs(v_row).LogText);	
		v_row := v_logs.NEXT(v_row);
	end loop;
	DBMS_DATAPUMP.stop_job(v_dp_job);
end;
/
