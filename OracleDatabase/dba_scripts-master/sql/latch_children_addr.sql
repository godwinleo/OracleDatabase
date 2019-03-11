define addr=&1
col name for a35
set trims on
 select 
name, 'Child '||child#, gets, misses, sleeps
      from
        v$latch_children  l
      where
        l.addr ='&addr'
;
