define pid=&1
col MESSAGE for a80 word_wrapped
col PP_CODE for a20
SELECT * 
FROM RDW_LOAD_LOG 
WHERE PROCESS_ID = &pid -- 193193  pe 
ORDER BY SYSTIME
/
