DECLARE
    l_cursor  number;
    l_result number;
    l_user_id number;
BEGIN
    SELECT USER_ID 
    INTO l_user_id
    FROM ALL_USERS 
    WHERE USERNAME='<nome-do-usuario>';
    
    l_cursor := sys.dbms_sys_sql.open_cursor;
    
    sys.dbms_sys_sql.parse_as_user
    (
      l_cursor,
      'CREATE DATABASE LINK nomelink CONNECT TO usuario IDENTIFIED BY "senha" USING ''tns''',
      dbms_sql.native, l_user_id 
    );
        
    l_result := sys.dbms_sys_sql.execute(l_cursor);
    
    sys.dbms_sys_sql.close_cursor(l_cursor);
END;
/
