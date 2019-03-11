/*
1- Se crea la task del SQL Access Advisor con este script.
2- Se crea el workload con advisor_workload_create
3- Se linkea el workload a la task advisor_workload_ref
4- Se corre el advisor
5- Se genera el reporte
*/

set echo off
set feed on
accept sqlwkldname varchar2 PROMPT 'enter SQL Access advisor Workload name'
accept description varchar2 PROMPT 'enter description'
accept sqlsetname varchar2 PROMPT 'enter SQL Tuning Set name'
accept sqlsetowner varchar2 PROMPT 'enter SQL Tuning Set owner'
declare
l_sqlwkld_name varchar2(100) :='&sqlwkldname';
l_desc varchar2(300) :='&description';
l_sqlset_owner varchar2(100) :='&sqlsetowner';
l_sqlset_name varchar2(100) :='&sqlsetname';
l_saved_rows number :=0;
l_failed_rows number :=0;

begin
	DBMS_ADVISOR.create_sqlwkld (
		workload_name	=> l_sqlwkld_name,
		description	=> l_desc
	);
	
	DBMS_ADVISOR.IMPORT_SQLWKLD_STS (
		workload_name	=> l_sqlwkld_name
		,sts_owner	=> l_sqlset_owner
		,sts_name	=> l_sqlset_name
		--,import_mode    IN VARCHAR2 := 'NEW',
		--,priority       IN NUMBER := 2,
		,saved_rows	=> l_saved_rows
		,failed_rows	=> l_failed_rows
	);

	dbms_output.put_line ('Created workload '||l_sqlwkld_name||'. Imported '||l_saved_rows||' rows. Rejected '||l_failed_rows||' rows.');
	exception
	when others then
		begin
			dbms_output.put_line (SQLERRM);
			dbms_output.put_line ('error, droppeando el workload.');
			DBMS_ADVISOR.delete_sqlwkld (l_sqlwkld_name);
		end;

end;
/

undef sqlwkldname description sqlsetname sqlsetowner
