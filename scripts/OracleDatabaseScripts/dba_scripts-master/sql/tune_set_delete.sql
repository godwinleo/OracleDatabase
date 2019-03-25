set serveroutput on
set pages 80
set lines 185

define name=&1
begin
	dbms_sqltune.delete_sqlset (
		sqlset_name => '&name'
		);

end;
/
