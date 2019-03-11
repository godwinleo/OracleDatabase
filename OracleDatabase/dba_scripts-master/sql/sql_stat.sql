SET PAGESIZE 20
COL SDATE                FOR A14
COL SQL_PROFILE          FOR A11 trunc
COL ROWS_PROCESSED_TOTAL FOR 99999999999 HEADING ROWS_PT
COL PLAN_HASH_VALUE                      HEADING PLAN_HASH
COL OPTIMIZER_COST       FOR 99999999    HEADING COST
COL OPTIMIZER_MODE       FOR A4          HEADING 'MODE'
COL OMODE                 FOR A4          HEADING 'MODE'
COL ROWS_PROCESSED       FOR 99999999    HEADING ROWS
COL BUFFER_GETS_TOTAL    FOR 99999999999 HEADING BUFFER_GETS
COL FETCHES_TOTAL        FOR 99999       HEADING FETCHES_TOT
COL INVALIDATIONS        FOR 9999        HEADING INVAL
COL EXECUTIONS           FOR 999999999   HEADING EXEC
COL CPU_MIN              FOR 999999      HEADING 'CPU_m'
COL ELAP_MIN             FOR 999999      HEADING 'ELAP_m'
COL LAST_ACTIVE_TIME     FOR A10         HEADING LAST_ACTIVE
COL SHARABLE_MEM         FOR 999999      HEADING SHAREMEM
COL SORTS                FOR 99999        
COL FETCHES              FOR 9999999       
COL DISK_READS           FOR 999999999    HEADING DISK_R
COL DIRECT_WRITES        FOR 999999999    HEADING DIRECT_W
COL iowait_min           FOR 999999999    HEADING IOWAIT_m
COL LAST_ACT             FOR A14
COL RS                   FOR 99999        HEADING 'R/S'

SELECT TO_CHAR(last_active_time,'DD-MM-YY HH24:MI') LAST_ACT,
       plan_hash_value,
       substr(optimizer_mode,1,1) omode, 
       optimizer_cost,       
       sharable_mem,       
       sorts,
       fetches,
       executions,
       invalidations, 
       disk_reads,
       direct_writes,
       buffer_gets,
       rows_processed,
       round(elapsed_time/1000/1000/60) elap_min,
       ROUND(cpu_time/1000/1000/60)     cpu_min,       
       round(user_io_wait_time/1000/1000/60) iowait_min,
--       rows_processed/round(elapsed_time/1000/1000) rs,
       sql_profile	
FROM V$SQLAREA WHERE SQL_ID='&sql_id'
/