SET FEED 10 LINES 170

col sid for 99999
col username format a20

var bdia  number;
var btime number;
var bdone number;

var edia  number;
var etime number;
var done  number;
var total number;

var esttime number;

col status format a15
col username format a30 heading "Username"
col st1 format a14 heading "Startup Time"
col st2 format a14 heading "System Date" noprint
col st3 format a12 heading "Running Time"
col st4 format a12 heading "Running Secs" noprint

define v1=0
define v2=0

col undoblocksdone new_value v1
col undoblockstotal new_value v2

select
  to_char( startup_time, 'dd/mm/yy hh24"h"mi' ) st1,
  to_char( sysdate, 'dd/mm/yy hh24"h"mi' ) st2,
  lpad( to_char( trunc(sysdate,'YEAR') + (sysdate-startup_time-1),
        decode( trunc( sysdate-startup_time, 0 ), 0, '"0d "hh24"h"mi', 'fmddd"d "fmhh24"h"mi' ) ), 12, ' ' ) st3,
  to_char( (sysdate-startup_time)*24*60*60, '999g999g990' ) st4
from v$instance;

PROMPT
PROMPT ###### DADOS DE UNDO   ##########

WITH Blocos as
(
  SELECT 
     INST_ID
    ,to_char(BEGIN_TIME, 'dd/mm hh24:mi' ) BEGIN_TIME
    ,to_char(END_TIME, 'dd/mm hh24:mi' ) END_TIME
    ,to_char(TRUNC(SYSDATE) + (END_TIME - BEGIN_TIME), 'hh24:mi:ss' ) Intervalo
    ,UNDOBLKS
    ,ACTIVEBLKS ATIVOS
    ,UNEXPIREDBLKS UNEXPIRED
    ,EXPIREDBLKS EXPIRED
    ,ACTIVEBLKS+UNEXPIREDBLKS+EXPIREDBLKS TOTAL
  FROM GV$UNDOSTAT
  WHERE END_TIME>=SYSDATE-1/1440/6
  ORDER BY INST_ID
  --ORDER BY END_TIME DESC, INST_ID FETCH FIRST 3 ROWS ONLY
),
prop as
(
  SELECT MAX(BLOCK_SIZE) BLOCK_SIZE, 1048576 MEGA FROM DBA_TABLESPACES WHERE CONTENTS = 'UNDO'
)
SELECT
   B.INST_ID
  ,B.intervalo "Intervalo"
  ,ROUND(b.ativos * p.block_size / p.mega ) "Ativo"
  ,ROUND(b.unexpired * p.block_size / p.mega ) "Unexpired"
  ,ROUND(b.expired * p.block_size / p.mega ) "Expirado"
  ,LPAD( TO_CHAR( (b.total * p.block_size / p.mega ), 'fm999g999' ), 10, ' ' ) "InUse MB"
FROM BLOCOS B
CROSS JOIN PROP P
/

PROMPT
PROMPT ########## ATIVAS      ##########
SELECT
 (SELECT max(SID) FROM GV$SESSION S WHERE S.INST_ID = INST_ID AND S.SADDR = SES_ADDR) SID,
 (SELECT USERNAME FROM V$SESSION WHERE SADDR = SES_ADDR) USERNAME,
 XIDUSN USN, XIDSLOT SLOT, XIDSQN SEQUENCE, STATUS, START_TIME, USED_UBLK, USED_UREC, LOG_IO, PHY_IO, TRUNC( USED_UBLK * 8 / 1024 ) UNDO_MB
FROM GV$TRANSACTION
/

PROMPT ########## RECUPERANDO ##########

SELECT 
  inst_id, pid, usn, state
  , undoblockstotal "Total"
  , undoblockstotal-undoblocksdone "ToDo"
  , undoblocksdone "Done"
  , ROUND(UNDOBLOCKSDONE*100/UNDOBLOCKSTOTAL,2 ) "PercDone",
  case when cputime > 0 and undoblockstotal-undoblocksdone > 0 
    then to_char( SYSDATE+(((undoblockstotal-undoblocksdone) / (undoblocksdone / cputime)) / 86400), 'dd/mm hh24:mi' )
    else 'Done'
    end "Finish at" 
FROM gv$fast_start_transactions
/

set feed off serverout on verify off

declare
  dtime number;
  ddone number;
begin

  if :bdia is null then

    :bdia  := to_char( sysdate, 'j' );
    :btime := to_char( sysdate, 'sssss' );
    :bdone := &v1.;

  else

    :edia  := to_char( sysdate, 'j' );
    :etime := to_char( sysdate, 'sssss' );
    :done  := &v1.;
    :total := &v2.;

    dtime := (:edia*86400+:etime) - (:bdia*86400+:btime);
    ddone := :done - :done;

    :esttime := dtime * :total / ddone;

  end if;

end;
/

undefine v1 v2
set feed 6 serverout off verify off

col st1 clear
col st2 clear
col st3 clear
col st4 clear
