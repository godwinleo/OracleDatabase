define user=&1
set lines 185
set pages 100
set feed on
set trims on

col owner for a30
break on report
compute sum of cant on report
select owner,object_type,status, count(1) cant
from dba_objects
where owner like upper('&user')
--and status!='VALID'
group by owner,object_type,status
order by 1,2,3
/
