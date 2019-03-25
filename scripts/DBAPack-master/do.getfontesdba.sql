SET VERIFY OFF TRIMSPOOL ON PAGES 0 FEEDBACK OFF TERMOUT OFF

DEFINE TIPO='&1.'
DEFINE DONO='&2.'
DEFINE NOME='&3.'

COL CNOME NEW_VALUE P_PATH
COL CDONO NEW_VALUE P_DONO
COL CTIPO NEW_VALUE P_TIPO

SELECT
 Lower( 'fontes\&dono.\' ||
   Decode(UPPER('&tipo'), 'PACKAGE BODY', 'PACKAGE', 'TYPE BODY', 'TYPE', '&tipo' ) || '\&nome..Sql' ||
   Decode(UPPER('&tipo'), 'PACKAGE BODY', '.Bdy', 'TYPE BODY', '.Bdy' ) ) cNome,
 Lower( '&dono.' ) cDono,
 Lower( Decode( UPPER('&tipo'), 'PACKAGE BODY', 'PACKAGE', 'TYPE BODY', 'TYPE', '&tipo' ) ) cTipo
FROM DUAL
/

HOST MKDIR Fontes
HOST MKDIR Fontes\&P_Dono.
HOST MKDIR Fontes\&P_Dono.\&P_Tipo.

SET TERMOUT ON
PROMPT Fonte gerado em &P_Path.
SET TERMOUT OFF

SPOOL &P_Path.

PROMPT -- &P_Path.
PROMPT
PROMPT SET DEFINE OFF
PROMPT
-- VERIFICAR SE WORD WRAP TIRA A IDENTACAO
REM COL TEXTO_FMT FORMAT A500 WORD_WRAP
COL TEXTO_FMT FORMAT A500

/* SELECT /*+ NO_MERGE(V)
  DECODE( LINE, 1,
    REPLACE(
      REPLACE(
        REPLACE( TEXT, 'FOR EACH ROW', CHR(10)||'FOR EACH ROW'),
           'BEFORE', CHR(10)||'BEFORE' ),
             'AFTER', CHR(10)||'AFTER' ), TEXT)  TEXTO_FMT
*/

SELECT /*+ NO_MERGE(V) */
 TEXT   TEXTO_FMT
FROM (
  SELECT
    NAME, TYPE, LINE,
    DECODE( LINE, 1,
      'CREATE OR REPLACE '||TYPE||' '||OWNER||'.' ||
      REPLACE(REPLACE(TRIM(REPLACE(UPPER(TEXT),TYPE)),'"'),OWNER||'.'), TEXT ) TEXT
  FROM DBA_SOURCE
  WHERE UPPER ( NAME ) = UPPER( '&NOME' )
  AND OWNER = UPPER( '&DONO' )
  AND TYPE = UPPER( '&TIPO' )
  UNION
  SELECT NAME, TYPE, MAX( LINE ) + 1 LINE, '/' TEXT
  FROM DBA_SOURCE
  WHERE UPPER ( NAME ) = UPPER( '&NOME' )
  AND OWNER = UPPER( '&DONO' )
  AND TYPE = UPPER( '&TIPO' )
  GROUP BY NAME, TYPE
) V
/

COL TEXTO_FMT CLEAR

PROMPT
PROMPT SET DEFINE "&"
SPOOL OFF
SET PAGES 100 FEEDBACK 6 TERMOUT ON

