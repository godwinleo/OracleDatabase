set lines 185
set pages 0
col segment_name for a25
col max_mb for 999,999,999.99
col aloc_mb for 999,999,999.99
col partition_name for a15
col segment_type for a15
col column_name for a20
col table_name for a20
 --select max(ext.block_id+ext.blocks) end,max(ext.block_id+ext.blocks)*tb.block_size/1024/1024/1024 max_Gb 
 select df.tablespace_name, df.file_id, end, round(end*tb.block_size/1024/1024,2) max_MB, round(df.bytes/1024/1024,2) aloc_MB
 from 
   (select tablespace_name,file_id,max(ext.block_id+ext.blocks) end
   from dba_extents ext
   group by tablespace_name,file_id) ext
   ,dba_data_files df
   , dba_tablespaces tb
 --, (select tablespace_name,sum(bytes) from dba_segments group by tablespace_name) seg
 where ext.FILE_ID=df.file_id
 and ext.TABLESPACE_NAME=tb.TABLESPACE_NAME
 and tb.contents='PERMANENT'
 and tb.tablespace_name not in ('SYSTEM','SYSAUX')
 and df.bytes/1024/1024 > 1024
 --and ext.TABLESPACE_NAME='&&1'
order by tablespace_name,max_mb
/
