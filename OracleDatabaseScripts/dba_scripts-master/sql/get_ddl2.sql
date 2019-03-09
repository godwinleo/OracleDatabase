set echo off
set feed off
define type=&1
define object=&2
col definition for a200
SET LONG 1000000000
set lines 200
set pages 0
set trims on
set serveroutput on

exec dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',TRUE);

SELECT dbms_metadata.get_ddl('&type','&object') definition
FROM DUAL;

SELECT dbms_metadata.get_granted_ddl('&type','&object') definition
FROM DUAL;

