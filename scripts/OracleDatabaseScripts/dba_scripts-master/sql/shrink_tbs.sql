define tbs=&1
set lines 185
set pages 40
col file_id for 99999
col end_block for 9,999,999,999,999
col end_bytes for 9,999,999,999,999,999
col aloc_bytes for 9,999,999,999,999,999
col used_bytes for 9,999,999,999,999,999
select df.file_id, nvl(end,0) end_block, nvl(end*tb.block_size,0) end_bytes
,df.bytes aloc_bytes, nvl(ext.used*tb.block_size,0) used_bytes
from dba_tablespaces tb
 , dba_data_files df
 , (select tablespace_name,file_id,max(ext.block_id+ext.blocks) end,sum(ext.blocks) used
    from dba_extents ext
    group by tablespace_name,file_id) ext
where tb.TABLESPACE_NAME=upper('&tbs')
and tb.tablespace_name=df.tablespace_name
and df.tablespace_name=ext.tablespace_name (+)
and df.file_id=ext.file_id (+)
order by ext.file_id
/
