define user=&1
set pages 200
set lines 185
set trims on
col username for a25
col account_Status for a30
col default_tablespace for a20
col temporary_tablespace for a20
col profile for a30
select u.username,u.account_status
,CREATED, lock_date, expiry_date
,profile
,default_tablespace,temporary_tablespace
from dba_users u
where 
EXPIRY_DATE < trunc(sysdate)
;
