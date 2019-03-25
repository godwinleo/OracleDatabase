def owner=&1
def name=&2
set lines 180
set pages 60
col owner for a30
col mview_name for a30
col container_name for a30
select owner,mview_name,container_name
,COMPILE_STATE
,UPDATABLE
,UPDATE_LOG
from dba_mviews
where mview_name like ('&name')
and owner like upper('&owner')
/
