select owner, name, queue_table, ENQUEUE_ENABLED,DEQUEUE_ENABLED
from dba_queues
where owner like 'SYSMAN%'
/