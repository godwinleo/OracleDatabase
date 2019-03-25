set lines 185
set pages 0
col segment_name for a25
col max_mb for 999,999,999.99
col aloc_mb for 999,999,999.99
col used_mb for 999,999,999.99
col recup_mb for 999,999,999.99
col partition_name for a15
col segment_type for a15
col column_name for a20
col table_name for a20
 --select max(ext.block_id+ext.blocks) end,max(ext.block_id+ext.blocks)*tb.block_size/1024/1024/1024 max_Gb 
select tbs.tablespace_name, max_mb-used_mb recup_mb,seg.used_mb, max_MB, aloc_MB,tbs.status,  round (used_mb/aloc_mb*100,2) used_pct
from
 (select df.tablespace_name, round(sum(end*tb.block_size)/1024/1024,2) max_MB, round(sum(df.bytes)/1024/1024,2) aloc_MB,tb.status
 from 
   (select tablespace_name,file_id,max(ext.block_id+ext.blocks) end
   from dba_extents ext
   group by tablespace_name,file_id) ext
   ,dba_data_files df
   , dba_tablespaces tb
 where ext.FILE_ID=df.file_id
 --and df.bytes/1024/1024 > 1024
 and ext.TABLESPACE_NAME=tb.TABLESPACE_NAME
 and tb.contents='PERMANENT'
 and tb.tablespace_name not in ('SYSTEM','SYSAUX')
 group by df.tablespace_name,tb.status
 ) tbs
 , (select tablespace_name,round(sum(bytes)/1024/1024,2) used_mb from dba_segments group by tablespace_name) seg
 where tbs.TABLESPACE_NAME=seg.tablespace_name (+)
 and round (used_mb/aloc_mb*100,2) < 80
order by max_mb-used_mb
/
