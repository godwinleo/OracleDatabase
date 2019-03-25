with x as (select s.osuser osuser , s.username
     , s.status
     , se.sid
     , s.serial# serial
     , n.name
     , round(max(se.value)/1024/1024, 2) maxmem_mb
     , max(se.value) as maxmem
  from v$sesstat se , v$statname n , v$session s
 where n.statistic# = se.statistic#
--  and n.name in ('session pga memory','session pga memory max', 'session uga memory','session uga memory max')
  and n.name in ('session pga memory','session uga memory')
   and s.sid        = se.sid
 group by s.osuser, s.username, s.status, se.sid, s.serial#, n.name
 order by maxmem desc 
 ) 
 select * from x where rownum < 50
 /
 
 
with x as (select s.osuser osuser , s.username
     , s.status
     , se.sid
     , s.serial# serial
     , n.name
     , round(max(se.value)/1024/1024, 2) maxmem_mb
     , max(se.value) as maxmem
  from v$sesstat se , v$statname n , v$session s
 where n.statistic# = se.statistic#
--  and n.name in ('session pga memory','session pga memory max', 'session uga memory','session uga memory max')
  and n.name in ('session pga memory','session uga memory')
   and s.sid        = se.sid
 group by s.osuser, s.username, s.status, se.sid, s.serial#, n.name
 order by maxmem desc 
 ) 
 select username, name, sum(maxmem_mb), count(*)
 from x
 group by username, name
 order by 3 desc
 /
 