define owner=&1

begin

for priv in (
	select 'grant execute on '||decode(REFERENCED_OWNER,'PUBLIC','',REFERENCED_OWNER||'.')||REFERENCED_NAME
	||' to '||owner sentence
	--, DEPENDENCY_TYPE, REFERENCED_LINK_NAME
	from DBA_DEPENDENCIES dep
	where owner like upper ('&owner')
	and exists ( select 1 
					from dba_objects obj 
					where dep.OWNER = obj.OWNER
					and dep.NAME = obj.OBJECT_NAME 
					and obj.object_type not in ('TABLE','VIEW')
					and status ='INVALID')
	and not exists ( select 1 
					from dba_tab_privs privs 
					where dep.REFERENCED_NAME = privs.TABLE_NAME 
					and grantee in (dep.owner,'PUBLIC') )
	and referenced_owner !=owner
	group by REFERENCED_OWNER,REFERENCED_NAME,owner
	--, DEPENDENCY_TYPE, REFERENCED_LINK_NAME
	order by owner
	)
	loop
		begin
		execute immediate priv.sentence;
		dbms_output.put_line(priv.sentence||' :OK');
		exception
			when others then
				dbms_output.put_line(priv.sentence||' :FAILED -> '||SQLERRM);
		end;
	end loop;
end;
/