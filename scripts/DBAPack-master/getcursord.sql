DEFINE L_BUF_GET=0
DEFINE L_BUF_GET_BY_EXEC=0
DEFINE ARG=&&1.
DEFINE MSG=''

@do.getcursor.sql &arg.

PROMPT Para obter o resumo dos Top Cursores use @GetCursor &P1. &P2.
PROMPT
UNDEFINE L_BUF_GET L_BUF_GET_BY_EXEC MSG ARG P1 P2 P3 HH 
