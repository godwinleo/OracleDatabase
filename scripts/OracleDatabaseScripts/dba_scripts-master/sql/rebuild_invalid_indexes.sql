 select 'alter index '||idx||' rebuild '||decode(partition_name,null,'',' partition '||partition_name)||' online compute statistics;' query
 from
 (select owner||'.'||index_name idx, 1 partition_position, null partition_name,tablespace_name
 from dba_indexes
 where status ='UNUSABLE'
 union all
 select index_owner||'.'||index_name idx, partition_position, partition_name,tablespace_name
 from dba_ind_partitions
 where status ='UNUSABLE'
 order by idx, partition_position
 )
/
