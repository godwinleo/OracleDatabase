set echo off
define schema=&1
set serveroutput on
set long 100000000
set timing on
set feed on
begin
	dbms_Stats.gather_schema_Stats(
		ownname => '&schema'
		, options => 'GATHER AUTO'
		--, method_opt => 'FOR ALL COLUMNS SIZE AUTO'
		--, method_opt => 'FOR ALL INDEXED COLUMNS SIZE SKEWONLY'
		--, sample_size => DBMS_STATS.AUTO_SAMPLE_SIZE
		, cascade => true
		, degree => 4
		, no_invalidate => false
	);
end;
/
set timing off
