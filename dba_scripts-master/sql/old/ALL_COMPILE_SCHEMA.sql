set echo on
set feedback on
set trimspool on
set timing on
set lines 5000
set pages 5000
SET SERVEROUTPUT ON
VARIABLE V_OWNER VARCHAR2 (30)
DECLARE
CURSOR C_OBJETOS (P_OWNER VARCHAR2)
IS
SELECT owner, object_name, object_type,
       DECODE(object_type, 'PACKAGE', 2,'PACKAGE BODY', 3, 1) AS recompile_order
FROM   ALL_OBJECTS
WHERE  OWNER = P_OWNER
AND    status = 'INVALID'
ORDER BY recompile_order;

nombre_objeto 	VARCHAR2(100);
propietario 	VARCHAR2(100);
tipo_objeto 	VARCHAR2(100);
sql_str		 	VARCHAR2(1000);
vorden 		 	number;
comperr		 	VARCHAR2(1000);
BEGIN
	 :V_OWNER := '&1';
	
OPEN C_OBJETOS (:V_OWNER);
LOOP
	FETCH C_OBJETOS  INTO propietario, nombre_objeto, tipo_objeto, vorden ;
	EXIT WHEN C_OBJETOS%NOTFOUND;
	IF tipo_objeto = 'PACKAGE BODY' THEN
		sql_str := 'ALTER PACKAGE '||propietario||'.'||nombre_objeto||' COMPILE BODY';
		dbms_output.put_line(sql_str);
		BEGIN
			EXECUTE IMMEDIATE sql_str; 
		EXCEPTION
			WHEN OTHERS THEN
				begin
					FOR I IN ( 
					select SUBSTR('Compilation Error on line '||LINE||': '||TEXT,1,1000) comperr
					from ALL_ERRORS
					WHERE OWNER = propietario
					AND 	NAME 	= nombre_objeto
					AND 	TYPE 	= tipo_objeto) LOOP
						dbms_output.put_line(I.comperr);			
					
					END LOOP;
				EXCEPTION 
					WHEN OTHERS THEN
						dbms_output.put_line('Error al compilar '||nombre_objeto);
				end;
		END;
	ELSE
		sql_str := 'ALTER '||tipo_objeto||' '||propietario||'.'||nombre_objeto||' COMPILE';
		dbms_output.put_line(sql_str);
		BEGIN
			EXECUTE IMMEDIATE sql_str; 
		EXCEPTION
			WHEN OTHERS THEN
				begin
					FOR I IN ( 
					select SUBSTR('Compilation Error on line '||LINE||': '||TEXT,1,1000) comperr 
					from ALL_ERRORS
					WHERE OWNER = propietario
					AND 	NAME 	= nombre_objeto
					AND 	TYPE 	= tipo_objeto) LOOP
						dbms_output.put_line(I.comperr);			
					
					END LOOP;
				EXCEPTION 
					WHEN OTHERS THEN
						dbms_output.put_line('Error al compilar '||nombre_objeto);
				end;
		END;
	END IF;
END LOOP; 
CLOSE C_OBJETOS;
END;
/

