accept username char prompt ' User : '

declare
v_user varchar2(100) := upper('&username');

begin
for sess in (select sid,serial#,OSUSER,PROGRAM,MACHINE,module from v$session where username like v_user )
loop
	begin 
		execute immediate 'alter system kill session '''||sess.sid||','||sess.serial#||'''' ;
		--dbms_output.put_line( 'alter system kill session '''||sess.sid||','||sess.serial#||'''') ;
		dbms_output.put_line ('killed '''||sess.sid||','||sess.serial#||' from : '||sess.osuser||'@'||sess.machine ||
		' program: '||sess.program);
	exception
	when others then
		dbms_output.put_line ('tried to kill '''||sess.sid||','||sess.serial#||' from : '||sess.osuser||'@'||sess.machine ||
		' program: '||sess.program||' Error -> '|| SQLERRM);
	end;
end loop;
exception
when others then
	dbms_output.put_line ('Error -> '||SQLERRM);
end;
/