SET PAGESIZE 20
COL SDATE                FOR A14
COL SQL_PROFILE          FOR A11 trunc
COL ROWS_PROCESSED_TOTAL FOR 99999999999   HEADING ROWS_PT
COL PLAN_HASH_VALUE                        HEADING PLAN_HASH
COL OPTIMIZER_COST       FOR 99999999      HEADING COST
COL BUFFER_GETS_TOTAL    FOR 99999999999   HEADING BUFFER_GETS
COL OPTIMIZER_MODE       FOR A4          HEADING 'MODE'
COL oMODE                 FOR A4          HEADING 'MODE'
COL FETCHES_TOTAL        FOR 9999999       HEADING FETCHES
COL EXECUTIONS_TOTAL     FOR 999999999     HEADING EXEC_TOT
COL IOWAIT_MIN           FOR 9999999       HEADING IOWAIT_m
COL elapsed              FOR 999999        HEADING 'ELAP_m'
COL CPU_MIN              FOR 999999
COL sorts_total          FOR 99999         HEADING SORTS
COL VERSION_COUNT        FOR 999           HEADING VERSIONS
COL EXECUTIONS_TOTAL     FOR 999999999     HEADING EXEC
COL invalidations_total  FOR 99999         HEADING INVAL
COL DISK_READS_TOTAL     FOR 999999999     HEADING DISK_R
COL DIRECT_WRITES_TOTAL  FOR 999999999     HEADING DIRECT_W
COL ROWS_PROCESSED_TOTAL FOR 99999999      HEADING ROWS
COL INTERVAL             FOR 999
COL RS                   FOR 99999        HEADING 'R/S'

select to_char(s.BEGIN_INTERVAL_TIME,'DD-MM-YY HH24:MI') SDATE, 
--       (TO_DATE(to_char(s.END_INTERVAL_TIME,'DD-MM-YY HH24:MI'),'DD-MM-YY HH24:MI') - TO_DATE(to_char(s.BEGIN_INTERVAL_TIME,'DD-MM-YY HH24:MI'),'DD-MM-YY HH24:MI'))*1440 INTERVAL,
       b.plan_hash_value,
       substr(b.optimizer_mode,1,1) omode, 
       b.optimizer_cost,
       b.sharable_mem,       
       b.sorts_total,
       b.fetches_total,
       b.executions_total,
       b.invalidations_total,
       b.disk_reads_total,
       b.direct_writes_total,
       b.buffer_gets_total,
       b.rows_processed_total,
       round(B.ELAPSED_TIME_TOTAL/1000/1000/60) elapsed,
       round(b.cpu_time_total/1000/1000/60) cpu_min,
       round(b.iowait_total/1000/1000/60) iowait_min,
       b.rows_processed_total/round(B.ELAPSED_TIME_TOTAL/1000/1000) rs,
       b.sql_profile
 from SYS.DBA_HIST_SQLSTAT  b,
      dba_hist_snapshot     s
where b.sql_id='&sql_id' 
  and b.snap_id = s.snap_id
  AND TO_DATE(to_char(s.BEGIN_INTERVAL_TIME,'DD-MM-YY HH24:MI'),'DD-MM-YY HH24:MI') >= TRUNC(SYSDATE)-200
order by s.BEGIN_INTERVAL_TIME ASC
/