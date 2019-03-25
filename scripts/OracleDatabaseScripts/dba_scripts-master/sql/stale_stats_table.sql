set serveroutput on
undef schema tab
define schema=&1
define tab=&2

DECLARE
stats_tab dbms_stats.objecttab;
filter_tab dbms_stats.objecttab := dbms_stats.objecttab()  ;
v_schema varchar2(100) := '&schema';
v_tabname varchar2(100) := '&tab';
v_stale_count number;
v_is_stale number;
emsg varchar2(1000);

begin
	filter_tab.extend(1);
	filter_Tab(1).ownname := v_schema;
	filter_Tab(1).objname := v_tabname;
	--filter_Tab(1).partname := '%';
	--filter_Tab(1).objtype := 'TABLE PARTITION';
	dbms_Stats.gather_schema_stats( 
		  objlist => stats_tab
		, obj_filter_list  => filter_tab
		, ownname => v_schema
		--, ownname => null
		, options => 'LIST AUTO'
	);

	v_stale_count := stats_tab.COUNT;
	dbms_output.put_line('Stale count: '|| v_stale_count );


	if v_stale_count > 0 then
		for i in stats_tab.FIRST.. stats_tab.LAST
		loop
			dbms_output.put_line(stats_tab(i).ObjType ||': ' || stats_tab(i).ownname ||'.'|| stats_tab(i).ObjName ||':'|| stats_tab(i).partname|| ':'||
			stats_tab(i).subpartname);

			--pipe row (stats_tab(i));
		end loop;
	end if;

exception
when others then
	emsg :=SQLERRM;
	dbms_output.put_line('Error : '|| emsg );
end;
/
