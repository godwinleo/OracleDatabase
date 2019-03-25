/*

TM     DML enqueue
TX     Transaction enqueue
UL     User supplied
CU     Cursor bind
TO     Temporary object
SS     Sort segment
JQ     Job queue
PI, PS Parallel operation
HW     Space management operations on a specific segment
TT     Temporary table enqueue
CI     Cross-instance function invocation instance

BL     Buffer hash table instance
CF     Control file schema global enqueue
PF     Password File
QA..QZ Row cache instance (A..Z = cache)
NA..NZ Library cache pin instance (A..Z = namespace)
LA..LP Library cache lock instance lock (A..P = namespace)
PR     Process startup
DF     Data file instance
DL     Direct loader parallel index create
RT     Redo thread global enqueue
DM     Mount/startup db primary/secondary instance
SC     System commit number instance
DR     Distributed recovery process
SM     SMON
DX     Distributed transaction entry
SN     Sequence number instance
FS     File set
SQ     Sequence number enqueue
IN     Instance number
ST     Space transaction enqueue
IR     Instance recovery serialization global enqueue
SV     Sequence number value
IS     Instance state
TA     Generic enqueue
IV     Library cache invalidation instance
TS     Temporary segment enqueue (ID2=0)
TS     New block allocation enqueue (ID2=1)
KK     Thread kick
UN     User name
MM     Mount definition global enqueue
US     Undo segment DDL
MR     Media recovery
WL     Being-written redo log instance

*/

DEFINE P1=&1.
DEFINE P2=EXT_SMARTECM

SET PAGESIZE 2000 LINESIZE 300 DEFINE ON VERIFY OFF FEEDBACK OFF TERMOUT OFF

COLUMN cls_where new_value p_cls_where NOPRINT;
COLUMN mysid new_value p_mysid NOPRINT;

SELECT
 DECODE( '&P1.', '%', 'AND 1=1', 'AND V.OBJECT_ID IN ( SELECT OBJ# FROM SYS.OBJ$ WHERE NAME LIKE UPPER( ''&P1.'' ) )' ) cls_where
 ,(SELECT SID FROM GV$MYSTAT WHERE ROWNUM < 2) MYSID
FROM DUAL;

SET TERMOUT ON

PROMPT
PROMPT   Tabelas=&p1. Show_Partitions=NO
PROMPT

BREAK ON OBJETO SKIP 1

COL OBJETO FORMAT A45
COL PARTICAO FORMAT A28 NOPRINT
COL SESSAO FORMAT A15 JUST R
COL USUARIO FORMAT A25
COL MODO FORMAT A28
COL SEGUNDOS FORMAT A11
COL PROGRAMA FORMAT A30

WITH ALL_LOCKS AS 
(
  SELECT  /*+ MATERIALIZE */ * FROM GV$LOCK 
),
 FILTERED_LOCKS AS
(
  SELECT * 
  FROM ALL_LOCKS
  WHERE TYPE NOT IN ( 'XR', 'RT', 'TS', 'MR', 'CF', 'PW', 'RS', 'TO', 'PS', 'KD','CO','RD','DM','KT', 'AE' )
),
LOCKS AS
(
  SELECT
     V1.*, V2.ID1 OBJECT_ID
  FROM
    (SELECT * FROM FILTERED_LOCKS WHERE TYPE = 'TX')  V1,
    (SELECT * FROM FILTERED_LOCKS WHERE TYPE = 'TM')  V2,
     SYS.OBJ$ O
  WHERE V1.SID = V2.SID
    AND V2.ID1 = O.OBJ#
    AND O.DATAOBJ# IS NOT NULL
  UNION ALL
  SELECT V3.*, V3.ID1 FROM FILTERED_LOCKS V3
  WHERE V3.TYPE <> 'TX'
),
RESULTADOS AS
(
  SELECT /*+ ALL_ROWS */
    ( SELECT U.USERNAME || '.' || O.NAME FROM SYS.OBJ$ O, ALL_USERS U WHERE OBJ# = V.OBJECT_ID AND U.USER_ID = O.OWNER# ) OBJETO
   ,( SELECT NVL(O.SUBNAME, 'TABLE') FROM SYS.OBJ$ O WHERE O.OBJ# = V.OBJECT_ID  ) PARTICAO
   --,LPAD( ''''||V.SID||','||S.SERIAL#||'''',12,' ')
   ,LPAD( ''''||V.SID||','||S.SERIAL#||',@'||S.INST_ID||'''',15,' ') SESSAO
   ,DECODE(S.TYPE,'BACKGROUND',SUBSTR(S.PROGRAM,INSTR(S.PROGRAM,'(')+1,4), S.USERNAME) USUARIO
   ,DECODE( V.LMODE  , 2,'[2  RS]',3,'[3  RX]',4,'[4   S]',5,'[5 SRX]',6,'[6   X]','[     ]') || ' ' ||
    DECODE( V.REQUEST, 2,'[2  RS]',3,'[3  RX]',4,'[4   S]',5,'[5 SRX]',6,'[6   X]','[     ]') || ' ' ||
    DECODE( V.TYPE,
       'TM', 'TABLE MODE',
       'TX', 'TRANSACTION',
       'DX', 'DIST TRANS',
       'UL', 'USER LOCK',
       'CU', 'CURSOR BIND',
       'TO', 'TEMP OBJ',
       'SS', 'SORT SEG',
       'PS', 'PARLL EXEC',
       'JQ', 'JOB QUEUE',
       'US', 'UNDO SEG DDL',
       V.TYPE ) MODO
   -- ,V.CTIME SEGUNDOS
   ,CASE V.TYPE 
       WHEN 'AE' THEN 'ID1=' || V.ID1 || ' ID2=' || V.ID2
       ELSE NULL
    END DETALHES
   ,SUBSTR(NUMTODSINTERVAL(V.CTIME,'SECOND'),9,11) SEGUNDOS
   ,SUBSTR( 
      UPPER(SUBSTR(S.PROGRAM, 1, DECODE(INSTR(S.PROGRAM,' '), 0, LENGTH(S.PROGRAM), INSTR(S.PROGRAM,' ')-1))) ||'@'||
      LOWER(SUBSTR(S.MACHINE, DECODE(INSTR(S.MACHINE,'\'), 0, 1,INSTR(S.MACHINE,'\')+1), DECODE(INSTR(S.MACHINE,'.'), 0, LENGTH(S.MACHINE), INSTR(S.MACHINE,'.')-1)))
    , 1, 30 ) PROGRAMA
  FROM
    LOCKS V
   ,GV$SESSION S
  WHERE V.SID = S.SID
  AND  V.INST_ID = S.INST_ID
  &P_CLS_WHERE.
  AND V.SID <> &P_MYSID.
  ORDER BY
    OBJECT_ID
   ,DECODE(PARTICAO,'TABLE',' ', PARTICAO)
   ,ID2, DECODE(LMODE, 0, NULL, LMODE ), CTIME DESC
)
SELECT
  OBJETO, PARTICAO, SESSAO, USUARIO, MODO, SEGUNDOS, PROGRAMA, DETALHES
FROM RESULTADOS
--WHERE USUARIO LIKE '&P2.'
/

SET VERIFY ON FEED 6 PAGESIZE 100

COL OBJETO   CLEAR
COL PARTICAO CLEAR
COL USUARIO  CLEAR
COL MODO     CLEAR
COL SEGUNDOS CLEAR
COL PROGRAMA CLEAR

CLEAR BREAK

UNDEFINE P_CLS_WHERE
UNDEFINE P_MYSID
UNDEFINE P1
UNDEFINE 1


