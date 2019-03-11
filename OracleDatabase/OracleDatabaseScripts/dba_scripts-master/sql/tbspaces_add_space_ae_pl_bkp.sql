set lines 185
set pages 200
set serveroutput on
accept free_space_margin char prompt 'Free Space Desired : '
accept max_df_size char prompt 'Max Datafile Size Desired : '

declare
v_free_space_margin number := nvl('&free_space_margin',25);
v_add_mb number ;
v_add_mb_remaining number ;
max_df_size_mb number := nvl('&max_df_size',40000);

begin

for tbs in (
select /* RULE */ tb.tablespace_name
,round((aloc.max_size-USED_BYTES)/aloc.max_size*100,2) FREE_AE_pct
,round((aloc_bytes-USED_BYTES)/aloc_bytes*100,2) FREE_pct
,round(ALOC_BYTES/1024/1024,2) aloc_mb
--,round((nvl(ALOC_BYTES/1024/1024,0)-nvl(USED_BYTES/1024/1024,0),2) free_mb 
,round(nvl(USED_BYTES/1024/1024,0),2) used_mb
,round(nvl(aloc.max_size/1024/1024,0),2) max_MB
,round(nvl((aloc.max_size-ALOC_BYTES)/1024/1024,0),2) max_MB_diff
,round(USED_BYTES/((100-v_free_space_margin)/100)/1024/1024,2) NEW_ALOC_MB
,ceil(USED_BYTES/((100-v_free_space_margin)/100)/1024/1024/100)*100 NEW_ALOC_round
,ceil(USED_BYTES/((100-v_free_space_margin)/100)/1024/1024/100)*100 - round(nvl(aloc.max_size/1024/1024,0),2) INC_ALOC_round
,trunc((ceil(USED_BYTES/((100-v_free_space_margin)/100)/1024/1024/100)*100 - round(nvl(aloc.max_size/1024/1024,0),2))/cant_dfs,0) INC_x_file
--,round(ALOC_MB-(USED_MB/(80/100),2) INC_MB
,cant_dfs
,tb.bigfile
from
	dba_tablespaces tb
	, (
		select tablespace_name,sum(bytes) ALOC_BYTES,sum(max_bytes) MAX_size, count(1) cant_dfs
		from
		( select tablespace_name,bytes,decode(autoextensible,'YES',maxbytes,bytes) max_bytes
                from dba_data_files) df
		group by tablespace_name
	) aloc
	, (
		select tablespace_name,sum(bytes) USED_BYTES , max(next_extent) next_ext
		from dba_segments
		group by tablespace_name
	) used
where tb.contents='PERMANENT'
and tb.status='ONLINE'
and tb.tablespace_name=aloc.tablespace_name
and tb.tablespace_name=used.tablespace_name (+)
and round((aloc.max_size-USED_BYTES)/aloc.max_size*100,2) < v_free_space_margin
order by 2 desc,aloc_mb ,used_mb
)
loop
	dbms_output.put_line ('-- Tablespace '||rpad(tbs.tablespace_name,25)||' Current AE: '||rpad(tbs.FREE_AE_pct,4)||
	'% Needs '||rpad (tbs.INC_ALOC_round,5)||' MB more to get to '||rpad(tbs.NEW_ALOC_round,8)||' MB.' );
	dbms_output.put_line ('-- Tablespace has '||tbs.cant_dfs||' datafiles. Per file :'||tbs.INC_x_file||' Mb');
	
	
	v_add_mb_remaining := tbs.INC_ALOC_round;
--	v_add_x_file := tbs.INC_ALOC_round
	
	for dfs in (
	 select df.file_id
	 ,df.file_name ,df.bytes/1024/1024 MB
	 ,df.maxbytes/1024/1024 MAX_MB
	 ,df.status
	from
		dba_data_files df
		, v$datafile df2
		where df.tablespace_name=tbs.tablespace_name
		and df.file_id=df2.file#
		order by df2.creation_time
	)
	loop
		if v_add_mb_remaining < tbs.INC_x_file then
			v_add_mb := ceil((dfs.max_mb+v_add_mb_remaining)/100)*100;
		else
			v_add_mb := ceil((dfs.max_mb+tbs.INC_x_file)/100)*100;
		end if;
		
		if v_add_mb > max_df_size_mb and tbs.bigfile='NO'
		then
			v_add_mb := max_df_size_mb;
		end if;
		
		if v_add_mb <> dfs.max_mb
		then
			dbms_output.put_line ('-- DF id '||dfs.file_id||' maxsize '||dfs.max_mb||' MB may go to '||v_add_mb||' MB . ');	
			dbms_output.put_line ('alter database datafile '||dfs.file_id||' autoextend on  maxsize '||v_add_mb||'M; ');
		end if;
		
		v_add_mb_remaining := v_add_mb_remaining - ( v_add_mb - dfs.max_mb );
	end loop;
	
	while v_add_mb_remaining > 0
	loop
		
		if v_add_mb_remaining > max_df_size_mb then
			v_add_mb := ceil((max_df_size_mb)/100)*100;
		else
			v_add_mb := ceil((v_add_mb_remaining)/100)*100;
		end if;
	
		dbms_output.put_line ('alter tablespace '||rpad(tbs.tablespace_name,25)||' add datafile size 200M autoextend on next 200M maxsize '
		||v_add_mb||'M;');
		v_add_mb_remaining := v_add_mb_remaining - v_add_mb ;
	end loop;

end loop;

exception
when others then 
	dbms_output.put_line ('Error -> :'||SQLERRM);
end;
/
