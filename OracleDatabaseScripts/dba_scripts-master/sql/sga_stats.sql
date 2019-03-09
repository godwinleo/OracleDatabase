col MB for 999,999,999.99
col pool for a30

select nvl(pool,name) pool, sum(bytes/(1024*1024)) MB
from v$sgastat
group by nvl(pool,name)
order by mb desc
/