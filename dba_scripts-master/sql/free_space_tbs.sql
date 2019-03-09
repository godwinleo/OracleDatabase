define tbs=&1
set lines 185
set pages 30
col max_mb for 999,999.99
col aloc_mb for 999,999.99
col used_mb for 999,999.99
col diff_mb for 999,999.99
col free_mb for 999,999.99
col status for a10
col extent_management for a5 truncated
col file_name for a50 truncated
col file_id for 9999
col bs for 999
select /*+ NO_MERGE */ 
file_id, file_name, aloc_MB, max_MB, used_MB
,status , blocksize bs, extent_management
,round(used_mb/aloc_mb*100,2) pct_used
,round(aloc_mb-max_mb,2) diff_mb
,round(aloc_mb-used_mb,2) free_mb
from
(
select /* RULE */ df.file_id, df.file_name, round(df.bytes/1024/1024,2) aloc_MB,round(end*tb.block_size/1024/1024,2) max_MB, round(used*tb.block_size/1024/1024,2) used_MB
,tb.status ,tb.block_size/1024 blocksize, tb.extent_management
 from 
     dba_tablespaces tb
   , dba_data_files df
   , 	(select tablespace_name,file_id,max(ext.block_id+ext.blocks) end, sum(ext.blocks) used
	from dba_extents ext
   	group by tablespace_name,file_id ) ext
 where tb.tablespace_name=upper('&tbs')
 and tb.tablespace_name=df.tablespace_name
 and df.tablespace_name=ext.tablespace_name (+)
 and df.FILE_ID=ext.file_id (+)
) a
order by diff_mb
/
