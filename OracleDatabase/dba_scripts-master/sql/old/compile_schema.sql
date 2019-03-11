set echo off
set feed off
col definition for a200
SET LONG 1000000000
set lines 200
set pages 0
set trims on
set serveroutput on
set define on
set feed on
define owner=&1


declare 
v_owner varchar(30) := '&owner';

sqlstr varchar(200);
l_output long;

begin

	for inv_obj in ( select owner,decode(object_type,'PACKAGE BODY','PACKAGE',object_type) object_type,object_name,decode(object_type,'PACKAGE BODY',' BODY','') body from dba_objects where status='INVALID' and owner like upper(v_owner) )
	loop
		begin
		sqlstr :='alter '||inv_obj.object_type||' '||inv_obj.owner||'.'||inv_obj.object_name||' compile'||inv_obj.body;
		dbms_output.put_line(sqlstr);
		execute immediate sqlstr;
		exception
		when others then
		dbms_output.put_line(sqlstr||':'||SQLERRM);
		end;
	end loop;
end;
/

