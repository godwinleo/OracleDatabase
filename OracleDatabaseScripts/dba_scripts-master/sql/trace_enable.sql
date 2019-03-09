set serveroutput on

accept identifier	char prompt	'TrcIdentifier :	'

begin
	execute immediate 'ALTER SESSION SET tracefile_identifier = '''||&identifier||'';
	
	DBMS_SESSION.SESSION_TRACE_ENABLE(
		waits     => null,
		binds     => null, 
		plan_stat => null
		);
	
exception
when others then
	dbms_output.put_line('Error tracing -> '||SQLERRM);
end;
/