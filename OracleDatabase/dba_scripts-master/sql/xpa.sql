COL PLAN_TABLE_OUTPUT FOR A178
SET PAGESIZE 4000

-- DISPLAY         - to format and display the contents of a plan table.
-- DISPLAY_CURSOR  - to format and display the contents of the execution plan of any loaded cursor.
-- DISPLAY_AWR     - to format and display the contents of the execution plan of a stored SQL statement in the AWR.
-- DISPLAY_SQLSET  - to format and display the contents of the execution plan of statements stored in a SQL tuning set.

-- look at
-- V$SQL_PLAN, V$SESSION and V$SQL_PLAN_STATISTICS_ALL
--
--
-- ----------------------------------------------------
-- SYNTAX
-- ----------------------------------------------------
--
-- 
-- DBMS_XPLAN.DISPLAY_AWR( 
--    sql_id            IN      VARCHAR2,
--    plan_hash_value   IN      NUMBER DEFAULT NULL,
--    db_id             IN      NUMBER DEFAULT NULL,
--    format            IN      VARCHAR2 DEFAULT TYPICAL);
-- 
--
--
-- ----------------------------------------------------
-- PARAMETERS:
-- ----------------------------------------------------
--
--  plan_hash_value: Optional parameter. Identifies a specific stored execution plan for a SQL statement. 
--                   If suppressed, all stored execution plans are shown.

--  format: FORMAT: controls the detail of output: BASIC | TYPICAL | SERIAL | ALL | OUTLINE | ADVANCED 
--                  RUNSTATS_TOT  - Same as IOSTATS, that is, displays IO statistics for ALL executions of the specified cursor.
--                  RUNSTATS_LAST - Same as IOSTATS LAST, that is, displays the runtime statistics for the LAST execution of the cursor

--  sqlset_owner:   The owner of the SQL tuning set. The default is the current user. 
--
--

prompt MODE: BASIC | TYPICAL | SERIAL | ALL | OUTLINE | ADVANCED | RUNSTATS_TOT | RUNSTATS_LAST
     
select * from table(dbms_xplan.display_awr('&sqlid','&plan_hash',null,'&format'));


SET PAGESIZE 100