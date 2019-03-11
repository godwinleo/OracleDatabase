set verify off
col profile format a40

break on profile skip page on resource_type skip 1
select profile, resource_type, resource_name, limit
from dba_profiles
where profile like upper('%&&1.%') 
order by profile, resource_type
/

break on profile skip 1
select profile, username
from dba_users where profile like upper('%&&1.%') or username like  upper('%&&1.%')
order by profile
/

undefine 1
clear break

set verify on