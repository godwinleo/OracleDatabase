col full_path for a70
col type for a20
define dg_number=&1

break on group_number skip 1 on report
compute sum label "Total MB for DG#" of mb on group_number
--compute sum label "Total MB " of mb on report
select alias.group_number
	,sys_connect_by_path(alias.name,'/') full_path
	--,alias.PARENT_INDEX 	,alias.reference_INDEX
	,af.type
	,round(af.bytes/1024/1024,2) MB
	,af.blocks
	,to_char(af.creation_date,'YYYY-MON-DD HH24:MI') cdate, to_char(af.modification_date,'YYYY-MON-DD HH24:MI') mdate
	,round(af.space/1024/1024,2) space_MB
	from v$asm_alias alias
	, V$asm_file af
	where alias.file_number=af.file_number (+)
	and alias.group_number=af.group_number (+)
	and alias.group_number like nvl('&dg_number','%')
	start with alias.alias_index = 0
	connect by alias.PARENT_INDEX= prior alias.REFERENCE_INDEX
/

/*
col full_path for a70
select dg.group_number ,af.*
from
	(select --alias.name, alias.ALIAS_DIRECTORY 
	sys_connect_by_path(alias.name,'/') full_path
	,alias.PARENT_INDEX ,alias.reference_INDEX
	,af.type
	,alias.group_number
	from v$asm_alias alias
	, V$asm_file af
	where alias.file_number=af.file_number (+)
	and alias.group_number=af.group_number (+)
	start with alias.alias_index =0
	connect by alias.PARENT_INDEX= prior alias.REFERENCE_INDEX
	) af
, v$asm_diskgroup dg
where dg.group_number=af.group_number
/
*/