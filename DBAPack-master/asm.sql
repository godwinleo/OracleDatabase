SET LINES 1000 FEED OFF

COL PATH      FORMAT A30
COL LABEL     FORMAT A20

COL GROUP_NUMBER FORMAT 99 HEAD "G#"
COL VOLUME_NUMBER FORMAT 99 HEAD "V#"
COL NUM_VOL FORMAT 99 HEAD "V#"
COL DISK_NUMBER  FORMAT 99 HEAD "D#"
COL FILE_NUMBER  FORMAT 999 HEAD "F#"

COL FS_NAME       FORMAT A30
COL MOUNTPATH     FORMAT A30
COL VOLUME_DEVICE FORMAT A30

COL FAILGROUP        FORMAT A14 HEAD FGROUP
COL COMPATIBILITY    FORMAT A12
COL DATABASE_COMPATIBILITY    FORMAT A12

COL FILE_NAME    FORMAT A34
COL FILE_TYPE    FORMAT A20 
COL GROUP_NAME   FORMAT A17
COL DISK_NAME    FORMAT A28 HEAD DISK_NAME
COL LABEL_NAME    FORMAT A28 HEAD LABEL_NAME
COL VOLUME_NAME  FORMAT A20 HEAD VOLUME_NAME
COL VOTING       FORMAT A6

COL INSTANCE     FORMAT A12
COL DB_CLIENT    FORMAT A12
COL SOFTWARE     FORMAT A12
COL COMPATIBLE   FORMAT A12 

COL COMPATIBLE_ASM   FORMAT A11 HEAD "COMPATIBLE|ASM"
COL COMPATIBLE_RDBMS FORMAT A11 HEAD "COMPATIBLE|RDBMS"
COL COMPATIBLE_ADVM  FORMAT A11 HEAD "COMPATIBLE|ADVM"
COL REPAIR_TIME      FORMAT A7 HEAD "REPAIR|TIME"

PROMPT
PROMPT ===============> ASM DISKGROUPS

-- sql original
SELECT
  GROUP_NUMBER                   
 ,NAME GROUP_NAME
 ,STATE                          
 ,TYPE                           
 ,ROUND(TOTAL_MB/1024) TOTAL_GB
 ,ROUND(FREE_MB/1024) FREE_GB
 ,ROUND(COLD_USED_MB/1024) COLD_USED_GB
 ,ROUND(USABLE_FILE_MB/1024) USABLE_GB
 ,SECTOR_SIZE                    
 ,BLOCK_SIZE                     
 ,ALLOCATION_UNIT_SIZE           
 ,REQUIRED_MIRROR_FREE_MB        
 ,OFFLINE_DISKS                  
 ,COMPATIBILITY                  
 ,DATABASE_COMPATIBILITY         
 ,VOTING_FILES                   
FROM V$ASM_DISKGROUP
ORDER BY 1
.

-- nova vis�o - flavio
WITH VAD AS
(
  SELECT
    D.GROUP_NUMBER                   
   ,D.NAME GROUP_NAME
   ,CASE D.STATE WHEN 'CONNECTED' THEN 'MOUNTED' ELSE D.STATE END STATE
   ,D.TYPE                           
   ,ROUND(D.TOTAL_MB/1024) OS_TOTAL_GB
   ,ROUND(D.TOTAL_MB/1024/(CASE TYPE WHEN 'EXTERN' THEN 1 WHEN 'NORMAL' THEN 2 ELSE 3 END)) TOTAL_GB
   ,ROUND(D.COLD_USED_MB/1024/(CASE TYPE WHEN 'EXTERN' THEN 1 WHEN 'NORMAL' THEN 2 ELSE 3 END)) USED_GB
   ,ROUND(D.FREE_MB/1024/(CASE TYPE WHEN 'EXTERN' THEN 1 WHEN 'NORMAL' THEN 2 ELSE 3 END)) FREE_GB
   ,ROUND(D.REQUIRED_MIRROR_FREE_MB/1024/(CASE TYPE WHEN 'EXTERN' THEN 1 WHEN 'NORMAL' THEN 2 ELSE 3 END)) MIRROR_GB
   ,ROUND(D.USABLE_FILE_MB/1024) USABLE_GB
   ,(SELECT VALUE FROM V$ASM_ATTRIBUTE A WHERE D.GROUP_NUMBER = A.GROUP_NUMBER AND NAME =  'disk_repair_time' ) REPAIR_TIME
   ,(SELECT VALUE FROM V$ASM_ATTRIBUTE A WHERE D.GROUP_NUMBER = A.GROUP_NUMBER AND NAME =  'compatible.asm'   ) COMPATIBLE_ASM
   ,(SELECT VALUE FROM V$ASM_ATTRIBUTE A WHERE D.GROUP_NUMBER = A.GROUP_NUMBER AND NAME =  'compatible.rdbms' ) COMPATIBLE_RDBMS
   ,(SELECT VALUE FROM V$ASM_ATTRIBUTE A WHERE D.GROUP_NUMBER = A.GROUP_NUMBER AND NAME =  'compatible.advm'  ) COMPATIBLE_ADVM
  FROM V$ASM_DISKGROUP D
) 
SELECT
   GROUP_NAME
  ,STATE
  ,TYPE
  ,OS_TOTAL_GB
  ,TOTAL_GB
  ,USED_GB
  ,FREE_GB
  ,TRUNC(FREE_GB/TOTAL_GB*100,3) FREE_PCT
  ,USABLE_GB
  ,TRUNC(USABLE_GB/TOTAL_GB*100,3 ) USABLE_PCT
  ,REPAIR_TIME
  ,COMPATIBLE_ASM
FROM VAD
ORDER BY GROUP_NAME
/
PROMPT

