select segment_name,tablespace_name,status,count(1) extents
from dba_undo_extents
group by segment_name,tablespace_name,status
order by extents
/
