set serveroutput on

accept schema char prompt 'Schema name : '

DECLARE
stats_tab dbms_stats.objecttab;
v_schema varchar2(100) := '&schema';
v_stale_count number;
emsg varchar2(1000);

begin
	dbms_Stats.gather_schema_stats( 
		  objlist => stats_tab
		, options => 'LIST STALE'
		, ownname => upper(v_schema)
	);

	v_stale_count := stats_tab.COUNT;
	dbms_output.put_line('Stale count: '|| v_stale_count );

	if v_stale_count > 0 then
		for i in stats_tab.FIRST.. stats_tab.LAST
		loop
			dbms_output.put_line(stats_tab(i).ObjType ||': ' || stats_tab(i).ownname ||'.'|| stats_tab(i).ObjName ||':'|| stats_tab(i).partname);
		end loop;
	end if;

exception
when others then
	emsg :=SQLERRM;
	dbms_output.put_line('Error : '|| emsg );
end;
/
