set define on verify off long 200 lines 300 pages 400 feed off
col owner format a23 Head "Owner"
col username format a30 Head "Connects To"
col db_link format a38 Head "Database Link"
col host format a50 word_wrap Head "Connect Description"
col CREATED Head "Created"

select owner, db_link, username, created, host
from dba_db_links
where owner LIKE upper( '&1.' )
and   ( db_link LIKE upper( '&2.' ) escape '\' or lower(host) like '%&2.%' escape '\' )
order by owner, length(db_link), db_link
/

select distinct host
from dba_db_links
where (lower(host) like '%dg4%' or lower(host) like '%tg4%' or lower(host) like '%hs%' or lower(host) like '%sql%' )
.

set define "&" verify on feed 6 lines 200

undefine 1
undefine 2
col host clear
col db_link clear
col username clear
col owner clear

PROMPT

