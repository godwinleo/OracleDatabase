set echo off
set feed off
SET LONG 1000000000
set trims on
set serveroutput on
set define on

accept owner char prompt 'Schema : '
accept name char prompt 'DB Link name : '
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
lv_objname varchar2(50):= upper('&name');
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
	
	for db_link in (
				select owner,object_name,object_type from dba_objects
				where owner like v_owner
				and object_name like lv_objname
				and object_type='DATABASE LINK'
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
	
	
end;
/

