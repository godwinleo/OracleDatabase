accept directory char prompt 'Directory : '
accept netlink char prompt 'Network link : '
accept source_owner char prompt 'Source Owner : '
accept remap_schema char prompt 'Remap Schema : '

declare

	v_directory varchar2(30) := '&directory';
	v_network_link varchar2(30) := '&netlink';
	v_source_owner varchar2(30) := '&source_owner';
	v_remap_schema varchar2(30) := '&remap_schema';
	v_job_name varchar2(200);
	v_dp_job number;
	v_job_state VARCHAR2 (30);
	v_status ku$_Status; -- data pump status
	job_not_exist EXCEPTION;
	PRAGMA EXCEPTION_INIT (job_not_exist, -31626);

	v_logs ku$_LogEntry;
    v_row  PLS_INTEGER;
begin
	v_job_name := 'IMP_'||replace(v_source_owner,'$','#')||'\@'||v_network_link;
	dbms_output.put_line(' Starting ... ');
	v_dp_job := DBMS_DATAPUMP.open (operation => 'IMPORT',
									job_mode => 'SCHEMA',
									job_name => v_job_name,
									remote_link => v_network_link);
						
	dbms_output.put_line(' expdp job created: '||v_dp_job);
	
	DBMS_DATAPUMP.add_file(	handle => v_dp_job,
							filename => v_job_name||'.log',
							DIRECTORY => v_directory,
							filetype => DBMS_DATAPUMP.ku$_file_type_log_file
							);
	
	/*
	DBMS_DATAPUMP.add_file(	handle => v_dp_job,
							filename => v_job_name||'.sql',
							DIRECTORY => 'EXP_MQ38255',
							filetype => DBMS_DATAPUMP.KU$_FILE_TYPE_SQL_FILE
							);
	*/
							
	dbms_output.put_line(' log set : '||v_dp_job);
	/*
	DBMS_DATAPUMP.add_file(	handle => v_dp_job,
							filename => v_job_name||'%u.dmp',
							DIRECTORY => v_directory,
							filetype => DBMS_DATAPUMP.ku$_file_type_dump_file
							);
	*/						
	DBMS_DATAPUMP.metadata_filter(	Handle => v_dp_job,
									Name => 'SCHEMA_EXPR',
									value => 'LIKE '''||v_source_owner||''''
									);
	
	/*
	DBMS_DATAPUMP.metadata_filter(	Handle => v_dp_job,
									Name => 'NAME_EXPR',
									value => 'LIKE '''||v_source_table||''''
									);
	*/
	
	DBMS_DATAPUMP.metadata_filter(	Handle => v_dp_job,
									Name => 'INCLUDE_PATH_EXPR',
									value => 'IN (''DB_LINK'')'
									--object_path => 'USER'
									);
	
	/*
	if v_filter is not null
	then
	DBMS_DATAPUMP.data_filter(	Handle => v_dp_job,
								Name => 'SUBQUERY',
								value => v_filter,
								table_name => v_source_table,
								schema_name => v_source_owner
							);
	end if;
	*/
	/* for Metadata Only use INCLUDE_ROWS = 0 */
	DBMS_DATAPUMP.data_filter(	Handle => v_dp_job,
							Name => 'INCLUDE_ROWS',
							value => 1
						);
	
	if v_remap_schema is not null
	then
		DBMS_DATAPUMP.METADATA_REMAP (
										v_dp_job, 
										'REMAP_SCHEMA',
										v_source_owner,
										v_remap_schema
									);
	end if;	
		
	DBMS_DATAPUMP.SET_PARAMETER(	handle => v_dp_job,
									Name => 'TABLE_EXISTS_ACTION',
									value => 'SKIP'
								);
	
	DBMS_DATAPUMP.METADATA_TRANSFORM (	handle => v_dp_job,
									Name => 'SEGMENT_ATTRIBUTES',
									value => 0
								);
	
	dbms_output.put_line(' Parameters set: '||v_dp_job);
	
	DBMS_DATAPUMP.start_job(v_dp_job);
	
	--DBMS_DATAPUMP.DETACH(v_dp_job);
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
