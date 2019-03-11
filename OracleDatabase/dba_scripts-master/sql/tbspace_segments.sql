define tbspace=&1
set lines 185
set pages 200
col MB for 999,999,999.99
col segment_name for a30
col partition_name for a30
col owner for a20
col segment_type for a10
col LOB_TABLE for a25
col LOB_COLUMN for a25
select seg.bytes/1024/1024 MB,seg.segment_name,partition_name,seg.owner,segment_type,lob.table_name LOB_TABLE,lob.column_name LOB_COLUMN
from dba_segments seg, dba_lobs lob
where seg.tablespace_name='&tbspace'
and seg.tablespace_name=lob.tablespace_name (+)
and seg.segment_name=lob.segment_name (+)
order by bytes
;
