define seg=&1
select file_id,block_id blk_start, block_id+blocks-1 blk_end
, segment_name, tablespace_name, status
,blocks*1024*32 extent_size
from dba_undo_extents
where segment_name like upper('&seg')
--group by segment_name,tablespace_name,status
order by file_id,block_id
/
