define owner_name=notfound
col owner_name format a15 new_value owner_name TRUNC
col operation format a15 TRUNC
col job_mode format a10 TRUNC
col state format a20
col username new_value username
col sid new_value sid
col inst_id new_value inst_id

PROMPT
PROMPT DATAPUMP JOBS #######################################################################################################################################################################
select * from dba_datapump_jobs order by CASE WHEN STATE IN ('RUNNING') THEN 1 ELSE 0 END;

PROMPT LONG OPERATIONS  ####################################################################################################################################################################
@longs %

PROMPT TOPS ################################################################################################################################################################################
@topsab &owner_name.

rem @getcursor &sid. &inst_id.

col sid clear
col inst_id clear

PROMPT 
PROMPT ""     @dpmonit
PROMPT 