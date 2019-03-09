set echo off
set feed off
col definition for a200
SET LONG 1000000000
set trims on
set serveroutput on
set define on
accept old_tablespace char prompt 'Old tablespace : ' 
accept new_tablespace char prompt 'New tablespace : ' 
accept table_names char prompt 'Table names : ' 


declare 
v_tbs_old varchar2(30):=upper('&old_tablespace');
v_tbs_new varchar2(30):=upper('&new_tablespace');
v_tabnames varchar2(300) := upper('&table_names');
sqlstr clob ;

begin
	dbms_output.put_line ('Starting... ');
for tab in ( 
			select *
			from 
			(select table_name, owner table_owner, PARTITIONED, tablespace_name 
			from dba_tables 
			union all
			--select table_name, owner table_owner, 'YES' PARTITIONED, DEF_TABLESPACE_NAME tablespace_name
			--from dba_part_tables
			select table_name, table_owner table_owner, 'YES' PARTITIONED, tablespace_name
			from dba_tab_partitions
			group by table_name,table_owner,tablespace_name
			) tabs
			where tablespace_name = v_tbs_old
			and table_name like v_tabnames
)
loop
	if tab.partitioned = 'NO'
	then
		begin 
			sqlstr:= 'alter table '||tab.table_owner||'.'||tab.table_name||' move tablespace '||v_tbs_new||' compress for oltp ';
			execute immediate sqlstr;	
			dbms_output.put_line (' Moved table '||tab.table_owner||'.'||tab.table_name||' to tablespace '||v_tbs_new);
		exception
		when others then
			dbms_output.put_line (' changos 1 -> '||sqlstr||' : '||SQLERRM);
		end;
	else
		execute immediate 'alter table '||tab.table_owner||'.'||tab.table_name||' modify default attributes tablespace '||v_tbs_new||' compress for oltp ';
		for part in (select partition_name from dba_tab_partitions where table_name=tab.table_name and table_owner=tab.table_owner )
		loop
			begin 
				sqlstr:= 'alter table '||tab.table_owner||'.'||tab.table_name||' move partition '||part.partition_name||' tablespace '||v_tbs_new||' compress for oltp ';
				execute immediate sqlstr;
				dbms_output.put_line (' Moved partition '||part.partition_name||' from '||tab.table_owner||'.'||tab.table_name||' to tablespace '||v_tbs_new);
			exception
			when others then
				dbms_output.put_line (' changos 1.5 -> '||sqlstr||' : '||SQLERRM);
			end;
		end loop;
	end if;
	
	for ind in (select 
				* from 
				 ( select i.index_name, i.owner index_owner, i.partitioned, nvl(tablespace_name,def_tablespace_name) tablespace_name, i.table_name, i.table_owner
					from dba_indexes i, dba_part_indexes pi	
					where  i.owner=pi.owner (+)
					and i.index_name = pi.index_name (+)
				)
				where tablespace_name = v_tbs_old
				and table_owner=tab.table_owner 
				and table_name=tab.table_name
				and table_name like v_tabnames 
				)
	loop
		if ind.partitioned = 'NO'
		then
			begin 
				sqlstr := 'alter index '||ind.index_owner||'.'||ind.index_name||' rebuild online tablespace '||v_tbs_new;
				execute immediate sqlstr;
				dbms_output.put_line (' Rebuild index '||ind.index_owner||'.'||ind.index_name||' in tablespace '||v_tbs_new);
			exception
			when others then
				dbms_output.put_line (' changos 2 -> '||sqlstr||' : '||SQLERRM);
			end;
		else
		sqlstr := 'alter index '||ind.index_owner||'.'||ind.index_name||' modify default attributes tablespace '||v_tbs_new;
		execute immediate sqlstr;
		dbms_output.put_line('Success : '||sqlstr);
		for part in (select partition_name from dba_ind_partitions where index_name=ind.index_name and index_owner=ind.index_owner )
		loop
			begin 
				sqlstr := 'alter index '||ind.index_owner||'.'||ind.index_name||' rebuild online partition '||part.partition_name||' tablespace '||v_tbs_new;	
				execute immediate sqlstr;
				dbms_output.put_line (' Moved partition '||part.partition_name||' from '||ind.index_owner||'.'||ind.index_name||' to tablespace '||v_tbs_new);
			exception
			when others then
				dbms_output.put_line (' changos 2.5 -> '||sqlstr||' : '||SQLERRM);
			end;
		end loop;
		end if;
	
	end loop;
end loop;
	dbms_output.put_line ('Finished. ');
exception
when others then
	dbms_output.put_line (' changos 3 -> '||SQLERRM);
end;
/

