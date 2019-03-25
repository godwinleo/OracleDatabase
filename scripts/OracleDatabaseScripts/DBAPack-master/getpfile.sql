col qt_inst new_value qt_inst
col vw new_value vw
col exp new_value exp
define hidden=0
set termout off verify off pages 1000 feed 1000 lines 250
select 
   nvl(to_number(p.value), 1 ) qt_inst
  ,case when nvl(to_number(p.value), 1 ) > 1 then 'gv$parameter2 P' else 'v$parameter2 P' end vw
  ,case when nvl(to_number(p.value), 1 ) > 1 then '(select instance_name from gv$instance i where i.inst_id=p.inst_id)||''.''' else '''''' end exp
from v$parameter2 p
cross join  v$database d
where p.name='cluster_database_instances'
/

SET LONG 512
COL "="  FORMAT A1
COL NAME FORMAT A44
COL VALUE FORMAT A150 WRAP

set termout on verify off
SELECT 
  CASE WHEN isdeprecated = 'TRUE' THEN '(--)' ELSE '    ' END ||  '*.' || name NAME
 ,'=' "="
 ,NVL(value, ''''||value||'''' ) VALUE
FROM 
(
  -- global
  select isdeprecated, name, value, count(*)
  from &vw.
  WHERE (NVL( ISDEFAULT, 'X' ) = 'FALSE' or (name like 'log_archive_dest__' and length(value)>0)) 
  AND name not like '#_#_%' ESCAPE '#'
  and ( &hidden. = 1 OR ( &hidden. = 0 AND name not like '#_%' ESCAPE '#' ))
  group by isdeprecated, name, value
  having count(*) > 1 and count(*) >= &qt_inst.
)
UNION ALL
SELECT 
  CASE WHEN p.isdeprecated = 'TRUE' THEN '(--)' ELSE '    ' END ||  &exp. || p.name NAME
 ,'=' "="
 ,NVL(p.value, ''''||p.value||'''' ) VALUE
FROM &vw. 
WHERE (NVL( ISDEFAULT, 'X' ) = 'FALSE' or (name like 'log_archive_dest__' and length(value)>0)) 
AND p.name not like '#_#_%' ESCAPE '#'
and ( &hidden. = 1 OR ( &hidden. = 0 AND name not like '#_%' ESCAPE '#' ))
AND NOT EXISTS 
( 
SELECT 1 
  FROM 
  (
    -- global 
    select isdeprecated, name, value, count(*)
    from &vw.
    WHERE (NVL( ISDEFAULT, 'X' ) = 'FALSE' or (name like 'log_archive_dest__' and length(value)>0)) 
    AND name not like '#_#_%' ESCAPE '#'
    and ( &hidden. = 1 OR ( &hidden. = 0 AND name not like '#_%' ESCAPE '#' ))
    group by isdeprecated, name, value
    having count(*) > 1 and count(*) >= &qt_inst.
  )g 
  WHERE g.name = p.name 
)
ORDER BY 1
/

COL qt_inst CLEAR
COL vw CLEAR
COL exp CLEAR
COL "=" CLEAR
COL NAME CLEAR
COL VALUE CLEAR


PROMPT REM    @getpfile
PROMPT