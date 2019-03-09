SET LINES 300 FEED OFF

COL STATUS FORMAT A15
COL FILE_NAME FORMAT A60

COL USN  FORMAT 999                HEAD "USN"
COL NAME FORMAT A30                HEAD "SegName"
COL "Wrp/Srh/Ext" FORMAT A11
COL STATUS FORMAT A7               HEAD "Status"
COL GETS FORMAT 999G999G999         HEAD "Gets"
COL WAITS FORMAT 999G999           HEAD "Waits"
COL XACTS FORMAT 999               HEAD "XActs"
COL EXTENTS FORMAT 99999           HEAD "Extents"
COL MHWMSIZE FORMAT 999G999        HEAD "HWMSizeMb"
COL MRSSIZE FORMAT 999G999         HEAD "RSSizeMb"
COL MWRITES FORMAT 999G999         HEAD "WritesMb"
COL MAVEACTIVE FORMAT 999G999      HEAD "AvgActvMb"
COL MOPTSIZE FORMAT 999G999        HEAD "OptSizeMb"

COL "Size MB"           FORMAT A10 Just R
COL "Max MB"            FORMAT A10 Just R
COL "User MB"           FORMAT A10 Just R
COL "Free MB"           FORMAT A10 Just R
COL "InUse MB"          FORMAT A10 Just R

COL PCT_USED_MAX        Format 999d99 HEAD "Used(%)" Just R
COL INTERVALO           Format A9 HEAD "Inservalo" 

COL "Tablespace"        FORMAT A10
COL "ExtentsCnt"        FORMAT A10
COL "CurrSizeMb"        FORMAT A10
COL "CurrFreeMb"        FORMAT A10
COL "TbsMaxSizeMb"      FORMAT A12
COL "MaxUsedMb"         FORMAT A9
COL "MaxSortMb"         FORMAT A9

COL "Extent/Segment Management" FORMAT A30

break on inst_id skip page
compute sum of mrssize maveactive on inst_id 

select 
   s.inst_id
  ,s.usn
  ,s.xacts
  ,s.extents
  ,lpad(s.wraps,3,' ')||'|'||lpad(s.shrinks,3,' ')||'|'||lpad(s.extends,3,' ') "Wrp/Srh/Ext"
  ,s.gets
  ,s.waits
  ,status
  ,trunc(s.aveactive/1048576) maveactive
  ,trunc(s.rssize/1048576) mrssize
  ,trunc(s.hwmsize/1048576) mhwmsize
  ,trunc(s.writes/1048576) mwrites
  --,trunc(s.optsize/1048576) moptsize
from gv$rollstat s
order by s.inst_id, s.USN
.

clear break
clear compute

with undo_tbs as
(
  SELECT 
    t.tablespace_name 
  -- ,v.file_name
   ,T.EXTENT_MANAGEMENT || ' ' || T.ALLOCATION_TYPE || ' ' ||
    DECODE( T.NEXT_EXTENT, NULL, 'AutoAlloc, ', TO_CHAR( T.NEXT_EXTENT * T.BLOCK_SIZE / 1048576, 'fm9g999' ) || 'Mb, ' ) ||
    T.SEGMENT_SPACE_MANAGEMENT "Extent/Segment Management"
   ,LPAD( TO_CHAR( (v.maxblocks*t.block_size/1048576), 'fm999g999' ), 10, ' ' ) Max_MB
   ,LPAD( TO_CHAR( (v.blocks*t.block_size/1048576), 'fm999g999' ), 10, ' ' ) Size_MB
   ,LPAD( TO_CHAR( (v.user_blocks*t.block_size/1048576), 'fm999g999' ), 10, ' ' ) User_MB
   ,LPAD( TO_CHAR( (v.free_blocks*t.block_size/1048576), 'fm999g999' ), 10, ' ' ) Free_MB
   ,LPAD( TO_CHAR( (v.inuse_blocks*t.block_size/1048576), 'fm999g999' ), 10, ' ' ) InUse_MB
   ,TO_CHAR( ROUND(v.inuse_blocks/NULLIF(v.maxblocks,0)*100, 2 ), '99999990D00' ) PCT_USED_MAX
   ,TO_CHAR( ROUND(v.inuse_blocks/NULLIF(v.blocks,0)*100, 2 ), '9990D00' ) PCT_USED
  -- ,v.autoextensible
  -- ,v.status file_status
  -- ,v.online_status
  -- ,t.status tbs_status
  --, t.contents
  -- ,v.blocks
  -- ,v.maxblocks
  -- ,v.user_blocks
  -- ,v.free_blocks
  -- ,v.increment_by
   ,t.block_size
   , 1048576 MEGA 
  FROM dba_tablespaces t
  JOIN
  (
    SELECT f.file_name, f.tablespace_name, f.status, f.autoextensible,
    f.blocks, f.maxblocks, f.user_blocks, f.increment_by, 
    f.online_status, nvl(fs.blocks,0) free_blocks,  f.user_blocks-nvl(fs.blocks,0) inuse_blocks
    FROM dba_data_files f
    LEFT JOIN
    (
      SELECT /*+all_rows*/ file_id, sum(blocks) blocks 
      FROM dba_free_space
      GROUP BY file_id
    ) fs on (f.file_id = fs.file_id)
/*
    UNION ALL
    SELECT f.file_name, f.tablespace_name, f.status, f.autoextensible,
    f.blocks, f.maxblocks, f.user_blocks, f.increment_by,
    'TEMP' online_status, (f.user_blocks-nvl(su.used_blocks,0)) free_blocks, nvl(su.used_blocks,0) inuse_blocks
    FROM dba_temp_files f
    LEFT JOIN
    (
      SELECT segrfno#, tablespace, sum(blocks) used_blocks  FROM gv$sort_usage
      GROUP BY segrfno#, tablespace
    ) su ON (su.tablespace = f.tablespace_name and su.segrfno# = f.relative_fno)
*/    
  ) V on (v.tablespace_name = t.tablespace_name)
  --where t.contents  in ( 'UNDO', 'TEMPORARY')
  where t.contents  in ( 'UNDO' )
),
Blocos as
(
  SELECT 
     INST_ID
    ,(select name from v$tablespace where ts# = undotsn ) tablespace_name
    ,to_char(BEGIN_TIME, 'dd/mm hh24:mi' ) BEGIN_TIME
    ,to_char(END_TIME, 'dd/mm hh24:mi' ) END_TIME
    ,to_char(TRUNC(SYSDATE) + (END_TIME - BEGIN_TIME), 'hh24:mi:ss' ) Intervalo
    ,UNDOBLKS
    ,ACTIVEBLKS ATIVOS
    ,UNEXPIREDBLKS UNEXPIRED
    ,EXPIREDBLKS EXPIRED
    ,ACTIVEBLKS+UNEXPIREDBLKS+EXPIREDBLKS TOTAL
  FROM GV$UNDOSTAT
  WHERE END_TIME>=SYSDATE-1/1440/6
  ORDER BY INST_ID
  --ORDER BY END_TIME DESC, INST_ID FETCH FIRST 3 ROWS ONLY
)
SELECT
   B.INST_ID
  ,T.TABLESPACE_NAME "Tablespace"
  ,T.MAX_MB "Max Mb"
  ,T.USER_MB "User Mb"
  ,T.FREE_MB "Free Mb"
  ,T.INUSE_MB "InUse Mb"
  ,T.PCT_USED_MAX 
  ,B.intervalo 
  ,ROUND(b.ativos * t.block_size / t.mega ) "Ativo"
  ,ROUND(b.unexpired * t.block_size / t.mega ) "Unexpired"
  ,ROUND(b.expired * t.block_size / t.mega ) "Expirado"
  ,LPAD( TO_CHAR( (b.total * t.block_size / t.mega ), 'fm999g999' ), 10, ' ' ) "InUse MB"
FROM BLOCOS B
JOIN UNDO_TBS T ON (B.TABLESPACE_NAME =T.TABLESPACE_NAME)
/

PROMPT
SET FEED 6
SET HEAD ON
