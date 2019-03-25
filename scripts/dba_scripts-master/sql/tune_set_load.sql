set serveroutput on
set pages 80
set lines 185

exec dbms_output.put_line('Sqlset name: ');
define name=&1
exec dbms_output.put_line('Sqlset schema: ');
define schema=&2

declare
c_sql dbms_sqltune.sqlset_cursor;
begin
	open c_sql for
	select value(p)
	from table( dbms_sqltune.select_cursor_cache (
			'parsing_schema_name =''&schema''') ) p;

	dbms_sqltune.load_sqlset (
		sqlset_name => '&name',
		populate_cursor => c_sql);

	close c_sql;
end;
/
