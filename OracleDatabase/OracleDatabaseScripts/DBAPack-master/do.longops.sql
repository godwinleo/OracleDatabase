SET SERVEROUT ON VERIFY OFF FEEDBACK OFF DEFINE ON LINES 115

COLUMN c_anded_clause new_value p_anded_clause NOPRINT;
COLUMN c_filtro new_value p_filtro NOPRINT;

SELECT
  'User='||UPPER('&&P1.%') || ' | ' ||
  DECODE( SUBSTR( '&&P2.', 1, 1 ),
  '0', '',
  '_', 'SQL HashValue = '||SUBSTR('&P2',2)|| ' | ',
       'SID IN (&P2)'|| ' | ' ) ||
  'A Partir de ' || TRUNC( SYSDATE - &P_DIAS. ) || ' | ' ||
  Decode( &p_perc., 100.0, 'Todas as Operações', 'Somente Operações em Andamento' ) c_filtro,
  DECODE( SUBSTR( '&&P2.', 1, 1 ),
       '0', 'AND 1 = 1',
       '_', 'AND SQL_HASH_VALUE = '||SUBSTR('&P2',2),
            'AND SID IN (&P2)' ) c_anded_clause, to_char( sysdate, 'dd/mm hh24:mi:ss' ) "Hora Atual"
FROM DUAL
/

PROMPT

DECLARE
  SQL_ATUAL VARCHAR2(100) := 'FA00FA';
  SERIAL_ATUAL NUMBER := -1;
  SID_ATUAL NUMBER    := -1;
  INST_ATUAL NUMBER   := -1;
  SEGUNDOS NUMBER     := 0;
  HEADER BOOLEAN      := TRUE;
CURSOR C1 IS
  SELECT
   RPAD( 'USERNAME = ' || USERNAME || ' ('||SID||','||SERIAL#||',@'||INST_ID||')', 45, ' ' ) "USER"
  ,RPAD( UPPER(OPNAME) , 33, ' ' ) OPNAME
  ,TO_CHAR(START_TIME, 'DD/MM HH24:MI' ) INI
  ,TO_CHAR(TRUNC(TIME_REMAINING/3600),'fm900')||':'||TO_CHAR(TO_DATE('1','J')+(MOD(TIME_REMAINING,3600)/86400),'MI:SS') RESTANTE
  ,TO_CHAR(TRUNC(ELAPSED_SECONDS/3600),'fm900')||':'||TO_CHAR(TO_DATE('1','J')+(MOD(ELAPSED_SECONDS,3600)/86400),'MI:SS') PASSADO
  ,TO_CHAR(SOFAR*100/DECODE(TOTALWORK, 0, 1, TOTALWORK), '990D00' ) PERCENTUAL
  ,SUBSTR( NVL(TARGET, TARGET_DESC), 1, 33 ) OBJETO
  ,RPAD( 'HASH_VALUE = '  || SQL_HASH_VALUE, 23, ' ' ) "HASH"
  --,RPAD( 'SQL ADDRESS = ''' || SQL_ADDRESS  || '''', 35, ' ') "SQL"
  ,RPAD( 'SQL ID = ''' || SQL_ID  || '''', 25 , ' ') "SQL"
  ,SQL_ADDRESS
  ,SQL_ID
  ,SERIAL#
  ,SID
  ,INST_ID
  ,ELAPSED_SECONDS
  FROM GV$SESSION_LONGOPS
  WHERE TRUNC( START_TIME ) >= TRUNC( SYSDATE - &P_DIAS. )
  AND START_TIME IS NOT NULL
  AND OPNAME IS NOT NULL
  AND USERNAME LIKE UPPER('&&P1.%')
  &p_anded_clause.
  AND (SQL_ADDRESS,sid,serial#,inst_id) IN
    (
      SELECT SQL_ADDRESS, sid, serial#,inst_id
      FROM GV$SESSION_LONGOPS
      WHERE SOFAR*100/DECODE(TOTALWORK, 0, 1, TOTALWORK) <= &P_PERC.
    )
  ORDER BY
    INST_ID, USERNAME, SERIAL#, SQL_ADDRESS, START_TIME;
BEGIN

  DBMS_OUTPUT.ENABLE( 5E+5 );

  DBMS_OUTPUT.PUT_LINE( '+------------------------------------------------------------------------------------------------------------' );
  DBMS_OUTPUT.PUT_LINE( '+ Monitoramento de Operações Longas' );
  DBMS_OUTPUT.PUT_LINE( '+ &p_filtro' );
  DBMS_OUTPUT.PUT_LINE( '+------------------------------------------------------------------------------------------------------------' );

  FOR C IN C1 LOOP

    IF C.SQL_ADDRESS <> SQL_ATUAL OR C.SERIAL# <> SERIAL_ATUAL OR C.SID <> SID_ATUAL or C.INST_ID <> INST_ATUAL THEN

      IF SEGUNDOS <> 0 THEN
        DBMS_OUTPUT.PUT_LINE( '|  TEMPO TOTAL                                             ' || TO_CHAR( TO_DATE('01/2000', 'MM/YYYY') + SEGUNDOS /(24*3600), 'HH24:MI:SS' ) );
        DBMS_OUTPUT.PUT_LINE( '+------------------------------------------------------------------------------------------------------------' );
        SEGUNDOS := 0;
      END IF;

      DBMS_OUTPUT.PUT( CHR(10) );
      DBMS_OUTPUT.PUT_LINE( '+------------------------------------------------------------------------------------------------------------' );
      DBMS_OUTPUT.PUT_LINE( '+' || C."USER" || '  ' || C."SQL"  );
      DBMS_OUTPUT.PUT_LINE( '+---------------------------------------------- ----------------------------------- ' );
      SQL_ATUAL := C.SQL_ADDRESS;
      SERIAL_ATUAL := C.SERIAL#;
      SID_ATUAL := C.SID;
      INST_ATUAL := C.INST_ID;
      HEADER := TRUE;

    END IF;

    SEGUNDOS := SEGUNDOS + C.ELAPSED_SECONDS ;

    IF HEADER THEN
      DBMS_OUTPUT.PUT_LINE( '| OPERAÇÃO                          CONCLUÍDO INÍCIO      RESTANTE PASSADO  OBJETO' );
      DBMS_OUTPUT.PUT_LINE( '| --------------------------------- --------- ----------- -------- -------- ---------------------------------' );
      HEADER := FALSE;     --  123456789.123456789.123456789.123                                         123456789.123456789.123456789.123
    END IF;

    DBMS_OUTPUT.PUT_LINE( '| ' || C.OPNAME || ' ' || LPAD( C.PERCENTUAL, 8, ' ' ) || '% '||
                                  C.INI || ' ' || C.RESTANTE || ' ' || C.PASSADO || ' ' || C.OBJETO );

  END LOOP;

  DBMS_OUTPUT.PUT_LINE( '| TEMPO TOTAL                                             ' || TO_CHAR( TO_DATE('01/2000', 'MM/YYYY') + SEGUNDOS /(24*3600), 'HH24:MI:SS' ) );
  DBMS_OUTPUT.PUT_LINE( '+------------------------------------------------------------------------------------------------------------' );

END;
/

PROMPT
SET VERIFY ON SERVEROUT OFF FEEDBACK 6

UNDEFINE 1
UNDEFINE 2
UNDEFINE P1
UNDEFINE P2
UNDEFINE P_DIAS=3
UNDEFINE P_PERC=99.99
UNDEFINE p_anded_clause
UNDEFINE p_filtro

COL c_filtro CLEAR
COL c_anded_clause CLEAR

