COL NAME   FORMAT A20 HEAD "Parâmetro"
COL VALUE  FORMAT A30 HEAD "Valor"
COL PLAN_TABLE_OUTPUT FORMAT A200 HEAD "Plano de Execução"
SET PAGES 1000

SELECT PLAN_TABLE_OUTPUT
FROM TABLE(DBMS_XPLAN.DISPLAY('SYS.PLAN_TABLE$', '&1.', 'TYPICAL'  )) 
--FROM TABLE(DBMS_XPLAN.DISPLAY('SYS.PLAN_TABLE$', '&1.', 'ALL'  )) -- ALL -PROJECTION -ALIAS 
/

SELECT NAME, UPPER(VALUE) VALUE
FROM V$PARAMETER
WHERE NAME IN ( 'cursor_sharing', 'optimizer_mode', 'hash_join_enabled' )
UNION ALL
SELECT 'sql_id', '&P_SQL_ID.' FROM DUAL where '&P_SQL_ID.' <> 'n/a'
UNION ALL
SELECT 'child_address', case when '&P_SQL_ID.' = 'n/a' then 'n/a' else to_char('&p_child_addr.') end FROM DUAL where  '&P_SQL_ID.' <> 'n/a'
UNION ALL
SELECT DISTINCT 'plan_hash_value', case when '&P_SQL_ID.' = 'n/a' then 'n/a' else to_char(PLAN_ID) end
FROM sys.PLAN_TABLE$
WHERE STATEMENT_ID = '&1.' and  '&P_SQL_ID.' <> 'n/a'
UNION ALL
SELECT 'sql_profile', '&p_sql_profile.' FROM DUAL where length('&p_sql_profile.') > 0
UNION ALL
SELECT 'sql_plan_baseline', '&p_sql_plan_baseline.' FROM DUAL where length('&p_sql_plan_baseline.') > 0
UNION ALL
SELECT 'sql_patch', '&p_sql_patch.' FROM DUAL where length('&p_sql_patch.') > 0
UNION ALL
SELECT 'outline_category', '&p_outline_category.' FROM DUAL where length('&p_outline_category.') > 0
--UNION ALL
--SELECT 'arquivo', upper('explain.&1..sql') FROM DUAL 
/

COL NAME   clear
COL VALUE  clear
COL PLAN_TABLE_OUTPUT clear
SET PAGES 100


