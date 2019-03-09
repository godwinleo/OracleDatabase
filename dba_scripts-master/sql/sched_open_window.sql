set feed on
set serveroutput on

accept window char prompt 'DBMS_SCHEDULER Window Name : '

BEGIN
  -- Open window.
  DBMS_SCHEDULER.open_window (
   window_name => upper('&window'),
   duration    => INTERVAL '2' HOUR,
   force       => TRUE);

exception
when others then
	dbms_output.put_line('Error -> '||SQLERRM);
END;
/