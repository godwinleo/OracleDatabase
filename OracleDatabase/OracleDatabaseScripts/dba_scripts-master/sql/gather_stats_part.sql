set echo off
define schema=&1
define table=&2
define part=&3
set serveroutput on
set long 100000000
set timing on
set feed on
begin
	dbms_Stats.gather_table_Stats(
		ownname => '&schema'
		, tabname => '&table'
		, partname => '&part'
		--, method_opt => 'FOR ALL COLUMNS SIZE AUTO'
		--, method_opt => 'FOR ALL INDEXED COLUMNS SIZE SKEWONLY'
		--, sample_size => DBMS_STATS.AUTO_SAMPLE_SIZE
		--, sample_size => DBMS_STATS.AUTO_SAMPLE_SIZE
		, granularity => 'APPROX_GLOBAL AND PARTITION'
		, cascade => true
		, degree => 6
		, no_invalidate => false
	);
end;
/
set timing off
