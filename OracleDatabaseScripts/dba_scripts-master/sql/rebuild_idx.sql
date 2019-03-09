accept owner char prompt 'Index Owner : '
accept index char prompt 'Index Name : '
accept extent_size char prompt 'Extent size : '

declare
sqlstr varchar2(1000);
v_owner varchar2(100) := '&owner';
v_index varchar2(100) := '&index';
v_extent varchar2(100) :='&extent_size';

begin

	for idx in (
	select * 
	from  (
			select owner index_owner, index_name idx_name, 1 partition_position, null partition_name,tablespace_name
			from dba_indexes
			--where status ='UNUSABLE'
			union all
			select index_owner, index_name idx_name, partition_position, partition_name,tablespace_name
			from dba_ind_partitions
			--where status ='UNUSABLE'
		)
	where index_owner like upper(v_owner) 
	and idx_name like upper(v_index)
	order by index_owner, idx_name, partition_position
)
	loop
		sqlstr := 'alter index '||idx.index_owner||'.'||idx.idx_name||' modify default attributes storage ( initial '||v_extent||' next '||v_extent||' ) ';
		execute immediate sqlstr;
		dbms_output.put_line(sqlstr);
		
		if idx.partition_name is null 
		then
			sqlstr:= 'alter index '||idx.index_owner||'.'||idx.idx_name||' rebuild online storage (initial '||v_extent||' next '||v_extent||' )';
		else
			sqlstr:= 'alter index '||idx.index_owner||'.'||idx.idx_name||' rebuild partition '||idx.partition_name||' storage (initial '||v_extent||' next '||v_extent||' ) ';
		end if;

		begin
			execute immediate sqlstr;
			--dbms_output.put_line(sqlstr);
			dbms_output.put_line('Success. cmd => '||sqlstr );
		exception
		when others then
			dbms_output.put_line(' Error cmd => '||sqlstr||' =>'||SQLERRM);
		end;

	end loop;

exception
when others then 
	dbms_output.put_line(' Error '||SQLERRM);
end;
/

