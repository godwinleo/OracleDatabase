set serveroutput on

accept sid			char prompt	'Session SID :		'
accept serial		char prompt	'Session Serial# :	'
accept identifier	char prompt	'TrcIdentifier :	'

begin
	execute immediate 'ALTER SESSION SET tracefile_identifier = &identifier';
	
	sys.dbms_system.set_ev(&sid,&serial,10046,12,'');
	
	--sys.dbms_system.set_sql_trace_in_session(&sid,&serial,true);
/*
	DBMS_MONITOR.SESSION_TRACE_ENABLE(
    session_id   => &sid,
    serial_num   => &serial,
    waits        => null,
    binds        => null,
    plan_stat    => null);
	*/
		
exception
when others then
	dbms_output.put_line('Error tracing -> '||SQLERRM);
end;
/