set serveroutput on
set long 10000000

accept owner char prompt 'Owner :'
accept dblink_name char prompt 'DBLINK Name :'
accept target_user char prompt 'Target User :'
accept password char prompt 'Password :'
accept tnsentry char prompt 'TNS Entry :'

declare
uid number;

v_owner varchar2(30) := '&owner';
v_dblink varchar2(30) := '&dblink_name';
v_tgt_user varchar2(30) := '&target_user';
v_passwd varchar2(30) := '&password';
v_host varchar2(50) := '&tnsentry';
sqltext varchar2(1000);
sqltext_drop varchar2(1000);

myint integer;
begin
	select user_id into uid from all_users where username=upper(v_owner);

	sqltext_drop :='drop DATABASE LINK "'||v_dblink||'"';
	sqltext :='CREATE DATABASE LINK "'||v_dblink||'" CONNECT TO '||v_tgt_user||' IDENTIFIED BY "'||v_passwd||'"'||' USING '''||v_host||'''';
	
	myint:=sys.dbms_sys_sql.open_cursor();
	sys.dbms_output.put_line(sqltext_drop);
	
	begin
		sys.dbms_sys_sql.parse_as_user(myint,sqltext_drop,dbms_sql.native,UID);
		dbms_output.put_line('Dropped database link in '||v_owner); 
	exception
	when others then
		dbms_output.put_line('Cannot drop database link in '||v_owner||' -> '||SQLERRM); 
	end;
	execute immediate 'grant create database link to '||v_owner;
	sys.dbms_output.put_line(sqltext);
	sys.dbms_sys_sql.parse_as_user(myint,sqltext,dbms_sql.native,UID);
	sys.dbms_sys_sql.close_cursor(myint);
	dbms_output.put_line('link created successfully in '||v_owner); 
exception
when others
	then
		dbms_output.put_line('error creating link in '||v_owner||' -> '||SQLERRM); 
end ;
/

