-- From Metalink: How to Find which Session is Holding a Particular Library Cache Lock (Doc ID 122793.1)

/*
select kgllkhdl Handle,kgllkreq Request, kglnaobj Object
from sys.x$kgllk l, v$session s
where l.kgllkses=s.saddr 
and s.event='library cache lock'
--kgllkses = '572ed244'
and kgllkreq > 0;

*/

select kgllkses saddr,kgllkhdl handle,kgllkmod mod,kglnaobj object
,s.username, s.sid, s.serial#
from sys.x$kgllk lock_a, v$session s
where kgllkmod > 0
and exists (select lock_b.kgllkhdl from x$kgllk lock_b
			where kgllkses in (select saddr from v$session where  event='library cache lock' /* blocked session */)
			and lock_a.kgllkhdl = lock_b.kgllkhdl
			and kgllkreq > 0)
and s.saddr= lock_a.kgllkses
;