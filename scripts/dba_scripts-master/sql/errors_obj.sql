define owner=&1
define obj=&2
col owner for a15
col type for a12
col errortxt for a80 truncated
col text for a75 truncated
col line_pos for a8
col seq for 999

select -- err.owner,
err.type
,err.sequence seq,err.line||':'||err.position line_pos
,err.text errortxt
,ltrim(src.text) text
from dba_Errors err,
dba_source src
where err.name like upper('&obj')
and src.owner like upper('&owner')
and err.owner=src.owner
and err.name=src.name
and err.line=src.line
and err.type=src.type
--and err.type='PACKAGE'
order by err.type,err.owner,err.name,err.sequence
;
