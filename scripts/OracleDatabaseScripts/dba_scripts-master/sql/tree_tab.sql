set trims on
define owner=&1
define tab=&2
col tab for a35

select constraint_name,constraint_type,owner||'.'||table_name tab,r_owner||'.'||r_constraint_name r_constraint
,status
,decode(constraint_type,'P',1,'R','2') hola
,decode(table_name,upper('&tab'),3,0) chau
from dba_constraints cons
/*
, (select table_name 
	from dba_constraints
	where contraint_type in ('P','R')
)*/
where constraint_type in ('P','R')
and ( table_name in upper('&tab')
		and owner in upper('&owner') )
or exists
	(select 1 
		from dba_constraints 
		where owner=cons.r_owner 
		and constraint_name=cons.r_constraint_name
		--and cons.constraint_type='R'
		and table_name in upper ('&tab')
		and owner in upper('&owner')
		)
order by  hola+chau desc
/
