define txt=&1
col owner for a30
col name for a30
col text for a70

select OWNER
, NAME
, TYPE
, LINE
, TEXT
from dba_source
where text like '%&txt%'
/