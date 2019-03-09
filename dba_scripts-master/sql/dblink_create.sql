set echo off
set feed off
SET LONG 1000000000
set trims on
set serveroutput on
set define on

accept owner char prompt 'Schema : '
accept dblink_name char prompt 'DB Link name : '
accept dest_owner char prompt 'Connect to : '
accept password char prompt 'Password : '
accept tns_entry char prompt 'TNS entry : '

declare 
v_execute varchar2(3) := nvl(upper('&exec_yn'),'NO');
v_tbs varchar(30);
v_owner varchar(30) := upper('&owner');
v_tbsdef long;
sqlstr varchar2(2000);
l_output long;

lv_tabname varchar2(50);
lv_mviewname varchar2(50);
lv_objname varchar2(50):= upper('&dblink_name');
lv_dest_owner varchar2(50):= upper('&dest_owner');
lv_password varchar2(50):= '&password';
lv_tns varchar2(50):= upper('&tns_entry');
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
	
	begin
		myint:=sys.dbms_sys_sql.open_cursor();
		select user_id into uid from all_users where username=v_owner;
		sqlstr :='create database link '||lv_objname||' connect to "'||lv_dest_owner||'" identified by "'||lv_password||'" using  '''||lv_tns||''' ';
		dbms_output.put_line(sqlstr);
		sys.dbms_sys_sql.parse_as_user(myint,sqlstr,dbms_sql.native,UID);
		sys.dbms_sys_sql.close_cursor(myint);
	exception
		when others then
		dbms_output.put_line('Error creating dblink '||lv_objname||' as user: '||v_owner||'. Error -> '||SQLERRM);
	end;
	
end;
/

