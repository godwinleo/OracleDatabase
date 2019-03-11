select extract( day from snap_interval) *24*60+extract( hour from snap_interval) *60+extract( minute from snap_interval ) snapshot_interval
, extract( day from retention) *24*60+extract( hour from retention) *60+extract( minute from retention ) retention_interval
, topnsql
from dba_hist_wr_control;