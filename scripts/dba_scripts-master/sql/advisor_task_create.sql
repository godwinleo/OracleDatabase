/*
1- Se crea la task del SQL Access Advisor con este script.
2- Se crea el workload con advisor_workload_create
3- Se linkea el workload a la task
4- Se corre el advisor
5- Se genera el reporte
*/

set echo off
set feed on
accept taskname varchar2 PROMPT 'enter SQL Access advisor task name'
accept description varchar2 PROMPT 'enter description'
declare
l_taskname varchar2(100) :='&taskname';
l_task_desc varchar2(300) :='&description';

begin
	DBMS_ADVISOR.create_task (
		advisor_name => DBMS_ADVISOR.sqlaccess_advisor,
		task_name    => l_taskname,
		task_desc    => l_task_desc
	);

end;
/

undef taskname description
