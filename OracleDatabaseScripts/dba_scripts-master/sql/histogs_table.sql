define tabname=&1
set pages 200
set lines 180
set trims on
col OWNER for a20
col TABLE_NAME for a25
col COLUMN_NAME for a30
col ENDPOINT_NUMBER for 99999999999
col ENDPOINT_VALUE for 99999999999
col ENDPOINT_ACTUAL_VALUE for a40

select OWNER,TABLE_NAME,COLUMN_NAME,ENDPOINT_NUMBER,ENDPOINT_VALUE,ENDPOINT_ACTUAL_VALUE
from dba_tab_histograms
where table_name=upper('&tabname')
order by column_name;
