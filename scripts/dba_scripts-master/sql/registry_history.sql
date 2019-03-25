set pages 100
set feed on
col action_time for a20
col comments for a30
col version for a20
col action for a20
col action_time for a30
col namespace for a15
col bundle_series for a15
select *
from sys.registry$history
order by action_time
/
