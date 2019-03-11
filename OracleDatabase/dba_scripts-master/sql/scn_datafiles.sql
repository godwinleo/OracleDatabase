col checkpoint_change# for 9999999999999999
select checkpoint_change#,count(1)
from v$datafile
where enabled='READ WRITE'
group by checkpoint_change#
order by checkpoint_change#
/
