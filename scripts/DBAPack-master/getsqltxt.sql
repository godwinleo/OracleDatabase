set verify off LINES 300

col "Inst"      format 9999 head "Inst"
col "Abrindo"   format a6 head "  Open| /Exec"
col sql_text    format a120  head "Texto do SQL"
col disk_reads  format 999g999g990 head "Leituras|Físicas"
col buffer_gets format 999g999g999g990 head "Leituras|Lógicas"
col "PorExec"   format 999g999g990 head "/Execução"
col "Linhas"    format 999g999g990 head "Linhas|Processadas"
col executions  format 99999999 head "Execuções"
col times       format a16  just r head "CPU/Elapsed|(msecs)"
col times_byexec  format a12  just r head "/Execução"
col parse_user    format a20

define p_user="&1."
define p_texto="&2."

REM PROMPT *&P_TEXTO.*

SELECT /* cGetSqlTxt */
  inst_id inst,  sql_id
 ,parsing_schema_name parse_user
 ,lpad( trim(USERS_OPENING)||'/'||trim(USERS_EXECUTING), 6, ' ' ) "Abrindo"
 ,executions, rows_processed "Linhas"
 ,disk_reads, disk_reads/decode(executions,0, 1,executions) "PorExec"
 ,buffer_gets, buffer_gets/decode(executions,0, 1,executions) "PorExec"
 ,lpad( trim(trunc(cpu_time/1000))||'/'||trim(trunc(elapsed_time/1000)), 16, ' ' ) times 
 ,lpad( trim(trunc(cpu_time/decode(executions,0, 1,executions)/1000))||'/'||trim(trunc(elapsed_time/decode(executions,0, 1,executions)/1000)), 12, ' ' ) times_byexec 
 ,substr( sql_text, 1, 120 ) sql_text
from gv$sqlarea
where UPPER( sql_fulltext ) like UPPER('&p_texto.')
and sql_text not like 'SELECT /* cGetSqlTxt */%'
and UPPER( parsing_schema_name ) like UPPER('&p_user.')
--and buffer_gets > 10000
--and executions > 1000
--order by case when executions > 1 then buffer_gets/executions else buffer_gets end desc
order by buffer_gets desc
/
set verify on

undefine 1 2  p_user p_texto

col sql_text    clear
col disk_reads  clear
col buffer_gets clear
col "PorExec"   clear
col "Abrindo"   clear
col "Linhas"    clear
col executions  clear


 