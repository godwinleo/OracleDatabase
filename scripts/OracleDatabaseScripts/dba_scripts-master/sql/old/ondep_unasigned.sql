col user_name for a29
col status for a15
col db_sid for a15
col account_type for a20
col db_profile for a29
select user_name,db_sid,status,soeid,resource_id,account_type,create_date,db_profile,auth_type
from ondep.ondep_users
where status='OPEN' 
and ACCOUNT_TYPE != 'SYSTEM ACCOUNT'
and soeid is null
order by db_sid,create_date,user_name
/

