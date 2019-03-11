define tbspace=&1
set lines 185
set pages 200
set feed on
col file# for 9999
col name for a60
col MB for 999,999,999.99
col NEXT_MB for 999,999,999.99
col MAX_MB for 999,999,999.99
col autoextensible for a4
break on report
compute sum of MB on report
select df2.file#,df2.name,df2.bytes/1024/1024 MB
--,df.autoextensible,df.INCREMENT_BY*tb.block_size/1024/1024 NEXT_MB
--,df.maxbytes/1024/1024 MAX_MB
,df2.status,df2.blocks
--,df.maxblocks
from 
   v$tablespace tb
   , v$tempfile df2
where tb.name like upper('&tbspace')
and tb.ts#=df2.ts#
order by df2.creation_time
;
