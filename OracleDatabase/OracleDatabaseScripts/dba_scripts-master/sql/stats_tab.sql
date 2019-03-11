define owner=&1
define tab=&2
define part=&3
select owner,table_name,object_type,partition_name,subpartition_name,stale_stats
from dba_tab_statistics
where owner like upper('&owner')
and table_name like upper ('&tab')
and partition_name like upper ( nvl('&part','%') )
and object_type ='PARTITION'
--and nvl(stale_stats,'YES')='YES';
