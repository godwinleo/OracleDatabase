define tbspace=&1
set lines 185
set pages 200
set feed on
col file# for 9999
col name for a80
col tablespace_name for a30
col MB for 999,999,999.99
col NEXT_MB for 999,999,999.99
col MAX_MB for 999,999,999.99
col autoextensible for a4
break on report
compute sum of MB on report
select df.file#,tb.name tablespace_name,df.name,df.status
from 
   v$tablespace tb
   , v$datafile df
where tb.name like upper('&tbspace')
and tb.ts#=df.ts#
order by df.creation_time
;
