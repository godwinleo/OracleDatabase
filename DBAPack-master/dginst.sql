SET VERIFY OFF SERVEROUT ON FEEDBACK OFF UNDERLINE '~' LINES 200

col db_name format a9
col inst_name format a9
col host_name format a12
col db_unique_name format a14
col status format a20
col st1 format a14 heading "Startup Time"
col st3 format a12 heading "Running Time"
col st2 format a14 heading "System Date" noprint
col st4 format a12 heading "Running Secs" noprint
col scn format a20 just r

PROMPT
PROMPT ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~

select
   i.inst_id
  ,d.name db_name
  ,d.db_unique_name
  ,i.instance_name inst_name
  ,case when instr(i.host_name, '.') > 0 then substr( i.host_name, 1, instr(i.host_name, '.') -1 ) else i.host_name end host_name
  ,to_char( i.startup_time, 'dd/mm/yy hh24"h"mi' ) st1
  ,to_char( sysdate, 'dd/mm/yy hh24"h"mi' ) st2
  ,lpad( to_char( trunc(sysdate,'YEAR') + (sysdate-i.startup_time-1),
        decode( trunc( sysdate-i.startup_time, 0 ), 0, '"0d "hh24"h"mi', 'fmddd"d "fmhh24"h"mi' ) ), 12, ' ' ) st3
  ,to_char( (sysdate-i.startup_time)*24*60*60, '999g999g990' ) st4
  ,to_char(d.current_scn, '999g999g999g999g999') SCN
from gv$instance i 
join gv$database d on (i.inst_id = d.inst_id)
ORDER BY i.INST_ID        
/

select 
   i.inst_id
  ,i.status || ' ' || d.open_mode status
  ,i.logins
  ,i.archiver
  ,d.database_role db_role
  ,d.protection_mode
  ,d.switchover_status 
from gv$instance i 
join gv$database d on (i.inst_id = d.inst_id)
ORDER BY i.INST_ID        
/


SELECT INST_ID, PROCESS, STATUS, THREAD#, SEQUENCE#
FROM GV$MANAGED_STANDBY
ORDER BY INST_ID;

SELECT inst_id, DEST_ID, STATUS, RECOVERY_MODE, ARCHIVED_THREAD#, ARCHIVED_SEQ#, APPLIED_THREAD#, APPLIED_SEQ#, ERROR
FROM GV$ARCHIVE_DEST_STATUS 
WHERE STATUS <> 'INACTIVE';


col value format a15
col name format a30

select * from v$dataguard_stats;

PROMPT
SET FEEDBACK 6 UNDERLINE '-'

PROMPT ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
PROMPT

col st1 clear
col st2 clear
col st3 clear
col st4 clear
