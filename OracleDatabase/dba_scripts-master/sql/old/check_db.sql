set serveroutput on

declare 
pass number;
fail number;
err number;
begin
 dbadmin.fortidb_util.check_db@dbarepo ( pass, fail, err );
 dbms_output.put_line(pass||' '||fail||' '||err);
end;
/
