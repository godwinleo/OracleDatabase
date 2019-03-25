def owner=&1
def obj=&2
set lines 180
set pages 60
col owner for a30
col mview_name for a30
col container_name for a30
select owner,mview_name,container_name
from dba_mviews
where container_name like ('&obj')
and owner like upper('&owner')
/
