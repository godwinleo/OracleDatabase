define owner=ZENITH
define table=TCALM1
set serveroutput on size 10000
set feed off

spool &(table)_indexes.sql

declare
v_owner varchar2(30) :=upper('&owner');
v_tabname varchar2(30) :=upper('&table');

cursor ind_cursor
is
select owner,index_name from dba_indexes
where table_owner=v_owner and table_name=v_tabname;
lv_indown varchar2(30);
lv_indname varchar2(30);
sqlstr varchar(200);
l_output long;

begin
open ind_cursor; 
loop
	fetch ind_cursor into lv_indown, lv_indname;
EXIT WHEN ind_cursor%NOTFOUND; 
sqlstr :='select dbms_metadata.get_ddl('''||'INDEX'||''','''||lv_indname||''','''||lv_indown||''') from dual';
dbms_output.put_line(sqlstr);
--execute immediate 'select dbms_metadata.get_dll ( :a , :b, :c ) from dual' using 'INDEX',lv_indown,lv_indname;
execute immediate sqlstr into l_output;
dbms_output.put_line(l_output);
dbms_output.put_line(';');
	
end loop;
close ind_cursor;

end;
/

spool off
