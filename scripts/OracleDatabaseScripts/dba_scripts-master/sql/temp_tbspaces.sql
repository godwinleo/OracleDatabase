set lines 185
set pages 200
col tablespace_name for a32
col blk_size for a5
col "%_FREE" for 99.99
col aloc_mb for 9,999,999.99
col free_mb for 9,999,999.99
col used_mb for 9,999,999.99
col max_mb for 9,999,999.99
col next_ext for 999,999.99
col MAX_MB_DIFF for 9,999,999.99
col NEW_ALOC_MB for 9,999,999.99
break on report
compute SUM of USED_MB on report
compute SUM of ALOC_MB on report
select /* RULE */ tb.tablespace_name
,round((aloc.max_size-(TOTAL_BLOCKS*block_size))/aloc.max_size*100,2) "%_FREE_AE"
,round((aloc_bytes-(TOTAL_BLOCKS*block_size))/aloc_bytes*100,2) "%_FREE"
,round(ALOC_BYTES/1024/1024,2) aloc_mb
--,round((nvl(ALOC_BYTES/1024/1024,0)-nvl(USED_BYTES/1024/1024,0),2) free_mb 
,round(nvl(TOTAL_BLOCKS*BLOCK_SIZE/1024/1024,0),2) used_mb
,block_size/1024||'K' blk_size
,extent_management
,segment_space_management
,round(nvl(aloc.max_size/1024/1024,0),2) max_MB
,round(nvl((aloc.max_size-ALOC_BYTES)/1024/1024,0),2) max_MB_diff
,round(TOTAL_BLOCKS*BLOCK_SIZE/(80/100)/1024/1024,2) NEW_ALOC_MB
--,round(ALOC_MB-(USED_MB/(80/100),2) INC_MB
from
	dba_tablespaces tb
	, (
		select tablespace_name,sum(bytes) ALOC_BYTES,sum(max_bytes) MAX_size
		from
		( select tablespace_name,bytes,decode(autoextensible,'YES',maxbytes,bytes) max_bytes
                from dba_temp_files) df
		group by tablespace_name
	) aloc
	, (
		select tablespace, sum(blocks) TOTAL_BLOCKS 
		from v$sort_usage
		group by tablespace
	) used
where tb.contents='TEMPORARY'
and tb.status='ONLINE'
and tb.tablespace_name=aloc.tablespace_name
and tb.tablespace_name=used.tablespace (+)
--and round((aloc_bytes-USED_BYTES)/aloc_bytes*100,2) < 20
order by 2 desc,aloc_mb ,total_blocks
/
