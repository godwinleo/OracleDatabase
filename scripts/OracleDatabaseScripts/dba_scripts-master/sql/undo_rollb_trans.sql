--choreada de oracle,metalink 1337335.1
-- para transacciones que estan haciendo rollback
select b.name "UNDO Segment Name", b.inst# "Instance ID", b.status$ STATUS, a.ktuxesiz "UNDO Blocks", a.ktuxeusn, a.ktuxeslt xid_slot, a.ktuxesqn xid_seq
from x$ktuxe a, undo$ b
where a.ktuxesta = 'ACTIVE' and a.ktuxecfl like '%DEAD%' and a.ktuxeusn = b.us#;
