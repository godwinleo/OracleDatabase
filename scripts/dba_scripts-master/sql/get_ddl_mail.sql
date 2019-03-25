set echo off
define type="&1"
define owner=&2
define object=&3
define addr=&4
col definition for a200
SET LONG 1000000000
--set LONGCHUNKSIZE 2000000000
set lines 200
set pages 0
set trims on
set serveroutput on
set feed on

declare
v_def clob;
v_obj_grants clob;
pv_type varchar2(100):='&type';
pv_owner varchar2(100):='&owner';
pv_object varchar2(100):='&object';
v_sender varchar2(100):='mariano.raul.quidiello@citi.com';
v_recipient varchar2(100):='&addr';

v_body_from varchar2 (300) := 'FinTech Appl DB SME Team';
v_subject varchar2 (300) := pv_owner||'.'||pv_object||' source';

l_mail_conn   UTL_SMTP.connection;
smtp_host varchar2(100) := '150.110.179.107';
smtp_port number := 25;
l_boundary    VARCHAR2(50) := '----=*#abc1234321cba#*=';
l_step        PLS_INTEGER  := 12000;

begin
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',TRUE);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'PARTITIONING',TRUE);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'REF_CONSTRAINTS', false);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'CONSTRAINTS', true);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES', false);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'STORAGE',false);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'TABLESPACE',false);

SELECT dbms_metadata.get_ddl( upper(pv_type), upper(pv_object), upper(pv_owner) ) definition
into v_def
FROM DUAL;

begin
SELECT dbms_metadata.get_dependent_ddl('OBJECT_GRANT', upper(pv_object), upper(pv_owner) ) definition 
into v_obj_grants
FROM DUAL;
exception
when others then
	null;
end;

if v_obj_grants is not null
then
	begin
		DBMS_LOB.APPEND ( v_def , v_obj_grants );
	exception
	when others then
		dbms_output.put_line('No object dependents');
	end;
end if;

/* send mail! */

	begin
		l_mail_conn := UTL_SMTP.open_connection(smtp_host, smtp_port);
		UTL_SMTP.helo(l_mail_conn, smtp_host);
		UTL_SMTP.mail(l_mail_conn, v_sender);
		UTL_SMTP.rcpt(l_mail_conn, v_recipient);
	
		UTL_SMTP.open_data(l_mail_conn);
		UTL_SMTP.write_data(l_mail_conn, 'Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || UTL_TCP.crlf);
		UTL_SMTP.write_data(l_mail_conn, 'To: ' || v_recipient || UTL_TCP.crlf);
		UTL_SMTP.write_data(l_mail_conn, 'From: ' || v_body_from ||'<'||v_sender||'>'|| UTL_TCP.crlf);
		UTL_SMTP.write_data(l_mail_conn, 'Subject: ' || v_subject || UTL_TCP.crlf);
		UTL_SMTP.write_data(l_mail_conn, 'Reply-To: ' || v_sender || UTL_TCP.crlf);
		UTL_SMTP.write_data(l_mail_conn, 'MIME-Version: 1.0' || UTL_TCP.crlf);
		UTL_SMTP.write_data(l_mail_conn, 'Content-Type: multipart/alternative; boundary="' || l_boundary || '"' || UTL_TCP.crlf || UTL_TCP.crlf);
		
		UTL_SMTP.write_data(l_mail_conn, '--' || l_boundary || UTL_TCP.crlf);
		UTL_SMTP.write_data(l_mail_conn, 'Content-Type: text/html; charset="iso-8859-1"' || UTL_TCP.crlf || UTL_TCP.crlf);
	
		UTL_SMTP.write_data(l_mail_conn, pv_owner||'.'||pv_object||' Definition '|| UTL_TCP.crlf || UTL_TCP.crlf);
		
		UTL_SMTP.write_data(l_mail_conn, '--' || l_boundary || UTL_TCP.crlf);
		UTL_SMTP.write_data(l_mail_conn, 'Content-Type: ' || null || '; name="' || pv_owner||'.'||pv_object||'.sql' || '"' || UTL_TCP.crlf);
		UTL_SMTP.write_data(l_mail_conn, 'Content-Disposition: attachment; filename="' || pv_owner||'.'||pv_object||'.sql' || '"' || UTL_TCP.crlf || UTL_TCP.crlf);
		
		FOR i IN 0 .. TRUNC((DBMS_LOB.getlength(v_def) - 1 )/l_step) 
		LOOP
			UTL_SMTP.write_data(l_mail_conn, DBMS_LOB.substr(v_def, l_step, i * l_step + 1));
		END LOOP;
		
		UTL_SMTP.write_data(l_mail_conn, UTL_TCP.crlf || UTL_TCP.crlf);
		UTL_SMTP.write_data(l_mail_conn, '--' || l_boundary || '--' || UTL_TCP.crlf);
	
		UTL_SMTP.close_data(l_mail_conn);
		
		UTL_SMTP.quit(l_mail_conn);
	exception
	when others then
		dbms_output.put_line('Error sending email to '||v_recipient||' -> '||SQLERRM);
	end;
				
				
exception
when others then
	dbms_output.put_line('Error looking for -> Obj: '||' -> '||SQLERRM);
end;
/
