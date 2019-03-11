set serveroutput on
accept owner char prompt 'Schema : '
accept tab char prompt 'Table name : '

declare
	v_incremental varchar2(100);
	v_owner varchar2(100) :='&owner';
	v_tabname varchar2(100) :='&tab';
begin
	
	for tab in ( select owner, table_name 
					from all_part_tables 
					where owner like upper(v_owner)
					and table_name like upper(v_tabname)
					order by owner, table_name
				)
	loop
		DBMS_OUTPUT.PUT_LINE (tab.owner||'.'||tab.table_name);
		DBMS_STATS.DELETE_TABLE_STATS(tab.owner,tab.table_name);
	end loop;
exception
when others then
	dbms_output.put_line('Error -> '||SQLERRM);
end;
/