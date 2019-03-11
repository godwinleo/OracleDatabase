define tbspace=&1
set lines 185
set pages 200
set feed on
col file_id for 9999
col file_name for a60
col MB for 999,999,999.99
col NEXT_MB for 999,999,999.99
col MAX_MB for 999,999,999.99
col autoextensible for a4
select df.file_id,df.file_name,df.bytes/1024/1024 MB,df.autoextensible,df.INCREMENT_BY*tb.block_size/1024/1024 NEXT_MB,df.maxbytes/1024/1024 MAX_MB,df.status,df.blocks,df.maxblocks
from dba_data_files df
,dba_tablespaces tb
where tb.tablespace_name=upper('&tbspace')
and tb.tablespace_name=df.tablespace_name
order by file_id
;
