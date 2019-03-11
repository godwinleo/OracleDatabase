accept ownname char prompt 'Table owner	: '
accept tabname char prompt 'Table name	: '

declare
v_owner varchar2(100) :='&ownname';
v_tabname varchar2(200) :='&tabname';
v_highvalue varchar2(2000);
v_highvalue_dt date;
v_mindate date := '01-JAN-10';
v_partname varchar2(200);
v_partname_low varchar2(200);
v_sqlstr clob;
begin

	select partition_name , HIGH_VALUE 
	into v_partname, v_highvalue
	from dba_tab_partitions tp1
	where table_owner= upper(v_owner)
	and table_name = upper (v_tabname)
	and partition_position = ( select min(partition_position )
								from dba_tab_partitions tp2
								where tp1.table_owner=tp2.table_owner
								and tp1.table_name=tp2.table_name );
								
	execute immediate 'select '||v_highvalue||' from dual' into v_highvalue_dt;
								
	dbms_output.put_line(v_owner||'.'||v_tabname||' Partition : '||v_partname||' high value -> '||v_highvalue_dt);
	
	while v_highvalue_dt > v_mindate
	loop
		v_highvalue_dt := v_highvalue_dt - 1;
		v_partname_low := 'PARTITION_'||to_char(v_highvalue_dt-1,'YYYYMMDD');
		
		v_sqlstr := 'alter table '||v_owner||'.'||v_tabname||' split partition '||v_partname||' at (TO_DATE(''' ||
		to_char(v_highvalue_dt,'YYYY-MON-DD HH24:MI:SS')||''',''YYYY-MON-DD HH24:MI:SS'')) into ( PARTITION '||
		v_partname_low||', PARTITION '||v_partname||') update indexes';
		
		dbms_output.put_line(v_sqlstr);
		
		execute immediate v_sqlstr;
		v_partname := v_partname_low;
	end loop;
	
exception
when others then
	dbms_output.put_line ('Error -> '||SQLERRM);

end;							
/
							
							