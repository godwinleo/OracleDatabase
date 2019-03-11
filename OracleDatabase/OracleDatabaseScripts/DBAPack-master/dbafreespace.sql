DEFINE tbs='&1.'
DEFINE zero='00'
DEFINE detalhar='NAO'

@@do.dbafreespace.sql &tbs. &zero. &detalhar.

PROMPT Para detalhar os datafiles use @dbafreespaced &tbs.
PROMPT

UNDEFINE 1 2 3 tbs zero detalhar

