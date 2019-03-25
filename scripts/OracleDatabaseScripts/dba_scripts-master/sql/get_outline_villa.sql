DECLARE
 
cl_sql_text CLOB;
v_sqlid varchar2(30):= '&sqlid';
v_plan number:= &plan;
 
hint_spec sys.sqlprof_attr;
 
BEGIN
 
--SELECT sql_fulltext INTO cl_sql_text FROM gv$sqlarea WHERE sql_id='gtwyx63711jp1';
 
SELECT sql_text INTO cl_sql_text 
FROM dba_hist_sqltext 
WHERE sql_id = v_sqlid;
 
SELECT extractvalue(VALUE(d), '/hint') AS outline_hints
BULK COLLECT INTO hint_spec
FROM xmltable('/*/outline_data/hint' 
	passing ( 
		SELECT xmltype(other_xml) AS xmlval 
		FROM dba_hist_sql_plan 
		WHERE sql_id = v_sqlid
		AND plan_hash_value = v_plan
		AND other_xml IS NOT NULL)
) d;
 
dbms_output.put_line(hint_spec);

/*
DBMS_SQLTUNE.IMPORT_SQL_PROFILE(
	sql_text => cl_sql_text, 
	profile => hint_spec,
	name => v_prof_name, 
	force_match => TRUE);
*/
END;
/
