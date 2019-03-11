select component,current_size 
from v$memory_dynamic_components 
order by current_size
/
