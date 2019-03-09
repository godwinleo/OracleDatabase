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

cursor mview_cursor
is
select mview_name from dba_mviews
where owner=v_owner;

cursor tab_cursor
is
select tab.table_name from dba_tables tab
where tab.owner=v_owner
/*
and not exists ( select 1 from dba_constraints cons
	where tab.table_name=cons.table_name
and tab.owner=cons.owner
and cons.constraint_type='R')
*/
;

cursor recyclebin_cursor
is
select original_name,type from dba_recyclebin
where owner=v_owner and type like '%TABLE%';

cursor obj_cursor
is
select object_name,object_type from dba_objects
where owner=v_owner and object_type!='DATABASE LINK';
--where owner=v_owner and object_type not in  ('DATABASE LINK','SEQUENCE');

cursor dblink_cursor
is
select object_name,object_type from dba_objects
where owner=v_owner and object_type='DATABASE LINK';

sqlstr varchar2(2000);
l_output long;

lv_tabname varchar2(50);
lv_mviewname varchar2(50);
lv_objname varchar2(50);
lv_objtype varchar2(50);

myint integer;
uid number;

begin

open mview_cursor; 
loop
	fetch mview_cursor into lv_mviewname;
EXIT WHEN mview_cursor%NOTFOUND; 
	sqlstr :='drop materialized view '||v_owner||'.'||lv_mviewname;
	dbms_output.put_line(sqlstr);
	execute immediate sqlstr;
end loop;
close mview_cursor;

open tab_cursor; 
loop
	fetch tab_cursor into lv_tabname;
EXIT WHEN tab_cursor%NOTFOUND; 
	begin
sqlstr :='drop table "'||v_owner||'"."'||lv_tabname||'" cascade constraints';
dbms_output.put_line(sqlstr);
execute immediate sqlstr;
exception
	when others then
		dbms_output.put_line('Error :S');
	end;
--dbms_output.put_line(l_output);
	
end loop;
close tab_cursor;

/*
open dblink_cursor; 
loop
	fetch dblink_cursor into lv_tabname,lv_objtype;
	EXIT WHEN dblink_cursor%NOTFOUND; 
begin
	myint:=sys.dbms_sys_sql.open_cursor();
	select user_id into uid from all_users where username=v_owner;
	sqlstr :='drop '||lv_objtype||' "'||lv_tabname||'"';
	dbms_output.put_line(sqlstr);
	sys.dbms_sys_sql.parse_as_user(myint,sqlstr,dbms_sql.native,UID);
	sys.dbms_sys_sql.close_cursor(myint);
exception
	when others then
	dbms_output.put_line('Error runnning as user: '||SQLERRM||' - : '||lv_objtype||' - '||lv_tabname);
end;
	
end loop;
close dblink_cursor;
*/

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

