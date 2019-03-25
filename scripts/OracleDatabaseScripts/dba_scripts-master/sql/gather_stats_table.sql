set echo off
define schema=&1
define table=&2
set serveroutput on
set long 100000000
set timing on
set feed on
begin
	dbms_Stats.gather_table_Stats(
		ownname => '&schema'
		, tabname => '&table'
		, method_opt => 'FOR ALL COLUMNS SIZE AUTO'
		--, method_opt => 'FOR ALL COLUMNS SIZE 1'
		--, method_opt => 'FOR ALL INDEXED COLUMNS SIZE SKEWONLY'
		--, sample_size => DBMS_STATS.AUTO_SAMPLE_SIZE
		, granularity => 'ALL'
		, cascade => true
		, degree => 6
		, no_invalidate => false
		--, estimate_percent => 100
	);
end;
/
set timing off
