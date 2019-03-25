define scope='&1'
col name for a35
col value for a40
col scope for a20
col detail for a75 word_wrapped
select *
from exp_parameter
where scope like '&scope'
order by name, scope
/
