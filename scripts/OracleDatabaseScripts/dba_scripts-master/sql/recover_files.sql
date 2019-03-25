col change# for 999999999999999
col name for a60

select rf.*, df.name
from v$recover_file rf
,v$datafile df
where rf.file#=df.file#
;
