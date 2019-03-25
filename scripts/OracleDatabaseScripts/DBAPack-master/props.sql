SET LINES 200
set verify off
COL PROPERTY_NAME  FORMAT A30
COL PROPERTY_VALUE FORMAT A60
COL DESCRIPTION    FORMAT A50
SELECT * FROM DATABASE_PROPERTIES
.

select PROPERTY_NAME, PROPERTY_VALUE from database_properties where PROPERTY_NAME like upper('&1.')
/
