col min_scn for 999999999999999
col max_scn for 999999999999999
select status,fuzzy,count(1) cnt,min(checkpoint_change#) min_scn,max(checkpoint_change#) max_scn
, min(checkpoint_time) min_time, max(checkpoint_time) max_time
, min(checkpoint_count), max(checkpoint_count)
from v$datafile_header
group by status,fuzzy
/
