SET TERMOUT OFF HEAD OFF DEFINE "&" FEED OFF
SET SERVEROUT ON TIME ON TAB OFF

DEFINE OS=Linux
DEFINE OS=Windows

DEFINE p_new_prompt = 'SQLPROMPT "SQL> "'
DEFINE p_del_cmd    = 'del'
DEFINE p_txt_editor = '"notepad++.exe"'
DEFINE p_temp_path  = ''

COLUMN p_new_prompt NEW_VALUE p_new_prompt NOPRINT
COLUMN p_temp_path  NEW_VALUE p_temp_path  NOPRINT
COLUMN p_txt_editor NEW_VALUE p_txt_editor NOPRINT
COLUMN p_del_cmd    NEW_VALUE p_del_cmd    NOPRINT

SAVE temp.sql REP

select
  'SQLPROMPT "' || lower(user) ||'@'|| lower(instance_name) ||'.'|| replace(lower(host_name), '.redecamara.camara.gov.br', '' ) || '> "' p_new_prompt,
  decode( '&OS.', 'Linux', '/tmp/'  , '%TEMP%\\'        ) p_temp_path,
  decode( '&OS.', 'Linux', 'rm '    , 'del '            ) p_del_cmd,
  decode( '&OS.', 'Linux', 'gedit ' , '"notepad++.exe"' ) p_txt_editor
from v$instance
/

alter session SET nls_date_format='dd/mm/yyyy'
/

SET &p_new_prompt.

GET temp.sql NOLIST
.

-- Used by Trusted Oracle
COLUMN ROWLABEL format A15

-- Used for the SHOW ERRORS command
COLUMN LINE/COLUMN format A8
COLUMN ERROR    format A65  WORD_WRAPPED

-- Used for the SHOW SGA command
COLUMN name_col_plus_show_sga format a24

-- Defaults for SHOW PARAMETERS
COLUMN name_col_plus_show_param format a36 heading NAME
COLUMN value_col_plus_show_param format a50 heading VALUE

-- Defaults for SET AUTOTRACE EXPLAIN report
COLUMN other_plus_exp ON       FORMAT   a44
COLUMN other_tag_plus_exp ON   FORMAT   a30
COLUMN object_node_plus_exp ON FORMAT   a30
COLUMN plan_plus_exp ON        FORMAT   a95
COLUMN parent_id_plus_exp ON   FORMAT   990 HEADING  'p'
COLUMN id_plus_exp ON          FORMAT   990 HEADING  'i'

COLUMN name                format a50
COLUMN member              format a100
COLUMN filename            format a50
COLUMN file_name           format a50
COLUMN object_name         format a30
COLUMN sessao              format a10
COLUMN username            format a20
COLUMN event               format a30
COLUMN rv_domain           format a30
COLUMN rv_low_value        format a30
COLUMN rv_high_value       format a5
COLUMN rv_abbreviation     format a10
COLUMN rv_meaning          format a30
COLUMN data_type           format a10
COLUMN tipo                format a15
COLUMN notnull             format a7
COLUMN coluna              format a30
COLUMN comments            format a80
COLUMN JOB_NAME            format a30

DEFINE _editor=&p_txt_editor.

SET editfile &p_temp_path.sqlplus.sql
SET TERMOUT ON HEAD ON DEFINE "&" FEEDBACK 6
SET TRIMSPOOL  ON
SET numwidth    9
SET pagesize  200
SET linesize  400
SET long     4000

rem COLUMN P_TEMP_PATH CLEAR
COLUMN P_DEL_CMD CLEAR
COLUMN P_TXT_EDITOR CLEAR
COLUMN P_NEW_PROMPT CLEAR
