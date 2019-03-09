set serveroutput on
set long 1000000000

declare
hints clob;
v_row clob;
v_sqlid varchar2(2000):='&sqlid';
v_plan varchar2(2000):=&plan;
emesg varchar2(2000);
output clob;

cursor output_row_c is
select '                          '||plan_table_output||'''' result from table(dbms_xplan.display_awr(v_sqlid,v_plan,null,'OUTLINE'))
;

begin
open output_row_c;
loop
	fetch output_row_c into v_row;
	exit when output_row_c%NOTFOUND;
	begin
		--hints:=hints||v_row||'hola';
		hints:=hints||v_row||',';
		hints:=hints||chr(13);
	exception
	when others then
		emesg := SQLERRM;
		dbms_output.put_line('ERROR: '||' : '||emesg);
	end;
end loop;
	--dbms_output.put_line(hints);
	select REGEXP_REPLACE(hints,'^.*BEGIN_OUTLINE_DATA(.*)END_OUTLINE_DATA.*$','\1') 
	--select REGEXP_instr(hints,'^.*BEGIN_OUTLINE_DATA.*END_OUTLINE_DATA.*$') 
	--select REGEXP_instr(hints,'BEGIN_OUTLINE_DATA')
	into output
	from dual;
	--output:=output||'END_OUTLINE_DATA';
	dbms_output.put_line(output);
end;
/


