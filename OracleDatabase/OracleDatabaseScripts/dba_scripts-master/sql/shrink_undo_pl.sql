set lines 185
set pages 40
set serveroutput on

declare
v_rollname varchar2(200);
sqlstr varchar2(1000);

cursor undo_cursor
is
 SELECT segment_name
 FROM dba_undo_extents 
 group by segment_name
 order by sum(bytes)
;

begin

open undo_cursor;
loop
	fetch undo_cursor into v_rollname;
EXIT WHEN undo_cursor%NOTFOUND; 
sqlstr :='alter rollback segment "'||v_rollname||'" shrink';
dbms_output.put_line(sqlstr||';');
execute immediate sqlstr;

end loop;
close undo_cursor;
end;
/

