define schema=&1
define db=&2
 col source_schema for a25
 col PROFILE_ID for 99
 col PROFILE_NAME for a6
 col TGT_SCHEMA for a12
 col PASSWORD for a11
 col SCHEMA_ID for 9999
 col CFG_ID for 99
 col RUN for 99
 col global_retention for 99
select sch.schema||'@'||sch.sid source_schema, prof.*
from imp_profile prof, imp_schema sch
where sch.schema like upper('&schema')
and sch.sid like lower('&db')
and prof.schema_id (+)=sch.schema_id
order by sch.schema_id,tgt_schema,cfg_id
/

