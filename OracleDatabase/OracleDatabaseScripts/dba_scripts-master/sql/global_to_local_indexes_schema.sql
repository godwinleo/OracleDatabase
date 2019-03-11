accept owner char prompt 'Schema name: '
set serveroutput on

declare

v_def clob;
v_cons_def clob;
v_owner varchar2(100) := '&owner';

begin

dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',false);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'PARTITIONING',false);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES', false);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'TABLESPACE',false);

for ind in (
			select ind.owner idx_owner,ind.index_name idx_name,ind.index_type,ind.UNIQUENESS,ind.tablespace_name,ind.status
			--, ind.partitioned
			,ind.compression
			,cons.constraint_type, cons.owner constraint_owner, cons.constraint_name
			,cons.TABLE_NAME
			from dba_indexes ind, dba_tables tab, dba_constraints cons			
			where tab.owner like upper(v_owner)
			and ind.table_name=tab.table_name
			and ind.table_owner=tab.owner
			and tab.partitioned='YES'
			and ind.partitioned='NO'
			and ind.owner = cons.index_owner (+)
			and ind.index_name = cons.index_name (+)
			order by ind.table_name,ind.table_owner,ind.tablespace_name
			)
loop
	SELECT dbms_metadata.get_ddl('INDEX', ind.idx_name,ind.idx_owner) definition
	into v_def
	FROM DUAL;
	
	v_def := v_def ||' local compress compute statistics';
	dbms_output.put_line('Recreating index : '||ind.idx_owner||'.'||ind.idx_name );
	
	
	begin
		--dbms_output.put_line('Ind '||ind.idx_owner||'.'||ind.idx_name|| ' Definition -> '||v_def );
		if ind.constraint_type is null then
			execute immediate 'drop index '||ind.idx_owner||'.'||ind.idx_name;
			execute immediate v_def;
			dbms_output.put_line('Index : '||ind.idx_owner||'.'||ind.idx_name||' recreated successfully.' );
		elsif ind.constraint_type='P' then
			SELECT replace(dbms_metadata.get_ddl('CONSTRAINT', ind.constraint_name ,ind.constraint_owner),'USING INDEX ','USING INDEX '||ind.idx_owner||'.'||ind.idx_name) definition
			into v_cons_def
			FROM DUAL;
			
			dbms_output.put_line('Dropping constraint : '||ind.constraint_owner||'.'||ind.constraint_name );
			begin
				--dbms_output.put_line( 'alter table '||ind.constraint_owner||'.'||ind.table_name||' drop constraint '||ind.constraint_name);
				execute immediate 'alter table '||ind.constraint_owner||'.'||ind.table_name||' drop constraint '||ind.constraint_name;
				execute immediate 'drop index '||ind.idx_owner||'.'||ind.idx_name;
				execute immediate v_def;
				execute immediate v_cons_def;
				dbms_output.put_line('Index : '||ind.idx_owner||'.'||ind.idx_name||' recreated successfully.' );
				dbms_output.put_line('Constraint '||ind.constraint_owner||'.'||ind.constraint_name||' recreated successfully.' );
			exception
			when others then
				dbms_output.put_line('Error Recreating PK Index : '||ind.idx_owner||'.'||ind.idx_name|| ' -> '||SQLERRM );
				dbms_output.put_line('Ind '||ind.idx_owner||'.'||ind.idx_name|| ' Definition -> '||v_def );
				dbms_output.put_line('Ind '||ind.idx_owner||'.'||ind.idx_name|| ' Constraint Definition -> '||v_cons_def );
			end;
						
		end if;
	exception
	when others then
		dbms_output.put_line('Error Recreating index : '||ind.idx_owner||'.'||ind.idx_name|| ' -> '||SQLERRM );
		dbms_output.put_line('Command used -> '||v_def );
	end;

end loop;

exception
when others then
	dbms_output.put_line('Error -> '||SQLERRM);

end;
/
