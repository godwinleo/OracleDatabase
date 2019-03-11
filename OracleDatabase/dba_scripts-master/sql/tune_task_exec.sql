set serveroutput on

declare
taskname varchar2(100):='&task';

begin
DBMS_SQLTUNE.execute_TUNING_TASK( task_name => taskname );
end;
/
