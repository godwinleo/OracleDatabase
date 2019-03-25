define user=&1
select  tablespace_name,username,bytes/1024/1024 MB,max_bytes/1024/1024,blocks,max_blocks,dropped
from dba_Ts_quotas
where username=upper('&user')
/
