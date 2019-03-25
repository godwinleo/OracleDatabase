define rpoint=&1
col scn for 999999999999999
col name for a30

SELECT
 SCN
 , TIME
 , NAME 
FROM V$RESTORE_POINT 
WHERE NAME like upper('&rpoint');