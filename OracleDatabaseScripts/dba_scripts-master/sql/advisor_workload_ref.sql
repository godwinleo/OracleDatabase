/*
1- Se crea la task del SQL Access Advisor con este script.
2- Se crea el workload con advisor_workload_create
3- Se linkea el workload a la task advisor_workload_ref
4- Se corre el advisor
5- Se genera el reporte
*/

set echo off
set feed on
accept taskname varchar2 PROMPT 'enter SQL Access advisor Task name'
accept sqlwkldname varchar2 PROMPT 'enter SQL Access advisor Workload name'
declare
l_task_name varchar2(100) :='&taskname';
l_sqlwkld_name varchar2(100) :='&sqlwkldname';

begin
	DBMS_ADVISOR.ADD_SQLWKLD_REF (
		task_name	=> l_task_name
		,workload_name	=> l_sqlwkld_name
	);
	
	exception
	when others then
		begin
			dbms_output.put_line (SQLERRM);
		end;

end;
/

undef taskname sqlwkldname
