/*
1- Se crea la task del SQL Access Advisor con este script.
2- Se crea el workload con advisor_workload_create
3- Se linkea el workload a la task
4- Se corre el advisor
5- Se genera el reporte
*/

set echo off
set feed on
accept taskname varchar2 PROMPT 'enter SQL Access advisor task name to reset '
declare
l_taskname varchar2(100) :='&taskname';

begin
	DBMS_ADVISOR.reset_task ( task_name    => l_taskname ); 
end;
/

undef taskname 
