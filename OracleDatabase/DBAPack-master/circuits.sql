PROMPT
DEFINE USU_SECAD = "'SAE', 'FILIACAO_WEB', 'TITULONET', 'SAECERTIDAO','LOCAL_VOTACAO_WEB'"

--DEBUG DE PROCESSOS QUE NÃO TEM SESSÃO
SELECT P.SPID, P.ADDR, S.PADDR SESPROCESS, B.PADDR BGPROCESS, COUNT(S.PADDR) SESSOES
FROM V$PROCESS P, V$SESSION S, V$BGPROCESS B
WHERE P.ADDR = S.PADDR(+)
AND   P.ADDR = B.PADDR(+)
GROUP BY P.SPID, P.ADDR, S.PADDR, B.PADDR
ORDER BY SESSOES
.


SET VERIFY OFF SERVEROUT ON FEEDBACK OFF UNDERLINE '~' LINES 142

col st1 format a14 heading "Startup Time"
col st2 format a14 heading "System Date"
col st3 format a12 heading "Running Time"
col st4 format a12 heading "Running Secs"

COL LISTENER         FORMAT            A15 Head "Listener"
COL USERNAME         FORMAT            A30 Head "Usuário"
COL SESSOES          FORMAT        9999999 Head "Sessões|Total"
COL SESSOES_ATIVAS   FORMAT        9999999 Head "Sessões|Ativas"
COL SESSOES_INATIVAS FORMAT        9999999 Head "Sessões|Inativas"
COL SESSOES_SNIPED   FORMAT        9999999 Head "Sessões|Sniped"
COL SESSOES_KILLED   FORMAT        9999999 Head "Sessões|Killed"

Col TYPE             Format            A17 Head "Process|Queue"
Col QTOTAL           Format 99g999G999G999 Head "Enqueued|Packets"
Col QWAIT            Format 99g999G999G999 Head "Wait|Time(ms)"
Col AVGRES           Format       9990D000 Head "Agv Wait|Time(ms)"
Col QIDLE            Format 99g999G999G999 Head "Idle|Time(s)"
Col QBUSY            Format 99g999G999G999 Head "Busy|Time(s)"
Col PCT_BUSY         Format        9990D00 Head "Pct|Busy"
Col QTD_PRC          Format           9999 Head "Running|Processes"

Col MC               Format           9999 Head "Max|Circuits"
Col MS               Format           9999 Head "Max|S.Sessions"
Col SH               Format           9999 Head "Max|S.Servers"
Col MSS              Format           9999 Head "Limite|S.Servers"
Col SS               Format        999g999 Head "Started|S.Servers"
Col ST               Format        999g999 Head "Terminated|S.Servers"

select
  to_char( startup_time, 'dd/mm/yy hh24"h"mi' ) st1,
  to_char( sysdate, 'dd/mm/yy hh24"h"mi' ) st2,
  lpad( to_char( trunc(sysdate,'YEAR') + (sysdate-startup_time-1),
        decode( trunc( sysdate-startup_time, 0 ), 0, 'fm" 0d "hh24"h"mi', 'fm""ddd"d "hh24"h"mi' ) ), 12, ' ' ) st3,
  to_char( (sysdate-startup_time)*24*60*60, '999g999g990' ) st4
from v$instance;

PROMPT

DECLARE

 cValue VARCHAR2(8000);
 nPosI number := 1;
 nPosF number := 0;

BEGIN

  dbms_output.put_line( 'Dispatchers Configurados ' );
  dbms_output.put_line( lpad( '~', 77, '~' ) );

  SELECT distinct TRIM(VALUE) || ',' INTO cValue
  FROM V$PARAMETER WHERE NAME in ( 'mts_dispatchers', 'dispatchers' );

  LOOP

    nPosF := instr(substr( cValue, nPosI), ',' );
    dbms_output.put_line( Trim( substr( cValue, nPosI, nPosF-1)) );
    nPosI := nPosI + nPosF;
    exit when nPosI > length( cValue ) ;

  END LOOP;

END;
/

SET NULL TOTAL
BREAK ON LISTENER SKIP 1

WITH Nomes AS
(
  SELECT
    nvl(username, 'BackGround') username,
    machine/* , program, server */,
    replace( initcap
    (
      CASE
        WHEN USERNAME IS NULL THEN 'BACKGROUND'
        WHEN USERNAME =  'CAD_CONS1' THEN 'TELNET'
        WHEN substr(username,3,2) = 'BR' THEN 'Titulo_Online'
        WHEN USERNAME IN ( &USU_SECAD ) THEN decode(lower(substr(machine,1,4)),'tse\','sae.tse',username||'.'||machine )
        ELSE USERNAME END
     ),'_','') eqNome
  FROM
    v$session
  --ORDER BY 1
),
Circuitos AS
(
  SELECT
    decode( grouping(d.conf_indx) + grouping( sd.eqnome ), 2, 99, nvl(d.conf_indx+1,0) )  LISTENER
   ,decode( grouping(d.conf_indx) + grouping( sd.eqnome ), 2, 1, 1, 1, 0 )  ORDEM
   ,decode( grouping(sd.EqNome), 0, nvl(sd.EqNome, 'Outros' ), 'Total' ) USERNAME
   ,count(*) SESSOES
   ,sum( decode( s.status, 'ACTIVE'  , 1, 0 ) ) SESSOES_ATIVAS
   ,sum( decode( s.status, 'INACTIVE', 1, 0 ) ) SESSOES_INATIVAS
   ,sum( decode( s.status, 'SNIPED'  , 1, 0 ) ) SESSOES_SNIPED
   ,sum( decode( s.status, 'KILLED'  , 1, 0 ) ) SESSOES_KILLED
  FROM
   (
     SELECT distinct nomes.username, nomes.eqnome, nomes.machine
     FROM nomes, (select eqnome from nomes group by eqnome having count(*) > 4 ) g
     WHERE nomes.eqnome = g.eqnome
   ) sd, v$session s, v$circuit c, v$dispatcher d
  WHERE nvl(s.username, 'BackGround' ) = sd.username(+)
  AND   s.machine = sd.machine(+)
  AND   s.saddr = c.saddr(+) and c.dispatcher = d.paddr(+)
  GROUP BY ROLLUP( d.conf_indx, sd.eqnome )
)
SELECT
  decode( c.listener, 99, 'Total', 0, 'Dedicado', 'Dispatcher' ) LISTENER
 ,c.username
 ,c.sessoes
 ,c.sessoes_ativas
 ,c.sessoes_inativas
 ,c.sessoes_sniped
 ,c.sessoes_killed
FROM
  CIRCUITOS C
ORDER BY c.listener, c.ordem, c.sessoes
/

PROMPT
CLEAR BREAK

COL LISTENER         CLEAR
COL USERNAME         CLEAR
COL SESSOES          CLEAR
COL SESSOES_ATIVAS   CLEAR
COL SESSOES_INATIVAS CLEAR
COL SESSOES_SNIPED   CLEAR
COL SESSOES_KILLED   CLEAR

REM SET TERMOUT OFF
REM Col ttime NEW_VALUE ttime
REM select to_char( sysdate, 'dd/mm hh24:mi:ss' ) ttime from dual;
REM SET TERMOUT ON

REM PROMPT
REM PROMPT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
REM PROMPT SHARED SERVER MODEL (&ttime.)
REM PROMPT Referência: AvgWaitTime 0,10ms ~ 0,30ms | BusyTime < 50%
REM PROMPT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SELECT
  PS.TYPE TYPE
 ,QS.QTOTAL QTOTAL
 ,QS.QWAIT QWAIT
 ,ROUND( DECODE(QS.QWAIT, 0, 0, QS.QWAIT/QS.QTOTAL ), 2 ) AVGRES
 ,PS.IDLE QIDLE
, PS.BUSY QBUSY
, ROUND( PS.BUSY/(PS.BUSY+PS.IDLE) * 100, 2 ) PCT_BUSY
, PS.PROCESS QTD_PRC
FROM
(
  SELECT
    'Shared Server' TYPE
   ,SUM(Q.TOTALQ) QTOTAL
   ,SUM(Q.WAIT)*10 QWAIT
  FROM V$QUEUE Q
  WHERE Q.TYPE = 'COMMON'
  UNION ALL
  SELECT
    decode( d.conf_indx, null, 'Dedicado', 'Dispatcher' ) TYPE
   ,SUM(Q.TOTALQ) QTOTAL
   ,SUM(Q.WAIT)*10 QWAIT
  FROM V$QUEUE Q, V$DISPATCHER D
  WHERE Q.TYPE = 'DISPATCHER'
  AND  Q.PADDR = D.PADDR
  AND  D.ACCEPT = 'YES'
  GROUP BY
    decode( d.conf_indx, null, 'Dedicado', 'Dispatcher' )
) QS,
(
  SELECT
    'Shared Server' TYPE
   ,TRUNC(SUM(BUSY)/100) BUSY, TRUNC(SUM(IDLE)/100) IDLE, COUNT(*) PROCESS
  FROM V$SHARED_SERVER WHERE STATUS <> 'QUIT'
  UNION ALL
  SELECT
   decode( d.conf_indx, null, 'Dedicado', 'Dispatcher' ) TYPE
  ,TRUNC(SUM(D.BUSY)/100) BUSY, TRUNC(SUM(D.IDLE)/100) IDLE, COUNT(*) PROCESS
  FROM V$DISPATCHER D, (select value||'listener=Port 1521)' par from v$parameter where name='dispatchers' ) p
  WHERE D.ACCEPT = 'YES'
  GROUP BY
    decode( d.conf_indx, null, 'Dedicado', 'Dispatcher' )
) PS
WHERE QS.TYPE = PS.TYPE
/

SELECT
  maximum_connections mc
 ,maximum_sessions    ms
 ,servers_highwater sh
 ,to_number((select value from v$parameter where name = 'max_shared_servers' )) mss
 ,servers_started ss
 ,servers_terminated st
FROM V$SHARED_SERVER_MONITOR
/

SET NULL ''

SELECT STATUS, COUNT(*) "#SS" FROM V$SHARED_SERVER GROUP BY STATUS
/

col sessao   format a12 jus r head "Sessao"
col spid     format a5 head "SPId"

col username format a18 head "Usuario"
col machine  format a25 head "Machine"
col status   format a22 head "Status"
col program  format a50 head "Programa"
col requests format 999g999g999
col "%BUSY" format 990D00

select /*+rule*/
   LPAD( ''''||S.SID||','||S.SERIAL#||'''',12,' ') sessao, p.spid, s.username
  ,s.status || ' ' || ss.status status
  ,s.machine, s.program
from
  v$session s, v$circuit c, v$shared_server ss, v$process p
where s.saddr = c.saddr and c.circuit = ss.circuit
and ss.paddr = p.addr
and ss.status in ( 'WAIT(RECEIVE)', 'EXEC', 'WAIT(SEND)' )
order by 4,6
-- and s.status <> 'ACTIVE'
/

REM PROMPT
REM PROMPT SHARED SERVER STATUS
REM PROMPT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

select
   decode( grouping(s.program), 1, 'TOTAL', NVL(s.program, 'UNKNOW' ) ) program
  ,s.status || ' ' || ss.status status
  ,count(*) qtde
  ,sum(ss.requests) requests
  ,round(100*(sum(ss.busy)/sum(ss.busy+ss.idle)),2) "%BUSY"
from
  v$session s,  v$circuit c, v$shared_server ss
where s.saddr = c.saddr and c.circuit = ss.circuit
group by grouping sets( (s.program, s.status, ss.status), () )
order by s.program, s.status, ss.status


PROMPT
SET FEEDBACK 6 VERIFY ON NULL '' UNDERLINE '-'
COL PROGRAM          CLEAR
UNDEFINE USO_SECAD

