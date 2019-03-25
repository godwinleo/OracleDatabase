declare
sqlstr varchar2(1000);
begin

	for idx in (
select owner||'.'||index_name idx_name, 1 partition_position, null partition_name,tablespace_name
from dba_indexes
where status ='UNUSABLE'
union all
select index_owner||'.'||index_name idx_name, partition_position, partition_name,tablespace_name
from dba_ind_partitions
where status ='UNUSABLE'
order by idx_name, partition_position
)
	loop
		if idx.partition_name is null 
		then
			sqlstr:= 'alter index '||idx.idx_name||' rebuild online';
		else
			sqlstr:= 'alter index '||idx.idx_name||' rebuild partition '||idx.partition_name;
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

