define owner=&1

declare
v_owner varchar2(150) := '&owner';

begin

	for obj in (
			select DECODE(OBJECT_TYPE
				,'PACKAGE BODY','ALTER PACKAGE '||owner||'.'||object_name||' COMPILE BODY'
				,'TYPE BODY','ALTER TYPE '||owner||'.'||object_name||' COMPILE BODY'
				,'ALTER '||decode(owner,'PUBLIC','PUBLIC ','')||OBJECT_TYPE||' '||decode(owner,'PUBLIC','',owner||'.')||'"'||object_name||'"'||' COMPILE') sqltext
			from dba_objects 
			where status='INVALID' 
			and owner like upper(v_owner)
			order by 1
		)
	loop
		begin
			execute immediate obj.sqltext;
			dbms_output.put_line (obj.sqltext||' -> SUCCESS');
		exception
		when others then
			dbms_output.put_line (obj.sqltext||' -> ERROR! -> '||SQLERRM);
		end;
	end loop;
end;

/
