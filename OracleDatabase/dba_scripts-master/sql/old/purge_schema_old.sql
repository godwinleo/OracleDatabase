set echo off
set feed off
col definition for a200
SET LONG 1000000000
set lines 200
set pages 0
set trims on
set serveroutput on
set define on
define owner=&1


declare 
v_tbs varchar(30);
v_owner varchar(30) := upper('&owner');
v_tbsdef long;

cursor tab_cursor
is
select tab.table_name from dba_tables tab
where tab.owner=v_owner;

cursor recyclebin_cursor
is
select original_name,type from dba_recyclebin
where owner=v_owner and type like '%TABLE%';
sqlstr varchar(200);
l_output long;

lv_tabname varchar2(30);
lv_objname varchar2(30);
lv_objtype varchar2(30);

begin

	for mw in ( select * from dba_mviews where owner=v_owner )
	loop
		sqlstr :='drop materialized view '||mw.owner||'.'||mw.mview_name;
		dbms_output.put_line(sqlstr);
		execute immediate sqlstr;
	end loop;

open tab_cursor; 
loop
	fetch tab_cursor into lv_tabname;
EXIT WHEN tab_cursor%NOTFOUND; 
sqlstr :='drop table "'||v_owner||'"."'||lv_tabname||'" cascade constraints';
dbms_output.put_line(sqlstr);
execute immediate sqlstr;
--dbms_output.put_line(l_output);
	
end loop;
close tab_cursor;

open recyclebin_cursor;
loop
	fetch recyclebin_cursor into lv_objname,lv_objtype;
EXIT WHEN recyclebin_cursor%NOTFOUND; 
sqlstr :='purge '||lv_objtype||' '||v_owner||'.'||lv_objname;
dbms_output.put_line(sqlstr);
execute immediate sqlstr;
--dbms_output.put_line(l_output);

end loop;
close recyclebin_cursor;

end;
/

