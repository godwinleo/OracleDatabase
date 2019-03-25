define owner=&1
define obj=&2

select * 
from DBA_DEPENDENCIES
where owner like upper ('&owner')
and name like upper ('&obj')
/