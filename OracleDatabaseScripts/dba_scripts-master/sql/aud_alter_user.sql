define user=&1
col OS_USERNAME for a15
col username for a20
col terminal for a15
col SQL_TEXT for a30 word_wrapped
col OBJ_NAME for a30

select OS_USERNAME ,TERMINAL ,USERNAME ,to_char(TIMESTAMP,'YYYY-MON-DD HH24:MI:SS') timestamp 
--, to_char(EXTENDED_TIMESTAMP,'YYYY-MON-DD HH24:MI:SS') ex_timestamp
--, SYS_PRIVILEGE, STATEMENTID, SQL_TEXT
, ACTION_NAME , OBJ_NAME , RETURNCODE
from dba_audit_trail
where ACTION_NAME='ALTER USER'
and TIMESTAMP > trunc (sysdate)
and obj_name like upper('&user')
order by TIMESTAMP
/