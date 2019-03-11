define filesystem=&1
set lines 185
set pages 200
col tablespace_name for a27
col file_name for a60
col max_mb for 999,999,999.99
col diff_mb for 999,999,999.99
col aloc_mb for 999,999,999.99
col status for a20
 --select max(ext.block_id+ext.blocks) end,max(ext.block_id+ext.blocks)*tb.block_size/1024/1024/1024 max_Gb 
select /* NO_MERGE */ tablespace_name,file_name, aloc_mb-max_mb diff_mb, max_mb, aloc_mb,status 
from (
select /* RULE */ df.tablespace_name, df.file_name,round(nvl(end,0)*tb.block_size/1024/1024,2) max_MB, round(df.bytes/1024/1024,2) ALOC_MB,tb.status
from 
   dba_data_files df
   , dba_tablespaces tb
   , (select tablespace_name,file_id,max(ext.block_id+ext.blocks) end
   from dba_extents ext
   group by tablespace_name,file_id) ext
 where df.file_name like '&filesystem/%'
 --and df.bytes/1024/1024 > 1024
 and df.tablespace_name=tb.tablespace_name
 and tb.contents='PERMANENT'
 and tb.tablespace_name not in ('SYSTEM','SYSAUX')
 and df.tablespace_name=ext.tablespace_name (+)
 and df.file_id=ext.file_id (+)
) a
order by diff_mb
 --and round (used_mb/aloc_mb*100,2) < 80
/
