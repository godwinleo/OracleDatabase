DEFINE tbs='&1.'
DEFINE zero='00'
DEFINE detalhar='SIM'

@@do.dbafreespace.sql &tbs. &zero. &detalhar.

PROMPT Para resumir os tablespaces use @dbafreespace &tbs.
PROMPT

UNDEFINE 1 2 3 tbs zero detalhar

