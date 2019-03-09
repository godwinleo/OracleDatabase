define owner=&1
col idx for a45
col tab for a35
select index_owner||'.'||index_name idx, partition_position, partition_name,tablespace_name, table_owner||'.'||table_name tab
from (
	select owner index_owner, index_name, 1 partition_position, null partition_name,tablespace_name, status, table_owner, table_name
	from dba_indexes
	union all
	select ip.index_owner, ip.index_name, ip.partition_position, ip.partition_name, ip.tablespace_name, ip.status, idx.table_owner, idx.table_name
	from dba_ind_partitions ip, dba_indexes idx
	where  ip.index_owner=idx.owner
	and  ip.index_name=idx.index_name
) 
where status='UNUSABLE'
and (index_owner like upper('&owner')
	or table_owner like upper('&owner')
)
order by tab, idx, partition_position
/

