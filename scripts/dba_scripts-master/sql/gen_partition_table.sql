define 
spool %TABLE%_create.sql
SELECT dbms_metadata.get_ddl('TABLE', '&object','&owner') definition
FROM DUAL;


spool off

define owner=ZENITH
define table=TCALM1
spool %TABLE%_indexes.sql
declare
v_owner varchar2(30)=upper('&owner');
v_tabname varchar2(30)=upper('&table');

cursor ind_cursor
is
select index_name,index_owner from dba_indexes
where table_owner=v_owner and table_name=v_tabname;

lv_indown varchar2(30);
lv_indname varchar2(30);

begin
open ind_cursor 
loop
	fetch ind_cursor into lv_indown, lv_indname
EXIT WHEN ts_cursor%NOTFOUND; 
execute immediate ('dbms_metadata.get_dll('''INDEX''','''lv_indname''','''lv_indown''');');
	
end loop;
close ind_cursor;

end;

spool off

spool %TABLE%_grants.sql

spool off

spool %TABLE%_constraints.sql

spool off
