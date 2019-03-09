
begin

	for sched_job in ( 	select owner, job_name 
						--,enabled
						,state
						--,nvl(job_action,program_name) action
						,nvl(REPEAT_INTERVAL,schedule_name) schedule,schedule_type
						,to_char (next_run_date,'YYYY-MON-DD HH24:MI:SS')
						, failure_count
						from dba_scheduler_jobs
						where FAILURE_COUNT > 0
						order by schedule_type
					  )
	loop
		begin
			DBMS_SCHEDULER.DISABLE (NAME => sched_job.owner||'.'||sched_job.job_name, FORCE => TRUE);
			DBMS_SCHEDULER.ENABLE (NAME => sched_job.owner||'.'||sched_job.job_name);
			dbms_output.put_line ('Scheduler Job was reset -> '||sched_job.owner||'.'||sched_job.job_name);
		exception
		when others then
			dbms_output.put_line ('Error resetting Scheduler Job : '||sched_job.owner||'.'||sched_job.job_name||' -> '||SQLERRM);
		end;
	end loop;
	
exception
when others then
	dbms_output.put_line ('Error Fixing Scheduler Jobs : '||SQLERRM);
end;
/
