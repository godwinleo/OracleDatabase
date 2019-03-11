col host for a40 truncated
col lower_port for 99999
col upper_port for 99999
col acl for a60
col aclid for a32
select ACLID
,HOST
,LOWER_PORT
,UPPER_PORT
,ACL
from DBA_NETWORK_ACLS
order by 1
/
