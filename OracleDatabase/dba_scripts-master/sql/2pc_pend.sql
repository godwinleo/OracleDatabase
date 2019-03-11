set lines 185
set pages 70
col host for a30
col GLOBAL_TRAN_ID for a35
col local_tran_id for a15
col db_user for a15
col os_user for a15

 select local_tran_id,global_tran_id,state,COMMIT#,host,db_user
,os_user
 from dba_2pc_pending
/
