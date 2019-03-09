col username format a30
col sql_exec_start format a20
col sql_id format a20
col plan_hash format a20
col sql_text format a70 
col start_date new_value start_date.

set termout off
--select to_char(trunc(sysdate)+(14/24+0/1440), 'DD/MM/YYYY HH24:MI:SS') start_date from dual;
select to_char(trunc(sysdate)+(7/24), 'DD/MM/YYYY HH24:MI:SS') start_date from dual;
define nlimite='1'
set termout on 

set verify off pages 1000

rem prompt
rem prompt ############################################################################################
rem prompt Sentenças EDOC que demoraram mais de &nlimite. segundos, antes de  &START_DATE.
rem prompt ##################################################

SELECT rownum rank, v.* 
FROM (
  SELECT /*+ NO_XML_QUERY_REWRITE */ x1.username, 
  to_char(to_date(x1.sql_exec_start, 'mm/dd/yyyy hh24:mi:ss'),'yyyy/mm/dd hh24:mi:ss') dt_start, x1.sql_id, x1.plan_hash, trunc(x1.elapsed_time/1000000,2) elap_sec, 
  replace(replace(substr(x1.sql_text, 1, 50), chr(13), ' ' ), chr(10), ' ' ) sql_text
  FROM dba_hist_reports t, xmltable('/report_repository_summary/sql' 
  PASSING xmlparse(document t.report_summary) 
  COLUMNS 
  sql_id path '@sql_id' 
  , sql_exec_start path '@sql_exec_start' 
  , sql_exec_id path '@sql_exec_id' 
  , sql_text path 'sql_text'
  , username path 'user'
  , plan_hash path 'plan_hash'
  , duration path 'stats/stat[@name="duration"]' 
  , elapsed_time path 'stats/stat[@name="elapsed_time"]' 
  , cpu_time path 'stats/stat[@name="cpu_time"]' 
  ) x1 
  where t.COMPONENT_NAME = 'sqlmonitor'
  and  x1.username = 'EXT_SMARTECM'
  and  x1.elapsed_time/1000000 > &nlimite.
  --and  x1.sql_id = 'a9yr4qy05y1yc'
  --and to_date(x1.sql_exec_start, 'MM/DD/YYYY HH24:MI:SS') between trunc(sysdate) and sysdate
  and to_date(x1.sql_exec_start, 'MM/DD/YYYY HH24:MI:SS') between (to_date( '&START_DATE.', 'DD/MM/YYYY HH24:MI:SS' )-8/24)  and to_date( '&START_DATE.', 'DD/MM/YYYY HH24:MI:SS' )
  order by 5 desc 
  --fetch first 10 rows only
) V  
order by to_date(dt_start, 'yyyy/mm/dd hh24:mi:ss')
.

prompt
prompt ############################################################################################
prompt Sentencas EDOC que demoraram mais de &nlimite. segundos, a partir de &START_DATE.
prompt NOTA: nx_prepare_user_read_acls(:1) excluida da listagem
prompt ##################################################

SELECT rownum rank, v.* 
FROM (
  SELECT /*+ NO_XML_QUERY_REWRITE */ x1.username, 
  to_char(to_date(x1.sql_exec_start, 'mm/dd/yyyy hh24:mi:ss'),'yyyy/mm/dd hh24:mi:ss') dt_start, x1.sql_id, x1.plan_hash, trunc(x1.elapsed_time/1000000,2) elap_sec, 
  replace(replace(substr(x1.sql_text, 1, 70), chr(13), ' ' ), chr(10), ' ' ) sql_text
  FROM dba_hist_reports t, xmltable('/report_repository_summary/sql' 
  PASSING xmlparse(document t.report_summary) 
  COLUMNS 
  sql_id path '@sql_id' 
  , sql_exec_start path '@sql_exec_start' 
  , sql_exec_id path '@sql_exec_id' 
  , sql_text path 'sql_text'
  , username path 'user'
  , plan_hash path 'plan_hash'
  , duration path 'stats/stat[@name="duration"]' 
  , elapsed_time path 'stats/stat[@name="elapsed_time"]' 
  , cpu_time path 'stats/stat[@name="cpu_time"]' 
  ) x1 
  where t.COMPONENT_NAME = 'sqlmonitor'
  and  x1.username = 'EXT_SMARTECM'
  and  x1.elapsed_time/1000000 > &nlimite.
  --and  x1.sql_id = 'a9yr4qy05y1yc'
  and  x1.sql_text not like 'BEGIN nx_prepare_user_read_acls%'
  and  x1.sql_text not like 'BEGIN nx_update_read_acls%'
  and to_date(x1.sql_exec_start, 'MM/DD/YYYY HH24:MI:SS') >= to_date( '&START_DATE.', 'DD/MM/YYYY HH24:MI:SS' )
  --and to_date(x1.sql_exec_start, 'MM/DD/YYYY HH24:MI:SS') between trunc(sysdate) and sysdate
  order by 5 desc 
  --fetch first 10 rows only
) V  
--order by to_date(dt_start, 'yyyy/mm/dd hh24:mi:ss')
/
set verify on pages 66
