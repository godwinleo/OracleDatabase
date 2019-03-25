col book_dt for a15
col db_sid for a15
col servername for a15
col tbs_count for 999,999
break on report
compute count of db_sid on report
compute sum of tbs_count on report
select book_dt,db_sid,servername,count(distinct tablespace_name) tbs_count
from dbadmin.dbs_Segments
where book_dt=to_date(add_months(trunc(sysdate,'MON'),nvl(&month,0)))-1
group by book_dt,db_sid,servername
order by servername,db_sid
/
