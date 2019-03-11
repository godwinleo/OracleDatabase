set serveroutput on
set long 1000000000
col reco for a187
set lines 195
set pages 400
set arraysize 5000

accept taskname char PROMPT 'Tuning Task name :'

select DBMS_SQLTUNE.report_TUNING_TASK('&taskname') reco
from dual

/
