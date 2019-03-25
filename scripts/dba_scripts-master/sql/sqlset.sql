define sqlset=&1
col DESCRIPTION for a60 word_wrapped

select *
from dba_sqlset
where name like ('&sqlset')
order by created
/