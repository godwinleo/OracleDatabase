accept owner char prompt 'Table Schema : '
accept tab char prompt 'Table name : '
set serveroutput on

declare

rc number;
ownname varchar2(100):='&owner';
tabname varchar2(100):='&tab';

begin
	rc := dbs_purge.cleanup_table (ownname,tabname,trunc(sysdate));
	dbms_output.put_line(rc);
end;
/
