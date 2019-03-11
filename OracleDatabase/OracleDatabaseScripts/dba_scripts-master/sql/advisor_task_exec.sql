/*
1- Se crea la task del SQL Access Advisor con este script.
2- Se crea el workload con advisor_workload_create
3- Se linkea el workload a la task advisor_workload_ref
4- Se corre el advisor
5- Se genera el reporte
*/

set echo off
set feed on
accept taskname varchar2 prompt 'enter SQL Access advisor Task name'
declare
l_task_name varchar2(100) :='&taskname';

begin
	DBMS_ADVISOR.execute_task ( task_name	=> l_task_name);
	
	exception
	when others then
		begin
			dbms_output.put_line (SQLERRM);
		end;

end;
/

undef taskname
