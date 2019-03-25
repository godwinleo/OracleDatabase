SET SERVEROUT ON VERIFY OFF LINES 150 FEED OFF

PROMPT
PROMPT   MONITORAMENTO DE SEGMENTOS - Resumir: &P_RESUMO.
PROMPT   Tablespaces=&p_tbs. | Owner=&p_owner. | Objetos=&p_seg. | Ocupacao >= &P_PCTOCUP.% OR Size >= &P_MEGAS.M
PROMPT

DECLARE

  V_SEG VARCHAR2(1000) :=  REPLACE( UPPER('&p_seg.'), ' ', '' );
  TOT_BLOCKS NUMBER ;
  EMPTY_BLOCKS NUMBER;
  TBY NUMBER ;
  UBY NUMBER;
  LUEF NUMBER ;
  LUEBI NUMBER ;
  LUB NUMBER ;
  
  V_AUX INTEGER;

  TOT_MEGAS NUMBER;
  EMPTY_MEGAS NUMBER;

  G_TOT_MEGAS NUMBER;
  G_EMPTY_MEGAS NUMBER;

  CPART VARCHAR2(80);
  CNOME VARCHAR2(80);

  BLOCK_SIZE NUMBER(5);
  VPCTFREE  NUMBER(3) := NULL;
  VPCTUSED  NUMBER(3) := NULL;
  VINITRANS NUMBER(3) := NULL;
  VMAXTRANS NUMBER(3) := NULL;
  VHIBOUNDVAL varchar2(3000) := NULL;

  LAST_SEGMENT VARCHAR2(32) := 'X';

  FIRST          BOOLEAN := TRUE;
  RESUMIR        BOOLEAN := ( UPPER( '&P_RESUMO.' ) = 'SIM' );

  PRIMEIRA_PART  BOOLEAN := FALSE;
  LAST_WAS_PART  BOOLEAN := FALSE;

  AC_TOT_MEGAS    NUMBER;
  AC_EMPTY_MEGAS  NUMBER;
  AC_CNFRAGS      NUMBER;
  AC_CVAR_NEXT    VARCHAR2(1);
  AC_CNEXT        NUMBER;
  AC_VPCTFREE     NUMBER;
  AC_VPCTUSED     NUMBER;
  AC_VINITRANS    NUMBER;
  AC_VMAXTRANS    NUMBER;

  CURSOR C1 IS
    WITH SEGS AS (
    SELECT /*+materialize*/
      T.NAME TABLESPACE_NAME, S.SEGMENT_TYPE,
      DECODE( S.SEGMENT_TYPE,
         'INDEX', 'INDICE', 'TABLE', 'TABELA', 'INDEX PARTITION', 'INDICE', 'TABLE PARTITION', 'TABELA',
         'LOBINDEX', 'LOBIDX', 'LOGSEGMENT', 'LOBSEG', SUBSTR( TRIM(S.SEGMENT_TYPE), 1, 6 ) ) TIPO,
      S.OWNER, S.SEGMENT_NAME, S.PARTITION_NAME, S.NEXT_EXTENT/1048576 NEXT,
      S.MAX_EXTENTS, T.DFLMINLEN EXTLEN, S.EXTENTS NFRAGS,
      S.HEADER_FILE, S.HEADER_BLOCK, DECODE(NVL(S.PCT_INCREASE,0), 0, '', '*' ) VAR_NEXT
    FROM DBA_SEGMENTS S, SYS.TS$ T
    WHERE S.OWNER LIKE UPPER('&P_OWNER.')
    AND T.NAME LIKE UPPER('&P_TBS.' )
    AND S.SEGMENT_NAME NOT LIKE 'BIN$%'
    AND S.SEGMENT_TYPE NOT IN ( 'TEMPORARY' )
    AND NVL(S.TABLESPACE_NAME, 'A' ) = NVL( T.NAME, 'A' )
    )
    SELECT 
      S.* 
     ,TP.PARTITION_POSITION TP_POS
     ,IP.PARTITION_POSITION IP_POS
    FROM SEGS S
    LEFT JOIN DBA_TAB_PARTITIONS TP ON (TP.TABLE_OWNER = S.OWNER AND TP.TABLE_NAME = S.SEGMENT_NAME AND TP.PARTITION_NAME=S.PARTITION_NAME)
    LEFT JOIN DBA_IND_PARTITIONS IP ON (IP.INDEX_OWNER = S.OWNER AND IP.INDEX_NAME = S.SEGMENT_NAME AND IP.PARTITION_NAME=S.PARTITION_NAME)
    ORDER BY
      -- S.NAME, 
      DECODE( SUBSTR(S.SEGMENT_TYPE, 1, 5), 'TABLE', 1, 'INDEX', 2, 3 ),
      DECODE( SUBSTR(S.SEGMENT_NAME, 1, 3), 'PK_', 1, 'UK_', 2, 3 ),
      S.SEGMENT_NAME, NVL( TP.PARTITION_POSITION, IP.PARTITION_POSITION );

  PROCEDURE IMPRIME_DETALHE
    (CPART VARCHAR2, TOT_MEGAS NUMBER, EMPTY_MEGAS NUMBER, NFRAGS NUMBER, VAR_NEXT VARCHAR2,
     PNEXT NUMBER, PPCTFREE NUMBER, PPCTUSED NUMBER, PINITRANS NUMBER, PMAXTRANS NUMBER,
     PG_TOT_MEGAS IN OUT NUMBER, PG_EMPTY_MEGAS IN OUT NUMBER,
     FIRST IN OUT BOOLEAN, PRIMEIRA_PART IN OUT BOOLEAN, ULTIMA_PART BOOLEAN := FALSE )
  IS
    PCT_OCUP NUMBER;
  BEGIN

    IF TOT_MEGAS > 0 THEN
      PCT_OCUP := 100-ROUND( EMPTY_MEGAS * 100 / TOT_MEGAS, 2 ) ;
    ELSE
      PCT_OCUP := 0;
    END IF;

    IF PCT_OCUP >= &P_PCTOCUP. or TOT_MEGAS >= &P_MEGAS. THEN

      IF FIRST THEN
        DBMS_OUTPUT.PUT_LINE( '.---------------------------------------------------------------------.--------------------------.--------------.-------------------------.' );
        DBMS_OUTPUT.PUT_LINE( '|                                                                     |    ESPAÇO UTILIZADO      |   EXTENTS    |  PARÂMETROS DE BLOCO    |' );
        DBMS_OUTPUT.PUT_LINE( '|OBJETO                                      (*Next = PCTINCREASE > 0)| TOTAL_MB VAZIO_MB OCUPADO| FRAGS NEXT_MB|%FREE %USED ITRANS MTRANS|' );
        DBMS_OUTPUT.PUT_LINE( '|---------------------------------------------------------------------|--------- -------- -------|------ -------|----- ----- ------ ------|' );
        FIRST := FALSE;
        PRIMEIRA_PART := FALSE;
      ELSIF PRIMEIRA_PART THEN
        DBMS_OUTPUT.PUT_LINE( '|---------------------------------------------------------------------|--------- -------- -------|------ -------|----- ----- ------ ------|' );
        PRIMEIRA_PART := FALSE;
      END IF;

      DBMS_OUTPUT.PUT     ( RPAD( CPART                                               , 70, ' ' ) || '|' );
      DBMS_OUTPUT.PUT     ( LPAD( TO_CHAR(TOT_MEGAS             , 'fm999g990D00')     ,  9, ' ' ) );
      DBMS_OUTPUT.PUT     ( LPAD( TO_CHAR(EMPTY_MEGAS           , 'fm999990D00' )     ,  9, ' ' ) );
      DBMS_OUTPUT.PUT     ( LPAD( TO_CHAR(PCT_OCUP              , 'fm990D00'    )||'%',  8, ' ' ) || '|' );
      DBMS_OUTPUT.PUT     ( LPAD( TO_CHAR(NFRAGS                , 'fm99990'     )     ,  6, ' ' ) );
      DBMS_OUTPUT.PUT     ( LPAD( VAR_NEXT||TO_CHAR(NVL(PNEXT,0), 'fm9990D00'   )     ,  8, ' ' ) || '|' );
      DBMS_OUTPUT.PUT     ( LPAD( TO_CHAR(PPCTFREE              , 'fm990'       )||'%',  5, ' ' ) );
      DBMS_OUTPUT.PUT     ( LPAD( TO_CHAR(PPCTUSED              , 'fm990'       )||'%',  6, ' ' ) );
      DBMS_OUTPUT.PUT     ( LPAD( ' '||TO_CHAR(PINITRANS        , 'fm990'       )     ,  7, ' ' ) );
      DBMS_OUTPUT.PUT_LINE( LPAD( TO_CHAR(PMAXTRANS             , 'fm990'       )||'|',  8, ' ' ) );

      IF ULTIMA_PART THEN
        DBMS_OUTPUT.PUT_LINE( '|---------------------------------------------------------------------|--------- -------- -------|------ -------|----- ----- ------ ------|' );
      ELSE
        PG_TOT_MEGAS   := PG_TOT_MEGAS + TOT_MEGAS;
        PG_EMPTY_MEGAS := PG_EMPTY_MEGAS + EMPTY_MEGAS;
      END IF;

    END IF;

  END;

BEGIN

  SELECT VALUE INTO BLOCK_SIZE
  FROM V$PARAMETER WHERE NAME='db_block_size';

  G_TOT_MEGAS   := 0.0;
  G_EMPTY_MEGAS := 0.0;

  DBMS_OUTPUT.ENABLE( 1E+6 );

  FOR C IN C1 LOOP
    BEGIN

      DECLARE
         SEGTYPE VARCHAR2( 100 );
      BEGIN
        IF C.SEGMENT_TYPE IN ( 'LOBSEGMENT' ) THEN
          SEGTYPE := 'LOB';
        ELSIF C.SEGMENT_TYPE IN ( 'LOBINDEX' ) THEN
          SEGTYPE := 'INDEX';
        ELSE
          SEGTYPE := C.SEGMENT_TYPE;
        END IF;

        IF C.SEGMENT_TYPE IN ('LOBSEGMENT', 'LOBINDEX' ) THEN
          SELECT OBJECT_NAME INTO CNOME
          FROM DBA_OBJECTS
          WHERE OBJECT_ID = TO_NUMBER( SUBSTR( C.SEGMENT_NAME, 8, INSTR( C.SEGMENT_NAME, 'C0' ) - 8 ) );
        ELSE
          CNOME := C.SEGMENT_NAME;
        END IF;

        DBMS_SPACE.UNUSED_SPACE( C.OWNER, C.SEGMENT_NAME, SEGTYPE, TOT_BLOCKS,
                                 TBY, EMPTY_BLOCKS, UBY, LUEF, LUEBI, LUB, C.PARTITION_NAME );
      EXCEPTION
         WHEN OTHERS THEN
          --DBMS_OUTPUT.PUT_LINE( C.OWNER ||';'||C.SEGMENT_NAME||';'||SEGTYPE );
          --RAISE;
          TOT_BLOCKS := 0; TBY := 0;  EMPTY_BLOCKS := 0;
          UBY := 0;        LUEF := 0; LUEBI := 0;
          LUB := 0;
      END;
      
      -- NESTA HORA, FILTRA OS SEGMENTOS ESCOLHIDOS.
      -- SE CNOME NÃO ATENDER O FILTRO V_SEG, ABORTA E PASSA PARA O PROXIMO SEGMENTO
      IF SUBSTR( V_SEG, 1, 1 ) = '(' THEN
        IF INSTR( V_SEG, CNOME ) = 0 THEN
          RAISE no_data_found;
        END IF;
      ELSE
        SELECT 1 INTO V_AUX
        FROM DUAL
        WHERE CNOME LIKE V_SEG ESCAPE '\';
      END IF;      

      TOT_MEGAS   := TOT_BLOCKS*BLOCK_SIZE/1048576;
      EMPTY_MEGAS := EMPTY_BLOCKS*BLOCK_SIZE/1048576;

      VPCTFREE    := NULL;
      VPCTUSED    := NULL;
      VINITRANS   := NULL;
      VMAXTRANS   := NULL;
      VHIBOUNDVAL := NULL;

      BEGIN
      
        IF C.SEGMENT_TYPE = 'TABLE' THEN

          SELECT PCTFREE$, PCTUSED$, INITRANS, MAXTRANS
          INTO VPCTFREE, VPCTUSED, VINITRANS, VMAXTRANS
          FROM SYS.TAB$
          WHERE FILE# = C.HEADER_FILE AND BLOCK# = C.HEADER_BLOCK;

        ELSIF C.SEGMENT_TYPE = 'TABLE PARTITION' THEN

          SELECT PCTFREE$, PCTUSED$, INITRANS, MAXTRANS, HIBOUNDVAL
          INTO VPCTFREE, VPCTUSED, VINITRANS, VMAXTRANS, VHIBOUNDVAL
          FROM SYS.TABPART$
          WHERE FILE# = C.HEADER_FILE AND BLOCK# = C.HEADER_BLOCK;

        ELSIF C.SEGMENT_TYPE = 'INDEX' THEN

          SELECT PCTFREE$, INITRANS, MAXTRANS
          INTO VPCTFREE, VINITRANS, VMAXTRANS
          FROM SYS.IND$
          WHERE FILE# = C.HEADER_FILE AND BLOCK# = C.HEADER_BLOCK;

        ELSIF C.SEGMENT_TYPE = 'INDEX PARTITION' THEN

          SELECT PCTFREE$, INITRANS, MAXTRANS, HIBOUNDVAL
          INTO VPCTFREE, VINITRANS, VMAXTRANS, VHIBOUNDVAL
          FROM SYS.INDPART$
          WHERE FILE# = C.HEADER_FILE AND BLOCK# = C.HEADER_BLOCK;

        END IF;

      EXCEPTION
        WHEN OTHERS THEN
           NULL;
      END;

      IF LAST_SEGMENT <> C.SEGMENT_NAME THEN

        IF LAST_WAS_PART THEN
          IMPRIME_DETALHE
            ( CPART, AC_TOT_MEGAS, AC_EMPTY_MEGAS, AC_CNFRAGS, AC_CVAR_NEXT,
              AC_CNEXT, AC_VPCTFREE, AC_VPCTUSED, AC_VINITRANS, AC_VMAXTRANS,
              G_TOT_MEGAS, G_EMPTY_MEGAS, FIRST, PRIMEIRA_PART, (NOT RESUMIR)
            );
        END IF;

        AC_TOT_MEGAS    := 0;
        AC_EMPTY_MEGAS  := 0;
        AC_CNFRAGS      := 0;
        AC_CVAR_NEXT    := NULL;
        AC_CNEXT        := NULL;
        AC_VPCTFREE     := NULL;
        AC_VPCTUSED     := NULL;
        AC_VINITRANS    := NULL;
        AC_VMAXTRANS    := NULL;

        LAST_SEGMENT   := C.SEGMENT_NAME;
        LAST_WAS_PART  := C.PARTITION_NAME IS NOT NULL;
        PRIMEIRA_PART  := LAST_WAS_PART AND NOT RESUMIR;

      END IF;

      AC_TOT_MEGAS    := AC_TOT_MEGAS   + TOT_MEGAS   ;
      AC_EMPTY_MEGAS  := AC_EMPTY_MEGAS + EMPTY_MEGAS ;
      AC_CNFRAGS      := AC_CNFRAGS     + C.NFRAGS    ;

      AC_CNEXT        := NVL( AC_CNEXT    , C.NEXT     );
      AC_CVAR_NEXT    := NVL( AC_CVAR_NEXT, C.VAR_NEXT );
      AC_VPCTFREE     := NVL( AC_VPCTFREE , VPCTFREE   );
      AC_VPCTUSED     := NVL( AC_VPCTUSED , VPCTUSED   );
      AC_VINITRANS    := NVL( AC_VINITRANS, VINITRANS  );
      AC_VMAXTRANS    := NVL( AC_VMAXTRANS, VMAXTRANS  );

      IF INSTR( VHIBOUNDVAL, ''''  ) > 0 THEN
         VHIBOUNDVAL := 'n/a';
      END IF;

      IF LAST_WAS_PART AND NOT RESUMIR THEN
        CPART := '| - PART ' || C.PARTITION_NAME ||'('||VHIBOUNDVAL||')';
      ELSE
         CPART := '|' || C.TIPO || ' ' || LPAD(C.TABLESPACE_NAME, 12, ' ' ) || ':' || C.OWNER || '.' || CNOME;
      END IF;

      IF NOT ( RESUMIR AND LAST_WAS_PART ) THEN
        IMPRIME_DETALHE
          ( CPART, TOT_MEGAS, EMPTY_MEGAS, C.NFRAGS, C.VAR_NEXT,
            C.NEXT, VPCTFREE, VPCTUSED, VINITRANS, VMAXTRANS,
            G_TOT_MEGAS, G_EMPTY_MEGAS, FIRST, PRIMEIRA_PART
          );
      END IF;

      CPART := '|' || C.TIPO || ' ' || LPAD(C.TABLESPACE_NAME, 12, ' ' ) || ':' || C.OWNER || '.' || CNOME;
      
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;

    END;
    
  END LOOP;

  IF LAST_WAS_PART THEN
    IMPRIME_DETALHE
      ( CPART, AC_TOT_MEGAS, AC_EMPTY_MEGAS, AC_CNFRAGS, AC_CVAR_NEXT,
        AC_CNEXT, AC_VPCTFREE, AC_VPCTUSED, AC_VINITRANS, AC_VMAXTRANS,
        G_TOT_MEGAS, G_EMPTY_MEGAS, FIRST, PRIMEIRA_PART, (NOT RESUMIR)
      );
  END IF;

  IF NOT FIRST THEN
    DECLARE
      PCT NUMBER;
    BEGIN

      IF G_TOT_MEGAS > 0 THEN
        PCT := 100-ROUND( G_EMPTY_MEGAS * 100 / G_TOT_MEGAS, 2 ) ;
      ELSE
        PCT := 0;
      END IF;

      IF RESUMIR OR (NOT LAST_WAS_PART) THEN
        DBMS_OUTPUT.PUT_LINE( '|---------------------------------------------------------------------|--------- -------- -------|------ -------|----- ----- ------ ------|' );
      END IF;
      DBMS_OUTPUT.PUT_LINE( '| TOTAIS GERAIS ----------------------------------------------------- |'||
                            LPAD( TO_CHAR(G_TOT_MEGAS  , 'fm9g999g990'),  9, ' ' ) ||
                            LPAD( TO_CHAR(G_EMPTY_MEGAS, 'fm9g999g990'),  9, ' ' ) ||
                            LPAD( TO_CHAR(PCT, 'fm990D00')||'%',  8, ' ' ) || '| ----   ----- | ---   ---   ----   ---- |' );
      DBMS_OUTPUT.PUT_LINE( '·---------------------------------------------------------------------·--------------------------·--------------·-------------------------·' );
    END;
    
  END IF;

END;
/

PROMPT
SET SERVEROUT OFF VERIFY ON FEED ON
