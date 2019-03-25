accept ownname char prompt 'Table owner	: '
accept tabname char prompt 'Table name	: '

declare
v_owner varchar2(100) :='&ownname';
v_tabname varchar2(200) :='&tabname';
v_highvalue varchar2(2000);
v_highvalue_dt date;
v_mindate date := '31-DEC-09';
v_partname varchar2(200);
v_partname_low varchar2(200);
v_interval varchar2(100) := 'DAILY';
v_dateformat varchar2(100);
v_data_type varchar2(200);
v_sqlstr clob;
begin

	select tc.data_type
	into v_data_type
	from all_tab_columns tc, all_part_key_columns pkc
	where pkc.owner = upper(v_owner)
	and pkc.name = upper(v_tabname)
	and tc.table_name = pkc.name
	and tc.owner = pkc.owner
	and tc.column_name = pkc.column_name;
	
	
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
		case v_interval
		when 'MONTHLY' then
		begin
			v_dateformat   := 'YYYYMM';
			v_highvalue_dt := ADD_MONTHS (trunc(v_highvalue_dt,'MONTH'), - 1);
			v_partname_low := 'PARTITION_'||to_char(v_highvalue_dt-1,v_dateformat);
		end;
		when 'DAILY' then
		begin
			v_dateformat   :='YYYYMMDD';
			v_highvalue_dt := v_highvalue_dt - 1;
			v_partname_low := 'PARTITION_'||to_char(v_highvalue_dt-1,v_dateformat);
		end;
		else
			dbms_output.put_line ('error ! : invalid interval for partitioning ');
			exit;
		end case;
		
		if v_data_type = 'NUMBER' then
			v_sqlstr := 'alter table '||v_owner||'.'||v_tabname||' split partition '||v_partname||' at (' ||
			to_char(v_highvalue_dt,'YYYY-MON-DD HH24:MI:SS')||''',''YYYY-MON-DD HH24:MI:SS'') into ( PARTITION '||
			v_partname_low||', PARTITION '||v_partname||') update indexes parallel 4';
		else
			v_sqlstr := 'alter table '||v_owner||'.'||v_tabname||' split partition '||v_partname||' at (TO_DATE(''' ||
			to_char(v_highvalue_dt,'YYYY-MON-DD HH24:MI:SS')||''',''YYYY-MON-DD HH24:MI:SS'')) into ( PARTITION '||
			v_partname_low||', PARTITION '||v_partname||') update indexes parallel 4';
		end if;
		
		dbms_output.put_line(v_sqlstr);
		
		execute immediate v_sqlstr;
		v_partname := v_partname_low;
	end loop;
	
exception
when others then
	dbms_output.put_line ('Error -> '||SQLERRM);

end;							
/
							
							