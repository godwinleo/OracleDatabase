set long 2000000000
define ownname=&1
define viewname=&2

col text for a180 word_wrapped

select text from dba_views 
where owner like upper ('&ownname')
and view_name like upper ('&viewname')
;