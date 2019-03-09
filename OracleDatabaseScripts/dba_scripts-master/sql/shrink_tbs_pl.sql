define tbs=&1
set lines 185
set pages 40
set serveroutput on
col file_id for 99999
col end_block for 9,999,999,999,999
col end_bytes for 9,999,999,999,999,999
col aloc_bytes for 9,999,999,999,999,999
col used_bytes for 9,999,999,999,999,999

declare
v_tbs varchar(35) := upper('&tbs');
v_resize_bytes integer;
sqlstr varchar(1000);

begin

for  df in (
				select df.file_id, (nvl(end,0)+1)*tb.block_size resize_bytes
				from dba_tablespaces tb
				, dba_data_files df
				, (select tablespace_name,file_id,max(ext.block_id+ext.blocks) end
					from dba_extents ext
					group by tablespace_name,file_id
				) ext
				where tb.TABLESPACE_NAME like upper(v_tbs)
				and tb.tablespace_name=df.tablespace_name
				and df.tablespace_name=ext.tablespace_name (+)
				and df.file_id=ext.file_id (+)
				order by ext.file_id
			)

loop

	if df.resize_bytes < 10*1024*1024 -- 10mb
	then 
		v_resize_bytes := 1000*1024*1024;
	else 
		v_resize_bytes := df.resize_bytes;
	end if;
	
	sqlstr :='alter database datafile '||df.file_id||' resize '||v_resize_bytes;
	dbms_output.put_line(sqlstr||';');
	execute immediate sqlstr;
	--sqlstr :='alter database datafile '||df.file_id||' autoextend off ';
	--execute immediate sqlstr;
	
end loop;
end;
/

