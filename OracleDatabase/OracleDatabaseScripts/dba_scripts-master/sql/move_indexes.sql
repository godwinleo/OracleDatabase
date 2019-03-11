accept old_tablespace char prompt 'Old tablespace : ' 
accept new_tablespace char prompt 'New tablespace : ' 
accept table_names char prompt 'Table names : ' 
declare
v_tbs_old varchar2(30):=upper('&old_tablespace');
v_tbs_new varchar2(30):=upper('&new_tablespace');
v_tabnames varchar2(300) := upper('&table_names');
begin
	for ind in (			
				select 
				* from 
				 (  select i.index_name, i.owner index_owner, i.partitioned, tablespace_name, i.table_name, i.table_owner
					from dba_indexes i
					union all
					select i.index_name, ip.index_owner index_owner, 'YES' partitioned, ip.tablespace_name, i.table_name, i.table_owner
					from dba_ind_partitions ip, dba_indexes i
					where i.index_name=ip.index_name
					and i.owner=ip.index_owner
					group by i.index_name,ip.index_owner,ip.tablespace_name,i.table_owner,i.table_name
				)
				where tablespace_name = v_tbs_old
				--and table_owner=tab.table_owner 
				and table_name like v_tabnames
				)
	loop
		if ind.partitioned = 'NO'
		then
			begin 
				execute immediate 'alter index '||ind.index_owner||'.'||ind.index_name||' rebuild online tablespace '||v_tbs_new;
				dbms_output.put_line (' Rebuild index '||ind.index_owner||'.'||ind.index_name||' in tablespace '||v_tbs_new);
			exception
			when others then
				dbms_output.put_line (' changos 2 -> '||ind.index_owner||'.'||ind.index_name||' -> '||SQLERRM);
			end;
		else
		begin
			execute immediate 'alter index '||ind.index_owner||'.'||ind.index_name||' modify default attributes tablespace '||v_tbs_new;
			dbms_output.put_line (' changed prop -> '||ind.index_owner||'.'||ind.index_name);
		exception
		when others then
				dbms_output.put_line (' changos 2.3 -> '||ind.index_owner||'.'||ind.index_name||' -> '||SQLERRM);
		end;
		for part in (select partition_name from dba_ind_partitions where index_name=ind.index_name and index_owner=ind.index_owner )
		loop
			begin 
				execute immediate 'alter index '||ind.index_owner||'.'||ind.index_name||' rebuild partition '||part.partition_name||' tablespace '||v_tbs_new;	
				dbms_output.put_line (' Moved partition '||part.partition_name||' from '||ind.index_owner||'.'||ind.index_name||' to tablespace '||v_tbs_new);
			exception
			when others then
				dbms_output.put_line (' changos 2.5 -> '||ind.index_owner||'.'||ind.index_name||' -> '||SQLERRM);
			end;
		end loop;
		end if;
	end loop;
end;
/