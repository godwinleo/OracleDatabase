define user=&1
set lines 185
set pages 100
set feed on
set trims on

col owner for a30
col INVALID_OBJECTS_COUNT for 9,999

break on report
compute sum of invalid_objects_count on report
select owner,count(1) INVALID_OBJECTS_COUNT
from dba_objects
where owner like upper('&user')
and status!='VALID'
group by owner
order by 2
/
