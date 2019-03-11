col LOG_ID for 999999
col JOB_ID for 999999
col BOOK_DATE for a15
col RUN_DATE for a29
col SEVERITY for 99999
col PART_DROPPED for a3
col ROWS_ARCHIVED for 999999999
col MODULE for a20
col MESSAGE for a68 word_wrapped
 select * 
from audit_user.aud_archive_log order by log_id;
