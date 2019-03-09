define addr=&1
set pages 200
set lines 185
col segment_name for a50
col name for a35
set trims on
 select /*+ RULE */
        e.owner ||'.'|| e.segment_name  segment_name,
        e.extent_id  extent#,
        x.dbablk - e.block_id + 1  block#,
        x.tch,
        l.child#
	,l.name
      from
        sys.v$latch_children  l,
        sys.x$bh  x,
        sys.dba_extents  e
      where
        x.hladdr  = '&addr' and
        e.file_id = x.file# and
        x.hladdr = l.addr and
        x.dbablk between e.block_id and e.block_id + e.blocks -1
      order by x.tch 
;
