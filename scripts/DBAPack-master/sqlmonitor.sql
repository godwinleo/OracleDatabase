/*
 
REAL TIME

 
SET lines 200
SET pages 1000
SELECT *
FROM
  (SELECT status,
    username,
    sql_id,
    sql_exec_id,
    TO_CHAR(sql_exec_start,'dd-mon-yyyy hh24:mi:ss') AS sql_exec_start,
    ROUND(elapsed_time/1000000)                      AS "Elapsed (s)",
    ROUND(cpu_time    /1000000)                      AS "CPU (s)",
    buffer_gets,
    ROUND(physical_read_bytes /(1024*1024)) AS "Phys reads (MB)",
    ROUND(physical_write_bytes/(1024*1024)) AS "Phys writes (MB)"
  FROM v$sql_monitor
  WHERE USERNAME = 'EXT_SMARTECM'
  ORDER BY elapsed_time DESC
  )
WHERE rownum<=20;
   
*/
   

/*   

HISTORICO

, status path 'status' 
, sql_text path 'sql_text'
, first_refresh_time path 'first_refresh_time'
, last_refresh_time path 'last_refresh_time'
, refresh_count path 'refresh_count'
, inst_id path 'inst_id'
, session_id path 'session_id'
, session_serial path 'session_serial'
, user_id path 'user_id'
, con_id path 'con_id'
, con_name path 'con_name'
, modul path 'module'
, action path 'action'
, service path 'service'
, program path 'program'
, is_cross_instance path 'is_cross_instance'
, dop path 'dop'
, instances path 'instances'
, px_servers_requested path 'px_servers_requested'
, px_servers_allocated path 'px_servers_allocated'
, user_io_wait_time path 'stats/stat[@name="user_io_wait_time"]'
, application_wait_time path 'stats/stat[@name="application_wait_time"]'
, concurrency_wait_time path 'stats/stat[@name="concurrency_wait_time"]'
, cluster_wait_time path 'stats/stat[@name="cluster_wait_time"]'
, plsql_exec_time path 'stats/stat[@name="plsql_exec_time"]'
, other_wait_time path 'stats/stat[@name="other_wait_time"]'
, buffer_gets path 'stats/stat[@name="buffer_gets"]'
, read_reqs path 'stats/stat[@name="read_reqs"]'
, read_bytes path 'stats/stat[@name="read_bytes"]'
*/
   
col username format a30
col sql_exec_start format a20
col sql_id format a20
col plan_hash format a20
col sql_text format a50 
col start_date new_value start_date.

set termout off
--select to_char(trunc(sysdate)+(11/24+15/1440), 'DD/MM/YYYY HH24:MI:SS') start_date from dual;
select to_char(trunc(sysdate)+(7/24), 'DD/MM/YYYY HH24:MI:SS') start_date from dual;
define nlimite='3'
set termout on 

set verify off pages 200

prompt
prompt ############################################################################################
prompt Sentenças que demoraram mais de &nlimite. segundos, a partir de &START_DATE.
prompt ##################################################


SELECT rownum rank, v.* 
FROM (
  SELECT /*+ NO_XML_QUERY_REWRITE */ x1.username, 
  to_char(to_date(x1.sql_exec_start, 'mm/dd/yyyy hh24:mi:ss'),'yyyy/mm/dd hh24:mi:ss') dt_start, x1.sql_id, x1.plan_hash,
  trunc(x1.elapsed_time/1000000,2) elap_sec, 
  replace(replace(substr(x1.sql_text, 1, 50), chr(13), ' ' ), chr(10), ' ' ) sql_text
  FROM dba_hist_reports t 
  , xmltable('/report_repository_summary/sql' 
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
  and  x1.username LIKE UPPER('&1.')
  and  x1.elapsed_time/1000000 > &nlimite.
  --and  x1.sql_id = 'a9yr4qy05y1yc'
  --and to_date(x1.sql_exec_start, 'MM/DD/YYYY HH24:MI:SS') between trunc(sysdate) and sysdate
  and to_date(x1.sql_exec_start, 'MM/DD/YYYY HH24:MI:SS') >= to_date( '&START_DATE.', 'DD/MM/YYYY HH24:MI:SS' )
  order by 5 desc 
  --fetch first 10 rows only
) V  
WHERE USERNAME IS NOT NULL AND USERNAME <> 'SYS'
/
set verify on pages 66
