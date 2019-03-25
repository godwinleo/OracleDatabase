col component for a25 head "Component" 
col status format a10 head "Status" 
col initial_size for 999,999,999,999 head "Initial" 
col parameter for a25 heading "Parameter" 
col final_size for 999,999,999,999 head "Final" 
col changed head "Changed At" 

SELECT DISTINCT COMPONENT, MAX(TARGET_SIZE) "MAXIMUM SIZE" 
FROM DBA_HIST_MEMORY_RESIZE_OPS 
GROUP BY COMPONENT 
ORDER BY COMPONENT
/