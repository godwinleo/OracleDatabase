col program for a50
SELECT s.sid||','||s.serial# sess, s.username, s.program,
i.block_changes
FROM v$session s, v$sess_io i
WHERE s.sid = i.sid
and block_changes > 1000000
ORDER BY block_changes
/
