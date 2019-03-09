col component for a25 head "Component" 
col status format a10 head "Status" 
col initial_size for 999,999,999,999 head "Initial" 
col parameter for a25 heading "Parameter" 
col final_size for 999,999,999,999 head "Final" 
col changed head "Changed At" 

select component, parameter, initial_size, final_size, status, 
to_char(end_time ,'mm/dd/yyyy hh24:mi:ss') changed 
from v$memory_resize_ops 
order by 6 
/ 