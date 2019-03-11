define prof=&1
col profile for a35
col resource_name for a30
col resource for a15
col limit for a30
select *
from dba_profiles
where profile like upper('&prof')
/
