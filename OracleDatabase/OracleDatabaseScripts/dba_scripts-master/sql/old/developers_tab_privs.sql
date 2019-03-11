 select
    lpad(' ', 5*level) || granted_role || ' - ' || privilege
    || ' on ' ||table_owner || '.' || table_name "User, his roles and privileges"
  from
    (
    /* THE USERS */
      select
        null     grantee,
        username granted_role
  	  , null privilege
  	  ,null		table_owner
  	  ,null		table_name
      from
        dba_users
      where
        username in ('EMER_YU28246','EMER_AC59832','EMER_GL40458','EMER_ND72367','EMER_ND49727')
    /* THE ROLES TO ROLES RELATIONS */
    union
      select
        grantee,
        granted_role
  	  , null privilege
  	   ,null		table_owner
  	  ,null		table_name
      from
        dba_role_privs
    /* THE ROLES TO PRIVILEGE RELATIONS */
    union
      select
        grantee
  	  ,null granted_role
        ,privilege
  	  ,owner		table_owner
  	  ,	table_name
      from
        dba_tab_privs
  	where privilege not in ('SELECT','DEBUG')
    )
  start with grantee is null
  connect by grantee = prior granted_role;