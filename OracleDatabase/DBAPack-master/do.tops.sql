-- X$KSUSE    <--> V$SSESION
-- X$KGLLK    <--> V$OPEN_CURSOR
-- X$KSUPR    <--> V$PROCESS
-- X$KSUSD    <--> V$STATNAME
-- X$KSUSESTA <--> V$SESSTAT

DEFINE P1=&1.
DEFINE P2=&2.
DEFINE N_TOPS=&3.  -- APENAS OS TOP
DEFINE BKGRD=&4.   -- mostrar processos de background on não
DEFINE ATIVOS=&5.
DEFINE GLOBAL="YES"  -- usar GV$ 

COL RANK         FORMAT             A4 HEAD "Rank"
COL STATUS       FORMAT             A6 HEAD "Status"
COL LOGON_TIME   FORMAT            A11 HEAD "Login"
COL CHAMADA      FORMAT            A11 HEAD "Chamada"
COL LREADS       FORMAT 999G999G999G990 HEAD "Logical Reads"
COL WAITS        FORMAT            A26 HEAD "Wait"
COL SQL_ID       FORMAT            A13 HEAD "Sql ID"
COL SQL_TEXT     FORMAT            A90 HEAD "Sql Statement" TRUNC
COL MACHINE      FORMAT            A23 HEAD "Machine"       TRUNC
COL PROGRAMA     FORMAT            A15 HEAD "Programa"      TRUNC
COL CLI_ID       FORMAT            A20 HEAD "Cliente"     TRUNC

COLUMN cls_where new_value cls_where NOPRINT;
COLUMN cls_no_background new_value cls_no_background NOPRINT;
COLUMN cls_where_active new_value cls_where_active NOPRINT;
COLUMN cls_stats new_value n_stat NOPRINT;
COLUMN v_pagesize new_value v_pagesize NOPRINT;

COLUMN v_complemento new_value v_complemento NOPRINT;

COLUMN p_gv new_value p_gv NOPRINT;
COLUMN p_s_inst new_value p_s_inst NOPRINT;
COLUMN p_p_inst new_value p_p_inst NOPRINT;
COLUMN p_w_inst new_value p_w_inst NOPRINT;
COLUMN p_scope  new_value p_scope NOPRINT;

--COL SPID       FORMAT          99999 HEAD "SPId" print
--COL DREADS     FORMAT    999G999G990 HEAD "Disk Reads"
--COL SERVER     FORMAT            A1  HEAD "M"

SET VERIFY OFF TERMOUT OFF LINES 320 DEFINE ON FEEDBACK OFF

SELECT
  decode( '&BKGRD.', 'YES', '', 'AND S.TYPE <> ''BACKGROUND'' ' ) cls_no_background
 ,decode( '&GLOBAL.', 'YES', 'gv', 'v' ) p_gv 
 ,decode( '&GLOBAL.', 'YES', 's.inst_id', '''*''' ) p_s_inst
 ,decode( '&GLOBAL.', 'YES', 'p.inst_id', '''*''' ) p_p_inst
 ,decode( '&GLOBAL.', 'YES', 'w.inst_id', '''*''' ) p_w_inst
 ,decode( '&GLOBAL.', 'YES', 'Cluster', 'Single Instance' ) p_scope
 ,decode( '&ATIVOS.', 'YES', ' ativos)', ')' ) v_complemento
 ,&n_tops. + 8 v_pagesize
 ,case version 
     when '12.1.0.2.0' then '14'    -- estatisticas listadas no 12.1.0.2
     when '11.2.0.2.0' then '66,70' -- estatisticas listadas no 11.2.0.2
     when '11.2.0.1.0' then '63,67' -- estatisticas listadas no 11.2.0.1
     else '9'                       -- estatisticas listadas no 10g e anteriores 
  end cls_stats
FROM v$instance
/

VAR B1 VARCHAR2(  130 );
VAR B2 VARCHAR2(  130 );

VAR V1 VARCHAR2( 200 );
VAR V2 VARCHAR2( 200 );

BEGIN

  :B1 := '&P1.';
  :B2 := '&P2.';

  :V1 := '';
  :V2 := '';

  IF INSTR( '0123456789', SUBSTR( :B1, 1, 1 )) > 0 THEN
    :V1 := 'AND S.SID IN (' || :B1 || ')';
  ELSIF SUBSTR( :B1, 1, 1 ) = '#' THEN
    :V1 := 'AND (S.INST_ID,S.PADDR) IN ( SELECT INST_ID,P.ADDR FROM &p_gv.$PROCESS P WHERE P.SPID IN (' || SUBSTR( :B1, 2, LENGTH(:B1)) || '))';
  ELSIF SUBSTR( :B1, 1, 1 ) = '@' THEN
    :V1 := 'AND LOWER(S.MACHINE) LIKE '''||SUBSTR( LOWER(:B1), 2, LENGTH(:B1))||'''';
  ELSIF SUBSTR( :B1, 1, 1 ) = '*' THEN
    :V1 := 'AND LOWER(S.PROGRAM) LIKE '''||SUBSTR( LOWER(:B1), 2, LENGTH(:B1))||'''';
  ELSIF :B1 = '%' THEN
    :V1 := '';
  ELSIF :B1 IS NOT NULL THEN
    :V1 := 'AND TRIM(UPPER(SUBSTR(DECODE(S.USERNAME, NULL, SUBSTR(P.PROGRAM,INSTR(P.PROGRAM,''('')+1,4), S.USERNAME),1,24))) LIKE UPPER( '''||:B1||''' )';
                               
  END IF;
  
  IF :B2 = '1' THEN
    :V2 := 'AND s.status = ''ACTIVE''';
  ELSIF :B2 = '2' THEN
    :V2 := 'AND s.status = ''KILLED''';
  ELSE
    :V2 := '';
  END IF;

END;
/

SELECT 
  :V1 cls_where
 ,:V2 cls_where_active
FROM DUAL
/

SET TERMOUT ON PAGES &v_pagesize.;

COL USERNAME FORMAT A50 HEAD "TOP SESSIONS (&N_TOPS. primeiros&v_complemento.|&p_scope. - Background: &bkgrd.|| Sid,Serial#,@I  SPId Svr OraUser" TRUNC

REM PROMPT
REM PROMPT DEBUG WHERE        : &CLS_WHERE.
REM PROMPT DEBUG WHERE ACTIVE : &CLS_WHERE_ACTIVE.
REM PROMPT DEBUG BACKGROUND   : &CLS_NO_BACKGROUND.

set head off 
COL HH FORMAT A50
SELECT '     Hora Atual: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS' ) HH
FROM DUAL
/
set head on

WITH TOP_SESSIONS AS
(
  SELECT 
     &p_s_inst. INST, S.SID, S.SERIAL# SERIAL, S.STATUS, S.SERVER, P.SPID, S.OSUSER, S.CLIENT_IDENTIFIER
    ,TO_CHAR( S.LOGON_TIME, 'DD/MM HH24:MI' ) LOGON_TIME
    ,LOWER(SUBSTR(S.MACHINE,1,23)) MACHINE, S.TYPE, SS.VALUE LREADS
    ,S.CLIENT_INFO, TO_CHAR( SYSDATE - (S.LAST_CALL_ET/86400), 'DD/MM HH24:MI' ) CHAMADA
    ,S.PROGRAM PROGRAMA, S.PADDR, S.SQL_ID, S.SQL_ADDRESS
    ,SUBSTR(DECODE(S.USERNAME, NULL, SUBSTR(P.PROGRAM,INSTR(P.PROGRAM,'(')+1,4), S.USERNAME),1,24) USERNAME
  FROM &p_gv.$SESSION S
  JOIN( SELECT &p_s_inst. INST, S.SID, SUM(VALUE) VALUE 
        FROM &p_gv.$SESSTAT S WHERE S."STATISTIC#" in (&N_STAT.) 
        GROUP BY &p_s_inst., SID ) SS
    ON (S.SID = SS.SID  AND &p_s_inst. = SS.INST)
  LEFT JOIN &p_gv.$PROCESS P
    ON (S.PADDR = P.ADDR AND &p_s_inst. = &p_p_inst.)
  WHERE 1 = 1
  &CLS_WHERE.
  &CLS_WHERE_ACTIVE.
  &CLS_NO_BACKGROUND
  and rownum <= &N_TOPS. 
  ORDER BY SS.VALUE DESC 
--FETCH FIRST &N_TOPS. ROWS ONLY
),
RANKED_SESSIONS AS
(
  SELECT 
    LPAD(ROWNUM, 3, ' ' ) || ':' RANK
   ,TS.* 
  FROM TOP_SESSIONS TS
) 
SELECT 
   SE.RANK
  ,LPAD( ''''||SE.SID||','||SE.SERIAL||',@'||SE.INST||'''',15,' ') || LPAD( TO_NUMBER(SE.SPID), 6, ' ' ) ||
   DECODE(SE.SERVER, 'DEDICATED', ' DED ', ' MTS ' ) || SE.USERNAME ||
   DECODE( SE.CLIENT_INFO, NULL, '', '' /* CHR(10) || LPAD( ' ', 12, ' ' ) || SE.CLIENT_INFO */ ) USERNAME
  ,NVL( SE.CLIENT_IDENTIFIER, LOWER(SE.OSUSER) ) CLI_ID
  ,DECODE(SE.STATUS, 'INACTIVE', 'INACTV', SE.STATUS ) STATUS
  ,SE.LOGON_TIME
  ,SE.CHAMADA
  ,SE.SQL_ID
  ,SE.LREADS
  ,SUBSTR( W.EVENT, 1, 26 ) WAITS
  ,SE.MACHINE
  ,SE.PROGRAMA
  ,REPLACE(REPLACE( ST1.SQL_TEXT || ST2.SQL_TEXT, CHR(13), '' ), 10, ' ' ) SQL_TEXT
FROM RANKED_SESSIONS SE
LEFT JOIN &p_gv.$SESSION_WAIT W ON (W.SID=SE.SID AND &p_w_inst. = SE.INST)
LEFT JOIN &p_gv.$SQLTEXT ST1 ON ST1.SQL_ID = SE.SQL_ID AND ST1.PIECE = 0 AND ST1.ADDRESS = SE.SQL_ADDRESS
LEFT JOIN &p_gv.$SQLTEXT ST2 ON ST2.SQL_ID = SE.SQL_ID AND ST2.PIECE = 1 AND ST2.ADDRESS = SE.SQL_ADDRESS
ORDER BY SE.RANK 
/

PROMPT
SET VERIFY ON FEEDBACK 6;

UNDEFINE P1 P2 N_TOPS BKGRD ATIVOS
UNDEFINE 1 2 3 4 5

UNDEFINE CLS_WHERE;
UNDEFINE CLS_WHERE_ACTIVE;
UNDEFINE p_gv p_s_inst p_p_inst p_w_inst n_stat v_pagesize;

COLUMN cls_where CLEAR;
COLUMN cls_where_active CLEAR;

--COL status CLEAR;
--COL spid CLEAR;

COL username CLEAR;
COL machine  CLEAR;
COL programa CLEAR;
COL sql_text CLEAR;
COL lreads   CLEAR;
COL STATUS   CLEAR;
COL WAITS    CLEAR;
COL RANK     CLEAR;
COL SQL_ID   CLEAR;