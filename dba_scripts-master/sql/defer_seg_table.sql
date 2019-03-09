set serveroutput on
set feed on
def owner=&1
def tab=&2

begin
  dbms_space_admin.drop_empty_segments ( 
    schema_name => upper('&owner'), 
    table_name => upper('&tab'), 
    partition_name => NULL); 
end; 
/

