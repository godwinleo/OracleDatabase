set pages 200
set lines 180
set trims on
col PROPERTY_NAME for a40 TRUNCATE
col PROPERTY_VALUE for a40 TRUNCATE
col DESCRIPTION for a60 TRUNCATE

select *
from database_properties
order by PROPERTY_NAME;
