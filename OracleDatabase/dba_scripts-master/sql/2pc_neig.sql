set lines 185
set pages 70
col in_out for a30
col local_tran_id for a15
col database for a15
col dbuser_owner for a15
col interface for a15
col dbid for 99999999999999
col sess# for 99999999999999
col branch for a15

 select 
LOCAL_TRAN_ID
,IN_OUT       
,DATABASE     
,DBUSER_OWNER 
,INTERFACE    
,DBID         
,SESS#        
,BRANCH       
 from DBA_2PC_NEIGHBORS
/
