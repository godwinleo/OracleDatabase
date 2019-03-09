accept directory char prompt 'Directory : '
accept netlink char prompt 'Network link : '
accept source_owner char prompt 'Source Owner : '

declare
	v_directory varchar2(30) := '&directory';
	v_source_owner varchar2(30) := '&source_owner';
	v_dp_job number;
	v_job_state VARCHAR2 (30);
	v_status ku$_Status; -- data pump status
	job_not_exist EXCEPTION;
	PRAGMA EXCEPTION_INIT (job_not_exist, -31626);
	v_job_name varchar2(200);
	v_rundate varchar2(20);
	v_logs ku$_LogEntry;
    v_row  PLS_INTEGER;
begin
	
	select to_char(sysdate,'YYYYMMDDHH24MI') into v_rundate from dual;
	v_job_name := 'EXP@'||v_source_owner||'.'||v_rundate;
	
	dbms_output.put_line(' Starting ... ');
	v_dp_job := DBMS_DATAPUMP.open (operation => 'EXPORT',
									job_mode => 'SCHEMA', --FULL
									job_name => v_job_name );
									--remote_link => v_network_link);

	DBMS_DATAPUMP.SET_PARALLEL(	handle => v_dp_job,
							degree => 6
							);									
								
	dbms_output.put_line(' expdp job created: '||v_dp_job);
	
	DBMS_DATAPUMP.add_file(	handle => v_dp_job,
							filename => v_job_name||'.log',
							DIRECTORY => v_directory,
							filetype => DBMS_DATAPUMP.ku$_file_type_log_file
							);
	
	DBMS_DATAPUMP.add_file(	handle => v_dp_job,
							filename => v_job_name||'.%u.dmp',
							DIRECTORY => v_directory,
							filetype => DBMS_DATAPUMP.ku$_file_type_dump_file
							);
	/*						
	DBMS_DATAPUMP.metadata_filter(	Handle => v_dp_job,
									Name => 'SCHEMA_EXPR',
									value => 'LIKE ''OFS%'''
									--object_path => 'USER'
									);
	*/								
	DBMS_DATAPUMP.metadata_filter(	Handle => v_dp_job,
									Name => 'SCHEMA_NAME',
									value => v_source_owner					
								);
									
/*	
	DBMS_DATAPUMP.metadata_filter(	Handle => v_dp_job,
									Name => 'INCLUDE_PATH_EXPR',
									value => 'IN (''USER'') '
									--object_path => 'USER'
									);
									*/
																		
	/* for Metadata Only use INCLUDE_ROWS = 0 */
	DBMS_DATAPUMP.data_filter(	Handle => v_dp_job,
							Name => 'INCLUDE_ROWS',
							value => 1
						);
												
	DBMS_DATAPUMP.metadata_filter(	Handle => v_dp_job,
								Name => 'EXCLUDE_PATH_EXPR',
								value => 'IN (''USER'',''STATISTICS'') '
						);
						
	dbms_output.put_line(' Parameters set: '||v_dp_job);
	
	DBMS_DATAPUMP.start_job(v_dp_job);
	
	DBMS_DATAPUMP.DETACH(v_dp_job);
	dbms_output.put_line(' Running '||v_dp_job);
	
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
