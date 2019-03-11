col REMAP_DB_ID for 9999
col FROM_HOST   for a20
col FROM_SID    for a20
col TO_HOST     for a20
col TO_SID      for a20
col SCRAMBLE    for a20
col PASSWORD    for a20

select
REMAP_DB_ID
, FROM_HOST
, FROM_SID
, TO_HOST
, TO_SID
, SCRAMBLE
, PASSWORD
from dbadmin.IMP_REMAP_DB
/