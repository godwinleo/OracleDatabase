col data new_value data

set termout off feed off verify off
select to_char(sysdate, 'yyyymmddhh24mi' ) data
from dual;

set termout on 
set feed 6 verify on

spool a:\baseline.edoc.&data..sql

@topedoc

@topstmt ext_smar%
 
spool off

