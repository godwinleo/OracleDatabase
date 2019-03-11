set serveroutput on
set pages 80
set lines 185
undef name schema
begin
	dbms_sqltune.capture_cursor_cache_sqlset (
		sqlset_name => '&name'
		, time_limit => 300 -- 3600 1hour ; 1800 30min; 300 5min
		, repeat_interval => 5 -- seconds
		, capture_mode => dbms_sqltune.MODE_ACCUMULATE_STATS
		, basic_filter => 'parsing_schema_name=upper(''&schema'')'
		);
end;
/
