--drop queue table
define schema=&1

declare
v_schema varchar2(100):='&schema';
sqlstr clob;

begin

dbms_output.put_line ('first loop');

for aqtab in (
		select q.owner, q.name, q.queue_table
		from dba_objects o, dba_queues q
		where o.owner like upper(v_schema)
		and object_type='QUEUE'
		and status!='VALID'
		and o.object_name=q.name
		and o.owner=q.owner
	)

loop
	begin
	dbms_aqadm.drop_queue_table (
									queue_table=> aqtab.owner||'.'||aqtab.queue_table
									, force => true
								);
	dbms_output.put_line ('dropped queue '||aqtab.queue_table);
	exception
	when others then
		dbms_output.put_line ('error dropping queue '||aqtab.queue_table||' : '||SQLERRM);
	end;

end loop;


for aqtab in (
	select owner, table_name
	from dba_tables
	where owner like upper(v_schema)
	and table_name like 'AQ$%'
	)
loop
	dbms_output.put_line ('second loop');
	dbms_aqadm.drop_queue_table (
									queue_table=> aqtab.owner||'.'||aqtab.table_name
									, force => true
								);
								
	dbms_output.put_line ('dropped table '||aqtab.table_name);
end loop;



exception
when others then
	dbms_output.put_line( SQLERRM );

end;
/