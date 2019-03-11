set serveroutput on
/*
DBMS_SQLTUNE.CREATE_TUNING_TASK(
  sql_id           IN VARCHAR2,
  plan_hash_value  IN NUMBER   := NULL,
  scope            IN VARCHAR2 := SCOPE_COMPREHENSIVE,
  time_limit       IN NUMBER   := TIME_LIMIT_DEFAULT,
  task_name        IN VARCHAR2 := NULL,
  description      IN VARCHAR2 := NULL)
RETURN VARCHAR2;

*/
undef schema sqlset

declare
v_set varchar2(100) := '&sqlset';
v_schema varchar2(100) := '&schema';
taskname varchar2(100);

begin
--dbms_output.put_line('test'||v_sql_id||v_plan||v_schema);
taskname:= DBMS_SQLTUNE.CREATE_TUNING_TASK(
  sqlset_name => v_set
  , scope => DBMS_SQLTUNE.SCOPE_COMPREHENSIVE
  , time_limit => 15*60 --15 min
  , task_name => 'Tune_'||v_set
  , description => 'Tuning for '||v_schema
)
;

dbms_output.put_line(taskname);

end;
/
