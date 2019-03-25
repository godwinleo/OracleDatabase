DEFINE jowner=&&1.
DEFINE ativos='0'

@do.jobs.sql &jowner. &ativos.

UNDEFINE 1 JOWNER ATIVOS
PROMPT
