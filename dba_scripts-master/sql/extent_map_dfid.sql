set lines 185
set pages 500
define fileid=&1
col mb for 999,999,999.99
col file_id for 999
col mb_start for 999,999,999.99
col seg for a45
col partition_name for a20
col segment_type for a15
col column_name for a25
col owner for a15
col table_name for a25
col block_id for 99999999
col end for 99999999
break on file_id
 select ext.block_id,ext.block_id+ext.blocks end,ext.bytes/1024/1024 mb,ext.block_id*tb.block_size/1024/1024 mb_start
 ,decode (PARTITION_NAME,null,ext.SEGMENT_NAME,ext.SEGMENT_NAME||':'||ext.PARTITION_NAME) seg,ext.SEGMENT_TYPE
 ,lob.column_name,lob.table_name,ext.owner
 from  dba_tablespaces tb, dba_data_files df, dba_extents ext, dba_lobs lob
 where ext.FILE_ID=df.file_id
 and ext.TABLESPACE_NAME=tb.TABLESPACE_NAME
 and ext.segment_name=lob.segment_name (+)
 and ext.file_ID=&fileid
union
 select fs.block_id,fs.block_id+fs.blocks end,fs.bytes/1024/1024 mb,fs.block_id*tb.block_size/1024/1024 mb_start,'FREE' SEGMENT_NAME,'FREE' SEGMENT_TYPE,'FREE' column_name, 'FREE' table_name, 'FREE' owner
 from dba_free_space fs,dba_data_files df, dba_tablespaces tb
 where fs.FILE_ID=df.file_id
 and fs.TABLESPACE_NAME=tb.TABLESPACE_NAME
 and fs.file_ID=&fileid
order by BLOCK_ID
/
