
col occupant_name for a35
col occupant_desc for a65
col schema_name for a35
col move_procedure for a35
col move_procedure_desc for a45
select OCCUPANT_NAME ,OCCUPANT_DESC ,SCHEMA_NAME 
--,MOVE_PROCEDURE ,MOVE_PROCEDURE_DESC 
,round(SPACE_USAGE_KBYTES/1024/1024,2) GB
from v$sysaux_occupants
where SPACE_USAGE_KBYTES > 0
order by space_usage_kbytes
/

