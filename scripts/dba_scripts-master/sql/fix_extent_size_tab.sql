accept owner char prompt 'Table Schema : '
accept table char prompt 'Table Name : '
accept extent_size char prompt 'Extent size : '
set lines 185
set pages 200
set serveroutput on
declare
	v_owner varchar2(100) :='&owner';
	v_table varchar2(100) :='&table';
	v_extent varchar2(100) :='&extent_size';
	sqlstr varchar2(1000);
begin

sqlstr := 'alter table '||v_owner||'.'||v_table||' modify default attributes storage ( initial '||v_extent||' next '||v_extent||' ) compress for oltp ';
execute immediate sqlstr;
dbms_output.put_line(sqlstr);

for part in (
select part.partition_name,part.table_owner,part.tablespace_name,subpartition_count subps,nvl(seg.extents,0) extents,part.last_analyzed,nvl(seg.bytes/1024/1024,0) MB, NUM_ROWS
, CHAIN_CNT,AVG_ROW_LEN,GLOBAL_STATS,USER_STATS, compression
--,compress_for
,high_value
from dba_tab_partitions part
, ( select s.owner,s.segment_name, p.partition_name, sum(s.bytes) bytes,sum(s.extents) extents
	from dba_segments s, dba_tab_subpartitions p
	where s.segment_type = 'TABLE SUBPARTITION'
	and s.segment_name = p.table_name
	and s.partition_name = p.subpartition_name
	and s.owner = p.table_owner
	group by s.owner,s.segment_name,p.partition_name
	union all
	select s.owner,s.segment_name, s.partition_name, sum(s.bytes) bytes,sum(s.extents) extents
	from dba_segments s
	where s.segment_type = 'TABLE PARTITION'
	group by s.owner,s.segment_name,s.partition_name
) seg
where table_name=upper(v_table)
and table_owner like upper(v_owner)
and part.partition_name=seg.partition_name (+)
and part.table_name=seg.segment_name (+)
and part.table_owner=seg.owner (+)
--and seg.extents > 0
--and part.tablespace_name=seg.tablespace_name
order by table_name,table_owner,partition_position
)
loop
	if part.subps > 0
	then
		--dbms_output.put_line ('hola 2');
		sqlstr := 'alter table '||v_owner||'.'||v_table||' modify default attributes for partition '||part.partition_name||' storage (initial '||v_extent||' next '||v_extent||' ) compress for oltp ';
		
		execute immediate sqlstr;
		dbms_output.put_line(sqlstr);
		
		dbms_output.put_line ('hola 3');
		for subpart in (  select subpartition_name from dba_tab_subpartitions where TABLE_OWNER=v_owner and TABLE_NAME=v_table order by PARTITION_NAME,SUBPARTITION_POSITION)
		loop
			begin 
				--sqlstr := 'alter table '||v_owner||'.'||v_table||' move subpartition '||subpart.subpartition_name||' storage (initial '||v_extent||' next '||v_extent||' ) compress for oltp';
				sqlstr := 'alter table '||v_owner||'.'||v_table||' move subpartition '||subpart.subpartition_name||' compress for oltp';
				execute immediate sqlstr;
				dbms_output.put_line('ok -> to exec '||sqlstr);
			exception 
			when others then
				dbms_output.put_line('pincho sub partition '||v_owner||'.'||v_table||':'||subpart.subpartition_name||' -> '||SQLERRM);
			end;
		end loop;
	else
		begin 
			sqlstr := 'alter table '||v_owner||'.'||v_table||' move partition '||part.partition_name||' storage (initial '||v_extent||' next '||v_extent||' ) compress for oltp';
			execute immediate sqlstr;
		exception 
		when others then
			dbms_output.put_line('pincho partition '||SQLERRM);
		end;
	end if;
end loop;

exception
when others then
	dbms_output.put_line('pincho general '||SQLERRM);
end ;
/
