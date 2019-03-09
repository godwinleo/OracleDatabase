set serveroutput on
set pages 80
set lines 185

--exec dbms_output.put_line('Sqlset name: ');
ACCEPT name CHAR PROMPT 'Sqlset name:'
--exec dbms_output.put_line('Sqlset description: ');
ACCEPT description CHAR PROMPT 'Sqlset description:'

begin
	dbms_sqltune.create_sqlset(
		sqlset_name => '&name',
		description => '&description');
end;
/
