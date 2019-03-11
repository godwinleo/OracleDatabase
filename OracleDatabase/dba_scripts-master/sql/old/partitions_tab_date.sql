col db_sid for a10
col servername for a10
col table_name for a30
col table_owner for a15
col partition_name for a30
col tablespace_name for a15
select db_sid,servername,table_owner,table_name,partition_name,partition_position,tablespace_name,num_rows
from dbadmin.dbs_tab_partitions
partition (DBS_TAB_PARTITIONS_SEP10)
where table_name like upper('&tab')
and table_owner like upper ('&owner')
and book_dt =to_date('30-SEP-2010','DD-MON-YYYY')
order by db_sid,partition_position
/
