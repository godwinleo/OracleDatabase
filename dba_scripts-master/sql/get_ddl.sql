set echo off
set feed off
define type="&1"
define owner=&2
define object=&3
col definition for a200
SET LONG 1000000000
--set LONGCHUNKSIZE 2000000000
set lines 200
set pages 0
set trims on
set serveroutput on

declare
v_def clob;
pv_type varchar2(100):='&type';
pv_owner varchar2(100):='&owner';
pv_object varchar2(100):='&object';

begin
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',TRUE);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'PARTITIONING',FALSE);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'REF_CONSTRAINTS', false);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'CONSTRAINTS', false);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES', false);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'STORAGE',false);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'TABLESPACE',false);

/*
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'REF_CONSTRAINTS', true);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'CONSTRAINTS', true);
*/

SELECT dbms_metadata.get_ddl(upper(pv_type), upper(pv_object),upper(pv_owner)) definition
into v_def
FROM DUAL;

dbms_output.put_line('hola pv_type -> '||pv_type||' pv_object -> '||pv_object||' pv_owner -> '||pv_owner);
dbms_output.put_line(v_def);

/*
	begin
		SELECT dbms_metadata.get_dependent_ddl('INDEX', upper(pv_object), upper(pv_owner)) definition 
		into v_def
		FROM DUAL;
		dbms_output.put_line(v_def);
	exception
	when others then
		--dbms_output.put_line('Error looking for ref constraints -> Obj: '||' -> '||SQLERRM);
		dbms_output.put_line('Error looking for Indexes.');
	end;
	
	begin
		SELECT dbms_metadata.get_dependent_ddl('CONSTRAINT', upper(pv_object), upper(pv_owner)) definition 
		into v_def
		FROM DUAL;
		dbms_output.put_line(v_def);
	exception
	when others then
		--dbms_output.put_line('Error looking for ref constraints -> Obj: '||' -> '||SQLERRM);
		dbms_output.put_line('Error looking for constraints.');
	end;
	
	begin
		SELECT dbms_metadata.get_dependent_ddl('REF_CONSTRAINT', upper(pv_object), upper(pv_owner)) definition 
		into v_def
		FROM DUAL;
		dbms_output.put_line(v_def);
	exception
	when others then
		--dbms_output.put_line('Error looking for ref constraints -> Obj: '||' -> '||SQLERRM);
		dbms_output.put_line('Error looking for ref constraints.');
	end;
	

	
	begin
	dbms_metadata.set_transform_param(dbms_metadata.session_transform,'REF_CONSTRAINTS', true);
	dbms_metadata.set_transform_param(dbms_metadata.session_transform,'CONSTRAINTS', true);
	dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES', true);
	
		SELECT dbms_metadata.get_dependent_ddl('OBJECT_GRANT', upper(pv_object), upper(pv_owner)) definition 
		into v_def
		FROM DUAL;
		dbms_output.put_line(v_def);
	exception
	when others then
		--dbms_output.put_line('Error looking for obj grants or no obj grants -> Obj: '||' -> '||SQLERRM);
		dbms_output.put_line('Error looking for obj grants or no obj grants.');
	end;
*/
--dbms_output.put_line(v_def);
--dbms_output.put_line(v_obj_grants);
--dbms_output.put_line(v_ref_cons);
--SELECT dbms_metadata.get_granted_ddl('SYSTEM_GRANT', '&owner') definition FROM DUAL;
exception
when others then
	dbms_output.put_line('Error looking for -> Obj: '||' -> '||SQLERRM);
end;
/
