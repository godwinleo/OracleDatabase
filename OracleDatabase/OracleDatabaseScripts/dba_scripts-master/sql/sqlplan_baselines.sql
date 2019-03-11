select sql_handle,plan_name,parsing_schema_name,accepted 
from DBA_SQL_PLAN_BASELINES
where enabled='NO'
/
