col job_id      for 999999
col host        for a6
col schema      for a10  trunc
col sid         for a8   trunc
col tgt_host    for a10   trunc
col tgt_sid     for a10
col tgt_schema  for a10  trunc
col step        for A15
col status      for a8
col PRO_GB      for 9999 HEADING 'PRO_G'
col obj_miss    for 999 heading 'MISS'
col obj_dropped for 999 heading 'DROP'
col imp_mode    for a4 HEADING 'MODE'
col JOB_GB      for 9999 HEADING 'JOB_G'
col started     for a14
col finished    for a14
col vt_id       for 99999999999
col brm_id      for a17
col tot         for a5
col files       for a7   trunc

select q.job_id, s.sid, s.schema,to_char(q.book_date,'DD-MON-YY') BOOK_DATE,q.run,
       q.imp_mode, 
       decode(q.step,0,'(0)  NEW'     , 1,'(1)  IMPCFG'  , 2,'(2)  IMPPAR',
                     3,'(3)  FILECHK' , 4,'(4)  FILESND' ,
                     5,'(5)  FILEUZP' , 6,'(6)  TRUNCATE',
                     7,'(7)  IMPORT'  , 8,'(8)  LOGCHK'  , 9,'(9)  ERRFIX',
                    10,'(10) POST1'   ,11,'(11) STATS    ',12,'(12) POST2',
                    13,'(13) SCRAMBLE',14,'(14) POST3',
                    15,'(15) RMFILE', 16,'(16) ENDING',17,'(17) MAIL',
                   100,'(100)FINAL','OTHER') STEP,
       q.status, 
       q.tgt_sid,q.tgt_schema,
       q.submitted,
       Q.OBJ_DROPPED, 
       Q.OBJ_MISS,ROUND(q.prod_size/1024/1024/1024) PRO_GB,        ROUND(q.job_size/1024/1024/1024) JOB_GB,
       q.started,
       q.files
--       ,(select count(1) from imp_dumpfile where job_id= q.job_id and status='SENT') ||'/'||
 --      (select count(1) from imp_dumpfile where job_id= q.job_id) tot
from dbadmin.imp_queue q,
     dbadmin.imp_schema s
where s.schema_id=q.schema_id
  and q.step!=100
order by job_id,step,status;
