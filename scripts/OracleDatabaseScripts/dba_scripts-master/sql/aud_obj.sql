define obj=&1
col client for a35
col db_user for a20
col terminal for a15
col SQL_TEXT for a30 word_wrapped
col OBJ_NAME for a30
col USERHOST for a10
col COMMENT_TEXT for a20
col action_name for a15

select OS_USERNAME||'@'||userhost client,USERNAME db_user ,to_char(TIMESTAMP,'YYYY-MON-DD HH24:MI:SS') timestamp 
--, to_char(EXTENDED_TIMESTAMP,'YYYY-MON-DD HH24:MI:SS') ex_timestamp
, SESSIONID --, TRANSACTIONID
--, SYS_PRIVILEGE, STATEMENTID
, SQL_TEXT
, ACTION_NAME , OBJ_NAME , RETURNCODE
from dba_audit_trail
where TIMESTAMP > trunc (sysdate-5)
and obj_name like upper('&obj')
order by TIMESTAMP
/