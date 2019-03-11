col checkpoint_change# for 9999999999999999
col max_scn for 9999999999999999
col min_scn for 9999999999999999
select /*+ NO_MERGE */ fuzzy,count(1),min(checkpoint_change#) min_scn,max(checkpoint_change#) max_scn
,min(checkpoint_time),max(checkpoint_time)
from v$datafile_header
--where file# not in (Select file# from v$datafile where enabled!='READ WRITE')
group by fuzzy
/
