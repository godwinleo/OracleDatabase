accept owner char prompt 'Table Schema : '
accept table char prompt 'Table Name : '
accept compress_opt char prompt 'Compression : '

set lines 185
set pages 200
set serveroutput on
declare
	v_owner varchar2(100) :='&owner';
	v_table varchar2(100) :='&table';
	v_compress_opt varchar2(100) :='&compress_opt';
	sqlstr varchar2(1000);
begin

for tab in ( select owner, table_name name from dba_part_tables where owner like upper(v_owner) and table_name like upper (v_table))
loop
	--sqlstr := 'alter table '||tab.owner||'.'||tab.name||' modify default attributes storage ( initial '||v_extent||' next '||v_extent||' ) compress for oltp ';
	sqlstr := 'alter table '||tab.owner||'.'||tab.name||' modify default attributes '||v_compress_opt;
	begin
		execute immediate sqlstr;
		dbms_output.put_line(sqlstr);
	exception
	when others then
			dbms_output.put_line('pincho table '||tab.owner||'.'||tab.name||' -> '||SQLERRM);
	end;
	
		sqlstr := 'alter table '||tab.owner||'.'||tab.name||' '||v_compress_opt;
	begin
		execute immediate sqlstr;
		dbms_output.put_line(sqlstr);
	exception
	when others then
			dbms_output.put_line('pincho table '||tab.owner||'.'||tab.name||' -> '||SQLERRM);
	end;

for part in (
select part.table_name,part.partition_name,part.table_owner,part.tablespace_name,subpartition_count subps
,nvl(seg.extents,0) extents
--,part.last_analyzed,nvl(seg.bytes/1024/1024,0) MB, NUM_ROWS
, compression
,compress_for
,seg.initial_ext/1024
,seg.next_ext/1024
from dba_tab_partitions part
, ( select s.owner,s.segment_name, nvl(sp.partition_name,s.partition_name) partition_name, sum(s.bytes) bytes,sum(s.extents) extents, max(s.initial_extent) initial_ext, max(s.NEXT_EXTENT) next_ext
	from dba_segments s, dba_tab_subpartitions sp
	where s.segment_type in ('TABLE PARTITION','TABLE SUBPARTITION')
	and s.owner = sp.table_owner (+)
	and s.segment_name = sp.table_name (+)
	and s.partition_name = sp.subpartition_name (+)
	group by s.owner,s.segment_name,nvl(sp.partition_name,s.partition_name)
) seg
where table_name like upper(tab.name)
and table_owner like upper(tab.owner)
and part.partition_name=seg.partition_name (+)
and part.table_name=seg.segment_name (+)
and part.table_owner=seg.owner (+)
order by table_name,table_owner,partition_position
)
loop
	if part.subps > 0
	then
		sqlstr := 'alter table '||tab.owner||'.'||tab.name||' modify default attributes for partition '||part.partition_name||' '||v_compress_opt;

		begin
			execute immediate sqlstr;
			dbms_output.put_line(sqlstr);
		exception
		when others then
				dbms_output.put_line('pincho partition '||tab.owner||'.'||tab.name||':'||part.partition_name||' -> '||SQLERRM);
		end;
		
		for subpart in (  select subpartition_name from dba_tab_subpartitions 
							where TABLE_OWNER=tab.owner and TABLE_NAME=tab.name and PARTITION_NAME=part.PARTITION_NAME
							order by PARTITION_NAME,SUBPARTITION_POSITION)
		loop
			begin 
				sqlstr := 'alter table '||tab.owner||'.'||tab.name||' move subpartition '||subpart.subpartition_name||' '||v_compress_opt;
				execute immediate sqlstr;
				dbms_output.put_line('ok -> to exec '||sqlstr);
			exception 
			when others then
				dbms_output.put_line('pincho sub partition '||tab.owner||'.'||tab.name||':'||subpart.subpartition_name||' -> '||SQLERRM);
			end;
		end loop;
	else
		begin 
			sqlstr := 'alter table '||tab.owner||'.'||tab.name||' move partition '||part.partition_name||' '||v_compress_opt;
			execute immediate sqlstr;
			dbms_output.put_line('ok -> to exec '||sqlstr);
		exception 
		when others then
			dbms_output.put_line('pincho partition '||sqlstr||' ->'||SQLERRM);
		end;
	end if;
end loop;
end loop;

exception
when others then
	dbms_output.put_line('pincho general '||SQLERRM);
end ;
/
