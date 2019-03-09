-- do NOT add blank lines
-- do NOT add a slash or semi-colon terminator
-- this script is called from inside a SQL statement
--
-- as seen in dba_hist_active_sess_history
-- this is only needed for 10g  and lower
-- 11g+ use the v$sqlcommand view
-- Order is crucial, as the rownum will be the same as the stored opcode value
select 
rownum id, column_value opcode
from (
	table(
	sys.odcivarchar2list(
'CREATE_TABLE',
'INSERT',
'SELECT',
'CREATE_CLUSTER',
'ALTER_CLUSTER',
'UPDATE',
'DELETE',
'DROP_CLUSTER',
'CREATE_INDEX',
'DROP_INDEX',
'ALTER_INDEX',
'DROP_TABLE',
'CREATE_SEQUENCE',
'ALTER_SEQUENCE',
'ALTER_TABLE',
'DROP_SEQUENCE',
'GRANT_OBJECT',
'REVOKE_OBJECT',
'CREATE_SYNONYM',
'DROP_SYNONYM',
'CREATE_VIEW',
'DROP_VIEW',
'VALIDATE_INDEX',
'CREATE_PROCEDURE',
'ALTER_PROCEDURE',
'LOCK',
'NO-OP',
'RENAME',
'COMMENT',
'AUDIT_OBJECT',
'NOAUDIT_OBJECT',
'CREATE_DATABASE_LINK',
'DROP_DATABASE_LINK',
'CREATE_DATABASE',
'ALTER_DATABASE',
'CREATE_ROLLBACK_SEG',
'ALTER_ROLLBACK_SEG',
'DROP_ROLLBACK_SEG',
'CREATE_TABLESPACE',
'ALTER_TABLESPACE',
'DROP_TABLESPACE',
'ALTER_SESSION',
'ALTER_USER',
'COMMIT',
'ROLLBACK',
'SAVEPOINT',
'PL/SQL_EXECUTE',
'SET_TRANSACTION',
'ALTER_SYSTEM',
'EXPLAIN',
'CREATE_USER',
'CREATE_ROLE',
'DROP_USER',
'DROP_ROLE',
'SET_ROLE',
'CREATE_SCHEMA',
'CREATE_CONTROL_FILE',
'CREATE_TRIGGER',
'ALTER_TRIGGER',
'DROP_TRIGGER',
'ANALYZE_TABLE',
'ANALYZE_INDEX',
'ANALYZE_CLUSTER',
'CREATE_PROFILE',
'DROP_PROFILE',
'ALTER_PROFILE',
'DROP_PROCEDURE',
'ALTER_RESOURCE_COST',
'CREATE_MATERIALIZED_VIEW_LOG',
'ALTER_MATERIALIZED_VIEW_LOG',
'DROP_MATERIALIZED_VIEW_LOG',
'CREATE_MATERIALIZED_VIEW',
'ALTER_MATERIALIZED_VIEW',
'DROP_MATERIALIZED_VIEW',
'CREATE_TYPE',
'DROP_TYPE',
'ALTER_ROLE',
'ALTER_TYPE',
'CREATE_TYPE_BODY',
'ALTER_TYPE_BODY',
'DROP_TYPE_BODY',
'DROP_LIBRARY',
'TRUNCATE_TABLE',
'TRUNCATE_CLUSTER',
'CREATE_FUNCTION',
'ALTER_FUNCTION',
'DROP_FUNCTION',
'CREATE_PACKAGE',
'ALTER_PACKAGE',
'DROP_PACKAGE',
'CREATE_PACKAGE_BODY',
'ALTER_PACKAGE_BODY',
'DROP_PACKAGE_BODY',
'LOGON',
'LOGOFF',
'LOGOFF_BY_CLEANUP',
'SESSION_REC',
'SYSTEM_AUDIT',
'SYSTEM_NOAUDIT',
'AUDIT_DEFAULT',
'NOAUDIT_DEFAULT',
'SYSTEM_GRANT',
'SYSTEM_REVOKE',
'CREATE_PUBLIC_SYNONYM',
'DROP_PUBLIC_SYNONYM',
'CREATE_PUBLIC_DATABASE_LINK',
'DROP_PUBLIC_DATABASE_LINK',
'GRANT_ROLE',
'REVOKE_ROLE',
'EXECUTE_PROCEDURE',
'USER_COMMENT',
'ENABLE_TRIGGER',
'DISABLE_TRIGGER',
'ENABLE_ALL_TRIGGERS',
'DISABLE_ALL_TRIGGERS',
'NETWORK_ERROR',
'EXECUTE_TYPE',
'CREATE_DIRECTORY',
'DROP_DIRECTORY',
'CREATE_LIBRARY',
'CREATE_JAVA',
'ALTER_JAVA',
'DROP_JAVA',
'CREATE_OPERATOR',
'CREATE_INDEXTYPE',
'DROP_INDEXTYPE',
'DROP_OPERATOR',
'ASSOCIATE_STATISTICS',
'DISASSOCIATE_STATISTICS',
'CALL_METHOD',
'CREATE_SUMMARY',
'ALTER_SUMMARY',
'DROP_SUMMARY',
'CREATE_DIMENSION',
'ALTER_DIMENSION',
'DROP_DIMENSION',
'CREATE_CONTEXT',
'DROP_CONTEXT',
'ALTER_OUTLINE',
'CREATE_OUTLINE',
'DROP_OUTLINE',
'UPDATE_INDEXES',
'ALTER OPERATOR')
	)
)
