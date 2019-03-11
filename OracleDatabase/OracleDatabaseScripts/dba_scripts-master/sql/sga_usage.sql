col total_MB for 999,999,999.99
col free_MB for 999,999,999.99
col perc_free for 999.99
col pool for a30

select tot.pool, tot.bytes/1024/1024 total_mb, free.bytes/1024/1024 free_mb, free.bytes/tot.bytes*100 perc_free
from 
	(select pool,sum(bytes) bytes
		from v$sgastat 
		where pool is not null
		group by pool) tot
, (select pool,bytes 
	from v$sgastat 
	where name='free memory') free
where tot.pool=free.pool
order by total_mb desc
/