define schema=&1
 col PROFILE_ID for 99
 col PROFILE_NAME for a6
 col TGT_SCHEMA for a12
 col PASSWORD for a11
 col SCHEMA_ID for 9999
 col CFG_ID for 99
 col RUN for 99
 col global_retention for 99
select prof.*
from imp_profile prof, imp_schema sch
where sch.schema like '%&schema%'
and prof.schema_id=sch.schema_id
order by prof.schema_id,tgt_schema,cfg_id
/

