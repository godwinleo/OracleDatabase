set serveroutput on

exec dbms_output.put_line('Sqlset name: ');
define name=&1
exec dbms_output.put_line('Sqlset schema: ');
define schema=&2

declare
c_sql dbms_sqltune.sqlset_cursor;
begin
	dbms_scheduler.create_program(
		program_name   => '&(schema)_SQLTUNE_LOAD_PROG',
		program_type   => 'PLSQL_BLOCK',
		program_action => ' 
				declare
				c_sql dbms_sqltune.sqlset_cursor;
				begin
					open c_sql for
					select value(p)
					from table( dbms_sqltune.select_workload_repository (
							&snap_begin,
							&snap_end,
							basic_filter => 'upper(parsing_schema_name) = ''&schema''') 
					) p;

					dbms_sqltune.load_sqlset (
							sqlset_name => '''&name''',
							populate_cursor => c_sql);

						close c_sql;
					END;',
		enabled        => TRUE,
		comments       => 'Program to gather SCOTT''s statistics using a PL/SQL block.'
	);
end;
/
