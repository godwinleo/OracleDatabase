set pages 100
set feed on
col comp_id for a10
col comp_name for a45
col version for a15
col namespace for a15
col schema for a15
col other_schemas for a55
select comp_id,comp_name,version,status,modified,schema
,other_schemas
from dba_registry
order by modified,comp_id
/
