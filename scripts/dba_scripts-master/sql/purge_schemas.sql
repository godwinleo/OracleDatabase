set echo off
set feed off
SET LONG 1000000000
set trims on
set serveroutput on
set define on

accept owner char prompt 'Schema/s to Purge : '
accept exec_yn char prompt 'Sure? Please confirm YES : '

declare 
v_execute varchar2(3) := nvl(upper('&exec_yn'),'NO');
v_tbs varchar(30);
v_owner varchar(30) := upper('&owner');
v_tbsdef long;
sqlstr varchar2(2000);
l_output long;

lv_tabname varchar2(50);
lv_mviewname varchar2(50);
lv_objname varchar2(50);
lv_objtype varchar2(50);

myint integer;
uid number;

   not_found EXCEPTION;
   abort EXCEPTION;
   PRAGMA EXCEPTION_INIT(not_found, -04043);
   PRAGMA EXCEPTION_INIT(abort, -20001);

begin

	if v_execute !='YES' then
		dbms_output.put_line('Exiting');
		raise abort;
	end if;

	for mview in (
					select owner,mview_name from dba_mviews
					where owner like v_owner
				)
	loop
	
		sqlstr :='drop materialized view '||mview.owner||'.'||mview.mview_name;
		dbms_output.put_line(sqlstr);
		execute immediate sqlstr;
		
	end loop;

	for tab in (
					select owner,tab.table_name from dba_tables tab
					where tab.owner like v_owner
				)
	/*
	and not exists ( select 1 from dba_constraints cons
		where tab.table_name=cons.table_name
	and tab.owner=cons.owner
	and cons.constraint_type='R')
	*/
	loop
		
		begin
			sqlstr :='drop table "'||tab.owner||'"."'||tab.table_name||'" cascade constraints';
			dbms_output.put_line(sqlstr);
			execute immediate sqlstr;
		exception
		when others then
			dbms_output.put_line('Error :S -> '||SQLERRM);
		end;

	end loop;

	for rec_bin in (
					select owner,original_name,type from dba_recyclebin
					where owner like v_owner and type like '%TABLE%'
					)
	loop
		sqlstr :='purge '||rec_bin.type||' '||rec_bin.owner||'.'||rec_bin.original_name;
		dbms_output.put_line(sqlstr);
		execute immediate sqlstr;
		
	end loop;

	for job in (
					select owner,job_name from dba_scheduler_jobs
					where owner like v_owner
				)
	loop
		begin
			dbms_Scheduler.drop_job(job.owner||'.'||job.job_name);
		exception
			when others then
				dbms_output.put_line('Error Removing Scheduler Job !: '||SQLERRM||' - : '||job.owner||' - '||job.job_name);
		end;

	end loop;
	
	/*
	for job in (
					select job,schema_user from dba_jobs
					where schema_user like v_owner
				)
	loop
		begin
			sys.dbms_ijob.remove(job.job);
		exception
			when others then
				dbms_output.put_line('Error Removing Job !: '||SQLERRM||' - : '||job.schema_user||' - '||job.job);
		end;

	end loop;
	*/

	for obj in (
					select owner,object_name,object_type from dba_objects
					where owner like v_owner and object_type not in ('DATABASE LINK','JOB')
				)
	loop
		begin
			sqlstr :='drop '||obj.object_type||' "'||obj.owner||'"."'||obj.object_name||'"';
			dbms_output.put_line(sqlstr);
			execute immediate sqlstr;
		exception
			when not_found then	
				null;			
			when others then
				dbms_output.put_line('Error!: '||SQLERRM||' - : '||obj.owner||' - '||obj.object_name);
		end;

	end loop;

	/*
	for db_link in (
				select owner,object_name,object_type from dba_objects
				where owner like v_owner and object_type='DATABASE LINK'
				)
	loop
		
		begin
			myint:=sys.dbms_sys_sql.open_cursor();
			select user_id into uid from all_users where username=db_link.owner;
			sqlstr :='drop '||db_link.object_type||' "'||db_link.object_name||'"';
			dbms_output.put_line(sqlstr);
			sys.dbms_sys_sql.parse_as_user(myint,sqlstr,dbms_sql.native,UID);
			sys.dbms_sys_sql.close_cursor(myint);
		exception
			when others then
			dbms_output.put_line('Error runnning as user: '||SQLERRM||' - : '||db_link.object_type||' - '||db_link.object_name);
		end;
	
	end loop;
	*/
	
end;
/

