set serveroutput on
accept owner char prompt 'Schema : '
accept tab char prompt 'Table name : '
accept execyn char prompt 'Execute [y|n] : '

declare
	v_incremental varchar2(100);
	v_owner varchar2(100) :='&owner';
	v_tabname varchar2(100) :='&tab';
	v_exec varchar2(100) :='&execyn';
begin
	
	for tab in ( select owner, table_name 
					from all_tables 
					where owner like upper(v_owner)
					and table_name like upper(v_tabname)
					order by owner, table_name
				)
	loop
		select DBMS_STATS.GET_PREFS('INCREMENTAL',tab.owner,tab.table_name)
		into v_incremental 
		from dual;
		
		if v_incremental != 'FALSE'
		then
			DBMS_OUTPUT.PUT_LINE (tab.owner||'.'||tab.table_name);
			if v_exec ='y'
			then
				DBMS_STATS.SET_TABLE_PREFS(tab.owner,tab.table_name,'INCREMENTAL','FALSE');
				DBMS_STATS.DELETE_TABLE_STATS(tab.owner,tab.table_name);
				DBMS_STATS.GATHER_TABLE_STATS(tab.owner,tab.table_name);
			end if;
		end if;
	end loop;
end;
/