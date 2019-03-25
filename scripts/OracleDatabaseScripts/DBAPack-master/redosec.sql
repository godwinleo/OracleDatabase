set serverout on
declare
  vi number;
  vf number;
  redosec number;
  redo_hr_mb number;
begin
  select value into vi from v$sysstat where name like 'redo size';
  dbms_lock.sleep(10);
  select value into vf from v$sysstat where name like 'redo size';
  redosec := (vf-vi)/10;
  redo_hr_mb := redosec * 3600 / power( 2, 20 );
  dbms_output.put_line( 'Redo Size: ' || round( redosec, 2 ) || ' bytes/sec.' );
  dbms_output.put_line( 'Redo Size: ' || round( redo_hr_mb, 2 ) || ' Mb/h.' );
end;
/

