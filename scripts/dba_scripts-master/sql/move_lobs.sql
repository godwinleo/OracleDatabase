accept old_tablespace char prompt 'Old tablespace : ' 
accept new_tablespace char prompt 'New tablespace : ' 
accept table_names char prompt 'Table names : ' 

declare
v_tbs_old varchar2(30):=upper('&old_tablespace');
v_tbs_new varchar2(30):=upper('&new_tablespace');
v_tabnames varchar2(300) := upper('&table_names');
begin
	for lob in (			
				select 
				* from 
				(  select owner table_owner, table_name, SEGMENT_NAME lob_name, column_name, tablespace_name, PARTITIONED
					from dba_lobs
					union all
					select table_owner, table_name, lob_name, column_name, tablespace_name, 'YES' PARTITIONED
					from dba_lob_partitions
					group by table_owner, table_name, lob_name, column_name, tablespace_name
				)
				where tablespace_name = v_tbs_old
				--and table_owner=tab.table_owner 
				and table_name like v_tabnames
				)
	loop
		if lob.partitioned = 'NO'
		then
			begin
--alter table TABLA_LOB move lob (COLUMN_NAME) store as (tablespace TS_LOB);			
				execute immediate 'alter table '||lob.table_owner||'.'||lob.table_name||' move lob ('||lob.COLUMN_NAME||') store as (tablespace '||v_tbs_new||')';
				dbms_output.put_line (' Moved lob '||lob.table_owner||'.'||lob.table_name||' to tablespace '||v_tbs_new);
			exception
			when others then
				dbms_output.put_line (' changos 2 -> '||lob.table_owner||'.'||lob.table_name||' -> '||SQLERRM);
			end;
		else
		begin
			--execute immediate 'alter index '||ind.index_owner||'.'||ind.index_name||' modify default attributes tablespace '||v_tbs_new;
			dbms_output.put_line (' changed prop -> '||lob.table_owner||'.'||lob.table_name);
		exception
		when others then
				dbms_output.put_line (' changos 2.3 -> '||lob.table_owner||'.'||lob.table_name||' -> '||SQLERRM);
		end;
		for part in (select partition_name from dba_lob_partitions where table_owner=lob.table_owner and table_name=lob.table_name )
		loop
			begin 
				execute immediate 'alter table '||lob.table_owner||'.'||lob.table_name||' move partition '||part.partition_name ||' lob ('||lob.COLUMN_NAME||') store as (tablespace '||v_tbs_new||')';
				dbms_output.put_line (' Moved lob partition '||part.partition_name||' from '||lob.table_owner||'.'||lob.table_name||' to tablespace '||v_tbs_new);
			exception
			when others then
				dbms_output.put_line (' changos 2.5 -> '||lob.table_owner||'.'||lob.table_name||' part '||part.partition_name||' -> '||SQLERRM);
			end;
		end loop;
		end if;
	end loop;
end;
/