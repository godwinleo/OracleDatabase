col pool for a20
col name for a30
col MB for 999,999,999.99
select pool
, name
, bytes/1024/1024 MB
from v$sgastat
where name ='free memory'
order by bytes
;
