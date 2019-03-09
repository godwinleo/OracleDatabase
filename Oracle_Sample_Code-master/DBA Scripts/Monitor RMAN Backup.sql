SELECT to_char(start_time,'DD-MON-YY HH24:MI') "BACKUP STARTED",
       sofar, totalwork,
       elapsed_seconds/60 "ELAPSE (Min)",
       round(sofar/totalwork*100,2) "Complete%"
FROM   sys.v_$session_longops
WHERE  compnam = 'dbms_backup_restore'
/