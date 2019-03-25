define user=&1
define new_user=&2
set echo off
set feed off
col definition for a200
SET LONG 1000000000
set lines 200
set pages 0
set trims on
set serveroutput on
--set termout on


--spool user_&(new_user)_tbs_create.sql

declare 
v_tbs varchar(30);
v_user varchar(30) := upper('&user');
v_new_user varchar(30) := upper('&new_user');
v_tbsdef long;
v_userdef long;
v_sysgrants long;
v_rolegrants long;
v_objgrants long;

begin

dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',TRUE);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'PRETTY',TRUE);

--execute immediate 'select replace(replace(dbms_metadata.get_ddl( :a, :b ),:c,:d),:e,:f) from dual' 
--into v_userdef using 'USER', v_user,v_user,v_new_user,lower(v_user),lower(v_new_user);

select replace(replace(dbms_metadata.get_ddl( 'USER', v_user ),v_user,v_new_user),lower(v_user),lower(v_new_user))
into v_userdef
from dual;

-- tablespace
select default_tablespace 
into v_tbs
from dba_users
where username = v_user;

--SELECT dbms_metadata.get_ddl('TABLESPACE',v_tbs) definition FROM DUAL;
--execute immediate 'select replace(dbms_metadata.get_ddl( :a, :b ),:c,:d) from dual'
--into v_tbsdef using 'TABLESPACE', v_tbs,v_user,v_new_user;

select replace(replace(dbms_metadata.get_ddl( 'TABLESPACE', v_tbs ),v_user,v_new_user) , lower(v_user),lower(v_new_user))
into v_tbsdef
from dual;

dbms_output.put_line (v_tbsdef);
dbms_output.put_line (v_userdef);

-- role privs
select replace(replace(dbms_metadata.get_granted_ddl( 'ROLE_GRANT', v_user ),v_user,v_new_user),lower(v_user),lower(v_new_user))
into v_rolegrants
from dual;

dbms_output.put_line (v_rolegrants);

-- sys privs
select replace(replace(dbms_metadata.get_granted_ddl( 'SYSTEM_GRANT', v_user ),v_user,v_new_user),lower(v_user),lower(v_new_user))
into v_sysgrants
from dual;

dbms_output.put_line (v_sysgrants);

-- obj privs
select replace(replace(dbms_metadata.get_granted_ddl( 'OBJECT_GRANT', v_user ),v_user,v_new_user),lower(v_user),lower(v_new_user))
into v_objgrants
from dual;

dbms_output.put_line (v_objgrants);

-- ts quotas privs
for quota in ( select decode(max_bytes,-1,'UNLIMITED') max_bytes,tablespace_name from dba_ts_quotas where username=v_user )
loop
	dbms_output.put_line('alter user '||v_new_user||' quota '||quota.max_bytes||' on '||replace(quota.tablespace_name,v_user,v_new_user)||';');
end loop;

-- roles
for priv in ( select granted_role from dba_role_privs where grantee=v_user )
loop
	dbms_output.put_line('grant '||priv.granted_role||' to '||v_new_user||';');
end loop;

-- sys privs
for priv in ( select privilege from dba_sys_privs where grantee=v_user )
loop
	dbms_output.put_line('grant '||priv.privilege||' to '||v_new_user||';');
end loop;

-- tab privs
for priv in ( select privilege,owner,table_name from dba_tab_privs where grantee=v_user )
loop
	dbms_output.put_line('grant '||priv.privilege||' on '||priv.owner||'.'||priv.table_name||' to '||v_new_user||';');
end loop;

end;
/
--spool off
