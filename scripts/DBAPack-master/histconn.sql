SET LINES 200 PAGES 100 FEED OFF VERIFY OFF

VAR N NUMBER
COL COL1 NEW_VALUE extenso
COL COL2 NEW_VALUE un

PROMPT
PROMPT INTERVALO: "s" para histograma em segundos ou "m" para histograma em minutos
SET TERMOUT OFF
BEGIN
  IF lower('&1.') = 's' THEN
    :N := 60;
  ELSE
    :N :=  1;
  END IF;
END;
/
SELECT
  DECODE( :n, 60, 'segundos', 'minutos') col1,
  DECODE( :n, 60, 's', 'm') col2
FROM DUAL
/
SET TERMOUT ON
PROMPT USUÁRIO: Digite o NOME ou %PARTE%
SET TERMOUT OFF
DEFINE p_user=&2.
SET TERMOUT ON

col "Hora Atual"    format a15
col username        format a45 Head "User.Machine"
col event           format a35 Head "Evento de Espera" trunc
COL sess            format a25 Head " Sid,Serial#,@I  SPId Svr"
COL seconds_in_wait format  999G999G999 HEAD "Wait(s)"

col sessoes format a9     head "Total|Sessões"
col "00-05" format a7     head "00&un.-05&un.|At/Cr"
col "05-10" format a7     head "05&un.-10&un.|At/Cr"
col "10-15" format a7     head "10&un.-15&un.|At/Cr"
col "15-20" format a7     head "15&un.-20&un.|At/Cr"
col "20-30" format a7     head "20&un.-30&un.|At/Cr"
col "30-45" format a7     head "30&un.-45&un.|At/Cr"
col "45-60" format a7     head "45&un.-60&un.|At/Cr"
col " >=60" format a7     head " >= 60&un.|At/Cr"

PROMPT
PROMPT HISTOGRAMA DE CONEXÕES (filtrando usuário &p_user.)

select to_char(sysdate, 'dd/mm/yy hh24:mi' ) "Hora Atual"
from dual
/

PROMPT
PROMPT HISTOGRAMA POR HORARIO DE CRIACAO (tempo em &extenso.)
select
   trim(lower(username) ||'.'||
   lower(decode(instr(machine, '.'), 0, replace(machine, 'REDECAMARA\',''), substr(machine, 1, instr(machine, '.')-1))) ) username
 , sum( decode( trunc( (sysdate-logon_time)/( 5/(60*24*:n)), 0 ), 0, decode( status, 'ACTIVE', 1, 0), 0 ) ) || '/' ||
   sum( decode( trunc( (sysdate-logon_time)/( 5/(60*24*:n)), 0 ), 0, 1, 0 ) ) "00-05"
 , sum( decode( trunc( (sysdate-logon_time)/( 5/(60*24*:n)), 0 ), 1, decode( status, 'ACTIVE', 1, 0), 0 ) ) || '/' ||
   sum( decode( trunc( (sysdate-logon_time)/( 5/(60*24*:n)), 0 ), 1, 1, 0 ) ) "05-10"
 , sum( decode( trunc( (sysdate-logon_time)/( 5/(60*24*:n)), 0 ), 2, decode( status, 'ACTIVE', 1, 0), 0 ) ) || '/' ||
   sum( decode( trunc( (sysdate-logon_time)/( 5/(60*24*:n)), 0 ), 2, 1, 0 ) ) "10-15"
 , sum( decode( trunc( (sysdate-logon_time)/( 5/(60*24*:n)), 0 ), 3, decode( status, 'ACTIVE', 1, 0), 0 ) ) || '/' ||
   sum( decode( trunc( (sysdate-logon_time)/( 5/(60*24*:n)), 0 ), 3, 1, 0 ) ) "15-20"
 , sum( decode( trunc( (sysdate-logon_time)/(10/(60*24*:n)), 0 ), 2, decode( status, 'ACTIVE', 1, 0), 0 ) ) || '/' ||
   sum( decode( trunc( (sysdate-logon_time)/(10/(60*24*:n)), 0 ), 2, 1, 0 ) ) "20-30"
 , sum( decode( trunc( (sysdate-logon_time)/(15/(60*24*:n)), 0 ), 2, decode( status, 'ACTIVE', 1, 0), 0 ) ) || '/' ||
   sum( decode( trunc( (sysdate-logon_time)/(15/(60*24*:n)), 0 ), 2, 1, 0 ) ) "30-45"
 , sum( decode( trunc( (sysdate-logon_time)/(15/(60*24*:n)), 0 ), 3, decode( status, 'ACTIVE', 1, 0), 0 ) ) || '/' ||
   sum( decode( trunc( (sysdate-logon_time)/(15/(60*24*:n)), 0 ), 3, 1, 0 ) ) "45-60"
 , sum( decode( trunc( (sysdate-logon_time)/(60/(60*24*:n)), 0 ), 0, 0, decode( status, 'ACTIVE', 1, 0) ) ) || '/' ||
   sum( decode( trunc( (sysdate-logon_time)/(60/(60*24*:n)), 0 ), 0, 0, 1 ) ) " >=60"
 , sum( decode( status, 'ACTIVE', 1, 0) ) || '/' || count(*) sessoes
from gv$session
WHERE USERNAME like upper('&p_user.') AND STATUS <> 'KILLED'
group by
   trim(lower(username) ||'.'||
   lower(decode(instr(machine, '.'), 0, replace(machine, 'REDECAMARA\',''), substr(machine, 1, instr(machine, '.')-1))) )
order by 1
/
col sessoes format 999999 head "Total|Sessões"
col "00-05" format 999999 head "00&un.-05&un."
col "05-10" format 999999 head "05&un.-10&un."
col "10-15" format 999999 head "10&un.-15&un."
col "15-20" format 999999 head "15&un.-20&un."
col "20-30" format 999999 head "20&un.-30&un."
col "30-45" format 999999 head "30&un.-45&un."
col "45-60" format 999999 head "45&un.-60&un."
col " >=60" format 999999 head " >= 60&un."

BREAK ON REPORT
COMPUTE SUM OF SESSOES ON REPORT

PROMPT
PROMPT HISTOGRAMA POR TEMPO DE INATIVIDADE (tempo em &extenso.)
SELECT
   lower(s.username) ||'.'||
   lower(decode(instr(s.machine, '.'), 0, replace(S.machine, 'REDECAMARA\',''), substr(s.machine, 1, instr(s.machine, '.')-1)))||
   decode( s.status, 'ACTIVE','(ACTIVE)', '' ) username
 , W.EVENT
 , SUM( decode( trunc( W.SECONDS_IN_WAIT/(60/:n)/05, 0 ), 0, 1, 0 ) ) "00-05"
 , SUM( decode( trunc( W.SECONDS_IN_WAIT/(60/:n)/05, 0 ), 1, 1, 0 ) ) "05-10"
 , SUM( decode( trunc( W.SECONDS_IN_WAIT/(60/:n)/05, 0 ), 2, 1, 0 ) ) "10-15"
 , SUM( decode( trunc( W.SECONDS_IN_WAIT/(60/:n)/05, 0 ), 3, 1, 0 ) ) "15-20"
 , SUM( decode( trunc( W.SECONDS_IN_WAIT/(60/:n)/10, 0 ), 2, 1, 0 ) ) "20-30"
 , SUM( decode( trunc( W.SECONDS_IN_WAIT/(60/:n)/15, 0 ), 2, 1, 0 ) ) "30-45"
 , SUM( decode( trunc( W.SECONDS_IN_WAIT/(60/:n)/15, 0 ), 3, 1, 0 ) ) "45-60"
 , SUM( decode( trunc( W.SECONDS_IN_WAIT/(60/:n)/60, 0 ), 0, 0, 1 ) ) " >=60"
 , COUNT(*) sessoes
FROM gV$SESSION S INNER JOIN gV$SESSION_WAIT W ON (S.SID=W.SID and s.inst_id=w.inst_id)
WHERE USERNAME like upper('&p_user.') AND STATUS <> 'KILLED'
GROUP BY
   lower(s.username) ||'.'||
   lower(decode(instr(s.machine, '.'), 0, replace(S.machine, 'REDECAMARA\',''), substr(s.machine, 1, instr(s.machine, '.')-1)))||
   decode( s.status, 'ACTIVE','(ACTIVE)', '' )
   ,W.EVENT
order by 1
/

PROMPT
PROMPT INATIVOS A MAIS DE MEIA HORA
SELECT /*+RULE*/
   LPAD( ''''||S.SID||','||S.SERIAL#||',@'||S.INST_id||'''',15,' ') || LPAD( TO_NUMBER(P.SPID), 6, ' ' ) ||
   DECODE(S.SERVER, 'DEDICATED', ' DED', ' MTS' )  SESS
 , lower(s.username) ||'.'||
   lower(decode(instr(s.machine, '.'), 0, replace(S.machine, 'REDECAMARA\',''), substr(s.machine, 1, instr(s.machine, '.')-1)))||
   decode( s.status, 'ACTIVE','(ACTIVE)', '' ) username
 , W.SECONDS_IN_WAIT
 , W.EVENT
FROM gV$SESSION S
INNER JOIN gV$SESSION_WAIT W ON (S.SID=W.SID and s.inst_id=w.inst_id)
INNER JOIN gV$PROCESS P ON (S.PADDR = P.ADDR and s.inst_id=p.inst_id)
WHERE S.USERNAME like upper('&p_user.') AND S.STATUS <> 'KILLED'
AND   W.SECONDS_IN_WAIT > 1800
ORDER BY W.SECONDS_IN_WAIT
/


PROMPT
SET FEED 6 VERIFY ON
CLEAR BREAK
CLEAR COMPUTE
COL USERNAME CLEAR
COL SESS CLEAR
COL EVENT CLEAR
COL "Hora Atual" CLEAR
COL SECONDS_IN_WAIT CLEAR
UNDEFINE 1 2 p_user extenso un

