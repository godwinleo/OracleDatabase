set serveroutput on
set long 1000000000
set arraysize 5000

accept taskname char PROMPT 'Tuning Task name	:	'
accept addr		char PROMPT 'Send e-mail to		:	'

declare
v_task   varchar2(200) := '&taskname';
v_report clob;

v_recipient varchar2(100):='&addr';
v_from varchar2 (300) := 'mariano.raul.quidiello@citi.com';
v_body_from varchar2 (300) := 'FinTech Appl DB SME Team';
v_subject varchar2 (300) := 'Tune Taks Report - '||v_task;

l_mail_conn   UTL_SMTP.connection;
smtp_host varchar2(100) := '150.110.179.107';
smtp_port number := 25;
l_boundary    VARCHAR2(50) := '----=*#abc1234321cba#*=';
l_step        PLS_INTEGER  := 12000;

begin

	v_report := DBMS_SQLTUNE.report_TUNING_TASK( v_task );
	
	--Send mail
	begin
		l_mail_conn := UTL_SMTP.open_connection(smtp_host, smtp_port);
		UTL_SMTP.helo(l_mail_conn, smtp_host);
		UTL_SMTP.mail(l_mail_conn, v_from);
		UTL_SMTP.rcpt(l_mail_conn, v_recipient);
	
		UTL_SMTP.open_data(l_mail_conn);
		UTL_SMTP.write_data(l_mail_conn, 'Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || UTL_TCP.crlf);
		UTL_SMTP.write_data(l_mail_conn, 'To: ' || v_recipient || UTL_TCP.crlf);
		UTL_SMTP.write_data(l_mail_conn, 'From: ' || v_body_from ||'<'||v_from||'>'|| UTL_TCP.crlf);
		UTL_SMTP.write_data(l_mail_conn, 'Subject: ' || v_subject || UTL_TCP.crlf);
		UTL_SMTP.write_data(l_mail_conn, 'Reply-To: ' || v_from || UTL_TCP.crlf);
		UTL_SMTP.write_data(l_mail_conn, 'MIME-Version: 1.0' || UTL_TCP.crlf);
		UTL_SMTP.write_data(l_mail_conn, 'Content-Type: multipart/alternative; boundary="' || l_boundary || '"' || UTL_TCP.crlf || UTL_TCP.crlf);
		
		UTL_SMTP.write_data(l_mail_conn, '--' || l_boundary || UTL_TCP.crlf);
		UTL_SMTP.write_data(l_mail_conn, 'Content-Type: text/html; charset="iso-8859-1"' || UTL_TCP.crlf || UTL_TCP.crlf);
	
		UTL_SMTP.write_data(l_mail_conn, '<3' || UTL_TCP.crlf || UTL_TCP.crlf);
		
		UTL_SMTP.write_data(l_mail_conn, '--' || l_boundary || UTL_TCP.crlf);
		UTL_SMTP.write_data(l_mail_conn, 'Content-Type: ' || null || '; name="' || v_task||'.sql' || '"' || UTL_TCP.crlf);
		UTL_SMTP.write_data(l_mail_conn, 'Content-Disposition: attachment; filename="' || v_task||'.sql' || '"' || UTL_TCP.crlf || UTL_TCP.crlf);
		
		FOR i IN 0 .. TRUNC((DBMS_LOB.getlength(v_report) - 1 )/l_step) 
		LOOP
			UTL_SMTP.write_data(l_mail_conn, DBMS_LOB.substr(v_report, l_step, i * l_step + 1));
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
	dbms_output.put_line('Error running report -> '||SQLERRM);
end;
/
