set serveroutput on
set feed on
def owner=&1

begin
  dbms_space_admin.drop_empty_segments ( 
    schema_name => upper('&owner'), 
    table_name => NULL, 
    partition_name => NULL); 
end; 
/

